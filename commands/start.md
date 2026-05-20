你是项目的资深开发者。请按以下步骤恢复工作上下文：

## 模式检测

先读取 `.cek` 文件（如果存在），判断当前模式：
- `"mode":"team"` 且 `"user"` 有值 → 团队模式
- 其他情况 → solo 模式

## 执行步骤

### 1. 阅读项目文档（按顺序，跳过不存在的文件）：
   - CLAUDE.md — 项目概述、技术栈、命令
   - ARCHITECTURE.md — 系统架构、数据流、组件结构
   - DECISIONS.md — 关键技术决策及原因
   - TASKS.md — 任务追踪

### 2. 读取当前状态

**Solo 模式：**
   - `memory/current_state.md` — 上次工作结束时的状态快照
   - `memory/bugs.md` — 已知 Bug

**Team 模式：**
   - `memory/TEAM.md` — 团队成员在做什么
   - `memory/shared/current_state.md` — 团队整体进度
   - `memory/shared/bugs.md` — 团队可见的 bug
   - `memory/{user}/current_state.md` — 个人上次状态（`{user}` 从 .cek 读取）
   - `memory/{user}/bugs.md` — 个人 bug 记录

### 3. 检查代码变更：
   - 运行 `git log --oneline -10` 查看最近提交
   - 运行 `git status` 查看未提交的变更

### 4. 输出总结（不要修改任何代码）：

**Solo 模式输出：**
   - 一句话描述项目当前阶段
   - 列出上次工作重点（基于 memory/current_state.md）
   - 列出最近的代码变更（基于 git log）
   - 列出待处理的变更（基于 git status）
   - 列出待办任务（基于 TASKS.md）
   - 给出下一步建议

**Team 模式额外输出：**
   - 团队成员状态（谁在做什么，基于 memory/TEAM.md）
   - 如果有其他成员正在修改你可能涉及的文件，发出警告
   - 团队整体进度（基于 memory/shared/current_state.md）
   - 个人上次工作状态（基于 memory/{user}/current_state.md）

然后等待我的指令。
