import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/product.dart';
import '../models/user_stats.dart';

class ProductsService {
  final Dio _dio;

  ProductsService(String token)
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          headers: {'Authorization': 'Bearer $token'},
        ));

  Future<List<Product>> getProducts() async {
    final res = await _dio.get('/api/products');
    return (res.data as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Product> createProduct({
    required String name,
    String? description,
    required double price,
    int stock = 0,
  }) async {
    final res = await _dio.post('/api/products', data: {
      'name':        name,
      if (description != null) 'description': description,
      'price':       price,
      'stock':       stock,
    });
    return Product.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserStats> getUserStats() async {
    final res = await _dio.get('/api/users/me/stats');
    return UserStats.fromJson(res.data as Map<String, dynamic>);
  }
}
