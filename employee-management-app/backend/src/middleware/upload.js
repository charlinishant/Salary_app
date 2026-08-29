import fs from 'fs';
import multer from 'multer';
import path from 'path';
import { HttpError } from '../utils/httpError.js';

const allowedMimeTypes = new Set([
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
  'application/pdf',
]);

const storage = multer.diskStorage({
  destination: (_req, file, cb) => {
    let dir = 'uploads/profile';
    if (file.fieldname.includes('selfie') || file.fieldname === 'selfie') {
      dir = 'uploads/attendance';
    } else if (file.fieldname.includes('bill') || file.fieldname.includes('expense') || file.fieldname.includes('reimbursement') || file.fieldname.includes('attachment') || file.fieldname.includes('file')) {
      dir = 'uploads/expenses';
    } else if (file.fieldname.includes('document')) {
      dir = 'uploads/documents';
    }
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  },
});

export const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (!allowedMimeTypes.has(file.mimetype)) {
      cb(new HttpError(400, 'Only JPG, PNG, WEBP, and PDF files are allowed'));
      return;
    }
    cb(null, true);
  },
});
