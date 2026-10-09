import 'package:flutter/material.dart';

import 'package:progroup_ai_frontend/core/localization/app_localizations.dart';
import 'package:progroup_ai_frontend/core/routes/app_routes.dart';
import 'package:progroup_ai_frontend/data/mock/mock_groups.dart';
import 'package:progroup_ai_frontend/data/mock/mock_user.dart';
import 'package:progroup_ai_frontend/models/group_model.dart';
import 'package:progroup_ai_frontend/widgets/group_card.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<GroupModel> get myGroups {
    final studentName = MockUser.student.fullName;

    return MockGroups.groups
        .where((group) => group.members.contains(studentName))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = myGroups;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Nhóm của tôi', en: 'My Groups'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: groups.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: groups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final group = groups[index];

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
            ),
    );
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.groups_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.text(
              'Bạn chưa tham gia nhóm nào',
              en: 'You have not joined any group yet',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.text(
              'Hãy vào một lớp học phần để tạo hoặc tham gia nhóm.',
              en: 'Open a course to create or join a group.',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
