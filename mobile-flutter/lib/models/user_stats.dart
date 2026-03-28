class UserStats {
  final String username;
  final String role;
  final int productCount;

  const UserStats({
    required this.username,
    required this.role,
    required this.productCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    username:     json['username'] as String,
    role:         json['role'] as String,
    productCount: json['product_count'] as int,
  );

  factory UserStats.empty(String username, String role) =>
      UserStats(username: username, role: role, productCount: 0);
}
