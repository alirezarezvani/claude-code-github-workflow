# /kill-switch - Emergency Workflow Disable

**Description**: Emergency mechanism to immediately disable all GitHub Actions workflows. Use only in critical situations (infinite loops, runaway costs, security incidents).

**Usage**: `/kill-switch [enable|disable|status]`

**Estimated Time**: <10 seconds

---

## ⚠️  WARNING

**This is an EMERGENCY FEATURE. Use with extreme caution.**

**When to use**:
- ✅ Workflow infinite loops consuming GitHub Actions minutes
- ✅ Security incident requiring immediate workflow suspension
- ✅ Critical bug in workflows causing repository damage
- ✅ Runaway costs from excessive workflow runs

**When NOT to use**:
- ❌ Normal debugging (use workflow cancel instead)
- ❌ Minor workflow issues
- ❌ Temporary CI failures

---

## Workflow

You will help the user immediately enable or disable the workflow kill switch.

### Step 1: Check Current Status

**Check if killswitch file exists**:
```bash
if [ -f ".github/WORKFLOW_KILLSWITCH" ]; then
  KILLSWITCH_STATUS="ENABLED"
  KILLSWITCH_REASON=$(cat .github/WORKFLOW_KILLSWITCH 2>/dev/null || echo "No reason provided")
else
  KILLSWITCH_STATUS="DISABLED"
  KILLSWITCH_REASON="N/A"
fi
```

**Display current status**:
```
🚨 Workflow Kill Switch
=======================

Current Status: $KILLSWITCH_STATUS

$([ "$KILLSWITCH_STATUS" = "ENABLED" ] && echo "🔴 All workflows are currently DISABLED
Reason: $KILLSWITCH_REASON" || echo "🟢 All workflows are currently ACTIVE")
```

---

### Step 2: Determine Action

**If no argument provided, ask user**:
```
What action would you like to take?

1. enable   - DISABLE all workflows (emergency stop)
2. disable  - RE-ENABLE all workflows (normal operation)
3. status   - Show current status only

Enter 1, 2, or 3:
```

**Map selection**:
```bash
case $SELECTION in
  1|enable)
    ACTION="enable"
    ;;
  2|disable)
    ACTION="disable"
    ;;
  3|status)
    ACTION="status"
    ;;
  *)
    echo "❌ Invalid selection"
    exit 1
    ;;
esac
```

**If argument provided, use it**:
```bash
ACTION=${1:-prompt}  # Use first argument or prompt
```

---

### Step 3: Status Action

**If action is 'status'**:
```
📊 Kill Switch Status
=====================

Status: $KILLSWITCH_STATUS
File: .github/WORKFLOW_KILLSWITCH

$([ "$KILLSWITCH_STATUS" = "ENABLED" ] && echo "🔴 Workflows DISABLED since:
$(git log -1 --format='%ai' -- .github/WORKFLOW_KILLSWITCH 2>/dev/null || echo 'Unknown')

Reason: $KILLSWITCH_REASON

To re-enable workflows:
  /kill-switch disable" || echo "🟢 All workflows ACTIVE

Normal operation. No action needed.

To disable in emergency:
  /kill-switch enable")
```

**Exit**

---

### Step 4: Enable Kill Switch (Disable Workflows)

**If action is 'enable' and already enabled**:
```
ℹ️  Kill switch is already ENABLED

Workflows are already disabled.

Status: $KILLSWITCH_STATUS
Reason: $KILLSWITCH_REASON

To change reason or re-apply:
  /kill-switch disable
  /kill-switch enable
```

**Exit**

**If action is 'enable' and currently disabled**:

**Ask for reason**:
```
🚨 ENABLE KILL SWITCH
=====================

This will IMMEDIATELY DISABLE all GitHub Actions workflows.

Enter reason for disabling workflows:
(e.g., "Infinite loop in PR checks", "Security incident", "Runaway costs")

Reason:
```

**Confirm action**:
```
⚠️  CONFIRMATION REQUIRED
========================

You are about to DISABLE all workflows.

Reason: $REASON

This action will:
  ✓ Create .github/WORKFLOW_KILLSWITCH file
  ✓ Commit and push immediately (bypassing hooks)
  ✓ Stop all running workflows
  ✓ Prevent new workflow runs

Are you absolutely sure? (yes/no):
```

**Require typing 'yes'** (not just 'y'):
```bash
if [ "$CONFIRMATION" != "yes" ]; then
  echo ""
  echo "Kill switch NOT enabled. Operation cancelled."
  exit 0
fi
```

**Create killswitch file**:
```bash
cat > .github/WORKFLOW_KILLSWITCH << EOF
WORKFLOW KILL SWITCH ENABLED

All GitHub Actions workflows are currently disabled.

Reason: $REASON
Enabled by: $USER
Enabled at: $(date '+%Y-%m-%d %H:%M:%S %Z')

To re-enable workflows:
1. Delete this file: rm .github/WORKFLOW_KILLSWITCH
2. Commit: git commit -m "chore: re-enable workflows"
3. Push: git push origin $(git branch --show-current)

Or use: /kill-switch disable
EOF

echo ""
echo "✅ Kill switch file created"
```

**Commit and push immediately**:
```bash
echo "🔒 Committing kill switch..."

git add .github/WORKFLOW_KILLSWITCH

git commit --no-verify -m "🚨 EMERGENCY: Enable workflow kill switch

Reason: $REASON

All workflows are now disabled until further notice."

echo "📤 Pushing to remote (bypassing hooks)..."

CURRENT_BRANCH=$(git branch --show-current)
git push origin "$CURRENT_BRANCH" --no-verify

echo ""
echo "✅ Kill switch ENABLED and pushed to remote"
```

**Stop running workflows** (optional):
```
Stop all currently running workflows? (y/n):
```

**If 'y'**:
```bash
echo "🛑 Cancelling running workflows..."

# Get all running workflow runs
RUNNING_RUNS=$(gh run list --status in_progress --json databaseId --jq '.[].databaseId')

if [ -z "$RUNNING_RUNS" ]; then
  echo "   No running workflows to cancel"
else
  for run_id in $RUNNING_RUNS; do
    if gh run cancel "$run_id"; then
      echo "   ✅ Cancelled run #$run_id"
    else
      echo "   ⚠️  Failed to cancel run #$run_id"
    fi
  done
fi
```

**Display success**:
```
🚨 KILL SWITCH ENABLED
======================

All workflows are now DISABLED.

Status: ENABLED
Reason: $REASON
File: .github/WORKFLOW_KILLSWITCH

Effects:
  🔴 All workflow runs will immediately exit
  🔴 New workflow runs will be skipped
  🔴 PR checks will show as "skipped"
  🔴 Automated deployments are halted

Next Steps:
  1. Investigate and fix the issue
  2. Test fixes on a feature branch
  3. Re-enable workflows: /kill-switch disable

Monitor status:
  gh run list --limit 5

---

Kill switch enabled at $(date '+%Y-%m-%d %H:%M:%S')
```

---

### Step 5: Disable Kill Switch (Re-enable Workflows)

**If action is 'disable' and already disabled**:
```
ℹ️  Kill switch is already DISABLED

Workflows are currently active.

Status: ENABLED
Normal operation.

No action needed.
```

**Exit**

**If action is 'disable' and currently enabled**:

**Show current status**:
```
🟢 RE-ENABLE WORKFLOWS
======================

Current kill switch status:
  Status: ENABLED
  Reason: $KILLSWITCH_REASON

This will RE-ENABLE all GitHub Actions workflows.
```

**Confirm action**:
```
Re-enable all workflows? (y/n):
```

**If 'n'**: Exit with "Operation cancelled."

**If 'y'**, proceed:

**Remove killswitch file**:
```bash
echo "🗑️  Removing kill switch file..."

rm .github/WORKFLOW_KILLSWITCH

echo "✅ Kill switch file removed"
```

**Commit and push**:
```bash
echo "💾 Committing changes..."

git add .github/WORKFLOW_KILLSWITCH

git commit --no-verify -m "chore: disable workflow kill switch

Workflows re-enabled. Normal operation resumed."

echo "📤 Pushing to remote..."

CURRENT_BRANCH=$(git branch --show-current)
git push origin "$CURRENT_BRANCH"

echo ""
echo "✅ Kill switch DISABLED and pushed to remote"
```

**Verify workflows are enabled**:
```bash
echo ""
echo "🔍 Verifying workflows..."

# Check recent workflow runs
RECENT_RUNS=$(gh run list --limit 1 --json conclusion,status,createdAt --jq '.[0]')

if [ -n "$RECENT_RUNS" ]; then
  echo "   ✅ Workflows are responding"
else
  echo "   ⚠️  No recent workflow activity"
fi
```

**Display success**:
```
🟢 WORKFLOWS RE-ENABLED
=======================

All workflows are now ACTIVE.

Status: DISABLED
Normal operation resumed.

Workflows will:
  ✅ Run on push/PR events
  ✅ Execute quality checks
  ✅ Perform automated deployments
  ✅ Sync project board

Monitor workflows:
  gh run list --limit 10

Test workflow:
  git commit --allow-empty -m "test: verify workflows active"
  git push

---

Kill switch disabled at $(date '+%Y-%m-%d %H:%M:%S')
```

---

## Killswitch File Format

**File**: `.github/WORKFLOW_KILLSWITCH`

**Content**:
```
WORKFLOW KILL SWITCH ENABLED

All GitHub Actions workflows are currently disabled.

Reason: [User-provided reason]
Enabled by: [Username]
Enabled at: [Timestamp]

To re-enable workflows:
1. Delete this file: rm .github/WORKFLOW_KILLSWITCH
2. Commit: git commit -m "chore: re-enable workflows"
3. Push: git push origin [branch]

Or use: /kill-switch disable
```

---

## Workflow Integration

**All workflows MUST check for killswitch at the start**:

```yaml
name: Example Workflow

on: [push, pull_request]

jobs:
  check-killswitch:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Check Kill Switch
        run: |
          if [ -f ".github/WORKFLOW_KILLSWITCH" ]; then
            echo "🚨 KILL SWITCH ENABLED - Workflow disabled"
            cat .github/WORKFLOW_KILLSWITCH
            echo ""
            echo "All workflows are currently disabled."
            echo "This workflow will exit immediately."
            exit 1
          fi

  actual-work:
    needs: check-killswitch
    runs-on: ubuntu-latest
    steps:
      - name: Do Work
        run: echo "Workflow is active"
```

**Alternative: Composite action**:
```yaml
- name: Check Kill Switch
  uses: ./.github/actions/killswitch-check
```

---

## Error Handling

### Uncommitted Changes
```
❌ Cannot enable kill switch

Working directory has uncommitted changes:
[list changes]

Commit or stash changes first:
  git add .
  git commit -m "your message"

Then retry: /kill-switch enable
```

### Not on Main Branch
```
⚠️  Warning: Not on main branch

Current branch: $CURRENT_BRANCH

Kill switch should typically be enabled on main/dev branch
to affect all workflows across PRs.

Continue anyway? (y/n):
```

### Push Failed
```
❌ Failed to push kill switch to remote

Error: [error message]

Possible causes:
  • Branch protection preventing push
  • Network issues
  • Authentication problems

Manual steps:
  1. Kill switch file created locally
  2. Push manually: git push origin $(git branch --show-current)
  3. Or retry: /kill-switch enable
```

### File Already Exists (edge case)
```
⚠️  Kill switch file already exists but not tracked

Found: .github/WORKFLOW_KILLSWITCH
Git status: untracked or modified

Actions:
1. Stage and commit existing file
2. Overwrite with new file
3. Cancel operation

Enter 1, 2, or 3:
```

---

## Use Case Examples

### Example 1: Infinite Loop Detection
```
User notices:
  • GitHub Actions minutes rapidly increasing
  • Same workflow running repeatedly
  • Repository generating 100+ workflow runs/hour

Action:
  /kill-switch enable
  Reason: "Infinite loop in PR status sync workflow"

Result:
  • All workflows immediately stop
  • Investigate pr-status-sync.yml
  • Fix infinite loop condition
  • Test fix on feature branch
  • /kill-switch disable
```

### Example 2: Security Incident
```
User discovers:
  • Compromised API key in workflow
  • Unauthorized access to secrets
  • Suspicious workflow runs

Action:
  /kill-switch enable
  Reason: "Security incident - compromised credentials"

Result:
  • All workflows halted
  • Rotate all secrets immediately
  • Audit workflow history
  • Fix security issues
  • /kill-switch disable after verification
```

### Example 3: Runaway Costs
```
User receives alert:
  • GitHub Actions minutes nearing limit
  • Unexpected high usage
  • Complex workflows running excessively

Action:
  /kill-switch enable
  Reason: "Excessive GitHub Actions usage"

Result:
  • Workflows stopped
  • Analyze workflow efficiency
  • Optimize expensive workflows
  • Implement better caching
  • /kill-switch disable
```

---

## Testing Kill Switch

### Manual Test
```bash
# Enable kill switch
/kill-switch enable

# Verify workflows exit
git commit --allow-empty -m "test: verify killswitch"
git push

# Check workflow run
gh run list --limit 1
# Should show: "Check Kill Switch - failure"

# Disable kill switch
/kill-switch disable

# Verify workflows active
git commit --allow-empty -m "test: verify workflows active"
git push

# Check workflow run
gh run list --limit 1
# Should show: "workflow name - success"
```

### Automated Test
```yaml
# .github/workflows/test-killswitch.yml
name: Test Kill Switch

on: workflow_dispatch

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Test Kill Switch Detection
        run: |
          # Create killswitch file
          mkdir -p .github
          echo "TEST KILLSWITCH" > .github/WORKFLOW_KILLSWITCH

          # Run check (should exit 1)
          if [ -f ".github/WORKFLOW_KILLSWITCH" ]; then
            echo "✅ Kill switch detected correctly"
            exit 1
          else
            echo "❌ Kill switch NOT detected"
            exit 0
          fi
```

---

## Notes

- **Immediate Effect**: Takes effect on next workflow run (usually <30 seconds)
- **Repository-Wide**: Affects ALL workflows across all branches
- **Bypass Hooks**: Uses `--no-verify` to bypass pre-commit/pre-push hooks
- **Manual Override**: Can be disabled manually by deleting file and pushing
- **Audit Trail**: Git history tracks when and why killswitch was used
- **Reversible**: Can be disabled instantly with `/kill-switch disable`

---

## Best Practices

1. **Always provide clear reason** when enabling kill switch
2. **Communicate with team** before enabling (if time permits)
3. **Test workflows** on feature branch before re-enabling
4. **Document incident** after disabling kill switch
5. **Review workflow logs** to understand what triggered need for kill switch

---

## Testing Checklist

- [ ] Test enable kill switch
- [ ] Verify workflow runs exit immediately
- [ ] Test disable kill switch
- [ ] Verify workflows resume normally
- [ ] Test status command
- [ ] Test with uncommitted changes (should error)
- [ ] Test double-enable (should notify already enabled)
- [ ] Test double-disable (should notify already disabled)
- [ ] Verify git history records enable/disable actions
- [ ] Test canceling running workflows

---

**Author**: Alireza Rezvani
**Date**: 2025-11-06
**Estimated Time**: 30 minutes implementation
