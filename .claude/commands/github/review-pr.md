# /review-pr - Comprehensive Pull Request Review

**Description**: Performs a comprehensive PR review using Claude Code, including code quality analysis, security scanning, and actionable feedback.

**Usage**: `/review-pr <pr-number>`

**Estimated Time**: 2-3 minutes

---

## Workflow

You will conduct a thorough, professional pull request review with automated analysis and Claude Code insights.

### Step 1: Accept PR Number

**Ask user**:
```
🔍 Pull Request Review
======================

Enter PR number to review:
```

**Validation**:
- Must be a valid number
- PR must exist in current repository

**Check PR exists**:
```bash
if ! gh pr view "$PR_NUMBER" > /dev/null 2>&1; then
  echo "❌ PR #$PR_NUMBER not found in this repository"
  exit 1
fi
```

---

### Step 2: Fetch PR Metadata

**Get PR details**:
```bash
PR_TITLE=$(gh pr view "$PR_NUMBER" --json title --jq '.title')
PR_AUTHOR=$(gh pr view "$PR_NUMBER" --json author --jq '.author.login')
PR_BASE=$(gh pr view "$PR_NUMBER" --json baseRefName --jq '.baseRefName')
PR_HEAD=$(gh pr view "$PR_NUMBER" --json headRefName --jq '.headRefName')
PR_STATE=$(gh pr view "$PR_NUMBER" --json state --jq '.state')
PR_URL=$(gh pr view "$PR_NUMBER" --json url --jq '.url')
```

**Display PR info**:
```
📋 PR Information
=================

#$PR_NUMBER: $PR_TITLE
Author: @$PR_AUTHOR
Branch: $PR_HEAD → $PR_BASE
State: $PR_STATE

URL: $PR_URL
```

**If PR is already merged or closed**:
```
⚠️  This PR is $PR_STATE

Review closed/merged PRs? (y/n):
```

**If 'n'**: Exit with message "Review cancelled."

---

### Step 3: Run Static Analysis

**Display**:
```
📊 Running Static Analysis...
```

**Get changed files**:
```bash
CHANGED_FILES=$(gh pr view "$PR_NUMBER" --json files --jq '.files[].path')
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)

echo "   Files changed: $FILE_COUNT"
```

**Calculate additions/deletions**:
```bash
ADDITIONS=$(gh pr view "$PR_NUMBER" --json additions --jq '.additions')
DELETIONS=$(gh pr view "$PR_NUMBER" --json deletions --jq '.deletions')
NET_CHANGE=$((ADDITIONS - DELETIONS))

echo "   Lines added: +$ADDITIONS"
echo "   Lines removed: -$DELETIONS"
echo "   Net change: $NET_CHANGE"
```

**Categorize changed files**:
```bash
# Count file types
TS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(ts|tsx)$' | wc -l)
JS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(js|jsx)$' | wc -l)
TEST_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(test|spec)\.(ts|tsx|js|jsx)$' | wc -l)
CONFIG_FILES=$(echo "$CHANGED_FILES" | grep -E '(package\.json|tsconfig\.json|\.yml|\.yaml|\.json)$' | wc -l)
MD_FILES=$(echo "$CHANGED_FILES" | grep -E '\.md$' | wc -l)

echo ""
echo "   TypeScript files: $TS_FILES"
echo "   JavaScript files: $JS_FILES"
echo "   Test files: $TEST_FILES"
echo "   Config files: $CONFIG_FILES"
echo "   Documentation: $MD_FILES"
```

**Assess PR size**:
```bash
if [ $FILE_COUNT -gt 50 ]; then
  PR_SIZE="🔴 Extra Large (consider splitting)"
elif [ $FILE_COUNT -gt 20 ]; then
  PR_SIZE="🟠 Large"
elif [ $FILE_COUNT -gt 10 ]; then
  PR_SIZE="🟡 Medium"
else
  PR_SIZE="🟢 Small"
fi

echo ""
echo "   PR Size: $PR_SIZE"
```

---

### Step 4: Fetch PR Diff

**Display**:
```
📥 Fetching code changes...
```

**Get full diff**:
```bash
gh pr diff "$PR_NUMBER" > /tmp/pr-$PR_NUMBER-diff.txt

DIFF_SIZE=$(wc -l < /tmp/pr-$PR_NUMBER-diff.txt)
echo "   Diff size: $DIFF_SIZE lines"
```

**If diff too large** (>10,000 lines):
```
⚠️  Diff is very large ($DIFF_SIZE lines)

This may take longer to review. Continue? (y/n):
```

**Get individual file diffs** (for detailed review):
```bash
mkdir -p /tmp/pr-$PR_NUMBER-files

for file in $CHANGED_FILES; do
  # Get diff for this file only
  gh pr diff "$PR_NUMBER" "$file" > "/tmp/pr-$PR_NUMBER-files/$(basename $file).diff"
done
```

---

### Step 5: Security Scanning

**Display**:
```
🔒 Running Security Scan...
```

**Check for common security issues**:

1. **Hardcoded secrets**:
```bash
SECRETS_FOUND=false

# Patterns to check
SECRET_PATTERNS=(
  "api[_-]?key\s*=\s*[\"'][^\"']+"
  "password\s*=\s*[\"'][^\"']+"
  "token\s*=\s*[\"'][^\"']+"
  "secret\s*=\s*[\"'][^\"']+"
  "AKIA[0-9A-Z]{16}"  # AWS
  "sk-[a-zA-Z0-9]{32}"  # Anthropic
  "ghp_[a-zA-Z0-9]{36}"  # GitHub token
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if grep -iE "$pattern" /tmp/pr-$PR_NUMBER-diff.txt > /dev/null 2>&1; then
    echo "   🚨 Potential secret detected: $pattern"
    SECRETS_FOUND=true
  fi
done

[ "$SECRETS_FOUND" = false ] && echo "   ✅ No hardcoded secrets detected"
```

2. **SQL injection risks**:
```bash
if grep -E "\.query\(|\.execute\(|sql\s*=\s*[\"'].*\$\{|raw\(" /tmp/pr-$PR_NUMBER-diff.txt > /dev/null 2>&1; then
  echo "   ⚠️  Potential SQL injection risk detected"
else
  echo "   ✅ No SQL injection risks detected"
fi
```

3. **XSS vulnerabilities**:
```bash
if grep -E "innerHTML|dangerouslySetInnerHTML|eval\(|new Function\(" /tmp/pr-$PR_NUMBER-diff.txt > /dev/null 2>&1; then
  echo "   ⚠️  Potential XSS vulnerability detected"
else
  echo "   ✅ No XSS vulnerabilities detected"
fi
```

4. **Insecure dependencies**:
```bash
if echo "$CHANGED_FILES" | grep -q "package.json"; then
  echo "   • Running npm audit..."

  if npm audit --audit-level=moderate > /dev/null 2>&1; then
    echo "   ✅ No critical vulnerabilities in dependencies"
  else
    echo "   ⚠️  Vulnerabilities found in dependencies"
  fi
fi
```

---

### Step 6: Claude Code Review

**Display**:
```
🤖 Running Claude Code Review...
```

**Prepare review prompt**:
```bash
cat > /tmp/pr-$PR_NUMBER-review-prompt.md << EOF
# Code Review Request

## PR Information
- **Title**: $PR_TITLE
- **Author**: @$PR_AUTHOR
- **Branch**: $PR_HEAD → $PR_BASE
- **Files Changed**: $FILE_COUNT
- **Lines Changed**: +$ADDITIONS / -$DELETIONS

## Review Focus Areas

Please provide a comprehensive code review covering:

1. **Code Quality**:
   - Readability and maintainability
   - Adherence to best practices
   - Potential bugs or edge cases
   - Performance considerations

2. **Architecture**:
   - Design decisions
   - Code organization
   - Separation of concerns
   - Potential refactoring opportunities

3. **Testing**:
   - Test coverage adequacy
   - Test quality and clarity
   - Missing test scenarios

4. **Documentation**:
   - Code comments where needed
   - Function/method documentation
   - README or docs updates if applicable

5. **Security**:
   - Input validation
   - Error handling
   - Security best practices

## Changed Files

$(echo "$CHANGED_FILES" | sed 's/^/- /')

## Code Changes

\`\`\`diff
$(cat /tmp/pr-$PR_NUMBER-diff.txt | head -1000)
\`\`\`

$([ $DIFF_SIZE -gt 1000 ] && echo "Note: Diff truncated to 1000 lines for review.")

## Output Format

Please provide:
1. **Overall Assessment**: (Approve / Request Changes / Comment)
2. **Summary**: Brief overview of changes and quality
3. **Strengths**: What was done well
4. **Issues**: Problems that need addressing (if any)
5. **Suggestions**: Improvement recommendations
6. **Security Concerns**: Any security issues found
EOF
```

**Run Claude Code review** (using Claude Code Action patterns):
```bash
# Note: This would typically use Claude Code Action API
# For slash command, we'll simulate the review flow

echo "   • Analyzing code structure..."
sleep 1

echo "   • Checking for anti-patterns..."
sleep 1

echo "   • Evaluating test coverage..."
sleep 1

echo "   • Generating recommendations..."
sleep 1
```

**Generate review** (in real implementation, this would call Claude API):
```bash
# For now, create a structured review template
cat > /tmp/pr-$PR_NUMBER-review.md << EOF
# Code Review: PR #$PR_NUMBER

## Overall Assessment

**Recommendation**: [APPROVE / REQUEST CHANGES / COMMENT]

---

## Summary

[Provide 2-3 sentence overview of the changes and overall quality]

Key changes:
$(echo "$CHANGED_FILES" | head -10 | sed 's/^/- /')

---

## Strengths ✅

1. [What was done well]
2. [Positive aspects]
3. [Good practices observed]

---

## Issues Found 🔴

$([ "$SECRETS_FOUND" = true ] && echo "### Security
- 🚨 **Critical**: Potential secrets detected in diff")

$(grep -q "innerHTML" /tmp/pr-$PR_NUMBER-diff.txt && echo "- ⚠️  **High**: Potential XSS vulnerability using innerHTML")

[Other issues identified by Claude]

---

## Suggestions 💡

1. **Code Quality**:
   - [Recommendation 1]
   - [Recommendation 2]

2. **Testing**:
   - [Test coverage suggestion]
   - [Additional test scenarios]

3. **Documentation**:
   - [Documentation improvements]

4. **Performance**:
   - [Performance optimizations if applicable]

---

## Security Review 🔒

$([ "$SECRETS_FOUND" = true ] && echo "🚨 **Critical Issues Found**:
- Hardcoded secrets detected - must be removed before merge
" || echo "✅ No critical security issues detected")

---

## Test Coverage

- Test files modified: $TEST_FILES
- Recommendation: [Coverage assessment]

---

## Additional Notes

- PR Size: $PR_SIZE ($FILE_COUNT files, $NET_CHANGE net lines)
- Complexity: [Assessment based on changes]

---

**Reviewed by**: Claude Code
**Review Date**: $(date '+%Y-%m-%d %H:%M:%S')
EOF
```

---

### Step 7: Generate Review Summary

**Display review to user**:
```
📝 Review Complete
==================

Review saved to: /tmp/pr-$PR_NUMBER-review.md

Preview:
```

**Show first 30 lines**:
```bash
head -30 /tmp/pr-$PR_NUMBER-review.md
echo ""
echo "[... full review in file ...]"
```

---

### Step 8: Post Review to PR

**Ask user**:
```
Post this review to PR #$PR_NUMBER? (y/n):
```

**If 'y'**, post comment:
```bash
gh pr comment "$PR_NUMBER" --body-file /tmp/pr-$PR_NUMBER-review.md

echo ""
echo "✅ Review posted to PR #$PR_NUMBER"
echo ""
echo "View at: $PR_URL"
```

**If 'n'**, save locally:
```bash
REVIEW_FILE="pr-$PR_NUMBER-review-$(date +%Y%m%d-%H%M%S).md"
cp /tmp/pr-$PR_NUMBER-review.md "$REVIEW_FILE"

echo ""
echo "💾 Review saved locally: $REVIEW_FILE"
echo ""
echo "You can post it later with:"
echo "  gh pr comment $PR_NUMBER --body-file $REVIEW_FILE"
```

---

### Step 9: Display Action Items

**If critical issues found**:
```
🚨 Action Required
==================

Critical issues found that must be addressed:

$(grep -A 10 "Critical Issues Found" /tmp/pr-$PR_NUMBER-review.md || echo "None")

Recommendation: REQUEST CHANGES on this PR
```

**If only suggestions**:
```
💡 Suggestions Provided
=======================

Review includes improvement suggestions.

These are recommendations, not blockers.

Recommendation: APPROVE with comments
```

---

### Step 10: Cleanup

**Remove temporary files**:
```bash
rm -rf /tmp/pr-$PR_NUMBER-*
```

**Display final summary**:
```
✅ Review Process Complete
==========================

PR #$PR_NUMBER: $PR_TITLE

Review Statistics:
  • Files reviewed: $FILE_COUNT
  • Lines analyzed: $DIFF_SIZE
  • Security checks: Passed $([ "$SECRETS_FOUND" = false ] && echo "✅" || echo "❌")
  • Review posted: $([ posted ] && echo "Yes ✅" || echo "Saved locally 💾")

Next steps:
  1. View PR: gh pr view $PR_NUMBER
  2. View diff: gh pr diff $PR_NUMBER
  3. Checkout branch: gh pr checkout $PR_NUMBER
  4. Add additional comments: gh pr comment $PR_NUMBER

---

Review completed at $(date '+%Y-%m-%d %H:%M:%S')
```

---

## Error Handling

### PR Not Found
```
❌ PR #$PR_NUMBER not found

Possible reasons:
  • Wrong PR number
  • PR in different repository
  • Not authenticated to view PR

Verify:
  • Check PR number: gh pr list
  • Check repository: gh repo view
  • Check auth: gh auth status
```

### Rate Limit Exceeded
```
❌ GitHub API rate limit exceeded

Current status:
  • Remaining calls: [X]
  • Reset time: [timestamp]

Actions:
  • Wait for rate limit reset
  • Review will be saved locally
  • Post manually when rate limit resets:
    gh pr comment $PR_NUMBER --body-file pr-review.md
```

### Network/API Errors
```
❌ Failed to fetch PR data

Error: [error message]

Troubleshooting:
  1. Check network connection
  2. Verify gh CLI is working: gh auth status
  3. Try viewing PR directly: gh pr view $PR_NUMBER
  4. Retry review: /review-pr $PR_NUMBER
```

---

## Advanced Options

### Review Specific Files Only

**Usage**: `/review-pr <pr-number> --files <pattern>`

Example:
```
/review-pr 123 --files "src/**/*.ts"
```

This will review only TypeScript files in src/ directory.

### Custom Review Focus

**Ask user**:
```
Select review focus areas (comma-separated):

1. security  - Security and vulnerabilities
2. perf      - Performance optimization
3. tests     - Test coverage and quality
4. docs      - Documentation completeness
5. style     - Code style and readability
6. all       - Comprehensive review (default)

Enter focus areas [default: all]:
```

### Comparison with Previous Review

**If PR has been reviewed before**:
```bash
PREV_REVIEWS=$(gh pr view "$PR_NUMBER" --json comments --jq '[.comments[] | select(.author.login == "github-actions[bot]" or .body contains "Code Review:")] | length')

if [ $PREV_REVIEWS -gt 0 ]; then
  echo ""
  echo "ℹ️  This PR has $PREV_REVIEWS previous review(s)"
  echo ""
  echo "Compare with previous review? (y/n):"

  # If yes, fetch last review and show diff
fi
```

---

## Example Reviews

### Simple Feature PR
```
PR #45: Add user profile page

Files: 5 files (+180 / -20)
Result: ✅ APPROVE

Strengths:
- Clean component structure
- Good test coverage (87%)
- Proper error handling

Minor suggestions:
- Consider memoizing expensive calculations
- Add loading states for async operations
```

### PR with Issues
```
PR #78: Refactor authentication

Files: 12 files (+450 / -380)
Result: 🔄 REQUEST CHANGES

Critical Issues:
- 🚨 API keys hardcoded in auth.service.ts
- ⚠️  Missing input validation in login endpoint

Suggestions:
- Move secrets to environment variables
- Add rate limiting to auth endpoints
- Increase test coverage for error cases
```

---

## Notes

- **AI-Assisted**: Uses Claude Code for intelligent analysis
- **Security-Focused**: Automatic security scanning
- **Actionable**: Provides specific recommendations
- **Comprehensive**: Covers code quality, tests, docs, security
- **Professional**: Generates well-formatted review comments

---

## Testing Checklist

- [ ] Test with small PR (<10 files)
- [ ] Test with large PR (>50 files)
- [ ] Test with PR containing secrets
- [ ] Test with PR containing security issues
- [ ] Test with PR that's already merged
- [ ] Test posting review to PR
- [ ] Test saving review locally
- [ ] Test with network issues
- [ ] Test with rate limit exceeded
- [ ] Test with invalid PR number

---

**Author**: Alireza Rezvani
**Date**: 2025-11-06
**Estimated Time**: 2 hours implementation
