# Phase 4: GitHub App Authentication Support - Detailed Work Plan

**Status**: 📋 **PLANNED**
**Started**: TBD
**Estimated Duration**: 8-10 hours
**Priority**: HIGH
**Last Updated**: 2025-11-07

---

## 🎯 Phase 4 Objectives

Add comprehensive GitHub App authentication support to make setup easier and faster:
- ✅ GitHub App installation as **primary recommended method** (`/install-github-app`)
- ✅ API Key authentication as **fallback option** (existing implementation)
- ✅ OAuth Token authentication **properly documented** (existing partial implementation)
- ✅ Reduce setup time from **8-10 minutes to 2-3 minutes** (GitHub App path)
- ✅ Align with official Claude Code Action recommendations
- ✅ Maintain backward compatibility with existing API key users

---

## 📊 Current State Analysis

### What's Working ✅
- **ANTHROPIC_API_KEY**: Fully implemented across all workflows, setup wizard, and documentation
- **CLAUDE_CODE_OAUTH_TOKEN**: Partially implemented (one workflow only), minimally documented

### What's Missing ❌
- **GitHub App (`/install-github-app`)**: Not mentioned anywhere in blueprint
- **Authentication choice**: Setup wizard forces API key only, no menu/options
- **Comprehensive OAuth docs**: OAuth token barely documented, not integrated in wizard
- **Authentication comparison**: No guidance on which method to choose

### Impact
- Users spend **8-10 minutes** on manual API key setup instead of **2-3 minutes** with GitHub App
- Blueprint doesn't reflect **official "best practice"** from Claude Code Action docs
- Higher error rate due to manual secret entry (typos, validation issues)
- Pro/Max users unaware they could use subscription quota instead of API billing

---

## 🏗️ Implementation Strategy

### Priority Order (User Decisions)
1. **GitHub App**: Primary/Default (recommended first, API key fallback) ✅
2. **OAuth Token**: Document only (no workflow changes) ✅
3. **Enterprise methods**: Skip for now (AWS Bedrock, GCP Vertex AI) ❌
4. **Delivery**: High priority - comprehensive implementation ✅

### Architecture
```
Authentication Options
├── 1. GitHub App (PRIMARY - Recommended)
│   ├── One-command setup: /install-github-app
│   ├── Automatic secret configuration
│   ├── Most secure (OIDC-based)
│   └── Fastest: 2-3 minutes
│
├── 2. API Key (FALLBACK - Manual)
│   ├── Manual setup via Anthropic Console
│   ├── Manual secret configuration
│   ├── Current implementation (keep as-is)
│   └── Slower: 8-10 minutes
│
└── 3. OAuth Token (ALTERNATIVE - Pro/Max)
    ├── For subscription-based users
    ├── Setup via: claude setup-token
    ├── Document only (no workflow changes)
    └── Medium: 5-7 minutes
```

---

## 🔧 Work Packages

### **Work Package 4.1: Documentation Updates** (Priority: CRITICAL)
**Estimated Time**: 3-4 hours
**Dependencies**: None (can start immediately)
**Deliverables**: 6 updated documentation files

---

#### WP4.1.1: Update `GITHUB_SETUP.md` (60 minutes)
**Purpose**: Make GitHub App the recommended method in primary setup guide

**Tasks**:
- [ ] Add new **Section 0: GitHub App Installation (RECOMMENDED)** before current Section 1
  - [ ] Step-by-step guide for `/install-github-app`
  - [ ] Screenshot placeholders or ASCII diagrams of the flow
  - [ ] Prerequisites (Claude Code CLI installed)
  - [ ] Troubleshooting subsection (app installation failures)
- [ ] Restructure existing sections:
  - [ ] Section 1: Rename "ANTHROPIC_API_KEY" → "Alternative: Manual API Key Setup"
  - [ ] Section 2: Keep "PROJECTS_TOKEN" as-is (no changes)
  - [ ] Section 3: Expand "CLAUDE_CODE_OAUTH_TOKEN" → "Alternative: OAuth Token (Pro/Max Only)"
    - [ ] Add detailed setup instructions using `claude setup-token`
    - [ ] Explain Pro/Max requirement
    - [ ] Add troubleshooting
- [ ] Add **Authentication Comparison Table** at the very top (before Section 0):
  ```markdown
  | Method | Setup Time | Complexity | Best For | Requirements |
  |--------|------------|------------|----------|--------------|
  | GitHub App | 2-3 min | Low | Everyone (default) | Claude Code CLI |
  | API Key | 8-10 min | Medium | Manual control | Anthropic Console access |
  | OAuth Token | 5-7 min | Medium | Pro/Max users | Claude Pro/Max subscription |
  ```
- [ ] Update table of contents with new sections
- [ ] Add cross-references between sections ("Not using GitHub App? See Alternative methods...")

**Acceptance Criteria**:
- ✅ GitHub App appears first and prominently
- ✅ Comparison table helps users choose
- ✅ All three methods fully documented
- ✅ Clear navigation between options
- ✅ Troubleshooting for each method

**Testing**:
```bash
# Verify file structure
cat GITHUB_SETUP.md | grep "^##"
# Should show: Section 0 (GitHub App), Section 1 (API Key), Section 2 (PROJECTS_TOKEN), Section 3 (OAuth)
```

---

#### WP4.1.2: Update `docs/QUICK_START.md` (30 minutes)
**Purpose**: Show fastest path (GitHub App) in quick start guide

**Tasks**:
- [ ] Locate **Step 2: Authentication** (currently around line 65)
- [ ] Rewrite to show GitHub App first:
  ```markdown
  ## Step 2: Set Up Authentication (2 minutes)

  **Option 1: GitHub App (RECOMMENDED - Easiest)**

  In Claude Code CLI, run:
  ```bash
  /install-github-app
  ```

  Follow the prompts to authorize the app. Secrets configured automatically! ✨

  **Option 2: Manual API Key (If you prefer manual setup)**

  ```bash
  gh secret set ANTHROPIC_API_KEY
  ```

  Get your API key from https://console.anthropic.com/settings/keys

  **Option 3: OAuth Token (Pro/Max users only)**

  In Claude Code CLI, run:
  ```bash
  claude setup-token
  gh secret set CLAUDE_CODE_OAUTH_TOKEN
  ```
  ```
- [ ] Update **time estimate**: Change "5 minutes" → "2-3 minutes"
- [ ] Update **total Quick Start time**: Change from current → "Under 5 minutes total"
- [ ] Add note: "Don't have Claude Code CLI? See [Complete Setup Guide](COMPLETE_SETUP.md) for alternatives."

**Acceptance Criteria**:
- ✅ GitHub App shown first with "RECOMMENDED" badge
- ✅ All three options present but GitHub App emphasized
- ✅ Time savings highlighted (2 min vs 8 min)
- ✅ Clear call-to-action for each method

**Testing**:
```bash
# Verify structure
grep -A 10 "Step 2:" docs/QUICK_START.md
```

---

#### WP4.1.3: Update `docs/COMPLETE_SETUP.md` (60 minutes)
**Purpose**: Provide detailed authentication paths for all methods

**Tasks**:
- [ ] Locate **Section 4: Authentication Setup** (currently around lines 402-416)
- [ ] Complete rewrite with three authentication paths:

  **Path 1: GitHub App Installation (Primary)**
  - [ ] Detailed walkthrough with numbered steps:
    1. Ensure Claude Code CLI installed (`claude --version`)
    2. Navigate to repository directory
    3. Run `/install-github-app` command
    4. Follow interactive prompts (authorize app, select repository)
    5. Verify secrets created automatically
    6. Test authentication (run sample workflow)
  - [ ] Add troubleshooting subsection:
    - Claude Code CLI not found
    - App authorization fails
    - Secrets not created
    - Permission errors
  - [ ] Add "What secrets are created?" explanation

  **Path 2: Manual API Key Setup (Fallback)**
  - [ ] Keep existing detailed content for API key
  - [ ] Clearly mark as "Alternative Method"
  - [ ] Add when to use: "Use this if you don't have Claude Code CLI or prefer manual control"

  **Path 3: OAuth Token Setup (Pro/Max)**
  - [ ] New detailed section:
    1. Verify Pro/Max subscription active
    2. Run `claude setup-token` locally
    3. Copy generated token
    4. Set as GitHub secret: `gh secret set CLAUDE_CODE_OAUTH_TOKEN`
    5. Verify token works
  - [ ] Explain Pro/Max requirement clearly
  - [ ] Add troubleshooting: token expiration, subscription lapsed, etc.

- [ ] Add **Decision Tree Diagram** before the three paths:
  ```
  Which authentication method should I use?

  START
    ↓
  Do you have Claude Code CLI installed?
    ├─ YES → Go with GitHub App (fastest, easiest) ✅
    └─ NO → Continue
         ↓
       Do you have Claude Pro or Max subscription?
         ├─ YES → Use OAuth Token (uses subscription quota)
         └─ NO → Use API Key (manual setup)
  ```

**Acceptance Criteria**:
- ✅ Three complete authentication paths documented
- ✅ Decision tree helps users choose
- ✅ Troubleshooting for each path
- ✅ Clear prerequisites for each method
- ✅ Step-by-step instructions with validation

**Testing**:
```bash
# Verify section exists
grep -A 50 "Section 4:" docs/COMPLETE_SETUP.md
```

---

#### WP4.1.4: Update `README.md` (30 minutes)
**Purpose**: Surface authentication options early in main README

**Tasks**:
- [ ] **Requirements section** (~line 295): Add Claude Code CLI to requirements
  ```markdown
  **Minimum Requirements**:
  - GitHub account with repository admin access
  - GitHub CLI (`gh`) installed and authenticated
  - **Claude Code CLI installed** (for easiest setup via `/install-github-app`)
  - Git installed (v2.23+)
  ...
  ```
- [ ] **Quick Start section** (~lines 40-52): Update step 2 to mention GitHub App
  ```markdown
  # 2. Run the interactive setup wizard
  ./setup/wizard.sh
  # Choose "GitHub App" for fastest setup (2-3 minutes)
  ```
- [ ] **Features section** (~line 23): Add new bullet point
  ```markdown
  - 🔐 **Multiple Authentication Methods** - GitHub App (2 min), API Key, or OAuth
  ```
- [ ] Add new section **"Authentication Options"** after Requirements section (~line 308):
  ```markdown
  ## 🔐 Authentication Options

  Choose the authentication method that works best for you:

  | Method | Setup Time | Best For |
  |--------|------------|----------|
  | **GitHub App** | 2-3 min | Everyone (recommended) |
  | **API Key** | 8-10 min | Manual control preferred |
  | **OAuth Token** | 5-7 min | Pro/Max subscribers |

  See [GitHub Setup Guide](GITHUB_SETUP.md) for detailed instructions.
  ```

**Acceptance Criteria**:
- ✅ Authentication options visible early
- ✅ GitHub App mentioned in requirements
- ✅ Quick comparison table helps users decide
- ✅ Link to detailed setup guide

**Testing**:
```bash
# Verify sections exist
grep -E "Authentication|🔐" README.md
```

---

#### WP4.1.5: Update `docs/ARCHITECTURE.md` (45 minutes)
**Purpose**: Document authentication architecture and security model

**Tasks**:
- [ ] Add new section **"Authentication Architecture"** after "System Components" section
- [ ] Document three authentication flows with diagrams:

  **GitHub App Flow**:
  ```
  User → Claude Code CLI → /install-github-app →
  GitHub App Authorization → OIDC Token Exchange →
  Secrets Auto-Configured → Workflows Authenticate
  ```

  **API Key Flow**:
  ```
  User → Anthropic Console → Create API Key →
  Copy Key → Setup Wizard → Manual Entry →
  gh secret set → Workflows Use ANTHROPIC_API_KEY
  ```

  **OAuth Token Flow**:
  ```
  User → Claude Code CLI → claude setup-token →
  Token Generated → Copy Token →
  gh secret set → Workflows Use CLAUDE_CODE_OAUTH_TOKEN
  ```

- [ ] Add **Security Model** subsection:
  - GitHub App: OIDC-based, scoped permissions, auto-rotated
  - API Key: Long-lived, manual rotation required
  - OAuth Token: Session-based, may expire, regenerate via CLI

- [ ] Add **When to Use Which Method** decision matrix:
  ```markdown
  | Scenario | Recommended Method | Why |
  |----------|-------------------|-----|
  | First-time user | GitHub App | Fastest, easiest |
  | CI/CD automation | API Key | Predictable, long-lived |
  | Pro/Max subscriber | OAuth Token | Uses subscription quota |
  | Enterprise with AWS | API Key + Bedrock | Cloud integration |
  | Air-gapped environment | API Key | No external dependencies |
  ```

**Acceptance Criteria**:
- ✅ Clear architecture diagrams for all flows
- ✅ Security model explained
- ✅ Decision matrix helps advanced users
- ✅ Technical details for each method

**Testing**:
```bash
# Verify section exists
grep -A 30 "Authentication Architecture" docs/ARCHITECTURE.md
```

---

#### WP4.1.6: Update `docs/TROUBLESHOOTING.md` (45 minutes)
**Purpose**: Add authentication troubleshooting for all methods

**Tasks**:
- [ ] Add new section **"Authentication Issues"** early in document (after common issues)
- [ ] Subsection: **GitHub App Installation Problems**
  ```markdown
  ### GitHub App: Installation Fails

  **Symptom**: `/install-github-app` command not found or fails

  **Solutions**:
  1. Verify Claude Code CLI installed: `claude --version`
  2. Update to latest version: `brew upgrade claude-code` (macOS)
  3. Check you're in repository root directory
  4. Ensure you have admin access to repository
  5. Try manual API key method as fallback

  **Symptom**: App authorized but secrets not created

  **Solutions**:
  1. Check GitHub Actions permissions: Settings → Actions → Workflow permissions
  2. Verify repository has Issues, Projects enabled
  3. Re-run: `/install-github-app --force`
  4. Manual fallback: Set secrets manually via `gh secret set`
  ```

- [ ] Subsection: **API Key Validation Errors**
  ```markdown
  ### API Key: Validation Fails

  **Symptom**: "Invalid API key format" error in setup wizard

  **Solutions**:
  1. Verify key starts with `sk-ant-`
  2. Check for extra spaces/newlines when pasting
  3. Regenerate key in Anthropic Console if corrupted
  4. Use `gh secret set ANTHROPIC_API_KEY` directly (bypass wizard)

  **Symptom**: "Unauthorized" errors in workflow runs

  **Solutions**:
  1. Verify secret is set: `gh secret list`
  2. Check API key is still valid in Anthropic Console
  3. Verify billing is active (API access requires payment)
  4. Regenerate key and update secret
  ```

- [ ] Subsection: **OAuth Token Issues**
  ```markdown
  ### OAuth Token: Token Expired or Invalid

  **Symptom**: "Authentication failed" in workflows after some time

  **Solutions**:
  1. Regenerate token: `claude setup-token`
  2. Update secret: `gh secret set CLAUDE_CODE_OAUTH_TOKEN`
  3. Verify Pro/Max subscription is active
  4. Check token format is correct (no extra characters)

  **Symptom**: `claude setup-token` command fails

  **Solutions**:
  1. Ensure you have Pro or Max plan (Free plan not supported)
  2. Update Claude Code CLI to latest version
  3. Check internet connection (needs to reach Claude API)
  4. Fallback to API key method if OAuth not working
  ```

- [ ] Subsection: **Switching Authentication Methods**
  ```markdown
  ### How to Switch Between Authentication Methods

  **From API Key → GitHub App**:
  1. Run `/install-github-app`
  2. Old API key secret remains but won't be used
  3. Optional: Remove old secret: `gh secret delete ANTHROPIC_API_KEY`

  **From GitHub App → API Key**:
  1. Get API key from Anthropic Console
  2. Set secret: `gh secret set ANTHROPIC_API_KEY`
  3. Workflows will prefer API key over GitHub App

  **From OAuth → API Key/GitHub App**:
  1. Set new authentication method
  2. Delete OAuth secret: `gh secret delete CLAUDE_CODE_OAUTH_TOKEN`
  ```

**Acceptance Criteria**:
- ✅ Common issues for each auth method documented
- ✅ Clear step-by-step solutions
- ✅ Migration paths between methods
- ✅ Fallback options provided

**Testing**:
```bash
# Verify section exists
grep -A 10 "Authentication Issues" docs/TROUBLESHOOTING.md
```

---

### **Work Package 4.2: Setup Wizard Enhancement** (Priority: HIGH)
**Estimated Time**: 2-3 hours
**Dependencies**: WP4.1 (documentation provides reference)
**Deliverables**: Enhanced `setup/wizard.sh` with authentication menu

---

#### WP4.2.1: Restructure Authentication Step in Wizard (90 minutes)
**Purpose**: Add interactive menu for choosing authentication method

**Current Code Location**: `setup/wizard.sh`, lines 350-398 (Step 5: ANTHROPIC_API_KEY)

**Tasks**:
- [ ] **Backup current implementation**:
  ```bash
  # Extract current API key function for reuse
  # Lines 350-398 → new function setup_api_key()
  ```

- [ ] **Create new Step 5 with authentication menu** (replace lines 350-398):
  ```bash
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  🔑 Step 5: Authentication Setup"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Choose authentication method:"
  echo ""
  echo "  1️⃣  GitHub App (RECOMMENDED - Easiest)"
  echo "      ⏱️  Setup time: 2-3 minutes"
  echo "      🔒 Security: OIDC-based, auto-managed"
  echo "      ✅ Requires: Claude Code CLI installed"
  echo ""
  echo "  2️⃣  API Key (Manual Setup)"
  echo "      ⏱️  Setup time: 8-10 minutes"
  echo "      🔑 Security: Long-lived key, manual rotation"
  echo "      ✅ Requires: Anthropic Console account"
  echo ""
  echo "  3️⃣  OAuth Token (Pro/Max Only)"
  echo "      ⏱️  Setup time: 5-7 minutes"
  echo "      💎 Security: Subscription-based, may expire"
  echo "      ✅ Requires: Claude Pro or Max plan"
  echo ""
  read -p "Enter choice (1-3) [1]: " AUTH_CHOICE
  AUTH_CHOICE=${AUTH_CHOICE:-1}

  case $AUTH_CHOICE in
    1)
      setup_github_app
      ;;
    2)
      setup_api_key
      ;;
    3)
      setup_oauth_token
      ;;
    *)
      error "❌ Invalid choice. Please enter 1, 2, or 3."
      exit 1
      ;;
  esac
  ```

- [ ] **Add authentication method to wizard state** (for summary):
  ```bash
  # Store chosen method in variable
  WIZARD_AUTH_METHOD=""  # Will be set by each setup function
  ```

**Acceptance Criteria**:
- ✅ Clear menu with visual hierarchy (emojis, indentation)
- ✅ Default choice is GitHub App (option 1)
- ✅ Each option shows time estimate and requirements
- ✅ Invalid input rejected with helpful error
- ✅ Chosen method stored for final summary

**Testing**:
```bash
# Run wizard and test menu
./setup/wizard.sh
# Verify: Menu displays correctly, default works, invalid input rejected
```

---

#### WP4.2.2: Implement `setup_github_app()` Function (60 minutes)
**Purpose**: Guide user through GitHub App installation process

**Tasks**:
- [ ] Create new function after current Step 5 (~line 400):
  ```bash
  setup_github_app() {
    echo ""
    echo "🚀 Setting up GitHub App authentication..."
    echo ""

    # Check 1: Verify Claude Code CLI installed
    if ! command -v claude &> /dev/null; then
      echo "⚠️  Claude Code CLI not found."
      echo ""
      echo "📥 Please install Claude Code CLI first:"
      echo "   • macOS: brew install claude-code"
      echo "   • Linux: See https://docs.anthropic.com/claude-code"
      echo ""
      read -p "Install CLI and press Enter to continue, or type 'skip' to use API Key: " SKIP_APP
      if [[ "$SKIP_APP" == "skip" ]]; then
        echo "Switching to API Key method..."
        setup_api_key
        return
      fi

      # Re-check after user installs
      if ! command -v claude &> /dev/null; then
        error "Claude Code CLI still not found. Please install and try again."
        exit 1
      fi
    fi

    # Check 2: Verify CLI version (minimum requirement if needed)
    CLAUDE_VERSION=$(claude --version | head -n1)
    echo "✅ Claude Code CLI found: $CLAUDE_VERSION"
    echo ""

    # Check 3: Prompt user to run /install-github-app
    echo "📋 Next steps:"
    echo ""
    echo "1. In a separate terminal, navigate to this directory:"
    echo "   cd $(pwd)"
    echo ""
    echo "2. Open Claude Code CLI:"
    echo "   claude"
    echo ""
    echo "3. Run the installation command:"
    echo "   /install-github-app"
    echo ""
    echo "4. Follow the prompts to authorize the GitHub App"
    echo "   (this will open a browser window)"
    echo ""
    echo "5. Once complete, return here and press Enter"
    echo ""

    read -p "Press Enter after running /install-github-app... " WAIT

    # Check 4: Validate secrets were created
    echo ""
    echo "🔍 Validating authentication setup..."

    # Check for secrets (gh CLI shows names only, not values)
    if gh secret list | grep -q "ANTHROPIC_API_KEY\|CLAUDE_CODE_OAUTH_TOKEN"; then
      echo "✅ Authentication secrets found!"
      WIZARD_AUTH_METHOD="GitHub App"
    else
      echo "⚠️  No authentication secrets found."
      echo ""
      read -p "Did /install-github-app complete successfully? (y/n): " APP_SUCCESS
      if [[ "$APP_SUCCESS" != "y" ]]; then
        echo ""
        echo "Let's try the manual API Key method instead..."
        setup_api_key
        return
      else
        echo "⚠️  Proceeding, but you may need to set secrets manually later."
        WIZARD_AUTH_METHOD="GitHub App (manual verification needed)"
      fi
    fi

    echo ""
    success "GitHub App authentication configured!"
  }
  ```

- [ ] Add error handling for edge cases:
  - [ ] Claude CLI not found → offer to install or fallback to API key
  - [ ] User can't complete /install-github-app → fallback to API key
  - [ ] Secrets not detected → warn but continue (user might have set manually)

**Acceptance Criteria**:
- ✅ Checks for Claude Code CLI before proceeding
- ✅ Clear instructions for user to follow
- ✅ Validates secrets were created
- ✅ Offers fallback to API key if GitHub App fails
- ✅ User-friendly error messages

**Testing**:
```bash
# Test with Claude CLI installed
./setup/wizard.sh
# Select option 1, verify instructions clear

# Test without Claude CLI
brew unlink claude-code  # Temporarily hide CLI
./setup/wizard.sh
# Select option 1, verify fallback offered
brew link claude-code  # Restore
```

---

#### WP4.2.3: Refactor Existing API Key Code into `setup_api_key()` Function (30 minutes)
**Purpose**: Extract current API key implementation into reusable function

**Tasks**:
- [ ] Copy lines 350-398 (current Step 5 API key code)
- [ ] Create new function `setup_api_key()` around line 450:
  ```bash
  setup_api_key() {
    echo ""
    echo "🔑 Setting up API Key authentication..."
    echo ""

    # [PASTE EXISTING CODE FROM LINES 350-398 HERE]
    # Keep all validation, error handling, etc.

    # Add at end:
    WIZARD_AUTH_METHOD="API Key"
  }
  ```

- [ ] Update function to use consistent messaging:
  - Change "Step 5:" → (remove step number, it's now a function)
  - Keep all existing validation logic
  - Keep gh secret set command

- [ ] Test that extracted function works identically to original

**Acceptance Criteria**:
- ✅ Existing API key flow works exactly as before
- ✅ Code is in a reusable function
- ✅ Sets WIZARD_AUTH_METHOD variable
- ✅ No regression in functionality

**Testing**:
```bash
# Test API key method still works
./setup/wizard.sh
# Select option 2 (API Key)
# Verify: Same experience as before refactoring
```

---

#### WP4.2.4: Implement `setup_oauth_token()` Function (45 minutes)
**Purpose**: Add OAuth token setup for Pro/Max users

**Tasks**:
- [ ] Create new function after `setup_api_key()` (~line 500):
  ```bash
  setup_oauth_token() {
    echo ""
    echo "💎 Setting up OAuth Token authentication (Pro/Max only)..."
    echo ""

    # Check 1: Verify Claude Code CLI installed
    if ! command -v claude &> /dev/null; then
      echo "⚠️  Claude Code CLI not found."
      echo ""
      echo "OAuth Token setup requires Claude Code CLI."
      echo ""
      read -p "Switch to API Key method instead? (y/n): " SWITCH_API
      if [[ "$SWITCH_API" == "y" ]]; then
        setup_api_key
        return
      else
        error "Cannot proceed without Claude Code CLI."
        exit 1
      fi
    fi

    # Check 2: Verify Pro/Max subscription (can't check programmatically, just warn)
    echo "⚠️  OAuth Token requires Claude Pro or Max subscription."
    echo ""
    read -p "Do you have an active Pro or Max subscription? (y/n): " HAS_SUB
    if [[ "$HAS_SUB" != "y" ]]; then
      echo ""
      echo "OAuth Token is only available for Pro/Max subscribers."
      echo "Let's use API Key method instead..."
      echo ""
      setup_api_key
      return
    fi

    # Check 3: Prompt user to generate token
    echo ""
    echo "📋 Next steps:"
    echo ""
    echo "1. In a separate terminal, run:"
    echo "   claude setup-token"
    echo ""
    echo "2. Follow the prompts to generate your OAuth token"
    echo ""
    echo "3. Copy the generated token"
    echo ""
    echo "4. Return here and paste the token when prompted"
    echo ""

    read -p "Press Enter after running 'claude setup-token'... " WAIT

    # Check 4: Prompt for token
    echo ""
    echo "Please paste your OAuth token below:"
    echo "(Input will be hidden for security)"
    echo ""
    read -s -p "OAuth Token: " OAUTH_TOKEN
    echo ""

    # Check 5: Basic validation (should be non-empty, reasonable length)
    if [[ -z "$OAUTH_TOKEN" ]]; then
      error "OAuth token cannot be empty."
      exit 1
    fi

    if [[ ${#OAUTH_TOKEN} -lt 20 ]]; then
      echo "⚠️  Warning: Token seems unusually short. Please verify it's correct."
      read -p "Continue anyway? (y/n): " CONTINUE
      if [[ "$CONTINUE" != "y" ]]; then
        exit 1
      fi
    fi

    # Check 6: Set secret via gh CLI
    echo ""
    echo "🔒 Setting CLAUDE_CODE_OAUTH_TOKEN secret..."

    if echo "$OAUTH_TOKEN" | gh secret set CLAUDE_CODE_OAUTH_TOKEN; then
      success "OAuth token secret set successfully!"
      WIZARD_AUTH_METHOD="OAuth Token"
    else
      error "Failed to set secret. Please check gh CLI authentication."
      exit 1
    fi

    echo ""
    echo "✅ OAuth Token authentication configured!"
  }
  ```

- [ ] Add Pro/Max subscription check (informational warning)
- [ ] Validate token format (basic length check)
- [ ] Set secret via gh CLI
- [ ] Offer fallback to API key if user doesn't have subscription

**Acceptance Criteria**:
- ✅ Checks for Claude CLI before proceeding
- ✅ Warns about Pro/Max requirement
- ✅ Clear instructions for token generation
- ✅ Validates token (basic checks)
- ✅ Sets CLAUDE_CODE_OAUTH_TOKEN secret
- ✅ Offers fallback to API key if needed

**Testing**:
```bash
# Test OAuth flow (requires Pro/Max subscription)
./setup/wizard.sh
# Select option 3, verify prompts and flow

# Test without subscription
./setup/wizard.sh
# Select option 3, answer "no" to subscription question, verify fallback
```

---

#### WP4.2.5: Update Wizard Summary to Show Authentication Method (15 minutes)
**Purpose**: Display chosen authentication method in final summary

**Tasks**:
- [ ] Locate final summary section (lines ~570-615)
- [ ] Add authentication method display:
  ```bash
  echo "  Authentication: $WIZARD_AUTH_METHOD"
  ```

- [ ] Add auth-specific notes based on method:
  ```bash
  if [[ "$WIZARD_AUTH_METHOD" == "GitHub App" ]]; then
    echo ""
    echo "  🔐 GitHub App configured (OIDC-based, auto-managed)"
  elif [[ "$WIZARD_AUTH_METHOD" == "API Key" ]]; then
    echo ""
    echo "  🔑 API Key configured (remember to rotate periodically)"
  elif [[ "$WIZARD_AUTH_METHOD" == "OAuth Token" ]]; then
    echo ""
    echo "  💎 OAuth Token configured (uses Pro/Max subscription quota)"
  fi
  ```

**Acceptance Criteria**:
- ✅ Summary shows which auth method was chosen
- ✅ Method-specific notes displayed
- ✅ Consistent formatting with rest of summary

**Testing**:
```bash
# Run wizard with each auth method
# Verify summary shows correct method and notes
```

---

### **Work Package 4.3: Update Validation Script** (Priority: MEDIUM)
**Estimated Time**: 45 minutes
**Dependencies**: WP4.2 (wizard creates auth method)
**Deliverables**: Enhanced `setup/validate.sh` with auth validation

---

#### WP4.3.1: Add Authentication Detection in Validation Script (30 minutes)
**Purpose**: Detect which authentication method is configured and validate it

**Tasks**:
- [ ] Locate `setup/validate.sh`
- [ ] Add new validation section after secret checks (around line 100):
  ```bash
  # ─────────────────────────────────────────────────────────────────
  # Authentication Method Detection & Validation
  # ─────────────────────────────────────────────────────────────────
  echo ""
  echo "🔍 Checking authentication configuration..."
  echo ""

  # Check which secrets are set
  SECRETS=$(gh secret list --json name -q '.[].name')
  HAS_API_KEY=$(echo "$SECRETS" | grep -c "ANTHROPIC_API_KEY" || true)
  HAS_OAUTH=$(echo "$SECRETS" | grep -c "CLAUDE_CODE_OAUTH_TOKEN" || true)

  # Determine authentication method
  if [[ $HAS_API_KEY -gt 0 ]]; then
    echo "✅ API Key authentication detected (ANTHROPIC_API_KEY)"
    AUTH_METHOD="API Key"
  elif [[ $HAS_OAUTH -gt 0 ]]; then
    echo "✅ OAuth Token authentication detected (CLAUDE_CODE_OAUTH_TOKEN)"
    AUTH_METHOD="OAuth Token"
  else
    echo "⚠️  No authentication secrets found!"
    echo ""
    echo "Expected one of:"
    echo "  • ANTHROPIC_API_KEY (API Key method)"
    echo "  • CLAUDE_CODE_OAUTH_TOKEN (OAuth Token method)"
    echo ""
    echo "If you used GitHub App, secrets should be set automatically."
    echo "Run: gh secret list"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
    AUTH_METHOD="None"
  fi
  ```

- [ ] Add authentication test (optional, if possible):
  ```bash
  # Test authentication by triggering a simple workflow
  # (Only if safe to do so without spamming API)
  ```

**Acceptance Criteria**:
- ✅ Detects which auth method is configured
- ✅ Validates at least one auth secret exists
- ✅ Clear error if no auth found
- ✅ Adds to validation error count if missing

**Testing**:
```bash
# Test with API key set
gh secret set ANTHROPIC_API_KEY
./setup/validate.sh
# Verify: Detects API Key method

# Test with OAuth token
gh secret delete ANTHROPIC_API_KEY
gh secret set CLAUDE_CODE_OAUTH_TOKEN
./setup/validate.sh
# Verify: Detects OAuth Token method

# Test with no secrets
gh secret delete CLAUDE_CODE_OAUTH_TOKEN
./setup/validate.sh
# Verify: Shows warning about missing auth
```

---

#### WP4.3.2: Add Authentication Method to Validation Summary (15 minutes)
**Purpose**: Show authentication method in final validation report

**Tasks**:
- [ ] Locate final summary section (end of validate.sh)
- [ ] Add authentication method display:
  ```bash
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  📊 Validation Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  Repository: $REPO_NAME"
  echo "  Branching: $BRANCHING_STRATEGY"
  echo "  Authentication: $AUTH_METHOD"  # NEW
  echo "  Errors: $VALIDATION_ERRORS"
  echo ""
  ```

**Acceptance Criteria**:
- ✅ Summary includes authentication method
- ✅ Consistent formatting with other summary items

**Testing**:
```bash
# Run full validation
./setup/validate.sh
# Verify: Summary shows auth method
```

---

### **Work Package 4.4: Command & Agent Updates** (Priority: MEDIUM)
**Estimated Time**: 1 hour
**Dependencies**: WP4.1, WP4.2 (wizard and docs provide reference)
**Deliverables**: Updated `/blueprint-init` command and `blueprint-setup` agent

---

#### WP4.4.1: Update `/blueprint-init` Command Documentation (30 minutes)
**Purpose**: Align command docs with new authentication menu

**Tasks**:
- [ ] Open `.claude/commands/github/blueprint-init.md`
- [ ] Locate **Step 5: Authentication** section (lines 116-138)
- [ ] Rewrite to match wizard's authentication menu:
  ```markdown
  ### Step 5: Authentication Setup (2-3 minutes)

  The wizard will prompt you to choose an authentication method:

  **Option 1: GitHub App (Recommended)**
  - One-command setup via `/install-github-app`
  - Automatic secret configuration
  - Fastest method (2-3 minutes)
  - Requires Claude Code CLI installed

  **Option 2: API Key (Manual)**
  - Get from https://console.anthropic.com/settings/keys
  - Manual secret configuration
  - Slower method (8-10 minutes)
  - Works for all users

  **Option 3: OAuth Token (Pro/Max)**
  - Generate via `claude setup-token`
  - Uses subscription quota
  - Medium speed (5-7 minutes)
  - Requires Pro or Max plan

  **The wizard will guide you through your chosen method.**
  ```

- [ ] Update **Expected Output** section (lines 201-202):
  ```markdown
  - ✅ Authentication configured (GitHub App, API Key, or OAuth Token)
  ```

- [ ] Update time estimates in command header (reduce from 10 min to 5 min average)

**Acceptance Criteria**:
- ✅ All three auth methods documented
- ✅ Matches wizard experience
- ✅ Clear pros/cons for each method
- ✅ Time estimates updated

**Testing**:
```bash
# Read command docs
cat .claude/commands/github/blueprint-init.md
# Verify: Auth section matches wizard
```

---

#### WP4.4.2: Update `blueprint-setup` Agent (30 minutes)
**Purpose**: Update agent to handle multiple authentication methods

**Tasks**:
- [ ] Open `.claude/agents/blueprint-setup.md`
- [ ] Locate authentication setup section (around line 120)
- [ ] Update to check for multiple auth methods:
  ```markdown
  ## Step 5: Configure Authentication

  **Objective**: Set up Claude Code authentication

  **Process**:
  1. Check if Claude Code CLI is available
     - If yes: Recommend GitHub App method
     - If no: Use API Key method

  2. For GitHub App:
     - Verify `claude` command exists
     - Prompt user to run `/install-github-app`
     - Wait for confirmation
     - Validate secrets created

  3. For API Key:
     - Prompt for API key
     - Validate format (sk-ant-*)
     - Set via gh secret set

  4. For OAuth Token:
     - Check for Pro/Max subscription
     - Guide through `claude setup-token`
     - Set via gh secret set

  **Validation**:
  - [ ] At least one auth secret exists (ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN)
  - [ ] Secret accessible to workflows
  - [ ] No validation errors

  **Error Handling**:
  - If GitHub App fails: Fallback to API Key
  - If OAuth fails: Fallback to API Key
  - If all fail: Exit with clear error message
  ```

**Acceptance Criteria**:
- ✅ Agent can handle all three auth methods
- ✅ Automatic fallback to API Key if preferred method fails
- ✅ Clear validation steps
- ✅ Proper error handling

**Testing**:
```bash
# Not directly testable without running agent
# Review agent documentation for clarity and completeness
```

---

### **Work Package 4.5: Configuration Template Updates** (Priority: LOW)
**Estimated Time**: 30 minutes
**Dependencies**: None (documentation only)
**Deliverables**: Updated config templates with auth method field

---

#### WP4.5.1: Add Authentication Method Field to All Config Templates (30 minutes)
**Purpose**: Document authentication method in config files (for future use)

**Tasks**:
- [ ] Update `setup/configs/simple-web.json`:
  ```json
  {
    "name": "Simple Web Project",
    "authentication": {
      "method": "github-app",
      "comment": "Options: github-app (recommended), api-key, oauth-token"
    },
    "branching": {
      "strategy": "simple",
      ...
    }
  }
  ```

- [ ] Update `setup/configs/standard-web.json` (same pattern)
- [ ] Update `setup/configs/complex-web.json` (same pattern)
- [ ] Update `setup/configs/standard-mobile.json` (same pattern)
- [ ] Update `setup/configs/standard-fullstack.json` (same pattern)
- [ ] Update `setup/configs/custom-template.json` (same pattern with all options documented)

**Note**: Wizard doesn't currently use this field for auth setup, but it's good documentation for users who want to understand config structure.

**Acceptance Criteria**:
- ✅ All 6 config files have authentication field
- ✅ Default is "github-app" (recommended)
- ✅ Comment explains available options
- ✅ Consistent formatting across all configs

**Testing**:
```bash
# Verify all configs have auth field
for f in setup/configs/*.json; do
  echo "Checking $f..."
  jq '.authentication.method' "$f"
done
# Should output: "github-app" for each file
```

---

### **Work Package 4.6: Testing & Validation** (Priority: CRITICAL)
**Estimated Time**: 2 hours
**Dependencies**: All previous WPs (can only test after implementation)
**Deliverables**: Validated end-to-end authentication flows

---

#### WP4.6.1: Test GitHub App Authentication Flow (45 minutes)
**Purpose**: Validate GitHub App setup works end-to-end

**Tasks**:
- [ ] **Setup clean test environment**:
  ```bash
  # Create test repository
  gh repo create test-blueprint-auth --public
  cd test-blueprint-auth

  # Clone blueprint
  git clone https://github.com/alirezarezvani/claude-code-github-workflow.git .github-blueprint
  cd .github-blueprint
  ```

- [ ] **Test wizard with GitHub App**:
  - [ ] Run `./setup/wizard.sh`
  - [ ] Select option 1 (GitHub App)
  - [ ] Verify Claude CLI check works
  - [ ] Follow prompts to run `/install-github-app`
  - [ ] Verify secrets created automatically
  - [ ] Complete wizard successfully

- [ ] **Run validation script**:
  ```bash
  ./setup/validate.sh
  # Expected: All checks pass, auth method shows "GitHub App"
  ```

- [ ] **Test workflow with GitHub App auth**:
  - [ ] Trigger bootstrap workflow
  - [ ] Verify no authentication errors
  - [ ] Check workflow logs for successful auth

- [ ] **Document issues encountered** (if any)

**Acceptance Criteria**:
- ✅ Wizard completes with GitHub App
- ✅ Secrets auto-created correctly
- ✅ Validation script passes
- ✅ Workflows authenticate successfully
- ✅ No errors in any step

**Testing Checklist**:
- [ ] Claude CLI installed
- [ ] GitHub App authorization works
- [ ] Secrets created (verify with `gh secret list`)
- [ ] Bootstrap workflow runs successfully
- [ ] No auth errors in logs

---

#### WP4.6.2: Test API Key Authentication Flow (Regression Test) (30 minutes)
**Purpose**: Ensure existing API key flow still works after changes

**Tasks**:
- [ ] **Setup clean test environment** (same as WP4.6.1)

- [ ] **Test wizard with API Key**:
  - [ ] Run `./setup/wizard.sh`
  - [ ] Select option 2 (API Key)
  - [ ] Enter valid API key when prompted
  - [ ] Verify secret set successfully
  - [ ] Complete wizard successfully

- [ ] **Run validation script**:
  ```bash
  ./setup/validate.sh
  # Expected: All checks pass, auth method shows "API Key"
  ```

- [ ] **Test workflow with API Key auth**:
  - [ ] Trigger bootstrap workflow
  - [ ] Verify authentication works
  - [ ] No regression from previous behavior

**Acceptance Criteria**:
- ✅ Existing API key flow unchanged
- ✅ No breaking changes
- ✅ Validation passes
- ✅ Workflows work as before

**Testing Checklist**:
- [ ] API key validation works
- [ ] Secret set via gh CLI
- [ ] Bootstrap workflow runs
- [ ] Identical experience to before changes

---

#### WP4.6.3: Test OAuth Token Authentication Flow (30 minutes)
**Purpose**: Validate new OAuth token method works

**Tasks**:
- [ ] **Setup clean test environment** (same as WP4.6.1)

- [ ] **Test wizard with OAuth Token**:
  - [ ] Run `./setup/wizard.sh`
  - [ ] Select option 3 (OAuth Token)
  - [ ] Verify Pro/Max subscription check
  - [ ] Generate token via `claude setup-token`
  - [ ] Enter token when prompted
  - [ ] Verify secret set successfully
  - [ ] Complete wizard successfully

- [ ] **Run validation script**:
  ```bash
  ./setup/validate.sh
  # Expected: All checks pass, auth method shows "OAuth Token"
  ```

- [ ] **Test workflow with OAuth auth**:
  - [ ] Trigger bootstrap workflow
  - [ ] Verify authentication works
  - [ ] No errors in logs

**Acceptance Criteria**:
- ✅ OAuth flow works for Pro/Max users
- ✅ Subscription check works
- ✅ Token validation works
- ✅ Workflows authenticate successfully

**Testing Checklist**:
- [ ] Claude CLI available
- [ ] Pro/Max subscription active
- [ ] Token generated successfully
- [ ] Secret set correctly
- [ ] Bootstrap workflow runs

---

#### WP4.6.4: Test Authentication Fallback Scenarios (15 minutes)
**Purpose**: Validate fallback logic when preferred method fails

**Tasks**:
- [ ] **Test GitHub App → API Key fallback**:
  - [ ] Run wizard, select GitHub App
  - [ ] Simulate Claude CLI not available (temporarily hide)
  - [ ] Verify wizard offers API Key fallback
  - [ ] Complete with API Key method

- [ ] **Test OAuth → API Key fallback**:
  - [ ] Run wizard, select OAuth Token
  - [ ] Answer "no" to subscription question
  - [ ] Verify wizard switches to API Key
  - [ ] Complete with API Key method

**Acceptance Criteria**:
- ✅ Fallback logic works smoothly
- ✅ User not left in error state
- ✅ Alternative method completes successfully

**Testing Checklist**:
- [ ] GitHub App fallback works
- [ ] OAuth fallback works
- [ ] User experience smooth during fallback

---

### **Work Package 4.7: Documentation Review & Polish** (Priority: LOW)
**Estimated Time**: 30 minutes
**Dependencies**: All documentation WPs complete
**Deliverables**: Proofread and polished documentation

---

#### WP4.7.1: Documentation Review Checklist (30 minutes)

**Tasks**:
- [ ] **Review all updated docs for**:
  - [ ] Spelling/grammar errors
  - [ ] Broken links
  - [ ] Consistent terminology (GitHub App vs Github App vs github-app)
  - [ ] Code examples are correct
  - [ ] Screenshots/diagrams load correctly (if added)
  - [ ] Formatting is consistent

- [ ] **Verify cross-references**:
  - [ ] All internal links work (e.g., `[Setup Guide](GITHUB_SETUP.md)`)
  - [ ] External links work (e.g., Anthropic Console, Claude docs)
  - [ ] Table of contents updated if structure changed

- [ ] **Test setup instructions**:
  - [ ] Follow QUICK_START.md step-by-step (fresh user perspective)
  - [ ] Follow COMPLETE_SETUP.md step-by-step
  - [ ] Verify all commands work as documented

- [ ] **Consistency check**:
  - [ ] Same time estimates across all docs (2-3 min for GitHub App, etc.)
  - [ ] Same authentication option names everywhere
  - [ ] Same order (GitHub App, API Key, OAuth Token)

**Acceptance Criteria**:
- ✅ No spelling/grammar errors
- ✅ All links work
- ✅ Consistent terminology
- ✅ Instructions tested and accurate
- ✅ Professional presentation

**Testing**:
```bash
# Check for broken internal links
for file in docs/*.md GITHUB_SETUP.md README.md; do
  echo "Checking $file..."
  grep -o '\[.*\](.*.md)' "$file" | while read link; do
    # Extract file path
    path=$(echo "$link" | sed 's/.*(\(.*\))/\1/')
    if [[ ! -f "$path" ]] && [[ ! -f "docs/$path" ]]; then
      echo "  ⚠️  Broken link: $link"
    fi
  done
done
```

---

## 📊 Implementation Summary

### Total Deliverables
- **6 documentation files** updated (GITHUB_SETUP.md, QUICK_START.md, COMPLETE_SETUP.md, README.md, ARCHITECTURE.md, TROUBLESHOOTING.md)
- **2 setup scripts** enhanced (wizard.sh, validate.sh)
- **2 command/agent files** updated (blueprint-init.md, blueprint-setup.md)
- **6 config templates** updated (all setup/configs/*.json)

**Total: 16 files modified**

### New Content Created
- **3 new functions** in wizard.sh (setup_github_app, setup_api_key, setup_oauth_token)
- **1 new authentication menu** in wizard
- **1 new comparison table** in GITHUB_SETUP.md
- **1 new architecture section** in ARCHITECTURE.md
- **1 new troubleshooting section** in TROUBLESHOOTING.md
- **Multiple new subsections** across all docs

---

## ✅ Acceptance Criteria (Phase 4 Complete)

### Functional Requirements
- ✅ GitHub App appears as recommended method in all documentation
- ✅ Setup wizard offers interactive authentication menu
- ✅ All three auth methods work end-to-end (GitHub App, API Key, OAuth Token)
- ✅ Fallback logic works when preferred method unavailable
- ✅ Validation script detects and validates chosen auth method
- ✅ No breaking changes for existing API key users

### Performance Requirements
- ✅ Setup time reduced from 8-10 minutes to 2-3 minutes (GitHub App path)
- ✅ API key path time unchanged (backward compatible)
- ✅ OAuth token path: 5-7 minutes (new option)

### Usability Requirements
- ✅ Clear comparison table helps users choose auth method
- ✅ Wizard provides helpful error messages and fallbacks
- ✅ Documentation comprehensive for all three methods
- ✅ Troubleshooting guide covers common auth issues

### Documentation Requirements
- ✅ GitHub App method documented in 6 files
- ✅ All docs consistent in terminology and structure
- ✅ No broken links, spelling errors, or formatting issues
- ✅ Code examples tested and accurate

---

## 🚦 Testing Checklist

### Before Committing Each WP
- [ ] Code syntax is correct (bash scripts, JSON configs, markdown)
- [ ] All changes tested locally
- [ ] No breaking changes to existing functionality
- [ ] Documentation updated to match code changes

### Before Marking Phase 4 Complete
- [ ] All 16 files updated and tested
- [ ] All three auth methods validated end-to-end
- [ ] Documentation reviewed and proofread
- [ ] No regression in existing features
- [ ] All acceptance criteria met
- [ ] Final commit pushed to main branch

---

## 📝 Implementation Notes

### Key Design Decisions
1. **GitHub App as default**: Aligns with official Claude Code Action recommendation
2. **API Key as fallback**: Ensures universal compatibility
3. **OAuth Token documented only**: Minimal implementation effort, good documentation
4. **No workflow changes**: OAuth token uses existing CLAUDE_CODE_OAUTH_TOKEN from claude-code-review.yml
5. **Wizard-based approach**: Interactive menu provides best UX for choosing auth method

### Future Enhancements (Out of Scope)
- AWS Bedrock authentication support
- Google Vertex AI authentication support
- Automatic auth method migration tool
- Authentication health monitoring dashboard

---

## 📅 Timeline Estimate

**Optimistic**: 8 hours (if no issues)
**Realistic**: 10 hours (with testing and polish)
**Pessimistic**: 12 hours (if significant issues found during testing)

**Recommended approach**: Work in WP order, commit after each WP, test incrementally.

---

**End of Phase 4 Work Plan**
