export interface Book {
  id: string;
  title: string;
  author: string;
  year: number;
  genre: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateBookDTO {
  title: string;
  author: string;
  year: number;
  genre: string;
}

export interface UpdateBookDTO {
  title?: string;
  author?: string;
  year?: number;
  genre?: string;
}
