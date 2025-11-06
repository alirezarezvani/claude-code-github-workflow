# /create-pr - Create Pull Request with Proper Linking

**Description**: Creates a pull request with automatic issue linking, quality check validation, and proper labels.

**Usage**: `/create-pr`

**Estimated Time**: 1-2 minutes

---

## Workflow

You will guide the user through creating a well-formed pull request with proper issue linking and labels.

### Step 1: Detect Current Branch

**Get current branch**:
```bash
CURRENT_BRANCH=$(git branch --show-current)
```

**Validate branch name**:
```bash
# Check if branch follows naming convention
if [[ ! "$CURRENT_BRANCH" =~ ^(feature|fix|hotfix|refactor|test|docs)/ ]]; then
  echo "⚠️  Warning: Branch name doesn't follow convention"
  echo "   Current: $CURRENT_BRANCH"
  echo "   Expected: feature/*, fix/*, hotfix/*, etc."
  echo ""
fi
```

**Display**:
```
📝 Create Pull Request
======================

Current branch: $CURRENT_BRANCH
```

**Check if branch is pushed**:
```bash
if ! git ls-remote --heads origin "$CURRENT_BRANCH" | grep -q "$CURRENT_BRANCH"; then
  echo "⚠️  Branch not pushed to remote"
  echo ""
  echo "Push now? (y/n):"
  read PUSH_NOW

  if [ "$PUSH_NOW" = "y" ]; then
    git push -u origin "$CURRENT_BRANCH"
  else
    echo "❌ Cannot create PR without pushing branch"
    exit 1
  fi
fi
```

---

### Step 2: Determine Target Branch

**Get branching strategy** (detect from repository):
```bash
# Check which branches exist
HAS_DEV=$(git ls-remote --heads origin dev | grep -q dev && echo "true" || echo "false")
HAS_STAGING=$(git ls-remote --heads origin staging | grep -q staging && echo "true" || echo "false")
```

**Suggest target branch**:
```bash
# Default suggestion based on strategy
if [ "$CURRENT_BRANCH" = "hotfix/"* ] && [ "$HAS_STAGING" = "true" ]; then
  SUGGESTED_TARGET="staging"  # Hotfixes go to staging in complex strategy
elif [ "$HAS_DEV" = "true" ]; then
  SUGGESTED_TARGET="dev"  # Standard strategy
else
  SUGGESTED_TARGET="main"  # Simple strategy
fi
```

**Ask user for target**:
```
Target branch [default: $SUGGESTED_TARGET]:

Available branches:
  • main (production)
${HAS_DEV:+  • dev (development)}
${HAS_STAGING:+  • staging (staging)}

Enter target branch or press Enter for default:
```

**Validate target exists**:
```bash
if ! git ls-remote --heads origin "$TARGET_BRANCH" | grep -q "$TARGET_BRANCH"; then
  echo "❌ Target branch '$TARGET_BRANCH' does not exist"
  exit 1
fi
```

---

### Step 3: Check for Unpushed Commits

**Compare with remote**:
```bash
COMMITS_AHEAD=$(git rev-list --count origin/$TARGET_BRANCH..$CURRENT_BRANCH)
```

**If commits ahead**:
```
ℹ️  Commits ahead of $TARGET_BRANCH: $COMMITS_AHEAD

Recent commits:
```

**Show recent commits**:
```bash
git log origin/$TARGET_BRANCH..$CURRENT_BRANCH --oneline --max-count=5
```

---

### Step 4: Validate Quality Checks

**Display**:
```
🔍 Checking quality gates...
```

**Run quick quality checks**:
```bash
QUALITY_PASSED=true

# Check 1: Lint
if command -v npm &> /dev/null && [ -f "package.json" ]; then
  echo "   • Running lint..."
  if npm run lint > /dev/null 2>&1; then
    echo "   ✅ Lint passed"
  else
    echo "   ❌ Lint failed"
    QUALITY_PASSED=false
  fi
fi

# Check 2: Type check
if [ -f "tsconfig.json" ]; then
  echo "   • Running type check..."
  if npm run type-check > /dev/null 2>&1 || npm run typecheck > /dev/null 2>&1 || npx tsc --noEmit > /dev/null 2>&1; then
    echo "   ✅ Type check passed"
  else
    echo "   ❌ Type check failed"
    QUALITY_PASSED=false
  fi
fi

# Check 3: Tests (optional)
echo ""
echo "Run tests before creating PR? (y/n) [default: n]:"
read RUN_TESTS

if [ "$RUN_TESTS" = "y" ]; then
  echo "   • Running tests..."
  if npm test > /dev/null 2>&1; then
    echo "   ✅ Tests passed"
  else
    echo "   ❌ Tests failed"
    QUALITY_PASSED=false
  fi
fi
```

**If quality checks failed**:
```
❌ Quality checks failed!

You can:
1. Fix issues and retry
2. Create PR anyway (not recommended)
3. Cancel

Enter 1, 2, or 3:
```

**If option 1**: Exit with message to fix and re-run
**If option 2**: Continue with warning
**If option 3**: Exit

---

### Step 5: Extract Related Issue Numbers

**Try to extract from branch name**:
```bash
# Extract issue number from branch name
# Format: feature/issue-123-description
if [[ "$CURRENT_BRANCH" =~ issue-([0-9]+) ]]; then
  ISSUE_NUMBER="${BASH_REMATCH[1]}"
  echo "📌 Detected issue from branch name: #$ISSUE_NUMBER"
fi
```

**Ask for issue numbers**:
```
Link issues (comma-separated, e.g., 123,456):
${ISSUE_NUMBER:+[default: $ISSUE_NUMBER]}

Issues:
```

**Validate issues exist**:
```bash
IFS=',' read -ra ISSUES <<< "$ISSUE_NUMBERS"

for issue in "${ISSUES[@]}"; do
  issue=$(echo "$issue" | tr -d ' ')  # Trim whitespace

  if ! gh issue view "$issue" > /dev/null 2>&1; then
    echo "⚠️  Issue #$issue not found"
    echo "Continue anyway? (y/n):"
    read CONTINUE
    [ "$CONTINUE" != "y" ] && exit 1
  fi
done
```

**Display linked issues**:
```
🔗 Linked Issues:
```

**Show issue titles**:
```bash
for issue in "${ISSUES[@]}"; do
  issue=$(echo "$issue" | tr -d ' ')
  ISSUE_TITLE=$(gh issue view "$issue" --json title --jq '.title')
  echo "   • Issue #$issue: $ISSUE_TITLE"
done
```

---

### Step 6: Generate PR Title

**Analyze commits for type**:
```bash
# Get commit messages since target branch
COMMIT_MESSAGES=$(git log origin/$TARGET_BRANCH..$CURRENT_BRANCH --pretty=format:"%s")

# Detect conventional commit type from most recent commits
if echo "$COMMIT_MESSAGES" | grep -qE "^feat"; then
  SUGGESTED_TYPE="feat"
elif echo "$COMMIT_MESSAGES" | grep -qE "^fix"; then
  SUGGESTED_TYPE="fix"
elif echo "$COMMIT_MESSAGES" | grep -qE "^docs"; then
  SUGGESTED_TYPE="docs"
elif echo "$COMMIT_MESSAGES" | grep -qE "^refactor"; then
  SUGGESTED_TYPE="refactor"
elif echo "$COMMIT_MESSAGES" | grep -qE "^test"; then
  SUGGESTED_TYPE="test"
else
  # Default based on branch type
  case "$CURRENT_BRANCH" in
    feature/*) SUGGESTED_TYPE="feat" ;;
    fix/*) SUGGESTED_TYPE="fix" ;;
    hotfix/*) SUGGESTED_TYPE="fix" ;;
    refactor/*) SUGGESTED_TYPE="refactor" ;;
    test/*) SUGGESTED_TYPE="test" ;;
    docs/*) SUGGESTED_TYPE="docs" ;;
    *) SUGGESTED_TYPE="feat" ;;
  esac
fi
```

**Generate title from issue**:
```bash
if [ -n "$ISSUE_NUMBER" ]; then
  ISSUE_TITLE=$(gh issue view "$ISSUE_NUMBER" --json title --jq '.title')
  SUGGESTED_TITLE="$SUGGESTED_TYPE: ${ISSUE_TITLE,,}"  # Lowercase
else
  # Generate from branch name
  BRANCH_DESC=$(echo "$CURRENT_BRANCH" | sed -E 's/^[^/]+\/(issue-[0-9]+-)?//' | tr '-' ' ')
  SUGGESTED_TITLE="$SUGGESTED_TYPE: $BRANCH_DESC"
fi
```

**Ask for PR title**:
```
PR Title [suggested]:
  $SUGGESTED_TITLE

Press Enter to use suggested, or type custom title:
```

**Validate title**:
- Follows conventional commit format
- Not too long (<72 characters preferred)

---

### Step 7: Generate PR Body

**Create PR body from template**:
```bash
cat > /tmp/pr-body.md << EOF
## Summary
[Provide brief description of changes]

## Type of Change
- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] 💥 Breaking change
- [ ] 📝 Documentation update
- [ ] 🔧 Configuration change
- [ ] ♻️ Code refactoring

## Related Issues
$(for issue in "${ISSUES[@]}"; do
  issue=$(echo "$issue" | tr -d ' ')
  echo "Closes #$issue"
done)

## Changes Made
$(git log origin/$TARGET_BRANCH..$CURRENT_BRANCH --pretty=format:"- %s")

## Platform
- [ ] 🌐 Web
- [ ] 📱 Mobile (iOS)
- [ ] 📱 Mobile (Android)
- [ ] 🔧 Infrastructure/DevOps

## Testing
### Test Coverage
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

### Manual Testing Steps
1.
2.
3.

## Code Quality Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] All CI/CD checks passing

## Breaking Changes
Has Breaking Changes: No

## Additional Context
[Add any additional context here]
EOF
```

**Ask to customize**:
```
📝 PR body generated

Review/edit PR body? (y/n) [default: n]:
```

**If 'y'**: Open in editor:
```bash
${EDITOR:-vim} /tmp/pr-body.md
```

---

### Step 8: Determine Labels

**Auto-detect labels based on**:
- Branch name (type)
- Changed files (platform)
- Issue labels (if linked)

```bash
LABELS=()

# Type labels
case "$CURRENT_BRANCH" in
  feature/*) LABELS+=("type:feature") ;;
  fix/*) LABELS+=("type:fix") ;;
  hotfix/*) LABELS+=("type:hotfix") ;;
  refactor/*) LABELS+=("type:refactor") ;;
  test/*) LABELS+=("type:test") ;;
  docs/*) LABELS+=("type:docs") ;;
esac

# Platform labels (detect from changed files)
CHANGED_FILES=$(git diff origin/$TARGET_BRANCH...$CURRENT_BRANCH --name-only)

if echo "$CHANGED_FILES" | grep -qE "^(mobile|ios|android)/"; then
  LABELS+=("platform:mobile")
elif echo "$CHANGED_FILES" | grep -qE "^(api|server|backend)/"; then
  LABELS+=("platform:fullstack")
else
  LABELS+=("platform:web")
fi

# Copy priority from linked issue
if [ -n "$ISSUE_NUMBER" ]; then
  ISSUE_LABELS=$(gh issue view "$ISSUE_NUMBER" --json labels --jq '.labels[].name')
  if echo "$ISSUE_LABELS" | grep -q "priority:"; then
    PRIORITY_LABEL=$(echo "$ISSUE_LABELS" | grep "priority:" | head -1)
    LABELS+=("$PRIORITY_LABEL")
  fi
fi
```

**Display labels**:
```
🏷️  Labels to apply:
$(printf "   • %s\n" "${LABELS[@]}")

Add more labels? (y/n):
```

---

### Step 9: Create Pull Request

**Create PR using gh CLI**:
```bash
gh pr create \
  --base "$TARGET_BRANCH" \
  --head "$CURRENT_BRANCH" \
  --title "$PR_TITLE" \
  --body-file /tmp/pr-body.md \
  ${LABELS:+--label "$(IFS=,; echo "${LABELS[*]}")"} \
  --web
```

**Note**: `--web` flag opens PR in browser

**Alternative without --web** (to capture URL):
```bash
PR_URL=$(gh pr create \
  --base "$TARGET_BRANCH" \
  --head "$CURRENT_BRANCH" \
  --title "$PR_TITLE" \
  --body-file /tmp/pr-body.md \
  ${LABELS:+--label "$(IFS=,; echo "${LABELS[*]}")"})
```

**Get PR number**:
```bash
PR_NUMBER=$(gh pr list --head "$CURRENT_BRANCH" --json number --jq '.[0].number')
```

---

### Step 10: Display Success Summary

**Show success message**:
```
✅ Pull Request Created!
========================

PR #$PR_NUMBER: $PR_TITLE

   From: $CURRENT_BRANCH
   To:   $TARGET_BRANCH

   URL: $PR_URL

Linked Issues:
$(for issue in "${ISSUES[@]}"; do
  issue=$(echo "$issue" | tr -d ' ')
  echo "   • #$issue"
done)

Labels Applied:
$(printf "   • %s\n" "${LABELS[@]}")

---

🚀 Next Steps:

1. Automated checks will run:
   • Lint
   • Type check
   • Unit tests
   • Quality gates

2. PR will auto-update issue status to "In Review"

3. Once approved and merged:
   • Issues will move to "To Deploy"
   • Source branch will be deleted automatically

4. Monitor PR status:
   gh pr view $PR_NUMBER
   gh pr checks $PR_NUMBER

---

PR created successfully at $(date '+%Y-%m-%d %H:%M:%S')
```

**Cleanup**:
```bash
rm -f /tmp/pr-body.md
```

---

## Error Handling

### Not on a Feature Branch
```
❌ Cannot create PR from this branch

Current branch: $CURRENT_BRANCH

You can only create PRs from:
  • feature/* branches
  • fix/* branches
  • hotfix/* branches
  • Other working branches

You cannot create PRs from:
  • main
  • dev
  • staging

Switch to a feature branch first:
  git checkout -b feature/your-feature
```

### No Commits Ahead
```
ℹ️  No new commits

Current branch is up-to-date with $TARGET_BRANCH.

Make some changes first:
  git status
  git log origin/$TARGET_BRANCH..$CURRENT_BRANCH
```

### PR Already Exists
```
ℹ️  Pull request already exists

PR #$EXISTING_PR: $EXISTING_PR_TITLE
URL: $EXISTING_PR_URL

You can:
  • Update the PR: /create-pr --update
  • View the PR: gh pr view $EXISTING_PR
  • Close old PR and create new: gh pr close $EXISTING_PR
```

### No Linked Issues
```
⚠️  No issues linked

Creating PR without linked issues will:
  • Skip automated status tracking
  • Not close issues automatically
  • Require manual project board updates

Continue anyway? (y/n):
```

---

## Examples

### Feature PR
```
Branch: feature/issue-123-add-user-auth
Target: dev
Issues: #123
Title: feat: add user authentication
Labels: type:feature, platform:fullstack, priority:high
```

### Fix PR
```
Branch: fix/issue-456-null-pointer
Target: dev
Issues: #456
Title: fix: resolve null pointer in login
Labels: type:fix, platform:web, priority:medium
```

### Hotfix PR
```
Branch: hotfix/critical-security-issue
Target: staging  # or main in simple strategy
Issues: #789
Title: fix: patch security vulnerability
Labels: type:hotfix, platform:fullstack, priority:critical
```

---

## Notes

- **Enforces linked issues**: Required for automation
- **Quality checks**: Validates before creating PR
- **Auto-labels**: Intelligent label detection
- **Template filled**: Uses repository PR template
- **Opens browser**: Convenient for immediate review

---

## Testing Checklist

- [ ] Test from feature branch
- [ ] Test from fix branch
- [ ] Test from main branch (should error)
- [ ] Test with quality checks passing
- [ ] Test with quality checks failing
- [ ] Test with single linked issue
- [ ] Test with multiple linked issues
- [ ] Test without linked issues (should warn)
- [ ] Test with existing PR (should detect)
- [ ] Test label auto-detection
- [ ] Test PR body generation

---

**Author**: Alireza Rezvani
**Date**: 2025-11-06
**Estimated Time**: 1 hour implementation
