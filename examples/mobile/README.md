# Mobile Example - Expo with GitHub Workflow Blueprint

A minimal Expo/React Native application pre-configured with the GitHub Workflow Blueprint for demonstration and testing purposes.

---

## 📋 Overview

This example demonstrates:
- ✅ Expo SDK 50+ with TypeScript
- ✅ React Native development
- ✅ Blueprint workflows pre-configured
- ✅ Example Claude plan (5 mobile tasks)
- ✅ Sample test data (issues, PRs)
- ✅ Works with Expo Go

**Perfect for**:
- Mobile app development with blueprint
- React Native project automation
- Learning mobile-specific workflows
- Cross-platform development demos

---

## 🚀 Quick Start

### Prerequisites
- Node.js 20+
- pnpm 9+ (or npm/yarn)
- Expo CLI (`npm install -g expo-cli`)
- Expo Go app on iOS/Android device
- GitHub CLI (`gh`) authenticated
- Git configured

### Installation

```bash
# 1. Navigate to this example
cd examples/mobile

# 2. Install dependencies
pnpm install

# 3. Start Expo dev server
pnpm start
```

Scan the QR code with your device's camera (iOS) or Expo Go app (Android).

---

## 📱 Development

### Run on iOS Simulator
```bash
pnpm ios
```

### Run on Android Emulator
```bash
pnpm android
```

### Run on Web (for testing)
```bash
pnpm web
```

---

## 🔧 Blueprint Setup

### Option 1: Using the Wizard (Recommended)

```bash
# From the repository root
cd ../..
./setup/wizard.sh

# Select:
# - Project type: Mobile (2)
# - Branching strategy: Standard (2)
# - Provide your Project URL
# - Provide your Anthropic API key
```

### Option 2: Manual Setup

```bash
# 1. Create dev branch
git checkout -b dev
git push -u origin dev
git checkout main

# 2. Set secrets
gh secret set PROJECT_URL --body "https://github.com/users/YOUR_USERNAME/projects/1"
gh secret set ANTHROPIC_API_KEY --body "sk-ant-..."

# 3. Run bootstrap
gh workflow run bootstrap.yml

# 4. Verify setup
cd ../..
./setup/validate.sh
```

---

## 📝 Example Workflow

### Step 1: Convert Plan to Issues

The included `plan.json` contains 5 tasks for building a simple notes app.

```bash
# From repository root
claude /plan-to-issues examples/mobile/plan.json

# OR trigger workflow directly
gh workflow run claude-plan-to-issues.yml \
  -f plan_json="$(cat examples/mobile/plan.json)"
```

**Expected**: 5 issues created with mobile-specific labels.

---

### Step 2: View Created Issues

```bash
gh issue list --label "claude-code" --label "platform:mobile"
```

You should see:
- Issue #1: Setup React Native project structure
- Issue #2: Create Note data model with AsyncStorage
- Issue #3: Build Note list screen with FlatList
- Issue #4: Add create/edit/delete Note functionality
- Issue #5: Add note search and filtering

---

### Step 3: Start Working on Issue #1

```bash
# Wait 10 seconds for auto-branch creation
sleep 10

# Fetch new branches
git fetch

# Checkout the auto-created branch
git checkout feature/issue-1-setup-react-native-project-structure
```

---

### Step 4: Implement Feature

```bash
# Create component structure
mkdir -p src/{screens,components,utils}

# Work on the feature
# ...

# Commit changes
claude /commit-smart

# OR manual commit
git add .
git commit -m "feat(structure): setup React Native project structure

- Add screens and components directories
- Configure navigation
- Setup TypeScript
- Add basic layout

Closes #1"
```

---

### Step 5: Create Pull Request

```bash
# Using slash command
claude /create-pr

# OR manual PR
gh pr create \
  --base dev \
  --title "feat(structure): Setup React Native project structure" \
  --body "Closes #1" \
  --label "platform:mobile"
```

---

### Step 6: Monitor Quality Checks

```bash
# Watch PR checks
gh pr checks

# View workflow logs
gh run watch
```

Expected checks:
- ✅ lint
- ✅ typecheck
- ✅ pr-into-dev validation
- ⚠️ mobile-check (if configured)

---

### Step 7: Merge PR

```bash
# Once checks pass
gh pr merge --squash --delete-branch
```

**Automatic Updates**:
- Issue #1 status → "To Deploy"
- Project board → "To Deploy" column
- Source branch deleted

---

### Step 8: Repeat for Other Issues

Follow the same process for issues #2-5.

---

### Step 9: Release to Main

```bash
# Create release PR
claude /release

# OR manual PR
gh pr create \
  --base main \
  --head dev \
  --title "release: Notes App v1.0.0" \
  --body "Initial release with complete note-taking functionality.

## Features
- Project structure (#1)
- Note data model (#2)
- Note list screen (#3)
- CRUD operations (#4)
- Search and filtering (#5)

Closes #1, #2, #3, #4, #5"
```

---

### Step 10: Deploy to Production

```bash
# Merge release PR
gh pr merge --squash

# Build for app stores
pnpm build:ios
pnpm build:android
```

---

## 📦 What's Included

### Application Files

```
examples/mobile/
├── README.md (this file)
├── package.json (Expo SDK 50, TypeScript)
├── app.json (Expo configuration)
├── babel.config.js (Babel for Expo)
├── tsconfig.json (TypeScript configuration)
├── .gitignore (Standard React Native gitignore)
├── App.tsx (Main app component)
├── src/
│   ├── screens/
│   │   └── HomeScreen.tsx (Demo home screen)
│   ├── components/
│   │   └── Card.tsx (Reusable card component)
│   └── types/
│       └── index.ts (TypeScript types)
├── plan.json (5-task mobile plan)
└── test-data/
    ├── example-issue.json
    └── example-pr.json
```

### Blueprint Files (from root)

The blueprint workflows are located in the repository root:
- `.github/workflows/` - 8 core workflows
- `.github/actions/` - 5 composite actions
- `.claude/commands/github/` - 8 slash commands
- `.claude/agents/` - 4 specialized agents

---

## 🧪 Testing

### Run Linter
```bash
pnpm lint
```

### Type Check
```bash
pnpm type-check
```

### Test on Device
```bash
# Scan QR code or:
pnpm ios   # iOS simulator
pnpm android  # Android emulator
```

---

## 📊 Example Plan Details

The included `plan.json` contains 5 tasks for building a simple notes app:

### Task 1: Project Structure
- Setup React Native navigation
- Configure TypeScript
- Create directory structure
- Add basic layout

### Task 2: Data Model
- Define Note interface
- Setup AsyncStorage
- Create data utilities
- Add sample data

### Task 3: List Screen
- Build NoteList screen
- Add FlatList component
- Style with StyleSheet
- Handle empty state

### Task 4: CRUD Operations
- Add note creation form
- Implement edit functionality
- Add delete with confirmation
- Update AsyncStorage

### Task 5: Search & Filter
- Add search bar
- Implement search logic
- Add filter options
- Show search results

**Dependencies**: Tasks 3, 4, and 5 depend on Task 2 (data model).

---

## 🔍 Test Data

### example-issue.json

Sample issue format for mobile tasks:

```json
{
  "title": "Setup React Native project structure",
  "body": "## Description\nConfigure React Native project...",
  "labels": ["claude-code", "status:ready", "type:feature", "platform:mobile"],
  "milestone": "Notes App MVP"
}
```

### example-pr.json

Sample PR format:

```json
{
  "title": "feat(structure): Setup React Native project structure",
  "body": "## Summary\n...\n\nCloses #1",
  "base": "dev",
  "head": "feature/issue-1-setup-react-native-project-structure",
  "labels": ["type:feature", "platform:mobile"]
}
```

---

## 🎓 Learning Resources

### Blueprint Documentation

- **Quick Start**: `../../docs/QUICK_START.md`
- **Complete Setup**: `../../docs/COMPLETE_SETUP.md`
- **Workflows Reference**: `../../docs/WORKFLOWS.md`
- **Commands Reference**: `../../docs/COMMANDS.md`
- **Troubleshooting**: `../../docs/TROUBLESHOOTING.md`

### Mobile-Specific

- **Expo Documentation**: https://docs.expo.dev
- **React Native**: https://reactnative.dev
- **Mobile Workflow Config**: `../../setup/configs/standard-mobile.json`

---

## 🐛 Troubleshooting

### Issue: "Expo Go not connecting"

**Cause**: Device and computer on different networks

**Solution**: Ensure both are on same WiFi network or use tunnel mode

```bash
pnpm start --tunnel
```

---

### Issue: "Metro bundler error"

**Cause**: Cached files causing issues

**Solution**: Clear cache and restart

```bash
pnpm start --clear
```

---

### Issue: "TypeScript errors in Expo"

**Cause**: TypeScript configuration mismatch

**Solution**: Ensure correct TypeScript version

```bash
pnpm add -D typescript@~5.3.0
```

---

### Issue: Mobile checks fail in CI

**Cause**: mobile_check not configured

**Solution**: Update workflow configuration

```yaml
# .github/workflows/pr-into-dev.yml
- uses: ./.github/workflows/reusable-pr-checks.yml
  with:
    mobile_check: true  # Enable mobile checks
```

---

## 🔄 Reset Example

To reset this example:

```bash
# Delete all issues
gh issue list --label "claude-code" --label "platform:mobile" \
  --json number --jq '.[].number' | xargs -I {} gh issue close {}

# Delete dev branch
git push origin --delete dev

# Delete feature branches
git branch -r | grep "origin/feature/" | \
  sed 's/origin\///' | xargs -I {} git push origin --delete {}

# Re-run setup
cd ../..
./setup/wizard.sh
```

---

## 📱 Mobile-Specific Features

### AsyncStorage

This example uses AsyncStorage for data persistence:

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

// Save data
await AsyncStorage.setItem('notes', JSON.stringify(notes));

// Load data
const data = await AsyncStorage.getItem('notes');
const notes = data ? JSON.parse(data) : [];
```

### Navigation

Uses React Navigation for screen management:

```typescript
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### Platform-Specific Code

Handle iOS/Android differences:

```typescript
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.OS === 'ios' ? 20 : 0,
  },
});
```

---

## 🎯 Next Steps

1. **Complete the workflow**: Follow Steps 1-10 to experience mobile development
2. **Customize**: Modify `plan.json` for your app ideas
3. **Add features**: Expand beyond the basic example
4. **Test on devices**: Use Expo Go for real device testing
5. **Build for stores**: Prepare iOS/Android releases

---

## 📝 Notes

- This is a **minimal example** - production apps need more (authentication, backend API, push notifications)
- Focuses on **workflow demonstration** with React Native
- All components intentionally simple
- Expo makes mobile development accessible
- Can eject to bare React Native if needed

---

## 🤝 Contributing

Found an issue or improvement?
1. Create an issue describing the problem
2. Submit a PR with the fix
3. Follow the blueprint workflow!

---

## 📄 License

Same as the parent repository - see `../../LICENSE`

---

**Generated with [Claude Code](https://claude.com/claude-code)**

**Co-Authored-By**: Claude <noreply@anthropic.com>
