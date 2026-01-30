import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/encryption_provider.dart';
import '../../providers/voice_settings_provider.dart';
import '../../services/chat_service.dart';
import '../../services/privacy_service.dart';
import '../../services/voice_ai_service.dart';
import '../../widgets/chat_header.dart';
import '../../widgets/chat_menu.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String chatName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  String? _recordingPath;
  bool _isProcessingVoice = false;
  bool _isUploading = false;
  String? _playingAudioId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authState = ref.read(authStateProvider);
    final user = authState.value;
    if (user == null) return;

    _messageController.clear();

    // Check for sensitive data
    final encryptionSettings = ref.read(encryptionSettingsProvider);
    final isSensitive = PrivacyService.detectSensitiveData(
      text,
      encryptionSettings.customKeywords,
    );
    
    String messageToSend = text;
    bool isEncrypted = false;
    
    if (isSensitive && encryptionSettings.autoEncrypt) {
      messageToSend = PrivacyService.encryptMessage(text);
      isEncrypted = true;
    }

    await chatService.sendMessage(
      chatId: widget.chatId,
      text: messageToSend,
      senderId: user.uid,
      senderEmail: user.email ?? '',
      isEncrypted: isEncrypted,
    );
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    final authState = ref.read(authStateProvider);
    final user = authState.value;
    if (user == null) return;

    setState(() => _isUploading = true);

    try {
      await chatService.sendImageMessage(
        chatId: widget.chatId,
        imagePath: image.path,
        senderId: user.uid,
        senderEmail: user.email ?? '',
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      _recordingPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordingPath!,
      );
      
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordingDuration++);
      });
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final path = await _recorder.stop();
    
    setState(() => _isRecording = false);

    if (path == null) return;

    // Show dialog to send or process with AI
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Message'),
        content: const Text('How would you like to send this voice message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'send'),
            child: const Text('Send As Is'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'process'),
            child: const Text('Process with AI'),
          ),
        ],
      ),
    );

    if (action == 'cancel') return;
    if (action == 'send') {
      await _sendVoiceMessage(path, encrypted: false);
    } else if (action == 'process') {
      await _processAndSendVoice(path);
    }
  }

  Future<void> _processAndSendVoice(String path) async {
    setState(() => _isProcessingVoice = true);

    try {
      final voiceSettings = ref.read(voiceSettingsProvider);
      
      final processedPath = await voiceAIService.processVoice(
        path,
        pitchShift: voiceSettings.pitchShift,
        pitchSteps: voiceSettings.pitchSteps,
        useAiMasking: voiceSettings.useAiMasking,
        encrypt: voiceSettings.encryptVoice,
      );

      await _sendVoiceMessage(processedPath, encrypted: voiceSettings.encryptVoice);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice processing failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isProcessingVoice = false);
    }
  }

  Future<void> _sendVoiceMessage(String path, {bool encrypted = false}) async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    if (user == null) return;

    await chatService.sendVoiceMessage(
      chatId: widget.chatId,
      audioPath: path,
      senderId: user.uid,
      senderEmail: user.email ?? '',
      isEncrypted: encrypted,
    );
  }

  Future<void> _playAudio(String url, String messageId) async {
    if (_playingAudioId == messageId) {
      await _audioPlayer.stop();
      setState(() => _playingAudioId = null);
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() => _playingAudioId = messageId);
      
      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() => _playingAudioId = null);
      });
    }
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.uid;

    return Scaffold(
      appBar: AppBar(
        title: ChatHeader(chatName: widget.chatName, chatId: widget.chatId),
        actions: [
          ChatMenu(chatName: widget.chatName, chatId: widget.chatId),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),

          // Voice processing indicator
          if (_isProcessingVoice)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.primary.withOpacity(0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Processing voice with AI...'),
                ],
              ),
            ),

          // Upload indicator
          if (_isUploading)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.primary.withOpacity(0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Uploading image...'),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.backgroundSecondary,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment button
                  IconButton(
                    onPressed: _pickAndSendImage,
                    icon: const Icon(Icons.attach_file),
                    color: AppColors.textSecondary,
                  ),

                  // Recording indicator or text input
                  Expanded(
                    child: _isRecording
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.mic,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recording ${_formatDuration(_recordingDuration)}',
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            maxLines: 4,
                            minLines: 1,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                  ),

                  const SizedBox(width: 8),

                  // Voice/Send button
                  GestureDetector(
                    onLongPressStart: (_) => _startRecording(),
                    onLongPressEnd: (_) => _stopRecording(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isRecording ? AppColors.error : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _isRecording ? null : _sendMessage,
                        icon: Icon(
                          _isRecording ? Icons.mic : Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final isEncrypted = message.isEncrypted;
    final isVoice = message.isVoiceMessage;
    final hasImage = message.imageUrl != null;
    final hasAudio = message.audioUrl != null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.messageSent : AppColors.messageReceived,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 200,
                      height: 150,
                      color: AppColors.background,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),

            // Voice message
            if (hasAudio)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _playAudio(message.audioUrl!, message.id),
                    icon: Icon(
                      _playingAudioId == message.id
                          ? Icons.stop
                          : Icons.play_arrow,
                      color: isMe ? Colors.white : AppColors.primary,
                    ),
                  ),
                  Text(
                    isEncrypted ? '🔒 Encrypted voice' : '🎤 Voice message',
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.text,
                    ),
                  ),
                ],
              ),

            // Text message
            if (message.text.isNotEmpty && !hasImage && !hasAudio)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEncrypted)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 14,
                          color: isMe ? Colors.white70 : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Encrypted',
                          style: TextStyle(
                            fontSize: 12,
                            color: isMe ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  Text(
                    isEncrypted
                        ? PrivacyService.decryptMessage(message.text)
                        : message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.text,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),

            // Time
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white60 : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
