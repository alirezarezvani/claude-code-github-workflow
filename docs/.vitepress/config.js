import { defineConfig } from 'vitepress';

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: 'GitHub Workflow Blueprint',
  description:
    'Production-ready GitHub Actions + Claude Code automation blueprint for developers of all skill levels',

  // Base path for GitHub Pages (use repo name)
  base: '/claude-code-github-workflow/',

  // Clean URLs (remove .html extension)
  cleanUrls: true,

  // Last updated timestamp
  lastUpdated: true,

  // Markdown configuration
  markdown: {
    lineNumbers: true,
    theme: {
      light: 'github-light',
      dark: 'github-dark',
    },
  },

  // Head tags for SEO and PWA
  head: [
    ['link', { rel: 'icon', href: '/claude-code-github-workflow/favicon.ico' }],
    [
      'meta',
      {
        name: 'keywords',
        content:
          'github actions, claude code, workflow automation, ci/cd, github workflow, automation blueprint, claude ai',
      },
    ],
    ['meta', { property: 'og:type', content: 'website' }],
    [
      'meta',
      { property: 'og:title', content: 'GitHub Workflow Blueprint' },
    ],
    [
      'meta',
      {
        property: 'og:description',
        content:
          'Production-ready GitHub Actions + Claude Code automation blueprint',
      },
    ],
  ],

  // Theme configuration
  themeConfig: {
    // Site logo
    logo: '/logo.svg',

    // Navigation bar
    nav: [
      { text: 'Home', link: '/' },
      {
        text: 'Getting Started',
        items: [
          { text: 'Quick Start', link: '/QUICK_START' },
          { text: 'Complete Setup', link: '/COMPLETE_SETUP' },
        ],
      },
      {
        text: 'Guides',
        items: [
          { text: 'Workflows', link: '/WORKFLOWS' },
          { text: 'Commands', link: '/COMMANDS' },
          { text: 'Troubleshooting', link: '/TROUBLESHOOTING' },
          { text: 'Customization', link: '/CUSTOMIZATION' },
          { text: 'Architecture', link: '/ARCHITECTURE' },
        ],
      },
      { text: 'GitHub', link: 'https://github.com/alirezarezvani/claude-code-github-workflow' },
    ],

    // Sidebar navigation
    sidebar: [
      {
        text: 'Getting Started',
        collapsed: false,
        items: [
          { text: 'Introduction', link: '/' },
          { text: 'Quick Start', link: '/QUICK_START' },
          { text: 'Complete Setup', link: '/COMPLETE_SETUP' },
        ],
      },
      {
        text: 'Core Documentation',
        collapsed: false,
        items: [
          { text: 'Workflows Reference', link: '/WORKFLOWS' },
          { text: 'Slash Commands', link: '/COMMANDS' },
        ],
      },
      {
        text: 'Guides',
        collapsed: false,
        items: [
          { text: 'Troubleshooting', link: '/TROUBLESHOOTING' },
          { text: 'Customization', link: '/CUSTOMIZATION' },
          { text: 'Architecture', link: '/ARCHITECTURE' },
        ],
      },
      {
        text: 'Work Plans',
        collapsed: true,
        items: [
          { text: 'Phase 1 Workplan', link: '/PHASE1_WORKPLAN' },
          { text: 'Phase 2 Workplan', link: '/PHASE2_WORKPLAN' },
          { text: 'Phase 3 Workplan', link: '/PHASE3_WORKPLAN' },
        ],
      },
    ],

    // Social links
    socialLinks: [
      {
        icon: 'github',
        link: 'https://github.com/alirezarezvani/claude-code-github-workflow',
      },
    ],

    // Footer
    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2025 GitHub Workflow Blueprint',
    },

    // Edit link
    editLink: {
      pattern:
        'https://github.com/alirezarezvani/claude-code-github-workflow/edit/main/docs/:path',
      text: 'Edit this page on GitHub',
    },

    // Search (built-in local search)
    search: {
      provider: 'local',
      options: {
        detailedView: true,
        translations: {
          button: {
            buttonText: 'Search docs',
            buttonAriaLabel: 'Search documentation',
          },
          modal: {
            displayDetails: 'Display detailed list',
            resetButtonTitle: 'Reset search',
            backButtonTitle: 'Close search',
            noResultsText: 'No results for',
            footer: {
              selectText: 'to select',
              selectKeyAriaLabel: 'enter',
              navigateText: 'to navigate',
              navigateUpKeyAriaLabel: 'up arrow',
              navigateDownKeyAriaLabel: 'down arrow',
              closeText: 'to close',
              closeKeyAriaLabel: 'escape',
            },
          },
        },
      },
    },

    // Outline (table of contents)
    outline: {
      level: [2, 3],
      label: 'On this page',
    },

    // Last updated text
    lastUpdated: {
      text: 'Updated at',
      formatOptions: {
        dateStyle: 'full',
        timeStyle: 'medium',
      },
    },

    // External link icon
    externalLinkIcon: true,

    // Doc footer - prev/next navigation
    docFooter: {
      prev: 'Previous page',
      next: 'Next page',
    },

    // Return to top label
    returnToTopLabel: 'Return to top',

    // Sidebar menu label for mobile
    sidebarMenuLabel: 'Menu',

    // Dark mode switch label
    darkModeSwitchLabel: 'Appearance',

    // Light and dark mode switch title
    lightModeSwitchTitle: 'Switch to light theme',
    darkModeSwitchTitle: 'Switch to dark theme',
  },
});
