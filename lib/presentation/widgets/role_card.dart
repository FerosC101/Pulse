import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Role selection card widget
class RoleCard extends StatelessWidget {
  final String role;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    Key? key,
    required this.role,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? AppColors.white : AppColors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              role,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? AppColors.white : AppColors.darkText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
