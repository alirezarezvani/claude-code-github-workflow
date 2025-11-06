# Quick Start - 5 Minutes to First Workflow

Get your repository automated with GitHub Actions + Claude Code in under 5 minutes.

---

## 📋 Prerequisites (5 items)

Before you begin, ensure you have:

1. **GitHub Account** - With admin access to your repository
2. **GitHub Project Board** - Create a GitHub Projects v2 board
   - Go to: https://github.com/users/YOUR_USERNAME/projects → New Project
   - Choose "Table" view and create
3. **GitHub CLI** - Install and authenticate
   ```bash
   # macOS
   brew install gh
   gh auth login

   # Linux
   sudo apt install gh
   gh auth login

   # Windows
   winget install GitHub.cli
   gh auth login
   ```
4. **Git** - Version 2.23+ installed
   ```bash
   git --version  # Should be 2.23 or higher
   ```
5. **Anthropic API Key** - Get your Claude API key
   - Sign up at: https://console.anthropic.com/
   - Create an API key: https://console.anthropic.com/settings/keys

---

## 🚀 Installation (3 Steps)

### Step 1: Clone and Setup

Copy this blueprint into your project:

```bash
# Option A: Add to existing repository
cd your-project
git clone https://github.com/alirezarezvani/claude-code-github-workflow.git .blueprint-temp
cp -r .blueprint-temp/.github/ .
cp -r .blueprint-temp/.claude/ .
cp -r .blueprint-temp/setup/ .
rm -rf .blueprint-temp

# Option B: Start new project with blueprint
git clone https://github.com/alirezarezvani/claude-code-github-workflow.git my-project
cd my-project
```

### Step 2: Configure Secrets

Add required secrets to your repository:

```bash
# Method 1: Via GitHub CLI (Recommended)
gh secret set ANTHROPIC_API_KEY
# Paste your Anthropic API key when prompted

gh secret set PROJECT_URL
# Paste your project board URL (format: https://github.com/users/USERNAME/projects/NUMBER)

# Method 2: Via GitHub UI
# Go to: Settings → Secrets and variables → Actions → New repository secret
# Add ANTHROPIC_API_KEY and PROJECT_URL
```

**Project URL Format**:
- User project: `https://github.com/users/YOUR_USERNAME/projects/1`
- Organization project: `https://github.com/orgs/YOUR_ORG/projects/1`

### Step 3: Bootstrap Repository

Run the bootstrap workflow to set up labels and validate configuration:

```bash
# Run bootstrap workflow
gh workflow run bootstrap.yml

# Check if it succeeded
gh run list --workflow=bootstrap.yml --limit 1
```

**Alternative (GitHub UI)**:
1. Go to: `Actions` tab
2. Select: `Bootstrap Repository`
3. Click: `Run workflow` → `Run workflow`
4. Wait ~30 seconds for completion

---

## 🎯 Your First Automated Workflow (5 Minutes)

### Part 1: Create a Task from Claude Plan (Optional)

If you have a Claude Code plan:

```bash
# Save your plan to a file
cat > plan.json <<'EOF'
{
  "milestone": {
    "title": "My First Feature",
    "description": "Testing the blueprint automation"
  },
  "tasks": [
    {
      "title": "Add welcome message",
      "description": "Create a simple welcome message component",
      "acceptanceCriteria": [
        "Component displays welcome text",
        "Component has proper styling",
        "Tests pass"
      ],
      "priority": "medium",
      "type": "feature",
      "platform": "web"
    }
  ]
}
EOF

# Convert plan to issues
gh workflow run claude-plan-to-issues.yml -f plan_json="$(cat plan.json)"

# Check created issues
gh issue list --label claude-code
```

### Part 2: Create Manual Issue (Easier Start)

Create a simple issue to test the automation:

1. **Go to Issues** → `New Issue`
2. **Choose Template**: "Manual Task"
3. **Fill in Details**:
   - Title: "Add welcome message"
   - Description: "Create a simple welcome message"
   - Type: Feature
   - Priority: Medium
4. **Add Labels**:
   - `claude-code` (required)
   - `status:ready` (required)
   - `type:feature`
   - `platform:web`
5. **Submit** → Branch created automatically! 🎉

### Part 3: Work on the Issue

The workflow automatically creates a branch:

```bash
# Fetch the new branch
git fetch origin

# List branches to find yours
git branch -r | grep "feature/"

# Checkout the branch
git checkout feature/issue-1-add-welcome-message
```

### Part 4: Make Changes

Create a simple change:

```bash
# Create a file
echo "# Welcome to my project!" > WELCOME.md

# Stage changes
git add WELCOME.md

# Option A: Use smart commit command (if Claude Code CLI installed)
# This includes quality checks and secret scanning
/commit-smart

# Option B: Manual commit
git commit -m "feat: add welcome message"
git push origin feature/issue-1-add-welcome-message
```

### Part 5: Create Pull Request

```bash
# Option A: Use PR command (if Claude Code CLI installed)
/create-pr

# Option B: Via GitHub CLI
gh pr create \
  --title "feat: add welcome message" \
  --body "Closes #1

## Summary
Added welcome message to the project.

## Type of Change
- [x] Feature
- [ ] Fix
- [ ] Refactor

## Testing
- [x] Manual testing completed
- [x] Changes reviewed

## Platform
- [x] Web
- [ ] Mobile
- [ ] Fullstack" \
  --base dev
```

### Part 6: Watch the Automation! 🚀

Your PR triggers automatic workflows:

1. **Quality Checks Run** (`pr-into-dev.yml`)
   - ✅ Lint check
   - ✅ Type check
   - ✅ Unit tests
   - ✅ Conventional commit validation
   - ✅ Linked issue check

2. **Issue Status Updates** (`pr-status-sync.yml`)
   - Issue #1 status → "In Review"

3. **View Progress**:
   ```bash
   # Check workflow runs
   gh run list --limit 5

   # Watch specific run
   gh run watch
   ```

4. **Merge When Ready**:
   - All checks pass → Merge PR
   - Issue status → "To Deploy"
   - Branch deleted automatically

5. **Deploy to Production**:
   ```bash
   # Create release PR (dev → main)
   gh pr create --base main --head dev --title "Release v1.0.0"
   ```

6. **After Merge to Main**:
   - Issue #1 automatically closed
   - Status → "Done"
   - GitHub Release created (optional)

---

## ✅ Success! What Just Happened?

You just experienced a complete automated workflow:

```
Issue Created → Branch Created → PR Opened → Quality Checks →
Merge to Dev → Status Updated → Release PR → Merge to Main →
Issue Closed → Done! 🎉
```

All automated with zero manual tracking!

---

## 🐛 Common Issues

### Issue: "gh command not found"

**Problem**: GitHub CLI not installed

**Solution**:
```bash
# macOS
brew install gh

# Linux
sudo apt install gh

# Windows
winget install GitHub.cli

# Verify
gh --version
```

### Issue: "PROJECT_URL not set"

**Problem**: Secret not configured

**Solution**:
```bash
# Set the secret
gh secret set PROJECT_URL
# Enter your project URL: https://github.com/users/USERNAME/projects/1

# Verify it's set
gh secret list | grep PROJECT_URL
```

### Issue: "Workflow failed - ANTHROPIC_API_KEY"

**Problem**: API key not set or invalid

**Solution**:
```bash
# Set or update the API key
gh secret set ANTHROPIC_API_KEY
# Paste your API key when prompted

# Verify
gh secret list | grep ANTHROPIC_API_KEY
```

### Issue: "Branch not created automatically"

**Problem**: Missing required labels

**Solution**:
- Issue must have BOTH labels: `claude-code` AND `status:ready`
- Check labels: `gh issue view 1 --json labels`
- Add missing labels:
  ```bash
  gh issue edit 1 --add-label "claude-code,status:ready"
  ```

### Issue: "Quality checks failing"

**Problem**: Code doesn't pass lint/test/typecheck

**Solution**:
```bash
# Run checks locally before pushing
npm run lint
npm run type-check
npm run test

# Fix issues, then push again
```

### Issue: "Can't create PR - no linked issue"

**Problem**: PR body doesn't reference an issue

**Solution**:
- PR body must include: `Closes #1` or `Fixes #1` or `Resolves #1`
- Edit PR body to add issue reference
- Or use `/create-pr` command which auto-links

### Issue: "Bootstrap workflow failed"

**Problem**: Permissions or configuration issue

**Solution**:
```bash
# Check workflow logs
gh run list --workflow=bootstrap.yml --limit 1
gh run view [RUN_ID]

# Common fixes:
# 1. Ensure GITHUB_TOKEN has proper permissions
# 2. Verify PROJECT_URL is correct
# 3. Check you have admin access to repository
```

---

## 📚 Next Steps

### Learn More

- **[Complete Setup Guide](COMPLETE_SETUP.md)** - Detailed configuration options
- **[Workflows Reference](WORKFLOWS.md)** - Understand all 8 workflows
- **[Commands Reference](COMMANDS.md)** - Master all 8 slash commands
- **[Architecture Guide](ARCHITECTURE.md)** - How everything works together
- **[Troubleshooting](TROUBLESHOOTING.md)** - Comprehensive issue resolution

### Customize Your Setup

- **[Customization Guide](CUSTOMIZATION.md)** - Adapt to your workflow
- Change branching strategy (simple/standard/complex)
- Customize project board status names
- Add mobile support (iOS/Android)
- Configure advanced quality checks

### Join the Community

- **GitHub Issues** - Report bugs or request features
- **GitHub Discussions** - Ask questions and share tips
- **Contributing** - Help improve the blueprint

---

## 💡 Pro Tips

1. **Use Slash Commands** - Install Claude Code CLI for `/commit-smart`, `/create-pr`, `/review-pr`
2. **Project Board** - Keep your board open to watch status updates in real-time
3. **Quality First** - Let quality checks run before requesting reviews
4. **Conventional Commits** - Follow the format: `type(scope): description`
5. **Link Issues** - Always link PRs to issues for automatic tracking
6. **Draft PRs** - Use draft PRs for work-in-progress (keeps issue in "In Progress")

---

## 🎉 Congratulations!

You've successfully set up a production-ready GitHub Actions workflow with Claude Code! Your repository now has:

- ✅ Automated issue-to-branch workflow
- ✅ Comprehensive quality gates
- ✅ Bidirectional project board sync
- ✅ Automatic deployment tracking
- ✅ AI-powered code reviews
- ✅ Emergency kill switch

**Welcome to world-class automation!** 🚀

---

**Questions?** Check the [Troubleshooting Guide](TROUBLESHOOTING.md) or open an issue.

**Ready for more?** Read the [Complete Setup Guide](COMPLETE_SETUP.md) for advanced features.
