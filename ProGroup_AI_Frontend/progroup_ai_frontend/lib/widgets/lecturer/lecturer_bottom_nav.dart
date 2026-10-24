import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class LecturerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final int notificationCount;
  final VoidCallback? onGroupsTap;

  const LecturerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.notificationCount,
    this.onGroupsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex =
        currentIndex >= 0 && currentIndex < 5 ? currentIndex : 0;

    final items = [
      _NavItemData(
        label: AppLocalizations.text('Trang chủ', en: 'Home'),
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_rounded,
        color: const Color(0xFF2563EB), // Vibrant Blue
      ),
      _NavItemData(
        label: AppLocalizations.text('Lớp học phần', en: 'Courses'),
        activeIcon: Icons.school_rounded,
        inactiveIcon: Icons.school_rounded,
        color: const Color(0xFF6366F1), // Indigo
      ),
      _NavItemData(
        label: AppLocalizations.text('Nhóm', en: 'Groups'),
        activeIcon: Icons.groups_rounded,
        inactiveIcon: Icons.groups_rounded,
        color: const Color(0xFF10B981), // Emerald Green
      ),
      _NavItemData(
        label: AppLocalizations.text('Thông báo', en: 'Notifications'),
        activeIcon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_rounded,
        color: const Color(0xFFF59E0B), // Amber / Warm Orange
        badgeCount: notificationCount,
      ),
      _NavItemData(
        label: AppLocalizations.text('Cá nhân', en: 'Profile'),
        activeIcon: Icons.person_rounded,
        inactiveIcon: Icons.person_rounded,
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
                    onTap: () {
                      if (index == 2 && onGroupsTap != null) {
                        onGroupsTap!.call();
                        return;
                      }
                      onChanged(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pill container with active color & colorful unselected icon
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 15 : 9,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? item.color.withValues(
                                      alpha: isDark ? 0.28 : 0.16,
                                    )
                                  : item.color.withValues(
                                      alpha: isDark ? 0.10 : 0.08,
                                    ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  isSelected
                                      ? item.activeIcon
                                      : item.inactiveIcon,
                                  size: 22,
                                  color: isSelected
                                      ? item.color
                                      : item.color.withValues(alpha: 0.85),
                                ),
                                if (item.badgeCount != null &&
                                    item.badgeCount! > 0)
                                  Positioned(
                                    top: -5,
                                    right: -9,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 17,
                                        minHeight: 17,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFEF4444),
                                            Color(0xFFDC2626),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                              : Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        item.badgeCount! > 9
                                            ? '9+'
                                            : '${item.badgeCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Label strictly fitted on 1 single line with FittedBox
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.label,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? item.color
                                      : (isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B)),
                                  letterSpacing: -0.2,
                                ),
                              ),
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
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color color;
  final int? badgeCount;

  const _NavItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.color,
    this.badgeCount,
  });
}
