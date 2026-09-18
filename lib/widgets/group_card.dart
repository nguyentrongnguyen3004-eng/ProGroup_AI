import 'package:flutter/material.dart';
import '../models/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.group,
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
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      group.name.substring(0, 1),
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

                  const Icon(
                    Icons.chevron_right,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                'Trưởng nhóm: ${group.leader}',
              ),

              const SizedBox(height: 6),

              Text(
                'Thành viên: ${group.memberCount}/${group.maxMembers}',
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value:
                    group.memberCount / group.maxMembers,
              ),

              const SizedBox(height: 10),

              Chip(
                label: Text(group.status),
              ),
            ],
          ),
        ),
      ),
    );
  }
}