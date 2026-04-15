# PR 工作流

所有命令通过 Bash tool 调用 `gh`。并行执行独立的只读命令（如 `git status` + `gh pr view`）以加速。

---

## 从未暂存改动到 PR 的端到端流程

适用于：用户说"提 PR 吧"但当前分支还有未 commit 或未 push 的改动。

**边界**：如果用户显式调用了 `/commit` 内置 skill，commit 步骤交给 `/commit`，本流程只从第 4 步（push）开始衔接。

1. **看清改动**（并行）：`git status`，`git diff`，`git diff --cached`
2. **对齐拆分粒度**：如果改动跨越多个不相关主题，询问用户是拆成多个 commit 还是一个 commit 打包
3. **起草 commit message**：conventional commits 风格 `<type>: <summary>`（type ∈ feat/fix/docs/chore/refactor）
4. **暂存指定文件**：`git add <file1> <file2>`，**不要用 `-A` / `-a`**（防止误带入 `.env`、凭证等）
5. **创建 commit**（HEREDOC 避免转义）：

   ```bash
   git commit -m "$(cat <<'EOF'
   <type>: <summary>

   <optional body>
   EOF
   )"
   ```

6. **推送分支**：`git push -u origin <branch>`（首次推送带 `-u`）
7. 衔接下面的"创建 PR"章节

---

## 创建 PR

1. **先了解当前状态**（并行执行）：
   - `git status`
   - `git diff`（暂存 + 未暂存）
   - `git log <base>..HEAD --oneline`
   - `git diff <base>...HEAD --stat`

2. **分析 commits**：看整条分支的变更，不是只看最新 commit。起草标题（<70 字符）和 body。

3. **推送并创建 PR**（并行）：
   - 如需新建分支或推送：`git push -u origin <branch>`
   - 创建 PR：

   ```bash
   gh pr create --base main --title "<type>: <summary>" --reviewer <队友1>,<队友2> --body "$(cat <<'EOF'
   ## Summary
   - <要点 1>
   - <要点 2>

   ## Test plan
   - [ ] <测试项 1>
   - [ ] <测试项 2>

   Closes #<issue-n>
   EOF
   )"
   ```

4. 创建成功后把 PR URL 回给用户。

---

## 查看 PR

- **列表**：`gh pr list --json number,title,author,state,isDraft,reviewDecision --state open`
- **单个 PR 详情**：`gh pr view <n> --json state,mergeable,mergeStateStatus,reviewDecision,reviews,comments,statusCheckRollup`
- **看 diff**：`gh pr diff <n>`
- **看 CI**：`gh pr checks <n>`

---

## Review PR

- **提 review comment**（写在待定 review 里）：在 PR 页面操作，或用 `gh api` 构造；简单情形直接用：
  - 同意合并：`gh pr review <n> --approve --body "<总体评价>"`
  - 请求修改：`gh pr review <n> --request-changes --body "<要求修改的原因>"`
  - 纯评论：`gh pr review <n> --comment --body "<评论>"`
- **读 review 评论**：`gh api repos/:owner/:repo/pulls/<n>/comments`

---

## 更新 PR

- **改标题/body**：`gh pr edit <n> --title "..." --body "..."`
- **加/去 reviewer**：`gh pr edit <n> --add-reviewer <user>` / `--remove-reviewer <user>`
- **加/去 label**：`gh pr edit <n> --add-label needs-review` / `--remove-label wip`
- **同步 base 分支**（merge base into PR branch）：`gh pr update-branch <n>`
- **push 新 commits**：正常 `git push`，PR 自动更新

---

## Draft PR（进度同步场景）

- **创建 draft**：`gh pr create --draft ...`（其他参数同上）
- **转正**（ready for review）：`gh pr ready <n>`
- **用途**：队内异步同步进度但尚未完成时使用，避免触发 reviewer 邮件通知；转正后才走正式 review 流程

---

## 我相关的 PR 快速视图

- **全局状态**（我作者 + 等我 review + mention 我）：`gh pr status`
- **我创建的 open PR**：`gh pr list --author @me --state open --json number,title,reviewDecision,isDraft`
- **等我 review**：`gh pr list --search "review-requested:@me" --json number,title,author`
- **长时间无更新**（>7 天）：`gh pr list --search "updated:<$(date -d '7 days ago' +%Y-%m-%d)" --state open --json number,title,updatedAt`

---

## 合并 PR（破坏性 - 必须走完整门槛）

**合并的必经步骤，任何一步都不得跳过**：

1. **检查 CI**：执行 `gh pr checks <n>`
   - 有失败或进行中的 check → **立即停止，向用户汇报状态，不要"等一下再试"**
2. **检查 review 和 mergeable**：执行 `gh pr view <n> --json reviewDecision,mergeable,mergeStateStatus`
   - `reviewDecision != "APPROVED"` 或 `mergeable != "MERGEABLE"` → 停止并报告原因
3. **向用户确认**：明确询问"准备用 squash 合并 PR #<n>，是否执行？"，**等待用户回答**
4. **仅在用户明确同意后执行**：

   ```bash
   gh pr merge <n> --squash --delete-branch
   ```

- `--squash` 是团队默认；用户明确要求保留 commits 用 `--merge`，rebase 场景用 `--rebase`
- `--delete-branch` 合并后自动清理 feature 分支

---

## 常见组合

- **从 issue 到 PR 的链路**：创建分支时命名带 issue 编号（`feat/42-add-x`），PR body 里写 `Closes #42`
- **跨仓库查询**：任何 `gh` 命令加 `-R owner/repo`（例：`gh pr list -R acme/widget --author @me`）
