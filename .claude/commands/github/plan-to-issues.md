# /plan-to-issues - Convert Claude Plan to GitHub Issues

**Description**: Converts a Claude Code plan (JSON format) into GitHub issues with proper labels, milestones, and project board integration.

**Usage**:
- `/plan-to-issues <file-path>` - Read plan from file
- `/plan-to-issues` - Prompt for inline JSON

**Max Tasks**: 10 issues per plan (hard limit)

**Estimated Time**: <30 seconds

---

## Workflow

You will convert a Claude Code plan JSON into GitHub issues using the `claude-plan-to-issues` workflow.

### Step 1: Get Plan JSON

**Ask user for input method**:
```
📋 Convert Claude Plan to GitHub Issues
========================================

How would you like to provide the plan?

1. File path (e.g., plan.json)
2. Paste inline JSON

Enter 1 or 2:
```

**If option 1 (File path)**:
```
Enter file path:
```

**Validation**:
- File must exist
- File must be readable
- Read file content: `cat <file-path>`

**If option 2 (Inline JSON)**:
```
Paste your plan JSON (Ctrl+D or Enter twice when done):
```

**Capture multi-line input** until user signals completion.

---

### Step 2: Validate JSON Syntax

**Parse JSON**:
```bash
echo "$PLAN_JSON" | jq empty 2>&1
```

**If invalid JSON**:
```
❌ Invalid JSON syntax

Error: [error message from jq]

Please check your JSON and try again.
```

**Exit with error code 1**

---

### Step 3: Validate Plan Structure

**Check required fields**:

1. **Must have `tasks` array**:
   ```bash
   TASK_COUNT=$(echo "$PLAN_JSON" | jq '.tasks | length')
   ```

2. **Task count must be 1-10**:
   ```
   if [ $TASK_COUNT -eq 0 ]; then
     echo "❌ Plan has no tasks"
     exit 1
   fi

   if [ $TASK_COUNT -gt 10 ]; then
     echo "❌ Too many tasks: $TASK_COUNT (max 10 allowed)"
     echo ""
     echo "Please split your plan into multiple smaller plans."
     exit 1
   fi
   ```

3. **Each task must have required fields**:
   ```bash
   for i in $(seq 0 $((TASK_COUNT - 1))); do
     TITLE=$(echo "$PLAN_JSON" | jq -r ".tasks[$i].title")
     DESC=$(echo "$PLAN_JSON" | jq -r ".tasks[$i].description")

     if [ "$TITLE" == "null" ] || [ -z "$TITLE" ]; then
       echo "❌ Task $((i + 1)): Missing title"
       exit 1
     fi

     if [ "$DESC" == "null" ] || [ -z "$DESC" ]; then
       echo "❌ Task $((i + 1)): Missing description"
       exit 1
     fi
   done
   ```

**Display validation success**:
```
✅ Plan validated successfully
   Tasks: $TASK_COUNT
```

---

### Step 4: Extract Metadata (Optional)

**Check for milestone metadata**:
```bash
MILESTONE_TITLE=$(echo "$PLAN_JSON" | jq -r '.metadata.milestone.title // empty')
MILESTONE_DUE=$(echo "$PLAN_JSON" | jq -r '.metadata.milestone.dueDate // empty')
```

**If milestone found**:
```
📅 Milestone detected: $MILESTONE_TITLE
   Due date: $MILESTONE_DUE
```

---

### Step 5: Show Plan Summary

**Display summary**:
```
📋 Plan Summary
===============

Tasks: $TASK_COUNT

Issues to create:
```

**List each task**:
```bash
for i in $(seq 0 $((TASK_COUNT - 1))); do
  TITLE=$(echo "$PLAN_JSON" | jq -r ".tasks[$i].title")
  TYPE=$(echo "$PLAN_JSON" | jq -r ".tasks[$i].type // \"feature\"")
  PRIORITY=$(echo "$PLAN_JSON" | jq -r ".tasks[$i].priority // \"medium\"")

  echo "$((i + 1)). [$TYPE] $TITLE (priority: $PRIORITY)"
done
```

**Ask for confirmation**:
```
Create these issues? (y/n):
```

**If 'n'**: Exit with message "Operation cancelled."

---

### Step 6: Save Plan JSON to Temporary File

**Create temporary file**:
```bash
TEMP_FILE=$(mktemp /tmp/claude-plan-XXXXX.json)
echo "$PLAN_JSON" > "$TEMP_FILE"
```

**Display**:
```
💾 Plan saved to: $TEMP_FILE
```

---

### Step 7: Trigger GitHub Workflow

**Get repository info**:
```bash
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')
```

**Trigger workflow with inputs**:
```bash
gh workflow run claude-plan-to-issues.yml \
  -f plan_json="$(cat $TEMP_FILE)" \
  -f milestone_title="$MILESTONE_TITLE" \
  -f milestone_due_date="$MILESTONE_DUE"
```

**Display**:
```
⚙️  Triggering workflow: claude-plan-to-issues
   Repository: $REPO_OWNER/$REPO_NAME
```

**Get workflow run ID** (wait up to 10 seconds for workflow to start):
```bash
sleep 3  # Give workflow time to register

WORKFLOW_RUN_ID=$(gh run list \
  --workflow=claude-plan-to-issues.yml \
  --limit 1 \
  --json databaseId \
  --jq '.[0].databaseId')
```

**If workflow didn't start**:
```
⚠️  Workflow started but run ID not yet available.
   Check workflow status manually:

   gh run list --workflow=claude-plan-to-issues.yml
```

---

### Step 8: Monitor Workflow Execution

**If workflow run ID available, monitor progress**:
```
🔄 Monitoring workflow execution...

   Press Ctrl+C to stop monitoring (workflow will continue)
```

**Watch workflow**:
```bash
gh run watch $WORKFLOW_RUN_ID --interval 5
```

**Capture workflow status**:
```bash
WORKFLOW_STATUS=$(gh run view $WORKFLOW_RUN_ID --json status,conclusion --jq '.status,.conclusion')
```

---

### Step 9: Display Results

**If workflow succeeded**:

1. **Get created issues from workflow logs or summary**:
   ```bash
   gh run view $WORKFLOW_RUN_ID --log | grep -E "Created issue #[0-9]+"
   ```

2. **Extract issue numbers**:
   ```bash
   ISSUE_NUMBERS=$(gh run view $WORKFLOW_RUN_ID --log | \
     grep -oE "#[0-9]+" | \
     tr -d '#' | \
     sort -u)
   ```

3. **Display success message**:
   ```
   ✅ Issues created successfully!
   ================================

   Created Issues:
   ```

4. **List each issue with link**:
   ```bash
   for ISSUE_NUM in $ISSUE_NUMBERS; do
     ISSUE_TITLE=$(gh issue view $ISSUE_NUM --json title --jq '.title')
     ISSUE_URL=$(gh issue view $ISSUE_NUM --json url --jq '.url')
     echo "   • Issue #$ISSUE_NUM: $ISSUE_TITLE"
     echo "     $ISSUE_URL"
   done
   ```

5. **Show project board link**:
   ```bash
   PROJECT_URL=$(gh secret get PROJECT_URL --app actions 2>/dev/null || echo "Not configured")

   if [ "$PROJECT_URL" != "Not configured" ]; then
     echo ""
     echo "📊 View on project board:"
     echo "   $PROJECT_URL"
   fi
   ```

6. **Show next steps**:
   ```

   🚀 Next Steps:

   1. Review issues: gh issue list --label claude-code
   2. Issues will auto-create branches when ready
   3. Start working: git checkout feature/issue-1-...
   ```

**If workflow failed**:
```
❌ Workflow failed

View logs for details:
  gh run view $WORKFLOW_RUN_ID --log

Common issues:
  • Rate limit exceeded (wait a few minutes)
  • Invalid project board URL
  • Missing required secrets (PROJECT_URL, ANTHROPIC_API_KEY)

Try running /blueprint-init to validate setup.
```

---

### Step 10: Cleanup

**Remove temporary file**:
```bash
rm -f "$TEMP_FILE"
```

**Display**:
```
🧹 Cleanup complete
```

---

## Error Handling

### Invalid JSON
```
❌ Invalid JSON syntax

The plan JSON could not be parsed.

Tips:
  • Check for missing commas
  • Validate with: cat plan.json | jq
  • Use a JSON validator online

Example valid structure:
{
  "tasks": [
    {
      "title": "Task title",
      "description": "Task description",
      "type": "feature",
      "platform": "web",
      "priority": "medium",
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2"
      ]
    }
  ],
  "metadata": {
    "milestone": {
      "title": "Sprint 1",
      "dueDate": "2025-12-31"
    }
  }
}
```

### Too Many Tasks
```
❌ Too many tasks: $TASK_COUNT (max 10 allowed)

This limit ensures:
  • Manageable sprint planning
  • Faster workflow execution
  • Better issue tracking

Please split your plan into smaller plans:
  • Group related features
  • Create separate milestones
  • Run /plan-to-issues multiple times
```

### Workflow Not Found
```
❌ Workflow not found: claude-plan-to-issues.yml

This usually means the blueprint is not installed.

Run: /blueprint-init

Or manually check: ls .github/workflows/claude-plan-to-issues.yml
```

### Missing Secrets
```
❌ Required secrets not configured

The workflow requires these secrets:
  • PROJECT_URL - Your GitHub Project board URL
  • ANTHROPIC_API_KEY - Your Claude API key

To configure:
  1. Run: /blueprint-init
  2. Or manually: gh secret set PROJECT_URL
                  gh secret set ANTHROPIC_API_KEY
```

---

## Example Plans

### Simple Plan (3 tasks)
```json
{
  "tasks": [
    {
      "title": "Add user authentication",
      "description": "Implement JWT-based authentication",
      "type": "feature",
      "platform": "fullstack",
      "priority": "high",
      "acceptanceCriteria": [
        "Users can register with email/password",
        "Users can login and receive JWT token",
        "Protected routes verify JWT"
      ]
    },
    {
      "title": "Create user profile page",
      "description": "Display and edit user information",
      "type": "feature",
      "platform": "web",
      "priority": "medium",
      "acceptanceCriteria": [
        "Profile page shows user info",
        "Users can edit their profile",
        "Changes are saved to database"
      ]
    },
    {
      "title": "Add unit tests for auth",
      "description": "Test authentication flow",
      "type": "test",
      "platform": "web",
      "priority": "high",
      "acceptanceCriteria": [
        "Test user registration",
        "Test user login",
        "Test token validation"
      ]
    }
  ],
  "metadata": {
    "milestone": {
      "title": "Auth MVP",
      "dueDate": "2025-12-15"
    }
  }
}
```

### Complex Plan with Dependencies (5 tasks)
```json
{
  "tasks": [
    {
      "title": "Design database schema",
      "description": "Create tables for users and posts",
      "type": "feature",
      "platform": "fullstack",
      "priority": "critical"
    },
    {
      "title": "Implement database migrations",
      "description": "Create migration files",
      "type": "feature",
      "platform": "fullstack",
      "priority": "high",
      "dependencies": [1]
    },
    {
      "title": "Create API endpoints",
      "description": "REST API for CRUD operations",
      "type": "feature",
      "platform": "fullstack",
      "priority": "high",
      "dependencies": [2]
    },
    {
      "title": "Build frontend components",
      "description": "React components for UI",
      "type": "feature",
      "platform": "web",
      "priority": "medium",
      "dependencies": [3]
    },
    {
      "title": "Add integration tests",
      "description": "End-to-end testing",
      "type": "test",
      "platform": "fullstack",
      "priority": "medium",
      "dependencies": [3, 4]
    }
  ]
}
```

---

## Notes

- **Validation is strict**: Ensures workflow will succeed
- **Temporary files**: Cleaned up after execution
- **Monitoring is optional**: User can Ctrl+C and check later
- **Idempotent**: Safe to run multiple times (workflow handles duplicates)

---

## Testing Checklist

- [ ] Test with file path input
- [ ] Test with inline JSON input
- [ ] Test with 1 task
- [ ] Test with 10 tasks (max)
- [ ] Test with 11 tasks (should error)
- [ ] Test with invalid JSON
- [ ] Test with missing required fields
- [ ] Test with milestone
- [ ] Test without milestone
- [ ] Test workflow monitoring
- [ ] Test error handling (workflow failure)

---

**Author**: Alireza Rezvani
**Date**: 2025-11-06
**Estimated Time**: 1 hour implementation
