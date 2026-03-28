const { Router }       = require('express');
const bcrypt           = require('bcryptjs');
const { query }        = require('../config/db');
const { generateToken } = require('../utils/jwt');

const router = Router();

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ code: 'BAD_REQUEST', message: 'Username y password son requeridos' });
    }

    const { rows } = await query('SELECT * FROM users WHERE username = $1', [username]);
    if (rows.length === 0) {
      return res.status(401).json({ code: 'UNAUTHORIZED', message: 'Credenciales invalidas' });
    }

    const user = rows[0];
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(401).json({ code: 'UNAUTHORIZED', message: 'Credenciales invalidas' });
    }

    const token = generateToken(user.username, user.id, user.role);
    console.log(`Login exitoso: ${user.username}`);
    res.json({ token, username: user.username, role: user.role });
  } catch (err) {
    console.error('Error en login:', err.message);
    res.status(500).json({ code: 'INTERNAL_ERROR', message: 'Error interno del servidor' });
  }
});

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { username, email, password, role } = req.body;
    if (!username || !email || !password) {
      return res.status(400).json({ code: 'BAD_REQUEST', message: 'Username, email y password son requeridos' });
    }

    const existing = await query('SELECT 1 FROM users WHERE username = $1', [username]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ code: 'CONFLICT', message: 'Usuario ya existe' });
    }

    const existingEmail = await query('SELECT 1 FROM users WHERE email = $1', [email]);
    if (existingEmail.rows.length > 0) {
      return res.status(409).json({ code: 'CONFLICT', message: 'Email ya registrado' });
    }

    const hashed = await bcrypt.hash(password, 12);
    const { rows } = await query(
      'INSERT INTO users (username, email, password, role) VALUES ($1, $2, $3, $4) RETURNING id, username, role',
      [username, email, hashed, role || 'USER']
    );

    console.log(`Registro exitoso: ${rows[0].username}`);
    res.status(201).json({ token: null, username: rows[0].username, role: rows[0].role });
  } catch (err) {
    console.error('Error en registro:', err.message);
    res.status(500).json({ code: 'INTERNAL_ERROR', message: 'Error interno del servidor' });
  }
});

module.exports = router;
