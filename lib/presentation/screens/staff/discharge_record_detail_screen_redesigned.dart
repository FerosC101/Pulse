// lib/presentation/screens/staff/discharge_record_detail_screen_redesigned.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/data/models/patient_model.dart';
import 'package:intl/intl.dart';

class DischargeRecordDetailScreenRedesigned extends StatelessWidget {
  final PatientModel patient;

  const DischargeRecordDetailScreenRedesigned({
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
      backgroundColor: const Color(0xFFF7F8F3), // Off-white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002C3E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Record Details',
          style: GoogleFonts.openSansCondensed(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF002C3E), // Navy
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Overview Section
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Patient Overview',
                    style: GoogleFonts.openSansCondensed(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E), // Navy
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Avatar and Name
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[600],
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.fullName,
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF002C3E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${patient.age} years old',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Patient Info
                  _buildInfoRow('Gender', patient.gender),
                  if (patient.bloodType != null)
                    _buildInfoRow('Blood Type', patient.bloodType!),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Admission Summary Section
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Admission Summary',
                    style: GoogleFonts.openSansCondensed(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E), // Navy
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Department', patient.department),
                  _buildInfoRow(
                    'Admission Date',
                    admissionDate != null
                        ? DateFormat('MMM d, y - hh:mm a').format(admissionDate)
                        : 'N/A',
                  ),
                  _buildInfoRow(
                    'Discharge Date',
                    dischargeDate != null
                        ? DateFormat('MMM d, y - hh:mm a').format(dischargeDate)
                        : 'N/A',
                  ),
                  _buildInfoRow('Length of Stay', lengthOfStay),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Discharge Information Section
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Discharge Information',
                    style: GoogleFonts.openSansCondensed(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E), // Navy
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Discharge Date',
                    dischargeDate != null
                        ? DateFormat('MMM d, y - hh:mm a').format(dischargeDate)
                        : 'N/A',
                  ),
                  _buildInfoRow('Length of Stay', lengthOfStay),
                  _buildInfoRow('Status', _formatStatus(patient.status)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Primary Physician Section
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Primary Physician',
                    style: GoogleFonts.openSansCondensed(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E), // Navy
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Physician Name', 'Dr. [Not Available]'),
                  _buildInfoRow('Specialization', patient.department),
                  _buildInfoRow('Contact', '[Not Available]'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Discharge Summary Section
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Discharge Summary',
                    style: GoogleFonts.openSansCondensed(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E), // Navy
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Medical Summary
                  Text(
                    'Medical Summary',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      patient.notes ?? 'No discharge summary available.',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF002C3E),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Follow-up Instructions Section
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Follow-up Instructions',
                    style: GoogleFonts.openSansCondensed(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E), // Navy
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Post-Discharge Care',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFollowUpItem('1. Schedule follow-up appointment within 7-14 days'),
                  _buildFollowUpItem('2. Continue prescribed medications as directed'),
                  _buildFollowUpItem('3. Rest and avoid strenuous activities'),
                  _buildFollowUpItem('4. Monitor for any unusual symptoms'),
                  _buildFollowUpItem('5. Contact hospital immediately if condition worsens'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Emergency Contact Section
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Emergency Contact',
                    style: GoogleFonts.openSansCondensed(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E), // Navy
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Hospital Hotline', '+1 (555) 123-4567'),
                  _buildInfoRow('Emergency', '911'),
                  _buildInfoRow('Department Contact', '+1 (555) 987-6543'),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF002C3E), // Navy
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF10B981),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF002C3E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
