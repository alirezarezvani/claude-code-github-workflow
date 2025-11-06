# Fullstack Example - GitHub Workflow Blueprint

A minimal fullstack (MERN-style) application demonstrating the GitHub Workflow Blueprint with both frontend and backend development.

## 📋 Overview

This example showcases a **monorepo structure** with:
- **Client**: React 18 + TypeScript frontend (Vite)
- **Server**: Express + TypeScript REST API
- **Data**: In-memory storage (production would use MongoDB)
- **Testing**: Jest for both client and server
- **Blueprint Integration**: Fullstack workflow with coordinated deployments

**Demo Application**: Simple book catalog with CRUD operations

---

## 🏗️ Project Structure

```
examples/fullstack/
├── README.md                 # This file
├── package.json              # Root workspace config
├── pnpm-workspace.yaml       # pnpm workspaces
├── plan.json                 # Example plan (5 fullstack tasks)
├── test-data/                # Sample data
│   ├── example-issue.json    # Example GitHub issue
│   └── example-pr.json       # Example GitHub PR
│
├── client/                   # React frontend
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── index.html
│   ├── src/
│   │   ├── main.tsx
│   │   ├── App.tsx
│   │   ├── App.css
│   │   └── vite-env.d.ts
│   └── __tests__/
│       └── App.test.tsx
│
└── server/                   # Express backend
    ├── package.json
    ├── tsconfig.json
    ├── jest.config.js
    ├── src/
    │   ├── index.ts          # Entry point
    │   ├── app.ts            # Express app
    │   ├── routes/
    │   │   └── books.ts      # Book API routes
    │   ├── models/
    │   │   └── Book.ts       # Book type/interface
    │   └── data/
    │       └── store.ts      # In-memory data store
    └── __tests__/
        └── books.test.ts     # API tests
```

---

## 🚀 Quick Start

### Prerequisites

- Node.js 20+ and pnpm 9+ installed
- Git configured
- GitHub CLI (`gh`) installed
- `ANTHROPIC_API_KEY` and `PROJECT_URL` secrets configured

### Installation

```bash
# 1. Navigate to this example
cd examples/fullstack

# 2. Install dependencies (installs both client and server)
pnpm install

# 3. Start development servers (both client and server)
pnpm dev
```

This starts:
- **Frontend**: `http://localhost:5173` (Vite dev server)
- **Backend**: `http://localhost:3001` (Express API)

Visit the frontend URL to see the application running.

### Available Commands

**Root workspace:**
```bash
pnpm install          # Install all dependencies
pnpm dev              # Start both client and server in parallel
pnpm build            # Build both client and server
pnpm lint             # Lint both client and server
pnpm type-check       # Type-check both client and server
pnpm test             # Test both client and server
```

**Client only:**
```bash
cd client
pnpm dev              # Start Vite dev server (port 5173)
pnpm build            # Build for production
pnpm preview          # Preview production build
pnpm lint             # Lint frontend code
pnpm type-check       # Type-check frontend
pnpm test             # Run frontend tests
```

**Server only:**
```bash
cd server
pnpm dev              # Start Express server (port 3001)
pnpm build            # Build TypeScript to JavaScript
pnpm start            # Start production server
pnpm lint             # Lint backend code
pnpm type-check       # Type-check backend
pnpm test             # Run API tests
```

---

## 🔄 Blueprint Workflow Integration

This example demonstrates the complete blueprint workflow for fullstack development:

### 1. Setup the Blueprint

From the repository root:

```bash
# Run the interactive setup wizard
./setup/wizard.sh

# Or manually configure
claude /blueprint-init
```

### 2. Convert Plan to GitHub Issues

Use the included `plan.json` to create 5 coordinated fullstack tasks:

```bash
# Using slash command (recommended)
claude /plan-to-issues examples/fullstack/plan.json

# OR trigger workflow directly
gh workflow run claude-plan-to-issues.yml \
  -f plan_json="$(cat examples/fullstack/plan.json)"
```

This creates:
- **Issue #1**: Setup monorepo structure (foundation)
- **Issue #2**: Create Book API (backend)
- **Issue #3**: Build Book list UI (frontend)
- **Issue #4**: Add create/edit forms (fullstack)
- **Issue #5**: Add search/filter (fullstack)

### 3. Auto-Branch Creation

When issues get the `status:ready` label, branches are auto-created:

```bash
# Branch format: feature/issue-{number}-{slug}
# Examples:
#   feature/issue-1-setup-monorepo-structure
#   feature/issue-2-create-book-api
#   feature/issue-3-build-book-list-ui
```

### 4. Development Workflow

```bash
# Checkout the auto-created branch
git fetch origin
git checkout feature/issue-1-setup-monorepo-structure

# Make changes in both client/ and server/
# ... edit files ...

# Quality checks (runs on both client and server)
pnpm lint
pnpm type-check
pnpm test
pnpm build

# Smart commit with quality checks
claude /commit-smart

# Create PR with proper linking
claude /create-pr
```

### 5. PR Review & Merge

```bash
# Automated quality checks run:
# - Lint both client and server
# - Type-check both workspaces
# - Run tests for both
# - Build both for production
# - Path-based filtering (client/* or server/* changes)

# Claude-powered code review
claude /review-pr <pr-number>

# After approval, merge triggers:
# - Issue status update: "In Review" → "To Deploy"
# - Auto-deletion of feature branch
```

### 6. Production Release

```bash
# Create release PR (dev → main)
claude /release

# After merge to main:
# - All linked issues closed
# - Project status: "Done"
# - GitHub release created (optional)
# - Deployment triggered (if configured)
```

---

## 📦 Application Details

### API Endpoints

**Base URL**: `http://localhost:3001/api`

```http
GET    /api/books          # List all books
GET    /api/books/:id      # Get book by ID
POST   /api/books          # Create new book
PUT    /api/books/:id      # Update book
DELETE /api/books/:id      # Delete book
```

**Book Schema**:
```typescript
interface Book {
  id: string;
  title: string;
  author: string;
  year: number;
  genre: string;
  createdAt: Date;
  updatedAt: Date;
}
```

### Frontend Features

- **Book List**: Display all books in a responsive grid
- **Book Details**: View individual book information
- **Create Book**: Form to add new books
- **Edit Book**: Form to update existing books
- **Delete Book**: Remove books with confirmation
- **Search**: Filter books by title, author, or genre
- **Error Handling**: User-friendly error messages
- **Loading States**: Spinners during API calls

---

## 🧪 Testing

### Run All Tests

```bash
# From root (tests both client and server)
pnpm test
```

### Client Tests

```bash
cd client
pnpm test

# Tests include:
# - Component rendering
# - User interactions
# - API integration
# - Error handling
```

### Server Tests

```bash
cd server
pnpm test

# Tests include:
# - API endpoints (CRUD operations)
# - Request validation
# - Error responses
# - Data persistence
```

---

## 🚀 Deployment

### Build for Production

```bash
# Build both client and server
pnpm build

# Output:
# - client/dist/        → Static files for hosting (Vercel, Netlify, S3)
# - server/dist/        → Compiled JavaScript for Node.js server
```

### Deployment Options

**Client (Static Hosting)**:
- Vercel: `vercel deploy client/dist`
- Netlify: `netlify deploy --dir=client/dist`
- AWS S3: `aws s3 sync client/dist s3://your-bucket`

**Server (Node.js Hosting)**:
- Heroku: `git push heroku main`
- Railway: `railway up`
- AWS EC2/ECS: Deploy `server/dist` with Node.js runtime
- Docker: Create Dockerfile for `server/`

**Environment Variables**:
```bash
# Client (.env)
VITE_API_URL=https://your-api.com/api

# Server (.env)
PORT=3001
NODE_ENV=production
MONGODB_URI=mongodb://... # If using real database
```

---

## 🔧 Customization

### Switch to MongoDB

Replace `server/src/data/store.ts` with MongoDB client:

```typescript
// server/src/data/database.ts
import { MongoClient } from 'mongodb';

const client = new MongoClient(process.env.MONGODB_URI!);
await client.connect();

export const db = client.db('bookstore');
export const booksCollection = db.collection('books');
```

Update routes to use MongoDB queries instead of in-memory store.

### Add Authentication

1. Install dependencies:
```bash
cd server
pnpm add express-session passport passport-local bcrypt
pnpm add -D @types/express-session @types/passport
```

2. Add auth middleware:
```typescript
// server/src/middleware/auth.ts
export function requireAuth(req, res, next) {
  if (!req.isAuthenticated()) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}
```

3. Protect routes:
```typescript
router.post('/books', requireAuth, createBook);
```

### Add Mobile Client

Create a React Native client alongside the web client:

```bash
# In examples/fullstack/
mkdir mobile
cd mobile
npx create-expo-app . --template blank-typescript

# Share API types between clients
ln -s ../server/src/models shared-types
```

---

## 📚 Learn More

- **GitHub Workflow Blueprint**: See repository root README.md
- **Slash Commands**: Check `.claude/commands/github/` for available commands
- **Workflows**: See `.github/workflows/` for automation details
- **React + Vite**: https://vitejs.dev/guide/
- **Express**: https://expressjs.com/
- **TypeScript**: https://www.typescriptlang.org/

---

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Kill process on port 3001 (server)
lsof -ti:3001 | xargs kill -9

# Kill process on port 5173 (client)
lsof -ti:5173 | xargs kill -9
```

### CORS Errors

Server includes CORS middleware for `http://localhost:5173`. Update if needed:

```typescript
// server/src/app.ts
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:5173'
}));
```

### API Connection Failed

Check server is running:
```bash
curl http://localhost:3001/api/books
```

Update client API URL if needed:
```typescript
// client/src/config.ts
export const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001/api';
```

### Build Failures

Clear caches and reinstall:
```bash
# From root
rm -rf node_modules client/node_modules server/node_modules
rm -rf client/dist server/dist
pnpm install
pnpm build
```

---

## 📄 License

This example is part of the GitHub Workflow Blueprint and is provided as-is for demonstration purposes.

---

**Generated with the GitHub Workflow Blueprint** 🚀
Learn more: https://github.com/your-org/claudecode-github-bluprint
