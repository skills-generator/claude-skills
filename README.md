# Claude Skills

自用 Claude Code skills 集合。

## Skills

- [`github-ops`](./skills/github-ops/) — GitHub PR 和 Issue 的日常管理（基于 `gh` CLI）

## 安装

克隆本仓库后执行：

```bash
./install.sh
```

脚本会把 skill 拷贝到 `~/.claude/skills/`（可通过 `CLAUDE_SKILLS_DIR` 环境变量覆盖）。安装后编辑对应 skill 的 `SKILL.md` 填入团队约定（队友用户名等），再确认 `gh auth status` 已登录即可使用。
