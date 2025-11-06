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
**Status**: ✅ **COMPLETE** - All deliverables implemented and tested

**Detailed Work Plan**: See `docs/PHASE2_WORKPLAN.md` for comprehensive implementation guide

**Deliverables**:
- ✅ 8 essential slash commands for recurring operations
- ✅ 4 specialized subagents for complex automation
- ✅ Interactive setup wizard integration

**Current Progress**:
- [x] Phase 2 detailed work plan created (docs/PHASE2_WORKPLAN.md)
- [x] **WP4: Slash Commands** ✅ (8 commands - 10-12 hours)
  - [x] Session 4: Core Commands (4 commands - Complete 2025-11-06)
    - [x] /blueprint-init (544 lines - interactive setup wizard)
    - [x] /plan-to-issues (489 lines - plan JSON converter)
    - [x] /commit-smart (650 lines - smart commit with quality checks)
    - [x] /create-pr (645 lines - PR creation with proper linking)
  - [x] Session 5: Advanced Commands (4 commands - Complete 2025-11-06)
    - [x] /review-pr (550 lines - comprehensive Claude-powered review)
    - [x] /release (600 lines - production release management)
    - [x] /sync-status (580 lines - issue/board synchronization)
    - [x] /kill-switch (450 lines - emergency workflow disable)
- [x] **WP5: Specialized Subagents** ✅ (4 subagents - 6-8 hours)
  - [x] blueprint-setup (1,150 lines - autonomous setup wizard)
  - [x] plan-converter (1,080 lines - intelligent plan-to-issues converter)
  - [x] quality-orchestrator (980 lines - quality gate manager)
  - [x] workflow-manager (1,020 lines - consolidated automation orchestrator)

**Phase 2 Status**: ✅ **COMPLETE** - All 12 files created (8,738 total lines)
- **Commit b4d0e6a**: Session 4 (Core Commands) - 2,328 lines
- **Commit 95a44c7**: Session 5 (Advanced Commands) - 2,180 lines
- **Commit d59cd4f**: Session 6 (Specialized Subagents) - 4,230 lines

**Next**: Phase 3 - Documentation & Polish (setup automation, examples, comprehensive docs)

---

### **Phase 3: Documentation & Polish** (Week 3)
**Status**: ✅ **COMPLETE** (100% - 15/15 deliverables)

**Detailed Work Plan**: See `docs/PHASE3_WORKPLAN.md` for comprehensive implementation guide

**Deliverables**:
- ✅ 8 comprehensive documentation files (README + 7 docs/)
- ✅ Setup automation scripts (wizard.sh, validate.sh)
- ✅ Pre-built configuration templates (6 JSON configs)
- ✅ Example projects (web, mobile, fullstack)
- ✅ Testing scenarios

**Current Progress**:
- [x] Phase 3 detailed work plan created (docs/PHASE3_WORKPLAN.md)
- [x] **WP6: Core Documentation** ✅ 100% (8/8 files - 8-9 hours completed)
  - [x] README.md (enhanced - 400 lines) - Professional presentation
  - [x] QUICK_START.md (600 lines) - 5-minute setup guide
  - [x] COMPLETE_SETUP.md (900+ lines) - Detailed installation
  - [x] TROUBLESHOOTING.md (1000+ lines) - Comprehensive issue resolution
  - [x] WORKFLOWS.md (2,555 lines) - All 8 workflows documented
  - [x] COMMANDS.md (3,078 lines) - All 8 slash commands
  - [x] CUSTOMIZATION.md (989 lines) - Advanced configuration
  - [x] ARCHITECTURE.md (1,287 lines) - System design + decisions
- [x] **WP7: Setup Automation** ✅ 100% (10 files - 3-4 hours completed)
  - [x] wizard.sh (783 lines - interactive setup wizard)
  - [x] configs/simple-web.json (pre-built configuration)
  - [x] configs/standard-web.json (pre-built configuration)
  - [x] configs/complex-web.json (pre-built configuration)
  - [x] configs/standard-mobile.json (pre-built configuration)
  - [x] configs/standard-fullstack.json (pre-built configuration)
  - [x] configs/custom-template.json (customization template)
  - [x] validate.sh (546 lines - post-setup validation)
- [x] **WP8: Testing & Examples** ✅ 100% (4/4 deliverables - 4 hours completed)
  - [x] scenarios.md (~1,100 lines - 8 end-to-end test scenarios)
  - [x] examples/web (~800 lines, 15 files - Next.js 14 example)
  - [x] examples/mobile (~700 lines, 14 files - Expo/React Native example)
  - [x] examples/fullstack (~3,800 lines, 30+ files - MERN-style monorepo)

**Phase 3 Status**: ✅ **100% COMPLETE** (15/15 deliverables, ~18,500 lines documented)
- **Commit 2ce8c02**: README.md + QUICK_START.md (735 lines)
- **Commit dc116d1**: COMPLETE_SETUP.md + TROUBLESHOOTING.md (1,582 lines)
- **Commit f098a82**: WORKFLOWS.md (2,555 lines)
- **Commit efed977**: COMMANDS.md (3,078 lines)
- **Commit b99caa0**: CUSTOMIZATION.md (989 lines)
- **Commit 9d2afcb**: ARCHITECTURE.md (1,287 lines) + WP6 COMPLETE
- **Commit 1bb36ee**: wizard.sh + 6 configs + validate.sh (~1,329 lines) + WP7 COMPLETE
- **Commit e83dc1b**: scenarios.md (~1,100 lines)
- **Commit 464bb06**: examples/web (~800 lines, 15 files)
- **Commit f1ea576**: examples/mobile (~700 lines, 14 files)
- **Commit [current]**: examples/fullstack (~3,800 lines, 30+ files)

**🎉 PHASE 3 100% COMPLETE! 🎉**

All 3 phases complete:
- **Phase 1**: ✅ 100% (19 files, 3,342 lines)
- **Phase 2**: ✅ 100% (12 files, 8,738 lines)
- **Phase 3**: ✅ 100% (15 deliverables, ~18,500 lines)

**Total**: 59 deliverables (~30,700 lines of production-ready code)

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

**Phase**: ✅ **ALL PHASES COMPLETE!** 🎉
**Week**: 3
**Last Updated**: 2025-11-06
**Overall Progress**:
- Phase 1: ✅ 100% Complete (19 files, 3,342 lines)
- Phase 2: ✅ 100% Complete (12 files, 8,738 lines)
- Phase 3: ✅ 100% Complete (15 deliverables, ~18,500 lines documented)
  - **WP6: Core Documentation** ✅ 100% COMPLETE (8/8 files)
  - **WP7: Setup Automation** ✅ 100% COMPLETE (10 files: wizard + 6 configs + validator)
  - **WP8: Testing & Examples** ✅ 100% COMPLETE (4/4 deliverables: scenarios + web + mobile + fullstack)
**Total Implementation**: 59 deliverables (~30,700 lines of production-ready code)

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
- ✅ **Session 4 Complete** - All 4 core slash commands created (2025-11-06):
  - /blueprint-init (544 lines - interactive setup wizard with validation)
  - /plan-to-issues (489 lines - convert plans to GitHub issues)
  - /commit-smart (650 lines - smart commit with quality checks + secret detection)
  - /create-pr (645 lines - PR creation with proper issue linking)
- ✅ **Session 5 Complete** - All 4 advanced slash commands created (2025-11-06):
  - /review-pr (550 lines - comprehensive Claude-powered code review)
  - /release (600 lines - production release management with changelog)
  - /sync-status (580 lines - bidirectional issue/board synchronization)
  - /kill-switch (450 lines - emergency workflow disable mechanism)
- ✅ **Session 6 Complete** - All 4 specialized subagents created (2025-11-06):
  - blueprint-setup (1,150 lines - autonomous setup wizard with error recovery)
  - plan-converter (1,080 lines - intelligent plan parser with priority calculation)
  - quality-orchestrator (980 lines - comprehensive quality gate manager)
  - workflow-manager (1,020 lines - master automation orchestrator)

**🎉 PHASE 2 COMPLETE! All 12 files created successfully (8,738 total lines)**

- ✅ **Session 7 - Part 1** - Core Documentation Started (2025-11-06):
  - README.md (enhanced - 400 lines, professional presentation)
  - QUICK_START.md (600 lines - 5-minute setup guide)
  - **Commit 2ce8c02**: 735 lines added

- ✅ **Session 7 - Part 2** - Documentation Continues (2025-11-06):
  - COMPLETE_SETUP.md (900+ lines - detailed installation)
  - TROUBLESHOOTING.md (1000+ lines - comprehensive issue resolution)
  - **Commit dc116d1**: 1,582 lines added

- ✅ **Session 12 Complete** - Fullstack example created (2025-11-06):
  - examples/fullstack/README.md (600 lines - comprehensive fullstack guide)
  - examples/fullstack/client/ (React + Vite monorepo workspace)
  - examples/fullstack/server/ (Express + TypeScript API)
  - Full monorepo with pnpm workspaces
  - REST API with CRUD operations
  - Complete test coverage (Jest + Supertest)

**🎉 PHASE 3 100% COMPLETE! 🎉**
**🎉 ALL 3 PHASES COMPLETE! 🎉**

### Implementation Complete

**✅ WP6: Core Documentation (COMPLETE)**
- ✅ README.md (professional first impression)
- ✅ QUICK_START.md (5-minute setup guide)
- ✅ COMPLETE_SETUP.md (detailed installation)
- ✅ TROUBLESHOOTING.md (comprehensive solutions)
- ✅ WORKFLOWS.md (8 workflows reference)
- ✅ COMMANDS.md (8 slash commands)
- ✅ CUSTOMIZATION.md (advanced configuration)
- ✅ ARCHITECTURE.md (system design)

**✅ WP7: Setup Automation (COMPLETE)**
- ✅ wizard.sh (interactive setup wizard - 783 lines)
- ✅ configs/simple-web.json (solo developers)
- ✅ configs/standard-web.json (small/medium teams - recommended)
- ✅ configs/complex-web.json (enterprise)
- ✅ configs/standard-mobile.json (React Native/Expo)
- ✅ configs/standard-fullstack.json (full-stack monorepo)
- ✅ configs/custom-template.json (customization template)
- ✅ validate.sh (post-setup validation - 546 lines)

**✅ WP8: Testing & Examples (COMPLETE)**
- ✅ tests/scenarios.md (8 end-to-end test scenarios - ~1,100 lines)
- ✅ examples/web/ (Next.js 14 example - ~800 lines, 15 files)
- ✅ examples/mobile/ (Expo/React Native example - ~700 lines, 14 files)
- ✅ examples/fullstack/ (MERN-style monorepo - ~3,800 lines, 30+ files)

**Blueprint Ready for Production Use! 🚀**

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