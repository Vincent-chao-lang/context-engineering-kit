# Context Engineering 开发指南

> 真正高级的 AI 编程，不是"怎么提问"，而是"怎么管理上下文"。

## 一、核心理念

### 1.1 问题：AI 会失忆

大语言模型没有持久记忆。每次新会话，AI 对项目一无所知。这意味着：

- 上次讨论的架构决策，这次忘了
- 昨天修的 bug，今天可能重犯
- 上周否决的方案，这周又提出来
- 上下文窗口有限，聊多了前面的内容会被压缩

### 1.2 解法：状态外置化

核心思想来自软件工程：

```
配置外置  →  项目状态写入文件，不依赖 AI 记忆
状态持久化  →  每次会话通过文件恢复上下文
版本控制  →  Git 记录演化历史，AI 可读可回溯
```

把 AI 当成一个**很聪明但没有记忆的同事**。你不会期望新同事记住所有事情——你会给他写文档。

### 1.3 Context Engineering 的三个层次

```
Level 1 — Prompt Engineering：怎么写好一条指令
Level 2 — Context Engineering：怎么管理整个项目的上下文
Level 3 — Agent Engineering：  怎么让 AI 自主执行复杂任务
```

本指南聚焦 Level 2。

---

## 二、目录结构

每个 AI 协作项目推荐以下结构：

```
project/
├── README.md              # 项目入口文档
├── CLAUDE.md              # AI 项目说明书（每次会话必读）
├── AGENTS.md              # 通用 Agent 工作规则
├── ARCHITECTURE.md        # 架构文档（系统设计、数据流）
├── TASKS.md               # 任务追踪（进行中/待办/已完成）
├── DECISIONS.md           # 决策日志（为什么做这个选择）
├── memory/                # 实时状态（频繁更新）
│   ├── current_state.md   # 当前状态快照
│   ├── bugs.md            # Bug 记录
│   ├── experiments.md     # 实验记录
│   ├── lessons_learned.md # 踩坑记录
│   └── daily_log.md       # 每日工作日志
├── prompts/               # 编码规范（稳定，少更新）
│   ├── common/            # 通用编码规则和审查清单
│   ├── typescript/        # TypeScript 风格指南
│   ├── python/            # Python 风格指南
│   └── backend/           # 后端专项审查清单
└── src/                   # 源代码
```

### 2.1 文件分类

| 类型 | 文件 | 更新频率 | 谁写 |
|------|------|----------|------|
| **核心文档** | CLAUDE.md, AGENTS.md, ARCHITECTURE.md | 低（架构变更时） | 人 + AI |
| **决策记录** | DECISIONS.md | 中（做决策时） | 人 + AI |
| **任务管理** | TASKS.md | 高（每天） | AI 维护 |
| **实时状态** | memory/* | 高（每次会话） | AI 维护 |
| **编码规范** | prompts/* | 低（很少变） | 人定义 |

### 2.2 设计原则

- **CLAUDE.md 是入口**：AI 每次必读，是"入职培训"
- **AGENTS.md 是通用入口**：让 Codex 或其他 Agent 工具知道如何读取项目上下文
- **DECISIONS.md 防推翻**：记录"为什么"，避免 AI 反复提已被否决的方案
- **memory/ 是短期记忆**：频繁更新，反映当前状态
- **prompts/ 是长期规范**：很少变，定义项目标准
- **Git 是演化历史**：小步提交，AI 可以通过 git log 理解系统演化

---

## 三、文件详解

### 3.1 CLAUDE.md — AI 的入职培训

这是最重要的文件。每次会话开始，AI 首先读取它。

**包含内容：**
```markdown
# 项目目标          → 一句话说清楚项目是什么
# 当前阶段          → 现在在做什么（Phase 1/2/3）
# 技术栈            → 语言、框架、关键依赖
# 命令              → dev / build / test
# 编码原则          → 3-5 条最重要的规则
# 当前重点          → 最近在做什么（基于 git log 更新）
# 关键文件          → 哪些文件最重要
```

**编写原则：**
- 控制在 100 行以内，过长 AI 会忽略关键信息
- 只写 AI 必须知道的内容，不写人类文档
- 随项目演进更新"当前重点"部分

### 3.2 ARCHITECTURE.md — 系统全景图

**包含内容：**
- 技术栈表格
- 系统架构图（ASCII）
- 目录结构说明
- 核心模块职责
- 数据流描述
- 外部依赖

**价值：**
- AI 理解"改这里会影响哪里"
- 新会话不需要从零探索代码结构
- 避免破坏性修改

### 3.2.1 AGENTS.md — 通用 Agent 工作规则

`AGENTS.md` 面向 Codex 和其他支持仓库级 instructions 的 AI 编程工具。它不替代 `CLAUDE.md`，而是告诉工具：

- 开始工作前读哪些上下文文件
- 如何维护 `DECISIONS.md`、`TASKS.md` 和 `memory/`
- 收尾时应更新哪些状态文件

原则：项目事实仍然放在 `CLAUDE.md`、`ARCHITECTURE.md`、`DECISIONS.md` 和 `memory/` 中，`AGENTS.md` 只写工作规则。

### 3.3 DECISIONS.md — 防推翻机制

**格式：**
```markdown
## D001 — 选择 SQLite 而非 MongoDB

**日期:** 2026-04
**决策:** 使用 SQLite 作为本地数据库
**原因:**
- 无需额外服务，零运维
- 桌面应用天然适合嵌入式数据库
- 数据隐私，不经过网络

**放弃:**
- MongoDB：需要安装服务，对桌面应用过重
- localStorage：不支持复杂查询
```

**关键：写"放弃"部分**。这是防止 AI 反复提出被否方案的核心。当 AI 说"建议用 MongoDB"时，你只需要说"查看 DECISIONS.md D001"。

### 3.4 TASKS.md — 任务追踪

简单的三段式：
```
## 进行中 → 正在做的
## 待办   → 按优先级排列
## 已完成 → 保留最近 10 条
```

不需要复杂的 issue tracker。保持简单。

### 3.5 memory/ — 短期记忆

#### current_state.md
最重要的 memory 文件。**每次下班前必须更新。**

```markdown
# 当前状态

## 已完成
- 发票上传和识别
- 邮箱 IMAP 采集
- 增值税计算

## 当前问题
- PDF 解析偶发乱码
- 免费模型 1 QPS 限速明显

## 下次优先
1. 增加批量识别进度条
2. 支持更多发票类型
```

下次会话 AI 读这个文件，30 秒恢复上下文。

#### bugs.md
活跃 Bug 和已修复记录。防止 AI "忘记"已知问题。

#### experiments.md
记录实验。避免"上次试过方案 A 不行，这次又试一遍"。

#### lessons_learned.md
踩坑记录。格式固定：现象 → 根因 → 解决 → 教训。

#### daily_log.md
每日简要日志。回溯问题时非常有用。

### 3.6 prompts/ — 编码规范

这些文件分别定义"怎么写代码"的规则：

- **prompts/common/coding_rules.md**：跨技术栈编码硬规则（错误处理、安全、性能）
- **prompts/common/review_checklist.md**：通用提交前检查清单
- **prompts/typescript/style_guide.md**：TypeScript/前端项目风格指南
- **prompts/python/style_guide.md**：Python 项目风格指南
- **prompts/backend/review_checklist.md**：后端、API、数据层专项审查清单

这些文件很少变化，但 AI 在实现和审查前应按项目技术栈选择性参考。

---

## 四、日常工作流

### 4.1 每日循环

```
┌─────────────────────────────────────────────┐
│                                             │
│  ┌─────────┐     ┌──────────┐    ┌───────┐ │
│  │ /start  │────▶│   编码   │───▶│ /wrap │ │
│  │ 恢复上下文│     │  工作    │    │ 收尾  │ │
│  └─────────┘     └──────────┘    └───────┘ │
│       │                               │     │
│       ▼                               ▼     │
│  读取文档                        更新 memory │
│  总结状态                        更新 TASKS  │
│  列出待办                        写日志      │
│                                             │
└─────────────────────────────────────────────┘
```

### 4.2 /start — 开始工作

输入 `/start`，AI 自动：
1. 读取 CLAUDE.md、ARCHITECTURE.md、DECISIONS.md
2. 运行 `git log --oneline -10` 了解最近变更
3. 运行 `git status` 查看未提交工作
4. 输出：一句话当前状态 + 最近工作 + 待处理变更 + 下一步建议
5. **不修改任何代码**，等待你的指令

### 4.3 工作中 — 保持纪律

**Git 小步提交：**
```bash
git commit -m "feat: add email attachment download"
git commit -m "fix: resolve PDF parsing encoding issue"
git commit -m "refactor: extract invoice number validation"
```

每次提交代表一个有意义的变更。AI 可以通过 `git log` 理解系统演化。

**技术决策及时记录：**
当讨论中做出重要技术选择时，立即追加到 DECISIONS.md。

**踩坑及时记录：**
遇到非显而易见的问题，追加到 memory/lessons_learned.md。

### 4.4 /wrap — 下班收尾

输入 `/wrap`，AI 自动：
1. 查看今天的 git 提交和未提交变更
2. 更新 `memory/current_state.md`（已完成、当前问题、下次优先）
3. 追加 `memory/daily_log.md` 今日日志
4. 更新 `memory/bugs.md`（修复的标记、新发现的加入）
5. 更新 `TASKS.md`（完成移走、新增补上）
6. 输出今日总结

---

## 五、高级技巧

### 5.1 自定义命令模板

在 `.claude/commands/` 下创建常用命令模板：

```
.claude/commands/
├── start.md          # 恢复工作上下文
├── wrap.md           # 下班自动总结
├── init-context.md   # 新项目初始化骨架
└── [项目专属命令]     # 如 recognize_invoice.md
```

命令模板的好处：
- **一致性**：每次执行相同流程，不会遗漏步骤
- **效率**：一条命令代替长段 prompt
- **可迭代**：发现流程有问题，改模板即可

### 5.2 读取决策而非讨论

当 AI 提出一个你之前已经否决的方案时：

```
❌ "不要用 MongoDB"  →  AI 可能下次又提
✅ "查看 DECISIONS.md D003"  →  AI 读到原因后不会再提
```

### 5.3 让 AI 读 Git 历史

```bash
claude "阅读最近 10 个 commit，总结系统演化方向"
claude "查看 src/lib/zhipu-client.ts 的 git log，告诉我这个模块经历了哪些变更"
```

Git 是最好的上下文来源之一。

### 5.4 分层更新策略

```
                更新频率
    低 ◄──────────────────────► 高

  CLAUDE.md    DECISIONS.md    memory/current_state.md
  ARCHITECTURE  TASKS.md       memory/daily_log.md
  prompts/*                    memory/bugs.md
                               memory/lessons_learned.md
```

- **低频**（月/季度）：架构文档、编码规范
- **中频**（周）：任务列表、决策记录
- **高频**（每次会话）：memory 目录下的所有文件

### 5.5 Context Window 管理

上下文窗口是有限的。策略：

1. **CLAUDE.md 始终加载**：控制在 100 行以内
2. **ARCHITECTURE.md 按需加载**：只有涉及架构变更时才读
3. **memory/ 按需加载**：`/start` 时读 current_state，修 bug 时读 bugs
4. **DECISIONS.md 按需加载**：讨论方案时才读
5. **prompts/ 审查时加载**：代码审查前读 review_checklist

---

## 六、常见问题

### Q：这些文档会过时吗？

会。所以 `/wrap` 命令会更新 memory/，定期更新 CLAUDE.md 的"当前重点"。如果发现文档与代码不一致，信任代码。

### Q：需要所有文件都用吗？

不需要。最小可行集：`CLAUDE.md` + `memory/current_state.md` + `DECISIONS.md`。其他按需添加。

### Q：和 GitHub Issues / Jira 什么关系？

TASKS.md 是轻量替代。如果团队已有 issue tracker，TASKS.md 可以只记录 AI 需要关注的任务，不重复。

### Q：Claude Code 的 memory 和 memory/ 目录什么关系？

- Claude Code 内置 memory（`.claude/memory/`）：跨会话持久化，AI 自动管理
- 项目 `memory/` 目录：Context Engineering 体系的一部分，有明确结构

两者互补。内置 memory 存用户偏好和项目背景，项目 memory/ 存工作状态。

### Q：这套方法只适用于 Claude Code 吗？

不。核心思想（状态外置化、文档驱动）适用于任何 AI 编程工具。Claude Code 使用 `CLAUDE.md` 和 `.claude/commands/`；Codex 可以读取 `AGENTS.md`；Cursor 可迁移到 `.cursor/rules`；Windsurf 可迁移到 rules 文件。详见 `docs/tooling-guide.md`。

---

## 七、快速启动清单

新项目开始时：

- [ ] 运行 `install.sh` 安装命令和基础模板
- [ ] 在 Claude Code 中运行 `/init-context`，分析项目并生成/补齐上下文文件
- [ ] 检查 `CLAUDE.md`、`AGENTS.md`、`ARCHITECTURE.md` 和 `prompts/`
- [ ] 运行 `doctor.sh` 检查上下文文件健康状态
- [ ] 首次 `git commit` 建立基线

每次工作：

- [ ] 运行 `/start` 恢复上下文
- [ ] 小步 git commit
- [ ] 技术决策追加 DECISIONS.md
- [ ] 下班前运行 `/wrap` 收尾

### install.sh 和 /init-context 的区别

`install.sh` 是确定性的安装步骤，只复制命令模板和基础空模板，不分析项目代码。

`/init-context` 是智能初始化步骤，会读取当前项目，生成或补齐 `README.md`、`CLAUDE.md`、`AGENTS.md`、`ARCHITECTURE.md`、`prompts/` 等项目专属内容。

推荐流程：

```
install.sh → /init-context → /start / wrap（日常循环）
```

如果项目已经有 `CLAUDE.md`，`/init-context` 应读取并保留它，只补充缺失的 Context Engineering 约定；如果没有，则直接生成一个兼容 Claude Code 使用习惯的 `CLAUDE.md`。用户不需要额外先运行 Claude Code 官方 `/init`。

---

# Context Engineering Development Guide (English)

> The real leap in AI-assisted programming isn't "how to prompt" — it's "how to manage context."

## 1. Core Philosophy

### 1.1 The Problem: AI Has No Memory

Large language models have no persistent memory. Every new session, AI knows nothing about your project. This means:

- Architecture decisions from last session are forgotten this session
- Bugs fixed yesterday may be reintroduced today
- Proposals rejected last week are suggested again this week
- Context windows are limited; earlier content gets compressed as conversations grow

### 1.2 The Solution: Externalized State

The core idea comes from software engineering:

```
Externalize config  →  Write project state to files, don't rely on AI memory
Persist state       →  Restore context from files every session
Version control     →  Git records evolution history, AI can read and trace back
```

Treat AI like a **very smart but memoryless colleague**. You wouldn't expect a new colleague to remember everything — you'd write them documentation.

### 1.3 Three Levels of AI Programming

```
Level 1 — Prompt Engineering: How to write a good instruction
Level 2 — Context Engineering: How to manage an entire project's context
Level 3 — Agent Engineering:   How to let AI autonomously execute complex tasks
```

This guide focuses on Level 2.

---

## 2. Directory Structure

Every AI-collaboration project recommends the following structure:

```
project/
├── README.md              # Project overview document
├── CLAUDE.md              # AI project handbook (read every session)
├── AGENTS.md              # Universal agent working rules
├── ARCHITECTURE.md        # Architecture doc (system design, data flow)
├── TASKS.md               # Task tracking (in progress / to do / completed)
├── DECISIONS.md           # Decision log (why this choice was made)
├── memory/                # Real-time state (frequently updated)
│   ├── current_state.md   # Current state snapshot
│   ├── bugs.md            # Bug records
│   ├── experiments.md     # Experiment records
│   ├── lessons_learned.md # Lessons learned
│   └── daily_log.md       # Daily work log
├── prompts/               # Coding standards (stable, rarely updated)
│   ├── common/            # General coding rules and review checklists
│   ├── typescript/        # TypeScript style guide
│   ├── python/            # Python style guide
│   └── backend/           # Backend-specific review checklist
└── src/                   # Source code
```

### 2.1 File Classification

| Type | Files | Update frequency | Who writes |
|------|-------|------------------|------------|
| **Core docs** | CLAUDE.md, AGENTS.md, ARCHITECTURE.md | Low (on architectural changes) | Human + AI |
| **Decision records** | DECISIONS.md | Medium (when decisions are made) | Human + AI |
| **Task management** | TASKS.md | High (daily) | AI maintained |
| **Real-time state** | memory/* | High (every session) | AI maintained |
| **Coding standards** | prompts/* | Low (rarely changes) | Human defined |

### 2.2 Design Principles

- **CLAUDE.md is the entry point**: AI reads it every session, it's "onboarding"
- **AGENTS.md is the universal entry**: Lets Codex or other agent tools know how to read project context
- **DECISIONS.md prevents reversions**: Records "why", prevents AI from repeatedly suggesting rejected proposals
- **memory/ is short-term memory**: Frequently updated, reflects current state
- **prompts/ is long-term standards**: Rarely changes, defines project norms
- **Git is evolution history**: Small commits, AI can understand system evolution through git log

---

## 3. File Details

### 3.1 CLAUDE.md — AI's Onboarding Doc

This is the most important file. AI reads it first every session.

**Contents:**
```markdown
# Project Goals          → One sentence describing the project
# Current Phase          → What's happening now (Phase 1/2/3)
# Tech Stack             → Languages, frameworks, key dependencies
# Commands               → dev / build / test
# Coding Principles      → 3-5 most important rules
# Current Focus          → What's been worked on recently (updated from git log)
# Key Files              → Which files are most important
```

**Writing principles:**
- Keep under 100 lines; longer and AI ignores key info
- Only write what AI must know, not human documentation
- Update "Current Focus" as the project evolves

### 3.2 ARCHITECTURE.md — System Panorama

**Contents:**
- Tech stack table
- System architecture diagram (ASCII)
- Directory structure explanation
- Core module responsibilities
- Data flow description
- External dependencies

**Value:**
- AI understands "changing here affects there"
- New sessions don't need to explore code structure from zero
- Prevents destructive modifications

### 3.2.1 AGENTS.md — Universal Agent Working Rules

`AGENTS.md` targets Codex and other AI programming tools that support repo-level instructions. It doesn't replace `CLAUDE.md` but tells tools:

- Which context files to read before starting work
- How to maintain `DECISIONS.md`, `TASKS.md`, and `memory/`
- Which state files to update when wrapping up

Principle: Project facts remain in `CLAUDE.md`, `ARCHITECTURE.md`, `DECISIONS.md`, and `memory/`. `AGENTS.md` only contains working rules.

### 3.3 DECISIONS.md — Anti-Reversion Mechanism

**Format:**
```markdown
## D001 — Chose SQLite over MongoDB

**Date:** 2026-04
**Decision:** Use SQLite as local database
**Reasons:**
- No extra service needed, zero ops
- Desktop apps naturally suit embedded databases
- Data privacy, no network transit

**Rejected:**
- MongoDB: Requires installing a service, overkill for desktop apps
- localStorage: Doesn't support complex queries
```

**Key: Write the "Rejected" section.** This is the core mechanism for preventing AI from repeatedly suggesting rejected proposals. When AI says "suggest using MongoDB", you just say "check DECISIONS.md D001".

### 3.4 TASKS.md — Task Tracking

Simple three-section format:
```
## In Progress → Currently being worked on
## To Do       → Prioritized
## Completed   → Keep last 10
```

No need for a complex issue tracker. Keep it simple.

### 3.5 memory/ — Short-Term Memory

#### current_state.md
The most important memory file. **Must be updated before every wrap-up.**

```markdown
# Current State

## Completed
- Invoice upload and recognition
- Email IMAP collection
- VAT calculation

## Current Issues
- PDF parsing occasionally garbled
- Free model 1 QPS rate limiting noticeable

## Next Priorities
1. Add batch recognition progress bar
2. Support more invoice types
```

AI reads this file next session and restores context in ~30 seconds.

#### bugs.md
Active bugs and fixed records. Prevents AI from "forgetting" known issues.

#### experiments.md
Records experiments. Avoids "tried approach A last time, it didn't work, trying again this time".

#### lessons_learned.md
Gotcha records. Fixed format: Symptom → Root Cause → Fix → Lesson.

#### daily_log.md
Brief daily log. Very useful when tracing problems.

### 3.6 prompts/ — Coding Standards

These files define "how to write code" rules:

- **prompts/common/coding_rules.md**: Cross-stack hard coding rules (error handling, security, performance)
- **prompts/common/review_checklist.md**: General pre-commit checklist
- **prompts/typescript/style_guide.md**: TypeScript/frontend style guide
- **prompts/python/style_guide.md**: Python style guide
- **prompts/backend/review_checklist.md**: Backend, API, data layer review checklist

These files rarely change, but AI should reference them selectively during implementation and review.

---

## 4. Daily Workflow

### 4.1 Daily Loop

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  ┌─────────┐     ┌──────────┐    ┌───────────┐ │
│  │ /start  │────▶│  Coding  │───▶│  /wrap    │ │
│  │ Restore │     │  Work    │    │  Wrap up  │ │
│  └─────────┘     └──────────┘    └───────────┘ │
│       │                               │         │
│       ▼                               ▼         │
│  Read docs                      Update memory   │
│  Summarize state                Update TASKS    │
│  List to-dos                    Write log       │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 4.2 /start — Beginning Work

Type `/start` and AI automatically:
1. Reads CLAUDE.md, ARCHITECTURE.md, DECISIONS.md
2. Runs `git log --oneline -10` to understand recent changes
3. Runs `git status` to see uncommitted work
4. Outputs: one-sentence current state + recent work + pending changes + next step suggestions
5. **Does not modify any code**, waits for your instructions

### 4.3 During Work — Maintain Discipline

**Git small commits:**
```bash
git commit -m "feat: add email attachment download"
git commit -m "fix: resolve PDF parsing encoding issue"
git commit -m "refactor: extract invoice number validation"
```

Each commit represents a meaningful change. AI can understand system evolution through `git log`.

**Record technical decisions promptly:**
When important technical choices are made in discussion, immediately append to DECISIONS.md.

**Record gotchas promptly:**
When encountering non-obvious problems, append to memory/lessons_learned.md.

### 4.4 /wrap — End of Day Wrap-Up

Type `/wrap` and AI automatically:
1. Checks today's git commits and uncommitted changes
2. Updates `memory/current_state.md` (completed, current issues, next priorities)
3. Appends today's log to `memory/daily_log.md`
4. Updates `memory/bugs.md` (marks fixed, adds new discoveries)
5. Updates `TASKS.md` (moves completed, adds new)
6. Outputs today's summary

---

## 5. Advanced Tips

### 5.1 Custom Command Templates

Create common command templates under `.claude/commands/`:

```
.claude/commands/
├── start.md          # Restore work context
├── wrap.md           # End-of-day auto summary
├── init-context.md   # New project init skeleton
└── [project-specific commands]  # e.g., recognize_invoice.md
```

Benefits of command templates:
- **Consistency**: Same process every time, no missed steps
- **Efficiency**: One command replaces long prompts
- **Iterable**: Fix process issues by editing the template

### 5.2 Read Decisions Instead of Discussing

When AI suggests a proposal you've previously rejected:

```
❌ "Don't use MongoDB"  →  AI might suggest it again next time
✅ "Check DECISIONS.md D003"  →  AI reads the reasons and won't suggest it again
```

### 5.3 Let AI Read Git History

```bash
claude "Read the last 10 commits, summarize the system evolution direction"
claude "Check git log of src/lib/zhipu-client.ts, tell me what changes this module has been through"
```

Git is one of the best sources of context.

### 5.4 Tiered Update Strategy

```
                    Update frequency
    Low ◄──────────────────────► High

  CLAUDE.md    DECISIONS.md    memory/current_state.md
  ARCHITECTURE  TASKS.md       memory/daily_log.md
  prompts/*                    memory/bugs.md
                               memory/lessons_learned.md
```

- **Low frequency** (monthly/quarterly): Architecture docs, coding standards
- **Medium frequency** (weekly): Task lists, decision records
- **High frequency** (every session): All files under memory/

### 5.5 Context Window Management

Context windows are limited. Strategy:

1. **CLAUDE.md always loaded**: Keep under 100 lines
2. **ARCHITECTURE.md loaded on demand**: Only read when architecture changes are involved
3. **memory/ loaded on demand**: Read `current_state` at `/start`, read `bugs` when fixing bugs
4. **DECISIONS.md loaded on demand**: Only read when discussing approaches
5. **prompts/ loaded during review**: Read `review_checklist` before code reviews

---

## 6. FAQ

### Q: Will these docs go stale?

Yes. That's why `/wrap` updates memory/ and you periodically update CLAUDE.md's "Current Focus". If docs conflict with code, trust the code.

### Q: Do I need all files?

No. Minimum viable set: `CLAUDE.md` + `memory/current_state.md` + `DECISIONS.md`. Add others as needed.

### Q: How does this relate to GitHub Issues / Jira?

TASKS.md is a lightweight alternative. If the team already has an issue tracker, TASKS.md can just record tasks AI needs to focus on, avoiding duplication.

### Q: What's the relationship between Claude Code's memory and the memory/ directory?

- Claude Code built-in memory (`.claude/memory/`): Cross-session persistence, AI-managed
- Project `memory/` directory: Part of the Context Engineering system, with clear structure

They complement each other. Built-in memory stores user preferences and project background; project memory/ stores work state.

### Q: Does this only work with Claude Code?

No. The core ideas (externalized state, document-driven) apply to any AI programming tool. Claude Code uses `CLAUDE.md` and `.claude/commands/`; Codex reads `AGENTS.md`; Cursor migrates to `.cursor/rules`; Windsurf uses rules files. See `docs/tooling-guide.md` for details.

---

## 7. Quick Start Checklist

Starting a new project:

- [ ] Run `install.sh` to install commands and base templates
- [ ] Run `/init-context` in Claude Code to analyze project and generate/supplement context files
- [ ] Review `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md`, and `prompts/`
- [ ] Run `doctor.sh` to check context file health
- [ ] First `git commit` to establish baseline

Every work session:

- [ ] Run `/start` to restore context
- [ ] Small git commits
- [ ] Append technical decisions to DECISIONS.md
- [ ] Run `/wrap` before ending work

### install.sh vs /init-context

`install.sh` is a deterministic installation step that only copies command templates and base empty templates without analyzing project code.

`/init-context` is an intelligent initialization step that reads the current project and generates or supplements `README.md`, `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md`, `prompts/` with project-specific content.

Recommended flow:

```
install.sh → /init-context → /start / wrap (daily loop)
```

If the project already has `CLAUDE.md`, `/init-context` should read and preserve it, only supplementing missing Context Engineering conventions. If none exists, it generates a `CLAUDE.md` compatible with Claude Code usage patterns. Users don't need to separately run the official Claude Code `/init` first.
