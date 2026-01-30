import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/constants.dart';

class ChatMenu extends StatelessWidget {
  final String chatName;
  final String chatId;

  const ChatMenu({
    super.key,
    required this.chatName,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20),
              SizedBox(width: 12),
              Text('Chat Info'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'mute',
          child: Row(
            children: [
              Icon(Icons.notifications_off_outlined, size: 20),
              SizedBox(width: 12),
              Text('Mute'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              const SizedBox(width: 12),
              Text('Delete Chat', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'info':
        context.push('/chat-info/$chatId');
        break;
      case 'mute':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat muted')),
        );
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: Text('Are you sure you want to delete "$chatName"?'),
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
        if (confirmed == true && context.mounted) {
          context.go('/chats');
        }
        break;
    }
  }
}
