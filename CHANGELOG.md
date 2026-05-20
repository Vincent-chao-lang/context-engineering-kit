# Changelog

## 0.3.0 (2026-05-20)

### Added
- `VERSION` 文件 — kit 版本标识
- `CHANGELOG.md` — 版本变更记录
- `.cek` 元数据文件 — 安装时写入项目根目录，记录版本、模式、用户
- `upgrade.sh` — kit 升级脚本，覆盖 commands、添加新文件、更新 .cek
- 团队协作模式 — `install.sh --team --user <name>`
- `memory/TEAM.md` — 团队成员状态表
- `memory/shared/` — 团队共享状态
- `memory/{user}/` — 个人 memory（gitignored）
- `.gitattributes` — append-only 文件 merge=union
- `doctor.sh` 版本检查 — 对比 .cek 与 kit VERSION
- `doctor.sh` 团队模式检查

### Changed
- `install.sh` 新增 `--team`、`--user` 参数，末尾写 `.cek`
- `doctor.sh` 加版本和团队模式检查
- `commands/init-context.md` 支持团队模式目录结构
- `commands/start.md` 支持团队上下文展示
- `commands/wrap.md` 支持个人 memory 写入和 TEAM.md 更新

## 0.2.0 (2026-05-17)

### Added
- `doctor.sh` 健康检查脚本
- `AGENTS.md` 模板
- `prompts/` 按类别组织（common、typescript、python、backend）
- `docs/` 目录，包含三份指南

## 0.1.0 (2026-05-16)

### Added
- 初始发布
- `install.sh` 安装器
- 三个命令：`init-context`、`start`、`wrap`
- memory 模板
- prompts 模板
