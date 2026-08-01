import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    // optional: proxy /api to the backend so you can drop the full URL in client.js
    // proxy: { '/api': 'http://localhost:4000' },
  },
});
