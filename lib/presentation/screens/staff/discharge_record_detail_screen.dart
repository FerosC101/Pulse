// lib/presentation/screens/staff/discharge_record_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/data/models/patient_model.dart';
import 'package:intl/intl.dart';

class DischargeRecordDetailScreen extends StatelessWidget {
  final PatientModel patient;

  const DischargeRecordDetailScreen({
    super.key,
    required this.patient,
  });

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

  @override
  Widget build(BuildContext context) {
    final admissionDate = patient.admissionDate;
    final dischargeDate = patient.dischargeDate;

    // Calculate length of stay
    String lengthOfStay = 'N/A';
    if (admissionDate != null && dischargeDate != null) {
      final duration = dischargeDate.difference(admissionDate);
      if (duration.inDays > 0) {
        lengthOfStay = '${duration.inDays} days';
      } else if (duration.inHours > 0) {
        lengthOfStay = '${duration.inHours} hours';
      } else {
        lengthOfStay = '${duration.inMinutes} minutes';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discharge Record Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // TODO: Implement print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Print functionality coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header
            _buildSectionCard(
              icon: Icons.person,
              title: 'Patient Information',
              color: AppColors.primary,
              child: Column(
                children: [
                  _buildDetailRow('Full Name', patient.fullName),
                  _buildDetailRow('Age', '${patient.age} years'),
                  _buildDetailRow('Gender', patient.gender),
                  if (patient.bloodType != null)
                    _buildDetailRow('Blood Type', patient.bloodType!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Admission Details
            _buildSectionCard(
              icon: Icons.calendar_today,
              title: 'Admission Details',
              color: AppColors.info,
              child: Column(
                children: [
                  _buildDetailRow(
                    'Admission Date',
                    admissionDate != null
                        ? DateFormat('MMMM d, y - hh:mm a').format(admissionDate)
                        : 'N/A',
                  ),
                  _buildDetailRow('Department', patient.department),
                  if (patient.bedNumber != null)
                    _buildDetailRow('Bed Number', patient.bedNumber!),
                  _buildDetailRow('Initial Condition', patient.condition),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Discharge Details
            _buildSectionCard(
              icon: Icons.exit_to_app,
              title: 'Discharge Information',
              color: AppColors.success,
              child: Column(
                children: [
                  _buildDetailRow(
                    'Discharge Date',
                    dischargeDate != null
                        ? DateFormat('MMMM d, y - hh:mm a').format(dischargeDate)
                        : 'N/A',
                  ),
                  _buildDetailRow('Length of Stay', lengthOfStay),
                  _buildDetailRow('Status', _formatStatus(patient.status)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Primary Physician (Mock data - enhance based on your data model)
            _buildSectionCard(
              icon: Icons.medical_services,
              title: 'Primary Physician',
              color: AppColors.warning,
              child: Column(
                children: [
                  _buildDetailRow('Physician Name', 'Dr. [Not Available]'),
                  _buildDetailRow('Specialization', patient.department),
                  _buildDetailRow('Contact', '[Not Available]'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Discharge Summary
            _buildSectionCard(
              icon: Icons.description,
              title: 'Discharge Summary',
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medical Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patient.notes ?? 'No discharge summary available.',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  if (patient.notes != null && patient.notes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    const Text(
                      'Diagnosis',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      patient.condition,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Follow-up Instructions
            _buildSectionCard(
              icon: Icons.event_note,
              title: 'Follow-up Instructions',
              color: AppColors.info,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Post-Discharge Care',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFollowUpItem(
                    '1. Schedule follow-up appointment within 7-14 days',
                  ),
                  _buildFollowUpItem(
                    '2. Continue prescribed medications as directed',
                  ),
                  _buildFollowUpItem(
                    '3. Rest and avoid strenuous activities',
                  ),
                  _buildFollowUpItem(
                    '4. Monitor for any unusual symptoms',
                  ),
                  _buildFollowUpItem(
                    '5. Contact hospital immediately if condition worsens',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Emergency Contact
            _buildSectionCard(
              icon: Icons.phone,
              title: 'Emergency Contact',
              color: AppColors.error,
              child: Column(
                children: [
                  _buildDetailRow('Hospital Hotline', '+1 (555) 123-4567'),
                  _buildDetailRow('Emergency', '911'),
                  _buildDetailRow('Department Contact', '+1 (555) 987-6543'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
