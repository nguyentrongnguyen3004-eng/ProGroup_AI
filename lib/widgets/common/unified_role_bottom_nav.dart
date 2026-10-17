import 'package:flutter/material.dart';

class UnifiedRoleNavItem {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color color;
  final int badgeCount;

  const UnifiedRoleNavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.color,
    this.badgeCount = 0,
  });
}

class UnifiedRoleBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<UnifiedRoleNavItem> items;

  const UnifiedRoleBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex = (currentIndex >= 0 && currentIndex < items.length)
        ? currentIndex
        : 0;

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
                    onTap: () => onChanged(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                if (item.badgeCount > 0)
                                  Positioned(
                                    top: -5,
                                    right: -9,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
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
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? item.color
                                  : (isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF475569)),
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
