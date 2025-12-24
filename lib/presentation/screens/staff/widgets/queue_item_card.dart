// lib/presentation/screens/staff/widgets/queue_item_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/data/models/queue_model.dart';
import 'package:pulse/data/models/patient_model.dart';
import 'package:pulse/presentation/providers/queue_provider.dart';
import 'package:pulse/presentation/screens/staff/widgets/patient_admission_dialog.dart';
import 'package:pulse/presentation/screens/staff/widgets/change_priority_dialog.dart';

class QueueItemCard extends ConsumerWidget {
  final QueueModel queueItem;
  final int position;

  const QueueItemCard({
    super.key,
    required this.queueItem,
    required this.position,
  });

  Color _getTriageColor() {
    switch (queueItem.triageLevel) {
      case TriageLevel.critical:
        return AppColors.error;
      case TriageLevel.urgent:
        return Colors.orange;
      case TriageLevel.semiUrgent:
        return Colors.amber;
      case TriageLevel.nonUrgent:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final triageColor = _getTriageColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: triageColor.withOpacity(0.3), width: 2),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Position number
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: triageColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '#$position',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: triageColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Patient info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              queueItem.patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: triageColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              queueItem.triageLevel.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: triageColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('${queueItem.age}y • ${queueItem.gender}'),
                          const SizedBox(width: 16),
                          Icon(Icons.local_hospital, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              queueItem.department,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        queueItem.condition,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Waiting: ${queueItem.waitTimeString}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Menu button
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'admit',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle, size: 20),
                          SizedBox(width: 8),
                          Text('Admit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'priority',
                      child: Row(
                        children: [
                          Icon(Icons.priority_high, size: 20),
                          SizedBox(width: 8),
                          Text('Change Priority'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle, size: 20, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Remove', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'admit') {
                      // Admit patient from queue
                      showDialog(
                        context: context,
                        builder: (context) => PatientAdmissionDialog(
                          hospitalId: queueItem.hospitalId,
                        ),
                      );
                    } else if (value == 'priority') {
                      // Change triage priority
                      final newPriority = await showDialog<TriageLevel>(
                        context: context,
                        builder: (context) => ChangePriorityDialog(
                          currentPriority: queueItem.triageLevel,
                          patientName: queueItem.patientName,
                        ),
                      );

                      if (newPriority != null && context.mounted) {
                        try {
                          await ref
                              .read(queueControllerProvider.notifier)
                              .updatePriority(queueItem.id, newPriority.name);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Priority updated successfully'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            } else if (value == 'remove') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove from Queue'),
                  content: Text('Remove ${queueItem.patientName} from queue?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                try {
                  await ref
                      .read(queueControllerProvider.notifier)
                      .removeFromQueue(queueItem.id);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from queue'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              ),
            ],
          ),
          // Critical status indicator (vertical text on right edge)
          if (queueItem.triageLevel == TriageLevel.critical)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 20,
                decoration: BoxDecoration(
                  color: triageColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'CRITICAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}