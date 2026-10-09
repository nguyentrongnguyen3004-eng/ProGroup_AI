import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GovernanceSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hint;

  const GovernanceSearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Tìm kiếm',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        isDense: true,
      ),
    );
  }
}

class GovernanceStatusChip extends StatelessWidget {
  final String label;

  const GovernanceStatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final normalized = label.toLowerCase();
    final color =
        normalized.contains('học') ||
            normalized.contains('hoạt') ||
            normalized.contains('đã')
        ? AppTheme.successColor
        : normalized.contains('chưa') || normalized.contains('chờ')
        ? AppTheme.warningColor
        : AppTheme.grayColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class GovernanceInfoLine extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const GovernanceInfoLine({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppTheme.grayColor),
            const SizedBox(width: 9),
          ],
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.grayColor),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GovernanceActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const GovernanceActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.grayColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppTheme.grayColor),
            ],
          ),
        ),
      ),
    );
  }
}

class GovernanceStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const GovernanceStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = AppTheme.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.grayColor),
            ),
          ],
        ),
      ),
    );
  }
}
