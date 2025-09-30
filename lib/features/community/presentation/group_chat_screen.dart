import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Provider para manejar el estado del chat
final groupChatProvider = StateNotifierProvider<GroupChatController, GroupChatState>(
  (ref) => GroupChatController(),
);

class GroupChatController extends StateNotifier<GroupChatState> {
  GroupChatController() : super(GroupChatState()) {
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    state = state.copyWith(
      messages: [
        ChatMessage(
          id: '1',
          userId: 'user1',
          userName: 'Carlos',
          userAvatar: 'https://i.pravatar.cc/150?img=11',
          message: '¡Hola a todos! ¿Qué tal la nueva canción de The Killers? 🔥',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          isCurrentUser: false,
        ),
        ChatMessage(
          id: '2',
          userId: 'user2',
          userName: 'María',
          userAvatar: 'https://i.pravatar.cc/150?img=5',
          message: '¡Brutal! No puedo dejar de escucharla. Ya la pedí por la app.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 29)),
          isCurrentUser: false,
          isHighlighted: true,
        ),
        ChatMessage(
          id: '3',
          userId: 'user3',
          userName: 'Alex',
          userAvatar: 'https://i.pravatar.cc/150?img=8',
          message: 'A mí también me encantó. ¿Creen que la toquen en el próximo festival?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 28)),
          isCurrentUser: false,
        ),
        ChatMessage(
          id: '4',
          userId: 'user1',
          userName: 'Carlos',
          userAvatar: 'https://i.pravatar.cc/150?img=11',
          message: 'Ojalá que sí! Sería épico. Por cierto, están regalando entradas en la sección de concursos. 😊',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 26)),
          isCurrentUser: false,
          reactions: ['❤️', '👍', '🎉'],
          reactionCount: 10,
        ),
      ],
    );
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'currentUser',
      userName: 'Tú',
      userAvatar: 'https://i.pravatar.cc/150?img=20',
      message: message,
      timestamp: DateTime.now(),
      isCurrentUser: true,
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
    );
  }

  void addReaction(String messageId, String reaction) {
    final messages = state.messages.map((msg) {
      if (msg.id == messageId) {
        final List<String> reactions = [...(msg.reactions ?? <String>[]), reaction];
        return msg.copyWith(
          reactions: reactions,
          reactionCount: (msg.reactionCount ?? 0) + 1,
        );
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: messages);
  }
}

class GroupChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  GroupChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  GroupChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return GroupChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatMessage {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String message;
  final DateTime timestamp;
  final bool isCurrentUser;
  final bool isHighlighted;
  final List<String>? reactions;
  final int? reactionCount;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.message,
    required this.timestamp,
    required this.isCurrentUser,
    this.isHighlighted = false,
    this.reactions,
    this.reactionCount,
  });

  ChatMessage copyWith({
    List<String>? reactions,
    int? reactionCount,
  }) {
    return ChatMessage(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      message: message,
      timestamp: timestamp,
      isCurrentUser: isCurrentUser,
      isHighlighted: isHighlighted,
      reactions: reactions ?? this.reactions,
      reactionCount: reactionCount ?? this.reactionCount,
    );
  }
}

class GroupChatScreen extends ConsumerStatefulWidget {
  const GroupChatScreen({super.key, this.radioName});

  final String? radioName;

  static const routePath = '/group-chat';
  static const routeName = 'groupChat';

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.trim().isNotEmpty) {
      ref.read(groupChatProvider.notifier).sendMessage(message);
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    final displayHour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    return '${displayHour.toString()}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(groupChatProvider);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.colorScheme.surfaceContainerLow
          : const Color(0xFFF8F7FF),
      body: Column(
        children: [
          // Header con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.secondary.withOpacity(0.6),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    // Avatares de grupo
                    SizedBox(
                      width: 80,
                      height: 36,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 48,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                                child: Text(
                                  '+5',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.radioName != null
                                ? 'Chat ${widget.radioName}'
                                : 'Chat Radio',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '8 participantes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: theme.colorScheme.surface,
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surfaceContainerHigh
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: TextField(
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar en el chat',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          // Mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return _buildMessageBubble(context, theme, message);
              },
            ),
          ),
          // Input de mensaje
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botón de emoji
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Campo de texto
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.surfaceContainerHigh
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      style: const TextStyle(fontSize: 14),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de enviar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ThemeData theme, ChatMessage message) {
    final isCurrentUser = message.isCurrentUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: isCurrentUser ? 60 : 0,
        right: isCurrentUser ? 0 : 60,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(message.userAvatar),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.userName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: message.isHighlighted
                        ? LinearGradient(
                            colors: [
                              Color(0xFFE91E63),
                              Color(0xFF9C27B0),
                            ],
                          )
                        : null,
                    color: message.isHighlighted
                        ? null
                        : isCurrentUser
                            ? theme.colorScheme.primary.withOpacity(0.15)
                            : theme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isCurrentUser ? 18 : 4),
                      topRight: Radius.circular(isCurrentUser ? 4 : 18),
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: message.isHighlighted
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.reactions != null && message.reactions!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...message.reactions!.take(3).map((r) => Text(r)),
                                  if (message.reactionCount != null && message.reactionCount! > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        message.reactionCount.toString(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _formatTime(message.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: message.isHighlighted
                                  ? Colors.white.withOpacity(0.8)
                                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
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