import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../models/group_model.dart';

class GroupDetailScreen
    extends StatelessWidget {
  final GroupModel group;

  const GroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.chat,
                arguments: group.name,
              );
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              child: Text(
                group.name.substring(0, 1),
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              group.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '${group.memberCount}/${group.maxMembers} thành viên',
            ),

            const SizedBox(height: 25),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        'Thành viên',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...group.members.map(
                      (member) => ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading:
                            const CircleAvatar(
                          child:
                              Icon(Icons.person),
                        ),
                        title: Text(member),
                        subtitle: Text(
                          member == group.leader
                              ? 'Trưởng nhóm'
                              : 'Thành viên',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.lock_outline,
                ),
                title: const Text(
                  'Trạng thái nhóm',
                ),
                subtitle: Text(group.status),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chat,
                    arguments: group.name,
                  );
                },
                icon: const Icon(
                  Icons.chat,
                ),
                label: const Text(
                  'Mở chat nhóm',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}