import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isTappable;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isTappable = false,
    this.onTap,
    this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    return GlassCard(
      onTap: isTappable ? onTap : null,
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor ?? Colors.blue,
          ),
          const SizedBox(height: AppTheme.xs),
          Text(
            value,
            style: AppTheme.title2.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.primaryText(brightness),
            ),
          ),
          const SizedBox(height: AppTheme.xxxs),
          Text(
            title,
            style: AppTheme.caption1.copyWith(
              color: AppTheme.secondaryText(brightness),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DetailedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? valueColor;
  final Widget? trailing;

  const DetailedStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.sm),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.blue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor ?? Colors.blue,
            ),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.callout.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText(brightness),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTheme.caption1.copyWith(
                      color: AppTheme.secondaryText(brightness),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTheme.title3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppTheme.primaryText(brightness),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(height: 2),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
