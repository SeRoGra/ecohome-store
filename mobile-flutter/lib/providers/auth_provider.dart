import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status  = AuthStatus.unknown;
  String?    _token;
  String?    _username;
  String?    _role;

  AuthStatus get status   => _status;
  String?    get token    => _token;
  String?    get username => _username;
  String?    get role     => _role;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Carga la sesión guardada al iniciar la app.
  Future<void> init() async {
    final token    = await AuthService.getSavedToken();
    final username = await AuthService.getSavedUsername();
    final role     = await AuthService.getSavedRole();
    if (token != null && username != null) {
      _token    = token;
      _username = username;
      _role     = role;
      _status   = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final token = await AuthService.login(username, password);
    _token    = token;
    _username = await AuthService.getSavedUsername();
    _role     = await AuthService.getSavedRole();
    _status   = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _token    = null;
    _username = null;
    _role     = null;
    _status   = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
