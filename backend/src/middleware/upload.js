// upload.js — image upload middleware (multer), with safety limits.
// Files are stored on local disk under storage/uploads/crops (OUTSIDE web root).
// Security: whitelist real image mime types, cap file size, random filenames.
import multer from 'multer';
import { randomBytes } from 'crypto';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
// storage/uploads/crops lives at the project root, NOT under any web-served folder
export const UPLOAD_DIR = path.resolve(__dirname, '../../storage/uploads/crops');
fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const ALLOWED = new Set(['image/jpeg', 'image/png', 'image/webp']);

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, UPLOAD_DIR),
  filename: (_req, file, cb) => {
    // never trust the client filename — generate our own
    const ext = { 'image/jpeg': '.jpg', 'image/png': '.png', 'image/webp': '.webp' }[file.mimetype] || '';
    cb(null, `${Date.now()}-${randomBytes(6).toString('hex')}${ext}`);
  },
});

function fileFilter(_req, file, cb) {
  if (ALLOWED.has(file.mimetype)) return cb(null, true);
  cb(new Error('Only JPG, PNG, or WEBP images are allowed'));
}

export const uploadCropImages = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 2 * 1024 * 1024, // 2 MB per file
    files: 4,                  // up to 4 images per crop
  },
}).array('images', 4);

// wrap so multer errors become clean 400s instead of crashes
export function handleUpload(req, res, next) {
  uploadCropImages(req, res, (err) => {
    if (err) {
      const msg = err.code === 'LIMIT_FILE_SIZE' ? 'Each image must be under 2 MB' : err.message;
      return res.status(400).json({ error: msg });
    }
    next();
  });
}
