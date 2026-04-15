# Issue 工作流

所有命令通过 Bash tool 调用 `gh`。

## 创建 Issue

```bash
gh issue create \
  --title "<简洁描述>" \
  --label bug \
  --assignee <队友-username> \
  --body "$(cat <<'EOF'
## 现象
<描述发生了什么>

## 复现步骤
1. ...
2. ...

## 期望
<应该怎样>

## 环境 / 线索
<相关日志、文件路径>
EOF
)"
```

- 标题避免"xxx 的问题"这种模糊措辞；用动词或名词短语直接点问题
- 不确定 assignee 时先不指派，列 issue 后再分
- 不确定 label 时看已有 label：`gh label list`

## 查看 Issue

- **列表**：`gh issue list --json number,title,state,labels,assignees --state open`
- **按 assignee 过滤**：`gh issue list --assignee @me --json number,title,labels`
- **按 label 过滤**：`gh issue list --label bug --json number,title,assignees`
- **单个详情**：`gh issue view <n> --json title,body,state,labels,assignees,comments`

## 分类和分配

- **加 label**：`gh issue edit <n> --add-label bug --add-label blocked`
- **去 label**：`gh issue edit <n> --remove-label wip`
- **分配 assignee**：`gh issue edit <n> --add-assignee <username>`
- **取消 assignee**：`gh issue edit <n> --remove-assignee <username>`
- **改标题**：`gh issue edit <n> --title "..."`

## 评论和关闭

- **加评论**：`gh issue comment <n> --body "..."`
- **关闭 issue（破坏性 - 必须走完整门槛）**：

  **关闭的必经步骤，任何一步都不得跳过**：

  1. **先查看 issue 状态**：`gh issue view <n> --json state,title,assignees,comments` 确认 issue 存在且处于 open
  2. **确认不是应该由 PR 联动关闭**：如果 issue 是被某个 PR 解决的，**优先在 PR body 里写 `Closes #<n>`**，合并时 GitHub 自动关闭——不要手工 close
  3. **向用户确认**：询问"准备关闭 issue #<n>（标题：<title>），关闭原因是：<reason>？"，**等待用户回答**
  4. **仅在用户明确同意后执行**：

     ```bash
     gh issue close <n> --comment "<关闭原因或解决方式>"
     ```

- **重开**：`gh issue reopen <n> --comment "..."`

## 常见组合

- **分给我的 open issue**：`gh issue list --assignee @me --state open --json number,title,labels`
- **未分配的 bug**：`gh issue list --label bug --search "no:assignee" --json number,title`
- **从 issue 直接开分支**（gh 2.63+）：`gh issue develop <n> --checkout`——会基于 base 分支创建命名规范的分支并切过去

## 队内协作模式

1. 发现问题 → `gh issue create` 加 `bug` 或 `enhancement` label，不急着分人
2. 每天同步时 → `gh issue list --state open --json ...` 看全局，协商分配
3. 开始干 → `gh issue edit <n> --add-assignee @me --add-label wip`
4. 提 PR → PR body 带 `Closes #<n>`
5. PR 合并 → issue 自动关闭
