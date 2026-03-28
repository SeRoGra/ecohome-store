# EcoHome Store

Sistema fullstack que integra autenticación JWT, gestión de productos con trazabilidad, y chat en tiempo real. Construido con Express.js, React y Flutter sobre una base de datos PostgreSQL.

---

## Estructura del repositorio

```
ecohome-store/
├── backend/          # API REST + Socket.IO (Express.js + PostgreSQL + JWT)
├── web-react/        # Frontend web (React 18 + socket.io-client)
├── mobile-flutter/   # App móvil multiplataforma (Flutter)
└── db/
    └── init.sql      # Schema + datos de prueba
```

---

## Requisitos previos

- Node.js >= 18
- Flutter SDK >= 3.0
- Docker y Docker Compose (para PostgreSQL)

---

## Variables de entorno — Backend

Crear `backend/.env` (o copiar `backend/.env` ya incluido):

```env
PORT=8080
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecohome_chat
DB_USER=ecohome_user
DB_PASSWORD=ecohome_pass
JWT_SECRET=<clave-secreta-aleatoria>
JWT_EXPIRATION=86400000
CORS_ORIGIN=http://localhost:3000
```

---

## Cómo correr el proyecto

### 1. Base de datos (PostgreSQL vía Docker)

```bash
cd backend
docker-compose up -d
```

El script `db/init.sql` se ejecuta automáticamente al iniciar el contenedor y crea las tablas `users`, `products` y `messages` con datos de prueba.

### 2. Backend

```bash
cd backend
npm install
npm run dev        # desarrollo (nodemon)
# o
npm start          # producción
```

El servidor queda disponible en `http://localhost:8080`.

### 3. Frontend Web (React)

```bash
cd web-react
npm install
npm start
```

La app queda disponible en `http://localhost:3000`.

### 4. App Móvil (Flutter)

```bash
cd mobile-flutter
flutter pub get
flutter run                              # emulador por defecto
# Para apuntar a backend en red local:
flutter run --dart-define=API_BASE_URL=http://<IP-local>:8080
```

---

## Credenciales de prueba

| Usuario | Email | Contraseña | Rol |
|---|---|---|---|
| ventas_admin | ventas@ecohome.co | password123 | VENTAS |
| logistica_op | logistica@ecohome.co | password123 | LOGISTICA |
| soporte_01 | soporte@ecohome.co | password123 | SOPORTE |

---

## Rutas HTTP (API REST)

### Autenticación
| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/auth/signup` | Registro de usuario |
| POST | `/api/auth/login` | Login → devuelve JWT |

### Productos (requieren `Authorization: Bearer <token>`)
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/products` | Listar todos los productos (incluye creador) |
| GET | `/api/products/:id` | Obtener producto por ID |
| POST | `/api/products` | Crear producto |
| PUT | `/api/products/:id` | Actualizar producto |
| DELETE | `/api/products/:id` | Eliminar producto |

### Usuario (requiere `Authorization: Bearer <token>`)
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/users/me` | Datos del usuario autenticado |
| GET | `/api/users/me/stats` | Contador de productos creados por el usuario |

### Chat
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/chat/history` | Últimos 10 mensajes (requiere token) |

### Salud
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/health` | Health check del servidor |

---

## Eventos Socket.IO

El socket requiere autenticación JWT en el handshake:

```js
const socket = io('http://localhost:8080', {
  auth: { token: '<jwt-token>' }
});
```

| Evento | Dirección | Descripción |
|---|---|---|
| `messages` | Server → Client | Historial de últimos 10 mensajes (al conectar) |
| `new-message` | Client → Server | Enviar mensaje `{ text: string }` |
| `new-message` | Server → All | Broadcast del mensaje a todos los clientes |

---

## Base de datos — Tablas

```sql
users      (id, username, email, password, role, created_at)
products   (id, name, description, price, stock, created_by FK→users.id, created_at, updated_at)
messages   (id, user_id FK→users.id, username, text, created_at)
```
