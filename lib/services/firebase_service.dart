import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  FirebaseFirestore? _firestore;
  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  FirebaseMessaging? _messaging;
  FirebaseMessaging get messaging {
    _messaging ??= FirebaseMessaging.instance;
    return _messaging!;
  }

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Khởi tạo Firebase Core và Cloud Messaging
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      _initialized = true;

      // Cấu hình Firebase Messaging
      try {
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          _fcmToken = await messaging.getToken();
          if (kDebugMode) {
            print('[FCM] Token: $_fcmToken');
          }
        }

        // Lắng nghe token refresh
        messaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
        });

        // Lắng nghe notification khi app ở foreground
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            print('[FCM Foreground] Nhận tin: ${message.notification?.title} - ${message.notification?.body}');
          }
        });
      } catch (fcmError) {
        if (kDebugMode) {
          print('[FCM Init Error]: $fcmError');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Firebase Init Error]: $e');
      }
    }
  }

  // ==========================================
  // REALTIME CHAT METHODS (Cloud Firestore)
  // ==========================================

  /// Stream danh sách tin nhắn nhóm theo thời gian thực
  Stream<List<Map<String, dynamic>>> getGroupMessagesStream(String groupId) {
    if (!_initialized) {
      return Stream.value([]);
    }
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Gửi tin nhắn mới vào Firestore
  Future<void> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text', // text, join_request, file
    Map<String, dynamic>? metadata,
  }) async {
    if (!_initialized) return;

    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type,
      'metadata': metadata ?? {},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cập nhật trạng thái yêu cầu tham gia (join_request) trong đoạn chat
  Future<void> updateJoinRequestStatus({
    required String groupId,
    required String messageId,
    required String newStatus, // 'Đã chấp nhận' hoặc 'Từ chối'
  }) async {
    if (!_initialized) return;

    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update({
      'metadata.status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
