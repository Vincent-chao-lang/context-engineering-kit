# Context Engineering Kit 迷你手册

<p align="center">
  <img src="covers/variant-1-mini-handbook-cover.png" alt="Context Engineering Kit 迷你手册封面" width="420">
</p>

> 用一个下午，把 AI 编程从「每次重新解释项目」变成「每次读取项目状态」。

## 前言

如果你经常用 AI 写代码，大概率遇到过这种场景：昨天刚解释过项目架构，今天新会话又要重讲；上周已经否决的技术方案，AI 今天又推荐；一个 bug 昨天刚修，下一次重构又被引入。

这不是因为你不会写提示词。真正的问题是：项目状态没有稳定存放位置。

Context Engineering Kit 是一套轻量工具，把项目背景、任务、决策、bug 和每日状态放进项目文件。AI 每次开工先读这些文件，收尾时再更新它们。这样，项目上下文不再依赖某一次聊天记录，而是成为仓库的一部分。

这本迷你手册只讲最短路径：理解问题、安装工具、初始化上下文、每天使用、团队协作、保持不过期。读完后，你应该能在一个项目中建立最小可行的 `/start -> work -> /wrap` 循环。

案例团队叫 InvoiceFlow。Alice、Bob、Carol 三个人维护一个发票识别和报销审核工具。Alice 是 Tech Lead，Bob 做后端 OCR 和批量任务，Carol 做前端上传和进度反馈。

---

## 第 1 章：AI 编程为什么总是从零开始

很多团队第一次把 AI 编程工具接入项目时，会以为问题出在提示词上。

他们会写越来越长的开场白：这个项目用什么框架、上周做了什么、数据库为什么不用 MongoDB、哪个接口还没测、PDF 解析哪里有 bug。AI 当下能听懂，但下一次会话又回到原点。于是团队继续补提示词，继续解释背景，继续浪费前十几分钟。

真正的问题不是 AI 不够聪明，而是项目状态只存在于聊天记录里。

聊天记录不是可靠的项目数据库。它不跟着 git 走，不容易被团队共享，也很难被另一个工具读取。Alice 在 Claude Code 里解释过 InvoiceFlow 的数据库约束，Bob 用 Codex 时未必能看到；Carol 在 Cursor 里配置了前端规则，Alice 的会话也不会自动知道。

AI 编程的冷启动通常有四种表现：

- 项目背景反复解释。
- 技术决策反复讨论。
- 已知 bug 反复出现。
- 团队成员各自让 AI 朝不同方向推进。

Context Engineering Kit 的做法很朴素：把项目事实放回项目里。

架构写进 `ARCHITECTURE.md`，决策写进 `DECISIONS.md`，当前任务写进 `TASKS.md`，短期状态写进 `memory/`。AI 每次开工先读这些文件，再开始写代码。这样，团队不再依赖某一次对话的运气，而是依赖一套可检查、可提交、可维护的上下文结构。

**English Summary**

AI coding sessions start from zero when project state only lives in chat history. Context Engineering Kit moves project facts into versioned files so AI can recover context before work begins.

---

## 第 2 章：把上下文放进文件

不要把所有信息塞进一个超长 prompt。不同上下文有不同职责和更新频率。

Context Engineering Kit 的核心文件可以分成几类：

| 类型 | 文件 | 作用 |
| --- | --- | --- |
| 入口文档 | `CLAUDE.md`, `AGENTS.md` | 告诉 AI 如何开始理解项目 |
| 共享事实 | `ARCHITECTURE.md`, `TASKS.md`, `DECISIONS.md` | 记录架构、任务和决策 |
| 短期状态 | `memory/` | 记录当前进度、bug、实验、日志和经验 |
| 行为规则 | `prompts/` | 记录编码规范和 review 清单 |
| Claude Code 命令 | `.claude/commands/` | 提供 `/init-context`、`/start`、`/wrap` |

`CLAUDE.md` 更像 Claude Code 的项目入职文档。它应该短，告诉 AI 项目是什么、当前阶段是什么、常用命令是什么、接下来该读哪些文件。

`AGENTS.md` 是通用 agent 工作规则，适合 Codex 或其他支持仓库级 instructions 的工具。它不替代 `CLAUDE.md`，而是告诉 AI 开工前读什么、收尾时写什么。

`ARCHITECTURE.md` 解释系统结构，`TASKS.md` 解释当前工作，`DECISIONS.md` 解释为什么这样选择。三者共同减少团队反复解释。

`memory/` 保存短期状态。比如 InvoiceFlow 的 `memory/bugs.md` 记录 PDF 乱码问题：某些扫描件不能只读文本层，必须保留 OCR fallback。这个信息不一定是长期架构，但近期非常重要。

`prompts/` 保存相对稳定的规则。比如 Carol 可以把「上传页面必须处理 loading / empty / error」写进前端规则，之后不用每次提醒 AI。

一个简单原则：如果信息会影响下一次 AI 行动，就应该放进合适的文件。

**English Summary**

Do not put all context into one huge prompt. Entry docs, shared facts, short-term memory, and coding rules should live in separate files with clear responsibilities.

---

## 第 3 章：安装 Context Engineering Kit

安装分两步：先安装模板和命令，再初始化项目上下文。

### Solo 模式

在目标项目根目录运行：

```bash
/path/to/context-engineering-kit/install.sh
```

也可以指定目标项目：

```bash
/path/to/context-engineering-kit/install.sh /path/to/your-project
```

如果你是从 GitHub 临时安装，可以这样做：

```bash
git clone https://github.com/Vincent-chao-lang/context-engineering-kit /tmp/cek
/tmp/cek/install.sh
```

安装完成后，项目里会出现基础结构：

```text
.claude/commands/
AGENTS.md
TASKS.md
DECISIONS.md
memory/
prompts/
.cek
```

注意：`install.sh` 是确定性安装。它只复制命令和模板，不分析你的代码，也不会自动理解项目。

### 初始化项目上下文

接着进入 Claude Code，在目标项目中运行：

```text
/init-context
```

`/init-context` 会读取现有 README、源码、目录结构和上下文文件，生成或补齐 `CLAUDE.md`、`AGENTS.md`、`ARCHITECTURE.md`、`TASKS.md`、`DECISIONS.md` 和 `memory/`。

初始化后不要立刻全信。你应该 review 这些文件：

- `CLAUDE.md` 是否准确描述项目目标和当前阶段。
- `ARCHITECTURE.md` 是否符合真实代码结构。
- `TASKS.md` 是否反映当前优先级。
- `DECISIONS.md` 是否记录了关键选择和放弃方案。

最后做一次基线提交。这样，上下文文件就和代码一起进入版本历史。

**English Summary**

Installation and initialization are different. `install.sh` copies templates and commands; `/init-context` analyzes the project and creates project-specific context. Review the generated files before committing them.

---

## 第 4 章：每天的三个动作

迷你流程只有三个动作：

```text
/start -> work -> /wrap
```

### `/start`：开工前恢复上下文

每天开始时运行：

```text
/start
```

AI 会读取项目入口、架构、任务、决策、memory 和 git 状态。好的 `/start` 输出应该像一个简短 standup：

```text
当前阶段：MVP 稳定化。
最近重点：批量识别和 PDF 解析稳定性。
活跃 bug：扫描件 PDF 文本层乱码，需要 OCR fallback。
下一步：补任务状态 API 测试，再联调前端进度条。
```

这比「我准备好了」有用得多。

### `work`：正常开发，但及时记录关键状态

开发时不需要把所有事都写文档。只记三类信息：

- 会影响未来选择的，写进 `DECISIONS.md`。
- 会影响当前排序的，写进 `TASKS.md`。
- 会影响近期实现或避免重复踩坑的，写进 `memory/`。

例如 InvoiceFlow 当前阶段决定不用消息队列，先用数据库任务表，这是决策，应该写进 `DECISIONS.md`。前端还缺进度条，这是任务，写进 `TASKS.md`。PDF 乱码有复发风险，写进 `memory/bugs.md`。

开发中仍然要小步提交。Git 记录代码演化，memory 记录工作现场，两者互补。

### `/wrap`：收尾时写回状态

结束工作前运行：

```text
/wrap
```

它应该更新：

- `memory/current_state.md`
- `memory/bugs.md`
- `memory/daily_log.md`
- `TASKS.md`
- 必要时追加 `DECISIONS.md`

好的收尾不是一句「今天修了一些问题」，而是给下一次会话留下可行动状态：

```text
完成：为扫描件 PDF 增加 OCR fallback。
当前问题：大文件识别仍缺少进度反馈。
下次优先：Bob 补任务状态 API 测试；Carol 联调进度条。
```

**English Summary**

The daily loop is `/start -> work -> /wrap`. Start by reading context, work with small commits and correct state placement, then wrap by updating memory and tasks for the next session.

---

## 第 5 章：小团队怎么用

小团队最容易犯的错误，是把「共享上下文」理解成「大家共用同一个 memory 文件」。

这会很快变乱。Bob 的后端调试、Carol 的前端待办、Alice 的架构思考混在一起，AI 读到很多信息，却不知道哪些是团队共识，哪些只是个人现场。

team mode 的核心是分开：

- `memory/shared/`：团队共享状态。
- `memory/{user}/`：个人工作状态。
- `memory/TEAM.md`：谁在做什么。
- `.gitignore`：个人 memory 不进共享历史。
- `.gitattributes`：对部分共享文件使用合并规则，减少冲突。

安装 team mode：

```bash
/path/to/context-engineering-kit/install.sh --team --user alice
```

其他成员也用自己的名字安装：

```bash
/path/to/context-engineering-kit/install.sh --team --user bob
/path/to/context-engineering-kit/install.sh --team --user carol
```

重要边界：team mode 创建团队结构，不自动迁移 solo memory。solo memory 里有很多个人上下文，不应该未经整理直接变成团队事实。

从 solo 切到 team 时，建议：

1. 运行 team mode 安装。
2. 手动把旧 `memory/current_state.md` 中真正属于团队的内容提炼到 `memory/shared/current_state.md`。
3. 把个人工作现场放进自己的 `memory/{user}/`。
4. 用 `memory/TEAM.md` 记录每个人当前负责什么。

InvoiceFlow 的 `memory/TEAM.md` 可以很简单：

```text
Alice: 拆分批量识别任务边界，review 架构决策。
Bob: 实现任务状态 API 和 OCR fallback 测试。
Carol: 实现上传进度条和错误状态。
```

这张表不替代 standup，也不替代项目管理工具。它只是让 AI 开工时知道团队正在如何分工。

**English Summary**

Team mode separates shared team state from personal working state. It creates `memory/shared/`, `memory/{user}/`, and `memory/TEAM.md`, but it does not automatically migrate solo memory.

---

## 第 6 章：保持这套系统不过期

上下文系统会变旧。任务完成了但还留在待办里，bug 修复了但仍被标为 active，决策已经改变但旧记录没有补充说明，memory 越写越长，AI 开工时读到一堆噪音。

所以你需要轻量维护。

### 用 `doctor.sh` 做健康检查

运行：

```bash
/path/to/context-engineering-kit/doctor.sh /path/to/your-project
```

它会检查必要文件、命令、`AGENTS.md`、占位内容、memory 新鲜度、决策编号、版本和 team mode 配置。它不能判断每句话是否高质量，但能发现结构性问题。

### 用 `upgrade.sh` 保守升级

运行：

```bash
/path/to/context-engineering-kit/upgrade.sh /path/to/your-project
```

升级策略是保守的：commands 可以更新；根级模板、prompts 和已有 memory 通常不覆盖，以免丢失团队定制内容；新增文件会被创建；`.cek` 会更新版本。

### 每周做 20 分钟上下文整理

InvoiceFlow 团队每周只问四个问题：

1. AI 最近是否读到了过时信息？
2. 哪些任务或 bug 已解决但还留在活跃区域？
3. 哪些决策被重复讨论，说明记录不够清楚？
4. 哪些规则让大家不愿意维护，说明流程太重？

整理时不要追求完整历史。目标是让下一次行动更准确。

### 最小维护原则

- 如果 AI 反复问同一个背景，把它写进文件。
- 如果团队反复讨论同一个选择，把它写进 `DECISIONS.md`。
- 如果 bug 反复出现，把它写进 `memory/bugs.md`。
- 如果 review 反复指出同一个问题，把它写进 `prompts/`。
- 如果上下文文件越来越长，压缩掉不会影响下一步行动的内容。

**English Summary**

Context files can go stale. Use `doctor.sh` for health checks, `upgrade.sh` for conservative upgrades, and a weekly cleanup to remove stale tasks, resolved bugs, unclear decisions, and heavy rules.

---

## 快速清单

### 今天就能做

1. 在项目中运行 `install.sh`。
2. 在 Claude Code 中运行 `/init-context`。
3. Review 并提交生成的上下文文件。
4. 明天开工先运行 `/start`。
5. 收尾前运行 `/wrap`。

### 信息放哪里

| 信息 | 文件 |
| --- | --- |
| 项目目标和常用命令 | `CLAUDE.md` |
| Agent 工作规则 | `AGENTS.md` |
| 系统结构 | `ARCHITECTURE.md` |
| 当前任务 | `TASKS.md` |
| 技术决策和放弃方案 | `DECISIONS.md` |
| 当前状态和 bug | `memory/` |
| 编码规范和 review 清单 | `prompts/` |
| 团队成员状态 | `memory/TEAM.md` |

## 结语

Context Engineering Kit 不会替你做所有工程决策。它做的是一件更基础的事：让项目上下文有地方可去。

当上下文稳定下来，AI 才能真正像一个熟悉项目的同事一样工作。
