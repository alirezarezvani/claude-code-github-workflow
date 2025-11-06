import { Router, Request, Response } from 'express';
import { BookStore } from '../data/store.js';
import type { CreateBookDTO, UpdateBookDTO } from '../models/Book.js';

const router = Router();

// GET /api/books - List all books
router.get('/', async (_req: Request, res: Response) => {
  try {
    const books = await BookStore.findAll();
    res.json(books);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch books' });
  }
});

// GET /api/books/:id - Get book by ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const book = await BookStore.findById(req.params.id);
    if (!book) {
      return res.status(404).json({ error: 'Book not found' });
    }
    res.json(book);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch book' });
  }
});

// POST /api/books - Create new book
router.post('/', async (req: Request, res: Response) => {
  try {
    const dto: CreateBookDTO = req.body;

    // Basic validation
    if (!dto.title || !dto.author || !dto.year || !dto.genre) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const book = await BookStore.create(dto);
    res.status(201).json(book);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create book' });
  }
});

// PUT /api/books/:id - Update book
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const dto: UpdateBookDTO = req.body;
    const book = await BookStore.update(req.params.id, dto);

    if (!book) {
      return res.status(404).json({ error: 'Book not found' });
    }

    res.json(book);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update book' });
  }
});

// DELETE /api/books/:id - Delete book
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const success = await BookStore.delete(req.params.id);

    if (!success) {
      return res.status(404).json({ error: 'Book not found' });
    }

    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete book' });
  }
});

export default router;
