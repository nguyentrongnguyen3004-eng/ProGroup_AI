import 'dart:async';

import 'package:flutter/material.dart';



import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

import 'package:progroup_ai_frontend/screens/sinh_vien/group/join_request_screen.dart';

import 'package:progroup_ai_frontend/services/auth_service.dart';

import 'package:progroup_ai_frontend/services/chat_storage_service.dart';

import 'package:progroup_ai_frontend/services/firebase_service.dart';

import 'package:progroup_ai_frontend/services/student_api_service.dart';



class ChatScreen extends StatefulWidget {

  final String groupName;

  final int? groupId;



  const ChatScreen({

    super.key,

    required this.groupName,

    this.groupId,

  });



  @override

  State<ChatScreen> createState() => _ChatScreenState();

}



class _ChatScreenState extends State<ChatScreen> {

  final messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();



  StreamSubscription? _messagesSubscription;

  Timer? _refreshTimer;

  int? _effectiveGroupId;

  List<Map<String, dynamic>> messages = [];



  String get _currentUserId => AuthService.currentUser.id.toString();

  String get _currentUserName => AuthService.currentUser.fullName;

  String get _chatRoomId {
    final gid = _effectiveGroupId ?? widget.groupId;
    if (gid != null && gid > 0) return 'group_$gid';
    return 'group_${Uri.encodeComponent(widget.groupName)}';
  }

  @override
  void initState() {
    super.initState();
    _effectiveGroupId = widget.groupId;
    _initChatMessages();
    _resolveGroupAndJoinRequests();

    // TC_STU_048 & TC_STU_055: Tự động cập nhật nhãn thời gian tương đối theo thời gian thực (real-time)
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _initChatMessages() async {
    final roomId = _chatRoomId;

    // 1. Luôn tải tin nhắn đã lưu cục bộ trước để hiển thị ngay lập tức và không bị mất khi thoát/khởi động lại
    final local = await ChatStorageService.instance.loadMessages(
      roomId,
      currentUserId: _currentUserId,
    );
    if (!mounted) return;

    if (local.isNotEmpty) {
      setState(() {
        messages = local;
      });
      _scrollToBottom();
    }

    // 2. Nếu Firebase đã khởi tạo, lắng nghe Firestore Stream để đồng bộ tin nhắn realtime
    if (FirebaseService.instance.isInitialized) {
      await _messagesSubscription?.cancel();
      _messagesSubscription = FirebaseService.instance
          .getGroupMessagesStream(roomId)
          .listen(
        (firestoreMsgs) {
          if (!mounted) return;
          if (firestoreMsgs.isNotEmpty) {
            final mappedFirestore = firestoreMsgs.map((m) {
              final senderId = m['senderId']?.toString() ?? '';
              final isMe = senderId == _currentUserId;
              final rawCreated = m['createdAt'];
              return {
                'id': m['id'] ?? '',
                'senderId': senderId,
                'type': m['type'] ?? 'text',
                'name': m['senderName'] ?? '',
                'message': m['content'] ?? '',
                'me': isMe,
                'createdAt': rawCreated,
                'time': _formatMessageTime(rawCreated),
                'studentName': m['metadata']?['studentName'] ?? m['senderName'] ?? '',
                'studentMssv': m['metadata']?['studentMssv'] ?? '',
                'status': m['metadata']?['status'] ?? 'Chờ duyệt',
                'requestId': m['metadata']?['requestId'],
              };
            }).toList();

            final merged = _mergeWithLocalMessages(mappedFirestore, messages);

            setState(() {
              messages = merged;
            });
            ChatStorageService.instance.saveMessages(roomId, merged);
            _scrollToBottom();
          } else if (messages.isEmpty) {
            _loadDefaultWelcomeMessage();
          }
        },
        onError: (e) {
          debugPrint('[Chat] Firestore stream error: $e');
          if (mounted && messages.isEmpty) {
            _loadDefaultWelcomeMessage();
          }
        },
      );
    } else if (messages.isEmpty) {
      _loadDefaultWelcomeMessage();
    }
  }

  /// Kết hợp tin nhắn từ Firestore với các tin nhắn cục bộ chưa đồng bộ hoặc yêu cầu tham gia
  List<Map<String, dynamic>> _mergeWithLocalMessages(
    List<Map<String, dynamic>> remoteMsgs,
    List<Map<String, dynamic>> currentLocalMsgs,
  ) {
    final result = List<Map<String, dynamic>>.from(remoteMsgs);
    final existingIds = result.map((m) => m['id']?.toString() ?? '').where((id) => id.isNotEmpty).toSet();

    for (final local in currentLocalMsgs) {
      final id = local['id']?.toString() ?? '';
      final type = local['type']?.toString() ?? 'text';

      // Bỏ qua tin nhắn chào mừng mặc định nếu đã có dữ liệu thật
      if (id == 'welcome_1') continue;
      if (id.isNotEmpty && existingIds.contains(id)) continue;

      if (type == 'join_request' || type == 'system') {
        result.add(local);
        if (id.isNotEmpty) existingIds.add(id);
        continue;
      }

      // Chỉ giữ lại tin nhắn văn bản cục bộ đang chờ đồng bộ hoặc gửi khi offline/lỗi quyền Firestore
      final isPending = local['pendingSync'] == true;
      if (isPending) {
        final localText = local['message']?.toString() ?? '';
        final alreadySyncedInRemote = remoteMsgs.any(
          (r) => r['me'] == true && r['message']?.toString() == localText,
        );
        if (!alreadySyncedInRemote) {
          result.add(local);
          if (id.isNotEmpty) existingIds.add(id);
        }
      }
    }

    return result;
  }

  String _formatMessageTime(dynamic createdAt) {
    if (createdAt == null) return 'Vừa xong';
    DateTime? dt;
    try {
      if (createdAt is DateTime) {
        dt = createdAt;
      } else if (createdAt is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
      } else if (createdAt is String) {
        dt = DateTime.tryParse(createdAt);
      } else {
        try {
          dt = (createdAt as dynamic).toDate() as DateTime?;
        } catch (_) {
          dt = null;
        }
      }
    } catch (_) {
      dt = null;
    }

    if (dt == null) return 'Vừa xong';

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60 && diff.inSeconds >= -5) {
      return 'Vừa xong';
    }
    if (diff.inMinutes < 60 && diff.inMinutes > 0) {
      return '${diff.inMinutes} phút trước';
    }
    if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min';
    }
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} $hour:$min';
  }

  Future<void> _resolveGroupAndJoinRequests() async {
    if (_effectiveGroupId == null || _effectiveGroupId! <= 0) {
      try {
        final groups = await StudentApiService.instance.fetchMyGroups();
        if (mounted && groups.isNotEmpty) {
          for (final g in groups) {
            if (g.name == widget.groupName || widget.groupName.contains(g.name)) {
              final oldRoomId = _chatRoomId;
              _effectiveGroupId = g.id;
              if (_chatRoomId != oldRoomId) {
                await _initChatMessages();
              }
              break;
            }
          }
        }
      } catch (_) {}
    }
    _loadJoinRequests();
  }

  Future<void> _loadJoinRequests() async {
    final gid = _effectiveGroupId;
    if (gid == null || gid <= 0) return;
    try {
      final reqs = await StudentApiService.instance.fetchGroupJoinRequests(gid);
      if (!mounted || reqs.isEmpty) return;

      bool added = false;
      setState(() {
        for (final r in reqs) {
          final reqId = r['id']?.toString() ?? '';
          if (!messages.any((m) => m['type'] == 'join_request' && (m['requestId']?.toString() == reqId || m['id'] == reqId))) {
            final created = r['createdAt'] != null ? DateTime.tryParse(r['createdAt'].toString()) : DateTime.now();
            messages.insert(0, {
              'id': 'join_req_$reqId',
              'requestId': r['id'],
              'type': 'join_request',
              'name': r['studentName'] ?? 'Sinh viên',
              'message': 'Yêu cầu xin gia nhập nhóm',
              'me': false,
              'createdAt': created,
              'time': created != null ? _formatMessageTime(created) : 'Chờ duyệt',
              'studentName': r['studentName'] ?? '',
              'studentMssv': r['studentMssv'] ?? '',
              'status': r['status'] ?? 'Chờ duyệt',
            });
            added = true;
          }
        }
      });
      if (added) {
        await ChatStorageService.instance.saveMessages(_chatRoomId, messages);
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _loadDefaultWelcomeMessage() {
    if (!mounted) return;
    setState(() {
      messages = [
        {
          'id': 'welcome_1',
          'type': 'system',
          'name': 'Hệ thống',
          'message': 'Đoạn chat nhóm "${widget.groupName}" đã sẵn sàng với Cloud Firestore!',
          'me': false,
          'time': 'Hôm nay',
        },
      ];
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messagesSubscription?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();

    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final roomId = _chatRoomId;

    // TC_STU_054: Kích hoạt nhánh cục bộ ngay lập tức để không freeze giao diện, hỗ trợ chế độ ngoại tuyến (Airplane mode)
    final localMsg = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': _currentUserId,
      'type': 'text',
      'name': _currentUserName,
      'message': text,
      'me': true,
      'createdAt': now,
      'time': '$hour:$minute',
      'pendingSync': true,
    };

    setState(() {
      messages.add(localMsg);
    });
    _scrollToBottom();

    // Lưu cục bộ ngay lập tức để không bị mất khi thoát màn hình hoặc restart app
    await ChatStorageService.instance.saveMessages(roomId, messages);

    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseService.instance.sendMessage(
          groupId: roomId,
          senderId: _currentUserId,
          senderName: _currentUserName,
          content: text,
          type: 'text',
        ).timeout(const Duration(seconds: 4));

        // Đánh dấu đã đồng bộ thành công lên Firestore
        localMsg['pendingSync'] = false;
        await ChatStorageService.instance.saveMessages(roomId, messages);
      } catch (e) {
        debugPrint('[Chat] Offline / airplane mode sending message: $e');
        // Không văng lỗi ra UI, tin nhắn vẫn được giữ ở bộ nhớ cục bộ với pendingSync = true
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _approveJoinRequestInChat(Map<String, dynamic> item) async {
    final studentName = item['studentName'] as String? ?? 'Sinh viên';
    final messageId = item['id'] as String?;
    final rawReqId = item['requestId'] ?? int.tryParse(messageId?.replaceAll('join_req_', '') ?? '');
    final requestId = rawReqId is int ? rawReqId : int.tryParse(rawReqId?.toString() ?? '');

    try {
      int gid = _effectiveGroupId ?? widget.groupId ?? 0;
      if (gid <= 0) {
        try {
          final groups = await StudentApiService.instance.fetchMyGroups();
          if (groups.isNotEmpty) {
            final found = groups.firstWhere(
              (g) => g.name == widget.groupName || widget.groupName.contains(g.name),
              orElse: () => groups.first,
            );
            gid = found.id;
            _effectiveGroupId = gid;
          }
        } catch (_) {}
      }

      if (requestId != null && requestId > 0) {
        await StudentApiService.instance.respondJoinRequest(
          nhomId: gid,
          requestId: requestId,
          accept: true,
        );
      }
      if (FirebaseService.instance.isInitialized && messageId != null && messageId.isNotEmpty) {
        try {
          await FirebaseService.instance.updateJoinRequestStatus(
            groupId: _chatRoomId,
            messageId: messageId,
            newStatus: 'Đã chấp nhận',
          );
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        item['status'] = 'Đã chấp nhận';
        messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'system',
          'message': 'Trưởng nhóm đã duyệt yêu cầu. $studentName đã tham gia nhóm!',
          'createdAt': DateTime.now(),
          'time': 'Vừa xong',
        });
      });
      await ChatStorageService.instance.saveMessages(_chatRoomId, messages);
      _scrollToBottom();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã duyệt $studentName vào nhóm trực tiếp từ đoạn chat!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi duyệt yêu cầu: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _rejectJoinRequestInChat(Map<String, dynamic> item) async {
    final studentName = item['studentName'] as String? ?? 'Sinh viên';
    final messageId = item['id'] as String?;
    final rawReqId = item['requestId'] ?? int.tryParse(messageId?.replaceAll('join_req_', '') ?? '');
    final requestId = rawReqId is int ? rawReqId : int.tryParse(rawReqId?.toString() ?? '');

    try {
      int gid = _effectiveGroupId ?? widget.groupId ?? 0;
      if (gid <= 0) {
        try {
          final groups = await StudentApiService.instance.fetchMyGroups();
          if (groups.isNotEmpty) {
            final found = groups.firstWhere(
              (g) => g.name == widget.groupName || widget.groupName.contains(g.name),
              orElse: () => groups.first,
            );
            gid = found.id;
            _effectiveGroupId = gid;
          }
        } catch (_) {}
      }

      if (requestId != null && requestId > 0) {
        await StudentApiService.instance.respondJoinRequest(
          nhomId: gid,
          requestId: requestId,
          accept: false,
        );
      }
      if (FirebaseService.instance.isInitialized && messageId != null && messageId.isNotEmpty) {
        try {
          await FirebaseService.instance.updateJoinRequestStatus(
            groupId: _chatRoomId,
            messageId: messageId,
            newStatus: 'Đã từ chối',
          );
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        item['status'] = 'Đã từ chối';
      });
      await ChatStorageService.instance.saveMessages(_chatRoomId, messages);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã từ chối yêu cầu tham gia của $studentName.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi từ chối: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }



  @override

  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;



    return Scaffold(

      appBar: AppBar(

        title: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              widget.groupName,

              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),

            ),

            Row(

              children: [

                Container(

                  width: 7,

                  height: 7,

                  decoration: const BoxDecoration(

                    color: Color(0xFF10B981),

                    shape: BoxShape.circle,

                  ),

                ),

                const SizedBox(width: 5),

                Text(

                  'Cloud Firestore Realtime',

                  style: TextStyle(

                    fontSize: 11.5,

                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),

                    fontWeight: FontWeight.w500,

                  ),

                ),

              ],

            ),

          ],

        ),

        actions: [

          if (widget.groupId != null)

            IconButton(

              tooltip: 'Duyệt yêu cầu tham gia',

              icon: const Icon(Icons.how_to_reg_rounded),

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => JoinRequestScreen(

                      groupId: widget.groupId!,

                      groupName: widget.groupName,

                    ),

                  ),

                );

              },

            ),

        ],

      ),

      body: Column(

        children: [

          // ======================================================

          // MESSAGE LIST

          // ======================================================

          Expanded(

            child: ListView.builder(

              controller: scrollController,

              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),

              itemCount: messages.length,

              itemBuilder: (context, index) {

                final item = messages[index];

                final type = item['type'] as String? ?? 'text';



                if (type == 'system') {

                  return _buildSystemNotice(colors, item);

                }



                if (type == 'join_request') {

                  return _buildJoinRequestMessageCard(colors, item);

                }



                return _buildTextMessageBubble(colors, item);

              },

            ),

          ),



          // ======================================================

          // CHAT INPUT BAR (SAFE ABOVE ANDROID NAVIGATION BAR)

          // ======================================================

          _buildInputBar(colors),

        ],

      ),

    );

  }



  // ============================================================

  // MESSAGE ITEM BUILDERS

  // ============================================================



  Widget _buildTextMessageBubble(ColorScheme colors, Map<String, dynamic> item) {

    final bool me = item['me'] as bool? ?? false;

    final name = item['name'] as String? ?? '';

    final message = item['message'] as String? ?? '';

    final rawCreated = item['createdAt'];

    final time = rawCreated != null ? _formatMessageTime(rawCreated) : (item['time'] as String? ?? '');



    return Align(

      alignment: me ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(

        constraints: const BoxConstraints(maxWidth: 320),

        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.all(13),

        decoration: BoxDecoration(

          color: me ? const Color(0xFF2563EB) : colors.surface,

          borderRadius: BorderRadius.only(

            topLeft: const Radius.circular(16),

            topRight: const Radius.circular(16),

            bottomLeft: Radius.circular(me ? 16 : 4),

            bottomRight: Radius.circular(me ? 4 : 16),

          ),

          border: me ? null : Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withValues(alpha: 0.02),

              blurRadius: 4,

              offset: const Offset(0, 2),

            ),

          ],

        ),

        child: Column(

          crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,

          children: [

            if (!me && name.isNotEmpty)

              Padding(

                padding: const EdgeInsets.only(bottom: 4),

                child: Text(

                  name,

                  style: const TextStyle(

                    fontSize: 11.5,

                    fontWeight: FontWeight.bold,

                    color: Color(0xFF4F46E5),

                  ),

                ),

              ),

            Text(

              message,

              style: TextStyle(

                color: me ? Colors.white : colors.onSurface,

                fontSize: 14,

                height: 1.35,

              ),

            ),

            const SizedBox(height: 4),

            Text(

              time,

              style: TextStyle(

                fontSize: 10,

                color: me ? Colors.white70 : colors.onSurfaceVariant.withValues(alpha: 0.7),

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildJoinRequestMessageCard(ColorScheme colors, Map<String, dynamic> item) {

    final studentName = item['studentName'] as String? ?? 'Sinh viên';

    final studentMssv = item['studentMssv'] as String? ?? '';

    final status = item['status'] as String? ?? 'Chờ duyệt';

    final rawCreated = item['createdAt'];

    final time = rawCreated != null ? _formatMessageTime(rawCreated) : (item['time'] as String? ?? '');



    final isPending = status == 'Chờ duyệt';

    final isAccepted = status == 'Đã chấp nhận';



    return Container(

      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: isAccepted

            ? const Color(0xFF10B981).withValues(alpha: 0.08)

            : const Color(0xFF2563EB).withValues(alpha: 0.06),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(

          color: isAccepted

              ? const Color(0xFF10B981).withValues(alpha: 0.4)

              : const Color(0xFF2563EB).withValues(alpha: 0.3),

        ),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(

                  color: const Color(0xFF2563EB).withValues(alpha: 0.15),

                  shape: BoxShape.circle,

                ),

                child: const Icon(

                  Icons.person_add_alt_1_rounded,

                  color: Color(0xFF2563EB),

                  size: 20,

                ),

              ),

              const SizedBox(width: 10),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Text(

                      'Yêu cầu xin gia nhập nhóm',

                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),

                    ),

                    Text(

                      time,

                      style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),

                    ),

                  ],

                ),

              ),

              Container(

                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),

                decoration: BoxDecoration(

                  color: isAccepted

                      ? const Color(0xFF10B981).withValues(alpha: 0.15)

                      : const Color(0xFFF59E0B).withValues(alpha: 0.15),

                  borderRadius: BorderRadius.circular(8),

                ),

                child: Text(

                  status,

                  style: TextStyle(

                    fontSize: 11,

                    fontWeight: FontWeight.bold,

                    color: isAccepted ? const Color(0xFF059669) : const Color(0xFFD97706),

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 10),

          Text(

            'Sinh viên $studentName ($studentMssv) muốn tham gia nhóm đồ án của bạn.',

            style: const TextStyle(fontSize: 13.5),

          ),

          if (isPending) ...[

            const SizedBox(height: 12),

            Row(

              children: [

                Expanded(

                  child: ElevatedButton.icon(

                    onPressed: () => _approveJoinRequestInChat(item),

                    icon: const Icon(Icons.check_rounded, size: 16),

                    label: const Text('Duyệt tham gia', style: TextStyle(fontSize: 12.5)),

                    style: ElevatedButton.styleFrom(

                      backgroundColor: const Color(0xFF10B981),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                      padding: const EdgeInsets.symmetric(vertical: 8),

                    ),

                  ),

                ),

                const SizedBox(width: 8),

                OutlinedButton.icon(

                  onPressed: () => _rejectJoinRequestInChat(item),

                  icon: const Icon(Icons.close_rounded, size: 16),

                  label: const Text('Từ chối', style: TextStyle(fontSize: 12.5)),

                  style: OutlinedButton.styleFrom(

                    foregroundColor: const Color(0xFFEF4444),

                    side: const BorderSide(color: Color(0xFFEF4444)),

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),

                  ),

                ),

              ],

            ),

          ],

        ],

      ),

    );

  }



  Widget _buildSystemNotice(ColorScheme colors, Map<String, dynamic> item) {

    final message = item['message'] as String? ?? '';



    return Container(

      margin: const EdgeInsets.symmetric(vertical: 8),

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),

      decoration: BoxDecoration(

        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),

        borderRadius: BorderRadius.circular(12),

      ),

      child: Center(

        child: Text(

          message,

          textAlign: TextAlign.center,

          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),

        ),

      ),

    );

  }



  Widget _buildInputBar(ColorScheme colors) {

    return SafeArea(

      top: false,

      bottom: true,

      child: Container(

        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),

        decoration: BoxDecoration(

          color: colors.surface,

          border: Border(

            top: BorderSide(

              color: colors.outlineVariant.withValues(alpha: 0.35),

              width: 1,

            ),

          ),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withValues(alpha: 0.03),

              blurRadius: 6,

              offset: const Offset(0, -2),

            ),

          ],

        ),

        child: Row(

          children: [

            Expanded(

              child: TextField(

                controller: messageController,

                textInputAction: TextInputAction.send,

                onSubmitted: (_) => _sendMessage(),

                decoration: InputDecoration(

                  hintText: AppLocalizations.text(

                    'Nhập tin nhắn trao đổi...',

                    en: 'Type a message...',

                  ),

                  hintStyle: TextStyle(

                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),

                    fontSize: 13.5,

                  ),

                  filled: true,

                  fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),

                  border: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(18),

                    borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),

                  ),

                  enabledBorder: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(18),

                    borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),

                  ),

                  focusedBorder: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(18),

                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),

                  ),

                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                ),

              ),

            ),

            const SizedBox(width: 8),

            Container(

              decoration: BoxDecoration(

                gradient: const LinearGradient(

                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],

                ),

                borderRadius: BorderRadius.circular(16),

              ),

              child: IconButton(

                onPressed: _sendMessage,

                tooltip: 'Gửi',

                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),

              ),

            ),

          ],

        ),

      ),

    );

  }

}

