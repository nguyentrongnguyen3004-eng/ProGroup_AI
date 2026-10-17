import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadCount;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex = currentIndex >= 0 && currentIndex < 5 ? currentIndex : 0;

        final items = [
          _NavItemData(
            label: AppLocalizations.text('Trang chủ', en: 'Home'),
            icon: Icons.home_rounded,
            color: const Color(0xFF2563EB), // Blue
          ),
          _NavItemData(
            label: AppLocalizations.text('Lớp học phần', en: 'Courses'),
            icon: Icons.school_rounded,
            color: const Color(0xFF6366F1), // Indigo
          ),
          _NavItemData(
            label: AppLocalizations.text('Nhóm', en: 'Groups'),
            icon: Icons.groups_rounded,
            color: const Color(0xFF10B981), // Emerald
          ),
          _NavItemData(
            label: AppLocalizations.text('Thông báo', en: 'Notifications'),
            icon: Icons.notifications_rounded,
            color: const Color(0xFFF59E0B), // Amber
            badgeCount: unreadCount,
          ),
          _NavItemData(
            label: AppLocalizations.text('Cá nhân', en: 'Profile'),
            icon: Icons.person_rounded,
            color: const Color(0xFF8B5CF6), // Royal Purple
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(items.length, (index) {
                  final isSelected = selectedIndex == index;
                  final item = items[index];

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashFactory: NoSplash.splashFactory,
                        highlightColor: Colors.transparent,
                        onTap: () => onTap(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSelected ? 15 : 9,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? item.color.withValues(alpha: isDark ? 0.28 : 0.16)
                                      : item.color.withValues(alpha: isDark ? 0.10 : 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 22,
                                      color: isSelected
                                          ? item.color
                                          : item.color.withValues(alpha: 0.85),
                                    ),
                                    if (item.badgeCount != null && item.badgeCount! > 0)
                                      Positioned(
                                        top: -5,
                                        right: -9,
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 17,
                                            minHeight: 17,
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                                height: 1.05,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected
                                      ? item.color
                                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final Color color;
  final int? badgeCount;

  _NavItemData({
    required this.label,
    required this.icon,
    required this.color,
    this.badgeCount,
  });
}
