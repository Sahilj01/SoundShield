import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/constants.dart';
import '../../providers/encryption_provider.dart';
import '../../services/privacy_service.dart';

class PrivacyDemoScreen extends ConsumerStatefulWidget {
  const PrivacyDemoScreen({super.key});

  @override
  ConsumerState<PrivacyDemoScreen> createState() => _PrivacyDemoScreenState();
}

class _PrivacyDemoScreenState extends ConsumerState<PrivacyDemoScreen> {
  final _inputController = TextEditingController();
  String _detectionResult = '';
  String _maskedResult = '';
  String _encryptedResult = '';
  String _decryptedResult = '';
  bool _containsSensitive = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _analyzeText() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    final encryptionSettings = ref.read(encryptionSettingsProvider);

    setState(() {
      // Detection
      _containsSensitive = PrivacyService.detectSensitiveData(
        text,
        encryptionSettings.customKeywords,
      );
      _detectionResult = _containsSensitive
          ? '⚠️ Sensitive data detected!'
          : '✅ No sensitive data detected';

      // Masking
      _maskedResult = PrivacyService.maskSensitiveData(
        text,
        encryptionSettings.customKeywords,
      );

      // Encryption
      _encryptedResult = PrivacyService.encryptMessage(text);

      // Decryption
      _decryptedResult = PrivacyService.decryptMessage(_encryptedResult);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Test the privacy features by entering text containing sensitive information like passwords, credit card numbers, or SSN.',
                    style: TextStyle(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input section
          const Text(
            'Enter text to analyze:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inputController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Try: "My password is secret123"',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Analyze button
          ElevatedButton.icon(
            onPressed: _analyzeText,
            icon: const Icon(Icons.search),
            label: const Text('Analyze Text'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),

          // Results
          if (_detectionResult.isNotEmpty) ...[
            _buildResultCard(
              title: 'Detection Result',
              content: _detectionResult,
              icon: _containsSensitive ? Icons.warning : Icons.check_circle,
              color: _containsSensitive ? AppColors.warning : AppColors.success,
            ),
            const SizedBox(height: 16),
          ],

          if (_maskedResult.isNotEmpty) ...[
            _buildResultCard(
              title: 'Masked Output',
              content: _maskedResult,
              icon: Icons.visibility_off,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
          ],

          if (_encryptedResult.isNotEmpty) ...[
            _buildResultCard(
              title: 'Encrypted',
              content: _encryptedResult,
              icon: Icons.lock,
              color: AppColors.accent,
              isCode: true,
            ),
            const SizedBox(height: 16),
          ],

          if (_decryptedResult.isNotEmpty) ...[
            _buildResultCard(
              title: 'Decrypted',
              content: _decryptedResult,
              icon: Icons.lock_open,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
          ],

          // Sample data section
          const SizedBox(height: 16),
          const Text(
            'Sample Data to Try:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSampleChip('My password is abc123'),
              _buildSampleChip('Credit card: 4111-1111-1111-1111'),
              _buildSampleChip('SSN: 123-45-6789'),
              _buildSampleChip('API key: sk_test_abc123'),
              _buildSampleChip('Just a normal message'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    bool isCode = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              content,
              style: TextStyle(
                fontFamily: isCode ? 'monospace' : null,
                fontSize: isCode ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleChip(String text) {
    return ActionChip(
      label: Text(
        text.length > 25 ? '${text.substring(0, 25)}...' : text,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        _inputController.text = text;
        _analyzeText();
      },
    );
  }
}
