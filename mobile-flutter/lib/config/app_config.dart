/// Configuración global de la app.
/// Cambia [apiBaseUrl] según el entorno donde corra el backend:
///   - Emulador Android : http://10.0.2.2:8080
///   - Dispositivo físico: http://<IP-LAN>:8080
///   - Flutter web       : http://localhost:8080
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
}
