// lib/presentation/screens/staff/widgets/change_priority_dialog_redesigned.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/data/models/patient_model.dart';

class ChangePriorityDialogRedesigned extends StatefulWidget {
  final TriageLevel currentPriority;
  final String patientName;

  const ChangePriorityDialogRedesigned({
    super.key,
    required this.currentPriority,
    required this.patientName,
  });

  @override
  State<ChangePriorityDialogRedesigned> createState() => _ChangePriorityDialogRedesignedState();
}

class _ChangePriorityDialogRedesignedState extends State<ChangePriorityDialogRedesigned> {
  late TriageLevel _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.currentPriority;
  }

  Color _getPriorityColor(TriageLevel level) {
    switch (level) {
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
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Change Priority',
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E), // Navy
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF002C3E)),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...TriageLevel.values.map((level) {
                      final color = _getPriorityColor(level);
                      final isSelected = _selectedPriority == level;
                      final isCurrent = level == widget.currentPriority;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedPriority = level);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Radio button
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? color : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    level.displayName,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF002C3E),
                                    ),
                                  ),
                                ),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Current',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF002C3E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF002C3E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _selectedPriority),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF002C3E), // Navy
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Update',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
