# EcoHome Chat — Backend

Servidor Node.js con **Express.js**, **Socket.IO** y **PostgreSQL** para el chat corporativo y catálogo de productos en tiempo real.

> **Unidad 3**: este backend actúa como el **backend centralizado** que consume tanto la app React como la app Flutter, sin endpoints paralelos.

## Tecnologías

- **Express.js 4** — Servidor HTTP y rutas REST
- **Socket.IO 4** — WebSocket bidireccional con reconexión automática
- **PostgreSQL 16** — Persistencia de usuarios, mensajes y productos
- **JWT** (`jsonwebtoken`) — Autenticación stateless
- **BCrypt** (`bcryptjs`) — Hashing de contraseñas (cost 12)
- **Docker Compose** — Orquestación de servicios

## Estructura del proyecto

```
src/
├── index.js            ← Entry point: Express + HTTP + Socket.IO
├── config/
│   └── db.js           ← Pool de conexiones PostgreSQL (pg)
├── middleware/
│   └── auth.js         ← Middleware JWT para rutas protegidas
├── routes/
│   ├── auth.js         ← POST /api/auth/login, /register
│   ├── chat.js         ← GET /api/chat/history
│   ├── products.js     ← CRUD /api/products (Unidad 3)
│   └── users.js        ← GET /api/users/me/stats (Unidad 3)
├── socket/
│   └── chat.js         ← Handler Socket.IO: handshake JWT, eventos
└── utils/
    └── jwt.js          ← generateToken / verifyToken
db/
└── init.sql            ← Esquema + datos seed (usuarios + productos)
```

## Ejecución con Docker

```bash
docker-compose up -d --build
```

Levanta PostgreSQL (puerto 5432) y el backend (puerto 8080).

## Ejecución local (desarrollo)

```bash
# Requiere PostgreSQL corriendo en localhost:5432
npm install
npm run dev    # usa nodemon para hot-reload
```

## Variables de entorno (.env)

| Variable | Default | Descripción |
|----------|---------|-------------|
| `PORT` | 8080 | Puerto del servidor |
| `DB_HOST` | localhost | Host de PostgreSQL |
| `DB_PORT` | 5432 | Puerto de PostgreSQL |
| `DB_NAME` | ecohome_chat | Nombre de la base de datos |
| `DB_USER` | ecohome_user | Usuario de BD |
| `DB_PASSWORD` | ecohome_pass | Contraseña de BD |
| `JWT_SECRET` | — | Clave secreta para firmar tokens |
| `JWT_EXPIRATION` | 86400000 | Expiración del token (ms) |
| `CORS_ORIGIN` | `http://localhost:3000,http://localhost:3001` | Orígenes permitidos (separados por coma) |

## API REST

### Autenticación

#### POST `/api/auth/login`
```json
// Request
{ "username": "ventas_admin", "password": "password123" }

// Response 200
{ "token": "eyJ...", "username": "ventas_admin", "role": "VENTAS" }
```

#### POST `/api/auth/register`
```json
// Request
{ "username": "nuevo", "email": "nuevo@ecohome.co", "password": "mipass", "role": "USER" }

// Response 201
{ "token": null, "username": "nuevo", "role": "USER" }
```

### Chat

#### GET `/api/chat/history`
Header: `Authorization: Bearer <token>`

Retorna los últimos 10 mensajes ordenados cronológicamente.

### Productos (Unidad 3 — Trazabilidad)

Todos los endpoints requieren `Authorization: Bearer <token>`.

#### GET `/api/products`
Lista todos los productos con datos del creador.
```json
// Response 200
[
  {
    "id": 1,
    "name": "EcoBotella Acero 500ml",
    "description": "Botella reutilizable...",
    "price": "24.99",
    "stock": 100,
    "created_by": 1,
    "creator_username": "ventas_admin",
    "created_at": "2026-03-20T10:00:00.000Z",
    "updated_at": "2026-03-20T10:00:00.000Z"
  }
]
```

#### POST `/api/products`
Crea un producto. El `created_by` se toma **automáticamente** del JWT.
```json
// Request
{ "name": "EcoJarra", "price": 19.99, "stock": 50, "description": "Opcional" }

// Response 201
{ "id": 5, "name": "EcoJarra", ..., "creator_username": "ventas_admin" }
```

#### PUT `/api/products/:id`
Actualiza un producto existente.
```json
// Request
{ "name": "EcoJarra Pro", "price": 24.99, "stock": 45 }
```

#### DELETE `/api/products/:id`
Elimina un producto. Responde `204 No Content`.

### Usuarios — Stats (Unidad 3)

#### GET `/api/users/me/stats`
Header: `Authorization: Bearer <token>`
```json
// Response 200
{
  "username": "ventas_admin",
  "role": "VENTAS",
  "product_count": 14
}
```

## Socket.IO

Conexión con JWT en el handshake:
```javascript
const socket = io('http://localhost:8080', {
  auth: { token: '<JWT>' }
});
```

### Eventos

| Evento | Dirección | Descripción |
|--------|-----------|-------------|
| `messages` | Server → Client | Historial (10 últimos) al conectar |
| `new-message` | Client → Server | Enviar mensaje: `{ text }` |
| `new-message` | Server → Todos | Broadcast: `{ id, userId, username, text, role, createdAt }` |

## Base de datos

Tres tablas: `users`, `messages` y `products`. El esquema se inicializa automáticamente con `db/init.sql`.

**Tabla `products`** (Unidad 3):
- `id`, `name`, `description`, `price`, `stock`
- `created_by` → FK a `users.id` (trazabilidad del creador)
- `created_at`, `updated_at`

Usuarios seed (password: `password123`):
- `ventas_admin` (VENTAS)
- `logistica_op` (LOGISTICA)
- `soporte_01` (SOPORTE)

Productos seed: 4 productos eco-friendly pre-asignados a los usuarios seed.

## Pruebas con cURL

```bash
# 1. Login y obtener token
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"ventas_admin","password":"password123"}' | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

# 2. Crear producto (created_by se toma del JWT)
curl -X POST http://localhost:8080/api/products \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"EcoJarra","price":19.99,"stock":50}'

# 3. Listar productos con creador
curl http://localhost:8080/api/products \
  -H "Authorization: Bearer $TOKEN"

# 4. Ver estadísticas (contador del usuario)
curl http://localhost:8080/api/users/me/stats \
  -H "Authorization: Bearer $TOKEN"
```
