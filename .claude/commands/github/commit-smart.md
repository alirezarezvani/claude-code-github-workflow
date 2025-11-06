# /commit-smart - Smart Commit with Quality Checks

**Description**: Creates a commit with automatic quality checks, secret detection, and conventional commit format.

**Usage**: `/commit-smart`

**Estimated Time**: 1-2 minutes

---

## Workflow

You will guide the user through a safe, smart commit process with automatic quality checks and secret detection.

### Step 1: Check Git Status

**Run git status**:
```bash
git status --porcelain
```

**If no changes**:
```
ℹ️  No changes to commit

Working directory is clean.
```
**Exit successfully**

**If changes found, categorize them**:
```bash
# Staged files
STAGED_FILES=$(git diff --cached --name-only | wc -l)

# Unstaged changes
UNSTAGED_FILES=$(git diff --name-only | wc -l)

# Untracked files
UNTRACKED_FILES=$(git ls-files --others --exclude-standard | wc -l)
```

**Display summary**:
```
📝 Git Status Summary
=====================

Staged files:      $STAGED_FILES
Unstaged changes:  $UNSTAGED_FILES
Untracked files:   $UNTRACKED_FILES
```

---

### Step 2: Review Changed Files

**Show detailed file list**:
```bash
echo ""
echo "📋 Changed Files:"
echo ""

# Staged files (green)
git diff --cached --name-status | while read status file; do
  echo "   ✅ [$status] $file"
done

# Unstaged files (yellow)
git diff --name-status | while read status file; do
  echo "   ⚠️  [$status] $file (not staged)"
done

# Untracked files (gray)
git ls-files --others --exclude-standard | while read file; do
  echo "   📄 [??] $file (untracked)"
done
```

**If there are unstaged or untracked files, ask**:
```
Do you want to stage all changes? (y/n):
```

**If 'y'**: Run `git add -A`

**If 'n'**: Ask if user wants to select files:
```
Select files to stage? (y/n):

If 'y': Show interactive staging menu
If 'n': Continue with currently staged files only
```

**Interactive staging** (if requested):
```bash
# Use git add -p for interactive staging
git add -p
```

---

### Step 3: Scan for Secrets

**Define secret patterns** (basic regex):
```bash
SECRET_PATTERNS=(
  "api[_-]?key"
  "api[_-]?secret"
  "password\s*=\s*[\"'][^\"']+"
  "token\s*=\s*[\"'][^\"']+"
  "secret\s*=\s*[\"'][^\"']+"
  "aws[_-]?access"
  "private[_-]?key"
  "AKIA[0-9A-Z]{16}"  # AWS Access Key
  "sk-[a-zA-Z0-9]{32}"  # Anthropic API key pattern
)
```

**Scan staged files**:
```bash
SECRETS_FOUND=false

for file in $(git diff --cached --name-only); do
  # Skip binary files
  if file "$file" | grep -q "text"; then

    for pattern in "${SECRET_PATTERNS[@]}"; do
      if grep -iE "$pattern" "$file" > /dev/null 2>&1; then
        echo "⚠️  Potential secret found in: $file"
        echo "   Pattern: $pattern"
        grep -iE "$pattern" "$file" | head -3 | sed 's/^/   > /'
        SECRETS_FOUND=true
      fi
    done
  fi
done
```

**If secrets found**:
```
🚨 SECURITY ALERT: Potential Secrets Detected
==============================================

The following files may contain secrets or sensitive data.

⚠️  Files flagged:
[List files with pattern matches]

What would you like to do?
1. Review and fix (recommended)
2. Continue anyway (NOT RECOMMENDED)
3. Cancel commit

Enter 1, 2, or 3:
```

**If option 1**: Show each match and ask to:
- Edit file: `code $file` or `vim $file`
- Unstage file: `git reset HEAD $file`

**If option 2**: Show strong warning and require explicit confirmation:
```
⚠️  WARNING: You are about to commit potential secrets!

This is a SECURITY RISK. Are you absolutely sure?

Type 'I UNDERSTAND THE RISK' to continue:
```

**If option 3**: Exit with message "Commit cancelled."

---

### Step 4: Run Quality Checks

**Display**:
```
🔍 Running Quality Checks...
```

**Check 1: Lint**
```bash
if command -v npm &> /dev/null; then
  echo "   • Running linter..."

  if npm run lint > /dev/null 2>&1; then
    echo "   ✅ Lint passed"
  else
    echo "   ❌ Lint failed"
    LINT_FAILED=true
  fi
else
  echo "   ⏭️  Lint skipped (npm not found)"
fi
```

**Check 2: Type Check**
```bash
if [ -f "tsconfig.json" ]; then
  echo "   • Running type check..."

  if npm run type-check > /dev/null 2>&1 || npm run typecheck > /dev/null 2>&1 || npx tsc --noEmit > /dev/null 2>&1; then
    echo "   ✅ Type check passed"
  else
    echo "   ❌ Type check failed"
    TYPECHECK_FAILED=true
  fi
else
  echo "   ⏭️  Type check skipped (no tsconfig.json)"
fi
```

**Check 3: Unit Tests** (optional - can be slow)
```bash
# Ask user if they want to run tests
echo ""
echo "Run unit tests? (y/n) [default: n]:"
read RUN_TESTS

if [ "$RUN_TESTS" = "y" ]; then
  echo "   • Running unit tests..."

  if npm test > /dev/null 2>&1; then
    echo "   ✅ Tests passed"
  else
    echo "   ❌ Tests failed"
    TESTS_FAILED=true
  fi
fi
```

**If any checks failed**:
```
❌ Quality Checks Failed
========================

Failed checks:
${LINT_FAILED:+  • Lint}
${TYPECHECK_FAILED:+  • Type check}
${TESTS_FAILED:+  • Unit tests}

What would you like to do?
1. View errors and fix
2. Continue anyway (not recommended)
3. Cancel commit

Enter 1, 2, or 3:
```

**If option 1**: Show detailed errors:
```bash
${LINT_FAILED:+npm run lint}
${TYPECHECK_FAILED:+npm run type-check || npx tsc --noEmit}
${TESTS_FAILED:+npm test}
```

**If option 2**: Require confirmation:
```
⚠️  WARNING: Committing code with quality issues!

Type 'SKIP QUALITY CHECKS' to continue:
```

---

### Step 5: Generate Conventional Commit Message

**Analyze changes to suggest type**:
```bash
# Count file types changed
JS_FILES=$(git diff --cached --name-only | grep -E '\.(js|jsx|ts|tsx)$' | wc -l)
TEST_FILES=$(git diff --cached --name-only | grep -E '\.(test|spec)\.(js|jsx|ts|tsx)$' | wc -l)
MD_FILES=$(git diff --cached --name-only | grep -E '\.md$' | wc -l)
CONFIG_FILES=$(git diff --cached --name-only | grep -E '(package\.json|tsconfig\.json|\.eslintrc|\.prettierrc)' | wc -l)

# Suggest type based on files
if [ $TEST_FILES -gt 0 ]; then
  SUGGESTED_TYPE="test"
elif [ $MD_FILES -gt 0 ] && [ $JS_FILES -eq 0 ]; then
  SUGGESTED_TYPE="docs"
elif [ $CONFIG_FILES -gt 0 ] && [ $JS_FILES -eq 0 ]; then
  SUGGESTED_TYPE="chore"
else
  # Check for new files (feature) vs modified files (fix/refactor)
  NEW_FILES=$(git diff --cached --name-only --diff-filter=A | wc -l)
  if [ $NEW_FILES -gt 0 ]; then
    SUGGESTED_TYPE="feat"
  else
    SUGGESTED_TYPE="fix"
  fi
fi
```

**Ask for commit type**:
```
💬 Commit Message
=================

Select commit type [suggested: $SUGGESTED_TYPE]:

1. feat     - New feature
2. fix      - Bug fix
3. docs     - Documentation changes
4. style    - Code style (formatting, etc.)
5. refactor - Code refactoring
6. perf     - Performance improvement
7. test     - Adding/updating tests
8. build    - Build system changes
9. ci       - CI/CD changes
10. chore    - Other changes

Enter 1-10 or type [default: $SUGGESTED_TYPE]:
```

**Map selection to type**:
```bash
case $SELECTION in
  1|feat) TYPE="feat" ;;
  2|fix) TYPE="fix" ;;
  3|docs) TYPE="docs" ;;
  4|style) TYPE="style" ;;
  5|refactor) TYPE="refactor" ;;
  6|perf) TYPE="perf" ;;
  7|test) TYPE="test" ;;
  8|build) TYPE="build" ;;
  9|ci) TYPE="ci" ;;
  10|chore) TYPE="chore" ;;
  *) TYPE="$SUGGESTED_TYPE" ;;
esac
```

**Ask for scope** (optional):
```
Scope (optional, e.g., auth, api, ui) [press Enter to skip]:
```

**Ask for description**:
```
Description (concise, starts with verb):
Example: "add user authentication"
         "fix null pointer in login"

Enter description:
```

**Validate description**:
- Not empty
- Starts with lowercase
- Doesn't end with period
- Reasonable length (5-72 characters)

**Ask for breaking changes**:
```
Are there breaking changes? (y/n):
```

**If 'y'**, add to commit body:
```
BREAKING CHANGE: [ask user to describe]
```

**Build commit message**:
```bash
COMMIT_MSG="$TYPE"
[[ -n "$SCOPE" ]] && COMMIT_MSG="${COMMIT_MSG}(${SCOPE})"
COMMIT_MSG="${COMMIT_MSG}: ${DESCRIPTION}"
[[ -n "$BREAKING_CHANGE" ]] && COMMIT_MSG="${COMMIT_MSG}\n\nBREAKING CHANGE: ${BREAKING_CHANGE}"
```

---

### Step 6: Show Preview

**Display commit preview**:
```
📝 Commit Preview
=================

Message:
  $COMMIT_MSG

Files to commit ($STAGED_FILES files):
```

**Show diff summary**:
```bash
git diff --cached --stat
```

**Show concise diff** (first 20 lines):
```bash
echo ""
echo "Changes preview (first 20 lines):"
git diff --cached | head -20
```

**Ask for confirmation**:
```
Commit these changes? (y/n/e):

  y - Yes, commit
  n - No, cancel
  e - Edit message

Enter choice:
```

**If 'e' (Edit message)**:
```
Current message: $COMMIT_MSG

Enter new message (or press Enter to keep current):
```

---

### Step 7: Create Commit

**Commit changes**:
```bash
git commit -m "$COMMIT_MSG"
```

**Capture commit hash**:
```bash
COMMIT_HASH=$(git rev-parse --short HEAD)
```

**Display success**:
```
✅ Commit created successfully!
==============================

Commit: $COMMIT_HASH
Message: $COMMIT_MSG

Files committed: $STAGED_FILES
```

**Show commit details**:
```bash
git show --stat $COMMIT_HASH
```

---

### Step 8: Optional Push

**Ask to push**:
```
Push to remote? (y/n):
```

**If 'n'**: Display reminder:
```
ℹ️  Remember to push later:

  git push origin $(git branch --show-current)
```

**If 'y'**: Check remote and push:
```bash
# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Check if branch has upstream
if git rev-parse --abbrev-ref @{upstream} > /dev/null 2>&1; then
  echo "🚀 Pushing to origin/$CURRENT_BRANCH..."
  git push
else
  echo "🚀 Pushing and setting upstream..."
  git push -u origin $CURRENT_BRANCH
fi
```

**Display**:
```
✅ Pushed successfully!

  Branch: $CURRENT_BRANCH
  Remote: origin/$CURRENT_BRANCH
```

---

## Error Handling

### No Changes to Commit
```
ℹ️  Working directory is clean

Nothing to commit. Run:
  git status

to see current state.
```

### Git Not Initialized
```
❌ Not a git repository

Run: git init

to initialize a git repository.
```

### Pre-commit Hook Fails
```
❌ Pre-commit hook failed

Git hooks prevented this commit.

View hook output above for details.

You can bypass hooks with:
  git commit --no-verify -m "message"

But this is NOT RECOMMENDED.
```

### Push Failed (e.g., protected branch)
```
❌ Push failed

This usually happens when:
  • Branch is protected
  • Force push is disabled
  • PR is required

Solution:
  • Create a PR: /create-pr
  • Or push to different branch
```

---

## Examples

### Feature Commit
```
Type: feat
Scope: auth
Description: add JWT authentication

Result: feat(auth): add JWT authentication
```

### Fix Commit
```
Type: fix
Scope: api
Description: resolve null pointer in user endpoint

Result: fix(api): resolve null pointer in user endpoint
```

### Breaking Change
```
Type: feat
Scope: api
Description: redesign user API endpoints
Breaking: yes
Breaking description: User API now uses /v2/ prefix

Result:
feat(api): redesign user API endpoints

BREAKING CHANGE: User API now uses /v2/ prefix
```

---

## Notes

- **Security first**: Secret scanning prevents accidental commits
- **Quality gates**: Ensure code quality before committing
- **Conventional commits**: Maintain consistent commit history
- **Interactive**: User has control at every step
- **Safe**: Multiple confirmation points for risky actions

---

## Testing Checklist

- [ ] Test with no changes
- [ ] Test with staged changes
- [ ] Test with unstaged changes
- [ ] Test secret detection (create .env with fake key)
- [ ] Test quality checks passing
- [ ] Test quality checks failing
- [ ] Test conventional commit generation
- [ ] Test with breaking changes
- [ ] Test push to remote
- [ ] Test push without upstream

---

**Author**: Alireza Rezvani
**Date**: 2025-11-06
**Estimated Time**: 1.5 hours implementation
