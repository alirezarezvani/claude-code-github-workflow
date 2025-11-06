# Customization Guide

**Comprehensive guide to customizing the GitHub Workflow Blueprint for your team's needs**

---

## Table of Contents

1. [Overview](#overview)
2. [Customization Philosophy](#customization-philosophy)
3. [Customizing Workflows](#customizing-workflows)
4. [Customizing Slash Commands](#customizing-slash-commands)
5. [Custom Labels and Status Workflow](#custom-labels-and-status-workflow)
6. [Custom Branching Strategies](#custom-branching-strategies)
7. [Custom Quality Gates](#custom-quality-gates)
8. [Integration with External Tools](#integration-with-external-tools)
9. [Advanced Patterns](#advanced-patterns)
10. [Best Practices](#best-practices)
11. [Testing Custom Configurations](#testing-custom-configurations)
12. [Troubleshooting](#troubleshooting)

---

## Overview

The GitHub Workflow Blueprint is designed to be flexible and customizable. This guide covers all customization points, from simple configuration changes to advanced workflow modifications.

### What Can Be Customized?

- ✅ **Workflows**: Task limits, branch patterns, quality checks, triggers
- ✅ **Commands**: Behavior, default values, custom prompts
- ✅ **Labels**: Custom label schemes, colors, automation rules
- ✅ **Branching**: Strategies, naming conventions, protection rules
- ✅ **Quality Gates**: Lint rules, test thresholds, security scans
- ✅ **Integrations**: External tools, notifications, webhooks

### Before You Start

**⚠️ Important Guidelines:**

1. **Test First**: Always test customizations in a dev branch
2. **Version Control**: Commit changes with clear descriptions
3. **Documentation**: Update your project's CLAUDE.md with custom settings
4. **Rollback Plan**: Keep original files backed up
5. **Team Alignment**: Communicate changes to your team

---

## Customization Philosophy

### Safe Customization Principles

**DO:**
- ✅ Start with small, incremental changes
- ✅ Test each change thoroughly
- ✅ Document why you made the change
- ✅ Keep changes version-controlled
- ✅ Maintain backward compatibility when possible

**DON'T:**
- ❌ Modify core workflow logic without understanding it
- ❌ Remove safety mechanisms (rate limits, fork checks)
- ❌ Make multiple changes simultaneously
- ❌ Skip testing in non-production environments
- ❌ Forget to update documentation

### Levels of Customization

**Level 1: Configuration** (Beginner-friendly)
- Change input values (task limits, versions)
- Modify labels and colors
- Adjust timing and thresholds

**Level 2: Workflow Enhancement** (Intermediate)
- Add custom validation steps
- Integrate external tools
- Customize notifications

**Level 3: Architectural Changes** (Advanced)
- Modify workflow logic
- Add custom workflows
- Change branching strategies

---

## Customizing Workflows

### 1. Task Limit (Max Issues per Plan)

**Default**: 10 tasks per plan

**Location**: `.github/workflows/claude-plan-to-issues.yml:78`

**Current Configuration:**
```yaml
# Enforce max 10 tasks limit
if [[ $TASK_COUNT -gt 10 ]]; then
  echo "❌ Too many tasks: $TASK_COUNT (max 10 allowed)"
  exit 1
fi
```

**To Customize:**

```yaml
# Option 1: Increase limit to 15 tasks
if [[ $TASK_COUNT -gt 15 ]]; then
  echo "❌ Too many tasks: $TASK_COUNT (max 15 allowed)"
  exit 1
fi

# Option 2: Decrease limit to 5 tasks (better focus)
if [[ $TASK_COUNT -gt 5 ]]; then
  echo "❌ Too many tasks: $TASK_COUNT (max 5 allowed)"
  exit 1
fi

# Option 3: Remove limit (not recommended)
# Comment out the entire check (lines 78-87)
# ⚠️  Warning: May cause API rate limit issues
```

**Considerations:**
- **Higher limits**: Risk API rate limit exhaustion, slower workflow execution
- **Lower limits**: Better sprint focus, faster execution, easier tracking
- **No limit**: Dangerous - can exhaust GitHub API quota

**Recommended**: Keep at 10 for most teams, reduce to 5 for solo developers

---

### 2. Rate Limit Thresholds

**Default**:
- `claude-plan-to-issues.yml`: 100 minimum API calls
- `pr-into-dev.yml`: 50 minimum API calls
- Other workflows: 50 minimum API calls

**Location**: `.github/workflows/claude-plan-to-issues.yml:162`

**Current Configuration:**
```yaml
- name: Check rate limit
  uses: ./.github/actions/rate-limit-check
  with:
    minimum-remaining: 100
    github-token: ${{ github.token }}
```

**To Customize:**

```yaml
# Conservative (recommended for high-activity repos)
minimum-remaining: 200

# Moderate (default)
minimum-remaining: 100

# Aggressive (only if you understand the risks)
minimum-remaining: 25
```

**Impact:**
- **Higher threshold**: More conservative, prevents API exhaustion, may fail unnecessarily
- **Lower threshold**: More aggressive, allows more operations, risks hitting limits

**Recommendation**: Increase to 150-200 for organizations with many repositories

---

### 3. Branch Naming Patterns

**Default**: `feature/*`, `fix/*`, `hotfix/*`

**Location**: `.github/workflows/pr-into-dev.yml:80`

**Current Configuration:**
```yaml
if [[ ! "$BRANCH_NAME" =~ ^(feature|fix|hotfix)/ ]]; then
  echo "❌ Invalid branch name: $BRANCH_NAME"
  exit 1
fi
```

**To Customize:**

```yaml
# Add custom branch types
if [[ ! "$BRANCH_NAME" =~ ^(feature|fix|hotfix|chore|docs|refactor)/ ]]; then
  echo "❌ Invalid branch name: $BRANCH_NAME"
  exit 1
fi

# Different naming convention (e.g., Jira-style)
if [[ ! "$BRANCH_NAME" =~ ^(PROJ-[0-9]+|feature|fix)/ ]]; then
  echo "❌ Branch must start with PROJ-XXX, feature/, or fix/"
  exit 1
fi

# Relaxed (any branch name allowed)
# Comment out the check entirely
# ⚠️  Warning: Loses consistency and automation benefits
```

**Common Patterns:**

```bash
# GitHub Flow (minimal)
^(feature|fix)/

# GitFlow (standard)
^(feature|fix|hotfix|release|support)/

# Jira Integration
^(PROJ-[0-9]+|feature|fix)/

# Ticket System
^(ticket-[0-9]+|feature|fix)/
```

---

### 4. Conventional Commit Types

**Default**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Location**: `.github/workflows/pr-into-dev.yml:107-117`

**Current Configuration:**
```yaml
types: |
  feat
  fix
  docs
  style
  refactor
  perf
  test
  build
  ci
  chore
  revert
```

**To Customize:**

```yaml
# Minimal set (simpler for small teams)
types: |
  feat
  fix
  docs

# Extended set (more granular)
types: |
  feat
  fix
  docs
  style
  refactor
  perf
  test
  build
  ci
  chore
  revert
  hotfix
  security
  deps

# Custom business types
types: |
  feature
  bugfix
  improvement
  documentation
```

**Make Scope Required:**
```yaml
requireScope: true  # Change from false to true
```

---

### 5. Quality Check Configuration

**Default**: Lint, typecheck, unit tests

**Location**: `.github/workflows/pr-into-dev.yml:295-300`

**Current Configuration:**
```yaml
uses: ./.github/workflows/reusable-pr-checks.yml
with:
  mobile_check: false
  integration_tests: false
  node_version: '20'
  pnpm_version: '9'
```

**To Customize:**

```yaml
# Enable mobile checks for mobile/fullstack projects
uses: ./.github/workflows/reusable-pr-checks.yml
with:
  mobile_check: true              # ← Enable mobile validation
  integration_tests: true         # ← Enable integration tests
  node_version: '20'
  pnpm_version: '9'

# Use different Node.js/pnpm versions
uses: ./.github/workflows/reusable-pr-checks.yml
with:
  mobile_check: false
  integration_tests: false
  node_version: '22'              # ← Latest Node.js
  pnpm_version: '10'              # ← Latest pnpm
```

**Per-Project Configuration:**

Create `.github/workflow-config.json`:
```json
{
  "quality_checks": {
    "mobile_check": true,
    "integration_tests": true,
    "node_version": "20",
    "pnpm_version": "9",
    "custom_checks": [
      "npm run lint:security",
      "npm run check:licenses"
    ]
  }
}
```

---

### 6. Path-Based Filtering

**Default**: Run checks only when relevant files change

**Location**: `.github/workflows/reusable-pr-checks.yml` (uses `dorny/paths-filter@v3`)

**Current Configuration:**
```yaml
- uses: dorny/paths-filter@v3
  id: filter
  with:
    filters: |
      frontend:
        - 'src/**'
        - 'public/**'
        - 'package.json'
      backend:
        - 'server/**'
        - 'api/**'
      mobile:
        - 'mobile/**'
        - 'android/**'
        - 'ios/**'
```

**To Customize:**

```yaml
# Monorepo with multiple projects
- uses: dorny/paths-filter@v3
  id: filter
  with:
    filters: |
      web-app:
        - 'apps/web/**'
        - 'packages/shared/**'
      mobile-app:
        - 'apps/mobile/**'
        - 'packages/shared/**'
      backend:
        - 'apps/api/**'
        - 'packages/shared/**'
      infra:
        - 'infrastructure/**'
        - '.github/**'

# Documentation-only changes (skip CI)
- uses: dorny/paths-filter@v3
  id: filter
  with:
    filters: |
      docs-only:
        - '**/*.md'
        - 'docs/**'

# Then skip checks if only docs changed:
if: steps.filter.outputs.docs-only != 'true'
```

**Skip CI for Specific Files:**

Add to any workflow:
```yaml
on:
  pull_request:
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - 'LICENSE'
      - '.gitignore'
```

---

### 7. Workflow Triggers

**Default**: Specific events and branches

**To Customize:**

```yaml
# Add schedule trigger (daily checks)
on:
  pull_request:
    branches: [dev]
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC

# Add manual trigger
on:
  pull_request:
    branches: [dev]
  workflow_dispatch:
    inputs:
      skip_tests:
        type: boolean
        default: false

# Add push trigger (immediate feedback)
on:
  pull_request:
    branches: [dev]
  push:
    branches: [dev]
```

---

### 8. Concurrency Control

**Default**: Cancel in-progress runs for the same PR

**Current Configuration:**
```yaml
concurrency:
  group: pr-dev-${{ github.event.pull_request.number }}
  cancel-in-progress: true
```

**To Customize:**

```yaml
# Don't cancel (run all checks)
concurrency:
  group: pr-dev-${{ github.event.pull_request.number }}
  cancel-in-progress: false

# Group by branch (cancel old runs on same branch)
concurrency:
  group: branch-${{ github.head_ref }}
  cancel-in-progress: true

# No concurrency control (all runs execute)
# Remove the concurrency block entirely
```

---

## Customizing Slash Commands

### 1. /blueprint-init Defaults

**Location**: `.claude/commands/github/blueprint-init.md`

**Default Branching Strategy**:
```markdown
2. Standard: feature → dev → main (RECOMMENDED)
```

**To Customize:**

```markdown
# Change recommended strategy
2. Simple: feature → main (RECOMMENDED for solo developers)

# Or
3. Complex: feature → dev → staging → main (RECOMMENDED for enterprises)
```

**Add Pre-Configured Options:**

```markdown
### Step 2.5: Use Pre-Configured Template? (NEW)

**Ask user**:
```
Would you like to use a pre-configured template?

1. None (manual configuration)
2. Startup (simple branching, fast iteration)
3. Scale-up (standard branching, balanced)
4. Enterprise (complex branching, maximum safety)

Enter 1, 2, 3, or 4:
```
```

---

### 2. /commit-smart Quality Checks

**Location**: `.claude/commands/github/commit-smart.md`

**Default Checks**: Lint, typecheck, secret scan

**To Customize:**

Add to the workflow section:
```markdown
### Step 3.5: Run Custom Pre-Commit Checks (NEW)

**Run additional checks**:
```bash
# Security vulnerability scan
npm audit --audit-level=moderate

# License compliance
npm run check:licenses

# Bundle size check
npm run analyze:bundle

# Accessibility lint
npm run lint:a11y
```

**If any check fails**:
- Show clear error message
- Ask if user wants to:
  1. Fix issues and re-run
  2. Commit anyway (not recommended)
  3. Cancel commit
```

---

### 3. /plan-to-issues Validation

**Location**: `.claude/commands/github/plan-to-issues.md`

**Default**: Validates JSON schema, enforces max 10 tasks

**To Customize:**

```markdown
### Step 1.5: Custom Validation Rules (NEW)

**Additional validations**:
1. **Estimate Required**:
   - Each task must have `estimatedHours` field
   - Reject tasks without estimates

2. **Priority Distribution**:
   - At least 1 task must be high/critical priority
   - No more than 70% of tasks can be low priority

3. **Platform Balance**:
   - For fullstack projects, require mix of web + backend tasks
   - Warn if all tasks are single-platform

4. **Dependency Validation**:
   - Check that dependency issue numbers exist
   - Warn about circular dependencies
```

---

### 4. /create-pr Template Customization

**Location**: `.claude/commands/github/create-pr.md`

**Default Template**: Standard PR template

**To Customize:**

```markdown
### Step 6: Generate Custom PR Body (ENHANCED)

**Build PR body with custom sections**:

```markdown
## 📝 Summary
[Auto-generated from commit messages]

## 🎯 Motivation
[Why was this change needed?]

## 🔧 Implementation Details
[Key technical decisions]

## 📸 Visual Changes
[Screenshots if UI changed]

## ✅ Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Accessibility tested
- [ ] Performance tested

## 🔒 Security
- [ ] No secrets committed
- [ ] No new vulnerabilities
- [ ] Dependencies updated

## 📊 Metrics
- **Files Changed**: X files
- **Lines Added**: +XXX
- **Lines Removed**: -XXX
- **Test Coverage**: XX%

## 🔗 Links
- Issue: #XXX
- Figma: [Design Link]
- Docs: [Documentation]

Closes #XXX
```
```

---

## Custom Labels and Status Workflow

### 1. Default Label Scheme

**Status Labels**:
- `status:ready` - Ready to start
- `status:in-progress` - Currently being worked on
- `status:in-review` - In code review
- `status:to-deploy` - Merged to dev, awaiting production

**Type Labels**:
- `type:feature`, `type:fix`, `type:hotfix`, `type:docs`, `type:refactor`, `type:test`

**Platform Labels**:
- `platform:web`, `platform:mobile`, `platform:fullstack`

**Priority Labels**:
- `priority:critical`, `priority:high`, `priority:medium`, `priority:low`

---

### 2. Custom Label Colors

**Location**: `.github/workflows/bootstrap.yml` (label creation section)

**Current Colors**:
```yaml
# Status labels (blue shades)
status:ready         → 0e8a16 (green)
status:in-progress   → fbca04 (yellow)
status:in-review     → d4c5f9 (purple)
status:to-deploy     → 1d76db (blue)

# Type labels (color-coded)
type:feature  → 0e8a16 (green)
type:fix      → d73a4a (red)
type:hotfix   → b60205 (dark red)
```

**To Customize:**

```bash
# Create labels with custom colors
gh label create "status:ready" \
  --color "00ff00" \
  --description "Ready to start work" \
  --force

# Brand colors
gh label create "priority:critical" \
  --color "FF0000" \  # Your brand red
  --description "Critical priority"

# Semantic colors
gh label create "type:security" \
  --color "FFA500" \  # Orange for security
  --description "Security-related issue"
```

---

### 3. Additional Custom Labels

**Common Extensions:**

```bash
# Size labels
gh label create "size:xs" --color "c2e0c6" --description "Extra small (< 10 lines)"
gh label create "size:s" --color "bfe5bf" --description "Small (< 50 lines)"
gh label create "size:m" --color "7bc96f" --description "Medium (< 200 lines)"
gh label create "size:l" --color "6fba72" --description "Large (< 500 lines)"
gh label create "size:xl" --color "3d8f4d" --description "Extra large (> 500 lines)"

# Team labels
gh label create "team:frontend" --color "5319e7" --description "Frontend team"
gh label create "team:backend" --color "0052cc" --description "Backend team"
gh label create "team:mobile" --color "00875a" --description "Mobile team"

# Business labels
gh label create "business:revenue" --color "ffd700" --description "Revenue impact"
gh label create "business:ux" --color "ff69b4" --description "User experience"
gh label create "business:tech-debt" --color "8b4513" --description "Technical debt"
```

---

### 4. Custom Status Workflow

**Default Flow**: `ready → in-progress → in-review → to-deploy → done`

**To Customize:**

**Option 1: Add Testing Phase**
```
ready → in-progress → in-review → in-testing → to-deploy → done
```

**Update Project Board**:
1. Go to your GitHub Project board
2. Settings → Fields → Status
3. Add option: "In Testing" (between In Review and To Deploy)

**Update Workflow** (`.github/workflows/pr-status-sync.yml`):
```yaml
# Add testing status transition
- name: Set status to In Testing
  if: github.event.label.name == 'status:in-testing'
  run: |
    # GraphQL mutation to set status
```

**Option 2: Add Approval Phase**
```
ready → in-progress → in-review → approved → to-deploy → done
```

---

## Custom Branching Strategies

### 1. Switching Between Strategies

**Simple → Standard**:
```bash
# Create dev branch
git checkout -b dev
git push -u origin dev

# Update PR workflows to target dev
# Update /blueprint-init to recommend standard
```

**Standard → Complex**:
```bash
# Create staging branch
git checkout -b staging
git push -u origin staging

# Add staging → main workflow
# Update PR workflows for staging
```

---

### 2. Custom Branch Naming

**Default**: `feature/issue-123-description`

**To Customize:**

**Option 1: Jira-Style**
```bash
# Pattern: PROJ-123-description
^(PROJ-[0-9]+)/
```

**Update** `.github/workflows/create-branch-on-issue.yml`:
```yaml
# Extract Jira ticket from issue title
JIRA_TICKET=$(echo "$ISSUE_TITLE" | grep -oE 'PROJ-[0-9]+' || echo "")
if [[ -n "$JIRA_TICKET" ]]; then
  BRANCH_NAME="$JIRA_TICKET-$SLUG"
else
  BRANCH_NAME="feature/issue-$ISSUE_NUMBER-$SLUG"
fi
```

**Option 2: Username Prefix**
```bash
# Pattern: username/feature/description
git checkout -b "$USERNAME/feature/$DESCRIPTION"
```

**Option 3: Date-Based**
```bash
# Pattern: 2025-11/feature/description
MONTH=$(date +%Y-%m)
git checkout -b "$MONTH/feature/$DESCRIPTION"
```

---

### 3. Branch Protection Rules

**To Customize:**

```bash
# Require 2 approvals instead of 1
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_pull_request_reviews='{"required_approving_review_count":2}'

# Require specific reviewers (CODEOWNERS)
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_pull_request_reviews='{"require_code_owner_reviews":true}'

# Require all status checks to pass
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["lint","test","build"]}'

# Allow force push for admins only
gh api repos/:owner/:repo/branches/dev/protection \
  --method PUT \
  --field enforce_admins=false \
  --field allow_force_pushes=true
```

---

## Custom Quality Gates

### 1. Lint Rules

**ESLint Configuration**:

**Location**: `.eslintrc.json` or `.eslintrc.js`

**Strict Configuration**:
```json
{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended"
  ],
  "rules": {
    "no-console": "error",           // Block console.log
    "no-debugger": "error",           // Block debugger
    "@typescript-eslint/no-explicit-any": "error",  // Strict typing
    "react/prop-types": "error"       // Require prop types
  }
}
```

**Relaxed Configuration**:
```json
{
  "rules": {
    "no-console": "warn",             // Allow with warning
    "no-debugger": "warn",
    "@typescript-eslint/no-explicit-any": "off"  // Allow any type
  }
}
```

---

### 2. Test Coverage Thresholds

**Jest Configuration**:

**Location**: `jest.config.js` or `package.json`

```javascript
module.exports = {
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.tsx'
  ],
  coverageThresholds: {
    global: {
      statements: 80,    // 80% statement coverage
      branches: 75,      // 75% branch coverage
      functions: 80,     // 80% function coverage
      lines: 80          // 80% line coverage
    },
    // Per-directory thresholds
    './src/components/': {
      statements: 90     // Higher for critical code
    },
    './src/utils/': {
      statements: 95     // Even higher for utilities
    }
  }
};
```

---

### 3. Security Scanning

**Add Security Audit to Quality Checks**:

**Location**: `.github/workflows/reusable-pr-checks.yml`

**Add Job**:
```yaml
security-audit:
  name: Security Audit
  runs-on: ubuntu-latest

  steps:
    - uses: actions/checkout@v4

    - name: Run npm audit
      run: |
        npm audit --audit-level=moderate
      continue-on-error: true  # Don't block on vulnerabilities

    - name: Check for secrets
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: ${{ github.event.pull_request.base.sha }}
        head: ${{ github.event.pull_request.head.sha }}

    - name: SAST scan with Semgrep
      uses: returntocorp/semgrep-action@v1
      with:
        config: auto
```

---

### 4. Performance Thresholds

**Bundle Size Check**:

```yaml
bundle-size-check:
  name: Check Bundle Size
  runs-on: ubuntu-latest

  steps:
    - uses: actions/checkout@v4
    - uses: ./.github/actions/setup-node-pnpm

    - name: Build production bundle
      run: npm run build

    - name: Check bundle size
      run: |
        MAX_SIZE=500000  # 500KB max
        ACTUAL_SIZE=$(stat -f%z dist/bundle.js)

        if [ $ACTUAL_SIZE -gt $MAX_SIZE ]; then
          echo "❌ Bundle too large: $ACTUAL_SIZE bytes (max: $MAX_SIZE)"
          exit 1
        fi

        echo "✅ Bundle size OK: $ACTUAL_SIZE bytes"
```

---

## Integration with External Tools

### 1. Slack Notifications

**On PR Created**:

**Location**: `.github/workflows/pr-into-dev.yml`

**Add Step**:
```yaml
- name: Notify Slack
  if: github.event.action == 'opened'
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {
        "text": "New PR opened: ${{ github.event.pull_request.title }}",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*New Pull Request*\n<${{ github.event.pull_request.html_url }}|${{ github.event.pull_request.title }}>"
            }
          },
          {
            "type": "context",
            "elements": [
              {
                "type": "mrkdwn",
                "text": "Author: ${{ github.event.pull_request.user.login }}"
              }
            ]
          }
        ]
      }
```

**Setup**:
1. Create Slack incoming webhook: https://api.slack.com/messaging/webhooks
2. Add secret: `gh secret set SLACK_WEBHOOK_URL`

---

### 2. Discord Notifications

```yaml
- name: Notify Discord
  if: github.event.action == 'opened'
  uses: Ilshidur/action-discord@master
  env:
    DISCORD_WEBHOOK: ${{ secrets.DISCORD_WEBHOOK }}
  with:
    args: |
      **New PR**: ${{ github.event.pull_request.title }}
      By: ${{ github.event.pull_request.user.login }}
      Link: ${{ github.event.pull_request.html_url }}
```

---

### 3. Jira Integration

**Auto-Link Jira Issues**:

```yaml
- name: Link to Jira
  uses: atlassian/gajira-transition@master
  with:
    issue: ${{ env.JIRA_ISSUE }}
    transition: "In Progress"
  env:
    JIRA_BASE_URL: ${{ secrets.JIRA_BASE_URL }}
    JIRA_USER_EMAIL: ${{ secrets.JIRA_USER_EMAIL }}
    JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
    JIRA_ISSUE: ${{ github.event.pull_request.title | extract-jira-key }}
```

**Extract Jira Key from PR Title**:
```bash
JIRA_KEY=$(echo "$PR_TITLE" | grep -oE '[A-Z]+-[0-9]+')
```

---

### 4. Vercel Deployment

**Auto-Deploy Previews**:

```yaml
deploy-preview:
  name: Deploy Preview to Vercel
  runs-on: ubuntu-latest
  if: github.event.action == 'opened' || github.event.action == 'synchronize'

  steps:
    - uses: actions/checkout@v4
    - uses: amondnet/vercel-action@v25
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
        vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
        github-comment: true
```

---

### 5. Netlify Deployment

```yaml
- name: Deploy to Netlify
  uses: nwtgck/actions-netlify@v2
  with:
    publish-dir: './dist'
    production-branch: main
    github-token: ${{ secrets.GITHUB_TOKEN }}
    deploy-message: "Deploy from PR #${{ github.event.pull_request.number }}"
  env:
    NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
    NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

---

## Advanced Patterns

### 1. Multi-Environment Deployment

**Setup**:
```
feature → dev → staging → production
          ↓       ↓         ↓
       dev.app  staging.app  app.com
```

**Workflow**:

1. **Create Staging Workflow** (`.github/workflows/dev-to-staging.yml`)
2. **Create Production Workflow** (`.github/workflows/staging-to-production.yml`)
3. **Add Environment Secrets**:
   ```bash
   # Staging
   gh secret set STAGING_API_KEY --env staging

   # Production
   gh secret set PRODUCTION_API_KEY --env production
   ```

---

### 2. Feature Flags

**Integrate LaunchDarkly/ConfigCat**:

```yaml
- name: Evaluate Feature Flags
  uses: launchdarkly/find-code-references@v2
  with:
    access-token: ${{ secrets.LD_ACCESS_TOKEN }}
    project-key: 'default'
```

**Use in Code**:
```typescript
if (await featureFlags.isEnabled('new-feature')) {
  // New feature code
}
```

---

### 3. Automated Dependency Updates

**Beyond Dependabot - Auto-Merge Safe Updates**:

```yaml
name: Auto-Merge Dependabot

on:
  pull_request:
    branches: [main, dev]

jobs:
  auto-merge:
    if: github.actor == 'dependabot[bot]'
    runs-on: ubuntu-latest

    steps:
      - name: Check if safe to merge
        id: check
        run: |
          # Only auto-merge patch and minor updates
          if [[ "${{ github.event.pull_request.title }}" =~ "Bump.*from.*to.*[0-9]+\.[0-9]+\.[0-9]+" ]]; then
            echo "safe=true" >> $GITHUB_OUTPUT
          fi

      - name: Auto-merge
        if: steps.check.outputs.safe == 'true'
        run: |
          gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

### 4. Monorepo Support

**Path-Based Workflows**:

```yaml
# Only run frontend checks if frontend changed
frontend-checks:
  name: Frontend Quality Checks
  runs-on: ubuntu-latest

  steps:
    - uses: dorny/paths-filter@v3
      id: filter
      with:
        filters: |
          frontend:
            - 'packages/frontend/**'

    - name: Run frontend checks
      if: steps.filter.outputs.frontend == 'true'
      run: |
        cd packages/frontend
        npm run lint
        npm run test
```

---

## Best Practices

### 1. Documentation

**Always Document Custom Changes**:

Create `docs/CUSTOM_CONFIG.md`:
```markdown
# Custom Configuration

## Changes Made

### 1. Increased Task Limit to 15
- **Date**: 2025-11-06
- **Reason**: Large sprint planning needs
- **Impact**: May hit API rate limits more often
- **Rollback**: Change line 78 back to 10

### 2. Added Slack Notifications
- **Date**: 2025-11-06
- **Webhook**: #engineering-prs channel
- **Trigger**: All PR events
```

---

### 2. Version Control

**Use Feature Branches for Workflow Changes**:

```bash
# Create feature branch
git checkout -b config/increase-task-limit

# Make changes
# Test thoroughly

# Create PR
/create-pr
```

**Tag Major Changes**:
```bash
git tag -a v1.1.0-custom -m "Custom configuration: increased task limit to 15"
git push origin v1.1.0-custom
```

---

### 3. Testing

**Test Workflow Changes**:

```bash
# Test locally with act (GitHub Actions local runner)
act pull_request -j validate-pr-title

# Test in non-production branch first
git checkout dev
gh workflow run pr-into-dev.yml
```

**Validate YAML Syntax**:
```bash
# Install yamllint
pip install yamllint

# Validate all workflows
yamllint .github/workflows/*.yml
```

---

### 4. Rollback Strategy

**Keep Backup**:
```bash
# Before modifying workflow
cp .github/workflows/pr-into-dev.yml .github/workflows/pr-into-dev.yml.backup

# If issues occur
mv .github/workflows/pr-into-dev.yml.backup .github/workflows/pr-into-dev.yml
git commit -m "rollback: revert PR workflow changes"
```

---

## Testing Custom Configurations

### 1. Workflow Testing Checklist

**Before Committing Workflow Changes**:

- [ ] YAML syntax valid (`yamllint`)
- [ ] Test with sample PR in dev branch
- [ ] Verify rate limits not exceeded
- [ ] Check workflow execution time (<2 minutes)
- [ ] Validate all conditional logic
- [ ] Test failure scenarios
- [ ] Check status checks appear in PR
- [ ] Verify notifications work (if added)

---

### 2. Integration Testing

**Test Complete Flow**:

```bash
# 1. Create test issue
gh issue create --title "test: workflow validation" --body "Test issue"

# 2. Verify branch auto-creation
git fetch
git branch -r | grep feature/issue-

# 3. Create test changes
git checkout feature/issue-XXX
echo "test" > test.txt
git add test.txt
git commit -m "test: validation"
git push

# 4. Create PR
gh pr create --title "test: workflow validation" --body "Closes #XXX"

# 5. Monitor workflow
gh run list --workflow=pr-into-dev.yml --limit 1

# 6. Check PR status
gh pr view

# 7. Clean up
gh pr close
git checkout main
git branch -D feature/issue-XXX
```

---

## Troubleshooting

### Common Issues

#### 1. Workflow Not Triggering

**Problem**: Workflow doesn't run after PR creation

**Solutions**:
```yaml
# Check trigger configuration
on:
  pull_request:
    types:
      - opened              # ← Ensure correct event types
      - synchronize
    branches:
      - dev                 # ← Match your branch name exactly
```

**Debug**:
```bash
# Check workflow runs
gh run list --workflow=pr-into-dev.yml

# View workflow file
gh workflow view pr-into-dev.yml
```

---

#### 2. Rate Limit Errors

**Problem**: "Rate limit exceeded" errors

**Solutions**:
1. Increase `minimum-remaining` threshold
2. Add delays between API calls
3. Reduce number of concurrent workflows
4. Use GitHub App token (higher limits)

```yaml
# Use GitHub App token
- uses: actions/create-github-app-token@v1
  id: app-token
  with:
    app-id: ${{ secrets.APP_ID }}
    private-key: ${{ secrets.APP_PRIVATE_KEY }}
```

---

#### 3. Custom Label Not Found

**Problem**: "Label 'custom-label' not found"

**Solutions**:
```bash
# Create missing label
gh label create "custom-label" --color "0e8a16" --description "Custom label"

# Or update bootstrap.yml to create it
```

---

#### 4. Branch Protection Blocking Automation

**Problem**: Workflow can't update PR/issue due to branch protection

**Solutions**:
1. Use GitHub App token (bypasses some restrictions)
2. Exclude bot from restrictions
3. Use `GITHUB_TOKEN` with elevated permissions

```yaml
permissions:
  contents: write       # ← Add required permissions
  pull-requests: write
  issues: write
```

---

### Getting Help

**Resources**:
- 📖 [GitHub Actions Documentation](https://docs.github.com/en/actions)
- 📖 [Workflow Syntax Reference](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- 💬 [Community Discussions](https://github.com/discussions)
- 🐛 [Report Issues](https://github.com/issues)

**Debug Mode**:
```yaml
# Enable debug logging
- name: Debug step
  run: |
    set -x  # Enable bash debug mode
    echo "Variable: $MY_VAR"
  env:
    ACTIONS_STEP_DEBUG: true
```

---

## Summary

### Customization Decision Matrix

| Need | Complexity | Risk | Recommendation |
|------|-----------|------|----------------|
| Change task limit | Low | Low | Safe, document reason |
| Add custom labels | Low | Low | Safe, update bootstrap |
| Modify branch names | Medium | Medium | Test thoroughly |
| Change quality checks | Medium | Low | Start conservative |
| Add external tools | Medium | Medium | Use secrets, test |
| Modify workflow logic | High | High | Expert only, backup |

### Safe Customization Workflow

1. **Plan**: Document what and why
2. **Backup**: Save original files
3. **Branch**: Use feature branch
4. **Change**: Make incremental changes
5. **Test**: Validate in dev environment
6. **Review**: Get team approval
7. **Deploy**: Merge to main
8. **Monitor**: Watch first few runs
9. **Document**: Update CUSTOM_CONFIG.md

---

**Remember**: Start small, test thoroughly, document everything, and you'll have a perfectly customized workflow system that scales with your team!

---

**Last Updated**: 2025-11-06
**Version**: 1.0.0
