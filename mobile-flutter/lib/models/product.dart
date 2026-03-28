class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final int createdBy;
  final String creatorUsername;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.createdBy,
    required this.creatorUsername,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id:              int.parse(json['id'].toString()),
    name:            json['name'] as String,
    description:     json['description'] as String?,
    price:           double.parse(json['price'].toString()),
    stock:           json['stock'] as int,
    createdBy:       int.parse(json['created_by'].toString()),
    creatorUsername: json['creator_username'] as String,
    createdAt:       DateTime.parse(json['created_at'] as String),
  );
}
