# Context Engineering Kit 使用指南

## 为什么需要这套工具

用 AI 写代码的人都会遇到同一个问题：**AI 没有持久记忆。**

每次开新会话，AI 对项目一无所知。上次讨论的架构决策，这次忘了；昨天修的 bug，今天可能重犯；上周否决的方案，这周又提出来。你不得不反复解释项目背景，浪费大量时间在"恢复上下文"上。

这个问题的根源不是 AI 不够聪明，而是我们缺少一种**把项目状态稳定地传递给 AI 的机制**。

Prompt Engineering 解决的是"怎么写好一条指令"。但一条指令再好，也承载不了整个项目的上下文——架构决策、当前进度、已知 bug、踩过的坑、被否决的方案……这些信息远超一个 prompt 的容量。

真正需要做的是 **Context Engineering**——管理整个项目的上下文，让 AI 每次都能快速、准确地理解项目现状。

核心思路很简单，来自软件工程的一条老原则：**配置外置**。把项目状态写入文件，不依赖 AI 的记忆；每次会话通过文件恢复上下文，不靠对话历史。就像你不会期望新同事记住所有事情——你会给他写文档。

这套 kit 就是把这套思路落地的工具。它不替你写代码，而是解决一个更基础的问题：**让 AI 在每次会话开始时，像一个熟悉项目的同事一样投入工作，而不是一个陌生人从零开始。**

具体来说，它做了三件事：

1. **状态外置化** — 项目进度、技术决策、已知问题全部写入文件，AI 读取文件即可恢复上下文
2. **闭环工作流** — `/start` 读上下文、编码、`/wrap` 写上下文，形成每日循环，状态持续积累
3. **决策留痕** — 记录"为什么"和"放弃了什么"，防止 AI 反复提已被否决的方案

从个人开发到团队协作，这套机制同样适用。个人模式下 AI 只需恢复一个人的状态；团队模式下 AI 还能看到其他成员在做什么，避免冲突和重复工作。

下面的内容会详细介绍这套工具的结构、用法和最佳实践。

---

## 概述

这是一套 AI 辅助编程的项目上下文管理工具包，核心理念是"状态外置化"——把项目状态写入文件，让 AI 每次通过文件恢复上下文，而不是依赖记忆。

### 目录结构

```
context-engineering-kit/
├── install.sh              # 安装脚本，复制命令和模板到目标项目
├── doctor.sh               # 健康检查，验证上下文文件是否齐全/过期
├── README.md               # 快速开始
├── commands/               # Claude Code 斜杠命令模板
│   ├── init-context.md     #   /init-context — 新项目首次初始化
│   ├── start.md            #   /start — 每天开始工作，恢复上下文
│   └── wrap.md             #   /wrap — 每天下班，总结并更新状态文件
├── templates/              # 纯空模板（install.sh 复制到目标项目）
│   ├── AGENTS.md           #   通用 Agent 工作规则（兼容 Codex 等）
│   ├── TASKS.md            #   任务追踪模板
│   ├── DECISIONS.md        #   决策日志模板
│   ├── memory/             #   短期状态文件模板
│   │   ├── current_state.md
│   │   ├── bugs.md
│   │   ├── experiments.md
│   │   ├── lessons_learned.md
│   │   └── daily_log.md
│   └── prompts/            #   编码规范模板
│       ├── common/         #   通用编码规则、审查清单
│       ├── typescript/     #   TS 风格指南
│       ├── python/         #   Python 风格指南
│       └── backend/        #   后端审查清单
└── docs/
    ├── usage-guide.md               使用手册
    ├── context-engineering-guide.md  完整开发指南（最详细的文档）
    └── tooling-guide.md              跨工具适配（Cursor/Windsurf/Codex）
```

### 三个核心命令

| 命令 | 场景 | 做什么 |
|------|------|--------|
| `/init-context` | 新项目首次 | 分析代码 → 生成 CLAUDE.md、ARCHITECTURE.md 等 |
| `/start` | 每天上班 | 读文档 + git 状态 → 30 秒恢复上下文 |
| `/wrap` | 每天下班 | 总结今天 → 更新 memory/ 文件 → 写日志 |

### 日常工作流

```
/start → 编码工作 → /wrap → (循环)
```

### 关键设计

1. **CLAUDE.md** — AI 的"入职培训"，每次会话必读，控制在 100 行内
2. **DECISIONS.md** — 记录"为什么"和"放弃了什么"，防止 AI 反复提已否决的方案
3. **memory/** — 高频更新的短期状态（当前进度、bug、日志）
4. **prompts/** — 低频变化的编码规范（人类定义）
5. **分层更新**：文档按频率分三层——架构/规范（月级）→ 决策/任务（周级）→ memory（每次会话）

### 模板可自定义

Kit 提供的所有模板（`commands/`、`templates/`、`prompts/`）都是起点，不是约束。你可以根据项目和个人习惯自由调整：

- `commands/` 下的命令模板可以修改步骤、增删检查项
- `templates/memory/` 的文件格式可以按需增减字段
- `prompts/` 的编码规范应该反映你项目的真实风格
- 甚至文件本身也可以增删——不需要的文件直接删掉，缺少的文件自己加

原则：**模板服务于你的工作流，不是反过来。**

### install.sh vs /init-context

- `install.sh` 是确定性安装：只复制命令模板和空模板，不分析代码
- `/init-context` 是智能初始化：读取项目代码，生成项目专属的 CLAUDE.md 等文件

简单说，这套工具解决了 AI 编程的核心痛点——AI 没有持久记忆。通过文件体系让 AI 每次开新会话都能快速"恢复记忆"，而不是从零开始。

### 记忆体谁来维护

大部分由 AI 自动维护，人只做审核和少数决策。

**自动维护（AI 做）：**

- `memory/` 下的所有文件：`/wrap` 命令自动根据 git log 和工作状态更新 `current_state.md`、`daily_log.md`、`bugs.md`、`lessons_learned.md`
- `TASKS.md`：`/wrap` 自动把完成的移走、新增的补上
- 上下文恢复：`/start` 自动读取所有文件，30 秒恢复状态

**人工维护（人做）：**

- `CLAUDE.md`：项目核心信息，人审阅确认
- `DECISIONS.md`：技术决策由人拍板，但记录可以 AI 辅助写入
- `prompts/`：编码规范由人定义，很少变

**实际工作流：**

```
你：/start          ← AI 自动恢复上下文，不需要你做什么
你：编码工作        ← 正常写代码，小步 git commit
你：/wrap           ← AI 自动总结、更新所有 memory 文件
```

人唯一需要主动做的是做技术决策时告诉 AI 记一下（比如"把这个决策记到 DECISIONS.md"），以及偶尔审阅 AI 生成的文档是否准确。本质上，人只管"做什么"和"为什么这么做"，"记住状态"这件事完全交给 AI 和文件体系。

---

## 详细使用指南

这份指南按实际使用顺序组织：安装工具、初始化项目、日常开发管理、诊断和完善项目上下文。

## 1. 安装工具

进入你的目标项目根目录：

```bash
cd /path/to/your-project
```

运行安装脚本：

```bash
/path/to/context-engineering-kit/install.sh
```

也可以从任意目录指定目标项目：

```bash
/path/to/context-engineering-kit/install.sh /path/to/your-project
```

安装完成后，项目里会出现：

```text
.claude/commands/init-context.md
.claude/commands/start.md
.claude/commands/wrap.md
AGENTS.md
TASKS.md
DECISIONS.md
memory/
prompts/
```

说明：

- `install.sh` 只复制命令和基础模板，不分析项目代码。
- 项目专属的 `CLAUDE.md`、`ARCHITECTURE.md`、README 增强内容由下一步 `/init-context` 生成或补齐。

## 2. 初始化项目上下文

在目标项目中启动 Claude Code：

```bash
cd /path/to/your-project
claude
```

进入 Claude Code 后运行：

```text
/init-context
```

`/init-context` 会做这些事：

- 读取项目配置，如 `package.json`、`pyproject.toml`、`Cargo.toml`、`go.mod`
- 扫描主要源码目录，如 `src/`、`app/`、`lib/`、`packages/`
- 读取已有 `README.md`、`CLAUDE.md`、`ARCHITECTURE.md`
- 查看最近 git 提交和当前工作区状态
- 创建或补齐 `CLAUDE.md`、`AGENTS.md`、`ARCHITECTURE.md`、`TASKS.md`、`DECISIONS.md`、`memory/`、`prompts/`

如果项目已经有 `CLAUDE.md`，`/init-context` 应保留原内容，只补充缺失的 Context Engineering 信息。你不需要额外先运行 Claude Code 官方 `/init`。

初始化后，人工快速检查这些文件：

- `CLAUDE.md`：项目目标、技术栈、运行命令是否正确
- `ARCHITECTURE.md`：模块划分和数据流是否符合真实代码
- `AGENTS.md`：Agent 启动和收尾规则是否符合你的团队习惯
- `prompts/`：是否保留了适合当前技术栈的规则
- `TASKS.md`：当前任务是否准确

检查无误后提交基线：

```bash
git add CLAUDE.md AGENTS.md ARCHITECTURE.md TASKS.md DECISIONS.md memory prompts .claude/commands
git commit -m "chore: initialize context engineering"
```

## 3. 日常开始工作

每次开始开发前，在 Claude Code 中运行：

```text
/start
```

`/start` 会读取：

- `CLAUDE.md`
- `ARCHITECTURE.md`
- `DECISIONS.md`
- `TASKS.md`
- `memory/current_state.md`
- `memory/bugs.md`
- 最近 git log
- 当前 git status

它应该输出：

- 项目当前阶段
- 上次工作重点
- 最近代码变更
- 待处理的未提交变更
- 当前待办
- 下一步建议

原则：`/start` 只恢复上下文，不修改代码。

## 4. 开发过程中的管理规则

开发时保持三件事同步。

第一，任务同步到 `TASKS.md`：

```markdown
## 进行中
- [ ] 实现用户登录错误提示

## 待办
- [ ] 增加登录失败重试限制

## 已完成
- [x] 接入登录 API
```

第二，重要技术决策写入 `DECISIONS.md`：

```markdown
## D002 — 使用 PostgreSQL 作为主数据库

**日期:** 2026-05
**决策:** 使用 PostgreSQL 存储业务数据。

**原因:**
- 需要事务和复杂查询
- 团队已有运维经验

**放弃:**
- MongoDB：当前业务关系型查询更多

**约束:**
- 新增数据模型必须包含迁移脚本
```

第三，问题和经验写入 `memory/`：

- 新 bug：写入 `memory/bugs.md`
- 尝试过但失败的方案：写入 `memory/experiments.md`
- 非显而易见的踩坑：写入 `memory/lessons_learned.md`
- 当前状态变化：由 `/wrap` 更新 `memory/current_state.md`

建议保持小步提交：

```bash
git commit -m "feat: add login error handling"
git commit -m "test: cover invalid login payload"
git commit -m "docs: record auth database decision"
```

## 5. 日常收尾

每天结束工作前，在 Claude Code 中运行：

```text
/wrap
```

`/wrap` 从三个维度收集信息，不单依赖 git log：

| 维度 | 来源 | 作用 |
|------|------|------|
| 已提交的变更 | `git log --oneline --since="today"` | 知道今天做了什么 |
| 未提交的变更 | `git diff --stat` + `git status` | 捕获还没 commit 的工作 |
| 历史状态 | `memory/*` + `TASKS.md` | 知道之前的状态，用于对比更新 |

具体执行步骤：

1. **收集当天变更**：运行 `git log`、`git diff --stat`、`git status`
2. **读取当前状态**：读取 `memory/current_state.md`、`memory/bugs.md`、`memory/daily_log.md`、`TASKS.md`
3. **更新文件**：
   - `memory/current_state.md` — 根据今天的 git 变更更新已完成/当前问题/下次优先，更新 `_最后更新` 日期
   - `memory/daily_log.md` — 在文件顶部追加今天的日志（完成/发现/明天）
   - `memory/bugs.md` — 修复的 bug 从「活跃 Bug」移到「已修复」，新发现的加入「活跃 Bug」
   - `memory/lessons_learned.md` — 如果踩了有价值的坑，追加一条记录
   - `TASKS.md` — 完成的任务移到「已完成」，未完成的保留或移回「待办」，新增必要的待办项
4. **输出总结**：今日完成、发现、明天计划、已更新文件列表

收尾后建议检查：

```bash
git diff -- memory TASKS.md
```

如果内容准确，提交当天上下文更新：

```bash
git add memory TASKS.md DECISIONS.md
git commit -m "docs: update project context"
```

## 6. 诊断项目上下文

运行健康检查：

```bash
/path/to/context-engineering-kit/doctor.sh /path/to/your-project
```

在目标项目根目录也可以运行：

```bash
/path/to/context-engineering-kit/doctor.sh
```

`doctor.sh` 会检查：

- 必要文件是否存在
- `.claude/commands` 是否完整
- `AGENTS.md` 是否存在
- 文件是否仍包含占位内容
- 当前模式对应的 `memory/*/current_state.md` 是否有更新时间、是否过旧
- `DECISIONS.md` 是否有重复编号

常见结果和处理方式：

```text
WARN: CLAUDE.md is missing; run /init-context after install to generate project-specific context
```

处理：这是刚安装但尚未初始化项目上下文时的正常提示。在 Claude Code 中运行 `/init-context`。

```text
WARN: memory/current_state.md has no parsable last update date
```

处理：运行 `/wrap`，或手动把最后一行改成：

```markdown
_最后更新: 2026-05-20_
```

```text
WARN: DECISIONS.md still appears to contain placeholder text
```

处理：把示例占位内容替换为真实决策；如果还没有决策，保留模板也可以，但第一次正式决策后应补齐。

```text
FAIL: duplicate decision IDs: D003
```

处理：打开 `DECISIONS.md`，把重复编号改成递增编号。

## 7. 定期完善

每周或每个里程碑后做一次上下文整理：

```bash
/path/to/context-engineering-kit/doctor.sh
```

然后检查：

- `CLAUDE.md` 是否仍能在 100 行以内说明项目重点
- `ARCHITECTURE.md` 是否反映真实模块结构
- `DECISIONS.md` 是否记录了关键取舍，尤其是被放弃方案
- `TASKS.md` 是否只保留当前有用任务
- `memory/bugs.md` 是否清理了已修复问题
- `prompts/` 是否还符合当前技术栈

## 8. 推荐工作流

新项目：

```text
install.sh
→ /init-context
→ 人工检查生成内容
→ git commit
```

每天开发：

```text
/start
→ 编码和小步提交
→ 记录决策、bug、踩坑
→ /wrap
→ git commit 上下文更新
```

定期治理：

```text
doctor.sh
→ 修复缺失、占位、过期、重复编号
→ 更新 CLAUDE.md / ARCHITECTURE.md / prompts/
```

## 9. 团队协作

### 9.1 安装团队模式

团队模式下，每位成员在本地独立安装，指定自己的用户名：

```bash
/path/to/context-engineering-kit/install.sh --team --user alice
```

`--team` 会做以下额外操作（solo 模式不会做）：

1. 创建 `memory/shared/`（团队共享状态）和 `memory/alice/`（个人状态）
2. 创建 `memory/TEAM.md`（团队成员状态表）
3. 在 `.gitignore` 追加 `memory/*/` `!memory/shared/`，排除个人 memory
4. 创建 `.gitattributes`，对 `DECISIONS.md` 等文件设置 `merge=union`

其他成员安装时各自用自己的用户名：

```bash
./install.sh --team --user bob
./install.sh --team --user carol
```

### 9.2 文件分类与冲突预防

| 文件 | 归属 | Git 策略 | 冲突风险 |
|------|------|----------|----------|
| `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md` | 共享 | 正常追踪 | 低（很少改） |
| `DECISIONS.md` | 共享 | `merge=union` | 低（追加写入） |
| `TASKS.md` | 共享 | 正常追踪 | 中（多人可能同时改） |
| `memory/TEAM.md` | 共享 | `merge=union` | 低（每人只改自己的行） |
| `memory/shared/` | 共享 | 正常追踪 | 中（整体状态） |
| `memory/{user}/` | 个人 | gitignored | 无（不在仓库中） |
| `prompts/` | 共享 | 正常追踪 | 低（很少改） |
| `.claude/commands/` | 共享 | 正常追踪 | 低（很少改） |

`merge=union` 的含义：git 合并时如果同一处有冲突，保留双方的修改而不是报错。这对追加写入的文件（`DECISIONS.md`、`TEAM.md`）是安全的。

### 9.3 memory/TEAM.md — 团队感知的核心

`TEAM.md` 是一张简单的表格，记录谁在做什么：

```markdown
| Member | Working On | Since | Status |
|--------|-----------|-------|--------|
| alice | 发票批量识别 | 2026-05-20 | in progress |
| bob | 邮箱采集功能 | 2026-05-20 | in progress |
| carol | VAT 计算优化 | 2026-05-19 | review |
```

- `/start` 时 AI 会读取这张表，展示团队上下文，如果有人和你改同一批文件会发出警告
- `/wrap` 时 AI 只更新你自己的那一行，不会改别人的
- 因为用了 `merge=union`，即使两个人同时 `/wrap` 也不会冲突

### 9.4 团队模式的日常工作流

每位成员的日常和 solo 模式一样，只是 AI 读写路径不同：

**`/start`：**
1. 读 `memory/TEAM.md` → 展示团队成员在做什么
2. 读 `memory/shared/current_state.md` → 团队整体进度
3. 读 `memory/{user}/current_state.md` → 你个人的上次状态
4. 如果有其他成员和你修改同一批文件，发出警告

**编码中：**
- 和 solo 模式完全一致：小步 git commit，决策追加 `DECISIONS.md`
- 如果涉及跨成员协作，在 `memory/TEAM.md` 的 Coordination Notes 中追加说明

**`/wrap`：**
1. 更新 `memory/{user}/` 下的个人文件（current_state、daily_log、bugs 等）
2. 更新 `memory/shared/current_state.md` 团队整体状态
3. 更新 `memory/TEAM.md` 你自己的行（Working On、Status）
4. 不碰其他成员的 `memory/{other_user}/`

### 9.5 团队模式的 doctor.sh 检查

```bash
/path/to/context-engineering-kit/doctor.sh /path/to/your-project
```

团队模式下额外检查：

- `memory/TEAM.md` 是否存在
- `memory/shared/` 目录是否存在
- 当前用户的 `memory/{user}/` 目录是否存在
- `.gitignore` 是否包含个人 memory 排除规则
- `.gitattributes` 是否包含 merge 策略

### 9.6 Solo 与 Team 切换

如果项目初期用 solo 模式，后来需要转为团队协作：

```bash
# 1. 用团队模式重新安装
/path/to/context-engineering-kit/install.sh --team --user alice

# 2. 手动迁移已有的 memory 文件
mkdir -p memory/alice
mv memory/current_state.md memory/alice/
mv memory/daily_log.md memory/alice/
mv memory/bugs.md memory/alice/
mv memory/experiments.md memory/alice/
mv memory/lessons_learned.md memory/alice/

# 3. 创建 shared/ 目录（从个人状态中提炼团队状态）
mkdir -p memory/shared
# 把项目整体进度写入 memory/shared/current_state.md
# 把团队可见的 bug 写入 memory/shared/bugs.md

# 4. 在 Claude Code 中运行 /init-context 重新生成上下文
```

## 10. Kit 升级

### 10.1 版本标识

Kit 使用语义化版本号，存储在 `VERSION` 文件中。每次 `install.sh` 安装时，会在项目根目录写入 `.cek` 元数据文件：

```json
{"version":"0.3.0","mode":"team","user":"alice","installed_at":"2026-05-20"}
```

所有命令通过读取 `.cek` 判断当前安装的版本和模式。

### 10.2 检查目标项目是否落后于当前本地 kit

```bash
/path/to/context-engineering-kit/doctor.sh /path/to/your-project
```

`doctor.sh` 会对比项目 `.cek` 中的版本与当前本地 kit 的 `VERSION` 文件；它不会联网检查远程最新版本。如果目标项目安装版本低于当前本地 kit，会输出：

```text
WARN: installed version 0.2.0, latest is 0.3.0 — run upgrade.sh
```

### 10.3 执行升级

```bash
/path/to/context-engineering-kit/upgrade.sh /path/to/your-project
```

`upgrade.sh` 会：

1. 读取 `.cek` 中的已安装版本和 kit 的 `VERSION` 文件
2. 展示两个版本之间的变更日志
3. 确认后执行升级

升级策略（保护你的自定义内容）：

| 文件类型 | 升级行为 | 原因 |
|----------|----------|------|
| `.claude/commands/` | **覆盖** | 命令模板很少被用户修改，新版本可能修复了命令逻辑 |
| 根级模板（AGENTS.md 等） | **跳过** | 已被 `/init-context` 改写为项目内容，覆盖会丢失 |
| `memory/` | **跳过已有文件，只创建新增模板** | 活跃工作文件不能覆盖，但新版本可能引入新模板 |
| `prompts/` | **跳过** | 用户可能已按项目风格自定义 |
| 新增的模板文件 | **创建** | kit 新版本可能引入新模板，只创建不存在的文件 |
| `.cek` | **更新版本号** | 保留模式、用户等其他字段 |

### 10.4 升级后验证

```bash
# 检查升级结果
/path/to/context-engineering-kit/doctor.sh /path/to/your-project

# 查看更新的 commands
git diff -- .claude/commands/

# 查看新增的文件
git status
```

### 10.5 版本号规则

Kit 遵循语义化版本（SemVer）：

- **主版本号（Major）**：不兼容的架构变更，如目录结构调整
- **次版本号（Minor）**：新增功能，如团队模式、新命令模板
- **修订号（Patch）**：bug 修复、文档更新

所有变更记录在 `CHANGELOG.md` 中，格式遵循 [Keep a Changelog](https://keepachangelog.com/)。

---

# Context Engineering Kit — Usage Guide (English)

## Why This Tool Exists

Anyone who uses AI to write code runs into the same problem: **AI has no persistent memory.**

Every new session, AI knows nothing about your project. Architecture decisions from last session? Forgotten. Bugs fixed yesterday? Might be reintroduced today. Proposals rejected last week? Suggested again this week. You waste significant time repeatedly explaining project context just to "get AI up to speed."

The root cause isn't that AI isn't smart enough — it's that we lack a mechanism to **reliably transfer project state to AI**.

Prompt Engineering solves "how to write a good instruction." But no matter how good an instruction is, it can't carry the full context of a project — architecture decisions, current progress, known bugs, lessons learned, rejected proposals... This information far exceeds what a single prompt can hold.

What's really needed is **Context Engineering** — managing the entire project's context so AI can quickly and accurately understand the current state every time.

The core idea is simple, borrowed from an old software engineering principle: **externalize configuration**. Write project state to files instead of relying on AI memory. Restore context from files every session instead of relying on chat history. Just like you wouldn't expect a new colleague to remember everything — you'd write them documentation.

This kit puts that idea into practice. It doesn't write code for you — it solves a more fundamental problem: **making AI start each session like a colleague who knows the project, not a stranger starting from zero.**

Specifically, it does three things:

1. **Externalized state** — Project progress, technical decisions, and known issues are all written to files. AI reads files to restore context.
2. **Closed-loop workflow** — `/start` reads context, you code, `/wrap` writes context. A daily cycle where state accumulates continuously.
3. **Decision trail** — Records "why" and "what was rejected", preventing AI from revisiting already-decided topics.

This mechanism works for both solo development and team collaboration. In solo mode, AI only needs to restore one person's state. In team mode, AI can also see what other members are working on, avoiding conflicts and duplicate effort.

---

## Overview

A project context management toolkit for AI-assisted programming. Core idea: "externalize state" — write project state to files so AI restores context from files every session instead of relying on memory.

### Directory Structure

```
context-engineering-kit/
├── install.sh              # Installer, copies commands and templates
├── doctor.sh               # Health checker
├── upgrade.sh              # Upgrader
├── VERSION                 # Version number
├── CHANGELOG.md            # Changelog
├── README.md               # Quick start
├── commands/               # Claude Code slash command templates
│   ├── init-context.md     #   /init-context — first-time project init
│   ├── start.md            #   /start — restore context at start of day
│   └── wrap.md             #   /wrap — summarize and update state at end of day
├── templates/              # Empty templates (copied to target project)
│   ├── AGENTS.md           #   Universal agent working rules
│   ├── TASKS.md            #   Task tracking template
│   ├── DECISIONS.md        #   Decision log template
│   ├── memory/             #   Short-term state templates
│   │   ├── current_state.md
│   │   ├── bugs.md
│   │   ├── experiments.md
│   │   ├── lessons_learned.md
│   │   └── daily_log.md
│   ├── prompts/            #   Coding standards templates
│   │   ├── common/         #   General coding rules, review checklists
│   │   ├── typescript/     #   TS style guide
│   │   ├── python/         #   Python style guide
│   │   └── backend/        #   Backend review checklist
│   └── team/               #   Team mode templates
│       ├── TEAM.md
│       ├── gitignore.append
│       └── gitattributes
└── docs/
    ├── usage-guide.md               This guide
    ├── context-engineering-guide.md  Full development guide
    └── tooling-guide.md              Cross-tool adaptation
```

### Three Core Commands

| Command | When | What it does |
|---------|------|--------------|
| `/init-context` | First time on new project | Analyzes code → generates/supplements context files |
| `/start` | Start of each work session | Reads docs + git status → restores context in ~30s |
| `/wrap` | End of each work session | Summarizes today → updates memory files → writes log |

### Daily Workflow

```
/start → coding work → /wrap → (loop)
```

### Key Design

1. **CLAUDE.md** — AI's "onboarding doc", read every session, kept under 100 lines
2. **DECISIONS.md** — Records "why" and "what was rejected", prevents AI from revisiting rejected proposals
3. **memory/** — High-frequency short-term state (progress, bugs, logs)
4. **prompts/** — Low-frequency coding standards (human-defined)
5. **Tiered updates**: Three tiers by frequency — architecture/standards (monthly) → decisions/tasks (weekly) → memory (every session)

### Templates Are Customizable

All templates provided by the kit (`commands/`, `templates/`, `prompts/`) are starting points, not constraints. Adjust freely:

- `commands/` templates can have steps added, removed, or modified
- `templates/memory/` file formats can have fields added or removed
- `prompts/` should reflect your project's actual coding style
- Files themselves can be added or removed — delete what you don't need, add what's missing

Principle: **Templates serve your workflow, not the other way around.**

### install.sh vs /init-context

- `install.sh` is deterministic: only copies command templates and empty templates, doesn't analyze code
- `/init-context` is intelligent: reads project code and generates project-specific CLAUDE.md, etc.

In short, this tool solves the core pain point of AI programming — AI has no persistent memory. Through a file system, AI can quickly "recover memory" every new session instead of starting from zero.

### Who Maintains the Memory

Most maintenance is done automatically by AI. Humans only review and make a few decisions.

**Auto-maintained (AI does):**

- All files under `memory/`: `/wrap` automatically updates `current_state.md`, `daily_log.md`, `bugs.md`, `lessons_learned.md` based on git log and work state
- `TASKS.md`: `/wrap` automatically moves completed items and adds new ones
- Context restoration: `/start` automatically reads all files, restores state in ~30s

**Manually maintained (humans do):**

- `CLAUDE.md`: Project core info, human reviews and confirms
- `DECISIONS.md`: Technical decisions made by humans, but recording can be AI-assisted
- `prompts/`: Coding standards defined by humans, rarely change

**Actual workflow:**

```
You: /start          ← AI automatically restores context, nothing for you to do
You: coding work     ← Normal coding, small git commits
You: /wrap           ← AI automatically summarizes, updates all memory files
```

The only thing you need to actively do is tell AI to record technical decisions (e.g., "record this decision in DECISIONS.md"), and occasionally review AI-generated documentation for accuracy. Essentially, humans only decide "what to do" and "why", while "remembering state" is entirely handled by AI and the file system.

---

## Detailed Usage Guide

Organized in actual usage order: installation, project initialization, daily development management, diagnostics, and context refinement.

## 1. Installation

Navigate to your target project root:

```bash
cd /path/to/your-project
```

Run the installer:

```bash
/path/to/context-engineering-kit/install.sh
```

Or specify a target project from any directory:

```bash
/path/to/context-engineering-kit/install.sh /path/to/your-project
```

After installation, the project will have:

```text
.claude/commands/init-context.md
.claude/commands/start.md
.claude/commands/wrap.md
AGENTS.md
TASKS.md
DECISIONS.md
memory/
prompts/
.cek
```

Notes:

- `install.sh` only copies commands and base templates, doesn't analyze project code.
- Project-specific `CLAUDE.md`, `ARCHITECTURE.md`, and README enhancements are generated or supplemented by `/init-context` in the next step.

## 2. Initialize Project Context

Start Claude Code in the target project:

```bash
cd /path/to/your-project
claude
```

Once in Claude Code, run:

```text
/init-context
```

`/init-context` will:

- Read project configs like `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`
- Scan main source directories like `src/`, `app/`, `lib/`, `packages/`
- Read existing `README.md`, `CLAUDE.md`, `ARCHITECTURE.md`
- Check recent git commits and current working tree state
- Create or supplement `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md`, `TASKS.md`, `DECISIONS.md`, `memory/`, `prompts/`

If the project already has `CLAUDE.md`, `/init-context` preserves the original content and only adds missing Context Engineering info. You don't need to run the official Claude Code `/init` first.

After initialization, quickly review these files:

- `CLAUDE.md`: Are project goals, tech stack, and run commands correct?
- `ARCHITECTURE.md`: Does the module breakdown match the actual code?
- `AGENTS.md`: Do the agent startup/wrap rules match your team's habits?
- `prompts/`: Are the rules appropriate for your tech stack?
- `TASKS.md`: Are current tasks accurate?

Once verified, commit the baseline:

```bash
git add CLAUDE.md AGENTS.md ARCHITECTURE.md TASKS.md DECISIONS.md memory prompts .claude/commands .cek
git commit -m "chore: initialize context engineering"
```

## 3. Daily Start of Work

Before each development session, run in Claude Code:

```text
/start
```

`/start` reads:

- `CLAUDE.md`
- `ARCHITECTURE.md`
- `DECISIONS.md`
- `TASKS.md`
- `memory/current_state.md`
- `memory/bugs.md`
- Recent git log
- Current git status

It should output:

- Current project phase
- Last session's focus
- Recent code changes
- Uncommitted changes
- Current to-do items
- Next step suggestions

Principle: `/start` only restores context, never modifies code.

## 4. Development Management Rules

During development, keep three things in sync.

First, sync tasks to `TASKS.md`:

```markdown
## In Progress
- [ ] Implement login error messages

## To Do
- [ ] Add login failure retry limit

## Completed
- [x] Integrate login API
```

Second, write important technical decisions to `DECISIONS.md`:

```markdown
## D002 — Use PostgreSQL as Primary Database

**Date:** 2026-05
**Decision:** Use PostgreSQL for business data storage.

**Reasons:**
- Need transactions and complex queries
- Team has ops experience

**Rejected:**
- MongoDB: Current business needs more relational queries

**Constraints:**
- New data models must include migration scripts
```

Third, write issues and lessons to `memory/`:

- New bugs: write to `memory/bugs.md`
- Failed approaches: write to `memory/experiments.md`
- Non-obvious gotchas: write to `memory/lessons_learned.md`
- State changes: updated by `/wrap` in `memory/current_state.md`

Recommended: small commits:

```bash
git commit -m "feat: add login error handling"
git commit -m "test: cover invalid login payload"
git commit -m "docs: record auth database decision"
```

## 5. Daily Wrap-Up

Before ending work each day, run in Claude Code:

```text
/wrap
```

`/wrap` collects information from three dimensions, not just git log:

| Dimension | Source | Purpose |
|-----------|--------|---------|
| Committed changes | `git log --oneline --since="today"` | Know what was done today |
| Uncommitted changes | `git diff --stat` + `git status` | Capture work not yet committed |
| Historical state | `memory/*` + `TASKS.md` | Know previous state for comparison |

Execution steps:

1. **Collect today's changes**: Run `git log`, `git diff --stat`, `git status`
2. **Read current state**: Read `memory/current_state.md`, `memory/bugs.md`, `memory/daily_log.md`, `TASKS.md`
3. **Update files**:
   - `memory/current_state.md` — Update completed/current issues/next priorities based on today's git changes, update `_last updated` date
   - `memory/daily_log.md` — Prepend today's log at the top (completed/discovered/tomorrow)
   - `memory/bugs.md` — Move fixed bugs from "Active" to "Fixed", add newly discovered ones to "Active"
   - `memory/lessons_learned.md` — If a valuable lesson was learned, append a record
   - `TASKS.md` — Move completed tasks to "Completed", keep unfinished ones in progress or move back to "To Do", add necessary new items
4. **Output summary**: Today's completions, discoveries, tomorrow's plan, list of updated files

After wrap-up, review changes:

```bash
git diff -- memory TASKS.md
```

If content is accurate, commit the context update:

```bash
git add memory TASKS.md DECISIONS.md
git commit -m "docs: update project context"
```

## 6. Diagnosing Project Context

Run the health check:

```bash
/path/to/context-engineering-kit/doctor.sh /path/to/your-project
```

`doctor.sh` checks:

- Required files exist
- `.claude/commands` is complete
- `AGENTS.md` exists
- Files still contain placeholder content
- The mode-specific `memory/*/current_state.md` files have update timestamps and are not stale
- `DECISIONS.md` has no duplicate IDs
- Kit version is up to date
- Team mode configuration (if applicable)

Common results and how to handle them:

```text
WARN: CLAUDE.md is missing; run /init-context after install to generate project-specific context
```

Fix: This is expected after install but before project context initialization. Run `/init-context` in Claude Code.

```text
WARN: memory/current_state.md has no parsable last update date
```

Fix: Run `/wrap`, or manually change the last line to:

```markdown
_last updated: 2026-05-20_
```

```text
WARN: DECISIONS.md still appears to contain placeholder text
```

Fix: Replace placeholder content with real decisions. If no decisions yet, keeping the template is fine, but fill it in after the first real decision.

```text
FAIL: duplicate decision IDs: D003
```

Fix: Open `DECISIONS.md` and renumber duplicates sequentially.

## 7. Periodic Refinement

Do a context cleanup every week or after each milestone:

```bash
/path/to/context-engineering-kit/doctor.sh
```

Then check:

- Can `CLAUDE.md` still describe project focus in under 100 lines?
- Does `ARCHITECTURE.md` reflect the real module structure?
- Does `DECISIONS.md` record key tradeoffs, especially rejected proposals?
- Does `TASKS.md` only keep currently relevant tasks?
- Has `memory/bugs.md` cleaned up fixed issues?
- Does `prompts/` still match the current tech stack?

## 8. Recommended Workflows

New project:

```text
install.sh
→ /init-context
→ Review generated content
→ git commit
```

Daily development:

```text
/start
→ Code with small commits
→ Record decisions, bugs, lessons
→ /wrap
→ git commit context updates
```

Periodic maintenance:

```text
doctor.sh
→ Fix missing, placeholder, stale, or duplicate items
→ Update CLAUDE.md / ARCHITECTURE.md / prompts/
```

## 9. Team Collaboration

### 9.1 Installing Team Mode

In team mode, each member installs independently with their own username:

```bash
/path/to/context-engineering-kit/install.sh --team --user alice
```

The `--team` flag adds these extra operations (not done in solo mode):

1. Creates `memory/shared/` (team-wide state) and `memory/alice/` (personal state)
2. Creates `memory/TEAM.md` (team member status table)
3. Appends to `.gitignore`: `memory/*/` and `!memory/shared/`, excluding personal memory
4. Creates `.gitattributes` with `merge=union` for `DECISIONS.md` and other append-only files

Other members install with their own usernames:

```bash
./install.sh --team --user bob
./install.sh --team --user carol
```

### 9.2 File Classification and Conflict Prevention

| File | Ownership | Git strategy | Conflict risk |
|------|-----------|--------------|---------------|
| `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md` | Shared | Normal tracking | Low (rarely changed) |
| `DECISIONS.md` | Shared | `merge=union` | Low (append-only) |
| `TASKS.md` | Shared | Normal tracking | Medium (multiple people may edit) |
| `memory/TEAM.md` | Shared | `merge=union` | Low (each person edits own row) |
| `memory/shared/` | Shared | Normal tracking | Medium (overall state) |
| `memory/{user}/` | Personal | gitignored | None (not in repo) |
| `prompts/` | Shared | Normal tracking | Low (rarely changed) |
| `.claude/commands/` | Shared | Normal tracking | Low (rarely changed) |

`merge=union` means: when git encounters a conflict during merge, it keeps both sides instead of reporting an error. This is safe for append-only files like `DECISIONS.md` and `TEAM.md`.

### 9.3 memory/TEAM.md — The Core of Team Awareness

`TEAM.md` is a simple table recording who's working on what:

```markdown
| Member | Working On | Since | Status |
|--------|-----------|-------|--------|
| alice | Batch invoice recognition | 2026-05-20 | in progress |
| bob | Email collection feature | 2026-05-20 | in progress |
| carol | VAT calculation optimization | 2026-05-19 | review |
```

- `/start` reads this table to show team context, warns if someone is modifying the same files you're working on
- `/wrap` only updates your own row, never touches others'
- With `merge=union`, even if two people `/wrap` simultaneously there's no conflict

### 9.4 Daily Workflow in Team Mode

Each member's daily routine is the same as solo mode, just with different AI read/write paths:

**`/start`:**
1. Read `memory/TEAM.md` → show what team members are working on
2. Read `memory/shared/current_state.md` → team overall progress
3. Read `memory/{user}/current_state.md` → your personal last state
4. Warn if other members are modifying files you might touch

**During coding:**
- Identical to solo mode: small git commits, append decisions to `DECISIONS.md`
- For cross-member coordination, add notes in `memory/TEAM.md` Coordination Notes

**`/wrap`:**
1. Update personal files under `memory/{user}/` (current_state, daily_log, bugs, etc.)
2. Update `memory/shared/current_state.md` for team overall state
3. Update your own row in `memory/TEAM.md` (Working On, Status)
4. Never touch other members' `memory/{other_user}/`

### 9.5 Team Mode doctor.sh Checks

```bash
/path/to/context-engineering-kit/doctor.sh /path/to/your-project
```

Additional checks in team mode:

- `memory/TEAM.md` exists
- `memory/shared/` directory exists
- Current user's `memory/{user}/` directory exists
- `.gitignore` has personal memory exclusion rules
- `.gitattributes` has merge strategies

### 9.6 Switching from Solo to Team

If a project started in solo mode and later needs team collaboration:

```bash
# 1. Re-install with team mode
/path/to/context-engineering-kit/install.sh --team --user alice

# 2. Manually migrate existing memory files
mkdir -p memory/alice
mv memory/current_state.md memory/alice/
mv memory/daily_log.md memory/alice/
mv memory/bugs.md memory/alice/
mv memory/experiments.md memory/alice/
mv memory/lessons_learned.md memory/alice/

# 3. Create shared/ directory (extract team state from personal state)
mkdir -p memory/shared
# Write overall project progress to memory/shared/current_state.md
# Write team-visible bugs to memory/shared/bugs.md

# 4. Run /init-context in Claude Code to regenerate context
```

## 10. Kit Upgrades

### 10.1 Version Identification

The kit uses semantic versioning stored in the `VERSION` file. Each `install.sh` run writes a `.cek` metadata file to the project root:

```json
{"version":"0.3.0","mode":"team","user":"alice","installed_at":"2026-05-20"}
```

All commands read `.cek` to determine the installed version and mode.

### 10.2 Checking Whether a Project Lags Behind the Local Kit

```bash
/path/to/context-engineering-kit/doctor.sh /path/to/your-project
```

`doctor.sh` compares the version in the project's `.cek` with the current local kit's `VERSION` file; it does not check the remote latest version. If the project is behind:

```text
WARN: installed version 0.2.0, latest is 0.3.0 — run upgrade.sh
```

### 10.3 Running Upgrades

```bash
/path/to/context-engineering-kit/upgrade.sh /path/to/your-project
```

`upgrade.sh` will:

1. Read the installed version from `.cek` and the kit's `VERSION` file
2. Show the changelog between the two versions
3. Confirm, then execute the upgrade

Upgrade policy (protects your customizations):

| File type | Upgrade behavior | Reason |
|-----------|------------------|--------|
| `.claude/commands/` | **Overwrite** | Rarely edited by users; new versions may fix command logic |
| Root templates (AGENTS.md etc.) | **Skip** | Already rewritten by `/init-context` with project content |
| `memory/` | **Skip** | Active working files; overwriting loses state |
| `prompts/` | **Skip** | May be customized per project |
| New template files | **Create** | New templates in the kit version are added only if missing |
| `.cek` | **Update version** | Preserves mode, user, and other fields |

### 10.4 Post-Upgrade Verification

```bash
# Check upgrade results
/path/to/context-engineering-kit/doctor.sh /path/to/your-project

# View updated commands
git diff -- .claude/commands/

# View new files
git status
```

### 10.5 Version Numbering Rules

The kit follows Semantic Versioning (SemVer):

- **Major**: Incompatible architectural changes, e.g., directory structure changes
- **Minor**: New features, e.g., team mode, new command templates
- **Patch**: Bug fixes, documentation updates

All changes are recorded in `CHANGELOG.md`, following [Keep a Changelog](https://keepachangelog.com/) format.
