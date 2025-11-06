# Phase 2 Work Plan - Automation Layer

**Project**: GitHub Workflow Blueprint
**Phase**: 2 - Automation Layer
**Duration**: Estimated 16-20 hours (Week 2)
**Status**: 🔴 Not Started
**Date Created**: 2025-11-06

---

## 🎯 Phase 2 Objectives

Implement the automation layer that provides developers with powerful slash commands and specialized subagents to interact with the GitHub workflow system efficiently.

**Deliverables**:
- 8 essential slash commands for recurring operations
- 4 specialized subagents for complex automation
- Interactive setup wizard

---

## 📋 Work Package Overview

### WP4: Slash Commands (8 commands)
**Estimated Time**: 10-12 hours
**Priority**: HIGH
**Files to Create**: 8 `.claude/commands/github/*.md` files

### WP5: Specialized Subagents (4 subagents)
**Estimated Time**: 6-8 hours
**Priority**: MEDIUM
**Files to Create**: 4 `.claude/agents/*.md` files

---

## 📦 WP4: Slash Commands

### Session 4: Core Commands (4 commands)
**Estimated Time**: 5-6 hours
**Priority**: CRITICAL - Foundation commands

#### WP4.1: `/blueprint-init` Command
**Time**: 1.5 hours
**Complexity**: HIGH
**File**: `.claude/commands/github/blueprint-init.md`

**Description**: Interactive setup wizard that configures repository from scratch

**Workflow Steps**:
1. Detect project type (web/mobile/fullstack)
2. Ask branching strategy (simple/standard/complex)
3. Ask for project board URL
4. Validate tools (gh CLI, git)
5. Create branches (dev, staging if needed)
6. Set repository secrets
7. Run bootstrap workflow
8. Apply branch protections
9. Validate complete setup
10. Generate summary report

**Acceptance Criteria**:
- ✅ Completes setup in <5 minutes
- ✅ Handles all 3 project types
- ✅ Clear error messages at each step
- ✅ Validates before proceeding to next step
- ✅ Rollback on failure

**Testing**:
- Test with each project type
- Test with each branching strategy
- Test error handling (missing tools, invalid URLs)
- Test rollback on failures

---

#### WP4.2: `/plan-to-issues` Command
**Time**: 1 hour
**Complexity**: MEDIUM
**File**: `.claude/commands/github/plan-to-issues.md`

**Description**: Converts Claude Code plan JSON to GitHub issues

**Workflow Steps**:
1. Accept plan JSON (file path or inline)
2. Validate JSON schema
3. Check task count (max 10)
4. Trigger claude-plan-to-issues workflow
5. Wait for completion (poll status)
6. Display created issue links
7. Provide project board link

**Acceptance Criteria**:
- ✅ Handles both file and inline JSON
- ✅ Validates before triggering workflow
- ✅ Shows real-time progress
- ✅ Links to all created issues
- ✅ Graceful error handling

**Testing**:
- Test with valid 10-task plan
- Test with invalid JSON
- Test with >10 tasks (should error)
- Test with file path vs inline

---

#### WP4.3: `/commit-smart` Command
**Time**: 1.5 hours
**Complexity**: MEDIUM
**File**: `.claude/commands/github/commit-smart.md`

**Description**: Smart commit with quality checks and secret detection

**Workflow Steps**:
1. Run git status
2. Review changed files
3. Scan for secrets (basic regex patterns)
4. Run pre-commit checks (lint, typecheck)
5. Generate conventional commit message
6. Show preview with diff summary
7. Confirm with user
8. Commit
9. Optional: Ask to push

**Acceptance Criteria**:
- ✅ Prevents committing secrets
- ✅ Quality checks pass before commit
- ✅ Conventional commit format enforced
- ✅ Clear preview shown
- ✅ User confirmation required

**Testing**:
- Test secret detection (.env files, API keys)
- Test quality check failures
- Test conventional commit generation
- Test push prompt

---

#### WP4.4: `/create-pr` Command
**Time**: 1 hour
**Complexity**: MEDIUM
**File**: `.claude/commands/github/create-pr.md`

**Description**: Creates PR with proper issue linking and labels

**Workflow Steps**:
1. Detect current branch
2. Ask for target branch (dev/main/staging)
3. Validate quality checks passed
4. Find related issue numbers from branch name
5. Generate PR title (conventional)
6. Fill PR template automatically
7. Create PR via gh CLI
8. Add appropriate labels
9. Display PR URL

**Acceptance Criteria**:
- ✅ Enforces linked issues
- ✅ Validates quality checks passed
- ✅ Proper PR format
- ✅ Correct labels applied
- ✅ Shows PR link

**Testing**:
- Test with feature branch
- Test with no linked issue (should prompt)
- Test quality check validation
- Test label assignment

---

### Session 5: Advanced Commands (4 commands)
**Estimated Time**: 5-6 hours
**Priority**: HIGH - Operational commands

#### WP4.5: `/review-pr` Command
**Time**: 2 hours
**Complexity**: HIGH
**File**: `.claude/commands/github/review-pr.md`

**Description**: Comprehensive PR review using Claude Code

**Workflow Steps**:
1. Accept PR number
2. Fetch PR changes via gh CLI
3. Run static analysis (complexity, LOC)
4. Claude code review (using Claude Code Action API)
5. Security scan (common vulnerabilities)
6. Generate structured review comment
7. Post comment to PR
8. Show summary to user

**Acceptance Criteria**:
- ✅ Comprehensive code review
- ✅ Security issues flagged
- ✅ Clear, actionable feedback
- ✅ Posted to PR as comment
- ✅ Actionable suggestions

**Testing**:
- Test with various PR sizes
- Test security vulnerability detection
- Test code quality feedback
- Test comment formatting

---

#### WP4.6: `/release` Command
**Time**: 1.5 hours
**Complexity**: MEDIUM
**File**: `.claude/commands/github/release.md`

**Description**: Creates production release PR

**Workflow Steps**:
1. Validate on dev branch
2. Check all PRs merged
3. Generate changelog (from commits)
4. Bump version (ask user)
5. Create release PR (dev → main)
6. Show release checklist
7. Wait for approval (optional)
8. Monitor merge status

**Acceptance Criteria**:
- ✅ Only works from dev branch
- ✅ Changelog generated automatically
- ✅ Release PR created with template
- ✅ Checklist provided
- ✅ Monitors completion

**Testing**:
- Test from dev branch
- Test from wrong branch (should error)
- Test changelog generation
- Test version bumping

---

#### WP4.7: `/sync-status` Command
**Time**: 1 hour
**Complexity**: MEDIUM
**File**: `.claude/commands/github/sync-status.md`

**Description**: Syncs issues and project board status

**Workflow Steps**:
1. Scan all open issues
2. Check associated PRs
3. Check project board status
4. Identify inconsistencies
5. Show proposed changes
6. Confirm with user
7. Apply fixes
8. Generate report

**Acceptance Criteria**:
- ✅ Finds all inconsistencies
- ✅ Shows clear before/after
- ✅ Requires user confirmation
- ✅ Fixes automatically after confirmation
- ✅ Detailed report generated

**Testing**:
- Test with inconsistent statuses
- Test with multiple issues
- Test confirmation flow
- Test report generation

---

#### WP4.8: `/kill-switch` Command
**Time**: 30 minutes
**Complexity**: LOW
**File**: `.claude/commands/github/kill-switch.md`

**Description**: Emergency workflow disable mechanism

**Workflow Steps**:
1. Show current killswitch status
2. Ask for action (enable/disable/status)
3. Create/update `.github/WORKFLOW_KILLSWITCH` file
4. Commit with --no-verify
5. Push immediately
6. Verify workflows respect killswitch
7. Notify team (optional comment)

**Acceptance Criteria**:
- ✅ Immediate effect
- ✅ All workflows check killswitch file
- ✅ Bypasses git hooks
- ✅ Clear status display
- ✅ Easy to reverse

**Testing**:
- Test enable/disable
- Test status check
- Test workflow respect
- Test reversal

---

## 📦 WP5: Specialized Subagents

### Session 6: Subagents (4 subagents)
**Estimated Time**: 6-8 hours
**Priority**: MEDIUM - Autonomous automation

#### WP5.1: `blueprint-setup` Subagent
**Time**: 2 hours
**Complexity**: HIGH
**File**: `.claude/agents/blueprint-setup.md`

**Description**: Autonomous setup wizard agent

**Responsibilities**:
- Detect project structure automatically
- Ask configuration questions intelligently
- Create required branches
- Set repository secrets securely
- Apply branch protections
- Validate complete setup
- Generate setup documentation

**Tools Available**: Bash, GitHub CLI, Read, Write, Grep

**Acceptance Criteria**:
- ✅ Autonomous setup completion
- ✅ Handles edge cases gracefully
- ✅ Clear progress updates
- ✅ Validation before completion
- ✅ Rollback on failure

**Testing**:
- Test with empty repository
- Test with existing structure
- Test error recovery
- Test rollback mechanism

---

#### WP5.2: `plan-converter` Subagent
**Time**: 1.5 hours
**Complexity**: MEDIUM
**File**: `.claude/agents/plan-converter.md`

**Description**: Intelligent plan-to-issues converter

**Responsibilities**:
- Parse complex plan JSON
- Validate structure and constraints
- Create milestone with proper metadata
- Generate issues (max 10) with all fields
- Link dependencies between issues
- Set priorities intelligently
- Add issues to project board

**Tools Available**: Read, Write, GitHub API

**Acceptance Criteria**:
- ✅ Handles complex nested plans
- ✅ Proper priority assignment
- ✅ Dependency linking works
- ✅ Project board integration
- ✅ Error recovery and retry

**Testing**:
- Test with complex plan
- Test with dependencies
- Test with various priorities
- Test error handling

---

#### WP5.3: `quality-orchestrator` Subagent
**Time**: 1.5 hours
**Complexity**: MEDIUM
**File**: `.claude/agents/quality-orchestrator.md`

**Description**: Quality gate manager

**Responsibilities**:
- Run all quality checks (lint, test, typecheck)
- Aggregate results from multiple sources
- Generate comprehensive reports
- Block/approve merges based on results
- Manage GitHub status checks
- Retry on transient failures
- Provide actionable feedback

**Tools Available**: Bash, GitHub API, Read

**Acceptance Criteria**:
- ✅ All checks executed properly
- ✅ Clear pass/fail status
- ✅ Detailed reports with context
- ✅ Handles failures gracefully
- ✅ Fast execution (<2 minutes)

**Testing**:
- Test with passing checks
- Test with failing checks
- Test retry mechanism
- Test report generation

---

#### WP5.4: `workflow-manager` Subagent
**Time**: 2 hours
**Complexity**: HIGH
**File**: `.claude/agents/workflow-manager.md`

**Description**: Consolidated automation manager

**Responsibilities**:
- PR lifecycle management (open → review → merge)
- Project board sync (bidirectional)
- Branch cleanup (delete merged branches)
- Deployment coordination
- Status tracking across systems
- Notification handling
- Error recovery

**Tools Available**: Bash, GitHub API, GraphQL

**Acceptance Criteria**:
- ✅ Handles all automation scenarios
- ✅ No infinite loops
- ✅ Idempotent operations
- ✅ Clear logging at each step
- ✅ Automatic error recovery

**Testing**:
- Test PR lifecycle
- Test project board sync
- Test branch cleanup
- Test error scenarios

---

## 🧪 Testing Strategy

### Unit Testing
- Each slash command tested individually
- Each subagent tested in isolation
- Mock GitHub API responses

### Integration Testing
- Test slash commands triggering workflows
- Test subagents interacting with GitHub
- Test end-to-end scenarios

### User Acceptance Testing
- Test complete setup flow
- Test developer daily workflow
- Test error scenarios and recovery

---

## 📊 Progress Tracking

### Session 4: Core Commands (4/8 commands)
- [ ] `/blueprint-init` (1.5h)
- [ ] `/plan-to-issues` (1h)
- [ ] `/commit-smart` (1.5h)
- [ ] `/create-pr` (1h)

**Total**: 5-6 hours

### Session 5: Advanced Commands (4/8 commands)
- [ ] `/review-pr` (2h)
- [ ] `/release` (1.5h)
- [ ] `/sync-status` (1h)
- [ ] `/kill-switch` (0.5h)

**Total**: 5-6 hours

### Session 6: Subagents (4/4 subagents)
- [ ] `blueprint-setup` (2h)
- [ ] `plan-converter` (1.5h)
- [ ] `quality-orchestrator` (1.5h)
- [ ] `workflow-manager` (2h)

**Total**: 6-8 hours

---

## 📁 Directory Structure (Post Phase 2)

```
.claude/
├── commands/
│   └── github/
│       ├── blueprint-init.md
│       ├── plan-to-issues.md
│       ├── commit-smart.md
│       ├── create-pr.md
│       ├── review-pr.md
│       ├── release.md
│       ├── sync-status.md
│       └── kill-switch.md
└── agents/
    ├── blueprint-setup.md
    ├── plan-converter.md
    ├── quality-orchestrator.md
    └── workflow-manager.md
```

---

## ✅ Definition of Done (Phase 2)

### Functional Requirements
- ✅ All 8 slash commands work as documented
- ✅ All 4 subagents complete tasks autonomously
- ✅ Setup wizard completes successfully in <5 minutes
- ✅ Error handling works in all scenarios

### Quality Requirements
- ✅ Commands follow consistent format
- ✅ Subagents provide clear progress updates
- ✅ All error messages are helpful
- ✅ Documentation is comprehensive

### Testing Requirements
- ✅ Unit tests for each command
- ✅ Integration tests for workflows
- ✅ User acceptance testing completed
- ✅ Edge cases handled

---

## 🚀 Getting Started

To begin Phase 2 implementation:

1. **Read specifications**: Review `implementation.md` Task 2.1 and 2.2
2. **Create directories**: `mkdir -p .claude/commands/github .claude/agents`
3. **Start with Session 4**: Begin with core commands
4. **Test as you go**: Test each command immediately after creation
5. **Update CLAUDE.md**: Mark progress after each session

---

## 📝 Notes

- Slash commands use Claude Code CLI command format
- Subagents are autonomous and use specified tools only
- All commands should have clear help text
- Error messages must be actionable
- Progress updates should be frequent

---

**Next Step**: Start with Session 4 - Create `/blueprint-init` command

**Estimated Completion**: End of Week 2
