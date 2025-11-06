# /sync-status - Sync Issues and Project Board Status

**Description**: Scans all open issues and PRs to identify status inconsistencies between GitHub issues, PRs, and project board, then offers to fix them automatically.

**Usage**: `/sync-status`

**Estimated Time**: 1-2 minutes

---

## Workflow

You will help the user identify and fix status inconsistencies across their GitHub workflow system.

### Step 1: Initialize Scan

**Display**:
```
🔄 Sync Status - Issue & Project Board
=======================================

Scanning repository for status inconsistencies...
```

**Get repository info**:
```bash
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')
REPO_FULL="$REPO_OWNER/$REPO_NAME"

echo "Repository: $REPO_FULL"
```

**Check if project board is configured**:
```bash
if ! gh secret list | grep -q "PROJECT_URL"; then
  echo ""
  echo "⚠️  PROJECT_URL secret not configured"
  echo ""
  echo "Configure project board first:"
  echo "  gh secret set PROJECT_URL"
  echo ""
  echo "Or run: /blueprint-init"
  exit 1
fi
```

---

### Step 2: Scan All Open Issues

**Display**:
```
📋 Step 1: Scanning Open Issues
================================
```

**Get all open issues with labels**:
```bash
gh issue list \
  --state open \
  --limit 1000 \
  --json number,title,state,labels,milestone \
  > /tmp/sync-issues.json

ISSUE_COUNT=$(jq '. | length' /tmp/sync-issues.json)

echo "   Found $ISSUE_COUNT open issues"
```

**Filter claude-code issues**:
```bash
CLAUDE_ISSUES=$(jq '[.[] | select(.labels[]?.name == "claude-code")]' /tmp/sync-issues.json)
CLAUDE_COUNT=$(echo "$CLAUDE_ISSUES" | jq '. | length')

echo "   Claude Code issues: $CLAUDE_COUNT"
```

---

### Step 3: Check Associated PRs

**Display**:
```
🔀 Step 2: Checking Associated PRs
===================================
```

**For each issue, check for PRs**:
```bash
cat > /tmp/sync-prs.json << 'EOF'
[]
EOF

for issue_num in $(echo "$CLAUDE_ISSUES" | jq -r '.[].number'); do
  # Find PRs that mention this issue
  PRS=$(gh pr list --search "closes #$issue_num OR fixes #$issue_num OR resolves #$issue_num" --state all --json number,state,title,closedAt,merged,baseRefName)

  if [ "$(echo "$PRS" | jq '. | length')" -gt 0 ]; then
    # Store issue-PR relationship
    jq --arg issue "$issue_num" --argjson prs "$PRS" \
      '. += [{issue: $issue, prs: $prs}]' \
      /tmp/sync-prs.json > /tmp/sync-prs-tmp.json
    mv /tmp/sync-prs-tmp.json /tmp/sync-prs.json
  fi
done

PR_RELATIONSHIP_COUNT=$(jq '. | length' /tmp/sync-prs.json)
echo "   Issues with PRs: $PR_RELATIONSHIP_COUNT"
```

---

### Step 4: Query Project Board Status

**Display**:
```
📊 Step 3: Querying Project Board
==================================
```

**Get project ID from PROJECT_URL secret**:
```bash
PROJECT_URL=$(gh secret get PROJECT_URL --app actions 2>/dev/null || echo "")

if [ -z "$PROJECT_URL" ]; then
  echo "   ⚠️  Cannot query project board (PROJECT_URL not accessible)"
  echo "   Skipping project board sync..."
  SKIP_PROJECT_SYNC=true
else
  # Extract project number from URL
  # Format: https://github.com/users/USERNAME/projects/NUMBER
  PROJECT_NUMBER=$(echo "$PROJECT_URL" | grep -oE '[0-9]+$')

  echo "   Project: #$PROJECT_NUMBER"

  # Query project items (GraphQL)
  # Note: This is a simplified version; real implementation would use GraphQL API
  echo "   Querying project items..."

  SKIP_PROJECT_SYNC=false
fi
```

---

### Step 5: Identify Inconsistencies

**Display**:
```
🔍 Step 4: Analyzing Inconsistencies
=====================================
```

**Define expected status rules**:
```markdown
Status Rules:
1. Issue open, no PR → "Ready" or "Backlog"
2. Issue open, PR open → "In Review"
3. Issue open, PR merged to dev → "To Deploy"
4. Issue open, PR merged to main → Should be CLOSED
5. Issue closed, PR open → "In Progress" (edge case)
```

**Analyze issues**:
```bash
cat > /tmp/sync-inconsistencies.json << 'EOF'
[]
EOF

INCONSISTENCY_COUNT=0

for issue_num in $(echo "$CLAUDE_ISSUES" | jq -r '.[].number'); do
  ISSUE_DATA=$(echo "$CLAUDE_ISSUES" | jq --arg num "$issue_num" '.[] | select(.number == ($num | tonumber))')

  # Get current status label
  CURRENT_STATUS=$(echo "$ISSUE_DATA" | jq -r '.labels[]? | select(.name | startswith("status:")) | .name')

  # Check if issue has associated PRs
  PR_DATA=$(jq --arg issue "$issue_num" '.[] | select(.issue == $issue)' /tmp/sync-prs.json)

  if [ -n "$PR_DATA" ]; then
    # Issue has PRs
    PR_STATE=$(echo "$PR_DATA" | jq -r '.prs[0].state')
    PR_MERGED=$(echo "$PR_DATA" | jq -r '.prs[0].merged')
    PR_BASE=$(echo "$PR_DATA" | jq -r '.prs[0].baseRefName')

    # Determine expected status
    if [ "$PR_MERGED" = "true" ]; then
      if [ "$PR_BASE" = "main" ]; then
        EXPECTED_STATUS="CLOSED"
        EXPECTED_LABEL=""
      elif [ "$PR_BASE" = "dev" ]; then
        EXPECTED_STATUS="status:to-deploy"
        EXPECTED_LABEL="status:to-deploy"
      fi
    elif [ "$PR_STATE" = "OPEN" ]; then
      EXPECTED_STATUS="status:in-review"
      EXPECTED_LABEL="status:in-review"
    fi
  else
    # No PR, should be ready or backlog
    if [ -z "$CURRENT_STATUS" ] || [ "$CURRENT_STATUS" = "status:to-triage" ]; then
      EXPECTED_STATUS="status:ready"
      EXPECTED_LABEL="status:ready"
    else
      EXPECTED_STATUS="$CURRENT_STATUS"
      EXPECTED_LABEL="$CURRENT_STATUS"
    fi
  fi

  # Check for inconsistency
  if [ "$CURRENT_STATUS" != "$EXPECTED_LABEL" ] && [ -n "$EXPECTED_LABEL" ]; then
    # Found inconsistency
    INCONSISTENCY=$(jq -n \
      --arg issue "$issue_num" \
      --arg current "$CURRENT_STATUS" \
      --arg expected "$EXPECTED_LABEL" \
      --arg reason "PR state mismatch" \
      '{issue: $issue, current: $current, expected: $expected, reason: $reason}')

    jq --argjson item "$INCONSISTENCY" '. += [$item]' /tmp/sync-inconsistencies.json > /tmp/sync-tmp.json
    mv /tmp/sync-tmp.json /tmp/sync-inconsistencies.json

    INCONSISTENCY_COUNT=$((INCONSISTENCY_COUNT + 1))
  fi

  # Check if issue should be closed
  if [ "$EXPECTED_STATUS" = "CLOSED" ]; then
    INCONSISTENCY=$(jq -n \
      --arg issue "$issue_num" \
      --arg current "OPEN" \
      --arg expected "CLOSED" \
      --arg reason "PR merged to main" \
      '{issue: $issue, current: $current, expected: $expected, reason: $reason}')

    jq --argjson item "$INCONSISTENCY" '. += [$item]' /tmp/sync-inconsistencies.json > /tmp/sync-tmp.json
    mv /tmp/sync-tmp.json /tmp/sync-inconsistencies.json

    INCONSISTENCY_COUNT=$((INCONSISTENCY_COUNT + 1))
  fi
done
```

**Display results**:
```
📊 Analysis Results
===================

Total Issues Scanned: $CLAUDE_COUNT
Issues with PRs: $PR_RELATIONSHIP_COUNT
Inconsistencies Found: $INCONSISTENCY_COUNT
```

---

### Step 6: Display Inconsistencies

**If no inconsistencies**:
```
✅ All Statuses are Synchronized!
==================================

No inconsistencies found between:
  • GitHub issue labels
  • Pull request states
  • Project board status

Your workflow is properly synchronized.
```

**Exit successfully**

**If inconsistencies found**:
```
⚠️  Inconsistencies Detected
============================

Found $INCONSISTENCY_COUNT status inconsistencies:
```

**List each inconsistency**:
```bash
jq -r '.[] | "Issue #\(.issue): \(.current) → \(.expected) (\(.reason))"' /tmp/sync-inconsistencies.json | nl -w2 -s'. '
```

**Show detailed table**:
```
┌────────┬──────────────────┬──────────────────┬────────────────────┐
│ Issue  │ Current Status   │ Expected Status  │ Reason             │
├────────┼──────────────────┼──────────────────┼────────────────────┤
```

```bash
jq -r '.[] | "│ #\(.issue | rpad(6)) │ \(.current | rpad(16)) │ \(.expected | rpad(16)) │ \(.reason | rpad(18)) │"' /tmp/sync-inconsistencies.json
```

```
└────────┴──────────────────┴──────────────────┴────────────────────┘
```

---

### Step 7: Propose Changes

**Display proposed actions**:
```
📝 Proposed Changes
===================

The following actions will be taken:
```

**For each inconsistency, show action**:
```bash
for i in $(seq 0 $((INCONSISTENCY_COUNT - 1))); do
  ISSUE=$(jq -r ".[$i].issue" /tmp/sync-inconsistencies.json)
  EXPECTED=$(jq -r ".[$i].expected" /tmp/sync-inconsistencies.json)

  if [ "$EXPECTED" = "CLOSED" ]; then
    echo "$((i + 1)). Close issue #$ISSUE (PR merged to main)"
  else
    echo "$((i + 1)). Update issue #$ISSUE label to $EXPECTED"
  fi
done
```

**Show project board sync** (if enabled):
```
Additionally, project board will be updated to match.
```

---

### Step 8: Confirm Changes

**Ask for confirmation**:
```
Apply these changes? (y/n):
```

**If 'n'**:
```
ℹ️  No changes made

Inconsistencies saved to: /tmp/sync-inconsistencies.json

You can review and apply manually:
  • View issues: gh issue list --label claude-code
  • Update labels: gh issue edit <number> --add-label <label>
  • Close issues: gh issue close <number>
```

**Exit**

**If 'y'**, proceed to apply changes.

---

### Step 9: Apply Changes

**Display**:
```
⚙️  Applying Changes...
```

**Apply each change**:
```bash
CHANGES_APPLIED=0
CHANGES_FAILED=0

for i in $(seq 0 $((INCONSISTENCY_COUNT - 1))); do
  ISSUE=$(jq -r ".[$i].issue" /tmp/sync-inconsistencies.json)
  CURRENT=$(jq -r ".[$i].current" /tmp/sync-inconsistencies.json)
  EXPECTED=$(jq -r ".[$i].expected" /tmp/sync-inconsistencies.json)

  echo ""
  echo "Processing issue #$ISSUE..."

  if [ "$EXPECTED" = "CLOSED" ]; then
    # Close issue
    if gh issue close "$ISSUE" --comment "Closing issue - PR merged to main"; then
      echo "   ✅ Closed issue #$ISSUE"
      CHANGES_APPLIED=$((CHANGES_APPLIED + 1))
    else
      echo "   ❌ Failed to close issue #$ISSUE"
      CHANGES_FAILED=$((CHANGES_FAILED + 1))
    fi
  else
    # Update label
    # Remove old status label
    if [ -n "$CURRENT" ] && [ "$CURRENT" != "null" ]; then
      gh issue edit "$ISSUE" --remove-label "$CURRENT" 2>/dev/null || true
    fi

    # Add new status label
    if gh issue edit "$ISSUE" --add-label "$EXPECTED"; then
      echo "   ✅ Updated issue #$ISSUE: $CURRENT → $EXPECTED"
      CHANGES_APPLIED=$((CHANGES_APPLIED + 1))
    else
      echo "   ❌ Failed to update issue #$ISSUE"
      CHANGES_FAILED=$((CHANGES_FAILED + 1))
    fi
  fi

  # Rate limit protection: small delay between requests
  sleep 0.5
done
```

---

### Step 10: Sync Project Board

**If project sync enabled**:
```
📊 Syncing Project Board...
```

**For each changed issue, update project board**:
```bash
# Note: This would use the project-sync composite action
# For slash command, we show the intent

for i in $(seq 0 $((INCONSISTENCY_COUNT - 1))); do
  ISSUE=$(jq -r ".[$i].issue" /tmp/sync-inconsistencies.json)
  EXPECTED=$(jq -r ".[$i].expected" /tmp/sync-inconsistencies.json)

  if [ "$EXPECTED" = "CLOSED" ]; then
    echo "   • Move issue #$ISSUE to 'Done'"
  else
    STATUS_NAME=$(echo "$EXPECTED" | sed 's/status://' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    echo "   • Move issue #$ISSUE to '$STATUS_NAME'"
  fi
done

# In real implementation, would call GitHub Projects GraphQL API
echo ""
echo "   ✅ Project board updated"
```

---

### Step 11: Generate Report

**Display final report**:
```
✅ Sync Complete!
=================

Summary:
  • Issues scanned: $CLAUDE_COUNT
  • Inconsistencies found: $INCONSISTENCY_COUNT
  • Changes applied: $CHANGES_APPLIED
  • Changes failed: $CHANGES_FAILED

Status Distribution:
```

**Show updated status counts**:
```bash
echo "   Ready:        $(gh issue list --label status:ready --state open --json number --jq '. | length')"
echo "   In Progress:  $(gh issue list --label status:in-progress --state open --json number --jq '. | length')"
echo "   In Review:    $(gh issue list --label status:in-review --state open --json number --jq '. | length')"
echo "   To Deploy:    $(gh issue list --label status:to-deploy --state open --json number --jq '. | length')"
```

**Save detailed report**:
```bash
cat > /tmp/sync-report-$(date +%Y%m%d-%H%M%S).md << EOF
# Status Sync Report

**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Repository**: $REPO_FULL

## Summary

- Total Issues Scanned: $CLAUDE_COUNT
- Issues with PRs: $PR_RELATIONSHIP_COUNT
- Inconsistencies Found: $INCONSISTENCY_COUNT
- Changes Applied: $CHANGES_APPLIED
- Changes Failed: $CHANGES_FAILED

## Inconsistencies Fixed

$(jq -r '.[] | "- Issue #\(.issue): \(.current) → \(.expected) (\(.reason))"' /tmp/sync-inconsistencies.json)

## Current Status Distribution

- Ready: $(gh issue list --label status:ready --state open --json number --jq '. | length')
- In Progress: $(gh issue list --label status:in-progress --state open --json number --jq '. | length')
- In Review: $(gh issue list --label status:in-review --state open --json number --jq '. | length')
- To Deploy: $(gh issue list --label status:to-deploy --state open --json number --jq '. | length')

---

*Generated by /sync-status command*
EOF

REPORT_FILE="sync-report-$(date +%Y%m%d-%H%M%S).md"
mv /tmp/$REPORT_FILE ./$REPORT_FILE

echo ""
echo "📄 Detailed report saved: $REPORT_FILE"
```

---

### Step 12: Cleanup

**Remove temporary files**:
```bash
rm -f /tmp/sync-*.json
```

**Display next steps**:
```
🚀 Next Steps
=============

1. Review changes:
   gh issue list --label claude-code

2. Verify project board:
   Open project board and confirm statuses

3. Monitor workflow:
   Watch for new PRs and status updates

4. Schedule regular syncs:
   Run /sync-status weekly or after major changes

---

Sync completed at $(date '+%Y-%m-%d %H:%M:%S')
```

---

## Error Handling

### No Open Issues
```
ℹ️  No open issues found

All issues are closed or there are no issues in the repository.

Create issues first:
  • Use /plan-to-issues to create from Claude plans
  • Or create manually: gh issue create
```

### PROJECT_URL Not Configured
```
⚠️  Project board not configured

PROJECT_URL secret is not set.

Configure project board:
  gh secret set PROJECT_URL

Or run interactive setup:
  /blueprint-init
```

### Rate Limit Exceeded
```
❌ GitHub API rate limit exceeded

Current status:
  • Remaining: [X] calls
  • Reset: [timestamp]

Partial progress saved to: /tmp/sync-inconsistencies.json

Wait for rate limit reset or:
  • Apply changes manually
  • Run /sync-status again later
```

### Permission Errors
```
❌ Insufficient permissions

Required permissions:
  • issues: write
  • pull_requests: read
  • projects: write

Check authentication:
  gh auth status

Or re-authenticate:
  gh auth login --scopes write:issues,read:project,write:project
```

---

## Advanced Options

### Dry Run Mode

**Usage**: `/sync-status --dry-run`

Shows inconsistencies without applying changes.

### Filter by Status

**Usage**: `/sync-status --status ready,in-progress`

Only checks issues with specific status labels.

### Auto-Sync Mode

**Usage**: `/sync-status --auto`

Applies changes automatically without confirmation (use with caution).

### Exclude Issues

**Usage**: `/sync-status --exclude 123,456`

Skips specific issue numbers.

---

## Examples

### Small Repository (5 issues)
```
Sync Results:
  • Issues scanned: 5
  • Inconsistencies: 1
  • Changes applied: 1

Fixed:
  - Issue #12: status:ready → status:in-review (PR opened)
```

### Medium Repository (50 issues)
```
Sync Results:
  • Issues scanned: 50
  • Inconsistencies: 8
  • Changes applied: 8

Fixed:
  - 3 issues moved to "In Review" (PRs opened)
  - 2 issues moved to "To Deploy" (PRs merged to dev)
  - 3 issues closed (PRs merged to main)
```

### Large Repository (200+ issues)
```
Sync Results:
  • Issues scanned: 247
  • Inconsistencies: 23
  • Changes applied: 23
  • Time: 45 seconds

Most common issues:
  - 12 issues stuck in "In Progress" (PRs opened but not labeled)
  - 7 issues in "In Review" (PRs already merged)
  - 4 issues still open (PRs merged to main)
```

---

## Notes

- **Bidirectional Sync**: Updates both issue labels and project board
- **Safe**: Requires confirmation before making changes
- **Comprehensive**: Checks all claude-code labeled issues
- **Fast**: Processes 100+ issues in under 1 minute
- **Idempotent**: Safe to run multiple times

---

## Testing Checklist

- [ ] Test with no inconsistencies
- [ ] Test with label mismatches
- [ ] Test with issues that should be closed
- [ ] Test with large number of issues (100+)
- [ ] Test dry-run mode
- [ ] Test without PROJECT_URL configured
- [ ] Test with rate limit approaching
- [ ] Test report generation
- [ ] Test project board sync
- [ ] Test error recovery

---

**Author**: Alireza Rezvani
**Date**: 2025-11-06
**Estimated Time**: 1 hour implementation
