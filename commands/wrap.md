你是项目的工作总结助手。请执行下班前的 Context Engineering 收尾流程。

## 模式检测

先读取 `.cek` 文件（如果存在），判断当前模式：
- `"mode":"team"` 且 `"user"` 有值 → 团队模式
- 其他情况 → solo 模式

## 执行步骤

### 第一步：收集当天变更

1. 运行 `git log --oneline --since="today"` 查看今天的提交
2. 运行 `git diff --stat` 查看未提交的变更
3. 运行 `git status` 查看工作区状态

### 第二步：读取当前状态

**Solo 模式：**
- `memory/current_state.md`
- `memory/bugs.md`
- `memory/daily_log.md`
- `TASKS.md`

**Team 模式：**
- `memory/TEAM.md`
- `memory/shared/current_state.md`
- `memory/shared/bugs.md`
- `memory/{user}/current_state.md`（`{user}` 从 .cek 读取）
- `memory/{user}/daily_log.md`
- `memory/{user}/bugs.md`
- `TASKS.md`

### 第三步：更新文件

逐一更新以下文件（已存在则追加/更新，不存在则创建）：

#### memory/current_state.md

**Solo 模式** → 更新 `memory/current_state.md`
**Team 模式** → 更新 `memory/{user}/current_state.md`（个人）+ `memory/shared/current_state.md`（团队整体）

根据今天的 git 变更更新：
- **已完成**：追加今天完成的功能/修复
- **当前问题**：更新已知问题（修复的移到下方，新发现的加入）
- **下次优先**：根据未完成的工作和 TODO 推导下一步
- 更新 `_最后更新` 日期为今天

#### memory/daily_log.md

**Solo 模式** → 更新 `memory/daily_log.md`
**Team 模式** → 更新 `memory/{user}/daily_log.md`

在文件顶部追加今天的日志：
```
## YYYY-MM-DD

**完成:** _（基于 git log 总结今天做了什么，2-3 条）_
**发现:** _（遇到的问题或新发现）_
**明天:** _（基于 current_state.md 的下次优先推导）_
```

#### memory/bugs.md

**Solo 模式** → 更新 `memory/bugs.md`
**Team 模式** → 更新 `memory/{user}/bugs.md`（个人）+ `memory/shared/bugs.md`（团队可见 bug）

如果今天修复了 bug，从「活跃 Bug」移到「已修复」。
如果发现了新 bug，添加到「活跃 Bug」。

#### memory/lessons_learned.md

**Solo 模式** → 更新 `memory/lessons_learned.md`
**Team 模式** → 更新 `memory/{user}/lessons_learned.md`

如果今天踩了有价值的坑，追加一条记录（LL00X 编号递增）。

#### TASKS.md

- 已完成的任务从「进行中」移到「已完成」
- 未完成的任务保留在「进行中」或移回「待办」
- 根据今天的发现新增必要的待办项

#### memory/TEAM.md（仅 Team 模式）

更新自己那一行：
- 更新 `Working On` 为当前任务状态
- 更新 `Status`（in progress / review / blocked / done）

### 第四步：输出总结

用以下格式输出今日总结：

```
## 今日总结 (YYYY-MM-DD)

### 完成
- [x] ...

### 发现
- ...

### 明天计划
1. ...
2. ...

### 已更新文件
- memory/current_state.md
- memory/daily_log.md
- ...
```
