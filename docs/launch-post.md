# Launch Post 草稿：AI 编程真正缺的不是提示词，是项目记忆

AI 编程工具越来越强，但很多开发者和小团队仍然遇到同一个问题：每次新会话都像从零开始。

你需要重新解释项目背景、技术栈、当前任务、上周做过的决策、昨天修过的 bug。AI 当下能听懂，但下一次会话又忘了。于是我们把提示词写得越来越长，却没有解决根本问题：项目状态没有稳定存放位置。

这就是我做 Context Engineering Kit 的原因。

## 从 Prompt Engineering 到 Context Engineering

Prompt Engineering 解决的是「这一条指令怎么写」。但真实项目不是一条指令能承载的。项目里有架构、任务、决策、bug、实验、踩坑经验、团队成员状态和编码规则。

这些信息不应该只存在聊天记录里。

Context Engineering 的核心思路很简单：把项目事实放回项目里。

- `CLAUDE.md` 让 Claude Code 快速理解项目。
- `AGENTS.md` 给 Codex 和其他 agent 工具一个通用入口。
- `ARCHITECTURE.md` 记录系统结构和数据流。
- `TASKS.md` 记录当前任务和优先级。
- `DECISIONS.md` 记录为什么选择某方案，以及为什么放弃另一个方案。
- `memory/` 记录当前状态、活跃 bug、实验、经验和每日日志。
- `prompts/` 记录稳定的编码规范和 review 清单。

AI 每次开工先读上下文，收尾时再写回状态。这样，项目记忆不依赖某一次聊天窗口，而是成为仓库的一部分。

## 每天只需要一个循环

Context Engineering Kit 提供三个核心 Claude Code 命令：

```text
/init-context
/start
/wrap
```

第一次进入项目时，运行 `/init-context`，让 AI 分析现有项目并生成或补齐上下文文件。

每天开始工作时，运行 `/start`，AI 读取项目文档、任务、决策、memory 和 git 状态，恢复项目现场。

每天结束时，运行 `/wrap`，AI 总结当天工作，更新 memory、任务和必要的决策记录。

日常循环就是：

```text
/start -> 编码工作 -> /wrap
```

## 小团队为什么更需要它

个人开发时，AI 忘记上下文会浪费时间。小团队里，这个问题会放大成协作成本。

Bob 的 AI 以为后端要上消息队列，Carol 的 AI 以为前端只需要轮询接口，Alice 的 AI 还在沿用上周的任务拆分。大家都在使用 AI，但每个 AI 看到的项目事实不同。

团队模式把上下文分开：

- `memory/shared/` 放团队共享状态。
- `memory/{user}/` 放个人工作状态。
- `memory/TEAM.md` 记录谁在做什么。
- 个人 memory 被 gitignore，减少冲突。
- 共享决策和团队状态可以使用 git 合并规则降低冲突。

这不是要替代 standup 或 issue tracker，而是让 AI 开工时知道团队正在如何协作。

## 这不是重型框架

Context Engineering Kit 只是一些 shell 脚本、Markdown 模板和 Claude Code 命令。它不接管你的项目，不要求引入服务，也不替代现有 issue tracker。

它做一件事：让 AI 编程里的项目上下文有稳定的存放位置和维护流程。

## 快速开始

```bash
# 在你的项目根目录
/path/to/context-engineering-kit/install.sh
```

然后进入 Claude Code：

```text
/init-context
```

之后每天：

```text
/start
# coding...
/wrap
```

## 我希望收到的反馈

这个项目仍然处在早期实践阶段。我更希望把它作为一种方法论和工具包邀请大家试用，而不是把它包装成标准答案。

最有价值的反馈是：

- `/init-context` 生成的上下文是否准确。
- `/start` 是否真的减少冷启动时间。
- `/wrap` 是否太重，还是能自然融入日常。
- team mode 是否符合小团队的真实协作方式。
- 哪些文件有用，哪些文件应该删减。

如果你也遇到 AI 编程里的项目失忆问题，可以试试 Context Engineering Kit。

真正高级的 AI 编程，不只是怎么提问，而是怎么管理上下文。

