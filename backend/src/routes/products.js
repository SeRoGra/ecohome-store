const { Router } = require('express');
const { query }   = require('../config/db');
const auth        = require('../middleware/auth');

const router = Router();

// Todas las rutas requieren JWT
router.use(auth);

// GET /api/products — lista todos con datos del creador
router.get('/', async (req, res) => {
  try {
    const { rows } = await query(`
      SELECT p.id, p.name, p.description, p.price, p.stock,
             p.created_by, u.username AS creator_username,
             p.created_at, p.updated_at
      FROM products p
      JOIN users u ON u.id = p.created_by
      ORDER BY p.created_at DESC
    `);
    res.json(rows);
  } catch (err) {
    console.error('Error al listar productos:', err.message);
    res.status(500).json({ code: 'INTERNAL_ERROR', message: 'Error interno del servidor' });
  }
});

// POST /api/products — crea producto; creador tomado del JWT
router.post('/', async (req, res) => {
  try {
    const { name, description, price, stock } = req.body;
    if (!name || price === undefined) {
      return res.status(400).json({ code: 'BAD_REQUEST', message: 'name y price son requeridos' });
    }

    const { rows } = await query(`
      INSERT INTO products (name, description, price, stock, created_by)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, name, description, price, stock, created_by, created_at, updated_at
    `, [name, description || null, price, stock ?? 0, req.user.userId]);

    const product = rows[0];
    res.status(201).json({
      ...product,
      creator_username: req.user.username,
    });
  } catch (err) {
    console.error('Error al crear producto:', err.message);
    res.status(500).json({ code: 'INTERNAL_ERROR', message: 'Error interno del servidor' });
  }
});

// PUT /api/products/:id — actualiza producto
router.put('/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const { name, description, price, stock } = req.body;
    if (!name || price === undefined) {
      return res.status(400).json({ code: 'BAD_REQUEST', message: 'name y price son requeridos' });
    }

    const { rows } = await query(`
      UPDATE products
      SET name = $1, description = $2, price = $3, stock = $4, updated_at = NOW()
      WHERE id = $5
      RETURNING id, name, description, price, stock, created_by, created_at, updated_at
    `, [name, description || null, price, stock ?? 0, id]);

    if (rows.length === 0) {
      return res.status(404).json({ code: 'NOT_FOUND', message: 'Producto no encontrado' });
    }

    // Obtener username del creador
    const { rows: userRows } = await query('SELECT username FROM users WHERE id = $1', [rows[0].created_by]);
    res.json({ ...rows[0], creator_username: userRows[0]?.username });
  } catch (err) {
    console.error('Error al actualizar producto:', err.message);
    res.status(500).json({ code: 'INTERNAL_ERROR', message: 'Error interno del servidor' });
  }
});

// DELETE /api/products/:id — elimina producto
router.delete('/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const { rowCount } = await query('DELETE FROM products WHERE id = $1', [id]);
    if (rowCount === 0) {
      return res.status(404).json({ code: 'NOT_FOUND', message: 'Producto no encontrado' });
    }
    res.status(204).send();
  } catch (err) {
    console.error('Error al eliminar producto:', err.message);
    res.status(500).json({ code: 'INTERNAL_ERROR', message: 'Error interno del servidor' });
  }
});

module.exports = router;
