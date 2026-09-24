import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String groupName;

  const ChatScreen({super.key, required this.groupName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      'name': 'Nguyễn Văn An',
      'message': 'Mọi người đã chọn đề tài chưa?',
      'me': true,
      'time': '19:20',
    },
    {
      'name': 'Trần Văn Minh',
      'message': 'Mình thấy đề tài số 1 khá ổn.',
      'me': false,
      'time': '19:21',
    },
    {
      'name': 'Lê Hoàng Nam',
      'message': 'Mình cũng đồng ý.',
      'me': false,
      'time': '19:22',
    },
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final message = messageController.text.trim();

    if (message.isEmpty) return;

    setState(() {
      messages.add({
        'name': 'Nguyễn Văn An',
        'message': message,
        'me': true,
        'time': TimeOfDay.now().format(context),
      });

      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.text(
                              'Chưa có tin nhắn',
                              en: 'No messages yet',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final item = messages[index];

                      final bool me = item['me'] as bool;

                      return Align(
                        alignment: me
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 310),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: me
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: me
                                ? null
                                : Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!me)
                                Text(
                                  item['name'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (!me) SizedBox(height: 4),
                              Text(
                                item['message'] as String,
                                style: TextStyle(
                                  color: me ? Colors.white : null,
                                  height: 1.35,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                item['time'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: me ? Colors.white70 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.text(
                          'Nhập tin nhắn...',
                          en: 'Enter a message...',
                        ),
                        prefixIcon: Icon(Icons.chat_outlined),
                      ),
                    ),
                  ),

                  SizedBox(width: 8),

                  IconButton.filled(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
