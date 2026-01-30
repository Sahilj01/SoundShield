import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/privacy_service.dart';

/// Encryption settings state
class EncryptionSettings {
  final bool autoEncrypt;
  final bool detectSensitiveData;
  final List<String> customKeywords;
  final String? encryptionKey;

  const EncryptionSettings({
    this.autoEncrypt = true,
    this.detectSensitiveData = true,
    this.customKeywords = const [],
    this.encryptionKey,
  });

  EncryptionSettings copyWith({
    bool? autoEncrypt,
    bool? detectSensitiveData,
    List<String>? customKeywords,
    String? encryptionKey,
  }) {
    return EncryptionSettings(
      autoEncrypt: autoEncrypt ?? this.autoEncrypt,
      detectSensitiveData: detectSensitiveData ?? this.detectSensitiveData,
      customKeywords: customKeywords ?? this.customKeywords,
      encryptionKey: encryptionKey ?? this.encryptionKey,
    );
  }
}

/// Provider for encryption settings
final encryptionSettingsProvider = StateNotifierProvider<EncryptionSettingsNotifier, EncryptionSettings>((ref) {
  return EncryptionSettingsNotifier();
});

/// State notifier for encryption settings
class EncryptionSettingsNotifier extends StateNotifier<EncryptionSettings> {
  EncryptionSettingsNotifier() : super(const EncryptionSettings());

  /// Toggle auto encryption
  void toggleAutoEncrypt() {
    state = state.copyWith(autoEncrypt: !state.autoEncrypt);
  }

  /// Toggle sensitive data detection
  void toggleDetectSensitiveData() {
    state = state.copyWith(detectSensitiveData: !state.detectSensitiveData);
  }

  /// Add custom keyword
  void addCustomKeyword(String keyword) {
    if (keyword.isNotEmpty && !state.customKeywords.contains(keyword.toLowerCase())) {
      state = state.copyWith(
        customKeywords: [...state.customKeywords, keyword.toLowerCase()],
      );
    }
  }

  /// Remove custom keyword
  void removeCustomKeyword(String keyword) {
    state = state.copyWith(
      customKeywords: state.customKeywords.where((k) => k != keyword.toLowerCase()).toList(),
    );
  }

  /// Set encryption key
  void setEncryptionKey(String key) {
    state = state.copyWith(encryptionKey: key);
  }
}

/// Provider for encryption service with settings
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  final settings = ref.watch(encryptionSettingsProvider);
  return EncryptionService(settings: settings);
});

/// Encryption service that uses current settings
class EncryptionService {
  final EncryptionSettings settings;

  EncryptionService({required this.settings});

  /// Detect if message contains sensitive data
  bool isSensitive(String text) {
    if (!settings.detectSensitiveData) return false;
    return PrivacyService.detectSensitiveData(text, settings.customKeywords);
  }

  /// Encrypt a message
  String encrypt(String text) {
    return PrivacyService.encryptMessage(text, settings.encryptionKey);
  }

  /// Decrypt a message
  String decrypt(String encryptedText) {
    return PrivacyService.decryptMessage(encryptedText, settings.encryptionKey);
  }

  /// Mask sensitive data in a message
  String mask(String text) {
    return PrivacyService.maskSensitiveData(text, settings.customKeywords);
  }

  /// Process message for privacy (detect about encrypt)
  Map<String, dynamic> processMessage(String text) {
    final sensitive = isSensitive(text);
    String processedText = text;
    bool encrypted = false;

    if (sensitive && settings.autoEncrypt) {
      processedText = encrypt(text);
      encrypted = true;
    }

    return {
      'originalText': text,
      'processedText': processedText,
      'isSensitive': sensitive,
      'isEncrypted': encrypted,
    };
  }
}
