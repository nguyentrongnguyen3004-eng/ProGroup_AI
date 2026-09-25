import 'package:flutter/material.dart';

import '../../../widgets/governance/governance_widgets.dart';
import '../registration/governance_registration_overview_screen.dart';
import 'governance_assignment_screen.dart';
import 'governance_import_screen.dart';

class GovernanceToolsScreen extends StatelessWidget {
  const GovernanceToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý khoa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Công cụ nghiệp vụ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GovernanceActionCard(
            title: 'Phân công giảng viên',
            subtitle: 'Chọn lớp học phần và xác nhận giảng viên phụ trách.',
            icon: Icons.assignment_ind_outlined,
            onTap: () => _open(context, const GovernanceAssignmentScreen()),
          ),
          GovernanceActionCard(
            title: 'Import dữ liệu',
            subtitle: 'Nhập sinh viên, giảng viên và lớp học phần từ CSV/XLSX.',
            icon: Icons.upload_file_outlined,
            onTap: () => _open(context, const GovernanceImportScreen()),
          ),
          GovernanceActionCard(
            title: 'Theo dõi đăng ký đồ án',
            subtitle: 'Tổng hợp nhóm và trạng thái đăng ký đề tài.',
            icon: Icons.fact_check_outlined,
            onTap: () =>
                _open(context, const GovernanceRegistrationOverviewScreen()),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}
