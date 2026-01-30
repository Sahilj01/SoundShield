import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Voice settings state
class VoiceSettings {
  final bool pitchShift;
  final int pitchSteps;
  final bool useAiMasking;
  final bool encryptVoice;

  const VoiceSettings({
    this.pitchShift = true,
    this.pitchSteps = 4,
    this.useAiMasking = true,
    this.encryptVoice = true,
  });

  VoiceSettings copyWith({
    bool? pitchShift,
    int? pitchSteps,
    bool? useAiMasking,
    bool? encryptVoice,
  }) {
    return VoiceSettings(
      pitchShift: pitchShift ?? this.pitchShift,
      pitchSteps: pitchSteps ?? this.pitchSteps,
      useAiMasking: useAiMasking ?? this.useAiMasking,
      encryptVoice: encryptVoice ?? this.encryptVoice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pitchShift': pitchShift,
      'pitchSteps': pitchSteps,
      'useAiMasking': useAiMasking,
      'encryptVoice': encryptVoice,
    };
  }

  factory VoiceSettings.fromJson(Map<String, dynamic> json) {
    return VoiceSettings(
      pitchShift: json['pitchShift'] ?? true,
      pitchSteps: json['pitchSteps'] ?? 4,
      useAiMasking: json['useAiMasking'] ?? true,
      encryptVoice: json['encryptVoice'] ?? true,
    );
  }
}

/// Provider for voice settings
final voiceSettingsProvider = StateNotifierProvider<VoiceSettingsNotifier, VoiceSettings>((ref) {
  return VoiceSettingsNotifier();
});

/// State notifier for voice settings
class VoiceSettingsNotifier extends StateNotifier<VoiceSettings> {
  VoiceSettingsNotifier() : super(const VoiceSettings()) {
    _loadSettings();
  }

  static const String _prefsKey = 'voice_settings';

  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pitchShift = prefs.getBool('${_prefsKey}_pitchShift') ?? true;
      final pitchSteps = prefs.getInt('${_prefsKey}_pitchSteps') ?? 4;
      final useAiMasking = prefs.getBool('${_prefsKey}_useAiMasking') ?? true;
      final encryptVoice = prefs.getBool('${_prefsKey}_encryptVoice') ?? true;

      state = VoiceSettings(
        pitchShift: pitchShift,
        pitchSteps: pitchSteps,
        useAiMasking: useAiMasking,
        encryptVoice: encryptVoice,
      );
    } catch (e) {
      // Use default settings if loading fails
    }
  }

  /// Save settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_prefsKey}_pitchShift', state.pitchShift);
      await prefs.setInt('${_prefsKey}_pitchSteps', state.pitchSteps);
      await prefs.setBool('${_prefsKey}_useAiMasking', state.useAiMasking);
      await prefs.setBool('${_prefsKey}_encryptVoice', state.encryptVoice);
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Toggle pitch shift
  void togglePitchShift() {
    state = state.copyWith(pitchShift: !state.pitchShift);
    _saveSettings();
  }

  /// Set pitch steps
  void setPitchSteps(int steps) {
    state = state.copyWith(pitchSteps: steps.clamp(-12, 12));
    _saveSettings();
  }

  /// Toggle AI masking
  void toggleAiMasking() {
    state = state.copyWith(useAiMasking: !state.useAiMasking);
    _saveSettings();
  }

  /// Toggle voice encryption
  void toggleEncryptVoice() {
    state = state.copyWith(encryptVoice: !state.encryptVoice);
    _saveSettings();
  }

  /// Update all settings at once
  void updateSettings({
    bool? pitchShift,
    int? pitchSteps,
    bool? useAiMasking,
    bool? encryptVoice,
  }) {
    state = state.copyWith(
      pitchShift: pitchShift,
      pitchSteps: pitchSteps,
      useAiMasking: useAiMasking,
      encryptVoice: encryptVoice,
    );
    _saveSettings();
  }
}
