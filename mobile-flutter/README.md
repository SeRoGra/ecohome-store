# EcoHome Flutter — App Móvil Multiplataforma

Aplicación **Flutter** (Android / iOS / Web) que consume el mismo backend centralizado Express.js de la Unidad 2, sin endpoints paralelos.

## Tecnologías

| Paquete | Versión | Uso |
|---------|---------|-----|
| `provider` | ^6.1.2 | Gestión de estado (AuthProvider, ProductsProvider) |
| `dio` | ^5.4.3 | Cliente HTTP para REST API |
| `socket_io_client` | ^2.0.3+1 | Conexión Socket.IO para chat en tiempo real |
| `shared_preferences` | ^2.2.3 | Persistencia del JWT en disco |

## Estructura del proyecto

```
lib/
├── main.dart                     ← MaterialApp + MultiProvider + routing raíz
├── config/
│   └── app_config.dart           ← API_BASE_URL (configurable con --dart-define)
├── models/
│   ├── product.dart              ← Product.fromJson()
│   ├── user_stats.dart           ← UserStats.fromJson() — contador de productos
│   └── chat_message.dart         ← ChatMessage.fromJson()
├── services/
│   ├── auth_service.dart         ← login(), logout(), getSavedToken()
│   ├── products_service.dart     ← getProducts(), createProduct(), getUserStats()
│   └── socket_service.dart       ← connect(token), sendMessage(), disconnect()
├── providers/
│   ├── auth_provider.dart        ← AuthStatus, token, username, role
│   └── products_provider.dart    ← lista de productos + stats del usuario
└── screens/
    ├── login_screen.dart         ← Formulario de login con JWT
    ├── home_screen.dart          ← BottomNavigationBar: Catálogo | Chat
    ├── products_screen.dart      ← Lista de productos + "Username (N)" + crear
    └── chat_screen.dart          ← Chat Socket.IO en tiempo real
```

## Configuración inicial (primera vez)

> Requiere **Flutter SDK 3.x** instalado y en el PATH.
> Descarga: https://docs.flutter.dev/get-started/install

```bash
cd ecohome-flutter

# Ejecuta el script de configuración (genera android/, ios/, web/, etc.)
chmod +x setup.sh
./setup.sh
```

El script:
1. Verifica que Flutter esté instalado
2. Crea el proyecto base con `flutter create`
3. Copia los directorios de plataforma generados
4. Ejecuta `flutter pub get`

## Ejecución

### Emulador Android
```bash
# URL backend por defecto: http://10.0.2.2:8080
# (10.0.2.2 es el localhost del host desde el emulador Android)
flutter run -d emulator
```

### Flutter Web (Chrome)
```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8080
```

### Dispositivo físico (misma red WiFi)
```bash
# Obtener IP local del host (ej. 192.168.1.50)
flutter run -d <device-id> \
  --dart-define=API_BASE_URL=http://192.168.1.50:8080
```

### Ver dispositivos disponibles
```bash
flutter devices
```

## Flujo completo de la app

```
Inicio
  └── LoginScreen
        ├── POST /api/auth/login  →  guarda JWT en SharedPreferences
        └── HomeScreen
              ├── [Tab 0] ProductsScreen
              │     ├── GET /api/products       →  lista con creator_username
              │     ├── GET /api/users/me/stats →  muestra "Username (N)"
              │     └── FAB → Crear producto
              │           └── POST /api/products →  created_by = JWT automático
              │                 └── contador se incrementa inmediatamente
              └── [Tab 1] ChatScreen
                    ├── Socket.IO connect(auth: { token })
                    ├── on('messages')     →  historial al conectar
                    ├── on('new-message')  →  mensaje en tiempo real
                    └── emit('new-message', { text })
```

## Evidencia del flujo (Actividad 1)

1. **Login**: ingresar `ventas_admin` / `password123` → obtiene JWT
2. **Catálogo**: ver lista de productos con `Creado por: ventas_admin` y contador `ventas_admin (N)`
3. **Crear producto**: pulsar FAB → llenar formulario → contador pasa de `(N)` a `(N+1)` instantáneamente
4. **Chat**: cambiar a pestaña Chat → conecta Socket.IO → enviar/recibir mensajes en tiempo real

## Cuentas de prueba

| Usuario | Contraseña | Rol |
|---------|-----------|-----|
| `ventas_admin` | `password123` | VENTAS |
| `logistica_op` | `password123` | LOGISTICA |
| `soporte_01`   | `password123` | SOPORTE |

## URL del backend

El backend es el de **Unidad 2** (`ecohome-chat-backend`), corriendo en `http://localhost:8080` (o `http://10.0.2.2:8080` desde emulador Android).

Para cambiar la URL sin recompilar, usa `--dart-define=API_BASE_URL=<url>`.

## Build de producción

```bash
# APK Android
flutter build apk --dart-define=API_BASE_URL=http://<IP>:8080

# Web
flutter build web --dart-define=API_BASE_URL=http://<IP>:8080
```
