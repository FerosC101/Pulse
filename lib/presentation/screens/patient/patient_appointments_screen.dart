// lib/presentation/screens/patient/patient_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/data/models/appointment_model.dart';
import 'package:pulse/data/models/appointment_status.dart' show AppointmentStatus;
import 'package:pulse/presentation/providers/appointment_provider.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class PatientAppointmentsScreen extends ConsumerStatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  ConsumerState<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends ConsumerState<PatientAppointmentsScreen> {
  String _selectedTab = 'all'; // 'all', 'outgoing', 'completed'

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Appointments',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please log in'));
          }

          final appointmentsAsync = ref.watch(patientAppointmentsProvider(user.id));

          return appointmentsAsync.when(
            data: (appointments) {
              // Filter appointments based on selected tab
              List<AppointmentModel> filteredAppointments;
              final now = DateTime.now();
              
              if (_selectedTab == 'outgoing') {
                filteredAppointments = appointments
                    .where((a) => a.dateTime.isAfter(now) && 
                           a.status != AppointmentStatus.completed &&
                           a.status != AppointmentStatus.cancelled)
                    .toList();
              } else if (_selectedTab == 'completed') {
                filteredAppointments = appointments
                    .where((a) => a.status == AppointmentStatus.completed)
                    .toList();
              } else {
                filteredAppointments = appointments;
              }

              return Column(
                children: [
                  // Tab Selector
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(child: _buildTab('All', 'all')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTab('Outgoing', 'outgoing')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTab('Completed', 'completed')),
                      ],
                    ),
                  ),

                  // Appointments List
                  Expanded(
                    child: filteredAppointments.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(patientAppointmentsProvider(user.id));
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredAppointments.length,
                              itemBuilder: (context, index) {
                                return _buildAppointmentCard(
                                  context,
                                  ref,
                                  filteredAppointments[index],
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error: $error',
                style: GoogleFonts.dmSans(),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: GoogleFonts.dmSans(),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkText : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book your first appointment with a doctor',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, WidgetRef ref, AppointmentModel appointment) {
    final isPast = appointment.dateTime.isBefore(DateTime.now());
    final canCancel = !isPast && 
                      appointment.status != AppointmentStatus.completed && 
                      appointment.status != AppointmentStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetails(context, ref, appointment, canCancel),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Name and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Dr. ${appointment.doctorName}',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.status == AppointmentStatus.confirmed 
                        ? 'Confirmed' 
                        : appointment.status.displayName,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Specialty and Hospital
              Text(
                '${appointment.doctorSpecialty} | ${appointment.hospitalName}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Date and Time Badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkText),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      DateFormat('MMMM d, y').format(appointment.dateTime),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkText),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      DateFormat('h:mm a').format(appointment.dateTime),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Main Complaints
              if (appointment.chiefComplaint != null && appointment.chiefComplaint!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.chiefComplaint!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(
    BuildContext context,
    WidgetRef ref,
    AppointmentModel appointment,
    bool canCancel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Appointments',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.darkText),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Info
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColors.textSecondary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. ${appointment.doctorName}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appointment.doctorSpecialty,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Appointment Details Grid
                    _buildDetailRow('Hospital', appointment.hospitalName),
                    _buildDetailRow(
                      'Date',
                      DateFormat('EEEE, MMMM d, y').format(appointment.dateTime),
                    ),
                    _buildDetailRow(
                      'Time',
                      DateFormat('h:mm a').format(appointment.dateTime),
                    ),
                    _buildDetailRow('Type', appointment.type.displayName),
                    _buildDetailRow('Status', appointment.status.displayName),

                    const SizedBox(height: 16),

                    // Chief Complaints Box
                    if (appointment.chiefComplaint != null && appointment.chiefComplaint!.isNotEmpty) ...[
                      Text(
                        'Main Complaints',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          appointment.chiefComplaint!,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.darkText,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    if (appointment.symptoms != null && appointment.symptoms!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Symptoms',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          appointment.symptoms!,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.darkText,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    if (appointment.prescription != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Prescription',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appointment.prescription!,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.darkText,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    if (canCancel) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => _cancelAppointment(context, ref, appointment),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel Appointment',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(
    BuildContext context,
    WidgetRef ref,
    AppointmentModel appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Appointment',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(appointmentControllerProvider.notifier).updateStatus(
              appointment.id,
              AppointmentStatus.cancelled,
            );

        if (context.mounted) {
          Navigator.pop(context); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Appointment cancelled',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error cancelling appointment: $e',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
