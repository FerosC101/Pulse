// lib/presentation/screens/staff/tabs/queue_tab_redesigned.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/data/models/patient_model.dart';
import 'package:pulse/presentation/providers/queue_provider.dart';
import 'package:pulse/presentation/screens/staff/widgets/queue_item_card_redesigned.dart';
import 'package:pulse/presentation/screens/staff/widgets/add_to_queue_dialog_redesigned.dart';

class QueueTabRedesigned extends ConsumerWidget {
  final String hospitalId;

  const QueueTabRedesigned({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueStreamProvider(hospitalId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3), // Off-white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Patient Queue',
          style: GoogleFonts.openSansCondensed(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF002C3E), // Navy
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Queue count header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                queueAsync.when(
                  data: (queue) => Text(
                    '${queue.length} waiting',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  loading: () => Text(
                    '...',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Queue List
          Expanded(
            child: queueAsync.when(
              data: (queue) {
                if (queue.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.queue_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No patients in queue',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort by triage level
                final sortedQueue = List.from(queue);
                sortedQueue.sort((a, b) {
                  final priorityOrder = {
                    TriageLevel.critical: 0,
                    TriageLevel.urgent: 1,
                    TriageLevel.semiUrgent: 2,
                    TriageLevel.nonUrgent: 3,
                  };
                  return (priorityOrder[a.triageLevel] ?? 99)
                      .compareTo(priorityOrder[b.triageLevel] ?? 99);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedQueue.length,
                  itemBuilder: (context, index) {
                    return QueueItemCardRedesigned(
                      queueItem: sortedQueue[index],
                      position: index + 1,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002C3E)),
                ),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Error: $error',
                  style: GoogleFonts.dmSans(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddToQueueDialogRedesigned(hospitalId: hospitalId),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Add to queue',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF002C3E), // Navy
        foregroundColor: Colors.white,
      ),
    );
  }
}
