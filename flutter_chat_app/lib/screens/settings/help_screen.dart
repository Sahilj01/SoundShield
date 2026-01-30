import 'package:flutter/material.dart';
import '../../config/constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FAQ Section
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),

          _buildFAQ(
            question: 'How do I start a new chat?',
            answer: 'Tap the floating action button on the Chats screen or use the person icon in the top right corner to see available users.',
          ),
          _buildFAQ(
            question: 'How does message encryption work?',
            answer: 'When you send a message containing sensitive data (like passwords, credit card numbers, etc.), the app automatically detects and encrypts it. Only the recipient can decrypt and read the message.',
          ),
          _buildFAQ(
            question: 'What is voice masking?',
            answer: 'Voice masking uses AI to alter your voice characteristics while preserving speech clarity. This helps protect your identity in voice messages.',
          ),
          _buildFAQ(
            question: 'How do I delete a chat?',
            answer: 'Long-press on a chat in the Chats list to select it, then tap the delete icon. You can also delete from the chat menu inside a conversation.',
          ),
          _buildFAQ(
            question: 'Can I create group chats?',
            answer: 'Yes! Tap the group icon in the top right corner of the Chats screen to create a new group and add members.',
          ),
          _buildFAQ(
            question: 'How do I send voice messages?',
            answer: 'Long-press the microphone/send button to record a voice message. Release to stop recording. You can choose to send it as-is or process it with AI voice masking.',
          ),

          const SizedBox(height: 24),

          // Contact section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.support_agent, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Need more help?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Contact our support team:',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'support@chatapp.com',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
