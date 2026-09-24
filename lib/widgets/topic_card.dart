import 'package:flutter/material.dart';

import '../models/topic_model.dart';

class TopicCard extends StatelessWidget {
  final TopicModel topic;
  final VoidCallback? onTap;

  const TopicCard({super.key, required this.topic, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPending = topic.status == 'Chờ duyệt';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                topic.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.4),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.source_outlined, size: 15),
                    label: Text(topic.source),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: isPending
                        ? Colors.orange.withValues(alpha: 0.1)
                        : null,
                    label: Text(topic.status),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      topic.technology,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
