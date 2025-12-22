// lib/presentation/screens/staff/widgets/patient_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/data/models/patient_model.dart';
import 'package:intl/intl.dart';

class PatientDetailDialog extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailDialog({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Patient Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Info Card
                    _buildInfoCard(
                      title: 'Personal Information',
                      icon: Icons.person,
                      color: AppColors.primary,
                      children: [
                        _buildInfoRow('Full Name', patient.fullName),
                        _buildInfoRow('Age', '${patient.age} years'),
                        _buildInfoRow('Gender', patient.gender),
                        if (patient.bloodType != null)
                          _buildInfoRow('Blood Type', patient.bloodType!),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Admission Info
                    _buildInfoCard(
                      title: 'Admission Information',
                      icon: Icons.local_hospital,
                      color: AppColors.info,
                      children: [
                        _buildInfoRow('Department', patient.department),
                        if (patient.bedNumber != null)
                          _buildInfoRow('Bed Number', patient.bedNumber!),
                        if (patient.roomNumber != null)
                          _buildInfoRow('Room Number', patient.roomNumber!),
                        _buildInfoRow(
                          'Admission Date',
                          DateFormat('MMM d, y - hh:mm a').format(patient.admissionDate),
                        ),
                        _buildInfoRow('Status', _formatStatus(patient.status)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Medical Info
                    _buildInfoCard(
                      title: 'Medical Information',
                      icon: Icons.medical_information,
                      color: AppColors.warning,
                      children: [
                        _buildInfoRow('Condition', patient.condition),
                        if (patient.triageLevel != null)
                          _buildInfoRow('Triage Level', patient.triageLevel!.displayName),
                        if (patient.notes != null && patient.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notes:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  patient.notes!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(PatientStatus status) {
    switch (status) {
      case PatientStatus.admitted:
        return 'Admitted';
      case PatientStatus.discharged:
        return 'Discharged';
      case PatientStatus.transferred:
        return 'Transferred';
      case PatientStatus.inQueue:
        return 'In Queue';
    }
  }
}
