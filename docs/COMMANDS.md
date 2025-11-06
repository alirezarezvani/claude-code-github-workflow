# Commands Reference

**Complete reference for all Claude Code slash commands in the Blueprint**

This guide documents all 8 slash commands that provide interactive automation for common development tasks.

---

## Table of Contents

- [Overview](#overview)
- [Command System](#command-system)
- [Quick Reference Table](#quick-reference-table)
- [Detailed Command Documentation](#detailed-command-documentation)
  - [1. /blueprint-init](#1-blueprint-init)
  - [2. /plan-to-issues](#2-plan-to-issues)
  - [3. /commit-smart](#3-commit-smart)
  - [4. /create-pr](#4-create-pr)
  - [5. /review-pr](#5-review-pr)
  - [6. /release](#6-release)
  - [7. /sync-status](#7-sync-status)
  - [8. /kill-switch](#8-kill-switch)
- [Command Integration](#command-integration)
- [Best Practices](#best-practices)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)

---

## Overview

The GitHub Workflow Blueprint includes 8 specialized slash commands that automate common development workflows through interactive Claude Code sessions.

### Core Commands

1. **`/blueprint-init`** - Interactive setup wizard
2. **`/plan-to-issues`** - Convert Claude plans to GitHub issues
3. **`/commit-smart`** - Smart commit with quality checks
4. **`/create-pr`** - Create pull requests with proper linking
5. **`/review-pr`** - Comprehensive Claude-powered code review
6. **`/release`** - Production release management
7. **`/sync-status`** - Issue and project board synchronization
8. **`/kill-switch`** - Emergency workflow disable mechanism

### Key Features

- ✅ **Interactive Guidance** - Step-by-step prompts with validation
- ✅ **Quality Gates** - Built-in checks before operations
- ✅ **Error Recovery** - Graceful handling of failures
- ✅ **Workflow Integration** - Seamless connection with GitHub Actions
- ✅ **Beginner-Friendly** - Clear explanations and helpful feedback
- ✅ **Time-Saving** - Automate repetitive tasks

---

## Command System

### How Commands Work

Slash commands are **interactive prompts** that guide Claude Code through complex workflows:

```
User types: /command-name [arguments]
    ↓
Claude Code loads command prompt
    ↓
Guides user through interactive workflow
    ↓
Validates inputs and prerequisites
    ↓
Executes operations safely
    ↓
Provides feedback and next steps
```

### Command Location

All commands are located in: `.claude/commands/github/`

```
.claude/commands/github/
├── blueprint-init.md
├── plan-to-issues.md
├── commit-smart.md
├── create-pr.md
├── review-pr.md
├── release.md
├── sync-status.md
└── kill-switch.md
```

### Creating Custom Commands

You can create your own commands by adding `.md` files to `.claude/commands/`:

```markdown
# /my-command - Custom Command

**Description**: What this command does

**Usage**: `/my-command [arguments]`

---

## Workflow

[Step-by-step instructions for Claude Code...]
```

---

## Quick Reference Table

| Command | Purpose | Duration | Prerequisites |
|---------|---------|----------|---------------|
| **`/blueprint-init`** | Complete repository setup | ~5 min | gh CLI, git, empty repo |
| **`/plan-to-issues`** | Convert plan JSON to issues | ~30 sec | Bootstrap complete |
| **`/commit-smart`** | Smart commit with quality checks | ~1 min | Staged changes |
| **`/create-pr`** | Create PR with issue linking | ~1 min | Committed changes |
| **`/review-pr`** | Claude-powered code review | ~2-5 min | Open PR |
| **`/release`** | Production release workflow | ~5 min | Features merged to dev |
| **`/sync-status`** | Manual status synchronization | ~30 sec | Bootstrap complete |
| **`/kill-switch`** | Emergency workflow disable | ~10 sec | None (emergency use) |

---

## Detailed Command Documentation

### 1. /blueprint-init

**Interactive setup wizard that configures your repository from scratch**

#### Purpose

Guides you through complete repository setup with the GitHub Workflow Blueprint, including:
- Branch creation (dev, staging)
- Secret configuration
- Bootstrap workflow execution
- Branch protection setup
- Project board validation

#### When to Use

- ✅ **First-time setup**: New repository
- ✅ **Clean install**: Starting fresh
- ✅ **Repository migration**: Moving to this blueprint

#### Usage

```bash
/blueprint-init
```

**No arguments required** - the command is fully interactive.

#### What It Does

1. **Welcome & Prerequisites Check**
   - Verifies `gh` CLI installed
   - Verifies `git` installed
   - Checks authentication status
   - Confirms in git repository

2. **Detect Project Type**
   - Asks: Web, Mobile, or Fullstack?
   - Configures appropriate workflows
   - Sets up path filters

3. **Choose Branching Strategy**
   - Simple: `feature → main`
   - Standard: `feature → dev → main` (recommended)
   - Complex: `feature → dev → staging → main`

4. **Get Project Board URL**
   - Prompts for GitHub Projects v2 URL
   - Validates URL format
   - Tests connectivity

5. **Get Anthropic API Key**
   - Prompts for Claude API key
   - Tests validity (optional)
   - Stores as secret

6. **Create Branches**
   - Creates `dev` branch (if standard/complex)
   - Creates `staging` branch (if complex)
   - Pushes to remote

7. **Set Repository Secrets**
   - Sets `PROJECT_URL` secret
   - Sets `ANTHROPIC_API_KEY` secret
   - Validates stored secrets

8. **Run Bootstrap Workflow**
   - Triggers `bootstrap.yml`
   - Creates required labels
   - Validates project board
   - Generates summary

9. **Apply Branch Protections**
   - Protects main branch
   - Protects dev branch (if exists)
   - Enforces squash merge
   - Requires PR reviews

10. **Validation & Summary**
    - Runs validation checks
    - Shows configuration summary
    - Provides next steps

#### Example Session

```
$ /blueprint-init

🚀 GitHub Workflow Blueprint - Setup Wizard
================================================

✅ gh CLI version 2.40.0
✅ git version 2.42.0
✅ Authenticated as alirezarezvani
✅ In git repository: /Users/ali/projects/my-app

📦 What type of project is this?
1. Web
2. Mobile
3. Fullstack
Enter 1, 2, or 3: 1

✅ Project type: Web

🌿 Which branching strategy?
1. Simple: feature → main
2. Standard: feature → dev → main (RECOMMENDED)
3. Complex: feature → dev → staging → main
Enter 1, 2, or 3: 2

✅ Branching strategy: Standard

📊 Enter your GitHub Project board URL:
Example: https://github.com/users/USERNAME/projects/1
> https://github.com/users/alirezarezvani/projects/1

✅ Project board validated

🔐 Enter your Anthropic API Key:
> sk-ant-api03-...

✅ API key validated

🌿 Creating branches...
✅ Created branch: dev
✅ Pushed to origin/dev

🔐 Setting repository secrets...
✅ Set PROJECT_URL
✅ Set ANTHROPIC_API_KEY

🚀 Running bootstrap workflow...
✅ Bootstrap complete (created 23 labels)

🛡️  Applying branch protections...
✅ Protected branch: main
✅ Protected branch: dev

✅ Setup Complete!

Next steps:
1. Create your first issue or plan
2. Run /plan-to-issues to create tasks
3. Start working on feature branches
```

#### Configuration

**Prerequisites**:
```bash
# Install gh CLI
brew install gh

# Or on Linux
curl -sS https://webi.sh/gh | sh

# Authenticate
gh auth login
```

**Project Board Setup**:
1. Create GitHub Project (v2, not classic)
2. Add a "Status" field (Single select)
3. Add status options: To triage, Backlog, Ready, In Progress, In Review, To Deploy, Done
4. Copy project URL

**Get Claude API Key**:
1. Go to https://console.anthropic.com/
2. Create account or login
3. Navigate to API Keys
4. Create new key
5. Copy key (starts with `sk-ant-`)

#### Troubleshooting

**Problem**: `❌ gh CLI not found`

**Solution**: Install GitHub CLI:
```bash
# macOS
brew install gh

# Windows
winget install GitHub.cli

# Linux
curl -sS https://webi.sh/gh | sh

# Verify installation
gh --version
```

---

**Problem**: `❌ Not authenticated with GitHub`

**Solution**: Authenticate with GitHub:
```bash
gh auth login

# Follow prompts:
# - Choose GitHub.com
# - Choose HTTPS
# - Authenticate via web browser
# - Complete authentication

# Verify
gh auth status
```

---

**Problem**: `❌ Invalid project board URL`

**Solution**: Ensure URL format is correct:
```
✅ Correct: https://github.com/users/USERNAME/projects/NUMBER
✅ Correct: https://github.com/orgs/ORGNAME/projects/NUMBER
❌ Wrong: https://github.com/USERNAME/projects/NUMBER (missing /users/)
❌ Wrong: Classic projects URL (must use Projects v2)
```

To find your project URL:
1. Go to your GitHub project board
2. Copy URL from browser address bar
3. Verify it matches the correct format

---

**Problem**: `❌ API key invalid`

**Solution**: Get a new API key:
1. Go to https://console.anthropic.com/
2. Delete old key (if exists)
3. Create new key
4. Copy entire key (including `sk-ant-` prefix)
5. Paste carefully (no extra spaces)

---

**Problem**: Bootstrap workflow fails

**Solution**: Check workflow logs:
```bash
# List recent workflow runs
gh run list --limit 5

# View failed run
gh run view [RUN_ID]

# Common issues:
# 1. PROJECT_URL secret not set correctly
# 2. ANTHROPIC_API_KEY invalid
# 3. Project board doesn't have Status field
```

Fix and re-run:
```bash
gh workflow run bootstrap.yml
```

---

#### Best Practices

✅ **DO**:
- Run in a clean, empty repository
- Have project board ready beforehand
- Test API key before setting as secret
- Read all prompts carefully
- Keep the wizard output for reference

❌ **DON'T**:
- Run on existing projects without backup
- Skip prerequisite checks
- Use classic GitHub Projects (must be v2)
- Share API keys or commit them
- Interrupt the wizard mid-setup

---

### 2. /plan-to-issues

**Convert Claude Code planning output (JSON) into GitHub issues**

#### Purpose

Transforms a structured plan from Claude Code into organized GitHub issues with:
- Proper labels (type, platform, priority)
- Milestone assignment
- Dependency linking
- Project board integration
- Acceptance criteria

#### When to Use

- ✅ **After planning**: You have a feature plan from Claude
- ✅ **Sprint planning**: Converting sprint goals to tasks
- ✅ **Bulk issue creation**: Need to create multiple related issues

#### Usage

```bash
/plan-to-issues [path/to/plan.json]

# Or interactive
/plan-to-issues
```

#### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `plan.json` | No | Path to JSON plan file (or paste inline) |

#### What It Does

1. **Accepts Plan Input**
   - Reads JSON file from path
   - Or prompts for inline JSON paste
   - Validates JSON syntax

2. **Validates Plan Schema**
   - Checks required fields
   - Verifies task count (max 10)
   - Validates types/platforms/priorities

3. **Extracts Milestone**
   - Gets milestone from plan
   - Or prompts for milestone name
   - Creates if doesn't exist

4. **Triggers Workflow**
   - Calls `claude-plan-to-issues.yml`
   - Passes JSON as input
   - Waits for completion

5. **Creates Issues** (via workflow)
   - Creates 1 issue per task
   - Assigns labels automatically
   - Links dependencies
   - Adds to project board

6. **Shows Results**
   - Lists created issues with links
   - Shows milestone info
   - Provides project board link
   - Displays next steps

#### Example Usage

**Scenario 1: File-based plan**

```bash
$ /plan-to-issues plan.json

📋 Reading plan from: plan.json

✅ Valid JSON plan found
   - Milestone: Sprint 1 - Authentication
   - Tasks: 3
   - All validation passed

🚀 Triggering claude-plan-to-issues workflow...

⏳ Waiting for workflow to complete...

✅ Workflow completed successfully!

📋 Created Issues:
1. #123 - Add login endpoint
   https://github.com/user/repo/issues/123
   Labels: claude-code, status:ready, type:feature, platform:web, priority:high

2. #124 - Add authentication middleware
   https://github.com/user/repo/issues/124
   Labels: claude-code, status:ready, type:feature, platform:web, priority:high
   Depends on: #123

3. #125 - Add logout endpoint
   https://github.com/user/repo/issues/125
   Labels: claude-code, status:ready, type:feature, platform:web, priority:medium
   Depends on: #123, #124

📊 All issues added to project board: Ready status

🎯 Next Steps:
1. Review issues on project board
2. Issues will auto-create branches when ready
3. Start working on #123 first (no dependencies)
```

**Scenario 2: Interactive (paste JSON)**

```bash
$ /plan-to-issues

📋 Paste your plan JSON (Ctrl+D when done):
{
  "milestone": "User Profile Feature",
  "tasks": [
    {
      "title": "Design user profile API",
      "description": "Create RESTful API for user profiles",
      "acceptanceCriteria": ["GET /api/users/:id", "PUT /api/users/:id"],
      "type": "feature",
      "platform": "web",
      "priority": "high",
      "dependencies": []
    }
  ]
}
^D

✅ Plan validated
🚀 Creating 1 issue...
✅ Issue #126 created successfully
```

#### Plan JSON Schema

```typescript
interface ClaudePlan {
  milestone?: string;  // Optional milestone name
  tasks: Task[];       // Array of tasks (max 10)
}

interface Task {
  title: string;                    // Required: Issue title
  description: string;              // Required: Issue body
  acceptanceCriteria: string[];     // Required: Success criteria
  type: 'feature' | 'fix' | 'docs' | 'refactor' | 'test';  // Required
  platform: 'web' | 'mobile' | 'fullstack';                // Required
  priority: 'critical' | 'high' | 'medium' | 'low';        // Required
  dependencies?: number[];          // Optional: Array of task indices (0-based)
}
```

#### Example Plan Files

**Minimal plan (1 task)**:
```json
{
  "milestone": "Quick Fix",
  "tasks": [
    {
      "title": "Fix navigation crash",
      "description": "Resolve null pointer exception in navigation",
      "acceptanceCriteria": [
        "No crashes on navigation",
        "Null checks added",
        "Unit tests pass"
      ],
      "type": "fix",
      "platform": "mobile",
      "priority": "critical",
      "dependencies": []
    }
  ]
}
```

**Complex plan (with dependencies)**:
```json
{
  "milestone": "Authentication MVP",
  "tasks": [
    {
      "title": "Add user model",
      "description": "Create User model with email/password fields",
      "acceptanceCriteria": ["Model created", "Migrations run", "Validations added"],
      "type": "feature",
      "platform": "web",
      "priority": "high",
      "dependencies": []
    },
    {
      "title": "Add login endpoint",
      "description": "Create POST /api/auth/login",
      "acceptanceCriteria": ["Accepts credentials", "Returns JWT", "Error handling"],
      "type": "feature",
      "platform": "web",
      "priority": "high",
      "dependencies": [0]
    },
    {
      "title": "Add login UI",
      "description": "Create login form component",
      "acceptanceCriteria": ["Form validation", "Calls API", "Shows errors"],
      "type": "feature",
      "platform": "web",
      "priority": "medium",
      "dependencies": [1]
    }
  ]
}
```

#### Configuration

**Task Limit**: Max 10 tasks per plan (hard limit)

**Why 10?**
- Prevents API exhaustion
- Encourages focused planning
- Manageable sprint scope
- Leaves room for manual issues

**If you have >10 tasks**:
```json
// Split into multiple files
// plan-part1.json (tasks 1-10)
// plan-part2.json (tasks 11-20)
// Run /plan-to-issues twice
```

#### Troubleshooting

**Problem**: `❌ Invalid JSON syntax`

**Solution**: Validate JSON:
```bash
# Test JSON validity
cat plan.json | jq .

# Common errors:
# - Missing commas between items
# - Trailing commas (not allowed)
# - Unquoted keys
# - Single quotes (use double quotes)
```

Use a JSON validator: https://jsonlint.com/

---

**Problem**: `❌ Too many tasks (limit: 10)`

**Solution**: Split plan into multiple files:
```bash
# Create part 1
head -n X plan.json > plan-part1.json
/plan-to-issues plan-part1.json

# Create part 2
tail -n +Y plan.json > plan-part2.json
/plan-to-issues plan-part2.json
```

Or prioritize and create most important 10 tasks first.

---

**Problem**: `❌ Missing required field: type`

**Solution**: Every task MUST have all required fields:
```json
{
  "title": "My task",           // ✅ Required
  "description": "Details",     // ✅ Required
  "acceptanceCriteria": [...],  // ✅ Required
  "type": "feature",            // ✅ Required
  "platform": "web",            // ✅ Required
  "priority": "high"            // ✅ Required
}
```

---

**Problem**: Workflow fails with "Rate limit exceeded"

**Solution**: Wait for rate limit reset:
```bash
# Check rate limit
gh api rate_limit

# Shows reset time
# Wait until reset, then retry:
/plan-to-issues plan.json
```

---

#### Best Practices

✅ **DO**:
- Validate JSON before running
- Keep tasks focused and atomic
- Write clear acceptance criteria
- Set realistic priorities
- Link dependencies correctly
- Stay under 10 tasks

❌ **DON'T**:
- Exceed 10 tasks per plan
- Skip required fields
- Use vague descriptions
- Create duplicate issues
- Forget dependencies

---

### 3. /commit-smart

**Smart commit with quality checks and secret scanning**

#### Purpose

Creates commits safely with:
- Automatic quality checks (lint, typecheck, tests)
- Secret scanning (prevents committing API keys)
- Conventional commit format validation
- Pre-commit hook execution
- Interactive confirmation

#### When to Use

- ✅ **Regular commits**: Daily development workflow
- ✅ **Before pushing**: Ensure quality before sharing
- ✅ **Important changes**: Extra validation needed

#### Usage

```bash
/commit-smart [commit message]

# Or interactive
/commit-smart
```

#### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `message` | No | Commit message (or prompt interactively) |

#### What It Does

1. **Show Git Status**
   - Lists staged changes
   - Lists unstaged changes
   - Shows untracked files

2. **Scan for Secrets** (Security Check)
   - Scans all files for:
     - API keys (patterns like `api_key`, `API_KEY=`)
     - Tokens (`token`, `auth_token`)
     - Passwords (`password`, `PASSWORD=`)
     - Private keys (`-----BEGIN PRIVATE KEY-----`)
   - **Blocks commit** if secrets found
   - Shows matched lines

3. **Run Quality Checks**
   - **Lint**: `npm run lint` or `pnpm lint`
   - **Type Check**: `npm run type-check` or `tsc --noEmit`
   - **Unit Tests**: `npm run test` or `npm run test:unit`
   - Shows pass/fail for each
   - **Blocks commit** if any fail

4. **Generate/Validate Commit Message**
   - Prompts for message if not provided
   - Validates conventional commit format
   - Suggests improvements if needed
   - Confirms with user

5. **Show Preview**
   - Shows final commit message
   - Shows files to be committed
   - Shows status checks results
   - Asks for confirmation

6. **Create Commit**
   - Adds staged files
   - Creates commit with message
   - Executes pre-commit hooks
   - Shows commit SHA

7. **Prompt for Push** (optional)
   - Asks if user wants to push
   - Shows remote and branch
   - Pushes if confirmed

#### Example Usage

**Scenario 1: Success (all checks pass)**

```bash
$ /commit-smart

📋 Git Status:
Staged changes:
  M  src/auth/login.ts
  M  src/auth/middleware.ts
  A  tests/auth.test.ts

Unstaged changes:
  M  README.md

Untracked files:
  temp.log

🔐 Scanning for secrets...
✅ No secrets detected

🧪 Running quality checks...
✅ Lint: passed
✅ Type check: passed
✅ Unit tests: passed (15 tests, 3.2s)

💬 Enter commit message:
> feat(auth): Add JWT authentication middleware

✅ Valid conventional commit format

📋 Commit Preview:
────────────────────────────────────────
Message: feat(auth): Add JWT authentication middleware

Files:
  src/auth/login.ts
  src/auth/middleware.ts
  tests/auth.test.ts

Quality Checks: ✅ All passed
────────────────────────────────────────

Proceed with commit? (y/n): y

✅ Commit created: abc1234

🚀 Push to origin/feature/issue-123-auth? (y/n): y

✅ Pushed to origin/feature/issue-123-auth
```

**Scenario 2: Secret detected (blocked)**

```bash
$ /commit-smart

🔐 Scanning for secrets...
❌ Potential secrets detected!

File: src/config.ts
Line 12: const API_KEY = "sk-ant-api03-xxx..."
        ^^^^^^^^ Matches pattern: API_KEY

File: .env.local
Line 3: DATABASE_PASSWORD="SuperSecret123"
       ^^^^^^^^ Matches pattern: PASSWORD

🚨 COMMIT BLOCKED

These files contain potential secrets. Options:

1. Remove secrets and use environment variables:
   // src/config.ts
   const API_KEY = process.env.ANTHROPIC_API_KEY;

2. Add to .gitignore:
   echo ".env.local" >> .gitignore

3. Use .env.example for templates:
   # .env.example
   ANTHROPIC_API_KEY=your_key_here
   DATABASE_PASSWORD=your_password_here

After fixing, run /commit-smart again.
```

**Scenario 3: Quality check failed**

```bash
$ /commit-smart

🧪 Running quality checks...
✅ Lint: passed
❌ Type check: failed

Type errors found:
  src/auth/login.ts:24:15 - error TS2339: Property 'userId' does not exist on type 'User'.

🚨 COMMIT BLOCKED

Fix type errors and try again:
  npm run type-check

Or run tests to see all errors:
  npm run test:unit
```

#### Configuration

**Required package.json scripts**:
```json
{
  "scripts": {
    "lint": "eslint .",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:unit": "jest --testPathIgnorePatterns=integration"
  }
}
```

**Optional scripts** (auto-detected):
```json
{
  "scripts": {
    "format:check": "prettier --check .",
    "lint:fix": "eslint . --fix",
    "test:watch": "jest --watch"
  }
}
```

**Secret scanning patterns** (customizable in command file):
```regex
API_KEY|api_key|apikey
TOKEN|token|auth_token
PASSWORD|password|passwd
SECRET|secret
-----BEGIN .* KEY-----
sk-ant-api03-.*
```

#### Troubleshooting

**Problem**: Quality checks fail

**Solution**: Fix issues before committing:
```bash
# Run checks locally to debug
npm run lint
npm run type-check
npm run test

# Fix issues
npm run lint:fix  # Auto-fix lint issues

# Verify fixes
npm run lint && npm run type-check && npm run test

# Then commit
/commit-smart
```

---

**Problem**: Secret detected but it's not a secret

**Solution**:
1. **If it's a test fixture** - Add to allowed patterns
2. **If it's example/dummy** - Rename variable:
   ```javascript
   // ❌ Flagged
   const API_KEY = "example_key_here";

   // ✅ Not flagged
   const EXAMPLE_API_KEY = "example_key_here";
   ```
3. **If it's in .env.example** - Should be ignored automatically

---

**Problem**: Commit message format invalid

**Solution**: Use conventional commit format:
```
feat: Add new feature
fix: Resolve bug
docs: Update documentation
style: Format code
refactor: Refactor code
perf: Performance improvement
test: Add tests
build: Build system changes
ci: CI/CD changes
chore: Other changes
```

With scope (optional):
```
feat(auth): Add login
fix(api): Resolve timeout
docs(readme): Update setup
```

---

**Problem**: Pre-commit hook fails

**Solution**: Check hook output:
```bash
# View pre-commit hook
cat .git/hooks/pre-commit

# Run hook manually
.git/hooks/pre-commit

# Fix issues shown
# Then retry commit
/commit-smart
```

Common hook failures:
- Prettier formatting
- ESLint errors
- Test failures

---

#### Best Practices

✅ **DO**:
- Run quality checks locally before committing
- Use conventional commit format
- Write clear, descriptive messages
- Commit frequently (small changes)
- Review changes before confirming

❌ **DON'T**:
- Commit secrets or API keys
- Skip quality checks
- Use generic messages ("fix", "updates")
- Commit large batches
- Ignore test failures

---

### 4. /create-pr

**Create pull requests with proper issue linking and validation**

#### Purpose

Creates PRs with:
- Automatic issue linking from branch name
- Conventional commit title validation
- PR template completion
- Quality check validation
- Appropriate label assignment

#### When to Use

- ✅ **Feature complete**: Ready for review
- ✅ **Bug fixed**: Fix tested and working
- ✅ **After commits**: Changes pushed to remote

#### Usage

```bash
/create-pr [target-branch]

# Or interactive
/create-pr
```

#### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `target-branch` | No | Target branch (default: dev) |

#### What It Does

1. **Detect Current Branch**
   - Gets current branch name
   - Extracts issue number if present
   - Example: `feature/issue-123-add-auth` → Issue #123

2. **Ask for Target Branch**
   - Prompts: dev, main, staging?
   - Validates target exists
   - Default: dev

3. **Validate Quality Checks**
   - Checks last CI run status
   - Ensures lint/test passed
   - Warns if no CI run found
   - Blocks if checks failed

4. **Find Related Issues**
   - Searches for issue by number
   - Or prompts user to enter issue numbers
   - Validates issues exist
   - Suggests linked issues

5. **Generate PR Title**
   - Uses conventional commit format
   - Infers type from branch name
   - Extracts scope from issue
   - Example: `feat(auth): Add user authentication`

6. **Fill PR Template**
   - Uses `.github/pull_request_template.md`
   - Fills in sections automatically:
     * Summary (from issue)
     * Type of change (feature/fix/etc.)
     * Related issues (`Closes #123`)
     * Testing checklist
     * Code quality checklist

7. **Add Appropriate Labels**
   - Type label (from branch/title)
   - Platform label (from issue)
   - Status label (`in-review`)

8. **Create PR**
   - Uses GitHub CLI
   - Opens in browser (optional)
   - Shows PR URL

9. **Trigger Workflows**
   - `pr-into-dev.yml` runs automatically
   - Quality checks execute
   - Status syncs with issues

#### Example Usage

**Scenario 1: Standard feature PR**

```bash
$ git checkout feature/issue-123-add-auth
$ /create-pr

🌿 Current branch: feature/issue-123-add-auth
📌 Detected issue: #123

🎯 Target branch:
1. dev (recommended)
2. main
3. staging
Enter 1, 2, or 3: 1

✅ Target: dev

🧪 Checking quality status...
✅ CI passed on last commit (abc1234)
   - Lint: ✅
   - Type check: ✅
   - Tests: ✅ (15/15)

📋 Related issues:
Found issue #123: "Add user authentication"
Link this issue? (y/n): y

✅ Will link: Closes #123

📝 Generating PR title...
Suggested: feat(auth): Add user authentication
Use this title? (y/n): y

✅ Title: feat(auth): Add user authentication

📄 Filling PR template...
✅ Template filled:
   - Summary from issue
   - Type: feature
   - Related issues: Closes #123
   - Testing checklist
   - Code quality checklist

🏷️  Adding labels...
✅ Labels: type:feature, platform:web, status:in-review

🚀 Creating PR...
✅ PR created: #456
   https://github.com/user/repo/pull/456

🔄 Workflows triggered:
   - pr-into-dev.yml (validation)
   - pr-status-sync.yml (status update)

✅ Issue #123 status updated: In Review

📋 Next Steps:
1. Review PR in browser
2. Wait for checks to pass
3. Request review from team
4. Address review comments
5. Merge when approved
```

**Scenario 2: Hotfix PR to main**

```bash
$ git checkout hotfix/issue-456-security-patch
$ /create-pr main

⚠️  Creating PR directly to main

This is a hotfix. Confirm:
- Critical security issue? (y/n): y
- Tested in staging? (y/n): y
- Team notified? (y/n): y

✅ Confirmed - proceeding

🚀 Creating hotfix PR...
Title: fix(security): Patch authentication vulnerability
Target: main
Labels: type:hotfix, priority:critical

✅ PR #457 created
✅ Requires immediate review

🚨 Remember:
- Get emergency approval
- Monitor deployment closely
- Notify stakeholders
```

#### Configuration

**PR Template** (`.github/pull_request_template.md`):
```markdown
## Summary
<!-- What does this PR do? -->

## Type of Change
- [ ] Feature
- [ ] Bug fix
- [ ] Hotfix
- [ ] Documentation
- [ ] Refactoring

## Related Issues
<!-- Closes #123 -->

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing complete

## Code Quality
- [ ] Lint passing
- [ ] Type check passing
- [ ] No console.log statements
- [ ] Documentation updated
```

**Branch Naming** (for auto-detection):
```
feature/issue-123-description  → Type: feature, Issue: #123
fix/issue-456-bug-name         → Type: fix, Issue: #456
hotfix/issue-789-critical      → Type: hotfix, Issue: #789
docs/issue-101-update-readme   → Type: docs, Issue: #101
```

#### Troubleshooting

**Problem**: `❌ Quality checks failed`

**Solution**: Fix issues before creating PR:
```bash
# View failed checks
gh run list --limit 5

# Fix issues
npm run lint:fix
npm run type-check
npm run test

# Commit fixes
/commit-smart

# Push
git push

# Then create PR
/create-pr
```

---

**Problem**: `❌ No linked issues found`

**Solution**: Manually specify issue:
```bash
# When prompted:
Related issues:
No issues auto-detected.
Enter issue numbers (comma-separated): 123, 124

✅ Will link: Closes #123, Closes #124
```

Or rename branch:
```bash
git branch -m feature/issue-123-my-feature
```

---

**Problem**: PR title validation fails

**Solution**: Use conventional format:
```
feat(scope): Description
fix(scope): Description
docs(scope): Description
```

The command will help you format it correctly.

---

**Problem**: PR template not filled correctly

**Solution**: Edit PR description after creation:
```bash
gh pr edit 456 --body "$(cat << EOF
## Summary
My updated description

Closes #123
EOF
)"
```

---

#### Best Practices

✅ **DO**:
- Create PRs when feature complete
- Link all related issues
- Fill PR template completely
- Wait for quality checks
- Review your own PR first

❌ **DON'T**:
- Create draft PRs with failing tests
- Skip issue linking
- Leave template sections blank
- Create PRs from dev/main branches
- Create huge PRs (>500 lines)

---

### 5. /review-pr

**Comprehensive Claude-powered code review**

#### Purpose

Performs automated code review using Claude Code to analyze:
- Code quality and best practices
- Security vulnerabilities
- Performance issues
- Test coverage
- Documentation completeness

#### When to Use

- ✅ **Before merging**: Final review check
- ✅ **Large PRs**: Need thorough analysis
- ✅ **Security-critical**: Extra validation needed

#### Usage

```bash
/review-pr [pr-number]

# Or interactive
/review-pr
```

#### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `pr-number` | No | PR number to review (or prompt) |

#### What It Does

1. **Accept PR Number**
   - Prompts for PR number if not provided
   - Or detects from current branch
   - Validates PR exists

2. **Fetch PR Details**
   - Gets PR title, description, files changed
   - Gets linked issues
   - Gets target branch

3. **Fetch PR Changes**
   - Downloads diff for all changed files
   - Excludes generated files (lock files, etc.)
   - Limits to reviewable files (<5000 lines)

4. **Run Static Analysis**
   - ESLint on changed files
   - TypeScript compiler checks
   - Security scanner (basic)
   - Complexity analysis

5. **Claude Code Review**
   - Analyzes code changes
   - Checks against best practices
   - Identifies potential issues
   - Suggests improvements
   - Reviews tests and docs

6. **Security Scan**
   - Scans for common vulnerabilities:
     * SQL injection patterns
     * XSS vulnerabilities
     * Hardcoded secrets
     * Insecure dependencies
   - Flags high-risk patterns

7. **Generate Review Comment**
   - Creates structured review
   - Highlights issues by severity
   - Provides code examples
   - Suggests fixes
   - Shows test coverage gaps

8. **Post to PR**
   - Posts as PR comment
   - Or as review (with status)
   - Includes summary at top

9. **Show Summary**
   - Shows key findings
   - Lists all issues
   - Provides PR link

#### Example Usage

**Scenario 1: Comprehensive review**

```bash
$ /review-pr 456

📋 Fetching PR #456...
✅ PR: "feat(auth): Add user authentication"
   - 15 files changed (+450, -120)
   - Target: dev
   - Linked: #123

📥 Downloading changes...
✅ Retrieved 12 reviewable files (3,245 lines)

🔍 Running static analysis...
✅ ESLint: 0 errors, 2 warnings
✅ TypeScript: No errors
⚠️  Security scan: 1 potential issue

🤖 Claude Code Review...
Analyzing code changes...

───────────────────────────────────────
## Code Review Summary

**Overall Assessment**: ✅ Looks Good (with minor suggestions)

### ✅ Strengths
1. Clean implementation of JWT authentication
2. Good test coverage (85%)
3. Proper error handling
4. Well-documented API endpoints

### ⚠️  Minor Issues
1. **Performance**: Consider caching user lookups
   File: src/auth/middleware.ts:45
   ```typescript
   // Current
   const user = await db.users.findOne({ id: userId });

   // Suggested
   const user = await cache.getOrFetch(`user:${userId}`,
     () => db.users.findOne({ id: userId })
   );
   ```

2. **Security**: Add rate limiting to login endpoint
   File: src/auth/login.ts:12
   Consider using express-rate-limit

### 📝 Documentation
- ✅ API endpoints documented
- ⚠️  Missing: Authentication flow diagram
- ⚠️  Missing: Error codes reference

### 🧪 Testing
- ✅ Unit tests present (15 tests)
- ✅ Integration test for login flow
- ⚠️  Missing: Test for token expiration
- ⚠️  Missing: Test for invalid credentials

### 🔒 Security
- ✅ Passwords hashed with bcrypt
- ✅ JWT tokens signed securely
- ⚠️  Consider: Adding refresh tokens
- ⚠️  Consider: Implementing rate limiting

### 💡 Recommendations
1. Add Redis caching for user sessions
2. Implement rate limiting (5 attempts/minute)
3. Add refresh token rotation
4. Document authentication flow

**Estimated effort to address**: ~2-3 hours

───────────────────────────────────────

✅ Review posted to PR #456
🔗 https://github.com/user/repo/pull/456#issuecomment-123456

📊 Summary:
   - 2 suggestions
   - 0 blocking issues
   - 4 enhancements
   - Recommended: Approve with minor changes

Would you like to:
1. Approve PR (with comments)
2. Request changes
3. Just comment (no status)
Enter 1, 2, or 3:
```

**Scenario 2: Security issues found**

```bash
$ /review-pr 457

🔍 Running security scan...
❌ Security issues found!

───────────────────────────────────────
## 🚨 Security Review

### Critical Issues ❌

1. **SQL Injection Vulnerability**
   File: src/api/users.ts:23
   ```typescript
   // ❌ Vulnerable
   const users = await db.query(`SELECT * FROM users WHERE id = ${userId}`);

   // ✅ Fixed
   const users = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
   ```
   Severity: Critical
   Action: Fix before merge

2. **Exposed API Keys**
   File: src/config.ts:5
   ```typescript
   // ❌ Hardcoded
   const API_KEY = "sk-ant-api03-xxx...";

   // ✅ Use environment
   const API_KEY = process.env.ANTHROPIC_API_KEY;
   ```
   Severity: Critical
   Action: Fix before merge

───────────────────────────────────────

🚨 RECOMMEND: Request changes

These security issues must be fixed before merge.
```

#### Configuration

**Review scope** (customizable):
- Code quality rules
- Security patterns
- Performance checks
- Documentation requirements
- Test coverage thresholds

**File exclusions**:
```
package-lock.json
yarn.lock
pnpm-lock.yaml
*.min.js
*.map
dist/*
build/*
node_modules/*
```

**Severity levels**:
- 🔴 **Critical**: Must fix before merge
- 🟡 **Warning**: Should fix
- 🔵 **Info**: Consider improving

#### Troubleshooting

**Problem**: Review takes too long

**Solution**: PR may be too large
```bash
# Check PR size
gh pr view 456 --json additions,deletions

# If > 500 lines, consider splitting:
# - Break into smaller PRs
# - Review in stages
# - Focus on critical files first
```

---

**Problem**: Claude review misses obvious issues

**Solution**: Run static analysis first:
```bash
npm run lint
npm run type-check
npm audit

# Fix issues found
# Then run /review-pr
```

---

**Problem**: Review comments not posting

**Solution**: Check permissions:
```bash
# Verify authentication
gh auth status

# Check repo access
gh api repos/:owner/:repo/collaborators/:username

# Re-authenticate if needed
gh auth refresh
```

---

#### Best Practices

✅ **DO**:
- Review PRs before requesting team review
- Address all critical issues
- Run static analysis first
- Keep PRs small (<500 lines)
- Fix security issues immediately

❌ **DON'T**:
- Skip reviewing large PRs
- Ignore security warnings
- Merge with unresolved issues
- Review WIP/draft PRs

---

### 6. /release

**Production release management and coordination**

#### Purpose

Manages production releases with:
- Changelog generation
- Version bumping
- Release PR creation
- Deployment coordination
- Team notification

#### When to Use

- ✅ **Sprint complete**: Features ready for production
- ✅ **Hotfix deployed**: Emergency fix verified
- ✅ **Scheduled release**: Regular deployment cycle

#### Usage

```bash
/release [version]

# Or interactive
/release
```

#### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `version` | No | Version number (or auto-increment) |

#### What It Does

1. **Validate on Dev Branch**
   - Checks current branch is `dev`
   - Ensures all PRs merged
   - Verifies CI passed

2. **Check All PRs Merged**
   - Lists open PRs to dev
   - Warns if PRs still open
   - Confirms to continue

3. **Generate Changelog**
   - Gets commits since last release
   - Categorizes by type:
     * Features
     * Bug fixes
     * Documentation
     * Other
   - Formats in markdown

4. **Determine Version**
   - Reads current version
   - Suggests next version (semver):
     * Major: Breaking changes
     * Minor: New features
     * Patch: Bug fixes only
   - Or use provided version

5. **Update Version Files**
   - Updates `package.json`
   - Updates `VERSION` file (if exists)
   - Commits version bump

6. **Create Release PR**
   - Creates PR: dev → main
   - Title: `release: Version X.Y.Z`
   - Body: Changelog + linked issues
   - Labels: `type:release`

7. **Show Release Checklist**
   - Pre-deployment checklist:
     * Version bumped
     * Changelog complete
     * Breaking changes documented
     * Stakeholders notified
     * Rollback plan ready

8. **Wait for Approval**
   - Shows PR link
   - Monitors for approval
   - Optional: Auto-merge when approved

9. **Monitor Merge and Deployment**
   - Watches for merge
   - Tracks deployment workflows
   - Confirms release completed

#### Example Usage

**Scenario 1: Standard release**

```bash
$ git checkout dev
$ /release

🚀 Release Manager
═══════════════════════════════════

✅ On dev branch
✅ All commits pushed
✅ CI passed

📋 Checking open PRs...
✅ No open PRs to dev

📝 Generating changelog...

─────────────────────────────────
## Changes Since v1.1.0

### Features
- feat(auth): Add JWT authentication (#123)
- feat(profile): Add user profile page (#124)
- feat(api): Add REST API endpoints (#125)

### Bug Fixes
- fix(nav): Resolve navigation crash (#126)
- fix(api): Fix timeout issues (#127)

### Documentation
- docs: Update API documentation (#128)

### Other
- chore: Update dependencies (#129)
─────────────────────────────────

📦 Current version: 1.1.0

Suggest next version:
- Breaking changes found: No
- New features: Yes (3)
- Bug fixes: Yes (2)

Recommended: 1.2.0 (minor bump)

Use 1.2.0? (y/n/custom): y

✅ Version: 1.2.0

📝 Updating version files...
✅ package.json updated
✅ Committed version bump (def5678)

🚀 Creating release PR...
Title: release: Version 1.2.0
Target: main
Source: dev

✅ PR created: #458
🔗 https://github.com/user/repo/pull/458

📋 Release Checklist:

Before merging:
- [x] Version bumped to 1.2.0
- [x] Changelog generated
- [ ] Breaking changes documented (N/A)
- [ ] Team notified
- [ ] Smoke tests passed
- [ ] Rollback plan ready
- [ ] Stakeholders informed

🎯 Next Steps:
1. Review release PR #458
2. Run smoke tests in staging
3. Get approval from team lead
4. Merge when ready
5. Monitor deployment

Would you like to:
1. Wait for approval (watch)
2. Exit and merge manually
3. Auto-merge when approved
Enter 1, 2, or 3: 1

⏳ Watching PR #458 for approval...
✅ Approved by @teamlead
✅ All checks passed

🎯 Ready to merge!
Merge now? (y/n): y

🚀 Merging release PR...
✅ Merged to main (commit ghi9012)

🔄 Triggering deployment...
✅ dev-to-main.yml started
✅ release-status-sync.yml started

⏳ Monitoring deployment...
✅ Production build succeeded
✅ Smoke tests passed
✅ Issues closed (#123-129)
✅ GitHub release created

🎉 Release v1.2.0 Complete!

🔗 https://github.com/user/repo/releases/tag/v1.2.0

📊 Summary:
- 7 issues closed
- 3 features shipped
- 2 bugs fixed
- Deployment time: 8 minutes

🎯 Post-Release Tasks:
1. Monitor production logs
2. Check error rates
3. Notify customers
4. Update documentation
5. Close milestone
```

**Scenario 2: Hotfix release**

```bash
$ git checkout hotfix/issue-789-critical-bug
$ /release hotfix

⚠️  HOTFIX Release Mode

This will create an emergency release:
- Skips normal release process
- Merges directly to main
- Notifies team immediately

Confirm critical bug? (y/n): y
Tested in staging? (y/n): y
Team aware? (y/n): y

✅ Confirmed - proceeding

📦 Version: 1.2.1 (patch)
📝 Changelog:
### Hotfix
- fix: Critical authentication vulnerability (#789)

🚀 Creating hotfix PR...
✅ PR #459 created (requires emergency approval)

🚨 Team notified via:
- Slack
- Email
- GitHub mention

⏳ Fast-track approval process...
✅ Emergency approved
✅ Merging immediately

🚀 Deploying hotfix...
✅ Deployed to production
✅ Issue #789 closed

⚠️  Monitor closely for next 30 minutes!
```

#### Configuration

**Version scheme** (Semantic Versioning):
```
MAJOR.MINOR.PATCH

1.0.0 → 1.0.1 (patch: bug fixes)
1.0.0 → 1.1.0 (minor: new features)
1.0.0 → 2.0.0 (major: breaking changes)
```

**Changelog categories**:
```
### Features (feat:)
### Bug Fixes (fix:)
### Documentation (docs:)
### Performance (perf:)
### Refactoring (refactor:)
### Other (chore:, style:, test:)
```

**Release PR template** (auto-filled):
```markdown
## 🚀 Release vX.Y.Z

### Features
- ...

### Bug Fixes
- ...

### Breaking Changes
None

### Linked Issues
Closes #123
Closes #124

### Pre-Deploy Checklist
- [ ] All tests passing
- [ ] Smoke tests complete
- [ ] Breaking changes documented
- [ ] Team notified

### Rollback Plan
If issues occur:
1. Revert merge commit
2. Re-deploy previous version
3. Investigate issues
```

#### Troubleshooting

**Problem**: `❌ Not on dev branch`

**Solution**: Checkout dev first:
```bash
git checkout dev
git pull origin dev
/release
```

---

**Problem**: Open PRs blocking release

**Solution**: Finish or close PRs:
```bash
# List open PRs
gh pr list --base dev

# Close non-critical PRs
gh pr close 123 --comment "Moving to next sprint"

# Or merge ready PRs
gh pr merge 124 --squash
```

---

**Problem**: Version conflict

**Solution**: Check git tags:
```bash
# List versions
git tag -l

# Current version
git describe --tags --abbrev=0

# If conflict, manually bump:
npm version patch  # or minor, or major
```

---

**Problem**: Smoke tests failing

**Solution**: Don't release!
```bash
# Fix issues first
npm run test:smoke

# Or run specific smoke tests
npm run test -- smoke/critical.test.ts

# Fix and verify
# Then retry release
```

---

#### Best Practices

✅ **DO**:
- Release from dev branch only
- Generate comprehensive changelog
- Test in staging first
- Notify team before release
- Monitor deployment closely
- Have rollback plan ready

❌ **DON'T**:
- Release with failing tests
- Skip changelog generation
- Release without approval
- Deploy during high-traffic periods
- Release on Fridays (unless critical)

---

### 7. /sync-status

**Manual synchronization of issues and project board status**

#### Purpose

Manually syncs when automation fails or inconsistencies detected:
- Issue status vs PR status
- Project board vs issue labels
- Stale issue states
- Missing project board items

#### When to Use

- ✅ **After automation issues**: Workflows failed
- ✅ **Manual changes made**: Direct issue edits
- ✅ **Inconsistencies found**: Status doesn't match reality

#### Usage

```bash
/sync-status [scope]

# Or interactive
/sync-status
```

#### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `scope` | No | What to sync: all, issues, board, prs |

#### What It Does

1. **Scan All Open Issues**
   - Gets all open issues with `claude-code` label
   - Checks current status
   - Gets associated PRs

2. **Check Associated PRs**
   - For each issue, finds linked PRs
   - Checks PR state (open, merged, closed)
   - Determines correct issue status

3. **Check Project Board Status**
   - Gets project board status for each issue
   - Compares with actual issue/PR state
   - Finds mismatches

4. **Identify Inconsistencies**
   - Lists issues with status mismatch
   - Shows current vs expected state
   - Estimates sync actions needed

5. **Show Proposed Changes**
   - Lists all changes to be made
   - Groups by type:
     * Issue status updates
     * Project board updates
     * Label updates
   - Shows before/after

6. **Confirm and Fix**
   - Asks for confirmation
   - Applies changes one by one
   - Shows progress
   - Handles errors gracefully

7. **Generate Report**
   - Shows what was fixed
   - Lists remaining issues
   - Provides recommendations

#### Example Usage

**Scenario 1: Full sync after automation failure**

```bash
$ /sync-status

🔄 Status Sync Tool
═══════════════════════════════════

📊 Scanning repository...
✅ Found 15 open issues with claude-code label
✅ Found 12 associated PRs
✅ Connected to project board

🔍 Checking for inconsistencies...

Found 5 issues with status problems:

────────────────────────────────────
1. Issue #123 "Add authentication"
   Current: In Progress
   Actual: PR #456 merged to dev
   Expected: To Deploy
   Action: Update to "To Deploy"

2. Issue #124 "Fix navigation"
   Current: In Review
   Actual: PR #457 closed (not merged)
   Expected: In Progress
   Action: Update to "In Progress"

3. Issue #125 "Update docs"
   Current: Ready
   Actual: PR #458 open and ready
   Expected: In Review
   Action: Update to "In Review"

4. Issue #126 "Add tests"
   Current: In Review
   Actual: No PR found
   Expected: In Progress
   Action: Update to "In Progress"

5. Issue #127 "Refactor code"
   Current: To Deploy
   Actual: On project board but not in status field
   Expected: Sync to board
   Action: Set board status to "To Deploy"
────────────────────────────────────

📋 Summary:
   - 5 issues need status updates
   - 2 project board syncs needed
   - 0 labels need updating

Estimated time: ~30 seconds

Apply these changes? (y/n): y

🔄 Syncing...

✅ Issue #123 → To Deploy
✅ Issue #124 → In Progress
✅ Issue #125 → In Review
✅ Issue #126 → In Progress
✅ Issue #127 → Project board synced

✅ All changes applied successfully!

📊 Final Report:
   - 5 issues synchronized
   - 0 errors
   - Repository is consistent

🎯 Recommendations:
   - Issue #124: Consider reopening PR
   - Issue #126: Create PR when ready
```

**Scenario 2: Selective sync (issues only)**

```bash
$ /sync-status issues

🔄 Syncing issues only...

📊 Checking issue statuses...
✅ Found 2 inconsistencies

1. Issue #130: In Progress → In Review (PR opened)
2. Issue #131: In Review → In Progress (PR closed)

Apply? (y/n): y

✅ Issues synchronized

Project board sync skipped (use /sync-status board)
```

**Scenario 3: Project board sync**

```bash
$ /sync-status board

🔄 Syncing project board...

📊 Checking board items...

Found 3 issues missing from board:
- #132 "Add feature X"
- #133 "Fix bug Y"
- #134 "Update docs Z"

Add to board? (y/n): y

✅ Added #132 to board (status: Ready)
✅ Added #133 to board (status: Ready)
✅ Added #134 to board (status: Ready)

Found 2 status mismatches:
- #135: Board shows "In Progress", Issue shows "In Review"
- #136: Board shows "In Review", Issue shows "To Deploy"

Sync board to match issues? (y/n): y

✅ #135 board → In Review
✅ #136 board → To Deploy

✅ Project board synchronized!
```

#### Configuration

**Sync scope options**:
```
all     - Sync everything (issues, board, PRs)
issues  - Sync issue statuses only
board   - Sync project board only
prs     - Check PR states only
```

**Status mapping**:
```
PR State              → Issue Status    → Board Status
────────────────────────────────────────────────────
No PR                 → In Progress     → In Progress
PR draft              → In Progress     → In Progress
PR ready              → In Review       → In Review
PR approved           → In Review       → In Review
PR merged to dev      → To Deploy       → To Deploy
PR merged to main     → Done (closed)   → Done
PR closed (no merge)  → In Progress     → In Progress
```

**Consistency rules**:
1. Issue status MUST match PR state
2. Project board MUST match issue status
3. Closed issues MUST be "Done" on board
4. Open issues MUST have valid status

#### Troubleshooting

**Problem**: Sync takes too long

**Solution**: Use scoped sync:
```bash
# Sync specific issues
/sync-status issues

# Or check one issue
gh issue view 123 --json state,labels
```

---

**Problem**: Changes not applying

**Solution**: Check permissions:
```bash
# Verify repo access
gh api repos/:owner/:repo --jq .permissions

# Need: write access to issues and project

# Check project URL secret
gh secret list | grep PROJECT_URL
```

---

**Problem**: False inconsistencies detected

**Solution**: May be due to:
1. Recent changes (wait 10 seconds)
2. Workflows still running (check Actions tab)
3. Manual edits (expected)

Run sync again after workflows complete.

---

**Problem**: Project board not syncing

**Solution**: Verify project board setup:
```bash
# Check PROJECT_URL secret
gh secret get PROJECT_URL

# Verify project exists
# Visit URL in browser

# Check Status field exists
# Project → Settings → Fields → Status
```

---

#### Best Practices

✅ **DO**:
- Run after workflow failures
- Use scoped sync for speed
- Review changes before applying
- Run during low-activity periods
- Check reports for patterns

❌ **DON'T**:
- Run during active workflows
- Sync without reviewing changes
- Ignore sync recommendations
- Run too frequently (causes churn)

---

### 8. /kill-switch

**Emergency workflow disable mechanism**

#### Purpose

Immediately disables all workflows in case of:
- Infinite loops detected
- Critical bug in workflows
- Emergency maintenance needed
- Runaway automation

#### When to Use

- 🚨 **Emergency only**: Workflows causing problems
- 🚨 **Infinite loops**: Automation not stopping
- 🚨 **Critical bugs**: Workflows breaking things

#### Usage

```bash
/kill-switch [action]

# Or interactive
/kill-switch
```

#### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `action` | No | enable, disable, or status |

#### What It Does

1. **Show Current Status**
   - Checks for `.github/WORKFLOW_KILLSWITCH` file
   - Shows whether killswitch is active
   - Lists affected workflows

2. **Ask for Action**
   - Enable killswitch (disable workflows)
   - Disable killswitch (re-enable workflows)
   - Show status only

3. **Create/Update Killswitch File**
   - Creates `.github/WORKFLOW_KILLSWITCH`
   - Or removes it (to re-enable)
   - Commits with `--no-verify` (skips hooks)

4. **Push Immediately**
   - Pushes without waiting
   - Bypasses all checks
   - Forces update if needed

5. **Verify All Workflows Respect Killswitch**
   - Each workflow checks for killswitch file
   - Exits immediately if found
   - Logs reason for exit

6. **Notify Team** (optional)
   - Posts to Slack/Discord
   - Sends email notification
   - Comments on open PRs

7. **Show Confirmation**
   - Confirms action taken
   - Shows when workflows will stop
   - Provides recovery instructions

#### Example Usage

**Scenario 1: Emergency disable**

```bash
$ /kill-switch

🚨 Emergency Kill Switch
═══════════════════════════════════

⚠️  WARNING: This will immediately disable ALL automated workflows!

Use only when:
- Workflows are causing problems
- Infinite loops detected
- Emergency maintenance needed

────────────────────────────────────

📊 Current Status:
✅ Workflows active (8 running normally)
❌ No killswitch active

What would you like to do?
1. Disable workflows (EMERGENCY)
2. Show status
3. Cancel
Enter 1, 2, or 3: 1

⚠️  Are you sure? Type 'DISABLE' to confirm: DISABLE

🚨 Activating kill switch...

✅ Created .github/WORKFLOW_KILLSWITCH
✅ Committed (abc1234)
✅ Pushed to origin/main

🔄 Workflows will stop within ~10 seconds

📋 Affected workflows:
   - bootstrap.yml
   - reusable-pr-checks.yml
   - pr-into-dev.yml
   - dev-to-main.yml
   - claude-plan-to-issues.yml
   - create-branch-on-issue.yml
   - pr-status-sync.yml
   - release-status-sync.yml

⚠️  All 8 workflows now disabled

🔔 Team notified:
   - Posted to #dev-ops Slack
   - Emailed team leads
   - Commented on open PRs

📋 To re-enable:
   /kill-switch enable

🎯 Next Steps:
1. Investigate the issue
2. Fix the problem
3. Test in another repo
4. Re-enable when safe:
   /kill-switch enable
```

**Scenario 2: Check status**

```bash
$ /kill-switch status

📊 Kill Switch Status
═══════════════════════════════════

🚨 ACTIVE - All workflows disabled

Reason: Emergency maintenance
Activated: 2025-11-06 10:30 UTC
Duration: 15 minutes
By: @alirezarezvani

📋 Status:
   - 8 workflows paused
   - 3 workflow runs cancelled
   - 0 queued runs

🔔 Team aware: Yes
   - Slack notification sent
   - 5 PRs have warning comment

📋 To re-enable:
   /kill-switch enable
```

**Scenario 3: Re-enable workflows**

```bash
$ /kill-switch enable

🔄 Re-enabling Workflows
═══════════════════════════════════

📊 Current Status:
🚨 Kill switch ACTIVE (disabled 20 minutes ago)

Are you sure workflows are safe to re-enable? (y/n): y

🔄 Deactivating kill switch...

✅ Removed .github/WORKFLOW_KILLSWITCH
✅ Committed (def5678)
✅ Pushed to origin/main

✅ Workflows re-enabled!

📋 Workflows active:
   - All 8 workflows operational
   - No queued runs
   - System healthy

🔔 Team notified:
   - Posted to #dev-ops Slack
   - Updated PR comments

🎯 Monitor closely for next 30 minutes
   Check Actions tab for any issues
```

**Scenario 4: Emergency with infinite loop**

```bash
$ /kill-switch

🚨 EMERGENCY: Possible infinite loop detected!

📊 Detected:
   - 15 workflow runs in last 2 minutes
   - Same workflows triggering repeatedly
   - API rate limit at 5%

⚠️  Auto-activating kill switch!

✅ Kill switch ACTIVATED
✅ All workflows stopped
✅ Team notified

📋 Investigation needed:
   1. Check recent commits for workflow changes
   2. Review workflow_dispatch triggers
   3. Check debounce delays
   4. Verify concurrency limits

Run /kill-switch status for details
```

#### How Workflows Check Killswitch

Each workflow includes this check:

```yaml
jobs:
  killswitch-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check kill switch
        run: |
          if [ -f .github/WORKFLOW_KILLSWITCH ]; then
            echo "🚨 Kill switch active - workflow disabled"
            echo "Remove .github/WORKFLOW_KILLSWITCH to re-enable"
            exit 1
          fi
          echo "✅ Kill switch not active - proceeding"
```

#### Configuration

**Killswitch file** (`.github/WORKFLOW_KILLSWITCH`):
```yaml
# Workflow Kill Switch
# All automated workflows are disabled while this file exists
#
# Activated: 2025-11-06 10:30 UTC
# By: @alirezarezvani
# Reason: Emergency maintenance - infinite loop detected
#
# To re-enable workflows: Delete this file and commit
#
# Emergency contact: ops-team@company.com
```

**Notification channels**:
- Slack webhook (optional)
- Email (via GitHub notifications)
- PR comments (automatic)
- Issue labels (adds `killswitch-active`)

#### Troubleshooting

**Problem**: Killswitch not stopping workflows

**Solution**: Workflows may be running already:
```bash
# List running workflows
gh run list --status in_progress

# Cancel them manually
gh run cancel RUN_ID

# Verify killswitch file exists
cat .github/WORKFLOW_KILLSWITCH
```

---

**Problem**: Can't push killswitch file

**Solution**: Bypass branch protection:
```bash
# Use admin override (if you have admin access)
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field enforce_admins=false

# Push killswitch
git push

# Re-enable protection
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field enforce_admins=true
```

---

**Problem**: Forgot killswitch is active

**Solution**: Set up reminders:
```bash
# Check daily
crontab -e
# Add: 0 9 * * * cd /repo && /kill-switch status

# Or add to team standup checklist
```

---

**Problem**: Need partial disable

**Solution**: Kill switch is all-or-nothing. For selective disable:
```bash
# Disable specific workflow
gh workflow disable bootstrap.yml

# List disabled workflows
gh workflow list

# Re-enable when ready
gh workflow enable bootstrap.yml
```

---

#### Best Practices

✅ **DO**:
- Use ONLY in emergencies
- Document reason for activation
- Notify team immediately
- Investigate root cause
- Test fix in separate repo
- Re-enable as soon as safe
- Monitor after re-enabling

❌ **DON'T**:
- Use casually or frequently
- Leave active for >1 hour
- Forget to re-enable
- Use without team notification
- Skip root cause analysis

---

## Command Integration

### How Commands Work with Workflows

```
Commands (Interactive)              Workflows (Automated)
────────────────                   ────────────────────

/blueprint-init                    → bootstrap.yml
   ↓
Creates branches, secrets          → Validates setup
   ↓

/plan-to-issues                    → claude-plan-to-issues.yml
   ↓
Triggers workflow                  → Creates issues
   ↓
                                   → create-branch-on-issue.yml
                                      (auto-creates branches)
   ↓

/create-pr                         → pr-into-dev.yml
   ↓
Creates PR                         → Validates PR
   ↓
                                   → pr-status-sync.yml
                                      (syncs status)
   ↓

/review-pr                         (Manual review)
   ↓
Posts review comments
   ↓

PR merged                          → pr-status-sync.yml
                                      (updates to "To Deploy")
   ↓

/release                           → dev-to-main.yml
   ↓
Creates release PR                 → Release gates
   ↓
                                   → release-status-sync.yml
                                      (closes issues, creates release)
```

### Coordination Points

1. **Setup Phase**: `/blueprint-init` → `bootstrap.yml`
2. **Planning Phase**: `/plan-to-issues` → `claude-plan-to-issues.yml`
3. **Development Phase**: Commands + auto-workflows
4. **Review Phase**: `/review-pr` + manual review
5. **Release Phase**: `/release` → release workflows

---

## Best Practices

### General Command Usage

✅ **DO**:
- Read command prompts carefully
- Answer questions thoughtfully
- Review changes before confirming
- Keep commands updated
- Report bugs/issues

❌ **DON'T**:
- Skip prerequisite checks
- Ignore error messages
- Rush through prompts
- Use commands without understanding
- Modify command files without testing

### Error Handling

**When commands fail**:
1. Read error message carefully
2. Check logs/output
3. Verify prerequisites
4. Try again with correct inputs
5. Ask for help if stuck

**Common recovery steps**:
```bash
# Check git status
git status

# Check gh CLI auth
gh auth status

# Check current branch
git branch --show-current

# Check remote status
git fetch --all
git status -uno
```

### Automation Flow

**Recommended workflow**:
```
Setup → Plan → Develop → Review → Release

Day 1: /blueprint-init (once)
Day 1: /plan-to-issues (sprint start)
Daily: /commit-smart + /create-pr
Weekly: /review-pr
Bi-weekly: /release

As needed: /sync-status, /kill-switch
```

---

## Common Patterns

### Pattern 1: New Feature Flow

```bash
# 1. Plan feature
cat > feature-plan.json << EOF
{
  "milestone": "User Authentication",
  "tasks": [...]
}
EOF

# 2. Create issues
/plan-to-issues feature-plan.json

# 3. Branch auto-created, start working
git fetch origin
git checkout feature/issue-123-add-auth

# 4. Develop with smart commits
# ... make changes ...
/commit-smart

# 5. Create PR when ready
/create-pr

# 6. Review before merge
/review-pr 456

# 7. Merge (manual via GitHub)

# 8. Release when sprint done
/release
```

### Pattern 2: Bug Fix Flow

```bash
# 1. Create issue manually or from bug report
gh issue create \
  --title "Fix navigation crash" \
  --label "type:fix,priority:high,claude-code,status:ready"

# 2. Branch auto-created

# 3. Fix and commit
git checkout fix/issue-789-nav-crash
# ... fix bug ...
/commit-smart "fix(nav): resolve null pointer"

# 4. Create PR
/create-pr

# 5. Quick release if critical
/release hotfix
```

### Pattern 3: Documentation Update

```bash
# 1. Create issue
gh issue create \
  --title "Update API docs" \
  --label "type:docs,claude-code,status:ready"

# 2. Make changes
git checkout docs/issue-100-update-api-docs
# ... update docs ...

# 3. Commit (skips tests for docs-only)
/commit-smart "docs(api): update endpoint documentation"

# 4. Create PR (fast-tracked)
/create-pr

# 5. Self-approve if minor
gh pr review --approve

# 6. Merge
gh pr merge --squash
```

### Pattern 4: Emergency Response

```bash
# Critical bug in production!

# 1. Disable workflows if causing issues
/kill-switch

# 2. Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-security-patch

# 3. Fix quickly
# ... make fix ...
git add .
git commit -m "fix(security): patch vulnerability"

# 4. Push and create PR directly to main
git push origin hotfix/critical-security-patch
gh pr create --base main --title "fix(security): Critical security patch" --body "Closes #999"

# 5. Emergency review
/review-pr 500

# 6. Get immediate approval and merge
gh pr merge --squash

# 7. Re-enable workflows
/kill-switch enable

# 8. Monitor production closely
```

---

## Troubleshooting

### General Issues

**Problem**: Command not found

**Solution**: Check command file exists:
```bash
ls -la .claude/commands/github/

# If missing, copy from blueprint:
cp -r /path/to/blueprint/.claude/commands/github .claude/commands/
```

---

**Problem**: Command hangs or freezes

**Solution**:
```bash
# Cancel: Ctrl+C
# Check for stuck processes:
ps aux | grep claude

# Restart Claude Code
# Try command again
```

---

**Problem**: Permissions error

**Solution**: Check authentication:
```bash
# GitHub CLI
gh auth status
gh auth refresh

# Git
git config --list | grep user

# Repository access
gh api repos/:owner/:repo --jq .permissions
```

---

**Problem**: Rate limit exceeded

**Solution**: Wait for reset:
```bash
# Check rate limit
gh api rate_limit

# Shows:
# - remaining calls
# - reset time
# - used calls

# Wait until reset, then retry
```

---

### Command-Specific Issues

See individual command documentation above for specific troubleshooting.

### Getting Help

1. **Check command documentation**: This guide
2. **View command prompt**: `.claude/commands/github/*.md`
3. **Check workflow logs**: `gh run list`
4. **Search GitHub Issues**: Common problems
5. **Ask team**: Slack/Discord channel
6. **File bug report**: GitHub Issues

---

## Next Steps

✅ **Commands documented!** You now understand all 8 interactive commands.

**Continue Learning**:
- [Workflows Reference](./WORKFLOWS.md) - 8 GitHub Actions workflows
- [Customization Guide](./CUSTOMIZATION.md) - Advanced configuration
- [Architecture Deep Dive](./ARCHITECTURE.md) - System design

**Get Started**:
1. Run `/blueprint-init` to set up your repository
2. Create your first plan with Claude Code
3. Run `/plan-to-issues` to create tasks
4. Use `/commit-smart` and `/create-pr` daily
5. Run `/release` when sprint completes

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-06
**Commands Version**: Phase 2 Complete
