import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.uid;
    final currentUserEmail = authState.value?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final users = snapshot.data ?? [];
          
          // Filter out current user
          final otherUsers = users.where((u) => u['id'] != currentUserId).toList();

          if (otherUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No other users yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: otherUsers.length + 1, // +1 for "Note to Self"
            itemBuilder: (context, index) {
              // Note to Self option
              if (index == 0) {
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      color: AppColors.success,
                    ),
                  ),
                  title: const Text(
                    'Note to Self',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Save messages for yourself'),
                  onTap: () => _startChat(
                    context,
                    currentUserId!,
                    currentUserId,
                    'Note to Self',
                  ),
                );
              }

              final user = otherUsers[index - 1];
              final email = user['email'] as String? ?? '';
              final displayName = user['displayName'] as String? ?? email.split('@').first;

              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(email),
                onTap: () => _startChat(
                  context,
                  currentUserId!,
                  user['id'] as String,
                  displayName,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _startChat(
    BuildContext context,
    String currentUserId,
    String otherUserId,
    String chatName,
  ) async {
    // Create or get existing chat
    final chatId = await chatService.createChat(
      name: chatName,
      users: [currentUserId, otherUserId],
    );

    if (context.mounted) {
      context.go('/chat/$chatId?name=${Uri.encodeComponent(chatName)}');
    }
  }
}
