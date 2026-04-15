# PR 工作流

所有命令通过 Bash tool 调用 `gh`。并行执行独立的只读命令（如 `git status` + `gh pr view`）以加速。

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

## 查看 PR

- **列表**：`gh pr list --json number,title,author,state,isDraft,reviewDecision --state open`
- **单个 PR 详情**：`gh pr view <n> --json state,mergeable,mergeStateStatus,reviewDecision,reviews,comments,statusCheckRollup`
- **看 diff**：`gh pr diff <n>`
- **看 CI**：`gh pr checks <n>`

## Review PR

- **提 review comment**（写在待定 review 里）：在 PR 页面操作，或用 `gh api` 构造；简单情形直接用：
  - 同意合并：`gh pr review <n> --approve --body "<总体评价>"`
  - 请求修改：`gh pr review <n> --request-changes --body "<要求修改的原因>"`
  - 纯评论：`gh pr review <n> --comment --body "<评论>"`
- **读 review 评论**：`gh api repos/:owner/:repo/pulls/<n>/comments`

## 更新 PR

- **改标题/body**：`gh pr edit <n> --title "..." --body "..."`
- **加/去 reviewer**：`gh pr edit <n> --add-reviewer <user>` / `--remove-reviewer <user>`
- **加/去 label**：`gh pr edit <n> --add-label needs-review` / `--remove-label wip`
- **同步 base 分支**（merge base into PR branch）：`gh pr update-branch <n>`
- **push 新 commits**：正常 `git push`，PR 自动更新

## 合并 PR（破坏性 - 需用户确认）

**每次合并前必做**：

1. 确认 CI 通过：`gh pr checks <n>`
2. 确认 review 状态：`gh pr view <n> --json reviewDecision,mergeable`
3. 征求用户确认：「要用 squash 合并 PR #<n> 吗？」

确认后执行：

```bash
gh pr merge <n> --squash --delete-branch
```

- `--squash` 是团队默认策略；如果用户明确要保留 commit 历史，用 `--merge`；rebase 场景用 `--rebase`。
- `--delete-branch` 合并后自动删 feature 分支，保持仓库干净。

## 常见组合

- **查看"等我 review 的 PR"**：`gh pr list --search "review-requested:@me" --json number,title,author`
- **查看我开的 PR**：`gh pr list --author @me --json number,title,state,reviewDecision`
- **从 issue 到 PR 的链路**：创建分支时命名带 issue 编号（`feat/42-add-x`），PR body 里写 `Closes #42`
