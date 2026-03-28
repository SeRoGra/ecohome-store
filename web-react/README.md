# EcoHome Chat — Frontend

Aplicación **React 18** con **socket.io-client** para el chat corporativo y catálogo de productos de EcoHome Store.

> **Unidad 3**: se agregó pantalla de Catálogo de Productos con trazabilidad (creador) y contador dinámico `"Usuario (N)"`.

## Tecnologías

- **React 18** — UI con hooks y lazy loading
- **socket.io-client 4** — Comunicación WebSocket con reconexión automática
- **Axios** — Cliente HTTP para endpoints REST
- **CSS custom** — Diseño inspirado en Slack/Discord con tema oscuro

## Estructura del proyecto

```
src/
├── App.jsx                    ← Router con navegación entre vistas (products/chat)
├── api/
│   └── chatApi.js             ← Cliente Axios + helpers: login, register, getHistory,
│                                 getProducts, createProduct, getUserStats
├── components/
│   ├── Login.jsx              ← Formulario de login/registro
│   ├── Login.css
│   ├── ChatScreen.jsx         ← Chat en tiempo real: sidebar + mensajes + input
│   ├── ChatScreen.css
│   ├── ProductsScreen.jsx     ← Catálogo: lista + formulario creación + contador (Unidad 3)
│   └── ProductsScreen.css
├── hooks/
│   ├── useAuth.js             ← Hook de autenticación con localStorage
│   └── useSocket.js           ← Hook Socket.IO: mensajes, conexión
└── styles/
    └── global.css             ← Variables CSS y reset global
```

## Ejecución

```bash
npm install
npm start
```

Disponible en `http://localhost:3000`. Requiere el backend corriendo en `http://localhost:8080`.

## Variable de entorno

```bash
# .env
REACT_APP_API_URL=http://localhost:8080
```

## Funcionalidades (Unidad 3)

### Pantalla de Catálogo (`/products`)
- **Header dinámico**: muestra `"Username (N)"` con el conteo de productos creados por el usuario
- **Lista de productos**: nombre, precio, stock y creador (`creator_username`) de cada producto
- **Formulario de creación**: nombre, descripción (opcional), precio, stock
- **Actualización dinámica**: tras crear un producto, el contador se incrementa inmediatamente sin recargar la página
- **Navegación**: botón en sidebar para cambiar entre Catálogo y Chat

### Pantalla de Chat (existente)
- Mensajes en tiempo real vía Socket.IO
- Separadores de fecha, avatares por rol, indicador de conexión
- **Nuevo**: enlace a Catálogo en el sidebar

## Cuentas de prueba

| Usuario | Contraseña | Rol |
|---------|-----------|-----|
| `ventas_admin` | `password123` | VENTAS |
| `logistica_op` | `password123` | LOGISTICA |
| `soporte_01`   | `password123` | SOPORTE |
