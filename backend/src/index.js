require('dotenv').config();

const express          = require('express');
const http             = require('http');
const cors             = require('cors');
const morgan           = require('morgan');
const authRouter       = require('./routes/auth');
const chatRouter       = require('./routes/chat');
const productsRouter   = require('./routes/products');
const usersRouter      = require('./routes/users');
const { initSocket }   = require('./socket/chat');

const app    = express();
const server = http.createServer(app);

// En desarrollo se permite cualquier origen localhost (Flutter web usa puertos aleatorios).
// En producción, definir CORS_ORIGIN con los dominios exactos separados por coma.
const CORS_ORIGIN = process.env.CORS_ORIGIN || '';

app.use(cors({
  origin: (origin, callback) => {
    // Sin origin → apps móviles nativas, Postman, cURL → siempre OK
    if (!origin) return callback(null, true);

    // Si hay lista explícita en variables de entorno, usarla
    if (CORS_ORIGIN) {
      const allowed = CORS_ORIGIN.split(',').map(o => o.trim());
      if (allowed.includes(origin)) return callback(null, true);
      return callback(new Error(`CORS bloqueado para origin: ${origin}`));
    }

    // Sin lista → modo desarrollo: permitir localhost, 127.0.0.1 y cualquier IP privada
    if (/^https?:\/\/(localhost|127\.0\.0\.1|\d{1,3}(\.\d{1,3}){3})(:\d+)?$/.test(origin)) {
      return callback(null, true);
    }

    callback(new Error(`CORS bloqueado para origin: ${origin}`));
  },
  credentials: true,
}));
app.use(express.json());
app.use(morgan('dev'));

// Rutas REST
app.use('/api/auth',     authRouter);
app.use('/api/chat',     chatRouter);
app.use('/api/products', productsRouter);
app.use('/api/users',    usersRouter);

// Health check
app.get('/health', (_req, res) => res.json({ status: 'UP' }));

// Socket.IO
initSocket(server);

// Iniciar servidor
const PORT = process.env.PORT || 8080;
server.listen(PORT, () => {
  console.log(`EcoHome Chat Backend corriendo en puerto ${PORT}`);
  console.log(`Socket.IO listo para conexiones`);
});
