import multer from 'multer';
import path from 'path';
import { HttpError } from '../utils/httpError.js';

const allowedMimeTypes = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/pdf',
]);

const storage = multer.diskStorage({
  destination: (_req, file, cb) => {
    if (file.fieldname.includes('selfie')) cb(null, 'uploads/attendance');
    else if (file.fieldname.includes('bill')) cb(null, 'uploads/expenses');
    else if (file.fieldname.includes('document')) cb(null, 'uploads/documents');
    else cb(null, 'uploads/profile');
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  },
});

export const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (!allowedMimeTypes.has(file.mimetype)) {
      cb(new HttpError(400, 'Only JPG, PNG, WEBP, and PDF files are allowed'));
      return;
    }
    cb(null, true);
  },
});
