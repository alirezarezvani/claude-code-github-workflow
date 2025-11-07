# GitHub Repository Setup Guide

**Complete configuration guide for GitHub Workflow Blueprint**

This guide covers all required settings to make the blueprint workflows function correctly.

---

## 📋 Table of Contents

1. [Required Secrets](#required-secrets)
2. [Branch Protection Rules](#branch-protection-rules)
3. [GitHub Projects v2 Setup](#github-projects-v2-setup)
4. [Repository Settings](#repository-settings)
5. [GitHub Actions Permissions](#github-actions-permissions)
6. [Labels Configuration](#labels-configuration)
7. [Optional Settings](#optional-settings)
8. [Validation Checklist](#validation-checklist)

---

## 🔐 Required Secrets

**Location**: Repository Settings → Secrets and variables → Actions

### 1. ANTHROPIC_API_KEY (Required for Claude Code features)

**Purpose**: Enables Claude Code Action for AI-powered code reviews

**How to get it**:
1. Go to https://console.anthropic.com/
2. Navigate to API Keys section
3. Create a new API key
4. Copy the key

**How to set it**:
```bash
# Via gh CLI
gh secret set ANTHROPIC_API_KEY

# Via GitHub UI
Settings → Secrets and variables → Actions → New repository secret
Name: ANTHROPIC_API_KEY
Secret: <your-api-key>
```

**Required by**:
- Claude Code Review workflow (optional, will skip if not set)

---

### 2. PROJECTS_TOKEN (Required for Project Board automation)

**Purpose**: Enables GitHub Projects v2 integration and Wiki sync

**How to create it**:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Name: `PROJECTS_TOKEN` or `GitHub Workflow Automation`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `project` (Full control of projects)
   - ✅ `write:discussion` (Read and write team discussions)
5. Set expiration (recommend: No expiration or 1 year)
6. Generate token and copy it

**How to set it**:
```bash
# Via gh CLI
gh secret set PROJECTS_TOKEN

# Via GitHub UI
Settings → Secrets and variables → Actions → New repository secret
Name: PROJECTS_TOKEN
Secret: <your-token>
```

**Required by**:
- `project-sync` composite action
- All workflows that update project board status
- Wiki sync workflow

---

### 3. CLAUDE_CODE_OAUTH_TOKEN (Optional)

**Purpose**: Alternative to ANTHROPIC_API_KEY for Claude Code Review

**How to get it**:
1. Go to https://claude.com/settings/oauth-tokens
2. Create new OAuth token
3. Copy the token

**How to set it**:
```bash
gh secret set CLAUDE_CODE_OAUTH_TOKEN
```

**Note**: Only needed if using OAuth flow instead of API key. The workflow will skip Claude Code Review if neither secret is set.

---

## 🛡️ Branch Protection Rules

**Location**: Repository Settings → Branches → Branch protection rules

### Main Branch Protection (CRITICAL)

**Branch name pattern**: `main`

**Required Settings**:

#### Protect matching branches
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: **1** (minimum)
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ⚠️ Do NOT check "Require approval from Code Owners" (unless you want this)

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - **Required status checks** (add these):
    - `Validate Source Branch`
    - `Production Build`
    - `Smoke Tests`
    - `Deployment Readiness`
    - `Release Gate Status`

- ✅ **Require conversation resolution before merging**

- ✅ **Require linear history** (enforces squash or rebase merges)

- ⚠️ **Do not allow bypassing the above settings** (recommended)

#### Rules applied to everyone including administrators
- ✅ **Restrict deletions** (cannot delete main branch)
- ✅ **Restrict force pushes** (cannot force push to main)
- ✅ **Require signed commits** (optional, recommended for security)

**CLI Command**:
```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"checks":[{"context":"Validate Source Branch"},{"context":"Production Build"},{"context":"Smoke Tests"},{"context":"Deployment Readiness"},{"context":"Release Gate Status"}]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field required_linear_history=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field required_conversation_resolution=true
```

---

### Dev Branch Protection (Recommended)

**Branch name pattern**: `dev`

**Required Settings**:

#### Protect matching branches
- ✅ **Require a pull request before merging**
  - ⚠️ Require approvals: **0** (or 1 if you want reviews)
  - ✅ Dismiss stale pull request approvals when new commits are pushed

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - **Required status checks**:
    - `Validate Branch Name`
    - `Validate PR Title`
    - `Validate Linked Issue`
    - `Run Quality Checks`

- ✅ **Require conversation resolution before merging**

- ⚠️ **Allow force pushes** (UNCHECKED - do not allow)

#### Rules applied to everyone including administrators
- ✅ **Restrict deletions**
- ⚠️ **Allow administrators to bypass** (optional, for emergency fixes)

**CLI Command**:
```bash
gh api repos/{owner}/{repo}/branches/dev/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"checks":[{"context":"Validate Branch Name"},{"context":"Validate PR Title"},{"context":"Validate Linked Issue"},{"context":"Run Quality Checks"}]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":0,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field required_conversation_resolution=true
```

---

## 📊 GitHub Projects v2 Setup

**Location**: Repository → Projects tab → Link a project

### Creating the Project Board

**Option 1: Via GitHub UI**

1. Go to your repository
2. Click **Projects** tab
3. Click **Link a project** → **New project**
4. Choose **Board** template
5. Name: `Development Workflow` (or your choice)
6. Click **Create project**

**Option 2: Via gh CLI**

```bash
# Create new project
gh project create --owner <username> --title "Development Workflow"

# Link to repository
gh project link <project-number> --repo <username>/<repo>
```

### Configure Status Field

**Required Status Values** (in this exact order):

| Status | Purpose |
|--------|---------|
| To Triage | New issues pending review |
| Backlog | Approved but not scheduled |
| Ready | Ready to start work |
| In Progress | Actively being worked on |
| In Review | PR created, awaiting review |
| To Deploy | Merged to dev, ready for release |
| Done | Released to production |

**How to configure**:

1. Open your project board
2. Click **⚙️** (Settings) in top-right
3. Go to **Custom fields** → **Status**
4. Add/edit status options to match the list above
5. Set default to **To Triage**

**Important**: The workflow expects these exact names. If you use different names, update the `project-sync` composite action.

### Get Project URL

You need the project URL for the `PROJECT_URL` secret:

```bash
# Via gh CLI
gh project list --owner <username>

# The URL will be like:
# https://github.com/users/<username>/projects/<number>
```

Save this URL - you'll need it for the bootstrap workflow.

---

## ⚙️ Repository Settings

**Location**: Repository Settings → General

### Required Settings

#### Features
- ✅ **Issues** (required for issue tracking)
- ✅ **Wikis** (required for wiki sync workflow)
- ⚠️ **Discussions** (optional, recommended for community)
- ⚠️ **Projects** (should be enabled automatically)

#### Pull Requests
- ✅ **Allow squash merging** (recommended default)
  - ✅ Default to pull request title
- ⚠️ **Allow merge commits** (optional)
- ⚠️ **Allow rebase merging** (optional)
- ✅ **Always suggest updating pull request branches**
- ✅ **Automatically delete head branches** (recommended)

#### Archives
- ⚠️ **Do not archive this repository** (unless intentional)

---

## 🔧 GitHub Actions Permissions

**Location**: Repository Settings → Actions → General

### Workflow Permissions

**Required Configuration**:

- ✅ **Allow all actions and reusable workflows**
  - (Or restrict to specific actions if you prefer)

**Workflow permissions**:
- ✅ **Read and write permissions**
  - Required for:
    - Creating/updating issues
    - Commenting on PRs
    - Updating project boards
    - Creating releases
    - Syncing wikis

- ✅ **Allow GitHub Actions to create and approve pull requests**
  - (Optional, only if you want automated PR creation)

### Actions Permissions

**Fork pull request workflows**:
- ✅ **Run workflows from fork pull requests**
  - Require approval for first-time contributors: **✅ Enabled**

---

## 🏷️ Labels Configuration

**Location**: Repository → Issues → Labels

### Required Labels

Run the `bootstrap.yml` workflow to automatically create these, or create manually:

#### Status Labels
- `status:ready` - 🟢 Green - Ready to start
- `status:in-progress` - 🟡 Yellow - Work in progress
- `status:in-review` - 🟠 Orange - In code review
- `status:to-deploy` - 🔵 Blue - Ready for deployment

#### Type Labels
- `type:feature` - 🟣 Purple - New feature
- `type:fix` - 🔴 Red - Bug fix
- `type:hotfix` - 🔥 Dark red - Critical hotfix
- `type:docs` - 📘 Light blue - Documentation
- `type:refactor` - 🔧 Grey - Code refactoring
- `type:test` - ✅ Green - Testing

#### Platform Labels
- `platform:web` - 🌐 Blue - Web platform
- `platform:mobile` - 📱 Purple - Mobile platform
- `platform:fullstack` - 🔗 Orange - Full-stack

#### Priority Labels
- `priority:critical` - 🔴 Red - Critical priority
- `priority:high` - 🟠 Orange - High priority
- `priority:medium` - 🟡 Yellow - Medium priority
- `priority:low` - 🟢 Green - Low priority

#### Meta Labels
- `claude-code` - 🤖 Purple - Created by Claude Code

**Auto-create labels**:
```bash
# Run bootstrap workflow
gh workflow run bootstrap.yml

# Or create via CLI
gh label create "status:ready" --color "0E8A16" --description "Ready to start"
gh label create "type:feature" --color "A855F7" --description "New feature"
# ... repeat for all labels
```

---

## 📌 Optional Settings

### GitHub Pages (for documentation site)

**Location**: Repository Settings → Pages

**Configuration**:
- ✅ **Source**: GitHub Actions
- ⚠️ **Branch**: (Leave as GitHub Actions, not gh-pages)
- ✅ **Enforce HTTPS**: Enabled

**Deployment**:
- Automatic via `deploy-pages.yml` workflow
- Site URL: `https://<username>.github.io/<repo>/`

---

### Dependabot

**Location**: Repository Settings → Code security and analysis

**Enable**:
- ✅ **Dependabot alerts**
- ✅ **Dependabot security updates**
- ✅ **Dependabot version updates** (configured via `.github/dependabot.yml`)

**Pre-configured** in this blueprint:
- Weekly npm dependency updates
- Weekly GitHub Actions updates

---

### Environments (for deployment)

**Location**: Repository Settings → Environments

**Recommended Environments**:

#### Staging
- **Protection rules**:
  - Required reviewers: 0 (or 1 if you want)
  - Wait timer: 0 minutes

#### Production
- **Protection rules**:
  - ✅ Required reviewers: 1+
  - ✅ Wait timer: 5 minutes (prevents accidental deployments)
  - ✅ Deployment branches: Only `main`

---

## ✅ Validation Checklist

After completing setup, verify everything works:

### 1. Secrets Verification

```bash
# Check secrets are set (will show names only, not values)
gh secret list
```

Expected output:
```
ANTHROPIC_API_KEY       Updated 2025-XX-XX
PROJECTS_TOKEN          Updated 2025-XX-XX
```

### 2. Run Bootstrap Workflow

```bash
# Run initial setup
gh workflow run bootstrap.yml

# Check status
gh run list --workflow=bootstrap.yml --limit 1
```

**Expected**: Creates labels, validates project board, checks secrets

### 3. Test Branch Protections

```bash
# Try to push directly to main (should fail)
git checkout main
echo "test" >> test.txt
git add test.txt
git commit -m "test: direct commit"
git push origin main

# Expected: rejected by remote
```

### 4. Create Test Issue

```bash
# Create test issue
gh issue create --title "Test: Validate setup" --body "Testing workflow automation"

# Expected: Issue created, added to project board in "To Triage" status
```

### 5. Test PR Flow

```bash
# Create feature branch
git checkout -b feature/test-setup
echo "# Test" > TEST.md
git add TEST.md
git commit -m "feat: test workflow"
git push -u origin feature/test-setup

# Create PR to dev
gh pr create --base dev --title "feat: Test workflow" --body "Closes #<issue-number>"

# Expected:
# - Branch name validation passes
# - PR title validation passes
# - Linked issue validation passes
# - Quality checks run
```

### 6. Verify Project Board Integration

1. Open your project board
2. Find the test issue created above
3. Verify it appears in "To Triage" column
4. Create a branch from the issue
5. Verify issue moves to "In Progress"

### 7. Test Release Flow

```bash
# Merge feature to dev
gh pr merge <pr-number> --squash

# Create release PR
gh pr create --base main --head dev --title "release: v1.0.0" --body "Release notes..."

# Expected:
# - Source branch validation passes (dev allowed)
# - All release gates run
# - Project board updates
```

---

## 🚨 Troubleshooting

### Issue: "PROJECTS_TOKEN secret not found"

**Solution**:
1. Verify secret is set: `gh secret list`
2. If missing, create PAT with `repo` and `project` scopes
3. Set secret: `gh secret set PROJECTS_TOKEN`

### Issue: "Cannot update project board"

**Solution**:
1. Verify project board exists and is linked to repo
2. Verify PROJECTS_TOKEN has `project` scope
3. Check project board status field has correct values
4. Run `gh project list --owner <username>` to verify access

### Issue: "Branch protection prevents merge"

**Solution**:
1. Verify required status checks are passing
2. Check branch protection rules match workflow names exactly
3. Temporarily disable "Require branches to be up to date" if needed

### Issue: "Workflow permissions error"

**Solution**:
1. Go to Settings → Actions → General
2. Set "Workflow permissions" to "Read and write permissions"
3. Enable "Allow GitHub Actions to create and approve pull requests"

### Issue: "Labels not found"

**Solution**:
```bash
# Run bootstrap workflow
gh workflow run bootstrap.yml

# Or create manually via CLI/UI
```

---

## 📖 Related Documentation

- [Quick Start Guide](docs/QUICK_START.md) - Get started in 5 minutes
- [Complete Setup Guide](docs/COMPLETE_SETUP.md) - Detailed installation
- [Workflows Reference](docs/WORKFLOWS.md) - All 8 workflows explained
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md) - Common issues and fixes

---

## 🔄 Setup Script (Optional)

For advanced users, here's a script to automate most settings:

```bash
#!/bin/bash
# setup-github.sh - Automated GitHub setup

set -e

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
PROJECT_URL="${2:-}"

echo "🔧 Setting up GitHub repository: $REPO"

# 1. Enable required features
echo "📝 Enabling repository features..."
gh api repos/$REPO -X PATCH \
  --field has_issues=true \
  --field has_wiki=true \
  --field has_projects=true \
  --field allow_squash_merge=true \
  --field delete_branch_on_merge=true

# 2. Set workflow permissions
echo "🔐 Configuring Actions permissions..."
gh api repos/$REPO/actions/permissions -X PUT \
  --field enabled=true \
  --field allowed_actions="all"

gh api repos/$REPO/actions/permissions/workflow -X PUT \
  --field default_workflow_permissions="write" \
  --field can_approve_pull_request_reviews=true

# 3. Run bootstrap workflow
echo "🚀 Running bootstrap workflow..."
gh workflow run bootstrap.yml -R $REPO

echo "✅ Setup complete!"
echo ""
echo "⚠️  Manual steps remaining:"
echo "1. Set ANTHROPIC_API_KEY secret"
echo "2. Set PROJECTS_TOKEN secret"
echo "3. Configure branch protection rules"
echo "4. Link project board (if not already linked)"
echo ""
echo "Run: ./setup/validate.sh to verify setup"
```

---

**Last Updated**: 2025-11-07
**Version**: 1.0.0
**Status**: Production Ready
