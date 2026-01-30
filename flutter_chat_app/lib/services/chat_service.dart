import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';

/// Message model
class Message {
  final String id;
  final String text;
  final String senderId;
  final String senderEmail;
  final DateTime createdAt;
  final String? imageUrl;
  final String? audioUrl;
  final bool isEncrypted;
  final bool isVoiceMessage;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderEmail,
    required this.createdAt,
    this.imageUrl,
    this.audioUrl,
    this.isEncrypted = false,
    this.isVoiceMessage = false,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'text': text,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'isEncrypted': isEncrypted,
      'isVoiceMessage': isVoiceMessage,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['_id'] ?? '',
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      isEncrypted: map['isEncrypted'] ?? false,
      isVoiceMessage: map['isVoiceMessage'] ?? false,
    );
  }
}

/// Chat model
class Chat {
  final String id;
  final String name;
  final List<String> users;
  final bool isGroup;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? createdBy;

  Chat({
    required this.id,
    required this.name,
    required this.users,
    this.isGroup = false,
    this.lastMessage,
    this.lastMessageTime,
    this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'users': users,
      'isGroup': isGroup,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null 
          ? Timestamp.fromDate(lastMessageTime!) 
          : null,
      'createdBy': createdBy,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map, String docId) {
    return Chat(
      id: docId,
      name: map['name'] ?? '',
      users: List<String>.from(map['users'] ?? []),
      isGroup: map['isGroup'] ?? false,
      lastMessage: map['lastMessage'],
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'],
    );
  }
}

/// Chat service for Firestore operations
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Get all chats for current user
  Stream<List<Chat>> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('users', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Chat.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get messages for a chat
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromMap(doc.data());
      }).toList();
    });
  }

  /// Send a text message
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String senderEmail,
    bool isEncrypted = false,
  }) async {
    final messageId = _uuid.v4();
    final message = Message(
      id: messageId,
      text: text,
      senderId: senderId,
      senderEmail: senderEmail,
      createdAt: DateTime.now(),
      isEncrypted: isEncrypted,
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    // Update last message in chat
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': isEncrypted ? '[Encrypted Message]' : text,
      'lastMessageTime': Timestamp.now(),
    });
  }

  /// Send an image message
  Future<void> sendImageMessage({
    required String chatId,
    required String imagePath,
    required String senderId,
    required String senderEmail,
  }) async {
    final imageUrl = await _uploadFile(imagePath, 'images');
    final messageId = _uuid.v4();
    
    final message = Message(
      id: messageId,
      text: '',
      senderId: senderId,
      senderEmail: senderEmail,
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': '📷 Image',
      'lastMessageTime': Timestamp.now(),
    });
  }

  /// Send a voice message
  Future<void> sendVoiceMessage({
    required String chatId,
    required String audioPath,
    required String senderId,
    required String senderEmail,
    bool isEncrypted = false,
  }) async {
    final audioUrl = await _uploadFile(audioPath, 'audio');
    final messageId = _uuid.v4();
    
    final message = Message(
      id: messageId,
      text: '',
      senderId: senderId,
      senderEmail: senderEmail,
      createdAt: DateTime.now(),
      audioUrl: audioUrl,
      isVoiceMessage: true,
      isEncrypted: isEncrypted,
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': '🎤 Voice message',
      'lastMessageTime': Timestamp.now(),
    });
  }

  /// Upload file to Firebase Storage
  Future<String> _uploadFile(String filePath, String folder) async {
    final file = File(filePath);
    final fileName = '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}';
    final ref = _storage.ref().child('$folder/$fileName');
    
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Create a new chat
  Future<String> createChat({
    required String name,
    required List<String> users,
    bool isGroup = false,
    String? createdBy,
  }) async {
    final chatRef = _firestore.collection('chats').doc();
    final chat = Chat(
      id: chatRef.id,
      name: name,
      users: users,
      isGroup: isGroup,
      createdBy: createdBy,
    );

    await chatRef.set(chat.toMap());
    return chatRef.id;
  }

  /// Delete a chat
  Future<void> deleteChat(String chatId) async {
    // Delete all messages first
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();
    
    for (final doc in messages.docs) {
      await doc.reference.delete();
    }

    // Delete the chat document
    await _firestore.collection('chats').doc(chatId).delete();
  }

  /// Get all users
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('email')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Create or update user profile
  Future<void> updateUserProfile({
    required String odui,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(odui).set({
      'email': email,
      'displayName': displayName ?? email.split('@').first,
      'photoUrl': photoUrl,
      'lastSeen': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}

/// Global chat service instance
final chatService = ChatService();
