import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/constants.dart';
import '../../providers/voice_settings_provider.dart';
import '../../services/voice_ai_service.dart';

class VoiceSettingsScreen extends ConsumerWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(voiceSettingsProvider);
    final notifier = ref.read(voiceSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Masking Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Server status card
          FutureBuilder<Map<String, dynamic>>(
            future: voiceAIService.checkHealth(),
            builder: (context, snapshot) {
              final isHealthy = snapshot.data?['status'] == 'healthy' ||
                  snapshot.data?['status'] == 'ok';
              final isLoading = snapshot.connectionState == ConnectionState.waiting;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLoading
                      ? AppColors.info.withOpacity(0.1)
                      : isHealthy
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLoading
                        ? AppColors.info.withOpacity(0.3)
                        : isHealthy
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLoading
                          ? Icons.hourglass_empty
                          : isHealthy
                              ? Icons.check_circle
                              : Icons.error,
                      color: isLoading
                          ? AppColors.info
                          : isHealthy
                              ? AppColors.success
                              : AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice AI Server',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isLoading
                                  ? AppColors.info
                                  : isHealthy
                                      ? AppColors.success
                                      : AppColors.error,
                            ),
                          ),
                          Text(
                            isLoading
                                ? 'Checking connection...'
                                : isHealthy
                                    ? 'Connected and ready'
                                    : 'Server not available',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Pitch shift toggle
          _buildSettingCard(
            title: 'Pitch Shift',
            subtitle: 'Alter voice pitch to disguise identity',
            trailing: Switch(
              value: settings.pitchShift,
              onChanged: (_) => notifier.togglePitchShift(),
              activeColor: AppColors.primary,
            ),
          ),

          // Pitch steps slider
          if (settings.pitchShift) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pitch Steps',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${settings.pitchSteps > 0 ? '+' : ''}${settings.pitchSteps}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: settings.pitchSteps.toDouble(),
                    min: -12,
                    max: 12,
                    divisions: 24,
                    onChanged: (value) => notifier.setPitchSteps(value.round()),
                    activeColor: AppColors.primary,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lower',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Higher',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // AI Masking toggle
          _buildSettingCard(
            title: 'AI Voice Masking',
            subtitle: 'Use neural network to transform voice characteristics',
            trailing: Switch(
              value: settings.useAiMasking,
              onChanged: (_) => notifier.toggleAiMasking(),
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Voice encryption toggle
          _buildSettingCard(
            title: 'Encrypt Voice Messages',
            subtitle: 'Encrypt audio files before sending',
            trailing: Switch(
              value: settings.encryptVoice,
              onChanged: (_) => notifier.toggleEncryptVoice(),
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Info section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      'How it works',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Pitch Shift: Changes the fundamental frequency of your voice\n'
                  '• AI Masking: Uses machine learning to alter voice characteristics while preserving speech clarity\n'
                  '• Encryption: Protects audio files with end-to-end encryption',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
