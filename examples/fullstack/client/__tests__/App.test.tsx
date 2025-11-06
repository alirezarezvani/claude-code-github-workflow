import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import App from '../src/App';

// Mock fetch for tests
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve([]),
  } as Response)
);

describe('App Component', () => {
  beforeEach(() => {
    (fetch as jest.Mock).mockClear();
  });

  it('renders the main heading', () => {
    render(<App />);
    const heading = screen.getByText(/GitHub Workflow Blueprint/i);
    expect(heading).toBeInTheDocument();
  });

  it('renders the subtitle', () => {
    render(<App />);
    const subtitle = screen.getByText(/Fullstack Example - React \+ Express/i);
    expect(subtitle).toBeInTheDocument();
  });

  it('shows loading state initially', () => {
    render(<App />);
    const loading = screen.getByText(/Loading books\.\.\./i);
    expect(loading).toBeInTheDocument();
  });

  it('calls the API on mount', () => {
    render(<App />);
    expect(fetch).toHaveBeenCalledWith('/api/books');
  });
});
