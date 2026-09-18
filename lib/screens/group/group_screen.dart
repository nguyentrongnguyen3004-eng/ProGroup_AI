import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../data/mock/mock_groups.dart';
import '../../widgets/group_card.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhóm của tôi'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: MockGroups.groups.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final group =
              MockGroups.groups[index];

          return GroupCard(
            group: group,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.groupDetail,
                arguments: group,
              );
            },
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.group_add),
        label: const Text('Tạo nhóm'),
      ),
    );
  }
}