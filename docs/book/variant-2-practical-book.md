# 方案 2：实践短书版

## 定位

这是推荐方案。它是一本 8-10 章的实践短书，既讲清 Context Engineering 的方法，也能带读者完成一次小团队落地。它不会变成纯命令手册，也不会扩张成大型组织治理书。

读者读完后，应该能回答三个问题：

- 我们团队的项目事实应该放在哪里？
- AI 每天开工和收尾时应该读写哪些内容？
- 当团队从 solo 变成多人协作时，怎么避免上下文冲突？

## 读者收益

- 独立开发者能建立最小可行的上下文循环。
- 小团队能建立共享事实、个人 memory、团队状态表和决策日志。
- Tech Lead 能把这套流程解释给团队，而不是只把工具装进项目。
- 团队能把 Claude Code、Codex、Cursor、Windsurf 的工具差异收敛到同一套项目文件。

## 目录

### 第 1 章：AI 编程为什么会失忆

从真实开发体验切入，区分聊天上下文、项目状态、团队共识。提出本书核心判断：AI 编程的上限取决于上下文工程，而不只是提示词技巧。

### 第 2 章：Context Engineering 的核心思想

介绍状态外置化、文档驱动、小步提交、决策留痕四个原则。说明为什么项目事实应该进入仓库，而不是留在聊天窗口。

### 第 3 章：从一个小团队项目开始

引入 InvoiceFlow 案例。展示三人团队在 AI 协作中的混乱：重复解释、决策反复、bug 复发、任务状态不一致。

### 第 4 章：搭建项目上下文文件体系

讲解 `CLAUDE.md`、`AGENTS.md`、`ARCHITECTURE.md`、`DECISIONS.md`、`TASKS.md`、`memory/`、`prompts/` 的职责边界。强调 `install.sh` 和 `/init-context` 的区别。

### 第 5 章：每天如何用 `/start` 开工

展示 AI 如何读取项目入口、架构、决策、任务、memory 和 git 状态。说明好的开工不是寒暄，而是恢复项目现场。

### 第 6 章：工作中如何记录任务、决策和 bug

介绍 `TASKS.md`、`DECISIONS.md`、`memory/bugs.md`、`memory/lessons_learned.md` 的使用纪律。强调决策记录不是会议纪要，而是防止 AI 和团队反复推翻上下文。

### 第 7 章：每天如何用 `/wrap` 收尾

解释收尾不是总结给人看，而是给下一次 AI 会话准备状态。展示如何更新 memory、移动任务、记录当天日志和留下下一步。

### 第 8 章：团队模式：共享状态与个人 memory

深入讲 team mode：`memory/shared/`、`memory/{user}/`、`memory/TEAM.md`、`.gitignore` 和 `.gitattributes`。明确 team mode 创建结构，不自动迁移 solo memory。

### 第 9 章：跨工具迁移到 Codex、Cursor、Windsurf

解释项目事实与工具规则分离。Codex 读 `AGENTS.md`，Cursor 和 Windsurf 可通过 rules 系统复用同一套事实，但不维护一套独立真相。

### 第 10 章：维护、升级和长期演进

介绍 `doctor.sh`、`upgrade.sh`、版本元数据 `.cek`、定期整理和团队复盘。说明如何避免上下文系统自己变成负担。

## 贯穿案例

InvoiceFlow 是一个小团队维护的发票识别和报销审核系统。团队有三个角色：

- Alice：Tech Lead，负责技术决策、任务边界和团队协作规则。
- Bob：后端开发，负责 OCR 处理、批量任务、数据库和接口。
- Carol：前端开发，负责上传流程、识别结果校对和用户反馈。

案例主线分三幕：

1. 混乱期：AI 每次会话都需要重新解释项目，团队反复讨论已决策的问题。
2. 落地期：团队安装 kit，运行 `/init-context`，建立共享事实和 memory。
3. 稳定期：团队用 `/start` 和 `/wrap` 维护上下文，用 team mode 处理多人协作。

## 样章片段

### 第 8 章节选：团队 memory 不是共享一份聊天记录

小团队最容易犯的错误，是把「共享上下文」理解成「大家共用同一份 memory」。

这听起来简单，但很快会出问题。Bob 正在修 OCR 队列，Carol 正在改批量上传页面，Alice 在整理下一阶段架构。三个人每天都让 AI 更新同一个 `memory/current_state.md`，文件会变成一锅粥：今天的后端 bug、前端待办、架构讨论、临时实验混在一起。AI 下一次读取时，看似信息很多，实际上很难判断哪些是团队共识，哪些只是某个人的工作现场。

团队模式的关键，是把「共享事实」和「个人工作状态」分开。

`memory/shared/` 放团队应该共同知道的状态，例如当前阶段、团队可见的阻塞、影响多人协作的 bug。`memory/{user}/` 放个人每天的工作现场，例如 Bob 今天调试了哪个 OCR 样本、Carol 明天要补哪个前端状态、Alice 刚刚否决了哪个架构方向的临时理由。

`memory/TEAM.md` 则是一张轻量的团队状态表。它不取代任务系统，也不取代 standup。它只回答一个问题：AI 开工时，应该知道团队里谁正在做什么。

这也是为什么 team mode 不应该自动把 solo memory 全部迁移成团队 memory。solo memory 里有很多个人上下文，它们不一定适合直接变成团队共识。正确做法是：安装 team mode 后，由团队从旧 memory 中提炼共享状态，把真正需要所有人知道的内容写入 `memory/shared/`，再把个人工作现场放进自己的 `memory/{user}/`。

好的团队 memory 不是信息越多越好，而是边界越清楚越好。

## English Summary Sample

Team memory should not be a shared chat transcript. This chapter separates shared project facts from personal working state. In team mode, `memory/shared/` holds team-level context, `memory/{user}/` holds individual work state, and `memory/TEAM.md` gives AI a quick view of who is doing what. The key design principle is clear ownership, not more text.

## 优点

- 篇幅适中，能形成完整读者旅程。
- 小团队优先，同时不丢掉独立开发者场景。
- 能自然覆盖当前 kit 的关键能力：安装、初始化、日常循环、team mode、跨工具、升级和诊断。
- 后续可拆成网站章节、电子书或系列文章。

## 风险

- 初版写作量明显高于迷你手册。
- 需要保持案例连贯，否则章节会退化成手册条目。
- 中英 summary 要控制维护成本，不能变成全文双语翻译。

## 适用结论

推荐选择这个方案作为完整书稿方向。它最符合「实践教程」「小团队优先」「Markdown 小书」三个目标。

