import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/encryption_provider.dart';
import '../../widgets/cell.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter your password to confirm',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true && _passwordController.text.isNotEmpty) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.reauthenticate(_passwordController.text);
        await authService.deleteAccount();

        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final encryptionSettings = ref.watch(encryptionSettingsProvider);
    final encryptionNotifier = ref.read(encryptionSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Account'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Privacy section
          _buildSectionHeader('Privacy'),
          Container(
            color: AppColors.backgroundSecondary,
            child: Column(
              children: [
                Cell(
                  icon: Icons.security,
                  title: 'Auto-encrypt sensitive messages',
                  subtitle: 'Automatically encrypt messages with sensitive data',
                  trailing: Switch(
                    value: encryptionSettings.autoEncrypt,
                    onChanged: (_) => encryptionNotifier.toggleAutoEncrypt(),
                    activeColor: AppColors.primary,
                  ),
                  showDivider: true,
                ),
                Cell(
                  icon: Icons.visibility_off,
                  title: 'Detect sensitive data',
                  subtitle: 'Warn before sending sensitive information',
                  trailing: Switch(
                    value: encryptionSettings.detectSensitiveData,
                    onChanged: (_) => encryptionNotifier.toggleDetectSensitiveData(),
                    activeColor: AppColors.primary,
                  ),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Custom keywords section
          _buildSectionHeader('Custom Keywords'),
          Container(
            color: AppColors.backgroundSecondary,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add custom words that should be treated as sensitive:',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...encryptionSettings.customKeywords.map((keyword) {
                      return Chip(
                        label: Text(keyword),
                        onDeleted: () => encryptionNotifier.removeCustomKeyword(keyword),
                        deleteIconColor: AppColors.error,
                      );
                    }),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                      onPressed: () => _addKeyword(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Account section
          _buildSectionHeader('Account'),
          Container(
            color: AppColors.backgroundSecondary,
            child: Column(
              children: [
                Cell(
                  icon: Icons.password,
                  title: 'Change Password',
                  onTap: () => _changePassword(),
                ),
                Cell(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account and data',
                  iconColor: AppColors.error,
                  titleColor: AppColors.error,
                  onTap: _deleteAccount,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _addKeyword() async {
    final controller = TextEditingController();
    final keyword = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Keyword'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter keyword',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (keyword != null && keyword.isNotEmpty) {
      ref.read(encryptionSettingsProvider.notifier).addCustomKeyword(keyword);
    }
    controller.dispose();
  }

  Future<void> _changePassword() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent')),
    );
    final authService = ref.read(authServiceProvider);
    final email = authService.currentUserEmail;
    if (email != null) {
      await authService.sendPasswordResetEmail(email);
    }
  }
}
