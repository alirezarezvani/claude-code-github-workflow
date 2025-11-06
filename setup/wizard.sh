#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────
# GitHub Workflow Blueprint - Setup Wizard
# ─────────────────────────────────────────────────────────────────
# Interactive setup wizard that configures a repository from scratch.
#
# Features:
# - Environment detection and validation
# - Interactive configuration prompts
# - Automated branch creation
# - Secret configuration
# - Bootstrap workflow execution
# - Branch protection setup
# - Comprehensive validation
#
# Usage: ./setup/wizard.sh
#
# Requirements:
# - Git 2.40+
# - GitHub CLI (gh) 2.40+
# - Bash 4.0+ (or compatible shell)
#
# Author: Alireza Rezvani
# Date: 2025-11-06
# ─────────────────────────────────────────────────────────────────

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
PROJECT_TYPE=""
BRANCHING_STRATEGY=""
PROJECT_URL=""
ANTHROPIC_API_KEY=""
REPO_OWNER=""
REPO_NAME=""
SETUP_LOG="setup-log.txt"
ROLLBACK_NEEDED=false

# ─────────────────────────────────────────────────────────────────
# Utility Functions
# ─────────────────────────────────────────────────────────────────

log() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$SETUP_LOG"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1" | tee -a "$SETUP_LOG"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1" | tee -a "$SETUP_LOG"
}

log_error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$SETUP_LOG"
}

log_step() {
    echo -e "\n${CYAN}▶${NC} ${PURPLE}$1${NC}" | tee -a "$SETUP_LOG"
}

prompt() {
    echo -e "${YELLOW}?${NC} $1"
}

confirm() {
    local prompt="$1"
    local response
    while true; do
        read -p "$(echo -e "${YELLOW}?${NC} $prompt (y/n): ")" response
        case "$response" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

# ─────────────────────────────────────────────────────────────────
# Step 1: Welcome & Prerequisites Check
# ─────────────────────────────────────────────────────────────────

show_welcome() {
    clear
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║        🚀 GitHub Workflow Blueprint - Setup Wizard 🚀           ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

This wizard will configure your repository with:

  ✅ GitHub Actions workflows (8 workflows)
  ✅ Composite actions (5 reusable actions)
  ✅ Configuration templates (PR, issues, commits)
  ✅ Project board integration
  ✅ Branch protections

Estimated time: <5 minutes

═══════════════════════════════════════════════════════════════════

EOF
    echo "" | tee "$SETUP_LOG"
    log_info "Setup started at $(date)"
    echo ""
}

check_prerequisites() {
    log_step "Step 1: Checking Prerequisites"

    local all_good=true

    # Check Git
    if command -v git &> /dev/null; then
        local git_version=$(git --version | awk '{print $3}')
        log "Git version $git_version detected"
    else
        log_error "Git is not installed"
        log_info "Install from: https://git-scm.com/downloads"
        all_good=false
    fi

    # Check GitHub CLI
    if command -v gh &> /dev/null; then
        local gh_version=$(gh --version | head -1 | awk '{print $3}')
        log "GitHub CLI version $gh_version detected"
    else
        log_error "GitHub CLI (gh) is not installed"
        log_info "Install from: https://cli.github.com/"
        all_good=false
    fi

    # Check GitHub authentication
    if command -v gh &> /dev/null; then
        if gh auth status &> /dev/null; then
            local gh_user=$(gh api user -q .login 2>/dev/null || echo "unknown")
            log "Authenticated as: $gh_user"
        else
            log_error "Not authenticated with GitHub CLI"
            log_info "Run: gh auth login"
            all_good=false
        fi
    fi

    # Check if in git repository
    if git rev-parse --git-dir &> /dev/null; then
        log "Git repository detected"

        # Get repository info
        REPO_OWNER=$(gh repo view --json owner -q .owner.login 2>/dev/null || echo "")
        REPO_NAME=$(gh repo view --json name -q .name 2>/dev/null || echo "")

        if [[ -n "$REPO_OWNER" && -n "$REPO_NAME" ]]; then
            log "Repository: $REPO_OWNER/$REPO_NAME"
        else
            log_warning "Could not detect GitHub repository info"
        fi
    else
        log_error "Not in a git repository"
        log_info "Run: git init && gh repo create"
        all_good=false
    fi

    echo ""

    if [[ "$all_good" != true ]]; then
        log_error "Prerequisites not met. Please install required tools and try again."
        if confirm "Do you want to continue anyway? (not recommended)"; then
            log_warning "Continuing without all prerequisites..."
            return 0
        else
            exit 1
        fi
    fi

    return 0
}

# ─────────────────────────────────────────────────────────────────
# Step 2: Detect Project Type
# ─────────────────────────────────────────────────────────────────

detect_project_type() {
    log_step "Step 2: Project Type Selection"

    cat << 'EOF'

📦 What type of project is this?

  1. Web (frontend/backend web applications)
     - React, Next.js, Vue, Angular, etc.
     - Node.js, Express, NestJS, etc.

  2. Mobile (React Native, iOS, Android)
     - React Native, Expo
     - Native iOS/Android

  3. Fullstack (web + backend + optional mobile)
     - Complete application stack
     - Multiple platforms

EOF

    while true; do
        read -p "$(echo -e "${YELLOW}?${NC} Enter 1, 2, or 3: ")" choice
        case $choice in
            1)
                PROJECT_TYPE="web"
                log "Selected: Web project"
                break
                ;;
            2)
                PROJECT_TYPE="mobile"
                log "Selected: Mobile project"
                break
                ;;
            3)
                PROJECT_TYPE="fullstack"
                log "Selected: Fullstack project"
                break
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done

    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Step 3: Choose Branching Strategy
# ─────────────────────────────────────────────────────────────────

choose_branching_strategy() {
    log_step "Step 3: Branching Strategy Selection"

    cat << 'EOF'

🌿 Which branching strategy do you want to use?

  1. Simple: feature → main
     ├─ Best for: Solo developers, small projects
     ├─ Fast, minimal overhead
     └─ Single review step

  2. Standard: feature → dev → main (RECOMMENDED)
     ├─ Best for: Small to medium teams
     ├─ Good balance of safety and speed
     └─ Staging environment before production

  3. Complex: feature → dev → staging → main
     ├─ Best for: Enterprise, multiple environments
     ├─ Maximum safety, slower
     └─ Multiple validation stages

EOF

    while true; do
        read -p "$(echo -e "${YELLOW}?${NC} Enter 1, 2, or 3 (default: 2): ")" choice
        choice=${choice:-2}
        case $choice in
            1)
                BRANCHING_STRATEGY="simple"
                log "Selected: Simple branching (feature → main)"
                break
                ;;
            2)
                BRANCHING_STRATEGY="standard"
                log "Selected: Standard branching (feature → dev → main)"
                break
                ;;
            3)
                BRANCHING_STRATEGY="complex"
                log "Selected: Complex branching (feature → dev → staging → main)"
                break
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done

    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Step 4: Get Project Board URL
# ─────────────────────────────────────────────────────────────────

get_project_url() {
    log_step "Step 4: Project Board Configuration"

    cat << 'EOF'

📊 Enter your GitHub Project board URL:

Format examples:
  • https://github.com/users/USERNAME/projects/NUMBER
  • https://github.com/orgs/ORG/projects/NUMBER

Example: https://github.com/users/alirezarezvani/projects/1

EOF

    while true; do
        read -p "$(echo -e "${YELLOW}?${NC} Project URL: ")" url

        # Validate URL format
        if [[ $url =~ ^https://github\.com/(users|orgs)/[^/]+/projects/[0-9]+$ ]]; then
            PROJECT_URL="$url"
            log "Project URL validated: $url"

            # Try to verify project exists
            log_info "Verifying project access..."
            if gh project view "$PROJECT_URL" &> /dev/null; then
                log "Project board verified and accessible"
            else
                log_warning "Could not verify project access (may be a permissions issue)"
                if confirm "Continue anyway?"; then
                    break
                else
                    continue
                fi
            fi
            break
        else
            log_error "Invalid URL format"
            echo "URL must match: https://github.com/(users|orgs)/USERNAME/projects/NUMBER"
        fi
    done

    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Step 5: Get Anthropic API Key
# ─────────────────────────────────────────────────────────────────

get_api_key() {
    log_step "Step 5: Anthropic API Key Configuration"

    cat << 'EOF'

🔑 Enter your Anthropic API Key:

This is required for Claude Code integration in workflows.
Get your API key from: https://console.anthropic.com/

⚠️  Your API key will be stored as an encrypted repository secret.

EOF

    while true; do
        read -sp "$(echo -e "${YELLOW}?${NC} API Key (hidden): ")" key
        echo ""

        # Basic validation
        if [[ -z "$key" ]]; then
            log_error "API key cannot be empty"
            continue
        fi

        if [[ ! $key =~ ^sk-ant- ]]; then
            log_warning "API key doesn't start with 'sk-ant-' (may be invalid)"
            if ! confirm "Continue anyway?"; then
                continue
            fi
        fi

        if [[ ${#key} -lt 20 ]]; then
            log_warning "API key seems too short (may be invalid)"
            if ! confirm "Continue anyway?"; then
                continue
            fi
        fi

        ANTHROPIC_API_KEY="$key"
        log "API key validated (sk-ant-***${key: -4})"
        break
    done

    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Step 6: Configuration Summary
# ─────────────────────────────────────────────────────────────────

show_configuration_summary() {
    log_step "Step 6: Configuration Summary"

    cat << EOF

╔══════════════════════════════════════════════════════════════════╗
║                    Configuration Summary                          ║
╚══════════════════════════════════════════════════════════════════╝

Project Type:          ${PROJECT_TYPE}
Branching Strategy:    ${BRANCHING_STRATEGY}
Project Board:         ${PROJECT_URL}
API Key:               sk-ant-***${ANTHROPIC_API_KEY: -4}

Branches to create:
EOF

    case $BRANCHING_STRATEGY in
        simple)
            echo "  • main (already exists)"
            ;;
        standard)
            echo "  • main (already exists)"
            echo "  • dev (will be created)"
            ;;
        complex)
            echo "  • main (already exists)"
            echo "  • dev (will be created)"
            echo "  • staging (will be created)"
            ;;
    esac

    echo ""

    if ! confirm "Ready to proceed with setup?"; then
        log_warning "Setup cancelled by user"
        echo ""
        log_info "Run './setup/wizard.sh' to start over"
        exit 0
    fi

    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Step 7: Create Required Branches
# ─────────────────────────────────────────────────────────────────

create_branches() {
    log_step "Step 7: Creating Required Branches"

    case $BRANCHING_STRATEGY in
        simple)
            log "No additional branches needed (using main only)"
            ;;
        standard)
            create_branch "dev"
            ;;
        complex)
            create_branch "dev"
            create_branch "staging"
            ;;
    esac

    echo ""
}

create_branch() {
    local branch_name="$1"

    # Check if branch exists locally
    if git rev-parse --verify "$branch_name" &> /dev/null; then
        log "Branch '$branch_name' already exists locally"

        # Check if exists remotely
        if git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"; then
            log "Branch '$branch_name' already exists remotely"
            return 0
        else
            # Push existing local branch
            log_info "Pushing local branch '$branch_name' to remote..."
            if git push -u origin "$branch_name"; then
                log "Branch '$branch_name' pushed to remote"
            else
                log_error "Failed to push branch '$branch_name'"
                ROLLBACK_NEEDED=true
                return 1
            fi
        fi
    else
        # Check if exists remotely but not locally
        if git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"; then
            log "Branch '$branch_name' exists remotely, checking out..."
            git checkout -b "$branch_name" "origin/$branch_name"
            log "Branch '$branch_name' checked out from remote"
        else
            # Create new branch
            log_info "Creating branch '$branch_name'..."
            local current_branch=$(git branch --show-current)

            # Create from main
            if git checkout -b "$branch_name"; then
                if git push -u origin "$branch_name"; then
                    log "Branch '$branch_name' created and pushed"
                    # Switch back to original branch
                    git checkout "$current_branch" &> /dev/null
                else
                    log_error "Failed to push branch '$branch_name'"
                    ROLLBACK_NEEDED=true
                    return 1
                fi
            else
                log_error "Failed to create branch '$branch_name'"
                ROLLBACK_NEEDED=true
                return 1
            fi
        fi
    fi

    return 0
}

# ─────────────────────────────────────────────────────────────────
# Step 8: Set Repository Secrets
# ─────────────────────────────────────────────────────────────────

set_secrets() {
    log_step "Step 8: Configuring Repository Secrets"

    # Set PROJECT_URL
    log_info "Setting PROJECT_URL secret..."
    if echo "$PROJECT_URL" | gh secret set PROJECT_URL; then
        log "PROJECT_URL configured"
    else
        log_error "Failed to set PROJECT_URL secret"
        log_info "Manual setup: Settings → Secrets and variables → Actions → New repository secret"
        log_info "Name: PROJECT_URL"
        log_info "Value: $PROJECT_URL"

        if ! confirm "Continue anyway?"; then
            ROLLBACK_NEEDED=true
            return 1
        fi
    fi

    # Set ANTHROPIC_API_KEY
    log_info "Setting ANTHROPIC_API_KEY secret..."
    if echo "$ANTHROPIC_API_KEY" | gh secret set ANTHROPIC_API_KEY; then
        log "ANTHROPIC_API_KEY configured"
    else
        log_error "Failed to set ANTHROPIC_API_KEY secret"
        log_info "Manual setup: Settings → Secrets and variables → Actions → New repository secret"
        log_info "Name: ANTHROPIC_API_KEY"
        log_info "Value: [your API key]"

        if ! confirm "Continue anyway?"; then
            ROLLBACK_NEEDED=true
            return 1
        fi
    fi

    # Verify secrets
    log_info "Verifying secrets..."
    if gh secret list | grep -q "PROJECT_URL" && gh secret list | grep -q "ANTHROPIC_API_KEY"; then
        log "Both secrets verified"
    else
        log_warning "Could not verify all secrets"
    fi

    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Step 9: Run Bootstrap Workflow
# ─────────────────────────────────────────────────────────────────

run_bootstrap() {
    log_step "Step 9: Running Bootstrap Workflow"

    log_info "Triggering bootstrap.yml workflow..."

    if gh workflow run bootstrap.yml; then
        log "Bootstrap workflow triggered"

        # Wait a moment for workflow to start
        sleep 3

        # Get the latest run ID
        log_info "Waiting for workflow to start..."
        local run_id=""
        local max_attempts=10
        local attempt=0

        while [[ -z "$run_id" ]] && [[ $attempt -lt $max_attempts ]]; do
            run_id=$(gh run list --workflow=bootstrap.yml --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || echo "")
            if [[ -z "$run_id" ]]; then
                sleep 2
                ((attempt++))
            fi
        done

        if [[ -n "$run_id" ]]; then
            log "Workflow started (Run ID: $run_id)"
            log_info "Monitoring workflow execution..."

            # Monitor workflow (with timeout)
            local status=""
            local max_wait=120  # 2 minutes
            local elapsed=0

            while [[ $elapsed -lt $max_wait ]]; do
                status=$(gh run view "$run_id" --json status --jq .status 2>/dev/null || echo "")

                if [[ "$status" == "completed" ]]; then
                    local conclusion=$(gh run view "$run_id" --json conclusion --jq .conclusion 2>/dev/null || echo "")

                    if [[ "$conclusion" == "success" ]]; then
                        log "Bootstrap workflow completed successfully"
                        return 0
                    else
                        log_error "Bootstrap workflow failed (conclusion: $conclusion)"
                        log_info "View logs: gh run view $run_id --log"

                        if confirm "Continue anyway? (not recommended)"; then
                            return 0
                        else
                            ROLLBACK_NEEDED=true
                            return 1
                        fi
                    fi
                fi

                sleep 5
                ((elapsed+=5))
            done

            log_warning "Workflow still running after ${max_wait}s"
            log_info "Check status: gh run view $run_id"

            if confirm "Continue without waiting?"; then
                return 0
            else
                return 1
            fi
        else
            log_error "Could not get workflow run ID"
            log_info "Check manually: gh run list --workflow=bootstrap.yml"

            if confirm "Continue anyway?"; then
                return 0
            else
                ROLLBACK_NEEDED=true
                return 1
            fi
        fi
    else
        log_error "Failed to trigger bootstrap workflow"
        log_info "Manual trigger: gh workflow run bootstrap.yml"

        if confirm "Continue anyway?"; then
            return 0
        else
            ROLLBACK_NEEDED=true
            return 1
        fi
    fi

    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Step 10: Apply Branch Protections
# ─────────────────────────────────────────────────────────────────

apply_branch_protections() {
    log_step "Step 10: Applying Branch Protections"

    log_warning "Branch protections require GitHub Pro or organization account"
    log_info "If you have a free account, you'll need to set these manually"

    if ! confirm "Attempt to apply branch protections now?"; then
        log_info "Skipping branch protection setup"
        log_info "Manual setup: Settings → Branches → Add rule"
        echo ""
        return 0
    fi

    # Protect main branch
    protect_branch "main" true

    # Protect dev branch (if standard/complex)
    if [[ "$BRANCHING_STRATEGY" == "standard" ]] || [[ "$BRANCHING_STRATEGY" == "complex" ]]; then
        protect_branch "dev" false
    fi

    # Protect staging branch (if complex)
    if [[ "$BRANCHING_STRATEGY" == "complex" ]]; then
        protect_branch "staging" false
    fi

    echo ""
}

protect_branch() {
    local branch="$1"
    local enforce_admins="$2"

    log_info "Protecting branch: $branch"

    # Note: This requires GitHub Pro or organization account
    # Using gh api to set branch protection

    local protection_json='{
        "required_status_checks": {
            "strict": true,
            "contexts": []
        },
        "enforce_admins": '"$enforce_admins"',
        "required_pull_request_reviews": {
            "required_approving_review_count": 1,
            "dismiss_stale_reviews": true
        },
        "restrictions": null,
        "required_linear_history": true,
        "allow_force_pushes": false,
        "allow_deletions": false
    }'

    if gh api "repos/$REPO_OWNER/$REPO_NAME/branches/$branch/protection" \
        --method PUT \
        --input - <<< "$protection_json" &> /dev/null; then
        log "Branch '$branch' protected"
    else
        log_warning "Could not protect branch '$branch' (may require GitHub Pro)"
        log_info "Manual setup: Settings → Branches → Add rule for '$branch'"
    fi
}

# ─────────────────────────────────────────────────────────────────
# Step 11: Validate Setup
# ─────────────────────────────────────────────────────────────────

validate_setup() {
    log_step "Step 11: Validating Setup"

    local all_good=true

    # Check branches
    log_info "Checking branches..."
    case $BRANCHING_STRATEGY in
        simple)
            if git ls-remote --heads origin main | grep -q main; then
                log "✓ Branch 'main' exists"
            else
                log_error "✗ Branch 'main' missing"
                all_good=false
            fi
            ;;
        standard)
            if git ls-remote --heads origin main | grep -q main; then
                log "✓ Branch 'main' exists"
            else
                log_error "✗ Branch 'main' missing"
                all_good=false
            fi
            if git ls-remote --heads origin dev | grep -q dev; then
                log "✓ Branch 'dev' exists"
            else
                log_error "✗ Branch 'dev' missing"
                all_good=false
            fi
            ;;
        complex)
            if git ls-remote --heads origin main | grep -q main; then
                log "✓ Branch 'main' exists"
            else
                log_error "✗ Branch 'main' missing"
                all_good=false
            fi
            if git ls-remote --heads origin dev | grep -q dev; then
                log "✓ Branch 'dev' exists"
            else
                log_error "✗ Branch 'dev' missing"
                all_good=false
            fi
            if git ls-remote --heads origin staging | grep -q staging; then
                log "✓ Branch 'staging' exists"
            else
                log_error "✗ Branch 'staging' missing"
                all_good=false
            fi
            ;;
    esac

    # Check secrets
    log_info "Checking secrets..."
    if gh secret list | grep -q "PROJECT_URL"; then
        log "✓ PROJECT_URL secret configured"
    else
        log_error "✗ PROJECT_URL secret missing"
        all_good=false
    fi

    if gh secret list | grep -q "ANTHROPIC_API_KEY"; then
        log "✓ ANTHROPIC_API_KEY secret configured"
    else
        log_error "✗ ANTHROPIC_API_KEY secret missing"
        all_good=false
    fi

    # Check workflows
    log_info "Checking workflows..."
    local workflow_count=$(ls -1 .github/workflows/*.yml 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$workflow_count" -eq 8 ]]; then
        log "✓ All 8 workflows present"
    else
        log_warning "⚠ Found $workflow_count workflows (expected 8)"
    fi

    # Check composite actions
    log_info "Checking composite actions..."
    local action_count=$(find .github/actions -name "action.yml" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$action_count" -eq 5 ]]; then
        log "✓ All 5 composite actions present"
    else
        log_warning "⚠ Found $action_count composite actions (expected 5)"
    fi

    echo ""

    if [[ "$all_good" == true ]]; then
        log "✅ All validations passed!"
    else
        log_warning "⚠ Some validations failed (see above)"
    fi

    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Step 12: Generate Summary
# ─────────────────────────────────────────────────────────────────

show_final_summary() {
    log_step "Setup Complete!"

    cat << EOF

╔══════════════════════════════════════════════════════════════════╗
║                    🎉 Setup Complete! 🎉                         ║
╚══════════════════════════════════════════════════════════════════╝

Your repository is now configured with the GitHub Workflow Blueprint.

📊 Summary:
   Project Type:      ${PROJECT_TYPE}
   Branching:         ${BRANCHING_STRATEGY}
   Workflows:         8 core workflows
   Actions:           5 composite actions
   Project Board:     Connected

🚀 Next Steps:

1. Create your first issue:
   • Go to Issues → New Issue
   • Use "Plan Task" template
   • Add labels: claude-code + status:ready
   • Branch will be auto-created!

2. Start working:
   $ git fetch
   $ git checkout feature/issue-1-your-task
   $ # Make changes
   $ git commit -m "feat: your changes"
   $ git push

3. Create pull request:
   • Use slash command: /create-pr
   • Or manually with proper issue linking
   • Automated quality checks will run

4. Helpful slash commands:
   • /plan-to-issues  - Convert Claude plan to issues
   • /commit-smart    - Smart commit with quality checks
   • /create-pr       - Create PR with proper linking
   • /review-pr       - Get Claude code review
   • /release         - Create production release

📚 Documentation:
   • README.md              - Project overview
   • docs/QUICK_START.md    - 5-minute guide
   • docs/WORKFLOWS.md      - All workflows explained
   • docs/COMMANDS.md       - All slash commands
   • docs/CUSTOMIZATION.md  - Advanced configuration

⚙️  Configuration saved to: .github/

═══════════════════════════════════════════════════════════════════

Setup completed at $(date)

Setup log saved to: ${SETUP_LOG}

EOF
}

# ─────────────────────────────────────────────────────────────────
# Rollback Function
# ─────────────────────────────────────────────────────────────────

perform_rollback() {
    log_step "Rollback: Cleaning Up"

    log_warning "Attempting to rollback changes..."

    # Remove created branches
    case $BRANCHING_STRATEGY in
        standard)
            if git ls-remote --heads origin dev | grep -q dev; then
                log_info "Deleting remote branch 'dev'..."
                git push origin --delete dev 2>/dev/null || true
            fi
            if git rev-parse --verify dev &> /dev/null; then
                git branch -D dev 2>/dev/null || true
            fi
            ;;
        complex)
            if git ls-remote --heads origin dev | grep -q dev; then
                log_info "Deleting remote branch 'dev'..."
                git push origin --delete dev 2>/dev/null || true
            fi
            if git ls-remote --heads origin staging | grep -q staging; then
                log_info "Deleting remote branch 'staging'..."
                git push origin --delete staging 2>/dev/null || true
            fi
            if git rev-parse --verify dev &> /dev/null; then
                git branch -D dev 2>/dev/null || true
            fi
            if git rev-parse --verify staging &> /dev/null; then
                git branch -D staging 2>/dev/null || true
            fi
            ;;
    esac

    # Note: We don't remove secrets as they may have existed before
    log_info "Secrets left intact (remove manually if needed)"

    log "Rollback complete"
    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Main Execution
# ─────────────────────────────────────────────────────────────────

main() {
    # Trap errors
    trap 'if [[ $? -ne 0 ]] && [[ "$ROLLBACK_NEEDED" == true ]]; then perform_rollback; fi' EXIT

    # Show welcome
    show_welcome

    # Step 1: Check prerequisites
    check_prerequisites || exit 1

    # Step 2: Detect project type
    detect_project_type

    # Step 3: Choose branching strategy
    choose_branching_strategy

    # Step 4: Get project URL
    get_project_url

    # Step 5: Get API key
    get_api_key

    # Step 6: Show configuration summary
    show_configuration_summary

    # Step 7: Create branches
    create_branches || exit 1

    # Step 8: Set secrets
    set_secrets || exit 1

    # Step 9: Run bootstrap
    run_bootstrap || exit 1

    # Step 10: Apply branch protections
    apply_branch_protections

    # Step 11: Validate setup
    validate_setup

    # Step 12: Show summary
    show_final_summary

    # Disable rollback trap (successful completion)
    ROLLBACK_NEEDED=false
}

# Run main function
main "$@"
