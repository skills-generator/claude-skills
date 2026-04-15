---
name: github-ops
description: GitHub PR 和 Issue 的日常管理。用于创建、查看、review、更新、合并 pull request，以及创建、查看、分类、分配、关闭 issue，管理 label 和 assignee。统一使用 gh CLI 执行所有 GitHub 操作。
---

# GitHub Ops

一个面向**小团队**的 Claude Code skill，把 PR 和 Issue 的日常操作统一到 `gh` CLI，并在 SKILL.md 里显式记录团队约定（分支命名、PR 标题、reviewer、合并策略），减少每次向 Claude 重复解释。

## 功能范围

**包含**

- PR：创建、查看列表/详情、review（approve / request-changes / comment）、更新（标题/body/reviewer/label）、同步 base 分支、squash 合并
- Issue：创建、查看列表/详情、加减 label、分配/取消 assignee、评论、关闭/重开、与 PR 联动关闭

**不包含**

- 仓库创建、fork、settings、branch protection
- release / tag 发布
- GitHub Actions workflow 触发（需要 token 有 `workflow` scope）

---

## 前置要求

1. **gh CLI** 已安装（`gh --version` 验证），推荐 2.60+
2. **已登录 GitHub**：运行 `gh auth login`，选 HTTPS + token 或浏览器授权
3. **Token scopes**：至少需要 `repo`；要操作 org 成员/team 信息可加 `read:org`
4. 用 `gh auth status` 确认当前账号和 scopes

---

## 安装方式

三选一，推荐方式 1：

### 1. 用户全局（推荐个人使用）

```bash
mkdir -p ~/.claude/skills
cp -r skills/github-ops ~/.claude/skills/
```

之后在任何项目里启动 Claude Code 都会自动加载此 skill。

### 2. 项目级（推荐团队共用）

把 skill 目录放到你项目的 `.claude/skills/` 下，跟着仓库一起版本化，团队成员克隆后自动生效：

```bash
mkdir -p <your-project>/.claude/skills
cp -r skills/github-ops <your-project>/.claude/skills/
```

### 3. 直接在本仓库内使用

克隆本仓库后在仓库根目录启动 Claude Code，skill 会被发现。

---

## 使用方法

### 如何触发

skill 靠 frontmatter 里的 `description` 字段匹配用户意图。以下表达会自动触发（无需手动 `/命令`）：

- "帮我提个 PR，标题叫 xxx"
- "看下当前有哪些 open PR"
- "review 一下 PR #12"
- "把 PR #12 合并掉"
- "开个 bug issue，描述 xxx"
- "把 issue #7 分给 alice"
- "列出所有带 bug label 的 issue"

### 典型示例

**创建 PR**

> 用户：帮我为当前分支提个 PR，Closes #5

Claude 会：
1. 读 `git status` / `git diff` / `git log base..HEAD` 搞清楚变更
2. 按约定生成 `feat: xxx` 格式的标题和 Summary + Test plan 结构的 body
3. 带上默认 reviewer，base=main
4. `gh pr create` 并把 PR URL 回给你

**合并 PR（有确认门槛）**

> 用户：合并 PR #12

Claude 会：
1. `gh pr checks 12` 确认 CI 通过
2. `gh pr view 12 --json reviewDecision,mergeable` 检查 review 状态
3. **向你确认** 再执行 `gh pr merge 12 --squash --delete-branch`

**Issue 分类**

> 用户：issue #7 是个 bug，分给 alice 处理

Claude 会：`gh issue edit 7 --add-label bug --add-assignee alice`

### 定制团队约定

**打开 `skills/github-ops/SKILL.md`，编辑底部的"团队约定"章节**：

- 把 `<队友1-github-username>` / `<队友2-github-username>` 换成真实 GitHub 用户名
- 按需修改分支命名规则、PR 标题格式、合并策略、label 集合

改完 SKILL.md 后 Claude 下次触发时会读到新约定，无需重启。

---

## 给 Claude 的执行规则

以下内容是 skill 触发时 Claude 应遵循的操作指引。

### 何时触发

- 用户提到 **PR**：创建、查看、review、更新、合并、rebase、check 状态
- 用户提到 **Issue**：创建、查看、分配、关闭、加 label、指派 assignee
- 用户说 "提 PR"、"开 issue"、"合并"、"分配队友"、"看下现在有哪些 PR/issue"

### 工具约定

- 所有 GitHub 操作使用 `gh` CLI，通过 Bash tool 执行
- 需要结构化数据时加 `--json <fields>`，避免解析人类可读输出
- 不使用 `mcp__github__*` 工具，保持单一工具路径
- **破坏性或对外可见操作前必须征求用户确认**：merge、close、删除评论、force push
- `gh pr merge` 之前先 `gh pr checks` 确认 CI 通过

### 团队约定（用户请编辑此节）

- **默认 base 分支**：`main`
- **分支命名**：`<type>/<short-slug>`，type ∈ `feat` / `fix` / `docs` / `chore` / `refactor`
- **PR 标题格式**：`<type>: <summary>`（conventional commits 风格）
- **默认 reviewer**：`<队友1-github-username>`, `<队友2-github-username>`
- **合并策略**：`--squash`（保持 main 线性历史）
- **常用 label**：`bug`, `enhancement`, `blocked`, `needs-review`, `wip`
- **Issue 关联**：PR body 里用 `Closes #<n>` 自动关闭对应 issue

### 详细流程

- PR 全流程（创建 / 查看 / review / 更新 / 合并）：见 `references/pr-workflow.md`
- Issue 全流程（创建 / 查看 / 分类 / 分配 / 关闭）：见 `references/issue-workflow.md`

按需加载对应 reference，不要默认把两个都读进来。
