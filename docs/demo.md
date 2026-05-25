# Demo 脚本：从 AI 失忆到项目记忆

这个 demo 用一个小型发票识别项目 InvoiceFlow 展示 Context Engineering Kit 的价值。它适合录屏、直播演示、README 展示或 launch post 配套说明。

## Demo 目标

在 8-12 分钟内展示四件事：

1. 安装前：AI 每次都需要重新解释项目。
2. 安装后：`/init-context` 建立项目上下文文件。
3. 日常工作：`/start` 读取上下文，`/wrap` 写回状态。
4. 团队模式：AI 知道谁在做什么，避免多人上下文冲突。

## 准备项目

可以使用任意小项目，也可以临时创建一个示例项目。建议项目设定如下：

- 项目名：InvoiceFlow
- 场景：发票上传、OCR 识别、报销审核
- 技术栈：任意前后端或脚本项目均可
- 已知决策：MVP 阶段不用消息队列，先用数据库任务表
- 已知 bug：扫描件 PDF 文本层可能乱码，需要 OCR fallback
- 当前任务：批量识别进度条、任务状态 API、错误状态处理

## Part 1：安装前的冷启动

打开一个新 AI 会话，给出一个模糊任务：

```text
帮我继续做 InvoiceFlow 的批量发票识别。
```

预期效果：

- AI 不知道项目结构。
- AI 可能建议重新选型。
- AI 不知道已有 bug。
- AI 不知道当前任务优先级。

然后人工补充一长段背景：

```text
这个项目是发票识别和报销审核工具。
我们当前在 MVP 稳定化阶段。
之前决定暂时不用消息队列，先用数据库任务表。
PDF 解析有个已知问题，扫描件文本层会乱码，必须保留 OCR fallback。
Bob 在做任务状态 API，Carol 在做前端进度条。
```

说明：这就是 Context Engineering Kit 要减少的重复解释。

## Part 2：安装和初始化

在项目根目录运行：

```bash
/path/to/context-engineering-kit/install.sh
```

展示生成的基础结构：

```text
.claude/commands/
AGENTS.md
TASKS.md
DECISIONS.md
memory/
prompts/
.cek
```

强调：

- `install.sh` 只复制命令和模板。
- 它不分析项目代码。
- 项目专属上下文由 `/init-context` 生成。

进入 Claude Code，运行：

```text
/init-context
```

展示 AI 生成或补齐的文件：

```text
CLAUDE.md
AGENTS.md
ARCHITECTURE.md
TASKS.md
DECISIONS.md
memory/current_state.md
```

演示重点：

- `CLAUDE.md` 是项目入口。
- `ARCHITECTURE.md` 记录模块和数据流。
- `DECISIONS.md` 写清楚为什么当前不用消息队列。
- `TASKS.md` 写当前任务。
- `memory/bugs.md` 记录 PDF 乱码风险。

## Part 3：日常开工 `/start`

开启一个新会话，运行：

```text
/start
```

理想输出应包含：

```text
当前阶段：MVP 稳定化。
当前重点：批量识别、任务状态 API、前端进度反馈。
相关决策：D001 当前阶段不用消息队列，先用数据库任务表。
活跃 bug：扫描件 PDF 文本层乱码，需要保留 OCR fallback。
下一步建议：补任务状态 API 测试，再联调前端进度条。
```

说明：

- AI 不再从零开始。
- 人不用重复解释项目背景。
- 决策、任务和 bug 都来自项目文件。

## Part 4：工作中记录关键状态

给 AI 一个具体任务：

```text
实现任务状态 API，注意不要引入消息队列，继续使用数据库任务表。
```

演示期望：

- AI 会参考 `DECISIONS.md`。
- AI 不会重新建议消息队列。
- AI 会把相关任务同步到 `TASKS.md`。
- 如果遇到 PDF 相关逻辑，会参考 `memory/bugs.md`。

可以展示一条新增决策：

```text
把“任务状态 API 先只支持 queued/running/done/failed 四种状态”记录到 DECISIONS.md。
```

## Part 5：收尾 `/wrap`

结束前运行：

```text
/wrap
```

理想更新：

```text
memory/current_state.md
memory/daily_log.md
memory/bugs.md
TASKS.md
DECISIONS.md
```

示例收尾状态：

```text
完成：任务状态 API 初版，支持 queued/running/done/failed。
当前问题：前端尚未联调 failed 状态展示。
下次优先：Carol 联调前端进度条和错误状态。
```

说明：

- `/wrap` 不是写日报给人看。
- 它是给下一次 AI 会话写上下文。

## Part 6：团队模式

运行 team mode：

```bash
/path/to/context-engineering-kit/install.sh --team --user alice
```

展示结构：

```text
memory/
├── TEAM.md
├── shared/
│   ├── current_state.md
│   └── bugs.md
└── alice/
    ├── current_state.md
    └── daily_log.md
```

强调边界：

- team mode 创建团队结构。
- 它不会自动迁移 solo memory。
- 需要手动把旧 memory 中的团队事实提炼到 `memory/shared/`。

展示 `memory/TEAM.md`：

```text
Alice: 拆分批量识别任务边界，review 架构决策。
Bob: 实现任务状态 API 和 OCR fallback 测试。
Carol: 实现上传进度条和错误状态。
```

在 team mode 下运行 `/start`，展示 AI 读取团队状态：

```text
团队状态：
- Bob 正在做任务状态 API
- Carol 正在做上传进度条
- Alice 正在整理架构和任务边界

建议避免同时修改任务状态字段定义。
```

## 演示结束语

可以用这段话收尾：

```text
Context Engineering Kit 不替代你的 AI 工具，也不替代项目管理系统。
它做的是更基础的一件事：把 AI 编程需要的项目记忆放进仓库。

当项目背景、任务、决策、bug 和每日状态都有稳定位置，
AI 每次开工就不再是陌生人。
```

## 录屏检查清单

- [ ] 演示安装前的重复解释成本。
- [ ] 明确 `install.sh` 和 `/init-context` 的区别。
- [ ] 展示 `/start` 读取上下文后的输出。
- [ ] 展示 `/wrap` 更新 memory 和任务。
- [ ] 明确 team mode 不自动迁移 solo memory。
- [ ] 展示 `memory/TEAM.md` 的团队感知价值。

