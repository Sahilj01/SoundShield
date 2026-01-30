import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cell.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundSecondary,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    user?.email?.isNotEmpty == true
                        ? user!.email![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? user?.email?.split('@').first ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/profile'),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Settings sections
          _buildSection(
            title: 'Account',
            children: [
              Cell(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Edit your profile information',
                onTap: () => context.push('/profile'),
              ),
              Cell(
                icon: Icons.lock_outline,
                title: 'Privacy & Account',
                subtitle: 'Manage privacy settings',
                onTap: () => context.push('/account'),
              ),
              Cell(
                icon: Icons.mic_outlined,
                title: 'Voice Masking',
                subtitle: 'Configure voice AI settings',
                onTap: () => context.push('/voice-settings'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSection(
            title: 'Support',
            children: [
              Cell(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'FAQs and contact support',
                onTap: () => context.push('/help'),
              ),
              Cell(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () => context.push('/about'),
              ),
              Cell(
                icon: Icons.science_outlined,
                title: 'Privacy Demo',
                subtitle: 'Test privacy features',
                onTap: () => context.push('/privacy-demo'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSection(
            title: 'Actions',
            children: [
              Cell(
                icon: Icons.logout,
                title: 'Sign Out',
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () => _handleSignOut(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          color: AppColors.backgroundSecondary,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authServiceProvider).signOut();
    }
  }
}
