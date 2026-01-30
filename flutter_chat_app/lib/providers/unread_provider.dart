import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for unread messages count
final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier();
});

/// State notifier for managing unread message count
class UnreadCountNotifier extends StateNotifier<int> {
  UnreadCountNotifier() : super(0);

  /// Set the unread count
  void setCount(int count) {
    state = count;
  }

  /// Increment the count
  void increment() {
    state++;
  }

  /// Decrement the count
  void decrement() {
    if (state > 0) {
      state--;
    }
  }

  /// Reset count to zero
  void reset() {
    state = 0;
  }
}

/// Provider for per-chat unread counts
final chatUnreadCountProvider = StateNotifierProvider<ChatUnreadCountNotifier, Map<String, int>>((ref) {
  return ChatUnreadCountNotifier();
});

/// State notifier for managing per-chat unread counts
class ChatUnreadCountNotifier extends StateNotifier<Map<String, int>> {
  ChatUnreadCountNotifier() : super({});

  /// Set count for a specific chat
  void setCountForChat(String chatId, int count) {
    state = {...state, chatId: count};
  }

  /// Increment count for a specific chat
  void incrementForChat(String chatId) {
    final currentCount = state[chatId] ?? 0;
    state = {...state, chatId: currentCount + 1};
  }

  /// Clear count for a specific chat
  void clearForChat(String chatId) {
    state = {...state, chatId: 0};
  }

  /// Get count for a specific chat
  int getCountForChat(String chatId) {
    return state[chatId] ?? 0;
  }

  /// Get total unread count
  int get totalCount {
    return state.values.fold(0, (sum, count) => sum + count);
  }
}
