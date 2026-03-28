class ChatMessage {
  final dynamic id;
  final String username;
  final String text;
  final String? role;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.username,
    required this.text,
    this.role,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id:        json['id'],
    username:  json['username'] as String,
    text:      json['text'] as String,
    role:      json['role'] as String?,
    createdAt: DateTime.parse(
      (json['createdAt'] ?? json['created_at']) as String,
    ),
  );
}
