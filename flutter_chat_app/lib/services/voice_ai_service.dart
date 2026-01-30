import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Voice AI Service for processing and masking voice messages
class VoiceAIService {
  /// API URL - change for your server
  static const String _webApiUrl = 'http://localhost:8000';
  static const String _mobileApiUrl = 'http://192.168.1.2:8000';
  
  final Dio _dio;
  
  VoiceAIService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  String get apiUrl => kIsWeb ? _webApiUrl : _mobileApiUrl;

  /// Process voice with AI masking
  /// 
  /// [audioPath] - Path to the audio file
  /// [pitchShift] - Whether to apply pitch shifting
  /// [pitchSteps] - Number of semitones to shift pitch
  /// [useAiMasking] - Whether to use AI voice masking
  /// [encrypt] - Whether to encrypt the processed audio
  Future<String> processVoice(
    String audioPath, {
    bool pitchShift = true,
    int pitchSteps = 4,
    bool useAiMasking = true,
    bool encrypt = true,
  }) async {
    try {
      debugPrint('🎤 Processing voice with options: pitchShift=$pitchShift, steps=$pitchSteps, ai=$useAiMasking, encrypt=$encrypt');

      final formData = FormData.fromMap({
        'audio_file': await MultipartFile.fromFile(
          audioPath,
          filename: 'voice.m4a',
        ),
        'pitch_shift': pitchShift.toString(),
        'pitch_steps': pitchSteps.toString(),
        'use_ai_masking': useAiMasking.toString(),
        'encrypt': encrypt.toString(),
      });

      debugPrint('📤 Sending to server: $apiUrl/api/process-voice');

      final response = await _dio.post(
        '$apiUrl/api/process-voice',
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).round();
          debugPrint('📤 Upload progress: $progress%');
        },
      );

      debugPrint('✅ Voice processed successfully');

      // Save processed file
      final dir = await getApplicationDocumentsDirectory();
      final ext = encrypt ? 'enc' : 'wav';
      final outputPath = '${dir.path}/masked_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await File(outputPath).writeAsBytes(response.data);
      debugPrint('💾 Saved processed voice to: $outputPath');

      return outputPath;
    } on DioException catch (e) {
      debugPrint('❌ Voice processing error: ${e.message}');
      
      // Try to extract error details
      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map) {
            final errorMessage = errorData['error'] ?? e.message;
            throw Exception('Voice processing failed: $errorMessage');
          }
        } catch (_) {}
      }
      
      throw Exception('Voice processing failed: ${e.message}');
    } catch (e) {
      debugPrint('❌ Voice processing error: $e');
      rethrow;
    }
  }

  /// Decrypt voice file
  Future<String> decryptVoice(String encryptedPath) async {
    try {
      final formData = FormData.fromMap({
        'encrypted_file': await MultipartFile.fromFile(
          encryptedPath,
          filename: 'voice.enc',
        ),
      });

      final response = await _dio.post(
        '$apiUrl/api/decrypt-voice',
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      // Save decrypted file
      final dir = await getApplicationDocumentsDirectory();
      final outputPath = '${dir.path}/decrypted_${DateTime.now().millisecondsSinceEpoch}.wav';

      await File(outputPath).writeAsBytes(response.data);
      debugPrint('🔓 Decrypted voice saved to: $outputPath');

      return outputPath;
    } on DioException catch (e) {
      debugPrint('❌ Voice decryption error: ${e.message}');
      throw Exception('Voice decryption failed: ${e.message}');
    }
  }

  /// Check server health
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      debugPrint('🏥 Checking server health: $apiUrl/health');
      
      final response = await _dio.get(
        '$apiUrl/health',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      
      debugPrint('✅ Server health: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Test connection to the voice AI server
  Future<bool> testConnection() async {
    final health = await checkHealth();
    return health['status'] == 'healthy' || health['status'] == 'ok';
  }
}

/// Global instance of voice AI service
final voiceAIService = VoiceAIService();
