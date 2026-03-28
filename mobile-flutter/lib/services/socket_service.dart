import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';
import '../models/chat_message.dart';

typedef MessageCallback = void Function(ChatMessage message);
typedef MessagesCallback = void Function(List<ChatMessage> messages);

class SocketService {
  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// Conecta al servidor Socket.IO con el JWT como autenticación.
  void connect({
    required String token,
    required MessagesCallback onHistory,
    required MessageCallback onNewMessage,
    required void Function() onConnect,
    required void Function() onDisconnect,
  }) {
    _socket = IO.io(
      AppConfig.apiBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) => onConnect());
    _socket!.onDisconnect((_) => onDisconnect());

    // Historial inicial al conectar
    _socket!.on('messages', (data) {
      if (data is List) {
        final msgs = data
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        onHistory(msgs);
      }
    });

    // Nuevo mensaje en tiempo real
    _socket!.on('new-message', (data) {
      if (data is Map<String, dynamic>) {
        onNewMessage(ChatMessage.fromJson(data));
      }
    });

    _socket!.connect();
  }

  /// Envía un mensaje al canal general.
  void sendMessage(String text) {
    _socket?.emit('new-message', {'text': text});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
