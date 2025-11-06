import type { Book, CreateBookDTO, UpdateBookDTO } from '../models/Book.js';

// In-memory data store (production would use MongoDB)
let books: Book[] = [
  {
    id: '1',
    title: 'The Pragmatic Programmer',
    author: 'Andrew Hunt, David Thomas',
    year: 1999,
    genre: 'Programming',
    createdAt: new Date('2024-01-01'),
    updatedAt: new Date('2024-01-01'),
  },
  {
    id: '2',
    title: 'Clean Code',
    author: 'Robert C. Martin',
    year: 2008,
    genre: 'Programming',
    createdAt: new Date('2024-01-02'),
    updatedAt: new Date('2024-01-02'),
  },
  {
    id: '3',
    title: 'Design Patterns',
    author: 'Gang of Four',
    year: 1994,
    genre: 'Software Engineering',
    createdAt: new Date('2024-01-03'),
    updatedAt: new Date('2024-01-03'),
  },
];

export class BookStore {
  static async findAll(): Promise<Book[]> {
    return books;
  }

  static async findById(id: string): Promise<Book | undefined> {
    return books.find((book) => book.id === id);
  }

  static async create(dto: CreateBookDTO): Promise<Book> {
    const newBook: Book = {
      id: (books.length + 1).toString(),
      ...dto,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    books.push(newBook);
    return newBook;
  }

  static async update(id: string, dto: UpdateBookDTO): Promise<Book | null> {
    const index = books.findIndex((book) => book.id === id);
    if (index === -1) return null;

    books[index] = {
      ...books[index],
      ...dto,
      updatedAt: new Date(),
    };
    return books[index];
  }

  static async delete(id: string): Promise<boolean> {
    const index = books.findIndex((book) => book.id === id);
    if (index === -1) return false;

    books = books.filter((book) => book.id !== id);
    return true;
  }

  // Utility for testing
  static reset(): void {
    books = [];
  }
}
