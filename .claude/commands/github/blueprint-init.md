# /blueprint-init - Interactive Setup Wizard

**Description**: Interactive setup wizard that configures a repository with the GitHub Workflow Blueprint from scratch.

**Usage**: `/blueprint-init`

**Estimated Time**: <5 minutes

---

## Workflow

You are an interactive setup wizard for the GitHub Workflow Blueprint. Guide the user through repository setup with clear questions, validation, and helpful feedback.

### Step 1: Welcome & Prerequisites Check

**Display welcome message**:
```
🚀 GitHub Workflow Blueprint - Setup Wizard
================================================

This wizard will configure your repository with:
✅ GitHub Actions workflows (8 workflows)
✅ Composite actions (5 reusable actions)
✅ Configuration templates (PR, issues, commits)
✅ Project board integration
✅ Branch protections

Estimated time: <5 minutes
```

**Check prerequisites**:
1. Verify `gh` CLI is installed: `gh --version`
2. Verify `git` is available: `git --version`
3. Verify authenticated: `gh auth status`
4. Check if in git repository: `git rev-parse --git-dir`

**If any prerequisite fails**:
- Show clear installation instructions
- Ask if user wants to continue anyway (not recommended)
- Provide links to documentation

---

### Step 2: Detect Project Type

**Ask user**:
```
📦 What type of project is this?

1. Web (frontend/backend web applications)
2. Mobile (React Native, iOS, Android)
3. Fullstack (web + backend + optional mobile)

Enter 1, 2, or 3:
```

**Store response as**: `PROJECT_TYPE` (web/mobile/fullstack)

**Validation**: Must be 1, 2, or 3. Re-prompt if invalid.

---

### Step 3: Choose Branching Strategy

**Ask user**:
```
🌿 Which branching strategy do you want to use?

1. Simple: feature → main
   - Best for: Solo developers, small projects
   - Fast, minimal overhead

2. Standard: feature → dev → main (RECOMMENDED)
   - Best for: Small to medium teams
   - Good balance of safety and speed

3. Complex: feature → dev → staging → main
   - Best for: Enterprise, multiple environments
   - Maximum safety, slower

Enter 1, 2, or 3:
```

**Store response as**: `BRANCHING_STRATEGY` (simple/standard/complex)

**Validation**: Must be 1, 2, or 3. Re-prompt if invalid.

---

### Step 4: Get Project Board URL

**Ask user**:
```
📊 Enter your GitHub Project board URL:

Format: https://github.com/users/USERNAME/projects/NUMBER
    or: https://github.com/orgs/ORG/projects/NUMBER

Example: https://github.com/users/alirezarezvani/projects/1

URL:
```

**Store response as**: `PROJECT_URL`

**Validation**:
1. Must match regex: `https://github\.com/(users|orgs)/[^/]+/projects/\d+`
2. Parse and extract: owner, project number
3. Verify project exists via: `gh api graphql -f query='...'`

**If invalid**: Show error and re-prompt

---

### Step 5: Get Anthropic API Key

**Ask user**:
```
🔑 Enter your Anthropic API Key:

This is required for Claude Code integration in workflows.
Get your API key from: https://console.anthropic.com/

API Key:
```

**Store response as**: `ANTHROPIC_API_KEY`

**Validation**:
1. Not empty
2. Starts with "sk-ant-"
3. Reasonable length (>20 characters)

**If invalid**: Show warning but allow to continue

**Security note**: Display: "⚠️  API key will be stored as a repository secret (encrypted)"

---

### Step 6: Configuration Summary

**Display summary**:
```
📋 Configuration Summary
========================

Project Type:          [PROJECT_TYPE]
Branching Strategy:    [BRANCHING_STRATEGY]
Project Board:         [PROJECT_URL]
API Key:               sk-ant-***[last 4 chars]

Branches to create:
[List based on strategy]

Ready to proceed? (y/n):
```

**If user answers 'n'**: Exit with message "Setup cancelled. Run /blueprint-init to start over."

---

### Step 7: Create Required Branches

**Based on branching strategy, create branches**:

**For Simple (feature → main)**:
- No additional branches needed (only main exists)

**For Standard (feature → dev → main)**:
- Check if `dev` exists: `git rev-parse --verify dev`
- If not, create: `git checkout -b dev && git push -u origin dev`

**For Complex (feature → dev → staging → main)**:
- Check if `dev` exists, create if not
- Check if `staging` exists: `git rev-parse --verify staging`
- If not, create: `git checkout -b staging && git push -u origin staging`

**Display progress**:
```
🌿 Creating branches...
   ✅ Branch 'dev' created
   ✅ Branch 'staging' created
```

**Error handling**: If branch creation fails, show error and ask if user wants to:
- Retry
- Skip (branches already exist)
- Abort setup

---

### Step 8: Set Repository Secrets

**Set secrets using GitHub CLI**:

```bash
# Set PROJECT_URL secret
gh secret set PROJECT_URL --body "$PROJECT_URL"

# Set ANTHROPIC_API_KEY secret
gh secret set ANTHROPIC_API_KEY --body "$ANTHROPIC_API_KEY"
```

**Display progress**:
```
🔐 Setting repository secrets...
   ✅ PROJECT_URL configured
   ✅ ANTHROPIC_API_KEY configured
```

**Verify secrets were set**:
```bash
gh secret list
```

**Error handling**: If secret setting fails:
- Show clear error message
- Provide manual instructions: "Settings → Secrets and variables → Actions → New repository secret"
- Ask if user wants to continue

---

### Step 9: Run Bootstrap Workflow

**Trigger bootstrap workflow**:
```bash
gh workflow run bootstrap.yml
```

**Wait for workflow to start and get run ID**:
```bash
WORKFLOW_RUN_ID=$(gh run list --workflow=bootstrap.yml --limit 1 --json databaseId --jq '.[0].databaseId')
```

**Display progress**:
```
⚙️  Running bootstrap workflow...
   - Creating labels (status, type, platform, priority)
   - Validating project board
   - Checking secrets
```

**Monitor workflow status** (poll every 5 seconds, max 2 minutes):
```bash
gh run watch $WORKFLOW_RUN_ID
```

**If workflow succeeds**: Continue to next step

**If workflow fails**:
- Show workflow logs: `gh run view $WORKFLOW_RUN_ID --log`
- Ask if user wants to:
  - View full logs
  - Retry bootstrap
  - Continue anyway (not recommended)
  - Abort setup

---

### Step 10: Apply Branch Protections

**Based on branching strategy, apply protections**:

**For all strategies - Protect `main` branch**:
```bash
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null \
  --field required_linear_history=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

**For Standard/Complex - Also protect `dev` branch**:
```bash
gh api repos/:owner/:repo/branches/dev/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

**For Complex - Also protect `staging` branch**:
```bash
gh api repos/:owner/:repo/branches/staging/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

**Display progress**:
```
🔒 Applying branch protections...
   ✅ Protected branch: main
   ✅ Protected branch: dev
   ✅ Protected branch: staging
```

**Error handling**: If branch protection fails (often due to free plan limitations):
- Show warning: "⚠️  Branch protections require GitHub Pro or organization account"
- Display manual steps to enable protections
- Continue setup (non-critical)

---

### Step 11: Validate Complete Setup

**Run validation checks**:

1. **Check branches exist**:
   ```bash
   git branch -r | grep -E "(origin/main|origin/dev|origin/staging)"
   ```

2. **Check secrets are set**:
   ```bash
   gh secret list | grep -E "(PROJECT_URL|ANTHROPIC_API_KEY)"
   ```

3. **Check labels were created**:
   ```bash
   gh label list | grep -E "(claude-code|status:ready|type:feature)"
   ```

4. **Check workflows exist**:
   ```bash
   ls -1 .github/workflows/*.yml | wc -l
   # Should be 8
   ```

5. **Check composite actions exist**:
   ```bash
   ls -1 .github/actions/*/action.yml | wc -l
   # Should be 5
   ```

**Display validation results**:
```
✅ Validation Results
=====================

Branches:          ✅ All required branches exist
Secrets:           ✅ Both secrets configured
Labels:            ✅ 23 labels created
Workflows:         ✅ 8 workflows ready
Composite Actions: ✅ 5 actions ready
Branch Protections: ⚠️  Manual setup required (see above)
```

---

### Step 12: Generate Setup Summary

**Display final summary**:
```
🎉 Setup Complete!
==================

Your repository is now configured with the GitHub Workflow Blueprint.

📊 Summary:
   Project Type:      [PROJECT_TYPE]
   Branching:         [BRANCHING_STRATEGY]
   Workflows:         8 core workflows
   Actions:           5 composite actions
   Labels:            23 labels
   Project Board:     Connected

🚀 Next Steps:

1. Create your first issue:
   - Use the "Plan Task" or "Manual Task" template
   - Add labels: claude-code + status:ready
   - Branch will be auto-created!

2. Start working:
   - git checkout feature/issue-1-your-task
   - Make changes
   - git commit -m "feat: your changes"
   - git push origin feature/issue-1-your-task

3. Create pull request:
   - Use /create-pr command (or manually)
   - Link issue in PR description: "Closes #1"
   - Automated quality checks will run

4. Helpful commands:
   - /plan-to-issues  - Convert Claude plan to issues
   - /commit-smart    - Smart commit with quality checks
   - /create-pr       - Create PR with proper linking
   - /release         - Create production release

📚 Documentation:
   - README.md         - Project overview
   - docs/QUICK_START.md - 5-minute guide
   - CLAUDE.md         - Project context

⚙️  Configuration saved to: .github/

---

Setup completed successfully at [timestamp]
```

**Save setup log** to `.github/setup-log.txt` for reference.

---

## Error Handling & Rollback

If setup fails at any step:

**Offer rollback options**:
```
❌ Setup failed at: [STEP_NAME]

Error: [ERROR_MESSAGE]

What would you like to do?
1. Retry this step
2. Skip this step (may cause issues)
3. Rollback changes and exit
4. Continue anyway (not recommended)

Enter 1, 2, 3, or 4:
```

**Rollback procedure** (if user selects option 3):
1. Delete created branches (if any): `git push origin --delete dev staging`
2. Remove secrets: `gh secret remove PROJECT_URL ANTHROPIC_API_KEY`
3. Delete created labels (if bootstrap ran): `gh label delete claude-code --yes`
4. Show: "✅ Rollback complete. Repository restored to previous state."

---

## Notes for Implementation

- **Interactive**: Use clear prompts and wait for user input
- **Validation**: Validate all inputs before proceeding
- **Progress**: Show clear progress indicators at each step
- **Errors**: Provide actionable error messages with solutions
- **Logging**: Log all actions to `.github/setup-log.txt`
- **Safety**: Always ask for confirmation before destructive actions
- **Help**: Provide links to documentation when needed

---

## Testing Checklist

- [ ] Test with each project type (web/mobile/fullstack)
- [ ] Test with each branching strategy (simple/standard/complex)
- [ ] Test with invalid inputs (error handling)
- [ ] Test with missing prerequisites
- [ ] Test rollback functionality
- [ ] Test on fresh repository
- [ ] Test on repository with existing setup (should handle gracefully)

---

**Author**: Alireza Rezvani
**Date**: 2025-11-06
**Estimated Time**: 1.5 hours implementation
