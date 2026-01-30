import 'dart:convert';

/// Privacy service for sensitive data detection and encryption
class PrivacyService {
  /// Default sensitive keywords - Comprehensive list
  static const List<String> defaultKeywords = [
    // Financial
    'password', 'account number', 'bank', 'bank account', 'balance',
    'credit card', 'debit card', 'atm', 'ifsc', 'upi', 'wallet',
    'transaction', 'amount', 'salary', 'income', 'tax', 'gst',
    'pin', 'cvv', 'otp', 'routing number', 'swift code',
    
    // Identity
    'ssn', 'social security', 'aadhaar', 'pan card', 'passport',
    'driver license', 'voter id', 'ration card', 'birth certificate',
    
    // Contact
    'phone', 'mobile', 'email', 'address', 'zip code', 'postal code',
    
    // Medical
    'medical', 'health', 'diagnosis', 'prescription', 'medicine',
    'hospital', 'doctor', 'patient id', 'insurance',
    
    // Login credentials
    'username', 'login', 'api key', 'secret key', 'token',
    'authentication', 'credential',
    
    // Legal
    'case number', 'court', 'lawyer', 'legal', 'contract', 'agreement',
    'document', 'certificate', 'license number',
    
    // Business
    'company', 'business', 'client', 'customer', 'vendor', 'supplier',
    'employee id', 'employee number', 'payroll', 'bonus', 'incentive',
    
    // Personal
    'date of birth', 'dob', 'age', 'mother name', 'father name',
    'spouse name', 'family', 'children', 'relatives',
    
    // Location
    'home address', 'office address', 'work address', 'location',
    
    // Technology
    'wifi password', 'network password', 'router password',
    
    // Other sensitive
    'confidential', 'private', 'classified', 'restricted', 'internal',
    'personal', 'sensitive', 'important', 'urgent', 'critical',
  ];

  /// Secret key for encryption (in production, this should be stored securely)
  static const String _defaultSecretKey = 'your-secret-key-here-change-in-production';

  /// Detect if a message contains sensitive information
  static bool detectSensitiveData(String text, [List<String> customKeywords = const []]) {
    if (text.isEmpty) return false;

    final lowerText = text.toLowerCase();
    final allKeywords = [...defaultKeywords, ...customKeywords];

    // Check for keyword matches
    for (final keyword in allKeywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        return true;
      }
    }

    // Check for common patterns
    final patterns = [
      // Email pattern
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      // Phone numbers (various formats)
      RegExp(r'\b(?:\+?1[-.\s]?)?(?:\(?\d{3}\)?[-.\s]?)?\d{3}[-.\s]?\d{4}\b'),
      RegExp(r'\b\d{10,12}\b'),
      // Credit card numbers
      RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'),
      // SSN
      RegExp(r'\b\d{3}[-\s]?\d{2}[-\s]?\d{4}\b'),
      // Aadhaar
      RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'),
      // IP addresses
      RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
      // URLs with credentials
      RegExp(r'https?://[^:]+:[^@]+@'),
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }

    return false;
  }

  /// Mask sensitive data in a message
  static String maskSensitiveData(String text, [List<String> customKeywords = const []]) {
    if (text.isEmpty) return text;

    String maskedText = text;
    final allKeywords = [...defaultKeywords, ...customKeywords];

    // Mask keywords
    for (final keyword in allKeywords) {
      final regex = RegExp(
        '($keyword)\\s*[:=]?\\s*([^\\s,;]+)',
        caseSensitive: false,
      );
      maskedText = maskedText.replaceAllMapped(regex, (match) {
        final key = match.group(1) ?? '';
        return '$key: ****';
      });
    }

    // Mask email addresses
    maskedText = maskedText.replaceAllMapped(
      RegExp(r'\b([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Z|a-z]{2,})\b'),
      (match) {
        final localPart = match.group(1) ?? '';
        if (localPart.length <= 2) return '**@***.***';
        return '${localPart[0]}***@***.***';
      },
    );

    // Mask phone numbers
    maskedText = maskedText.replaceAllMapped(
      RegExp(r'\b(\d{3})[-.\s]?(\d{3})[-.\s]?(\d{4})\b'),
      (match) => '***-***-${match.group(3)}',
    );

    // Mask credit card numbers
    maskedText = maskedText.replaceAllMapped(
      RegExp(r'\b(\d{4})[-\s]?(\d{4})[-\s]?(\d{4})[-\s]?(\d{4})\b'),
      (match) => '****-****-****-${match.group(4)}',
    );

    return maskedText;
  }

  /// Encrypt a message using simple Base64 + XOR (for demo purposes)
  /// In production, use proper AES encryption
  static String encryptMessage(String text, [String? key]) {
    if (text.isEmpty) return text;

    final secretKey = key ?? _defaultSecretKey;
    final keyBytes = utf8.encode(secretKey);
    final textBytes = utf8.encode(text);

    // XOR encryption
    final encryptedBytes = List<int>.generate(
      textBytes.length,
      (i) => textBytes[i] ^ keyBytes[i % keyBytes.length],
    );

    // Base64 encode
    final encrypted = base64Encode(encryptedBytes);
    return 'ENC:$encrypted';
  }

  /// Decrypt a message
  static String decryptMessage(String encryptedText, [String? key]) {
    if (encryptedText.isEmpty || !encryptedText.startsWith('ENC:')) {
      return encryptedText;
    }

    try {
      final secretKey = key ?? _defaultSecretKey;
      final keyBytes = utf8.encode(secretKey);

      // Remove prefix and decode Base64
      final encodedPart = encryptedText.substring(4);
      final encryptedBytes = base64Decode(encodedPart);

      // XOR decryption
      final decryptedBytes = List<int>.generate(
        encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
      );

      return utf8.decode(decryptedBytes);
    } catch (e) {
      return '[Decryption failed]';
    }
  }

  /// Check if a message is encrypted
  static bool isEncrypted(String text) {
    return text.startsWith('ENC:');
  }

  /// Process a message for privacy (detect, mask, and optionally encrypt)
  static Map<String, dynamic> processMessageForPrivacy(
    String text, {
    List<String> customKeywords = const [],
    bool encryptSensitive = true,
  }) {
    final isSensitive = detectSensitiveData(text, customKeywords);
    
    if (!isSensitive) {
      return {
        'originalText': text,
        'processedText': text,
        'isSensitive': false,
        'isEncrypted': false,
        'maskedText': text,
      };
    }

    final maskedText = maskSensitiveData(text, customKeywords);
    final processedText = encryptSensitive ? encryptMessage(text) : maskedText;

    return {
      'originalText': text,
      'processedText': processedText,
      'isSensitive': true,
      'isEncrypted': encryptSensitive,
      'maskedText': maskedText,
    };
  }

  /// Simulate what an attacker/MITM would see
  static Map<String, String> simulateAttackerView(Map<String, dynamic> messageData) {
    final isEncrypted = messageData['isEncrypted'] as bool? ?? false;
    final processedText = messageData['processedText'] as String? ?? '';

    if (isEncrypted) {
      return {
        'visible': processedText,
        'canRead': 'false',
        'explanation': 'Message is encrypted - content is unreadable',
      };
    }

    return {
      'visible': processedText,
      'canRead': 'true',
      'explanation': 'Message is visible to attacker',
    };
  }

  /// Generate a random encryption key
  static String generateSecureKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return base64Encode(utf8.encode('key_$timestamp'));
  }
}
