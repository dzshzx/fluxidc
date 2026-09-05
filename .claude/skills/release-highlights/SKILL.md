---
name: release-highlights
description: 起草发版日志或用户视角版本亮点时使用；先按 docs/release.md 区分本 fork 的 idcflare 发布与上游 stable 亮点。
---

# 起草版本亮点

先读 `docs/release.md` 的当前发布通道。本 fork 默认使用
`vX.Y.Z-idcflare.N`；用户明确指定上游无后缀 stable 时，才起草
`highlights/v<版本>.md`。起草任务交付可审阅文案；提交或发布按用户已有授权执行。

## 本 fork：idcflare 发布日志

1. 沿用任务已确定的目标版本，从 `git tag --list 'v*-idcflare.*' --merged HEAD`
   找到上一次已发布 fork tag，核对其提交与本次候选；范围为该 tag 到候选提交。
   首次 fork 发布使用任务给定的基线；基线确实不明时询问。
2. 根据 `git log --oneline --no-merges <上一fork-tag>..<候选>` 提炼用户可感知变化，
   对含义不明的提交查看其正文或相关改动，输出日志草稿。
3. 按 `docs/release.md` 的 fork 流程交付：CI 从 fork tag 生成增量明细与下载表格。
   该通道不消费 stable highlights；草稿不触发 tag、`just release` 或渠道发送。

## 上游无后缀 stable：版本亮点

该通道的 `highlights/v<版本>.md` 由 CI(`scripts/ci/compose_release_notes.py`)
消费：GitHub Release 正文为亮点与折叠明细，Telegram / AltStore 只发亮点。

1. **定范围**：
   ```bash
   PREV=$(git describe --tags --abbrev=0 --exclude='*-*' HEAD)   # 上一个 stable tag
   git log --oneline --no-merges "$PREV"..HEAD
   ```
2. **定目标版本**：沿用任务已有版本；否则从已确认的上游 beta 序列取核心版本。
   排除 fork 的 `-idcflare.N` tag；仍有歧义时询问目标版本。
3. **读写作约定**:`highlights/README.md`,严格遵守(用户视角、禁实现术语、`###` 分节、1000~2000 字)。
4. **聚类提炼**:把范围内提交按用户可感知的主题聚类(新功能 / 界面焕新 / 流畅度 / 稳定性…),几十个同主题 commit 合成一条人话。凡是用户没有感知的(重构、诊断设施、CI、依赖升级)一律不写。对拿不准"用户看到什么"的提交,读对应代码或 commit body 确认,不要凭 commit 标题脑补功能。
5. **写文件**:`highlights/v<版本>.md`(无 H1 标题,直接开场段落起笔)。若同版本文件已存在,先读旧稿,在其基础上增量更新而非覆盖。
6. **交稿**：给出草稿与比较范围。发布已获授权时按 `docs/release.md` 的上游流程
   继续；tag 必须包含该文件的提交，CI 才能读取。

## 自查

- 每条 bullet 单独念给非程序员听是否能懂?出现 rebuild / provider / saveLayer 等词即打回。
- Telegram 上限 4096 字符,正文加标题链接后仍需留余量。
- 分节只用 `###`(`##` 会被 TG 管线丢弃)。
