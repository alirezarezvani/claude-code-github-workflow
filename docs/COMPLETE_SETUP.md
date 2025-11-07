# Complete Setup Guide

Comprehensive step-by-step guide for setting up the GitHub Workflow Blueprint with all configuration options and advanced features.

---

## Table of Contents

1. [Detailed Prerequisites](#detailed-prerequisites)
2. [Installation Methods](#installation-methods)
3. [Configuration Options](#configuration-options)
4. [Branch Protection Setup](#branch-protection-setup)
5. [Secrets Configuration](#secrets-configuration)
6. [Verification Steps](#verification-steps)
7. [Advanced Options](#advanced-options)
8. [Troubleshooting](#troubleshooting)

---

## 📋 Detailed Prerequisites

### System Requirements

| Requirement | Minimum | Recommended | Notes |
|-------------|---------|-------------|-------|
| **Git** | 2.23+ | 2.40+ | For branch protection features |
| **GitHub CLI** | 2.0+ | Latest | Required for automation |
| **Node.js** | 18+ | 20+ | For web projects |
| **pnpm** | 8+ | 9+ | Faster than npm |
| **OS** | Any | macOS/Linux | Windows WSL2 recommended |

### Tool Installation

#### GitHub CLI

```bash
# macOS
brew install gh
gh --version  # Verify installation

# Ubuntu/Debian
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Windows (PowerShell)
winget install --id GitHub.cli

# Authenticate
gh auth login
gh auth status  # Verify
```

#### Node.js & pnpm

```bash
# Install Node.js via nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
node --version

# Install pnpm
npm install -g pnpm@latest
pnpm --version
```

### GitHub Account Setup

1. **Repository Access**
   - Admin permissions required
   - Ability to create and manage GitHub Actions
   - Ability to create and manage secrets

2. **GitHub Projects v2 Board**
   ```bash
   # Create via GitHub CLI
   gh project create --owner @me --title "My Project Board"

   # Or via web: https://github.com/users/USERNAME/projects → New Project
   ```

3. **Status Field Configuration**
   - Navigate to your project board
   - Click "⚙️" (Settings) → "Fields"
   - Ensure "Status" field exists with these options:
     - To Triage
     - Backlog
     - Ready
     - In Progress
     - In Review
     - To Deploy
     - Done

   **Note**: You can customize names, but update workflows accordingly.

### Anthropic API Access

1. **Sign up**: https://console.anthropic.com/
2. **Create API Key**: Settings → API Keys → "Create Key"
3. **Save securely**: You'll only see it once
4. **Verify**:
   ```bash
   curl https://api.anthropic.com/v1/messages \
     -H "x-api-key: YOUR_KEY" \
     -H "anthropic-version: 2023-06-01" \
     -H "content-type: application/json" \
     -d '{
       "model": "claude-3-5-sonnet-20241022",
       "max_tokens": 1024,
       "messages": [{"role": "user", "content": "Hello"}]
     }'
   ```

---

## 🚀 Installation Methods

### Method 1: Wizard Setup (Recommended)

Use the interactive wizard for quickest setup:

```bash
# Clone blueprint
git clone https://github.com/alirezarezvani/claude-code-github-workflow.git
cd claude-code-github-workflow

# Run wizard
./setup/wizard.sh

# Follow prompts to configure:
# 1. Project type (web/mobile/fullstack)
# 2. Branching strategy (simple/standard/complex)
# 3. Project board URL
# 4. Anthropic API key
# 5. Optional features

# Wizard automatically:
# - Copies files to correct locations
# - Sets secrets
# - Runs bootstrap workflow
# - Validates setup
```

### Method 2: Manual Setup

For full control over configuration:

#### Step 1: Copy Blueprint Files

```bash
# Clone repository
git clone https://github.com/alirezarezvani/claude-code-github-workflow.git blueprint
cd your-project

# Copy workflow files
mkdir -p .github/{workflows,actions,ISSUE_TEMPLATE}
cp -r blueprint/.github/workflows/* .github/workflows/
cp -r blueprint/.github/actions/* .github/actions/
cp -r blueprint/.github/ISSUE_TEMPLATE/* .github/ISSUE_TEMPLATE/
cp blueprint/.github/pull_request_template.md .github/
cp blueprint/.github/commit-template.txt .github/
cp blueprint/.github/CODEOWNERS .github/
cp blueprint/.github/dependabot.yml .github/

# Copy Claude Code files
mkdir -p .claude/{commands/github,agents}
cp -r blueprint/.claude/commands/github/* .claude/commands/github/
cp -r blueprint/.claude/agents/* .claude/agents/

# Copy setup scripts
cp -r blueprint/setup/ ./setup/

# Clean up
rm -rf blueprint
```

#### Step 1.5: Configure Git Remote

**CRITICAL**: The blueprint is a template. You must use it in YOUR own repository.

**If you cloned the template directly**:
```bash
# Check current remote
git remote get-url origin
# If it shows: https://github.com/alirezarezvani/claude-code-github-workflow.git
# You need to update it!

# Option A: Create new GitHub repository and update remote
gh repo create my-project --public --source=. --remote=origin

# Option B: Manually update to existing repository
git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Verify the change
git remote get-url origin
# Should show YOUR repository, not the template
```

**Why this matters**:
- ❌ **Wrong**: Pushing to template repository (you don't have permission)
- ✅ **Right**: Pushing to your own repository
- The setup wizard will detect and help fix this automatically

**If you copied files to existing repository**:
- No action needed - your git remote is already correct ✅

#### Step 2: Configure for Your Project Type

**For Web Projects**:
```yaml
# Edit .github/workflows/reusable-pr-checks.yml
# Ensure mobile_check is false
with:
  mobile_check: false
  integration_tests: true
```

**For Mobile Projects**:
```yaml
# Edit .github/workflows/reusable-pr-checks.yml
with:
  mobile_check: true
  integration_tests: true
```

**For Fullstack Projects**:
```yaml
# Edit .github/workflows/reusable-pr-checks.yml
with:
  mobile_check: false  # Set true if mobile included
  integration_tests: true
```

#### Step 3: Choose Branching Strategy

**Simple Strategy** (feature → main):
```bash
# Edit workflows to remove dev branch checks
# Files to modify:
# - .github/workflows/pr-into-dev.yml → pr-into-main.yml
# - .github/workflows/create-branch-on-issue.yml (change base to main)

# Update PR target
sed -i '' 's/base: dev/base: main/g' .github/workflows/*.yml
```

**Standard Strategy** (feature → dev → main) - DEFAULT:
No changes needed, works out of the box.

**Complex Strategy** (feature → dev → staging → main):
```bash
# Create staging branch
git checkout -b staging
git push -u origin staging

# Add staging workflows
cp .github/workflows/dev-to-main.yml .github/workflows/dev-to-staging.yml
# Edit dev-to-staging.yml to target staging instead of main

cp .github/workflows/dev-to-main.yml .github/workflows/staging-to-main.yml
# Edit staging-to-main.yml to accept PRs from staging only
```

---

## 🔧 Configuration Options

### Project Type Configuration

#### Web Project (Next.js/React/Vue)

**package.json scripts**:
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:ci": "jest --ci --coverage"
  }
}
```

**Required files**:
- `.eslintrc.json` - ESLint configuration
- `tsconfig.json` - TypeScript configuration (if using TS)
- `jest.config.js` - Jest configuration

#### Mobile Project (React Native/Expo)

**package.json scripts**:
```json
{
  "scripts": {
    "start": "expo start",
    "android": "expo run:android",
    "ios": "expo run:ios",
    "lint": "eslint .",
    "type-check": "tsc --noEmit",
    "test": "jest"
  }
}
```

**Enable mobile checks**:
```yaml
# .github/workflows/reusable-pr-checks.yml
with:
  mobile_check: true
```

#### Fullstack Project (MERN/MEAN)

**Monorepo structure**:
```
project/
├── packages/
│   ├── frontend/      # React/Next.js
│   │   └── package.json
│   ├── backend/       # Express/NestJS
│   │   └── package.json
│   └── mobile/        # Expo (optional)
│       └── package.json
├── package.json       # Root workspace
└── pnpm-workspace.yaml
```

**pnpm-workspace.yaml**:
```yaml
packages:
  - 'packages/*'
```

**Root package.json**:
```json
{
  "scripts": {
    "lint": "pnpm -r lint",
    "type-check": "pnpm -r type-check",
    "test": "pnpm -r test",
    "build": "pnpm -r build"
  }
}
```

---

## 🛡️ Branch Protection Setup

### Required Protection Rules

#### For `main` Branch

```bash
# Via GitHub CLI
gh api repos/:owner/:repo/branches/main/protection -X PUT --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["build-prod", "smoke-tests"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_linear_history": true,
  "allow_squash_merge": true,
  "allow_merge_commit": false,
  "allow_rebase_merge": false
}
EOF
```

#### For `dev` Branch

```bash
gh api repos/:owner/:repo/branches/dev/protection -X PUT --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["lint", "typecheck", "test-unit"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_linear_history": true,
  "allow_squash_merge": true,
  "allow_merge_commit": false,
  "allow_rebase_merge": false
}
EOF
```

#### Via GitHub UI

1. Go to: **Settings** → **Branches** → **Add rule**
2. Branch name pattern: `main` or `dev`
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1)
   - ✅ Dismiss stale pull request approvals
   - ✅ Require status checks to pass
     - Select: `lint`, `typecheck`, `test-unit` (for dev)
     - Select: `build-prod`, `smoke-tests` (for main)
   - ✅ Require branches to be up to date
   - ✅ Require linear history
   - ✅ Do not allow bypassing settings
4. Save changes

---

## 🔐 Secrets Configuration

### Required Secrets

#### 1. ANTHROPIC_API_KEY

```bash
# Via GitHub CLI
gh secret set ANTHROPIC_API_KEY
# Paste your key when prompted

# Or via GitHub UI
# Settings → Secrets and variables → Actions → New repository secret
# Name: ANTHROPIC_API_KEY
# Value: sk-ant-api03-...
```

#### 2. PROJECT_URL

```bash
# Get your project URL
gh project list --owner @me

# Set the secret (format: https://github.com/users/USERNAME/projects/NUMBER)
gh secret set PROJECT_URL
# Paste: https://github.com/users/yourname/projects/1
```

**Valid formats**:
- User project: `https://github.com/users/USERNAME/projects/NUMBER`
- Org project: `https://github.com/orgs/ORGNAME/projects/NUMBER`

**Validation**:
```bash
# Verify secrets are set
gh secret list

# Test PROJECT_URL access
gh project view NUMBER --owner @me
```

### Optional Secrets

#### SLACK_WEBHOOK_URL (Notifications)

```bash
gh secret set SLACK_WEBHOOK_URL
# Paste your Slack webhook URL
```

Usage in workflows:
```yaml
- name: Notify Slack
  if: failure()
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK_URL }} \
      -H 'Content-Type: application/json' \
      -d '{"text":"Workflow failed: ${{ github.workflow }}"}'
```

#### DEPLOY_KEY (Deployments)

```bash
# Generate SSH key for deployments
ssh-keygen -t ed25519 -C "github-actions" -f deploy_key

# Add public key to deployment server
cat deploy_key.pub

# Add private key to GitHub secrets
gh secret set DEPLOY_KEY < deploy_key
rm deploy_key deploy_key.pub
```

---

## ✅ Verification Steps

### Step 1: Validate File Structure

```bash
# Check all required files exist
./setup/validate.sh

# Manual check
tree -L 3 .github .claude
# Should show:
# .github/
# ├── workflows/ (8 files)
# ├── actions/ (5 directories)
# ├── ISSUE_TEMPLATE/ (2 files)
# └── ... (4 config files)
# .claude/
# ├── commands/github/ (8 files)
# └── agents/ (4 files)
```

### Step 2: Run Bootstrap Workflow

```bash
# Trigger bootstrap
gh workflow run bootstrap.yml

# Wait for completion
gh run watch

# Check results
gh run list --workflow=bootstrap.yml --limit 1

# View logs if needed
gh run view --log
```

**Expected output**:
```
✅ Created 15 labels
✅ Validated project board access
✅ Confirmed required secrets exist
✅ Setup complete!
```

### Step 3: Test Issue-to-Branch Flow

```bash
# Create test issue
gh issue create \
  --title "Test: Verify automation" \
  --body "Testing the blueprint automation" \
  --label "claude-code,status:ready,type:feature"

# Check branch was created (wait ~10 seconds)
git fetch origin
git branch -r | grep "feature/issue-"

# Should see: origin/feature/issue-1-test-verify-automation
```

### Step 4: Test Quality Checks

```bash
# Checkout test branch
git checkout feature/issue-1-test-verify-automation

# Make a change
echo "# Test" > TEST.md
git add TEST.md
git commit -m "test: verify quality checks"
git push origin feature/issue-1-test-verify-automation

# Create PR
gh pr create \
  --title "test: verify quality checks" \
  --body "Closes #1" \
  --base dev

# Watch quality checks run
gh pr checks

# Should see:
# ✓ lint
# ✓ typecheck
# ✓ test-unit
# ✓ conventional-commit
# ✓ linked-issue
```

### Step 5: Verify Project Board Sync

```bash
# Check issue status on project board
gh project item-list NUMBER --owner @me --format json | jq '.items[] | select(.content.number==1) | .fieldValues'

# Should show status: "In Review" (after PR created)
```

---

## 🔧 Advanced Options

### Custom Labels

Add custom labels beyond the defaults:

```bash
# Create custom labels
gh label create "priority:urgent" --color "d73a4a" --description "Urgent priority"
gh label create "platform:desktop" --color "1d76db" --description "Desktop platform"

# Use in workflows
# .github/workflows/custom-workflow.yml
on:
  issues:
    types: [labeled]

jobs:
  custom-handler:
    if: contains(github.event.issue.labels.*.name, 'priority:urgent')
    runs-on: ubuntu-latest
    steps:
      - name: Handle urgent issue
        run: echo "Urgent issue detected!"
```

### Modified Workflows

#### Disable Mobile Checks

```yaml
# .github/workflows/reusable-pr-checks.yml
# Remove or comment out mobile job
# jobs:
#   mobile-check:
#     if: needs.changes.outputs.mobile == 'true'
#     ...
```

#### Add Custom Quality Check

```yaml
# .github/workflows/pr-into-dev.yml
jobs:
  # ... existing jobs ...

  custom-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run custom check
        run: |
          # Your custom validation
          ./scripts/custom-validation.sh
```

### Integration with External Tools

#### Jira Integration

```yaml
# .github/workflows/jira-sync.yml
name: Sync with Jira

on:
  issues:
    types: [opened, closed]

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Sync to Jira
        env:
          JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
        run: |
          # Sync issue to Jira
          curl -X POST https://your-domain.atlassian.net/rest/api/3/issue \
            -H "Authorization: Bearer $JIRA_API_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"fields":{"project":{"key":"PROJ"},"summary":"${{ github.event.issue.title }}"}}'
```

#### Deployment to Vercel

```yaml
# .github/workflows/deploy-vercel.yml
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

---

## 🐛 Troubleshooting

### Bootstrap Fails

**Problem**: Bootstrap workflow fails with "PROJECT_URL not found"

**Solution**:
```bash
# Verify secret format
gh secret list | grep PROJECT_URL

# Test access
gh project view NUMBER --owner @me

# Re-set secret with correct format
gh secret set PROJECT_URL
```

### Branch Not Created

**Problem**: Issue has correct labels but no branch created

**Solution**:
```bash
# Check workflow run
gh run list --workflow=create-branch-on-issue.yml --limit 5

# View logs
gh run view [RUN_ID] --log

# Common causes:
# 1. Branch already exists → Delete and retry
# 2. Workflow disabled → Check .github/workflows/create-branch-on-issue.yml
# 3. Permissions issue → Check GITHUB_TOKEN permissions
```

### Quality Checks Timeout

**Problem**: PR checks run for >10 minutes and timeout

**Solution**:
```bash
# Check if caching is working
# .github/workflows/reusable-pr-checks.yml should have:
- uses: actions/cache@v3
  with:
    path: |
      ~/.pnpm-store
      node_modules
    key: ${{ runner.os }}-pnpm-${{ hashFiles('**/pnpm-lock.yaml') }}

# Manually clear cache
gh cache delete [CACHE_KEY]

# Increase timeout (if needed)
# Add to job:
timeout-minutes: 15
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for comprehensive issue resolution.

---

## 📚 Next Steps

- **Test workflows**: Create a few issues and PRs to verify everything works
- **Customize**: Adapt workflows to your specific needs ([CUSTOMIZATION.md](CUSTOMIZATION.md))
- **Learn commands**: Master all 8 slash commands ([COMMANDS.md](COMMANDS.md))
- **Understand workflows**: Deep dive into automation ([WORKFLOWS.md](WORKFLOWS.md))
- **Optimize**: Fine-tune quality gates and performance

---

**Setup complete!** Your repository now has production-ready automation. 🎉

**Questions?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or open an issue.
