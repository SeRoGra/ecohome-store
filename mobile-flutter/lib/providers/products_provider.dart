import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/user_stats.dart';
import '../services/products_service.dart';

class ProductsProvider extends ChangeNotifier {
  List<Product> _products    = [];
  UserStats?    _stats;
  bool          _loading     = false;
  String?       _error;

  List<Product> get products => _products;
  UserStats?    get stats    => _stats;
  bool          get loading  => _loading;
  String?       get error    => _error;

  Future<void> load(String token, String username, String role) async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      final svc = ProductsService(token);
      final results = await Future.wait([svc.getProducts(), svc.getUserStats()]);
      _products = results[0] as List<Product>;
      _stats    = results[1] as UserStats;
    } catch (e) {
      _error = 'Error al cargar productos';
      _stats ??= UserStats.empty(username, role);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct({
    required String token,
    required String name,
    String? description,
    required double price,
    int stock = 0,
  }) async {
    final svc = ProductsService(token);
    final newProduct = await svc.createProduct(
      name: name, description: description, price: price, stock: stock,
    );
    _products = [newProduct, ..._products];
    // Actualizar el contador del usuario
    final currentCount = _stats?.productCount ?? 0;
    _stats = UserStats(
      username:     _stats?.username ?? '',
      role:         _stats?.role ?? '',
      productCount: currentCount + 1,
    );
    notifyListeners();
  }
}
