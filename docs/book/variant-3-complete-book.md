# Context Engineering 完整实践书

<p align="center">
  <img src="covers/variant-3-complete-book-cover.png" alt="Context Engineering 完整实践书封面" width="420">
</p>

> 真正高级的 AI 编程，不是把一次提示词写得更长，而是让项目上下文有地方可去、有规则可循、有办法持续更新。

## 前言

AI 编程工具越来越强，但很多团队的实际体验并没有线性变好。第一天，AI 帮你快速搭出原型；第二天，它忘了昨天为什么这样设计；第三天，它又提出一个上周已经否决过的方案；再过一周，团队发现项目背景、任务状态、bug、实验结论和决策原因散落在不同聊天窗口里。

这不是某个模型或某个工具单独的问题。它更像软件工程里的状态管理问题：项目状态没有稳定的载体，AI 每次只能依赖当前会话里的临时上下文。

Context Engineering Kit 的出发点很简单：把项目事实放回项目里。

本书不是一本命令参考手册。`install.sh`、`/init-context`、`/start`、`/wrap`、`doctor.sh` 和 `upgrade.sh` 都只是载体。真正要建立的是一套团队习惯：让 AI 每次开工前读到正确的上下文，让团队做过的决定不会反复被推翻，让每天的工作状态能被下一次会话继承。

本书以一个虚构项目 InvoiceFlow 为贯穿案例。InvoiceFlow 是一个发票识别和报销审核系统，最初由 Alice 一个人做原型，后来加入 Bob 和 Carol，变成一个三人小团队。它经历的上下文混乱、决策反复、bug 复发和任务冲突，都是 AI 编程团队常见的问题。

每章以中文为主，并附英文 summary，方便非中文读者快速判断章节重点。

## 适合谁读

- 正在用 Claude Code、Codex、Cursor、Windsurf 等工具写代码的独立开发者。
- 2-8 人小团队里的 Tech Lead 或核心开发者。
- 想把 AI 编程从个人技巧变成团队流程的人。
- 正在设计 agent 工作流、项目 memory 或工程化提示体系的人。

---

# 第一部分：问题与方法

## 第 1 章：AI 编程的冷启动问题

Alice 最初做 InvoiceFlow 时，AI 给她带来了明显的速度提升。上传页面、OCR 调用、报销单字段映射，很多代码都能在短时间内生成。问题出现在第三周。

她打开一个新会话，让 AI 修 PDF 解析乱码。AI 看了几行代码后建议换一个 PDF 库。Alice 皱了一下眉：这个方案上周试过，处理扫描件不稳定。她提醒 AI。AI 接着建议把识别结果先写进 localStorage。Alice 又提醒：这个项目有审计要求，结果必须进数据库。十分钟过去，她还没开始修 bug，只是在恢复项目背景。

这就是 AI 编程的冷启动问题。

冷启动不是「AI 不知道你想要什么」这么简单。它包含四种成本：

- 时间成本：每次会话前都要重新解释项目。
- 决策成本：已经否决的技术方案被重新提出。
- 质量成本：已知 bug 或踩坑经验没有被读取，导致问题复发。
- 协作成本：团队成员看到的项目状态不一致，各自让 AI 朝不同方向推进。

传统开发里，团队会用 README、架构文档、ADR、issue tracker、提交历史和代码 review 来维持项目连续性。AI 编程并没有让这些工程实践失效，反而让它们更重要。因为 AI 是一个高产但无持久记忆的合作者，如果你不给它稳定的项目状态，它就只能根据当前窗口里的碎片推断。

InvoiceFlow 的第一次教训来自数据库。Alice 曾决定使用 SQLite，因为早期目标是本地桌面工具，不需要部署独立数据库服务。但这个决定只存在于一次聊天里。后来 Bob 加入后，让 AI 设计批量识别任务表，AI 又建议使用 PostgreSQL。PostgreSQL 不是坏方案，但它和当时的部署约束不一致。团队花了半小时重新讨论，最后回到 SQLite。

问题不在于 AI 提了 PostgreSQL。问题在于「为什么当前阶段不用 PostgreSQL」没有成为项目资产。

Context Engineering 要解决的就是这类问题：把 AI 需要知道的项目状态，从脆弱的聊天历史，迁移到稳定、可读、可审查、可版本化的文件体系里。



## 第 2 章：提示词之外的 Context Engineering

Prompt Engineering 解决的是「这一条指令怎么写」。Context Engineering 解决的是「整个项目的上下文如何被组织、传递和更新」。

两者的差别很关键。一个好 prompt 可以让 AI 在当前任务上更准确，但它承载不了整个项目的历史：架构为什么这样设计、哪些方案试过失败、当前谁在做什么、哪些 bug 不能再引入、哪些编码规则必须遵守。这些内容太长、太动态，也太需要团队共享。

Context Engineering Kit 把项目上下文拆成五类：

1. 项目事实：项目目标、技术栈、架构、关键目录和运行命令。
2. 工作状态：当前进度、下一步、阻塞项、每日日志。
3. 决策历史：选择了什么、放弃了什么、原因是什么。
4. 工具规则：AI 开工前读什么、收尾时写什么、实现时遵守哪些规范。
5. 执行反馈：bug、实验结果、踩坑经验、review checklist。

这五类信息的更新频率不同，所以不能塞进同一个文件。架构文档可能几周才改一次，`memory/current_state.md` 可能每天都改，`DECISIONS.md` 只在真正做决策时追加，`prompts/` 则通常由人维护，很少变化。

一个成熟的 AI 编程项目，应该像一个状态清晰的软件系统：

- 稳定配置放在稳定文件里。
- 高频状态放在 memory 里。
- 决策追加记录，不覆盖历史。
- 工具入口只放规则，不复制全部事实。
- 每次工作结束后更新下一次启动所需的信息。

InvoiceFlow 团队后来形成了一个约定：任何超过 15 分钟还在反复解释的问题，都应该被写进某个上下文文件。解释项目目标，写进 `CLAUDE.md`；解释架构影响，写进 `ARCHITECTURE.md`；解释为什么不用某方案，写进 `DECISIONS.md`；解释今天做到哪里，写进 `memory/current_state.md`。

这个约定把上下文从对话里抽出来，变成团队可维护的资产。

.

## 第 3 章：状态外置化

状态外置化是 Context Engineering 的核心原则。

软件工程里，我们早就知道不应该把配置写死在代码里，不应该把部署状态存在某个人电脑上，不应该让关键决策只留在口头讨论里。AI 编程也一样：不应该把项目状态只留在聊天窗口里。

聊天记录有几个天然缺陷：

- 不稳定：不同工具、不同会话之间无法自然共享。
- 不可审查：团队很难 code review 一段聊天历史。
- 不可版本化：你很难知道某条上下文何时改变、为什么改变。
- 不可裁剪：聊天越长，噪音越多，模型上下文窗口还会压缩旧信息。

文件则有相反的优势：

- 和代码放在同一个仓库里。
- 可以被 git 追踪和 review。
- 可以被 Claude Code、Codex、Cursor、Windsurf 等工具读取。
- 可以按职责拆分，避免一个上下文文件无限膨胀。

状态外置化不是把所有聊天都搬进 markdown。它要求团队判断：哪些事实会影响未来行动？哪些状态下一次会话必须知道？哪些决策如果不记录，会被再次推翻？

InvoiceFlow 团队最早犯过「过度记录」的错误。Alice 要求 AI 把每天所有讨论都写进 `daily_log.md`，结果一周后文件变成流水账。Bob 开工时让 AI 读取日志，AI 读到了很多已完成的临时问题，反而把注意力放错了地方。

后来他们改成三层结构：

- `CLAUDE.md` 和 `ARCHITECTURE.md` 写长期事实。
- `DECISIONS.md` 和 `TASKS.md` 写中期状态。
- `memory/` 写短期工作现场。

这种分层让 AI 不必在一堆杂乱记录中猜什么重要。文件名和职责本身就是上下文。



---

# 第二部分：文件体系

## 第 4 章：入口文档：`CLAUDE.md` 与 `AGENTS.md`

入口文档负责告诉 AI：这个项目是什么，以及你应该如何开始工作。

`CLAUDE.md` 面向 Claude Code。它更像 AI 的项目入职文档，应该包含项目目标、当前阶段、技术栈、常用命令、核心规则、关键文件和当前重点。它不应该写成完整架构说明，也不应该复制所有任务和 bug。太长的入口文档会让 AI 抓不住重点。

`AGENTS.md` 面向 Codex 和其他支持仓库级 instructions 的 AI 编程工具。它不是 `CLAUDE.md` 的替代品，而是通用 agent 工作规则。它应该告诉工具：开工前读哪些文件，修改代码时遵守哪些原则，做完后如何维护 `TASKS.md`、`DECISIONS.md` 和 `memory/`。

两者的分工可以这样理解：

- `CLAUDE.md` 更偏项目说明。
- `AGENTS.md` 更偏工作协议。
- 项目事实仍然放在 `CLAUDE.md`、`ARCHITECTURE.md`、`DECISIONS.md` 和 `memory/` 中。
- 不要为每个工具维护一套独立真相。

InvoiceFlow 的 `CLAUDE.md` 起初写了三百多行，包含数据库表、接口、页面状态、任务列表和 bug。结果 AI 每次开工都会读，但经常忽略真正关键的当前目标。后来 Alice 把它压缩到一百行以内，只保留：

- 项目一句话说明。
- 当前阶段：MVP 到团队协作试点。
- 技术栈和关键命令。
- 最近重点：批量识别、PDF 解析、审核流。
- 指向其他文件的阅读顺序。

详细架构被移到 `ARCHITECTURE.md`，任务被移到 `TASKS.md`，当天状态被移到 `memory/current_state.md`。入口变短后，AI 反而更稳定。

一个好的入口文档不是内容最多的文档，而是能把 AI 带到正确下一站的文档。





## 第 5 章：共享事实：架构、任务和决策

团队协作最怕的不是没人写文档，而是每个人脑子里的事实不一样。

InvoiceFlow 中，Bob 以为批量识别任务应该直接写数据库，Carol 以为前端只需要轮询接口，Alice 以为后端会先提供任务状态机。三个人都不是错的，但他们共享的事实不完整。AI 参与后，这种不一致会被放大：每个人的 AI 都根据自己会话里的上下文继续生成代码。

`ARCHITECTURE.md`、`TASKS.md` 和 `DECISIONS.md` 是共享事实的三根支柱。

`ARCHITECTURE.md` 回答「系统现在是什么样」。它应该描述模块职责、数据流、关键依赖和改动影响。它不需要记录每个函数，但要让 AI 知道改一个模块会牵动哪里。

`TASKS.md` 回答「我们正在做什么」。它可以很简单：进行中、待办、已完成。它不是完整 issue tracker，也不必替代 Jira 或 GitHub Issues。它的作用是让 AI 知道当前工作重心，而不是从聊天里猜。

`DECISIONS.md` 回答「我们为什么这样做」。最重要的是记录放弃了什么。只写「选择 SQLite」还不够，还要写「当前阶段不选 PostgreSQL 的原因」。这样当 AI 再次建议 PostgreSQL 时，团队可以让它读取 D001，而不是重新辩论。

共享事实有一个纪律：追加比改写安全。架构变了，可以更新架构文档；任务完成了，可以移动任务；但决策历史最好保留演化过程。团队不是为了证明过去永远正确，而是为了让未来的人和 AI 理解当时的约束。

InvoiceFlow 后来把批量识别拆成三条共享事实：

- `ARCHITECTURE.md`：批量任务由后端维护状态机，前端订阅或轮询进度。
- `TASKS.md`：Bob 做任务状态 API，Carol 做前端进度条，Alice review 错误处理。
- `DECISIONS.md`：D004 记录当前阶段不用消息队列，先用数据库任务表。

这三条事实让三个 AI 会话朝同一个方向工作。



## 第 6 章：短期记忆：`memory/`

`memory/` 是项目的短期记忆。它不负责解释整个项目，只负责让下一次会话知道最近发生了什么。

常见文件分工如下：

- `current_state.md`：当前状态快照，包含已完成、当前问题和下次优先。
- `bugs.md`：活跃 bug、已修复 bug 和复发风险。
- `experiments.md`：试过什么、结果如何、是否继续。
- `lessons_learned.md`：踩坑记录，最好写出现象、根因、解决和教训。
- `daily_log.md`：每天简要记录，方便回溯。

短期记忆的关键不是完整，而是可行动。下一次 AI 开工时，它最需要知道：上次做到了哪里，什么还没解决，接下来最应该做什么。

InvoiceFlow 的 PDF 解析 bug 就适合放在 `memory/bugs.md`。一开始，AI 修过一次乱码问题，但下次重构上传流程时又引入类似错误。后来 Bob 让 AI 在 `memory/bugs.md` 中记录：

- 某些扫描件使用嵌入字体，直接提取文本会乱码。
- 不要只依赖文本层，需要保留 OCR fallback。
- 修复时必须用三个样本文件回归测试。

这条记录不是长期架构，也不是正式决策，但它对近期开发非常重要。AI 每次处理 PDF 相关代码时读到它，就能避免重复犯错。

`memory/` 也要控制噪音。已解决且不再影响当前工作的内容，可以移到已解决区域，或者在周期性整理中压缩。短期记忆如果无限增长，就会失去短期的意义。

.

## 第 7 章：行为规则：`prompts/`

项目上下文不只包括「做什么」，还包括「怎么做」。

`prompts/` 存放相对稳定的编码规则和审查标准。它和 `memory/` 的区别在于更新频率：memory 经常变化，prompts 通常很少变化。把它们分开，可以避免短期状态污染长期规范。

Context Engineering Kit 默认提供几类模板：

- `prompts/common/coding_rules.md`：通用编码硬规则。
- `prompts/common/review_checklist.md`：提交前检查清单。
- `prompts/typescript/style_guide.md`：TypeScript 或前端项目风格。
- `prompts/python/style_guide.md`：Python 项目风格。
- `prompts/backend/review_checklist.md`：后端、API、数据层审查项。

这些文件不应该写成百科全书。真正有效的规则通常很短、很具体、能被执行。例如：

- API 错误响应必须包含稳定错误码。
- 数据库迁移必须可回滚。
- 前端 loading、empty、error 三种状态必须覆盖。
- 新增批量任务逻辑必须有幂等性说明。

InvoiceFlow 的前端曾多次漏掉错误状态。Carol 后来把「上传、识别、审核页面必须显式处理 loading / empty / error」写进前端规则。之后让 AI 改页面时，她不再每次重复提醒，而是要求 AI 先读取相关 prompts。

规则文件还有一个团队价值：它把个人偏好变成可讨论的工程约定。如果 Bob 认为后端接口必须返回 trace id，Carol 认为前端不需要展示，团队可以在 prompts 或架构文档里定规则，而不是每次 code review 重新争论。



---

# 第三部分：日常流程

## 第 8 章：初始化：从空模板到项目上下文

安装和初始化是两件不同的事。

`install.sh` 是确定性安装。它复制 Claude Code 命令、模板、memory 文件、prompts 和 `.cek` 元数据。它不分析你的代码，也不会自动理解项目。

`/init-context` 是智能初始化。它在 Claude Code 中运行，读取已有项目，生成或补齐 `CLAUDE.md`、`AGENTS.md`、`ARCHITECTURE.md`、`TASKS.md`、`DECISIONS.md`、`memory/` 等项目专属上下文。如果已经有 `CLAUDE.md`，它应该读取并保留已有内容，只补充缺失信息。

这条边界很重要。很多团队以为安装工具后，AI 就已经理解项目。实际上，安装只是把容器和命令放好；初始化才是把真实项目状态写进去。

InvoiceFlow 的初始化过程分三步：

1. Alice 在项目根目录运行 `install.sh`，得到命令和模板。
2. 她在 Claude Code 中运行 `/init-context`，让 AI 读取 README、源码、目录结构和 git 历史。
3. 团队 review 生成的 `CLAUDE.md`、`ARCHITECTURE.md` 和 `TASKS.md`，删掉不准确内容，补上关键决策。

初始化后的第一件事不是立刻写新功能，而是建立基线提交。这个提交让团队知道：从这一刻开始，上下文文件也是项目的一部分。

初始化要避免两个极端。一个极端是过度信任 AI，生成后不看就提交；另一个极端是追求一次写完所有文档。更好的做法是先建立最小准确上下文：项目目标、技术栈、运行命令、当前任务、重要决策和近期状态。后续再通过 `/wrap` 和人工 review 逐步完善。



## 第 9 章：开工：让 AI 重新进入项目现场

`/start` 的目标不是打招呼，而是恢复现场。

一个好的开工流程应该让 AI 快速回答：

- 这个项目是什么？
- 当前阶段是什么？
- 最近做了什么？
- 现在有哪些任务和 bug？
- 团队里谁在做什么？
- 本次工作前需要注意哪些决策和规则？

在 solo 模式下，`/start` 主要读取 `CLAUDE.md`、`AGENTS.md`、`ARCHITECTURE.md`、`TASKS.md`、`DECISIONS.md`、`memory/` 和 git 状态。在 team mode 下，它还应该读取 `memory/TEAM.md`、`memory/shared/` 和当前用户自己的 `memory/{user}/`。

InvoiceFlow 的一次有效开工输出大概是这样：

```text
已读取项目入口、架构、任务、决策和 memory。

当前阶段：MVP 稳定化，重点是批量识别和 PDF 解析稳定性。
团队状态：Bob 在做任务状态 API，Carol 在做批量上传进度条。
活跃 bug：扫描件 PDF 文本层乱码，需要保留 OCR fallback。
相关决策：D004 当前阶段不用消息队列，先用数据库任务表。
建议下一步：先补后端任务状态测试，再联调前端进度显示。
```

这比「我准备好了，需要我做什么？」有用得多。它把 AI 从陌生人变成一个刚参加完 standup 的同事。

`/start` 后，人仍然要给出明确任务。Context Engineering 不意味着 AI 自己决定所有事。它意味着当你说「修 PDF 解析 bug」时，AI 已经知道这个 bug 的背景、相关模块、历史坑和测试样本，而不是从零探索。



## 第 10 章：工作中：任务、决策、bug 的维护纪律

上下文系统能否长期有效，取决于工作中的维护纪律。

不是每个想法都要写入 `DECISIONS.md`，不是每个待办都要写入 `TASKS.md`，也不是每个报错都要写入 `memory/bugs.md`。写错地方比不写更麻烦，因为 AI 会把临时信息当成长期事实。

可以用三条判断：

- 会影响未来技术选择的，写进 `DECISIONS.md`。
- 会影响当前工作排序的，写进 `TASKS.md`。
- 会影响近期实现细节或避免重复踩坑的，写进 `memory/`。

InvoiceFlow 团队讨论是否引入消息队列。Bob 认为批量识别迟早需要队列，Alice 认为 MVP 阶段先用数据库任务表足够。这个决定会影响后端架构和后续任务设计，所以应该写进 `DECISIONS.md`。记录重点不是「Alice 赢了」，而是：

- 当前阶段用户量小。
- 部署复杂度要低。
- 数据库任务表足够支持 MVP。
- 放弃消息队列不是永久否定，而是推迟到吞吐量成为瓶颈时再评估。

另一个例子：Carol 发现前端上传页面缺少空状态。这个问题影响当前工作排序，写进 `TASKS.md` 即可。除非团队决定「所有页面必须有 loading / empty / error 状态」，才需要把规则写进 `prompts/`。

bug 的记录也要区分。一次普通 typo 不需要进入 `memory/bugs.md`。但 PDF 乱码这种容易复发、和实现策略有关的问题，值得记录现象、根因、修复和回归样本。

维护纪律的目的不是增加文档负担，而是让信息进入正确位置。



## 第 11 章：收尾：为下一次会话写上下文

`/wrap` 是整套流程的闭环。

很多人把收尾理解成「写一段今天做了什么」。这太浅了。真正好的收尾，是为下一次启动准备足够上下文，让未来的 AI 和未来的你不用重新挖掘现场。

`/wrap` 应该做几件事：

- 总结本次完成了什么。
- 更新 `memory/current_state.md`。
- 更新活跃 bug、实验和 lessons learned。
- 同步 `TASKS.md`：完成的移走，新增的补上，阻塞的标明原因。
- 必要时追加 `DECISIONS.md`。
- 在 team mode 下更新自己的 `memory/{user}/` 和 `memory/TEAM.md`。

InvoiceFlow 的一次收尾不是这样：

```text
今天修了一些 PDF 问题。
```

而应该更像这样：

```text
完成：为扫描件 PDF 增加 OCR fallback，补充 3 个回归样本。
当前问题：大文件识别耗时仍不稳定，超过 20 页时需要进度反馈。
下次优先：Bob 补任务状态 API 测试；Carol 联调进度条。
Bug 状态：PDF 文本层乱码从 active 移到 resolved，但保留回归样本说明。
```

这样的收尾让下一次 `/start` 有东西可读。它也让团队有机会在提交前 review AI 对状态的理解是否准确。

`/wrap` 不应该替代 git commit。Git 记录代码变化，memory 记录工作现场。两者结合，AI 才能既看到事实，又看到演化。



---

# 第四部分：团队与演进

## 第 12 章：团队模式

团队 memory 不是共享一份聊天记录。

如果三个人都更新同一个 `memory/current_state.md`，文件很快会变成混杂现场：Bob 的后端 bug、Carol 的前端待办、Alice 的架构思考挤在一起。AI 读到很多信息，却很难判断哪些是团队共识，哪些只是个人工作状态。

team mode 的设计是分层：

- `memory/shared/`：团队共享状态，例如整体阶段、团队可见 bug、跨成员阻塞。
- `memory/{user}/`：个人工作状态，例如某个人今天调试了什么、下一步要做什么。
- `memory/TEAM.md`：团队成员状态表，记录谁在做什么。
- `.gitignore`：忽略个人 memory，避免把个人工作现场推给所有人。
- `.gitattributes`：对 append-only 或共享状态文件设置合并规则，减少冲突。

需要明确的是：team mode 创建结构，不自动迁移 solo memory。原因很简单，solo memory 里有很多个人现场，不应该未经整理就变成团队事实。

从 solo 切到 team 时，InvoiceFlow 团队做了三件事：

1. 运行 `install.sh --team --user alice` 创建团队结构。
2. 从旧 `memory/current_state.md` 中提炼团队共享状态，写入 `memory/shared/current_state.md`。
3. 把 Alice 自己的近期工作现场放入 `memory/alice/`，再让 Bob 和 Carol 分别安装自己的个人 memory。

`memory/TEAM.md` 不需要复杂。它只要让 AI 开工时知道：

- Alice：整理任务边界和架构决策。
- Bob：实现批量识别任务状态 API。
- Carol：做上传页面进度条和错误状态。

这张表不会替代 standup，也不会替代项目管理工具。它只是让 AI 不再孤立地看待当前任务。



## 第 13 章：跨工具协作

团队通常不会只用一个 AI 工具。有人用 Claude Code，有人用 Codex，有人习惯 Cursor 或 Windsurf。如果每个工具都维护一套上下文，项目很快会分裂成多份真相。

跨工具协作的原则是：项目事实统一，工具规则适配。

项目事实应该放在共享文件里：

- `CLAUDE.md`
- `AGENTS.md`
- `ARCHITECTURE.md`
- `DECISIONS.md`
- `TASKS.md`
- `memory/`
- `prompts/`

工具规则只负责告诉不同 AI 如何读取和维护这些事实。Claude Code 可以通过 `CLAUDE.md` 和 `.claude/commands/` 工作。Codex 可以读取 `AGENTS.md` 作为仓库级 instructions。Cursor 和 Windsurf 可以通过各自 rules 系统迁移核心规则。

注意：当前 kit 不自动生成 `.cursor/rules` 或 Windsurf rules。它提供的是可迁移的文件体系和 `AGENTS.md` 这样的通用入口。

InvoiceFlow 的做法是：Alice 用 Claude Code 维护 `/start` 和 `/wrap` 工作流，Bob 用 Codex 时先让它读取 `AGENTS.md`、`ARCHITECTURE.md`、`TASKS.md` 和相关 memory，Carol 在 Cursor 中配置规则，要求 Cursor 参考同一套项目事实。三个人使用不同工具，但讨论的是同一份 `DECISIONS.md` 和 `TASKS.md`。

跨工具协作最怕复制粘贴。复制一份规则到另一个工具后，如果原文件更新而副本没更新，AI 就会读到旧事实。更好的做法是让工具规则尽量短，只指向项目事实文件。



## 第 14 章：诊断、升级和版本管理

上下文系统也需要健康检查。

项目跑一段时间后，可能出现几类问题：

- 必要文件缺失。
- memory 很久没更新。
- `DECISIONS.md` 编号重复。
- team mode 结构不完整。
- 项目安装的 kit 版本落后。
- 生成文件还停留在占位内容。

`doctor.sh` 的价值是把这些问题显性化。它不会替你判断所有内容是否高质量，但可以检查结构和明显风险。对小团队来说，这类检查很重要，因为上下文系统一旦坏掉，AI 不一定会主动告诉你。

升级则由 `upgrade.sh` 处理。升级策略必须保守，因为目标项目里的文档可能已经被团队定制。一般原则是：

- commands 可以覆盖，因为命令模板通常跟 kit 行为强相关。
- 根级模板和 prompts 遇到已有文件应跳过，避免覆盖团队内容。
- memory 已有文件应保留，只创建新增模板。
- `.cek` 记录版本、模式和用户等元数据。

InvoiceFlow 团队把 `doctor.sh` 放进每周例行检查。每周五，Alice 会运行一次，看看 memory 是否过期、team mode 是否完整、版本是否需要升级。这个动作不到一分钟，但能防止上下文系统悄悄腐化。

版本管理还有一个沟通价值。当团队成员说「我的 `/wrap` 行为和你的不一样」时，先看 `.cek` 和 commands 是否同版本，而不是直接猜工具问题。

## 第 15 章：从工具到团队习惯

很多团队第一次尝到 Context Engineering 的好处后，会走向另一个极端：什么都写。

每一次讨论都写进 `DECISIONS.md`，每一个临时想法都写进 `TASKS.md`，每一个报错都写进 `memory/bugs.md`。一周后，AI 的确有了很多上下文，但它需要在更多噪音中判断什么重要。团队也开始抱怨：维护这些文件是不是比直接写代码还麻烦？

这说明上下文系统进入了第二个阶段：不是缺少信息，而是缺少整理。

好的上下文不是项目的全部历史，而是下一次行动需要的最小充分事实。`DECISIONS.md` 应该记录会影响未来选择的决定，而不是每一次偏好讨论。`TASKS.md` 应该记录仍然影响当前工作的任务，而不是完整 issue tracker。`memory/` 应该保留近期状态和经验，而不是把所有聊天内容搬进仓库。

InvoiceFlow 团队后来形成了每周 20 分钟的上下文复盘，只问四个问题：

1. AI 最近是否读到了过时信息？
2. 哪些 bug 或任务已经解决但还留在活跃区域？
3. 哪些决策被重复讨论，说明记录不够清楚？
4. 哪些规则让大家不愿意维护，说明流程太重？

这四个问题比「文档是否完整」更有用。Context Engineering 不是追求完整文档，而是追求下一次行动更准确、更快、更少返工。

工具只能提供结构。真正让结构持续工作的，是团队习惯：开工先读上下文，决策要留痕，收尾要写回，定期要修剪。只要这些习惯存在，即使换一个 AI 工具，项目上下文也不会丢。

---

# 附录：落地清单

## 独立开发者最小流程

1. 运行 `install.sh`。
2. 在 Claude Code 中运行 `/init-context`。
3. Review `CLAUDE.md`、`ARCHITECTURE.md`、`TASKS.md` 和 `DECISIONS.md`。
4. 每次开工运行 `/start`。
5. 做小步提交。
6. 每次收尾运行 `/wrap`。
7. 每周清理一次 `TASKS.md` 和 `memory/`。

## 小团队落地流程

1. 先由 Tech Lead 在项目中建立 solo 或 team 基线。
2. 运行 `/init-context` 并组织一次上下文 review。
3. 使用 team mode 时，为每个成员建立自己的 `memory/{user}/`。
4. 把团队共享事实写入 `memory/shared/`。
5. 用 `memory/TEAM.md` 记录谁在做什么。
6. 决策进入 `DECISIONS.md`，任务进入 `TASKS.md`，近期状态进入 memory。
7. 每周运行 `doctor.sh` 并做上下文复盘。

## 文件放置速查

| 信息 | 放在哪里 |
| --- | --- |
| 项目目标、技术栈、常用命令 | `CLAUDE.md` |
| 通用 agent 工作协议 | `AGENTS.md` |
| 模块职责、数据流、依赖关系 | `ARCHITECTURE.md` |
| 当前任务和优先级 | `TASKS.md` |
| 重要技术选择及放弃方案 | `DECISIONS.md` |
| 当前状态、近期问题、下一步 | `memory/current_state.md` |
| 活跃 bug 和复发风险 | `memory/bugs.md` |
| 实验结果 | `memory/experiments.md` |
| 踩坑经验 | `memory/lessons_learned.md` |
| 编码规则和 review 清单 | `prompts/` |
| 团队成员状态 | `memory/TEAM.md` |

## 最后的原则

如果 AI 反复问同一个背景，把它写进文件。

如果团队反复讨论同一个选择，把它写进决策。

如果 bug 反复出现，把它写进 memory。

如果规则反复出现在 review 里，把它写进 prompts。

如果上下文文件越来越长，删掉或压缩不会影响下一次行动的内容。
