# Claude Code Attribution Guidelines

**Last Updated**: 2025-11-07

---

## Overview

This blueprint uses Claude Code for automation. Attribution is **automatically included** in all user-facing operations to credit the tool and provide transparency.

---

## Attribution Format

All automated operations include this footer:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Where Attribution MUST Appear ✅

### 1. Git Commits

**Commit Template** (`.github/commit-template.txt`):
- Attribution included in template automatically
- All commits using the template will have attribution

**Slash Commands** (`/commit-smart`, `/kill-switch`, `/release`):
- When creating commits, append attribution to message:

```bash
git commit -m "$(cat <<'EOF'
feat(feature): add new capability

Description of changes here.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 2. Pull Requests

**Slash Commands** (`/create-pr`, `/release`):
- When creating PRs, append attribution to body:

```bash
gh pr create \
  --title "feat: add feature" \
  --body "$(cat <<'EOF'
## Summary
Description of changes

## Changes
- Change 1
- Change 2

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 3. GitHub Issues

**Workflows** (claude-plan-to-issues.yml):
- When creating issues from plans, append attribution to body

**Agents** (plan-converter.md):
- When creating issues, append attribution to body:

```bash
gh issue create \
  --title "Task title" \
  --body "$(cat <<'EOF'
Task description and acceptance criteria

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### 4. PR/Issue Comments

**Slash Commands** (`/review-pr`):
- When posting review comments, include attribution at end

**Agents** (workflow-manager.md):
- When posting status updates, include attribution

**Workflows** (pr-into-dev.yml, dev-to-main.yml):
- When posting validation comments, include attribution

```bash
gh pr comment $PR_NUMBER --body "$(cat <<'EOF'
Comment content here

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### 5. Releases

**Slash Commands** (`/release`):
- When creating GitHub releases, include attribution in notes

```bash
gh release create v$VERSION \
  --title "Release v$VERSION" \
  --notes "$(cat <<'EOF'
Release notes here

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Where Attribution Should NOT Appear ❌

### Claude's Manual Operations (During Development/Debugging)

When **Claude (the AI assistant)** creates commits/PRs/comments manually during a conversation (not via commands/workflows), attribution should **NOT** be included:

```bash
# ❌ NO - Claude's manual commit during debugging
git commit -m "fix: debug issue"

# ❌ NO - Claude's manual PR during development
gh pr create --title "WIP: test fix" --body "Testing changes"

# ❌ NO - Claude's exploratory comments
gh pr comment 123 --body "Investigating issue..."
```

**Why?** These are development/debugging operations by Claude, not user-facing automated features.

### Validation/Error Messages

- Workflow validation failures
- Quality gate error messages
- Bootstrap warnings
- General error output

**Why?** These are system messages, not generated content.

---

## Implementation Checklist

### Commands (`.claude/commands/github/`)

- [ ] `/commit-smart` - Add attribution to commit message instructions
- [ ] `/create-pr` - Add attribution to PR body instructions
- [ ] `/release` - Add attribution to release PR and notes
- [ ] `/kill-switch` - Add attribution to emergency commits
- [ ] `/review-pr` - Add attribution to review comments
- [ ] `/sync-status` - Add attribution to status comments

### Agents (`.claude/agents/`)

- [ ] `plan-converter.md` - Add attribution to issue creation
- [ ] `workflow-manager.md` - Add attribution to comments
- [ ] `blueprint-setup.md` - Add attribution to setup commits

### Workflows (`.github/workflows/`)

- [ ] `claude-plan-to-issues.yml` - Add attribution to issues
- [ ] `pr-into-dev.yml` - Add attribution to validation comments
- [ ] `dev-to-main.yml` - Add attribution to gate comments
- [ ] `create-branch-on-issue.yml` - Add attribution to branch comments
- [ ] `pr-status-sync.yml` - Add attribution to status updates
- [ ] `release-status-sync.yml` - Add attribution to release comments

### Templates

- [x] `.github/commit-template.txt` - Attribution included ✅

---

## Customization

To modify or remove attribution:

1. **Commit Template**: Edit `.github/commit-template.txt`
2. **Commands**: Edit instructions in `.claude/commands/github/*.md`
3. **Agents**: Edit templates in `.claude/agents/*.md`
4. **Workflows**: Edit comment/issue/PR creation in `.github/workflows/*.yml`

---

## Benefits

- **Credits the Tool**: Acknowledges Claude Code's role in automation
- **Transparency**: Team members know which operations are AI-assisted
- **Discoverability**: Links to Claude Code for others to learn
- **Accountability**: Clear distinction between automated and manual operations
- **Consistency**: Standardized attribution across all automated operations

---

## Examples

### Good: Automated Command

```bash
# User runs: /commit-smart
# Result: Commit with attribution

feat(auth): implement SSO login

Added single sign-on authentication using OAuth 2.0.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Good: Automated Workflow

```yaml
# Workflow creates issue from plan
# Issue body includes attribution

Task: Implement user dashboard

Acceptance Criteria:
- Display user statistics
- Show recent activity
- Include logout button

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Bad: Claude's Manual Operation (Don't Add)

```bash
# Claude debugging during conversation
git commit -m "test: debug workflow"
# ❌ NO attribution - this is Claude's development work
```

---

## Questions?

For questions about attribution:
- See command/workflow source code
- Check `.github/commit-template.txt` for commit attribution
- Review this documentation for guidelines

---

**Remember**: Attribution is for **user-facing automated operations**, not Claude's manual development/debugging activities.
