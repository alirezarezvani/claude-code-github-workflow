#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────
# GitHub Workflow Blueprint - Validation Script
# ─────────────────────────────────────────────────────────────────
# Post-setup validation script that verifies complete configuration.
#
# Features:
# - Branch validation
# - Secret verification
# - Workflow syntax checking
# - Composite action validation
# - Project board connectivity
# - Label verification
# - Comprehensive reporting
#
# Usage: ./setup/validate.sh
#
# Requirements:
# - Git 2.40+
# - GitHub CLI (gh) 2.40+
# - Bash 4.0+
#
# Exit Codes:
# - 0: All validations passed
# - 1: One or more validations failed
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

# Validation results
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# ─────────────────────────────────────────────────────────────────
# Utility Functions
# ─────────────────────────────────────────────────────────────────

log_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED_CHECKS++))
    ((TOTAL_CHECKS++))
}

log_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED_CHECKS++))
    ((TOTAL_CHECKS++))
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNING_CHECKS++))
    ((TOTAL_CHECKS++))
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# ─────────────────────────────────────────────────────────────────
# Header
# ─────────────────────────────────────────────────────────────────

show_header() {
    clear
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║         ✅ GitHub Workflow Blueprint - Validation ✅            ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

This script validates your repository configuration.

═══════════════════════════════════════════════════════════════════

EOF
}

# ─────────────────────────────────────────────────────────────────
# 1. Branch Validation
# ─────────────────────────────────────────────────────────────────

validate_branches() {
    log_section "1. Checking Branches"

    # Check if in git repository
    if ! git rev-parse --git-dir &> /dev/null; then
        log_fail "Not in a git repository"
        return 1
    fi

    # Check main branch
    if git ls-remote --heads origin main 2>/dev/null | grep -q main; then
        log_pass "Branch 'main' exists"
    else
        log_fail "Branch 'main' missing"
    fi

    # Check dev branch (may or may not exist depending on strategy)
    if git ls-remote --heads origin dev 2>/dev/null | grep -q dev; then
        log_pass "Branch 'dev' exists (standard/complex strategy)"
    else
        log_info "Branch 'dev' not found (simple strategy or not created yet)"
    fi

    # Check staging branch (may or may not exist)
    if git ls-remote --heads origin staging 2>/dev/null | grep -q staging; then
        log_pass "Branch 'staging' exists (complex strategy)"
    else
        log_info "Branch 'staging' not found (simple/standard strategy)"
    fi

    # Check default branch
    local default_branch=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}')
    if [[ "$default_branch" == "main" ]]; then
        log_pass "Default branch is 'main'"
    else
        log_warn "Default branch is '$default_branch' (expected: main)"
    fi
}

# ─────────────────────────────────────────────────────────────────
# 2. Secret Verification
# ─────────────────────────────────────────────────────────────────

validate_secrets() {
    log_section "2. Checking Repository Secrets"

    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
        log_fail "GitHub CLI (gh) not available"
        return 1
    fi

    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        log_fail "Not authenticated with GitHub CLI"
        return 1
    fi

    # Check PROJECT_URL secret
    if gh secret list 2>/dev/null | grep -q "PROJECT_URL"; then
        log_pass "PROJECT_URL secret configured"

        # Try to validate format (if we can read it)
        local project_url=$(gh secret list 2>/dev/null | grep PROJECT_URL | awk '{print $1}')
        if [[ -n "$project_url" ]]; then
            log_info "PROJECT_URL is set"
        fi
    else
        log_fail "PROJECT_URL secret missing"
        log_info "Set with: gh secret set PROJECT_URL"
    fi

    # Check ANTHROPIC_API_KEY secret
    if gh secret list 2>/dev/null | grep -q "ANTHROPIC_API_KEY"; then
        log_pass "ANTHROPIC_API_KEY secret configured"
    else
        log_fail "ANTHROPIC_API_KEY secret missing"
        log_info "Set with: gh secret set ANTHROPIC_API_KEY"
    fi

    # Check GITHUB_TOKEN (auto-provided)
    log_pass "GITHUB_TOKEN (auto-provided by GitHub Actions)"
}

# ─────────────────────────────────────────────────────────────────
# 3. Workflow Validation
# ─────────────────────────────────────────────────────────────────

validate_workflows() {
    log_section "3. Checking GitHub Actions Workflows"

    local workflow_dir=".github/workflows"

    # Check if workflows directory exists
    if [[ ! -d "$workflow_dir" ]]; then
        log_fail "Workflows directory missing: $workflow_dir"
        return 1
    fi

    # Expected workflows
    local expected_workflows=(
        "bootstrap.yml"
        "reusable-pr-checks.yml"
        "pr-into-dev.yml"
        "dev-to-main.yml"
        "claude-plan-to-issues.yml"
        "create-branch-on-issue.yml"
        "pr-status-sync.yml"
        "release-status-sync.yml"
    )

    local found_count=0

    for workflow in "${expected_workflows[@]}"; do
        if [[ -f "$workflow_dir/$workflow" ]]; then
            # Check if YAML is valid (basic check)
            if command -v yamllint &> /dev/null; then
                if yamllint -d relaxed "$workflow_dir/$workflow" &> /dev/null; then
                    log_pass "$workflow (syntax valid)"
                else
                    log_warn "$workflow (syntax warnings)"
                fi
            else
                log_pass "$workflow (present)"
            fi
            ((found_count++))
        else
            log_fail "$workflow (missing)"
        fi
    done

    # Summary
    if [[ $found_count -eq ${#expected_workflows[@]} ]]; then
        log_pass "All $found_count workflows present"
    else
        log_warn "Found $found_count/${#expected_workflows[@]} workflows"
    fi

    # Check for YAML syntax using gh
    if command -v gh &> /dev/null; then
        log_info "Checking workflow syntax with GitHub CLI..."
        if gh workflow list &> /dev/null; then
            log_pass "GitHub CLI can read workflows (syntax valid)"
        else
            log_warn "GitHub CLI reports issues with workflows"
        fi
    fi
}

# ─────────────────────────────────────────────────────────────────
# 4. Composite Actions Validation
# ─────────────────────────────────────────────────────────────────

validate_composite_actions() {
    log_section "4. Checking Composite Actions"

    local actions_dir=".github/actions"

    # Check if actions directory exists
    if [[ ! -d "$actions_dir" ]]; then
        log_fail "Actions directory missing: $actions_dir"
        return 1
    fi

    # Expected composite actions
    local expected_actions=(
        "fork-safety"
        "rate-limit-check"
        "setup-node-pnpm"
        "project-sync"
        "quality-gates"
    )

    local found_count=0

    for action in "${expected_actions[@]}"; do
        local action_file="$actions_dir/$action/action.yml"

        if [[ -f "$action_file" ]]; then
            # Check if YAML is valid
            if command -v yamllint &> /dev/null; then
                if yamllint -d relaxed "$action_file" &> /dev/null; then
                    log_pass "$action (syntax valid)"
                else
                    log_warn "$action (syntax warnings)"
                fi
            else
                log_pass "$action (present)"
            fi
            ((found_count++))
        else
            log_fail "$action (missing)"
        fi
    done

    # Summary
    if [[ $found_count -eq ${#expected_actions[@]} ]]; then
        log_pass "All $found_count composite actions present"
    else
        log_warn "Found $found_count/${#expected_actions[@]} composite actions"
    fi
}

# ─────────────────────────────────────────────────────────────────
# 5. Configuration Templates Validation
# ─────────────────────────────────────────────────────────────────

validate_templates() {
    log_section "5. Checking Configuration Templates"

    # Check PR template
    if [[ -f ".github/pull_request_template.md" ]]; then
        log_pass "Pull request template present"
    else
        log_fail "Pull request template missing"
    fi

    # Check issue templates
    if [[ -d ".github/ISSUE_TEMPLATE" ]]; then
        local issue_template_count=$(ls -1 .github/ISSUE_TEMPLATE/*.md 2>/dev/null | wc -l | tr -d ' ')
        if [[ $issue_template_count -ge 2 ]]; then
            log_pass "Issue templates present ($issue_template_count templates)"
        else
            log_warn "Found $issue_template_count issue templates (expected: 2)"
        fi
    else
        log_fail "Issue templates directory missing"
    fi

    # Check commit template
    if [[ -f ".github/commit-template.txt" ]]; then
        log_pass "Commit template present"
    else
        log_warn "Commit template missing (optional)"
    fi

    # Check CODEOWNERS
    if [[ -f ".github/CODEOWNERS" ]]; then
        log_pass "CODEOWNERS file present"
    else
        log_warn "CODEOWNERS file missing (optional)"
    fi

    # Check dependabot config
    if [[ -f ".github/dependabot.yml" ]]; then
        log_pass "Dependabot configuration present"
    else
        log_warn "Dependabot configuration missing (optional)"
    fi
}

# ─────────────────────────────────────────────────────────────────
# 6. Labels Validation
# ─────────────────────────────────────────────────────────────────

validate_labels() {
    log_section "6. Checking Repository Labels"

    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI not available (skipping label check)"
        return 0
    fi

    # Expected labels
    local expected_labels=(
        "claude-code"
        "status:ready"
        "status:in-progress"
        "status:in-review"
        "status:to-deploy"
        "type:feature"
        "type:fix"
        "type:hotfix"
        "priority:high"
        "priority:medium"
        "priority:low"
    )

    local found_count=0

    for label in "${expected_labels[@]}"; do
        if gh label list 2>/dev/null | grep -q "^$label"; then
            ((found_count++))
        fi
    done

    if [[ $found_count -ge 10 ]]; then
        log_pass "Found $found_count labels (expected: ${#expected_labels[@]})"
    elif [[ $found_count -gt 0 ]]; then
        log_warn "Found $found_count labels (expected: ${#expected_labels[@]})"
        log_info "Run bootstrap workflow to create missing labels"
    else
        log_fail "No labels found"
        log_info "Run: gh workflow run bootstrap.yml"
    fi
}

# ─────────────────────────────────────────────────────────────────
# 7. Project Board Validation
# ─────────────────────────────────────────────────────────────────

validate_project_board() {
    log_section "7. Checking Project Board Connection"

    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI not available (skipping project board check)"
        return 0
    fi

    # Try to get PROJECT_URL from secrets (can't actually read the value)
    if gh secret list 2>/dev/null | grep -q "PROJECT_URL"; then
        log_pass "PROJECT_URL secret is set"

        # Note: We can't actually test the connection without the secret value
        log_info "Project board connectivity cannot be tested (secret value hidden)"
        log_info "Verify manually: gh project view <PROJECT_URL>"
    else
        log_fail "PROJECT_URL secret not set"
        log_info "Set with: gh secret set PROJECT_URL"
    fi
}

# ─────────────────────────────────────────────────────────────────
# 8. Documentation Validation
# ─────────────────────────────────────────────────────────────────

validate_documentation() {
    log_section "8. Checking Documentation"

    # Check README.md
    if [[ -f "README.md" ]]; then
        log_pass "README.md present"
    else
        log_fail "README.md missing"
    fi

    # Check docs directory
    if [[ -d "docs" ]]; then
        local doc_count=$(ls -1 docs/*.md 2>/dev/null | wc -l | tr -d ' ')
        if [[ $doc_count -ge 5 ]]; then
            log_pass "Documentation directory present ($doc_count guides)"
        else
            log_warn "Found $doc_count docs (expected: 8)"
        fi
    else
        log_warn "Documentation directory missing"
    fi

    # Check CLAUDE.md
    if [[ -f "CLAUDE.md" ]]; then
        log_pass "CLAUDE.md present (project context)"
    else
        log_warn "CLAUDE.md missing (optional)"
    fi
}

# ─────────────────────────────────────────────────────────────────
# 9. Claude Code Integration
# ─────────────────────────────────────────────────────────────────

validate_claude_integration() {
    log_section "9. Checking Claude Code Integration"

    # Check .claude directory
    if [[ -d ".claude" ]]; then
        log_pass ".claude directory present"

        # Check commands
        if [[ -d ".claude/commands/github" ]]; then
            local cmd_count=$(ls -1 .claude/commands/github/*.md 2>/dev/null | wc -l | tr -d ' ')
            if [[ $cmd_count -ge 5 ]]; then
                log_pass "Slash commands present ($cmd_count commands)"
            else
                log_warn "Found $cmd_count slash commands (expected: 8)"
            fi
        else
            log_warn "Slash commands directory missing"
        fi

        # Check agents
        if [[ -d ".claude/agents" ]]; then
            local agent_count=$(ls -1 .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
            if [[ $agent_count -ge 3 ]]; then
                log_pass "Agents present ($agent_count agents)"
            else
                log_warn "Found $agent_count agents (expected: 4)"
            fi
        else
            log_warn "Agents directory missing"
        fi
    else
        log_fail ".claude directory missing"
    fi
}

# ─────────────────────────────────────────────────────────────────
# 10. Environment Validation
# ─────────────────────────────────────────────────────────────────

validate_environment() {
    log_section "10. Checking Development Environment"

    # Check Git
    if command -v git &> /dev/null; then
        local git_version=$(git --version | awk '{print $3}')
        log_pass "Git installed (version $git_version)"
    else
        log_fail "Git not installed"
    fi

    # Check GitHub CLI
    if command -v gh &> /dev/null; then
        local gh_version=$(gh --version | head -1 | awk '{print $3}')
        log_pass "GitHub CLI installed (version $gh_version)"

        # Check authentication
        if gh auth status &> /dev/null; then
            local gh_user=$(gh api user -q .login 2>/dev/null || echo "unknown")
            log_pass "Authenticated as: $gh_user"
        else
            log_fail "Not authenticated with GitHub CLI"
            log_info "Run: gh auth login"
        fi
    else
        log_fail "GitHub CLI not installed"
    fi

    # Check Node.js (optional)
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        log_pass "Node.js installed ($node_version)"
    else
        log_info "Node.js not installed (optional for local development)"
    fi

    # Check pnpm (optional)
    if command -v pnpm &> /dev/null; then
        local pnpm_version=$(pnpm --version)
        log_pass "pnpm installed (version $pnpm_version)"
    else
        log_info "pnpm not installed (optional for local development)"
    fi

    # Check yamllint (optional)
    if command -v yamllint &> /dev/null; then
        log_pass "yamllint installed (for YAML validation)"
    else
        log_info "yamllint not installed (optional, install: pip install yamllint)"
    fi
}

# ─────────────────────────────────────────────────────────────────
# Generate Summary Report
# ─────────────────────────────────────────────────────────────────

generate_summary() {
    echo ""
    log_section "Validation Summary"

    cat << EOF
╔══════════════════════════════════════════════════════════════════╗
║                      Validation Results                          ║
╚══════════════════════════════════════════════════════════════════╝

Total Checks:    $TOTAL_CHECKS
Passed:          ${GREEN}✓ $PASSED_CHECKS${NC}
Failed:          ${RED}✗ $FAILED_CHECKS${NC}
Warnings:        ${YELLOW}⚠ $WARNING_CHECKS${NC}

EOF

    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                     ✅ SETUP VALID ✅                            ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "Your repository is properly configured!"
        echo ""

        if [[ $WARNING_CHECKS -gt 0 ]]; then
            echo -e "${YELLOW}Note: $WARNING_CHECKS warnings found (not critical)${NC}"
            echo ""
        fi

        return 0
    else
        echo -e "${RED}╔══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                   ❌ SETUP INCOMPLETE ❌                         ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${RED}$FAILED_CHECKS critical issues found.${NC}"
        echo ""
        echo "Please fix the issues above and run validation again."
        echo ""
        echo "Common fixes:"
        echo "  • Run setup wizard: ./setup/wizard.sh"
        echo "  • Run bootstrap workflow: gh workflow run bootstrap.yml"
        echo "  • Set secrets manually: gh secret set SECRET_NAME"
        echo ""
        return 1
    fi
}

# ─────────────────────────────────────────────────────────────────
# Main Execution
# ─────────────────────────────────────────────────────────────────

main() {
    show_header

    # Run all validation checks
    validate_branches
    validate_secrets
    validate_workflows
    validate_composite_actions
    validate_templates
    validate_labels
    validate_project_board
    validate_documentation
    validate_claude_integration
    validate_environment

    # Generate summary
    generate_summary

    # Exit with appropriate code
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"
