// auth.routes.js — /api/auth/* routes.
// Ports from: the auth entries in core/Router.php.
import { Router } from 'express';
import { register } from '../controllers/auth.controller.js';

const router = Router();

router.post('/register', register);
// login, logout, verify-otp, switch-role land here in slices A2, A3, A5

export default router;
