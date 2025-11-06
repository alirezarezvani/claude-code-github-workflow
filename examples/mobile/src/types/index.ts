// Navigation types
export type RootStackParamList = {
  Home: undefined;
  // Add more screens here as needed
};

// Example Note type for future implementation
export interface Note {
  id: string;
  title: string;
  content: string;
  createdAt: Date;
  updatedAt: Date;
}
