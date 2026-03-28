import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  /// Inicia sesión. Guarda token, username y role en SharedPreferences.
  /// Devuelve el token si el login es exitoso.
  static Future<String> login(String username, String password) async {
    final res = await _dio.post('/api/auth/login', data: {
      'username': username,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token',    token);
    await prefs.setString('username', data['username'] as String);
    await prefs.setString('role',     data['role'] as String);
    return token;
  }

  /// Cierra sesión limpiando el almacenamiento local.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Devuelve el token almacenado o null si no hay sesión.
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
}
