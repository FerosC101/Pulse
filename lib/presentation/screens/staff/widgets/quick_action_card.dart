// lib/presentation/screens/staff/widgets/quick_action_card.dart
import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    this.icon,
    this.iconAsset,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: iconAsset != null
                    ? Image.asset(
                        iconAsset!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        color: color,
                        errorBuilder: (context, error, stackTrace) => Icon(icon ?? Icons.circle, color: color, size: 32),
                      )
                    : Icon(icon ?? Icons.circle, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}