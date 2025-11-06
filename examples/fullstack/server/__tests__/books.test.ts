import request from 'supertest';
import app from '../src/app.js';
import { BookStore } from '../src/data/store.js';

describe('Books API', () => {
  beforeEach(() => {
    // Reset store before each test
    BookStore.reset();
  });

  describe('GET /api/books', () => {
    it('should return an array of books', async () => {
      const response = await request(app).get('/api/books');

      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
    });
  });

  describe('POST /api/books', () => {
    it('should create a new book', async () => {
      const newBook = {
        title: 'Test Book',
        author: 'Test Author',
        year: 2024,
        genre: 'Test Genre',
      };

      const response = await request(app).post('/api/books').send(newBook);

      expect(response.status).toBe(201);
      expect(response.body).toMatchObject(newBook);
      expect(response.body.id).toBeDefined();
    });

    it('should return 400 for missing fields', async () => {
      const invalidBook = {
        title: 'Test Book',
        // Missing other required fields
      };

      const response = await request(app).post('/api/books').send(invalidBook);

      expect(response.status).toBe(400);
      expect(response.body.error).toBeDefined();
    });
  });

  describe('GET /api/books/:id', () => {
    it('should return a book by ID', async () => {
      // Create a book first
      const newBook = {
        title: 'Test Book',
        author: 'Test Author',
        year: 2024,
        genre: 'Test Genre',
      };
      const createResponse = await request(app).post('/api/books').send(newBook);
      const bookId = createResponse.body.id;

      const response = await request(app).get(`/api/books/${bookId}`);

      expect(response.status).toBe(200);
      expect(response.body.id).toBe(bookId);
    });

    it('should return 404 for non-existent book', async () => {
      const response = await request(app).get('/api/books/999');

      expect(response.status).toBe(404);
    });
  });

  describe('PUT /api/books/:id', () => {
    it('should update a book', async () => {
      // Create a book first
      const newBook = {
        title: 'Test Book',
        author: 'Test Author',
        year: 2024,
        genre: 'Test Genre',
      };
      const createResponse = await request(app).post('/api/books').send(newBook);
      const bookId = createResponse.body.id;

      const updates = {
        title: 'Updated Title',
      };

      const response = await request(app)
        .put(`/api/books/${bookId}`)
        .send(updates);

      expect(response.status).toBe(200);
      expect(response.body.title).toBe('Updated Title');
    });

    it('should return 404 for non-existent book', async () => {
      const response = await request(app).put('/api/books/999').send({
        title: 'Updated',
      });

      expect(response.status).toBe(404);
    });
  });

  describe('DELETE /api/books/:id', () => {
    it('should delete a book', async () => {
      // Create a book first
      const newBook = {
        title: 'Test Book',
        author: 'Test Author',
        year: 2024,
        genre: 'Test Genre',
      };
      const createResponse = await request(app).post('/api/books').send(newBook);
      const bookId = createResponse.body.id;

      const response = await request(app).delete(`/api/books/${bookId}`);

      expect(response.status).toBe(204);

      // Verify it's deleted
      const getResponse = await request(app).get(`/api/books/${bookId}`);
      expect(getResponse.status).toBe(404);
    });

    it('should return 404 for non-existent book', async () => {
      const response = await request(app).delete('/api/books/999');

      expect(response.status).toBe(404);
    });
  });
});
