import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../widgets/contact_row.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  final Set<String> _selectedChats = {};
  bool _isSelectionMode = false;

  void _toggleSelection(String chatId) {
    setState(() {
      if (_selectedChats.contains(chatId)) {
        _selectedChats.remove(chatId);
        if (_selectedChats.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedChats.add(chatId);
      }
    });
  }

  void _startSelection(String chatId) {
    setState(() {
      _isSelectionMode = true;
      _selectedChats.add(chatId);
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedChats.clear();
    });
  }

  Future<void> _deleteSelectedChats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chats'),
        content: Text(
          'Are you sure you want to delete ${_selectedChats.length} chat(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final chatId in _selectedChats) {
        await chatService.deleteChat(chatId);
      }
      _cancelSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.uid;

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedChats.length} selected')
            : const Text('Chats'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelSelection,
              )
            : null,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: _deleteSelectedChats,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.group_add_outlined),
              onPressed: () => context.push('/group'),
              tooltip: 'New Group',
            ),
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              onPressed: () => context.push('/users'),
              tooltip: 'New Chat',
            ),
          ],
        ],
      ),
      body: currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Chat>>(
              stream: chatService.getChats(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading chats',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                final chats = snapshot.data ?? [];

                if (chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No chats yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a new conversation',
                          style: TextStyle(
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/users'),
                          icon: const Icon(Icons.add),
                          label: const Text('New Chat'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final isSelected = _selectedChats.contains(chat.id);

                    return ContactRow(
                      name: chat.name,
                      subtitle: chat.lastMessage ?? 'No messages yet',
                      time: chat.lastMessageTime,
                      isGroup: chat.isGroup,
                      isSelected: isSelected,
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelection(chat.id);
                        } else {
                          context.push(
                            '/chat/${chat.id}?name=${Uri.encodeComponent(chat.name)}',
                          );
                        }
                      },
                      onLongPress: () {
                        if (!_isSelectionMode) {
                          _startSelection(chat.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/users'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.chat, color: Colors.white),
            ),
    );
  }
}
