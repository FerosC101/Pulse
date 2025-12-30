// lib/presentation/screens/staff/widgets/queue_item_card_redesigned.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/data/models/queue_model.dart';
import 'package:pulse/data/models/patient_model.dart';
import 'package:pulse/presentation/providers/queue_provider.dart';
import 'package:pulse/presentation/screens/staff/widgets/emergency_admission_dialog.dart';
import 'package:pulse/presentation/screens/staff/widgets/change_priority_dialog_redesigned.dart';

class QueueItemCardRedesigned extends ConsumerWidget {
  final QueueModel queueItem;
  final int position;

  const QueueItemCardRedesigned({
    super.key,
    required this.queueItem,
    required this.position,
  });

  Color _getTriageColor() {
    switch (queueItem.triageLevel) {
      case TriageLevel.critical:
        return const Color(0xFFF7444E); // Primary Red
      case TriageLevel.urgent:
        return Colors.orange;
      case TriageLevel.semiUrgent:
        return Colors.amber;
      case TriageLevel.nonUrgent:
        return const Color(0xFF10B981); // Green
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final triageColor = _getTriageColor();
    final isCurrentPriority = queueItem.triageLevel == TriageLevel.critical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Info Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        queueItem.patientName,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF002C3E), // Navy
                        ),
                      ),
                    ),
                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: triageColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$position',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Patient Details
                Text(
                  '${queueItem.age}y ${queueItem.gender} | ${queueItem.triageLevel.displayName}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  queueItem.condition,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Waiting: ${queueItem.waitTimeString}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: 'Admit',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EmergencyAdmissionDialog(
                          hospitalId: queueItem.hospitalId,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: 'Change Priority',
                    onTap: () async {
                      final newPriority = await showDialog<TriageLevel>(
                        context: context,
                        builder: (context) => ChangePriorityDialogRedesigned(
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
                              SnackBar(
                                content: Text(
                                  'Priority updated successfully',
                                  style: GoogleFonts.dmSans(),
                                ),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error: $e',
                                  style: GoogleFonts.dmSans(),
                                ),
                                backgroundColor: const Color(0xFFF7444E),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: 'Remove',
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            'Remove from Queue',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF002C3E),
                            ),
                          ),
                          content: Text(
                            'Remove ${queueItem.patientName} from queue?',
                            style: GoogleFonts.dmSans(),
                          ),
                          actions: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF002C3E),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.dmSans(
                                  color: const Color(0xFF002C3E),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF7444E),
                              ),
                              child: Text(
                                'Remove',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                ),
                              ),
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
                              SnackBar(
                                content: Text(
                                  'Removed from queue',
                                  style: GoogleFonts.dmSans(),
                                ),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error: $e',
                                  style: GoogleFonts.dmSans(),
                                ),
                                backgroundColor: const Color(0xFFF7444E),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF002C3E), // Navy
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
