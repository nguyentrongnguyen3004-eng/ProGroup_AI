import 'package:flutter/material.dart';
import '../models/topic_model.dart';

class TopicCard extends StatelessWidget {
  final TopicModel topic;
  final VoidCallback? onTap;

  const TopicCard({
    super.key,
    required this.topic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                topic.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 6,
                children: [
                  Chip(
                    label: Text(topic.source),
                  ),
                  Chip(
                    label: Text(topic.status),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(
                    Icons.code,
                    size: 18,
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