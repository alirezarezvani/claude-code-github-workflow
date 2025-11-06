# Troubleshooting Guide

Comprehensive solutions for common issues with the GitHub Workflow Blueprint.

---

## Table of Contents

1. [Setup Issues](#setup-issues)
2. [Workflow Failures](#workflow-failures)
3. [Branch and PR Issues](#branch-and-pr-issues)
4. [Project Board Sync Issues](#project-board-sync-issues)
5. [Quality Check Failures](#quality-check-failures)
6. [Slash Command Issues](#slash-command-issues)
7. [Performance Issues](#performance-issues)
8. [Advanced Debugging](#advanced-debugging)

---

## 🚧 Setup Issues

### Issue: "gh command not found"

**Problem**: GitHub CLI not installed or not in PATH

**Solution**:
```bash
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# Windows
winget install GitHub.cli

# Verify installation
gh --version
which gh

# If installed but not found, add to PATH
export PATH="$PATH:/usr/local/bin"  # Add to ~/.bashrc or ~/.zshrc
```

**Alternative**: Download from https://cli.github.com/

---

### Issue: "gh auth login fails"

**Problem**: Authentication errors with GitHub CLI

**Solution**:
```bash
# Clear existing auth
gh auth logout

# Re-authenticate
gh auth login
# Choose: GitHub.com
# Choose: HTTPS
# Choose: Login with a web browser
# Follow browser prompt

# Verify
gh auth status

# If still failing, use token
gh auth login --with-token < token.txt
```

**Generate token**: https://github.com/settings/tokens
- Scopes needed: `repo`, `workflow`, `admin:org`, `project`

---

### Issue: "PROJECT_URL not set or invalid"

**Problem**: Secret not configured or wrong format

**Symptoms**:
- Bootstrap workflow fails
- Project sync workflows fail
- Error: "Could not find project"

**Solution**:
```bash
# Check current secrets
gh secret list

# Verify project exists
gh project list --owner @me

# Get correct URL format
# For user project: https://github.com/users/USERNAME/projects/NUMBER
# For org project: https://github.com/orgs/ORGNAME/projects/NUMBER

# Set/update secret
gh secret set PROJECT_URL
# Paste: https://github.com/users/yourname/projects/1

# Test access
gh project view 1 --owner @me

# Verify in workflow
gh workflow run bootstrap.yml
gh run watch
```

**Common mistakes**:
- ❌ `https://github.com/USERNAME/projects/1` (missing `/users/`)
- ❌ `https://github.com/projects/1` (missing owner)
- ✅ `https://github.com/users/USERNAME/projects/1` (correct)

---

### Issue: "ANTHROPIC_API_KEY not set or invalid"

**Problem**: Claude API key missing or expired

**Solution**:
```bash
# Get new API key
# Visit: https://console.anthropic.com/settings/keys

# Set secret
gh secret set ANTHROPIC_API_KEY
# Paste your key: sk-ant-api03-...

# Test key
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: YOUR_KEY_HERE" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "Hi"}]
  }'

# Should return a response, not 401 error
```

---

### Issue: "Bootstrap workflow fails with 'Label already exists'"

**Problem**: Labels created in previous run

**Solution**:
This is **not an error**! The workflow is idempotent and safe to re-run.

```bash
# View full logs to confirm success
gh run view --log

# Look for final status (should be green ✓)
# Individual label creation may show warnings but overall should succeed

# To start fresh (optional)
gh label list --json name --jq '.[].name' | xargs -I {} gh label delete {} --yes
gh workflow run bootstrap.yml
```

---

## 🔄 Workflow Failures

### Issue: "Workflow not triggering"

**Problem**: Workflow not running on expected events

**Diagnosis**:
```bash
# Check workflow syntax
gh workflow view [WORKFLOW_NAME]

# Check if workflow is enabled
gh workflow list

# View recent runs
gh run list --workflow=[WORKFLOW_NAME] --limit 10

# Check workflow file
cat .github/workflows/[WORKFLOW_FILE].yml
```

**Common causes**:

1. **Wrong branch filter**
   ```yaml
   # Check if your branch matches the filter
   on:
     pull_request:
       branches: [dev]  # Only triggers for PRs to 'dev'
   ```

2. **Killswitch enabled**
   ```bash
   # Check for killswitch file
   ls -la .github/WORKFLOW_KILLSWITCH

   # Remove if exists
   rm .github/WORKFLOW_KILLSWITCH
   git add .github/WORKFLOW_KILLSWITCH
   git commit -m "chore: disable killswitch"
   git push
   ```

3. **Path filters not matching**
   ```yaml
   # Check path filters
   paths:
     - 'src/**'  # Only triggers if src/ files changed
   ```

---

### Issue: "Rate limit exceeded"

**Problem**: Too many GitHub API calls

**Symptoms**:
- Error: "API rate limit exceeded"
- Workflows failing with 403 errors

**Solution**:
```bash
# Check current rate limit
gh api rate_limit

# Wait for reset (shown in response)

# Reduce API calls by:
# 1. Avoiding force pushes that retrigger workflows
# 2. Using workflow concurrency groups
# 3. Adding debouncing (10-second delays built-in)

# Emergency: Use killswitch
/kill-switch enable
```

**Prevention**:
- Rate limit check built into workflows (50+ calls minimum)
- Workflows skip on forks by default
- Debouncing prevents rapid retriggering

---

### Issue: "Workflow stuck in 'Queued' or 'In Progress'"

**Problem**: Workflow not completing

**Solution**:
```bash
# Check runner availability
gh api repos/:owner/:repo/actions/runners

# Cancel stuck run
gh run cancel [RUN_ID]

# Re-trigger
gh workflow run [WORKFLOW_NAME]

# Check for infinite loops
gh run list --limit 20
# Look for rapid succession of same workflow

# If infinite loop detected:
/kill-switch enable  # Stop all workflows
# Fix the issue
/kill-switch disable  # Re-enable
```

---

## 🌿 Branch and PR Issues

### Issue: "Branch not created automatically"

**Problem**: Issue has labels but no branch created

**Diagnosis**:
```bash
# Check issue labels
gh issue view NUMBER --json labels

# Check workflow runs
gh run list --workflow=create-branch-on-issue.yml --limit 5

# View logs
gh run view [RUN_ID] --log
```

**Required conditions**:
- Issue must have `claude-code` label
- Issue must have `status:ready` label
- Branch with same name must not already exist

**Solution**:
```bash
# Verify labels
gh issue edit NUMBER --add-label "claude-code,status:ready"

# Check if branch already exists
git fetch origin
git branch -r | grep "issue-NUMBER"

# If exists, delete and re-trigger
git push origin --delete feature/issue-NUMBER-title
# Remove and re-add label to trigger
gh issue edit NUMBER --remove-label "status:ready"
gh issue edit NUMBER --add-label "status:ready"
```

---

### Issue: "PR checks failing with 'no linked issue'"

**Problem**: PR doesn't reference an issue

**Solution**:
```bash
# PR body must contain:
# - "Closes #NUMBER"
# - "Fixes #NUMBER"
# - "Resolves #NUMBER"

# Update PR body
gh pr edit NUMBER --body "Closes #1

## Summary
My changes...
"

# Or via web UI: Edit PR description and add "Closes #1"

# Verification
gh pr view NUMBER --json body --jq '.body' | grep -i "closes\|fixes\|resolves"
```

---

### Issue: "PR checks fail with 'Conventional commit required'"

**Problem**: PR title doesn't follow conventional commits format

**Solution**:
```bash
# Current title
gh pr view NUMBER --json title --jq '.title'

# Update to conventional format
# Format: type(scope): description
# Types: feat, fix, docs, style, refactor, test, chore

gh pr edit NUMBER --title "feat: add user authentication"
gh pr edit NUMBER --title "fix(api): resolve CORS issue"
gh pr edit NUMBER --title "docs: update README"

# PR title will be used as merge commit message
```

**Valid types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructure
- `test`: Adding tests
- `chore`: Maintenance
- `perf`: Performance improvement

---

### Issue: "Can't push to feature branch - protected"

**Problem**: Trying to push to protected branch

**Solution**:
```bash
# Check branch protections
gh api repos/:owner/:repo/branches/[BRANCH]/protection

# Feature branches shouldn't be protected
# Only main/dev/staging should be protected

# If accidentally protected, remove protection
gh api repos/:owner/:repo/branches/[BRANCH]/protection -X DELETE

# Or via UI: Settings → Branches → Delete rule
```

---

## 📊 Project Board Sync Issues

### Issue: "Issue not appearing on project board"

**Problem**: Issue created but not on board

**Solution**:
```bash
# Manually add issue to project
gh project item-add NUMBER --owner @me --url https://github.com/OWNER/REPO/issues/ISSUE_NUMBER

# Check project items
gh project item-list NUMBER --owner @me

# Verify PROJECT_URL secret
gh secret list | grep PROJECT_URL

# Re-run project sync workflow
gh workflow run pr-status-sync.yml
```

---

### Issue: "Issue status not updating"

**Problem**: Status stuck on project board

**Diagnosis**:
```bash
# Check issue labels
gh issue view NUMBER --json labels

# Check recent workflow runs
gh run list --workflow=pr-status-sync.yml --limit 5

# View logs
gh run view [RUN_ID] --log

# Check project status field
gh project field-list NUMBER --owner @me
```

**Solution**:
```bash
# Manually update status
gh project item-edit \
  --id [ITEM_ID] \
  --field-id [STATUS_FIELD_ID] \
  --project-id [PROJECT_ID] \
  --single-select-option-id [OPTION_ID]

# Or trigger sync
/sync-status

# Check for debouncing (workflows wait 10 seconds)
# Recent rapid changes may be debounced
```

---

### Issue: "Status field not found"

**Problem**: Project board missing Status field

**Solution**:
1. Go to project board
2. Click ⚙️ Settings
3. Click "+ New field"
4. Name: "Status" (exact match)
5. Type: "Single select"
6. Add options:
   - To Triage
   - Backlog
   - Ready
   - In Progress
   - In Review
   - To Deploy
   - Done
7. Save

**Or customize status names in workflows**:
```yaml
# .github/workflows/pr-status-sync.yml
- uses: ./.github/actions/project-sync
  with:
    status-field: 'Status'  # Your field name
    status-value: 'My Custom Status'  # Your option name
```

---

## ✅ Quality Check Failures

### Issue: "Lint check failing"

**Problem**: Code doesn't pass linting

**Solution**:
```bash
# Run locally to see errors
npm run lint
# or
pnpm lint

# Auto-fix issues
npm run lint -- --fix

# Check ESLint config
cat .eslintrc.json

# Common fixes:
# 1. Unused variables → Remove or prefix with _
# 2. Missing semicolons → Add or configure ESLint
# 3. Wrong indentation → Run prettier

# Format code
npm run format
# or
npx prettier --write .

# Commit fixes
git add .
git commit -m "style: fix linting issues"
git push
```

---

### Issue: "Type check failing"

**Problem**: TypeScript errors

**Solution**:
```bash
# Run locally
npm run type-check
# or
npx tsc --noEmit

# Common errors:
# 1. Missing types → npm install --save-dev @types/[package]
# 2. Wrong types → Fix type annotations
# 3. tsconfig issues → Check tsconfig.json

# View errors in detail
npx tsc --noEmit --pretty

# Fix and push
git add .
git commit -m "fix: resolve type errors"
git push
```

---

### Issue: "Tests failing"

**Problem**: Unit tests not passing

**Solution**:
```bash
# Run tests locally
npm test

# Run with coverage
npm run test:coverage

# Run specific test
npm test -- path/to/test.spec.ts

# Update snapshots (if applicable)
npm test -- -u

# Debug failing test
npm test -- --watch

# Fix tests and push
git add .
git commit -m "test: fix failing tests"
git push
```

---

### Issue: "Quality checks timeout"

**Problem**: Checks take >10 minutes

**Solution**:
```bash
# Check if caching is working
# Should see "Cache restored" in logs
gh run view --log | grep -i cache

# Clear cache and retry
gh cache list
gh cache delete [CACHE_KEY]

# Optimize tests
# 1. Run tests in parallel
# 2. Mock expensive operations
# 3. Skip integration tests in PR checks

# Increase timeout (if necessary)
# .github/workflows/reusable-pr-checks.yml
jobs:
  test-unit:
    timeout-minutes: 15  # Default is 10
```

---

## 🤖 Slash Command Issues

### Issue: "Slash command not found"

**Problem**: Claude Code CLI not recognizing command

**Solution**:
```bash
# Verify command files exist
ls -la .claude/commands/github/

# Check command file format
cat .claude/commands/github/commit-smart.md

# Reload Claude Code CLI
# Restart your Claude Code session

# Try full path
claude-code run .claude/commands/github/commit-smart.md
```

---

### Issue: "/commit-smart fails with secrets detected"

**Problem**: Committing files with secrets

**Solution**:
```bash
# Review detected secrets
# Command shows which files have secrets

# Remove secrets
# 1. Move to .env file
# 2. Add .env to .gitignore
# 3. Use environment variables

# Example .env
cat > .env <<EOF
API_KEY=your_secret_key
DB_PASSWORD=your_password
EOF

# Add to .gitignore
echo ".env" >> .gitignore

# Update code to use env vars
# process.env.API_KEY

# Commit without secrets
git add .
/commit-smart
```

---

### Issue: "/create-pr fails - no issue linked"

**Problem**: Can't determine related issue

**Solution**:
```bash
# Ensure branch name includes issue number
# Format: feature/issue-NUMBER-description

# Current branch
git branch --show-current

# If wrong format, manually specify
/create-pr --issue 123

# Or include in PR body
gh pr create --body "Closes #123"
```

---

## ⚡ Performance Issues

### Issue: "Workflows running slow"

**Problem**: Checks take >5 minutes

**Diagnosis**:
```bash
# View workflow timing
gh run view [RUN_ID] --log | grep "took"

# Check job durations
gh run view [RUN_ID] --json jobs --jq '.jobs[] | {name, conclusion, duration}'
```

**Optimization**:

1. **Enable caching**:
   ```yaml
   - uses: actions/cache@v3
     with:
       path: ~/.pnpm-store
       key: ${{ runner.os }}-pnpm-${{ hashFiles('**/pnpm-lock.yaml') }}
       restore-keys: ${{ runner.os }}-pnpm-
   ```

2. **Use matrix for parallel tests**:
   ```yaml
   strategy:
     matrix:
       test-group: [unit, integration, e2e]
   ```

3. **Skip unnecessary checks**:
   ```yaml
   # Skip mobile checks for backend-only changes
   if: steps.changes.outputs.mobile == 'true'
   ```

---

## 🔍 Advanced Debugging

### Enable Workflow Debug Logging

```bash
# Set repository variable
gh variable set ACTIONS_STEP_DEBUG --body "true"
gh variable set ACTIONS_RUNNER_DEBUG --body "true"

# Re-run workflow
gh workflow run [WORKFLOW_NAME]

# View detailed logs
gh run view --log
```

### Check Workflow Permissions

```bash
# View token permissions
gh api repos/:owner/:repo/actions/permissions

# Update if needed
# Settings → Actions → General → Workflow permissions
# Select: "Read and write permissions"
```

### Inspect GitHub API Responses

```bash
# Test API access
gh api repos/:owner/:repo/issues

# Test project access
gh api graphql -f query='
  query {
    user(login: "USERNAME") {
      projectV2(number: NUMBER) {
        id
        title
      }
    }
  }
'

# Check rate limit
gh api rate_limit
```

---

## 📞 Getting Help

### Still Stuck?

1. **Check logs**: `gh run view --log`
2. **Search issues**: [github.com/yourrepo/issues](https://github.com)
3. **Ask community**: GitHub Discussions
4. **Open issue**: Include logs and config

### Information to Include

When reporting issues, provide:
```bash
# System info
uname -a
gh --version
git --version
node --version
pnpm --version

# Repository info
gh repo view

# Workflow logs
gh run view [RUN_ID] --log > workflow-logs.txt

# Secrets (names only, not values!)
gh secret list

# Recent runs
gh run list --limit 10
```

---

**Most issues are resolved within 5 minutes using this guide. Good luck!** 🚀

**Quick fixes not working?** Check [CUSTOMIZATION.md](CUSTOMIZATION.md) for advanced configuration options.
