import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/chat_message.dart';
import '../services/socket_service.dart';

const _roleColors = {
  'VENTAS':    Color(0xFF34D399),
  'LOGISTICA': Color(0xFF60A5FA),
  'SOPORTE':   Color(0xFFFBBF24),
  'USER':      Color(0xFFA78BFA),
};

Color _roleColor(String? role) => _roleColors[role] ?? const Color(0xFFA78BFA);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService     _socket    = SocketService();
  final TextEditingController _ctrl  = TextEditingController();
  final ScrollController  _scroll    = ScrollController();
  final List<ChatMessage> _messages  = [];
  bool   _connected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  void _connect() {
    final token = context.read<AuthProvider>().token!;
    _socket.connect(
      token: token,
      onConnect:    () { if (mounted) setState(() => _connected = true); },
      onDisconnect: () { if (mounted) setState(() => _connected = false); },
      onHistory: (msgs) {
        if (!mounted) return;
        setState(() {
          _messages.clear();
          _messages.addAll(msgs);
        });
        _scrollToBottom();
      },
      onNewMessage: (msg) {
        if (!mounted) return;
        setState(() => _messages.add(msg));
        _scrollToBottom();
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || !_connected) return;
    _socket.sendMessage(text);
    _ctrl.clear();
  }

  @override
  void dispose() {
    _socket.disconnect();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.eco, color: Color(0xFF2ECC71), size: 20),
            SizedBox(width: 8),
            Text('# general', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _connected ? const Color(0xff2ecc7120) : const Color(0xfffbbf2420),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _connected ? const Color(0xff2ecc7140) : const Color(0xfffbbf2440)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    color: _connected ? const Color(0xFF2ECC71) : const Color(0xFFFBBF24),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _connected ? 'Conectado' : 'Reconectando...',
                  style: TextStyle(
                    color: _connected ? const Color(0xFF2ECC71) : const Color(0xFFFBBF24),
                    fontSize: 11, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8B949E)),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF30363D)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_connected
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
                  )
                : _messages.isEmpty
                    ? const Center(
                        child: Text('💬  No hay mensajes. ¡Sé el primero!',
                            style: TextStyle(color: Color(0xFF8B949E))),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg    = _messages[i];
                          final isOwn  = msg.username == auth.username;
                          final showAv = i == 0 || _messages[i-1].username != msg.username;
                          return _MessageBubble(msg: msg, isOwn: isOwn, showAvatar: showAv);
                        },
                      ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              border: Border(top: BorderSide(color: Color(0xFF30363D))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    enabled: _connected,
                    style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _connected ? 'Mensaje en #general...' : 'Esperando conexión...',
                      hintStyle: const TextStyle(color: Color(0xFF8B949E)),
                      filled: true,
                      fillColor: const Color(0xFF0D1117),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF30363D)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF30363D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2ECC71)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: const Color(0xFF30363D).withOpacity(.5)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _send(),
                    maxLength: 2000,
                    maxLines: null,
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _connected && _ctrl.text.trim().isNotEmpty ? _send : null,
                  icon: const Icon(Icons.send_rounded),
                  color: const Color(0xFF2ECC71),
                  disabledColor: const Color(0xFF30363D),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xff2ecc7120),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isOwn;
  final bool showAvatar;

  const _MessageBubble({required this.msg, required this.isOwn, required this.showAvatar});

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(msg.role);
    final time  = '${msg.createdAt.hour.toString().padLeft(2,'0')}:${msg.createdAt.minute.toString().padLeft(2,'0')}';

    return Padding(
      padding: EdgeInsets.only(bottom: showAvatar ? 10 : 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isOwn) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 15,
                backgroundColor: color,
                child: Text(
                  msg.username.substring(0, 2).toUpperCase(),
                  style: const TextStyle(color: Color(0xFF0D1117), fontSize: 10, fontWeight: FontWeight.w700),
                ),
              )
            else
              const SizedBox(width: 30),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isOwn && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3, left: 2),
                    child: Text(msg.username,
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isOwn ? const Color(0xff2ecc7120) : const Color(0xFF21262D),
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(12),
                      topRight:    const Radius.circular(12),
                      bottomLeft:  Radius.circular(isOwn ? 12 : 2),
                      bottomRight: Radius.circular(isOwn ? 2 : 12),
                    ),
                    border: Border.all(
                      color: isOwn ? const Color(0xff2ecc7130) : const Color(0xFF30363D),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(msg.text,
                            style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      Text(time,
                          style: const TextStyle(color: Color(0xFF8B949E), fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isOwn) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
