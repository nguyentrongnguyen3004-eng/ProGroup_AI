import 'package:flutter/material.dart';

import '../../models/topic_model.dart';
import '../../widgets/app_button.dart';

class TopicDetailScreen
    extends StatelessWidget {
  final TopicModel topic;

  const TopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đề tài'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              topic.title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(topic.source),
                ),
                Chip(
                  label: Text(topic.status),
                ),
              ],
            ),

            const SizedBox(height: 25),

            _Section(
              title: 'Mô tả',
              content: topic.description,
            ),

            _Section(
              title: 'Mục tiêu',
              content: topic.objective,
            ),

            _Section(
              title: 'Phạm vi',
              content: topic.scope,
            ),

            _Section(
              title: 'Công nghệ dự kiến',
              content: topic.technology,
            ),

            const SizedBox(height: 15),

            AppButton(
              text: 'ĐĂNG KÝ ĐỀ TÀI',
              icon: Icons.check_circle_outline,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text(
                      'Đăng ký đề tài',
                    ),
                    content: const Text(
                      'Bạn có chắc muốn đăng ký '
                      'đề tài này cho nhóm?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(
                          context,
                        ),
                        child:
                            const Text('Hủy'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Đã gửi yêu cầu đăng ký.',
                              ),
                            ),
                          );
                        },
                        child:
                            const Text('Đăng ký'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            content,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}