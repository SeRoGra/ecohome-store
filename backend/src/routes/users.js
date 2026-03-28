const { Router } = require('express');
const { query }   = require('../config/db');
const auth        = require('../middleware/auth');

const router = Router();

// GET /api/users/me/stats — estadísticas del usuario autenticado
router.get('/me/stats', auth, async (req, res) => {
  try {
    const { rows } = await query(
      'SELECT COUNT(*)::int AS product_count FROM products WHERE created_by = $1',
      [req.user.userId]
    );
    res.json({
      username:      req.user.username,
      role:          req.user.role,
      product_count: rows[0].product_count,
    });
  } catch (err) {
    console.error('Error al obtener stats:', err.message);
    res.status(500).json({ code: 'INTERNAL_ERROR', message: 'Error interno del servidor' });
  }
});

module.exports = router;
