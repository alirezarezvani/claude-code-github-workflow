# /release - Create Production Release

**Description**: Creates a production release PR from dev to main with automatic changelog generation and version bumping.

**Usage**: `/release`

**Estimated Time**: 3-5 minutes

---

## Workflow

You will guide the user through creating a production-ready release with proper versioning, changelog, and deployment preparation.

### Step 1: Validate Current Branch

**Get current branch**:
```bash
CURRENT_BRANCH=$(git branch --show-current)
```

**Validate on dev branch**:
```bash
if [ "$CURRENT_BRANCH" != "dev" ]; then
  echo "❌ Release must be created from 'dev' branch"
  echo ""
  echo "Current branch: $CURRENT_BRANCH"
  echo ""
  echo "Switch to dev branch:"
  echo "  git checkout dev"
  echo "  git pull origin dev"
  exit 1
fi
```

**Display**:
```
🚀 Create Production Release
=============================

Current branch: dev ✅
```

---

### Step 2: Check Working Directory

**Ensure clean working directory**:
```bash
if ! git diff-index --quiet HEAD --; then
  echo "⚠️  Working directory has uncommitted changes"
  echo ""
  git status --short
  echo ""
  echo "Commit or stash changes before creating release:"
  echo "  git add ."
  echo "  git commit -m 'chore: prepare for release'"
  echo "  or"
  echo "  git stash"
  exit 1
fi
```

**Sync with remote**:
```bash
echo "🔄 Syncing with remote..."

git fetch origin dev
git fetch origin main

COMMITS_BEHIND=$(git rev-list HEAD..origin/dev --count)

if [ $COMMITS_BEHIND -gt 0 ]; then
  echo "⚠️  Local dev is $COMMITS_BEHIND commits behind origin/dev"
  echo ""
  echo "Pull latest changes? (y/n):"
  read PULL_NOW

  if [ "$PULL_NOW" = "y" ]; then
    git pull origin dev
  else
    echo "❌ Cannot create release without latest changes"
    exit 1
  fi
fi
```

---

### Step 3: Check Unreleased Commits

**Compare dev with main**:
```bash
COMMITS_AHEAD=$(git rev-list origin/main..dev --count)

if [ $COMMITS_AHEAD -eq 0 ]; then
  echo "ℹ️  No new commits to release"
  echo ""
  echo "dev branch is up-to-date with main."
  echo ""
  echo "Nothing to release."
  exit 0
fi
```

**Display commits**:
```
📦 Commits to Release
=====================

Found $COMMITS_AHEAD commits since last release:
```

**Show commit log**:
```bash
git log origin/main..dev --oneline --reverse | nl -w2 -s'. '
```

**Show commit breakdown by type**:
```bash
FEAT_COUNT=$(git log origin/main..dev --oneline | grep -cE "^[a-f0-9]+ feat" || echo 0)
FIX_COUNT=$(git log origin/main..dev --oneline | grep -cE "^[a-f0-9]+ fix" || echo 0)
DOCS_COUNT=$(git log origin/main..dev --oneline | grep -cE "^[a-f0-9]+ docs" || echo 0)
OTHER_COUNT=$((COMMITS_AHEAD - FEAT_COUNT - FIX_COUNT - DOCS_COUNT))

echo ""
echo "Commit Summary:"
echo "  ✨ Features: $FEAT_COUNT"
echo "  🐛 Fixes: $FIX_COUNT"
echo "  📝 Documentation: $DOCS_COUNT"
echo "  ⚙️  Other: $OTHER_COUNT"
```

---

### Step 4: Check Open PRs

**Check for open PRs into dev**:
```bash
OPEN_PRS=$(gh pr list --base dev --state open --json number --jq '. | length')

if [ $OPEN_PRS -gt 0 ]; then
  echo ""
  echo "⚠️  Warning: $OPEN_PRS open PR(s) targeting dev branch"
  echo ""
  echo "Open PRs:"
  gh pr list --base dev --state open --json number,title,author --jq '.[] | "  #\(.number): \(.title) (@\(.author.login))"'
  echo ""
  echo "Continue with release anyway? (y/n):"
  read CONTINUE_ANYWAY

  if [ "$CONTINUE_ANYWAY" != "y" ]; then
    echo "Release cancelled."
    exit 1
  fi
fi
```

---

### Step 5: Determine Version Bump

**Get current version**:
```bash
if [ -f "package.json" ]; then
  CURRENT_VERSION=$(jq -r '.version' package.json)
else
  # Try git tags
  CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
  CURRENT_VERSION=${CURRENT_VERSION#v}  # Remove 'v' prefix if present
fi

echo ""
echo "📌 Current Version: $CURRENT_VERSION"
```

**Parse version**:
```bash
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
```

**Suggest version bump**:
```bash
# Suggest based on commit types
if [ $FEAT_COUNT -gt 0 ] && [ $FIX_COUNT -eq 0 ]; then
  SUGGESTED_BUMP="minor"
  NEXT_VERSION="$MAJOR.$((MINOR + 1)).0"
elif [ $FIX_COUNT -gt 0 ] && [ $FEAT_COUNT -eq 0 ]; then
  SUGGESTED_BUMP="patch"
  NEXT_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
else
  SUGGESTED_BUMP="minor"
  NEXT_VERSION="$MAJOR.$((MINOR + 1)).0"
fi

# Check for breaking changes in commit messages
if git log origin/main..dev --pretty=format:"%s %b" | grep -qE "BREAKING CHANGE|!:"; then
  echo ""
  echo "🚨 Breaking changes detected in commits!"
  SUGGESTED_BUMP="major"
  NEXT_VERSION="$((MAJOR + 1)).0.0"
fi
```

**Ask user for version**:
```
🏷️  Version Bump
================

Suggested: $SUGGESTED_BUMP ($CURRENT_VERSION → $NEXT_VERSION)

Select version bump:
1. major - Breaking changes ($((MAJOR + 1)).0.0)
2. minor - New features ($MAJOR.$((MINOR + 1)).0)
3. patch - Bug fixes ($MAJOR.$MINOR.$((PATCH + 1)))
4. custom - Enter version manually

Enter 1-4 [default: $SUGGESTED_BUMP]:
```

**Process selection**:
```bash
case $SELECTION in
  1|major)
    NEW_VERSION="$((MAJOR + 1)).0.0"
    ;;
  2|minor)
    NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
    ;;
  3|patch)
    NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
    ;;
  4|custom)
    echo "Enter version (x.y.z format):"
    read CUSTOM_VERSION
    # Validate format
    if [[ ! "$CUSTOM_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "❌ Invalid version format. Must be x.y.z"
      exit 1
    fi
    NEW_VERSION="$CUSTOM_VERSION"
    ;;
  "")
    NEW_VERSION="$NEXT_VERSION"
    ;;
  *)
    echo "❌ Invalid selection"
    exit 1
    ;;
esac

echo ""
echo "✅ New version: $NEW_VERSION"
```

---

### Step 6: Generate Changelog

**Display**:
```
📝 Generating Changelog...
```

**Create changelog sections**:
```bash
cat > /tmp/release-changelog.md << EOF
# Release v$NEW_VERSION

**Release Date**: $(date '+%Y-%m-%d')

## What's Changed

EOF

# Features
if [ $FEAT_COUNT -gt 0 ]; then
  echo "### ✨ Features" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
  git log origin/main..dev --oneline --grep="^feat" --pretty=format:"- %s (%h)" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
fi

# Bug Fixes
if [ $FIX_COUNT -gt 0 ]; then
  echo "### 🐛 Bug Fixes" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
  git log origin/main..dev --oneline --grep="^fix" --pretty=format:"- %s (%h)" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
fi

# Documentation
if [ $DOCS_COUNT -gt 0 ]; then
  echo "### 📝 Documentation" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
  git log origin/main..dev --oneline --grep="^docs" --pretty=format:"- %s (%h)" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
fi

# Other changes
if [ $OTHER_COUNT -gt 0 ]; then
  echo "### ⚙️  Other Changes" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
  git log origin/main..dev --oneline --grep="^chore\\|^refactor\\|^perf\\|^test\\|^ci\\|^build" --pretty=format:"- %s (%h)" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
  echo "" >> /tmp/release-changelog.md
fi

# Full changelog link
cat >> /tmp/release-changelog.md << EOF
---

**Full Changelog**: https://github.com/$(gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"')/compare/v$CURRENT_VERSION...v$NEW_VERSION
EOF
```

**Display changelog preview**:
```
📄 Changelog Preview
====================
```

```bash
cat /tmp/release-changelog.md
```

**Ask to edit**:
```
Edit changelog? (y/n) [default: n]:
```

**If 'y'**, open editor:
```bash
${EDITOR:-vim} /tmp/release-changelog.md
```

---

### Step 7: Update Version Files

**Display**:
```
🔧 Updating Version Files...
```

**Update package.json** (if exists):
```bash
if [ -f "package.json" ]; then
  echo "   • Updating package.json..."
  jq --arg version "$NEW_VERSION" '.version = $version' package.json > package.json.tmp
  mv package.json.tmp package.json
  git add package.json
fi
```

**Update other version files** (common patterns):
```bash
# Check for version.txt
if [ -f "version.txt" ]; then
  echo "   • Updating version.txt..."
  echo "$NEW_VERSION" > version.txt
  git add version.txt
fi

# Check for VERSION file
if [ -f "VERSION" ]; then
  echo "   • Updating VERSION..."
  echo "$NEW_VERSION" > VERSION
  git add VERSION
fi

# Check for pyproject.toml (Python projects)
if [ -f "pyproject.toml" ]; then
  echo "   • Updating pyproject.toml..."
  sed -i '' "s/^version = .*/version = \"$NEW_VERSION\"/" pyproject.toml
  git add pyproject.toml
fi
```

**Commit version bump**:
```bash
git commit -m "chore: bump version to $NEW_VERSION"

echo "   ✅ Version files updated"
```

---

### Step 8: Create Release PR

**Display**:
```
🔀 Creating Release PR...
```

**Generate PR body**:
```bash
cat > /tmp/release-pr-body.md << EOF
# Release v$NEW_VERSION

## Summary

This PR releases version $NEW_VERSION to production.

$(cat /tmp/release-changelog.md)

## Pre-Release Checklist

### Code Quality
- [ ] All tests passing
- [ ] No linter errors
- [ ] Type check passing
- [ ] No console.log statements
- [ ] No commented-out code

### Testing
- [ ] Manual testing completed
- [ ] Edge cases tested
- [ ] Performance tested
- [ ] Security review completed

### Documentation
- [ ] CHANGELOG.md updated
- [ ] README.md updated (if needed)
- [ ] API docs updated (if applicable)
- [ ] Migration guide provided (if breaking changes)

### Deployment
- [ ] Database migrations ready (if applicable)
- [ ] Environment variables documented
- [ ] Rollback plan prepared
- [ ] Monitoring configured

### Communication
- [ ] Stakeholders notified
- [ ] Release notes drafted
- [ ] Support team briefed

## Deployment Plan

1. Merge this PR to main
2. Automated tests will run
3. Production deployment will trigger
4. Monitor logs and metrics
5. Create GitHub release with tag v$NEW_VERSION

## Rollback Plan

If issues arise:
1. Revert main branch to previous commit
2. Trigger emergency hotfix if needed
3. Investigate and fix in dev branch

---

**Release Manager**: @$USER
**Release Date**: $(date '+%Y-%m-%d')
**Commits Included**: $COMMITS_AHEAD
EOF
```

**Push dev branch** (ensure latest):
```bash
echo "   • Pushing dev branch..."
git push origin dev
```

**Create PR**:
```bash
PR_URL=$(gh pr create \
  --base main \
  --head dev \
  --title "Release v$NEW_VERSION" \
  --body-file /tmp/release-pr-body.md \
  --label "type:release" \
  --label "status:ready")

PR_NUMBER=$(echo "$PR_URL" | grep -oE '[0-9]+$')

echo ""
echo "✅ Release PR created: #$PR_NUMBER"
echo "   $PR_URL"
```

---

### Step 9: Display Release Checklist

**Show next steps**:
```
✅ Release PR Created!
======================

PR #$PR_NUMBER: Release v$NEW_VERSION

Current Version: $CURRENT_VERSION
New Version: $NEW_VERSION
Commits: $COMMITS_AHEAD

🔗 URL: $PR_URL

---

📋 Next Steps:

1. **Review PR** (REQUIRED):
   - Review all changes: gh pr diff $PR_NUMBER
   - Check changelog accuracy
   - Verify version bump is correct

2. **Complete Pre-Release Checklist**:
   - Run full test suite: npm test
   - Perform manual testing
   - Security review
   - Documentation updates

3. **Get Approval**:
   - Request review from team lead
   - Minimum 1 approval required
   - All CI checks must pass

4. **Merge to Production**:
   - gh pr merge $PR_NUMBER --squash
   - Monitor deployment
   - Verify production health

5. **Post-Release**:
   - Create GitHub release: gh release create v$NEW_VERSION
   - Notify stakeholders
   - Update status page

---

⚙️  Commands:

View PR:           gh pr view $PR_NUMBER
Review changes:    gh pr diff $PR_NUMBER
Add comment:       gh pr comment $PR_NUMBER -b "comment"
Request review:    gh pr review $PR_NUMBER --request-reviewer @username
Merge (when ready): gh pr merge $PR_NUMBER --squash

Monitor status:    gh pr checks $PR_NUMBER
```

---

### Step 10: Optional Monitoring

**Ask to monitor**:
```
Monitor PR status? (y/n):
```

**If 'y'**, start monitoring:
```bash
echo ""
echo "📊 Monitoring PR #$PR_NUMBER..."
echo "   (Press Ctrl+C to stop monitoring)"
echo ""

while true; do
  STATUS=$(gh pr view $PR_NUMBER --json state,mergeable,reviewDecision --jq '.')

  PR_STATE=$(echo "$STATUS" | jq -r '.state')
  MERGEABLE=$(echo "$STATUS" | jq -r '.mergeable')
  REVIEW_DECISION=$(echo "$STATUS" | jq -r '.reviewDecision')

  clear
  echo "🔄 PR #$PR_NUMBER Status ($(date '+%H:%M:%S'))"
  echo "========================================"
  echo ""
  echo "State: $PR_STATE"
  echo "Mergeable: $MERGEABLE"
  echo "Review Decision: $REVIEW_DECISION"
  echo ""

  # Check CI status
  gh pr checks $PR_NUMBER

  # If merged, break
  if [ "$PR_STATE" = "MERGED" ]; then
    echo ""
    echo "🎉 PR merged successfully!"
    echo ""
    echo "Creating GitHub release..."

    gh release create "v$NEW_VERSION" \
      --title "Release v$NEW_VERSION" \
      --notes-file /tmp/release-changelog.md

    echo ""
    echo "✅ Release v$NEW_VERSION completed!"
    break
  fi

  sleep 30
done
```

---

## Post-Release Actions

**After PR is merged**:
```
🎉 Release Complete!
====================

Version v$NEW_VERSION is now in production.

Recommended Actions:

1. **Create Git Tag** (if not auto-created):
   git tag -a v$NEW_VERSION -m "Release v$NEW_VERSION"
   git push origin v$NEW_VERSION

2. **Create GitHub Release**:
   gh release create v$NEW_VERSION \
     --title "Release v$NEW_VERSION" \
     --notes-file /tmp/release-changelog.md

3. **Update Documentation**:
   - Update installation instructions
   - Update API version references
   - Publish release notes

4. **Monitor Production**:
   - Check error rates
   - Monitor performance metrics
   - Verify key features

5. **Notify Team**:
   - Post in team channel
   - Update status page
   - Send release announcement

---

Release completed at $(date '+%Y-%m-%d %H:%M:%S')
```

---

## Error Handling

### Not on Dev Branch
```
❌ Must be on dev branch to create release

Current branch: $CURRENT_BRANCH

Switch to dev:
  git checkout dev
  git pull origin dev

Then retry: /release
```

### No Commits to Release
```
ℹ️  Nothing to Release

dev branch is up-to-date with main.

Make changes first:
  1. Create feature branches
  2. Merge PRs to dev
  3. Then create release
```

### Uncommitted Changes
```
❌ Working directory has uncommitted changes

Commit or stash changes first:
  git add .
  git commit -m "your message"

  or

  git stash
```

### Open PRs Warning
```
⚠️  $OPEN_PRS open PR(s) targeting dev

These PRs are not yet merged:
  [list PRs]

Recommendation:
  • Merge or close open PRs
  • Then create release

Or continue anyway (not recommended).
```

### Release PR Already Exists
```
ℹ️  Release PR already exists

PR #$EXISTING_PR: Release v$VERSION

URL: $PR_URL

Actions:
  • View PR: gh pr view $EXISTING_PR
  • Close old PR: gh pr close $EXISTING_PR
  • Create new PR: /release
```

---

## Example Releases

### Minor Release (New Features)
```
Release v1.2.0

Changes:
  ✨ Features: 5
  🐛 Fixes: 2
  📝 Docs: 1

Version: 1.1.0 → 1.2.0
Commits: 8
```

### Patch Release (Bug Fixes)
```
Release v1.1.1

Changes:
  🐛 Fixes: 3

Version: 1.1.0 → 1.1.1
Commits: 3
```

### Major Release (Breaking Changes)
```
Release v2.0.0

🚨 BREAKING CHANGES

Changes:
  ✨ Features: 12
  🐛 Fixes: 5
  💥 Breaking: 3

Version: 1.5.0 → 2.0.0
Commits: 20
```

---

## Notes

- **Dev Branch Required**: Releases must be created from dev
- **Automatic Changelog**: Generated from conventional commits
- **Version Bump**: Suggests based on commit types
- **Pre-Release Checklist**: Comprehensive quality checks
- **Monitoring**: Optional real-time PR status monitoring

---

## Testing Checklist

- [ ] Test from dev branch
- [ ] Test from wrong branch (should error)
- [ ] Test with no commits (should exit)
- [ ] Test with uncommitted changes (should error)
- [ ] Test version bump (major/minor/patch)
- [ ] Test changelog generation
- [ ] Test with breaking changes
- [ ] Test PR creation
- [ ] Test monitoring mode
- [ ] Test with existing release PR

---

**Author**: Alireza Rezvani
**Date**: 2025-11-06
**Estimated Time**: 1.5 hours implementation
