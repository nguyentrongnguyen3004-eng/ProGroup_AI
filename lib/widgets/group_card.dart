import 'package:flutter/material.dart';

import '../models/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;

  const GroupCard({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = group.maxMembers == 0
        ? 0.0
        : (group.memberCount / group.maxMembers).clamp(0.0, 1.0);

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
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: Text(
                      group.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Icon(Icons.chevron_right),
                ],
              ),

              const SizedBox(height: 14),

              Text('Trưởng nhóm: ${group.leader}'),

              const SizedBox(height: 6),

              Text('Thành viên: ${group.memberCount}/${group.maxMembers}'),

              const SizedBox(height: 9),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(value: progress, minHeight: 7),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.green),
                  const SizedBox(width: 7),
                  Text(
                    group.status,
                    style: const TextStyle(fontWeight: FontWeight.w600),
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
