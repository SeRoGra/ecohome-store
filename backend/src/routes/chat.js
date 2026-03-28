const { Router }     = require('express');
const { query }      = require('../config/db');
const authMiddleware = require('../middleware/auth');

const router = Router();

// GET /api/chat/history (protegido con JWT)
router.get('/history', authMiddleware, async (req, res) => {
  try {
    const { rows } = await query(`
      SELECT m.id, m.user_id AS "userId", m.username, m.text,
             m.created_at AS "createdAt", u.role
      FROM messages m
      JOIN users u ON m.user_id = u.id
      ORDER BY m.created_at DESC
      LIMIT 10
    `);
    res.json(rows.reverse());
  } catch (err) {
    console.error('Error obteniendo historial:', err.message);
    res.status(500).json({ code: 'INTERNAL_ERROR', message: 'Error interno del servidor' });
  }
});

module.exports = router;
