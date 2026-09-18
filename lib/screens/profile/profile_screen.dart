import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../data/mock/mock_user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockUser.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cá nhân',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(
                user.fullName.substring(0, 1),
                style: const TextStyle(
                  fontSize: 32,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Center(
            child: Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Center(
            child: Text(
              user.mssv ?? user.username,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.person),
                  title: const Text(
                    'Tên đăng nhập',
                  ),
                  subtitle:
                      Text(user.username),
                ),

                ListTile(
                  leading:
                      const Icon(Icons.email),
                  title: const Text(
                    'Email',
                  ),
                  subtitle: Text(user.email),
                ),

                ListTile(
                  leading:
                      const Icon(Icons.badge),
                  title: const Text(
                    'Vai trò',
                  ),
                  subtitle:
                      Text(user.roleName),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.lock_outline,
                  ),
                  title: const Text(
                    'Đổi mật khẩu',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {},
                ),

                ListTile(
                  leading: const Icon(
                    Icons.edit,
                  ),
                  title: const Text(
                    'Chỉnh sửa thông tin',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
            label: const Text(
              'Đăng xuất',
            ),
          ),
        ],
      ),
    );
  }
}