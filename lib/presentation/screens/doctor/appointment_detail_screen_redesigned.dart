import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/data/models/appointment_model.dart';
import 'package:pulse/data/models/appointment_status.dart';
import 'package:pulse/presentation/providers/appointment_provider.dart';
import 'package:intl/intl.dart';

/// Redesigned Appointment Detail Screen
/// Following Pulse Design System
class AppointmentDetailScreenRedesigned extends ConsumerStatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreenRedesigned({
    super.key,
    required this.appointment,
  });

  @override
  ConsumerState<AppointmentDetailScreenRedesigned> createState() =>
      _AppointmentDetailScreenRedesignedState();
}

class _AppointmentDetailScreenRedesignedState
    extends ConsumerState<AppointmentDetailScreenRedesigned> {
  final TextEditingController _notesController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.appointment.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3), // Off-white background
      body: SafeArea(
        child: Column(
          children: [
            // Gradient Header
            _buildGradientHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Information Card
                    _buildPatientInfoCard(),
                    const SizedBox(height: 16),
                    
                    // Appointment Details Card
                    _buildAppointmentDetailsCard(),
                    const SizedBox(height: 16),
                    
                    // Notes Section
                    _buildNotesSection(),
                    const SizedBox(height: 16),
                    
                    // Status & Actions
                    _buildStatusAndActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header
  Widget _buildGradientHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF002C3E)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(
            'Appointment Details',
            style: GoogleFonts.openSansCondensed(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF002C3E),
            ),
          ),
        ],
      ),
    );
  }

  /// Patient Information Card
  Widget _buildPatientInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                color: Color(0xFF002C3E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Patient Information',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF002C3E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSimpleInfoRow('Name:', widget.appointment.patientName),
          const SizedBox(height: 12),
          _buildSimpleInfoRow('Phone:', widget.appointment.patientPhone ?? '0902103214441'),
          const SizedBox(height: 12),
          _buildSimpleInfoRow('Email:', widget.appointment.patientEmail ?? 'josh@gmail.com'),
        ],
      ),
    );
  }

  /// Appointment Details Card
  Widget _buildAppointmentDetailsCard() {
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('MMMM d, yyyy');
    final endTime = widget.appointment.dateTime.add(Duration(minutes: widget.appointment.durationMinutes));
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFF002C3E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Appointment Overview',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF002C3E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSimpleInfoRow('Date:', dateFormat.format(widget.appointment.dateTime)),
          const SizedBox(height: 12),
          _buildSimpleInfoRow('Time:', '${timeFormat.format(widget.appointment.dateTime)} - ${timeFormat.format(endTime)}'),
          const SizedBox(height: 12),
          _buildSimpleInfoRow('Type:', widget.appointment.type?.toString() ?? 'Consultation'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status:',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.appointment.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(widget.appointment.status),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7444E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFF7444E)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: const Color(0xFF002C3E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Patient Complaint Section
  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medical_information_outlined,
                color: Color(0xFF002C3E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Patient Complaint',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF002C3E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Chief Complaint:',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.appointment.chiefComplaint ?? 'No complaint recorded',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF1A3A4A),
            ),
          ),
        ],
      ),
    );
  }

  /// Doctor's Notes and Prescription Sections plus Actions
  Widget _buildStatusAndActions() {
    return Column(
      children: [
        // Doctor's Notes
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    color: Color(0xFF002C3E),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Doctor\'s Notes',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.appointment.notes?.isEmpty ?? true
                    ? 'No notes yet'
                    : widget.appointment.notes!,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: (widget.appointment.notes?.isEmpty ?? true)
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Prescription
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.medication_outlined,
                    color: Color(0xFF002C3E),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Prescription',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.appointment.prescription?.isEmpty ?? true
                    ? 'No prescription yet'
                    : widget.appointment.prescription!,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: (widget.appointment.prescription?.isEmpty ?? true)
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Action Buttons
        if (widget.appointment.status == AppointmentStatus.confirmed)
          ElevatedButton(
            onPressed: () => _updateStatus(AppointmentStatus.completed),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 52),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Mark as Completed',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        
        if (widget.appointment.status == AppointmentStatus.confirmed) const SizedBox(height: 12),
        
        if (widget.appointment.status == AppointmentStatus.confirmed)
          ElevatedButton(
            onPressed: () => _updateStatus(AppointmentStatus.noShow),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7444E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 52),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off_outlined, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Mark as No Show',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        
        if (widget.appointment.status == AppointmentStatus.confirmed) const SizedBox(height: 12),
        
        if (widget.appointment.status != AppointmentStatus.completed &&
            widget.appointment.status != AppointmentStatus.cancelled)
          ElevatedButton(
            onPressed: () => _showCancelDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7444E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 52),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cancel_outlined, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Cancel Appointment',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'PENDING';
      case AppointmentStatus.confirmed:
        return 'CONFIRMED';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'CANCELLED';
      case AppointmentStatus.noShow:
        return 'NO SHOW';
      default:
        return 'UNKNOWN';
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A3A4A),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A3A4A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF1A3A4A),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _saveNotes() async {
    try {
      await ref.read(appointmentControllerProvider.notifier).updateAppointment(
            widget.appointment.id,
            {'doctorNotes': _notesController.text},
          );
      
      setState(() {
        _isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notes saved successfully',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save notes: $e',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateStatus(AppointmentStatus newStatus) async {
    try {
      await ref.read(appointmentControllerProvider.notifier).updateStatus(
            widget.appointment.id,
            newStatus,
          );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment status updated',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update status: $e',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Appointment',
          style: GoogleFonts.openSansCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF002C3E),
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFF002C3E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No, Keep It',
              style: GoogleFonts.dmSans(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(AppointmentStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7444E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
  }
}
