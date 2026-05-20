你是项目初始化专家。请为当前项目生成或补齐 Context Engineering 目录结构，支持 AI 高效协作。

目标：让用户只需要在安装本 kit 后运行一次 `/init-context`，即可得到可用的 AI 项目上下文。不要要求用户必须先运行 Claude Code 官方 `/init`。如果项目已有 `CLAUDE.md`，读取并保留其内容；如果没有，直接生成一个兼容 Claude Code 使用习惯的 `CLAUDE.md`。

## 模式检测

先读取 `.cek` 文件（如果存在），判断当前模式：
- `"mode":"team"` → 团队模式，需要创建 `memory/shared/`、`memory/{user}/`、`memory/TEAM.md`
- `"mode":"solo"` 或文件不存在 → solo 模式，使用标准 `memory/` 目录

## 执行步骤

### 第一步：分析项目

先了解当前项目：
1. 读取 `package.json`、`Cargo.toml`、`pyproject.toml`、`go.mod` 或其他项目配置文件（如果存在）
2. 扫描主要源码目录（如 `src/`、`app/`、`lib/`、`packages/`，存在什么读什么）
3. 读取已有的 `README.md`、`CLAUDE.md`、`ARCHITECTURE.md`（如果存在）
4. 运行 `git log --oneline -10` 和 `git status`（如果当前目录是 git 仓库）
5. 基于代码和配置判断技术栈、启动命令、测试命令、关键模块和当前阶段

如果缺少配置文件或源码目录，不要报错中断；根据已有文件生成最小可用上下文，并在最终总结里列出信息不足之处。

### 第二步：生成完整目录结构

在项目根目录创建以下完整结构。**已存在的文件不要覆盖；对于已有核心文档，只在需要时追加一个清晰的 Context Engineering 小节，或在最终总结中建议用户手动合并。**

#### Solo 模式（默认）

```
project/
├── README.md
├── CLAUDE.md
├── AGENTS.md
├── ARCHITECTURE.md
├── TASKS.md
├── DECISIONS.md
├── memory/
│   ├── current_state.md
│   ├── bugs.md
│   ├── experiments.md
│   ├── lessons_learned.md
│   └── daily_log.md
├── prompts/
│   ├── common/
│   │   ├── coding_rules.md
│   │   └── review_checklist.md
│   ├── typescript/
│   │   └── style_guide.md
│   ├── python/
│   │   └── style_guide.md
│   └── backend/
│       └── review_checklist.md
└── src/
```

#### Team 模式（.cek 中 mode 为 team 时）

```
project/
├── README.md
├── CLAUDE.md
├── AGENTS.md
├── ARCHITECTURE.md
├── TASKS.md
├── DECISIONS.md
├── memory/
│   ├── TEAM.md                # 团队成员状态表（共享）
│   ├── shared/                # 团队共享状态
│   │   ├── current_state.md
│   │   └── bugs.md
│   └── {user}/                # 个人 memory（gitignored）
│       ├── current_state.md
│       ├── daily_log.md
│       ├── experiments.md
│       ├── lessons_learned.md
│       └── bugs.md
├── prompts/
│   └── ...（同上）
└── src/
```

### 第三步：填充每个文件的模板内容

逐一创建所有缺失文件。已存在的文件默认跳过；如果已有文件明显是空模板，可以替换占位内容为项目实际内容。最终总结必须列出新建、补齐、跳过的文件。

---

#### README.md

如果不存在，根据第一步分析的项目信息生成，包含：
- 项目名称和一句话描述
- 功能特性列表
- 技术栈
- 快速开始（安装、运行、构建命令）
- 项目结构概览
- 许可证

#### CLAUDE.md

如果不存在，根据项目实际情况生成「AI 项目说明书」。如果已存在，读取它并尽量保留原内容；只补充缺失但重要的项目上下文。内容包含：
- 项目目标
- 当前阶段
- 技术栈
- 关键命令（dev / build / test）
- 编码原则（根据代码风格推导）
- 当前重点（基于 git log 最近提交）
- 关键文件和目录
- Context Engineering 使用约定（如 `/start`、`/wrap`、`DECISIONS.md`、`memory/` 的作用）

要求：
- 控制在 100 行以内，优先写 AI 每次会话必须知道的内容
- 不要把 README 或 ARCHITECTURE 的长篇内容复制进来
- 不要覆盖用户已有的重要说明
- 生成内容应兼容 Claude Code 自动读取 `CLAUDE.md` 的使用方式

#### AGENTS.md

如果不存在，创建通用 Agent 工作规则，包含：
- 每次工作前应读取的上下文文件
- 维护 `DECISIONS.md`、`TASKS.md`、`memory/` 的规则
- 对 Codex、Cursor、Windsurf 等工具也适用的协作约定

如果已存在，不覆盖；必要时在最终总结中建议用户合并 Context Engineering 启动规则。

#### ARCHITECTURE.md

如果不存在，根据项目实际代码结构生成架构文档，包含：
- 技术栈表格
- 系统架构图（ASCII）
- 目录结构说明
- 核心模块职责
- 数据流描述
- 外部依赖说明

#### TASKS.md
```markdown
# 任务追踪

## 进行中

_（当前正在进行的任务）_

## 待办

_（按优先级排列的待办事项）_

## 已完成

_（已完成的任务，保留最近 10 条）_
```

#### DECISIONS.md
```markdown
# 决策日志

记录项目中的关键技术决策及其原因。新增决策追加到末尾。

---

## D001 — [决策标题]

**日期:** YYYY-MM
**决策:** [一句话决策]

**原因:**
- [原因 1]
- [原因 2]

**放弃:**
- [被放弃的方案及原因]

**约束:**
- [决策带来的限制或后续要求]
```

#### memory/current_state.md
```markdown
# 当前状态

## 已完成

_（列出已完成的模块/功能）_

## 当前问题

_（已知 bug 或待解决的问题）_

## 下次优先

1. _（优先级最高的任务）_
2. _（次优先任务）_

---
_最后更新: [日期]_
```

#### memory/bugs.md
```markdown
# Bug 记录

## 活跃 Bug

_（尚未修复的 bug）_

## 已修复

_（保留最近的重要修复记录）_
```

#### memory/experiments.md
```markdown
# 实验记录

记录尝试过的方案、结果和结论，避免重复实验。

---

## [实验名称]

**日期:** YYYY-MM-DD
**假设:** _（要验证什么）_
**方法:** _（怎么做的）_
**结果:** _（成功/失败/数据）_
**结论:** _（学到了什么）_
```

#### memory/daily_log.md
```markdown
# 每日工作日志

## YYYY-MM-DD

**完成:** _（今天做了什么）_
**发现:** _（遇到的问题或新发现）_
**明天:** _（计划做什么）_
```

#### memory/lessons_learned.md
```markdown
# 踩坑记录

记录项目中遇到的具体问题、根因分析和解决方案，避免重蹈覆辙。

---

_新增踩坑记录请追加到末尾，格式：_

```
## LL00X — [简短标题]

**日期:** YYYY-MM-DD
**现象:** _（表现是什么）_
**根因:** _（根本原因）_
**解决:** _（怎么修的）_
**教训:** _（一句话总结，未来如何避免）_
```
```

#### prompts/common/coding_rules.md
根据项目实际技术栈和代码风格生成编码规则，包括但不限于：
- 命名约定
- 错误处理策略
- 安全要求
- 性能约束
- 依赖使用规范

#### prompts/[stack]/style_guide.md
根据项目实际代码风格生成或选择技术栈风格指南。常见路径：
- `prompts/typescript/style_guide.md`
- `prompts/python/style_guide.md`

内容包括但不限于：
- 代码格式化规则
- 注释风格
- 文件组织方式
- 组件/函数编写规范
- 类型定义规范

如果项目使用其他技术栈，可以创建对应目录，如 `prompts/go/`、`prompts/rust/`、`prompts/mobile/`。

#### prompts/common/review_checklist.md
```markdown
# 代码审查清单

每次提交代码前检查：

## 功能正确性
- [ ] 核心逻辑是否正确
- [ ] 边界条件是否处理
- [ ] 错误路径是否覆盖

## 代码质量
- [ ] 命名是否清晰（无歧义缩写）
- [ ] 是否有重复代码可提取
- [ ] 函数/组件是否职责单一

## 安全性
- [ ] 用户输入是否验证
- [ ] 敏感数据是否加密/脱敏
- [ ] API Key 是否暴露在代码中

## 性能
- [ ] 是否有不必要的重复计算
- [ ] 大列表是否虚拟化
- [ ] 异步操作是否有错误处理

## 兼容性
- [ ] 是否影响现有功能
- [ ] 数据结构变更是否向后兼容
```

#### prompts/backend/review_checklist.md

如果项目包含后端、API、任务队列或数据层，创建后端专项审查清单，覆盖 API 契约、数据迁移、安全、运维等检查项。

#### src/

如果 `src/` 目录不存在则创建（空目录）。如果已存在则跳过。

---

### 第四步：输出总结

完成后输出：
1. **新建了哪些文件**（列出路径）
2. **补齐/更新了哪些文件**（列出路径和原因）
3. **跳过了哪些已有文件**（列出路径）
4. **信息不足或需要人工确认的点**（如无法确定测试命令、部署方式）
5. **使用建议**：
   - 每次会话开始用 `/start` 恢复上下文
   - 下班前用 `/wrap` 自动总结当天工作并更新 memory 文件
   - 做出技术决策时追加到 `DECISIONS.md`
   - 踩坑时追加到 `memory/lessons_learned.md`
   - 发现 bug 记录到 `memory/bugs.md`
   - 用 `TASKS.md` 追踪任务进度
