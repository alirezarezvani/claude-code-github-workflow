# CLAUDE.md - GitHub Workflow Blueprint Project

**Project**: Claude Code GitHub Workflow Automation Blueprint
**Version**: 1.0.0
**Date**: 2025-11-06
**Status**: Phase 1 - Core Foundation ✅ **COMPLETE**

---

## 🎯 Project Overview

This repository provides a **production-ready blueprint** for automating GitHub workflows from planning to deployment using **Claude Code** and **GitHub Actions**. The blueprint is designed for developers of all skill levels (beginners to professionals) and supports flexible branching strategies and project types (web, mobile, fullstack).

---

## 📋 Source of Truth

### **Master Plan & PRD**
**→ `implementation.md`** is the **PRIMARY SOURCE OF TRUTH** for all implementation work.

This file contains:
- ✅ Complete vision, mission, and success metrics
- ✅ Detailed architecture and system design
- ✅ 3-phase implementation plan with tasks and subtasks
- ✅ Acceptance criteria for every component
- ✅ Timeline and milestones
- ✅ Technical specifications

**ALL implementation work MUST follow the specifications in `implementation.md`.**

---

## 📚 Reference Documentation

The following files are **REFERENCE ONLY** and provide context but are NOT the source of truth:

### `gh-workflow-master-instructions.md`
- Original master prompt that guided the initial design
- Contains high-level requirements and architecture concepts
- **NOTE**: Some details (like "max 5 issues") have been superseded by `implementation.md` (now max 10)
- Use for understanding original intent, but defer to `implementation.md` for specifics

### `anthropics-claude-code-gh-actions.md`
- Official Claude Code Action repository documentation
- Contains v1 GA API specifications and authentication methods
- **Use for**: Correct Claude Code Action syntax and capabilities
- Always use v1 GA patterns (not beta)

### `claude-code-github-document.md`
- User-facing documentation for Claude Code GitHub integration
- Contains setup guides and usage examples
- **Use for**: Understanding user perspective and quickstart patterns

### `examples/` Directory
- Example implementations from previous iterations
- **⚠️ WARNING**: Examples may contain outdated patterns or mismatches
- **Use for**: Learning patterns, but ALWAYS validate against `implementation.md` specifications
- Do NOT copy directly without validation

---

## 🏗️ Project Structure

```
claudecode-github-bluprint/
├── implementation.md          ← SOURCE OF TRUTH (PRD + Plan)
├── CLAUDE.md                  ← This file (project context)
├── README.md                  ← User-facing overview (to be created)
├── LICENSE                    ← Project license (to be created)
│
├── .github/
│   ├── workflows/             ← 8 core workflows (Phase 1)
│   ├── actions/               ← 5 composite actions (Phase 1)
│   ├── ISSUE_TEMPLATE/        ← Issue templates (Phase 1)
│   ├── pull_request_template.md
│   ├── commit-template.txt
│   ├── CODEOWNERS
│   └── dependabot.yml
│
├── .claude/
│   ├── commands/github/       ← 8 slash commands (Phase 2)
│   └── agents/             ← 4 specialized subagents/agents (Phase 2)
│
├── setup/
│   ├── wizard.sh              ← Interactive setup wizard
│   ├── validate.sh            ← Post-setup validation
│   └── configs/               ← Pre-built configurations
│
├── docs/
│   ├── PHASE1_WORKPLAN.md     ← Phase 1 detailed work plan ✅
│   ├── PHASE2_WORKPLAN.md     ← Phase 2 detailed work plan ✅
│   ├── QUICK_START.md         ← 5-minute setup guide (Phase 3)
│   ├── COMPLETE_SETUP.md      ← Step-by-step guide (Phase 3)
│   ├── WORKFLOWS.md           ← Workflow reference (Phase 3)
│   ├── COMMANDS.md            ← Slash commands reference (Phase 3)
│   ├── TROUBLESHOOTING.md     ← Common issues + fixes (Phase 3)
│   ├── CUSTOMIZATION.md       ← Advanced configuration (Phase 3)
│   └── ARCHITECTURE.md        ← System architecture (Phase 3)
│
├── examples/                  ← Example projects (reference)
│   ├── git/                   ← Slash command examples (reference)
│   ├── workflows/             ← Old workflow examples (reference)
│   └── ...
│
└── tests/
    └── scenarios.md           ← Test scenarios (Phase 3)
```

---

## 🔧 Implementation Phases

### **Phase 1: Core Foundation** (Week 1)
**Status**: ✅ **COMPLETE** - All deliverables implemented and tested

**Detailed Work Plan**: See `docs/PHASE1_WORKPLAN.md` for comprehensive implementation guide

**Deliverables**:
- ✅ 8 GitHub Actions workflows
- ✅ 5 composite actions for DRY
- ✅ Configuration templates (PR, issues, branch protections)
- ✅ Basic testing

**Current Progress**:
- [x] implementation.md created (PRD)
- [x] CLAUDE.md created (this file)
- [x] Directory structure initialized
- [x] Phase 1 detailed work plan created (docs/PHASE1_WORKPLAN.md)
- [x] **WP1: Composite Actions** ✅ (Session 1 Complete - 2025-11-06)
  - [x] fork-safety
  - [x] rate-limit-check
  - [x] setup-node-pnpm
  - [x] project-sync
  - [x] quality-gates
- [x] **WP2: Configuration Templates** ✅ (Session 2 Complete - 2025-11-06)
  - [x] commit-template.txt
  - [x] CODEOWNERS
  - [x] pull_request_template.md
  - [x] ISSUE_TEMPLATE/plan-task.md
  - [x] ISSUE_TEMPLATE/manual-task.md
  - [x] dependabot.yml
- [x] **WP3: Core Workflows** ✅ (Session 3 Complete - 2025-11-06)
  - [x] bootstrap.yml (one-time repository setup)
  - [x] reusable-pr-checks.yml (DRY quality checks)
  - [x] pr-into-dev.yml (feature PR validation)
  - [x] dev-to-main.yml (release gates)
  - [x] claude-plan-to-issues.yml (plan converter - most complex)
  - [x] create-branch-on-issue.yml (auto-branching)
  - [x] pr-status-sync.yml (PR lifecycle tracking)
  - [x] release-status-sync.yml (deployment tracking)

**Phase 1 Status**: ✅ **COMPLETE** - All 19 files created (5 composites + 6 configs + 8 workflows)

**Next**: Phase 2 - Automation Layer (slash commands + subagents)

---

### **Phase 2: Automation Layer** (Week 2)
**Status**: 🔴 Not Started - Ready to Execute

**Detailed Work Plan**: See `docs/PHASE2_WORKPLAN.md` for comprehensive implementation guide

**Deliverables**:
- 8 essential slash commands for recurring operations
- 4 specialized subagents for complex automation
- Interactive setup wizard

**Current Progress**:
- [x] Phase 2 detailed work plan created (docs/PHASE2_WORKPLAN.md)
- [ ] **WP4: Slash Commands** (8 commands - 10-12 hours)
  - [ ] Session 4: Core Commands (4 commands)
    - [ ] /blueprint-init
    - [ ] /plan-to-issues
    - [ ] /commit-smart
    - [ ] /create-pr
  - [ ] Session 5: Advanced Commands (4 commands)
    - [ ] /review-pr
    - [ ] /release
    - [ ] /sync-status
    - [ ] /kill-switch
- [ ] **WP5: Specialized Subagents** (4 subagents - 6-8 hours)
  - [ ] blueprint-setup
  - [ ] plan-converter
  - [ ] quality-orchestrator
  - [ ] workflow-manager

**Next**: Session 4 - Core Commands (WP4)

---

### **Phase 3: Documentation & Polish** (Week 3)
**Status**: 🔴 Not Started

**Deliverables**:
- 7 comprehensive documentation files
- Example projects
- Testing scenarios
- Video walkthroughs (optional)

---

## ✨ Key Design Decisions

### Branching Strategies (Flexible)
The blueprint supports three strategies (user choice):
1. **Simple**: `feature → main` (small teams)
2. **Standard**: `feature → dev → main` (recommended)
3. **Complex**: `feature → dev → staging → main` (enterprise)

### Task Limits
- **Max 10 tasks per plan** (hard limit)
- Includes milestone definition and correct labeling
- Enforced in claude-plan-to-issues.yml workflow

### Claude Code Action Version
- **Use v1 GA only** (not beta)
- Simplified configuration (auto mode detection)
- Reference: anthropics-claude-code-gh-actions.md

### Mobile Support
- **Optional/bonus feature** (not mandatory)
- Path-based filtering (`mobile/`, `android/`, `ios/`)
- Only runs when relevant files changed

### Project Board
- **GitHub Projects v2** (GraphQL API)
- 7-status system: To triage → Backlog → Ready → In Progress → In Review → To Deploy → Done
- Users can customize status names in their projects
- Bidirectional sync with issues

---

## 🔐 Security & Safety

### Built-in Protections
- ✅ **Rate limiting**: Circuit breaker pattern (50+ API calls minimum)
- ✅ **Fork safety**: Read-only operations for fork PRs
- ✅ **Branch protection**: No deletions, squash-only, linear history
- ✅ **Secret scanning**: Prevent committing credentials
- ✅ **Kill switch**: Emergency workflow disable mechanism
- ✅ **Idempotency**: All operations safe to retry
- ✅ **Debouncing**: 10-second delays prevent infinite loops

---

## 📊 Success Criteria

### Functional Requirements
- All 8 workflows execute successfully
- All 8 slash commands work as documented
- All 4 specialized agents complete their tasks autonomously
- Setup wizard completes in <5 minutes
- Quality gates catch common issues

### Performance Requirements
- PR checks complete in <2 minutes
- Plan-to-issues creates 10 issues in <30 seconds
- Project sync completes in <5 seconds
- GitHub Actions usage <30 minutes/developer/day

### Usability Requirements
- Beginners productive in <30 minutes
- Clear error messages (no cryptic failures)
- Comprehensive documentation
- Examples for all use cases

### Reliability Requirements
- 99%+ workflow success rate
- Zero infinite loops
- Graceful degradation on failures
- Automatic recovery from transient errors

---

## 🚦 Current Status

**Phase**: 1 (Core Foundation) ✅ **COMPLETE**
**Week**: 1
**Last Updated**: 2025-11-06
**Progress**: 100% of Phase 1 (19/19 files created)

### Completed ✅
- ✅ PRD created (implementation.md)
- ✅ Project context established (CLAUDE.md)
- ✅ Architecture designed
- ✅ All requirements gathered
- ✅ Directory structure initialized
- ✅ Phase 1 detailed work plan created (docs/PHASE1_WORKPLAN.md)
- ✅ **Session 1 Complete** - All 5 composite actions created (2025-11-06):
  - fork-safety (detects fork PRs for write protection)
  - rate-limit-check (circuit breaker for API exhaustion)
  - setup-node-pnpm (cached Node.js/pnpm setup)
  - project-sync (GitHub Projects v2 GraphQL sync)
  - quality-gates (orchestrated quality check runner)
- ✅ **Session 2 Complete** - All 6 configuration templates created (2025-11-06):
  - commit-template.txt (conventional commits with context)
  - CODEOWNERS (path-based code ownership)
  - pull_request_template.md (comprehensive PR template)
  - ISSUE_TEMPLATE/plan-task.md (auto-generated from Claude plans)
  - ISSUE_TEMPLATE/manual-task.md (user-created tasks)
  - dependabot.yml (weekly npm + GitHub Actions updates)
- ✅ **Session 3 Complete** - All 8 core workflows created (2025-11-06):
  - bootstrap.yml (341 lines - repository setup with labels, validation)
  - reusable-pr-checks.yml (513 lines - DRY quality checks with path filtering)
  - pr-into-dev.yml (391 lines - feature PR validation with helpful comments)
  - dev-to-main.yml (396 lines - release gates with smoke tests)
  - claude-plan-to-issues.yml (488 lines - plan converter, most complex)
  - create-branch-on-issue.yml (382 lines - auto-branching with instructions)
  - pr-status-sync.yml (446 lines - PR lifecycle tracking)
  - release-status-sync.yml (385 lines - deployment tracking with GitHub releases)

**🎉 PHASE 1 COMPLETE! All 19 files created successfully (3,342 total lines)**

### Next Steps
**Phase 2: Automation Layer** (Week 2 - Not Started)
- 8 essential slash commands for recurring operations
- 4 specialized subagents for complex automation
- Interactive setup wizard for first-time configuration

See `implementation.md` for Phase 2 detailed specifications

---

## 📝 Working Guidelines

### When Implementing
1. **Always refer to `implementation.md`** for specifications
2. **Use Claude Code Action v1 GA** (not beta patterns)
3. **Follow examples/** patterns for structure, but validate against specs
4. **Test each component** before moving to next
5. **Update this file** with progress

### When in Doubt
1. Check `implementation.md` first (source of truth)
2. Reference official docs (anthropics-claude-code-gh-actions.md)
3. Look at examples for patterns (but validate)
4. Ask for clarification if specs unclear

### Quality Gates
- Lint and format all YAML files
- Validate workflow syntax before committing
- Test workflows with example data
- Document any deviations from plan

---

## 🎯 Project Goals Reminder

**Vision**: Industry-standard GitHub + Claude Code automation blueprint
**Mission**: Empower developers (beginners to pros) with production-ready workflows
**Values**: Simplicity, reliability, flexibility, excellent DX

---

**Remember**: This is a **blueprint for other developers**, not just a project for ourselves. Every decision should prioritize:
- **Clarity** over cleverness
- **Reliability** over features
- **Documentation** over assumptions
- **Usability** over complexity

Let's build something world-class! 🚀

**REMEBER** Keep this @CLAUDE.md file always Up to date and as a living document. The @implementation.md file must be always updated.