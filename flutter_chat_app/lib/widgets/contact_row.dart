import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';

/// Contact row widget for chat list
class ContactRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final DateTime? time;
  final bool isGroup;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int unreadCount;
  final String? avatarUrl;

  const ContactRow({
    super.key,
    required this.name,
    required this.subtitle,
    this.time,
    this.isGroup = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.unreadCount = 0,
    this.avatarUrl,
  });

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primaryLight.withOpacity(0.2) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isGroup 
                        ? AppColors.accent.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.2),
                    backgroundImage: avatarUrl != null 
                        ? NetworkImage(avatarUrl!) 
                        : null,
                    child: avatarUrl == null
                        ? Icon(
                            isGroup ? Icons.group : Icons.person,
                            color: isGroup ? AppColors.accent : AppColors.primary,
                            size: 28,
                          )
                        : null,
                  ),
                  if (isSelected)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: unreadCount > 0 
                                  ? FontWeight.bold 
                                  : FontWeight.w600,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (time != null)
                          Text(
                            _formatTime(time),
                            style: TextStyle(
                              fontSize: 12,
                              color: unreadCount > 0 
                                  ? AppColors.primary 
                                  : AppColors.textLight,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: unreadCount > 0 
                                  ? AppColors.text 
                                  : AppColors.textSecondary,
                              fontWeight: unreadCount > 0 
                                  ? FontWeight.w500 
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
