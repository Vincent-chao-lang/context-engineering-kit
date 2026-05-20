# 跨工具适配指南

Context Engineering 的核心是文件化上下文，不依赖某一个 AI 编程工具。不同工具只是在“启动时读取哪些文件”和“自定义命令放在哪里”上不同。

## 工具映射

| 工具 | 推荐入口 | 命令/规则位置 | 说明 |
|------|----------|---------------|------|
| Claude Code | `CLAUDE.md` | `.claude/commands/` | `CLAUDE.md` 是项目说明书，`/init-context`、`/start`、`/wrap` 是 Claude Code 自定义命令 |
| Codex | `AGENTS.md` | 仓库级 instructions | `AGENTS.md` 告诉 Codex 每次工作前读取哪些上下文文件，以及如何维护 memory |
| Cursor | `.cursor/rules` | `.cursor/rules/` 或项目规则 | 可把 `CLAUDE.md` 和 `AGENTS.md` 的核心内容迁移为 Cursor Rules |
| Windsurf | rules 文件 | Windsurf rules | 可把启动读取顺序、决策记录、memory 维护规则写入 rules |

## 推荐文件分工

- `CLAUDE.md`：Claude Code 的项目级说明书，也可作为其他工具的项目摘要来源
- `AGENTS.md`：通用 agent 工作规则，适合 Codex 或其他读取仓库 instructions 的工具
- `DECISIONS.md`：技术决策和被放弃方案
- `TASKS.md`：任务状态
- `memory/`：短期状态、bug、实验、踩坑、日志
- `prompts/`：编码规范、风格指南、审查清单

## 迁移原则

不要为每个工具维护一套完全独立的事实。项目事实放在 `CLAUDE.md`、`ARCHITECTURE.md`、`DECISIONS.md`、`memory/` 中；工具规则只负责告诉 AI 如何读取和维护这些文件。

---

# Cross-Tool Adaptation Guide (English)

The core of Context Engineering is file-based context, which doesn't depend on any single AI programming tool. Different tools only differ in "which files to read at startup" and "where to put custom commands".

## Tool Mapping

| Tool | Entry point | Commands/rules location | Notes |
|------|-------------|------------------------|-------|
| Claude Code | `CLAUDE.md` | `.claude/commands/` | `CLAUDE.md` is the project handbook; `/init-context`, `/start`, `/wrap` are Claude Code custom commands |
| Codex | `AGENTS.md` | Repo-level instructions | `AGENTS.md` tells Codex which context files to read before each session and how to maintain memory |
| Cursor | `.cursor/rules` | `.cursor/rules/` or project rules | Migrate core content from `CLAUDE.md` and `AGENTS.md` to Cursor Rules |
| Windsurf | rules file | Windsurf rules | Write startup read order, decision records, and memory maintenance rules into rules |

## Recommended File Separation

- `CLAUDE.md`: Claude Code's project-level handbook, can also serve as the project summary source for other tools
- `AGENTS.md`: Universal agent working rules, suitable for Codex or other tools that read repo instructions
- `DECISIONS.md`: Technical decisions and rejected proposals
- `TASKS.md`: Task state
- `memory/`: Short-term state, bugs, experiments, lessons, logs
- `prompts/`: Coding standards, style guides, review checklists

## Migration Principles

Do not maintain a completely independent set of facts for each tool. Project facts live in `CLAUDE.md`, `ARCHITECTURE.md`, `DECISIONS.md`, and `memory/`. Tool rules only tell AI how to read and maintain these files.
