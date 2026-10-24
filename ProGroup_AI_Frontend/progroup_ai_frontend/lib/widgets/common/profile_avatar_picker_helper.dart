import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_localizations.dart';

class ProfileAvatarPickerHelper {
  ProfileAvatarPickerHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Hiển thị bottom sheet cho phép người dùng:
  /// 1. Chụp ảnh từ Camera
  /// 2. Chọn ảnh từ Thư viện (Gallery)
  /// 3. Xóa ảnh hiện tại
  static Future<void> show({
    required BuildContext context,
    required ValueChanged<String> onAvatarSelected,
    VoidCallback? onAvatarRemoved,
  }) async {
    final colors = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  AppLocalizations.text('Ảnh đại diện', en: 'Profile Picture'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB), size: 22),
                ),
                title: Text(AppLocalizations.text('Chụp ảnh mới', en: 'Take Photo')),
                subtitle: Text(
                  AppLocalizations.text('Mở máy ảnh và chụp ngay', en: 'Open camera and snap photo'),
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickImage(
                    context: context,
                    source: ImageSource.camera,
                    onAvatarSelected: onAvatarSelected,
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981), size: 22),
                ),
                title: Text(AppLocalizations.text('Chọn từ thư viện', en: 'Choose from Gallery')),
                subtitle: Text(
                  AppLocalizations.text('Chọn ảnh từ bộ sưu tập điện thoại', en: 'Pick image from gallery'),
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickImage(
                    context: context,
                    source: ImageSource.gallery,
                    onAvatarSelected: onAvatarSelected,
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
                ),
                title: Text(AppLocalizations.text('Xóa ảnh đại diện', en: 'Remove Photo')),
                subtitle: Text(
                  AppLocalizations.text('Trở về chữ cái tên đại diện', en: 'Revert to initial letter avatar'),
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (onAvatarRemoved != null) {
                    onAvatarRemoved();
                  } else {
                    onAvatarSelected('');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.text('Đã xóa ảnh đại diện.', en: 'Profile picture removed.'),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
    );
  }

  static Future<void> _pickImage({
    required BuildContext context,
    required ImageSource source,
    required ValueChanged<String> onAvatarSelected,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null || !context.mounted) return;

      final Uint8List bytes = await image.readAsBytes();
      if (bytes.isEmpty || !context.mounted) return;

      final extension = image.name.split('.').last.toLowerCase();
      final mime = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };

      final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              AppLocalizations.text('Xem trước ảnh đại diện', en: 'Preview Profile Picture'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2563EB), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 64,
                    backgroundImage: MemoryImage(bytes),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(AppLocalizations.text('Hủy', en: 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.text('Dùng ảnh này', en: 'Use This Photo')),
              ),
            ],
          );
        },
      );

      if (confirmed == true && context.mounted) {
        onAvatarSelected(dataUri);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.text('Cập nhật ảnh đại diện thành công!', en: 'Profile picture updated!'),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
