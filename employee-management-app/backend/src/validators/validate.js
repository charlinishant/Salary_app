import { validationResult } from 'express-validator';
import { HttpError } from '../utils/httpError.js';

export const validate = (req, _res, next) => {
  const result = validationResult(req);
  if (!result.isEmpty()) {
    const error = new HttpError(422, 'Validation failed');
    error.errors = result.array();
    next(error);
    return;
  }
  next();
};
