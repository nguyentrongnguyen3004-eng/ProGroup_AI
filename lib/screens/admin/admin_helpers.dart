import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../models/admin_account_model.dart';

String adminText(String vi, String en) => AppLocalizations.text(vi, en: en);

String adminRoleText(String role) => switch (role) {
  'Sinh viên' => adminText('Sinh viên', 'Student'),
  'Giảng viên' => adminText('Giảng viên', 'Lecturer'),
  'Giáo vụ khoa' => adminText('Giáo vụ khoa', 'Faculty staff'),
  'Phòng Đào tạo' => adminText('Phòng Đào tạo', 'Academic Affairs'),
  'Admin' => 'Admin',
  _ => role,
};

String adminStatusText(String status) => switch (status) {
  'Đang hoạt động' => adminText('Đang hoạt động', 'Active'),
  'Đã khóa' => adminText('Đã khóa', 'Locked'),
  'Đang học' => adminText('Đang học', 'Studying'),
  'Đã nghỉ' => adminText('Đã nghỉ', 'Inactive'),
  'Đang công tác' => adminText('Đang công tác', 'Working'),
  'Đang giảng dạy' => adminText('Đang giảng dạy', 'Teaching'),
  'Tạm ngưng' => adminText('Tạm ngưng', 'Suspended'),
  _ => AppLocalizations.status(status),
};

String adminActivityActionText(String action) => switch (action) {
  'Đăng nhập' => adminText('Đăng nhập', 'Sign in'),
  'Đăng xuất' => adminText('Đăng xuất', 'Sign out'),
  'Thêm user' => adminText('Thêm người dùng', 'Add user'),
  'Sửa user' => adminText('Cập nhật người dùng', 'Update user'),
  'Xóa user' => adminText('Xóa người dùng', 'Delete user'),
  'Khóa user' => adminText('Khóa người dùng', 'Lock user'),
  'Mở khóa user' => adminText('Mở khóa người dùng', 'Unlock user'),
  'Thay đổi role' => adminText('Thay đổi vai trò', 'Change role'),
  'Import dữ liệu' => adminText('Import dữ liệu', 'Import data'),
  'Cập nhật dữ liệu' => adminText('Cập nhật dữ liệu', 'Update data'),
  _ => action,
};

String adminActivityDescriptionText(String description) {
  if (!AppLocalizations.isEnglish) return description;
  if (description == 'Tài khoản Admin đăng nhập thành công.') {
    return 'Admin account signed in successfully.';
  }
  if (description == 'Tài khoản Admin đăng xuất.') {
    return 'Admin account signed out.';
  }
  if (description == 'Đã cập nhật thông tin tài khoản.') {
    return 'Account information was updated.';
  }
  if (description == 'Đã khóa tài khoản.') return 'Account was locked.';
  if (description == 'Đã mở khóa tài khoản.') return 'Account was unlocked.';
  if (description == 'Đã đồng bộ danh mục học phần mẫu.') {
    return 'Sample course catalog was synchronized.';
  }
  if (description == 'Đã import dữ liệu sinh viên mẫu.') {
    return 'Sample student data was imported.';
  }
  if (description.startsWith('Đã tạo tài khoản ')) {
    return 'Created account ${description.substring('Đã tạo tài khoản '.length)}';
  }
  if (description.startsWith('Đã xóa tài khoản ')) {
    return 'Deleted account ${description.substring('Đã xóa tài khoản '.length)}';
  }
  if (description.startsWith('Đổi vai trò từ ')) {
    return 'Account role was changed.';
  }
  return description;
}

void showAdminMessage(BuildContext context, String vi, String en) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(adminText(vi, en))));
}

String adminDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
}

Widget adminAvatar(
  BuildContext context,
  AdminAccountModel account, {
  double radius = 24,
}) {
  final initials = account.fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0])
      .take(2)
      .join()
      .toUpperCase();
  if (account.avatar.startsWith('data:image/')) {
    final separator = account.avatar.indexOf(',');
    if (separator > 0) {
      try {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(
            base64Decode(account.avatar.substring(separator + 1)),
          ),
        );
      } catch (_) {
        // Fall back to initials when the local image data is invalid.
      }
    }
  }
  return CircleAvatar(
    radius: radius,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    child: Text(initials.isEmpty ? 'PG' : initials),
  );
}

Widget adminEmptyState(BuildContext context, String vi, String en) => Center(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Text(
      adminText(vi, en),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge,
    ),
  ),
);
