const { Server }      = require('socket.io');
const { verifyToken } = require('../utils/jwt');
const { query }       = require('../config/db');

function initSocket(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin:      process.env.CORS_ORIGIN || 'http://localhost:3000',
      credentials: true,
    },
  });

  // Middleware: autenticacion JWT en el handshake
  io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) return next(new Error('Token requerido'));

    try {
      socket.user = verifyToken(token);
      next();
    } catch {
      next(new Error('Token invalido o expirado'));
    }
  });

  io.on('connection', async (socket) => {
    const { username, userId, role } = socket.user;
    console.log(`WS CONECTADO    - user='${username}' role='${role}' socketId='${socket.id}'`);

    // Enviar ultimos 10 mensajes al conectarse
    try {
      const { rows } = await query(`
        SELECT m.id, m.user_id AS "userId", m.username, m.text,
               m.created_at AS "createdAt", u.role
        FROM messages m
        JOIN users u ON m.user_id = u.id
        ORDER BY m.created_at DESC
        LIMIT 10
      `);
      socket.emit('messages', rows.reverse());
    } catch (err) {
      console.error('Error cargando historial:', err.message);
    }

    // Recibir new-message y hacer broadcast
    socket.on('new-message', async ({ text }) => {
      if (!text || text.length === 0 || text.length > 2000) return;

      try {
        const { rows } = await query(
          'INSERT INTO messages (user_id, username, text) VALUES ($1, $2, $3) RETURNING id, user_id AS "userId", username, text, created_at AS "createdAt"',
          [userId, username, text]
        );
        const msg = { ...rows[0], role };
        io.emit('new-message', msg);
        console.log(`Mensaje de '${username}': ${text.substring(0, 50)}...`);
      } catch (err) {
        console.error('Error guardando mensaje:', err.message);
      }
    });

    socket.on('disconnect', () => {
      console.log(`WS DESCONECTADO - user='${username}' socketId='${socket.id}'`);
    });
  });

  return io;
}

module.exports = { initSocket };
