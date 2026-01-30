import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key});

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  final _groupNameController = TextEditingController();
  final Set<String> _selectedUsers = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authStateProvider);
      final currentUserId = authState.value?.uid;

      if (currentUserId == null) return;

      final chatId = await chatService.createChat(
        name: _groupNameController.text.trim(),
        users: [currentUserId, ..._selectedUsers],
        isGroup: true,
        createdBy: currentUserId,
      );

      if (mounted) {
        context.go('/chat/$chatId?name=${Uri.encodeComponent(_groupNameController.text.trim())}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createGroup,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group name input
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundSecondary,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.group,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      hintText: 'Group name',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Selected users chips
          if (_selectedUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.backgroundSecondary,
              child: Wrap(
                spacing: 8,
                children: _selectedUsers.map((userId) {
                  return Chip(
                    label: Text(userId.substring(0, 8)),
                    onDeleted: () {
                      setState(() => _selectedUsers.remove(userId));
                    },
                  );
                }).toList(),
              ),
            ),

          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: AppColors.background,
            child: Text(
              'Add Participants',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Users list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: chatService.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data ?? [];
                final otherUsers = users.where((u) => u['id'] != currentUserId).toList();

                return ListView.builder(
                  itemCount: otherUsers.length,
                  itemBuilder: (context, index) {
                    final user = otherUsers[index];
                    final userId = user['id'] as String;
                    final email = user['email'] as String? ?? '';
                    final displayName = user['displayName'] as String? ?? email.split('@').first;
                    final isSelected = _selectedUsers.contains(userId);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUsers.add(userId);
                          } else {
                            _selectedUsers.remove(userId);
                          }
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(displayName),
                      subtitle: Text(email),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
