// ai.routes.js — /api/ai/*
import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import { chat } from '../controllers/ai.controller.js';
import { requireRole } from '../middleware/auth.middleware.js';

const __b2dir = path.dirname(fileURLToPath(import.meta.url));

// Store uploaded chat images temporarily (cleaned up after Gemini call)
const upload = multer({
  dest: path.resolve(__b2dir, '../storage/uploads/ai-tmp'),
  limits: { fileSize: 4 * 1024 * 1024 }, // 4MB per image
  fileFilter: (_req, file, cb) => {
    if (['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only JPG, PNG, or WEBP images'));
    }
  },
});

const router = Router();

router.post(
  '/chat',
  requireRole('farmer', 'admin'),
  upload.single('image'),
  chat
);

export default router;
