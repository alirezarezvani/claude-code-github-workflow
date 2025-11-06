import { useState, useEffect } from 'react';
import './App.css';

interface Book {
  id: string;
  title: string;
  author: string;
  year: number;
  genre: string;
}

const API_URL = '/api/books';

function App() {
  const [books, setBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchBooks();
  }, []);

  const fetchBooks = async () => {
    try {
      setLoading(true);
      const response = await fetch(API_URL);
      if (!response.ok) throw new Error('Failed to fetch books');
      const data = await response.json();
      setBooks(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="app">
      <header className="hero">
        <h1>🎯 GitHub Workflow Blueprint</h1>
        <p className="subtitle">Fullstack Example - React + Express</p>
      </header>

      <main className="container">
        <section className="card">
          <h2>📚 Book Catalog</h2>
          <p className="description">
            This is a minimal fullstack application demonstrating the GitHub
            Workflow Blueprint with both frontend and backend development.
          </p>
        </section>

        <section className="card">
          <h3>📖 Sample Books</h3>
          {loading && <p className="loading">Loading books...</p>}
          {error && <p className="error">Error: {error}</p>}
          {!loading && !error && books.length === 0 && (
            <p className="empty">No books found. Server returned empty array.</p>
          )}
          {!loading && !error && books.length > 0 && (
            <div className="books-grid">
              {books.map((book) => (
                <div key={book.id} className="book-card">
                  <h4>{book.title}</h4>
                  <p className="author">by {book.author}</p>
                  <p className="meta">
                    {book.year} • {book.genre}
                  </p>
                </div>
              ))}
            </div>
          )}
        </section>

        <section className="card">
          <h3>✨ Next Steps</h3>
          <ol className="steps">
            <li>
              <strong>Setup the blueprint:</strong> Run{' '}
              <code>./setup/wizard.sh</code> from repository root
            </li>
            <li>
              <strong>Convert plan to issues:</strong> Use{' '}
              <code>claude /plan-to-issues examples/fullstack/plan.json</code>
            </li>
            <li>
              <strong>Checkout auto-created branch:</strong> Issues labeled{' '}
              <code>status:ready</code> auto-create branches
            </li>
            <li>
              <strong>Develop with quality checks:</strong> Run{' '}
              <code>pnpm lint && pnpm type-check && pnpm test</code>
            </li>
            <li>
              <strong>Create PR:</strong> Use{' '}
              <code>claude /create-pr</code> with proper issue linking
            </li>
            <li>
              <strong>Deploy to production:</strong> Merge to main triggers
              deployment workflows
            </li>
          </ol>
        </section>

        <section className="card">
          <h3>🏗️ Monorepo Structure</h3>
          <div className="architecture">
            <div className="arch-item">
              <strong>Client (React + Vite)</strong>
              <p>Frontend running on <code>localhost:5173</code></p>
              <ul>
                <li>TypeScript + React 18</li>
                <li>Vite for fast builds</li>
                <li>Jest for testing</li>
              </ul>
            </div>
            <div className="arch-item">
              <strong>Server (Express API)</strong>
              <p>Backend running on <code>localhost:3001</code></p>
              <ul>
                <li>TypeScript + Express</li>
                <li>REST API endpoints</li>
                <li>In-memory data store</li>
              </ul>
            </div>
          </div>
        </section>

        <section className="card">
          <h3>🚀 Available Commands</h3>
          <div className="commands">
            <div className="command-group">
              <strong>Development:</strong>
              <code>pnpm dev</code>
              <p>Start both client and server</p>
            </div>
            <div className="command-group">
              <strong>Quality Checks:</strong>
              <code>pnpm lint && pnpm type-check && pnpm test</code>
              <p>Run all quality gates</p>
            </div>
            <div className="command-group">
              <strong>Production Build:</strong>
              <code>pnpm build</code>
              <p>Build both client and server</p>
            </div>
          </div>
        </section>
      </main>

      <footer className="footer">
        <p>
          Learn more:{' '}
          <a
            href="https://github.com/your-org/claudecode-github-bluprint"
            target="_blank"
            rel="noopener noreferrer"
          >
            GitHub Workflow Blueprint Documentation
          </a>
        </p>
      </footer>
    </div>
  );
}

export default App;
