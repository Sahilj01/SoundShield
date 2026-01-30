import 'package:flutter/material.dart';
import '../config/constants.dart';

/// Cell widget for settings lists
class Cell extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  const Cell({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    this.onTap,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor ?? AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                )
              : null,
          trailing: trailing ?? (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: AppColors.textLight,
                )
              : null),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 60,
            color: AppColors.borderLight,
          ),
      ],
    );
  }
}
