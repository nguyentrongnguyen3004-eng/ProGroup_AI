import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../data/mock/mock_topics.dart';
import '../../widgets/topic_card.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() =>
      _TopicScreenState();
}

class _TopicScreenState
    extends State<TopicScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final topics =
        MockTopics.topics.where((topic) {
      return topic.title
          .toLowerCase()
          .contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề tài'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration:
                  const InputDecoration(
                hintText: 'Tìm kiếm đề tài...',
                prefixIcon:
                    Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                20,
              ),
              itemCount: topics.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final topic = topics[index];

                return TopicCard(
                  topic: topic,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.topicDetail,
                      arguments: topic,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Text(
                        'Thêm đề tài',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        leading: const Icon(
                          Icons.add,
                        ),
                        title: const Text(
                          'Đề xuất đề tài',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.auto_awesome,
                        ),
                        title: const Text(
                          'AI hỗ trợ đề xuất',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Đề xuất'),
      ),
    );
  }
}