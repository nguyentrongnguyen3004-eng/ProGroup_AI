import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String groupName;

  const ChatScreen({
    super.key,
    required this.groupName,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {
  final messageController =
      TextEditingController();

  final List<Map<String, dynamic>> messages =
      [
    {
      'name': 'Nguyễn Văn An',
      'message':
          'Mọi người đã chọn đề tài chưa?',
      'me': true,
    },
    {
      'name': 'Trần Văn Minh',
      'message':
          'Mình thấy đề tài số 1 khá ổn.',
      'me': false,
    },
    {
      'name': 'Lê Hoàng Nam',
      'message':
          'Mình cũng đồng ý.',
      'me': false,
    },
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final message =
        messageController.text.trim();

    if (message.isEmpty) return;

    setState(() {
      messages.add({
        'name': 'Nguyễn Văn An',
        'message': message,
        'me': true,
      });

      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final item =
                    messages[index];

                final bool me =
                    item['me'] as bool;

                return Align(
                  alignment: me
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 300,
                    ),
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding:
                        const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: me
                          ? Colors.blue
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        if (!me)
                          Text(
                            item['name'],
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        if (!me)
                          const SizedBox(
                            height: 4,
                          ),
                        Text(
                          item['message'],
                          style: TextStyle(
                            color: me
                                ? Colors.white
                                : Colors.black87,
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
            child: Padding(
              padding:
                  const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          messageController,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Nhập tin nhắn...',
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton.filled(
                    onPressed: sendMessage,
                    icon: const Icon(
                      Icons.send,
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
}