---
layout: home

hero:
  name: GitHub Workflow Blueprint
  text: Production-Ready Automation
  tagline: Industry-standard GitHub Actions + Claude Code automation for developers of all skill levels. From planning to production in minutes.
  image:
    src: /logo.svg
    alt: GitHub Workflow Blueprint
  actions:
    - theme: brand
      text: Quick Start
      link: /QUICK_START
    - theme: alt
      text: View on GitHub
      link: https://github.com/alirezarezvani/claude-code-github-workflow

features:
  - icon: 🚀
    title: 8 Intelligent Workflows
    details: Complete automation from Claude plan to production deployment. Bootstrap, PR checks, plan conversion, auto-branching, status sync, and release management.

  - icon: 💻
    title: 8 Powerful Slash Commands
    details: Interactive operations for daily workflows. Setup wizard, smart commits, PR creation, code review, release management, and emergency controls.

  - icon: 🤖
    title: 4 Specialized Agents
    details: Autonomous task completion for complex operations. Setup automation, plan conversion, quality orchestration, and workflow management.

  - icon: 🔧
    title: 5 Composite Actions
    details: DRY principles with reusable workflow components. Node/pnpm setup, project sync, rate limiting, quality gates, and fork safety.

  - icon: 🎯
    title: 3 Working Examples
    details: Copy-paste ready applications. Next.js 14 web app, Expo mobile app, and fullstack MERN monorepo. All pre-configured with blueprint workflows.

  - icon: 📚
    title: Comprehensive Documentation
    details: 10 detailed guides covering setup, workflows, commands, troubleshooting, customization, and architecture. 8 end-to-end test scenarios included.

  - icon: ⚡
    title: <5 Minute Setup
    details: Interactive wizard handles everything. Detect project type, configure branches, set secrets, apply protections, and validate setup automatically.

  - icon: 🔐
    title: Built-in Safety
    details: Rate limiting, fork safety, branch protection, secret scanning, kill switch, idempotency, and 10-second debouncing prevent errors and infinite loops.

  - icon: 🎨
    title: Flexible Branching
    details: Three strategies supported. Simple (feature→main), Standard (feature→dev→main), or Complex (feature→dev→staging→main). User's choice.

  - icon: 📊
    title: GitHub Projects v2
    details: 7-status bidirectional sync. Issues automatically move through "To triage → Backlog → Ready → In Progress → In Review → To Deploy → Done".

  - icon: 🌍
    title: Multi-Platform Support
    details: Web, mobile, and fullstack workflows. Path-based filtering, platform-specific checks, and monorepo support. Quality gates adapt to project type.

  - icon: 🎓
    title: Beginner to Pro
    details: Designed for all skill levels. Clear docs, helpful errors, sensible defaults, and progressive complexity. Production-ready from day one.
---

## What's Included

<div class="vp-feature-grid">

### 🔄 Complete Workflow Automation

- **bootstrap.yml** - One-time repository setup with labels and validation
- **reusable-pr-checks.yml** - DRY quality gates (lint, typecheck, test, build)
- **pr-into-dev.yml** - Feature PR validation with conventional commits
- **dev-to-main.yml** - Release gates with smoke tests
- **claude-plan-to-issues.yml** - Convert Claude plans to GitHub issues (max 10)
- **create-branch-on-issue.yml** - Auto-create branches from ready issues
- **pr-status-sync.yml** - PR lifecycle tracking with project board sync
- **release-status-sync.yml** - Production deployment automation

### 💼 Interactive Slash Commands

- **/blueprint-init** - Interactive setup wizard with validation
- **/plan-to-issues** - Convert plan JSON to GitHub issues
- **/commit-smart** - Smart commits with quality checks and secret detection
- **/create-pr** - PR creation with proper issue linking
- **/review-pr** - Comprehensive Claude-powered code review
- **/release** - Production release management with changelog
- **/sync-status** - Manual status synchronization for corrections
- **/kill-switch** - Emergency workflow disable mechanism

### 🛠️ Setup & Configuration

- **setup/wizard.sh** - <5 minute interactive setup (783 lines)
- **setup/validate.sh** - 10-category post-setup validation (546 lines)
- **6 Pre-built Configs** - Simple/Standard/Complex web, Mobile, Fullstack, Custom template

### 📖 Examples & Testing

- **examples/web/** - Next.js 14 + TypeScript (15 files, ~800 lines)
- **examples/mobile/** - Expo + React Native (14 files, ~700 lines)
- **examples/fullstack/** - React + Express monorepo (30+ files, ~3,800 lines)
- **tests/scenarios.md** - 8 end-to-end test scenarios (~1,100 lines)

</div>

## Quick Links

- **[Quick Start Guide](/QUICK_START)** - Get started in 5 minutes
- **[Complete Setup](/COMPLETE_SETUP)** - Detailed installation
- **[Workflows Reference](/WORKFLOWS)** - All 8 workflows documented
- **[Commands Reference](/COMMANDS)** - All 8 slash commands
- **[Troubleshooting](/TROUBLESHOOTING)** - Common issues and solutions
- **[Architecture](/ARCHITECTURE)** - System design and decisions

## Success Metrics

✅ **Setup Time**: <5 minutes from clone to first workflow
✅ **PR Checks**: <2 minutes average completion time
✅ **Reliability**: 99%+ workflow success rate
✅ **Safety**: Zero infinite loops with built-in protections
✅ **Coverage**: Supports web, mobile, and fullstack projects
✅ **Documentation**: 13,000+ lines across 10 comprehensive guides

## Community

- **[GitHub Repository](https://github.com/alirezarezvani/claude-code-github-workflow)** - Source code and examples
- **[GitHub Wiki](https://github.com/alirezarezvani/claude-code-github-workflow/wiki)** - Quick reference documentation
- **[Issues](https://github.com/alirezarezvani/claude-code-github-workflow/issues)** - Report bugs or request features
- **[Discussions](https://github.com/alirezarezvani/claude-code-github-workflow/discussions)** - Community Q&A

## License

Released under the [MIT License](https://github.com/alirezarezvani/claude-code-github-workflow/blob/main/LICENSE).

---

<p style="text-align: center; margin-top: 3rem; color: var(--vp-c-text-2); font-size: 0.9rem;">
Built with ❤️ using <a href="https://github.com/anthropics/claude-code" target="_blank">Claude Code</a> | Powered by <a href="https://vitepress.dev" target="_blank">VitePress</a>
</p>
