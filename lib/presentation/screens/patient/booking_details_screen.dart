// lib/presentation/screens/patient/booking_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/data/models/appointment_model.dart';
import 'package:pulse/data/models/appointment_status.dart';
import 'package:pulse/data/models/appointment_type.dart';
import 'package:pulse/data/models/doctor_schedule_model.dart';
import 'package:pulse/data/models/hospital_model.dart';
import 'package:pulse/data/models/user_model.dart';
import 'package:pulse/presentation/providers/appointment_provider.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';
import 'package:pulse/presentation/providers/schedule_provider.dart';
import 'package:pulse/presentation/providers/user_provider.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final HospitalModel hospital;
  final UserModel doctor;

  const BookingDetailsScreen({
    super.key,
    required this.hospital,
    required this.doctor,
  });

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedTimeSlot;
  AppointmentType? _selectedType;
  
  final _chiefComplaintController = TextEditingController();
  final _symptomsController = TextEditingController();
  
  bool _isBooking = false;
  
  // Calendar state
  DateTime _displayedMonth = DateTime.now();

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  bool get _canBook {
    return _selectedDate != null &&
        _selectedTime != null &&
        _selectedType != null &&
        _chiefComplaintController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
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
          'Book Appointment',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
      ),
      body: ClipRect(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Doctor Profile Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${widget.doctor.fullName}',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.doctor.specialty ?? 'General Practitioner',
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
            ),

            const SizedBox(height: 24),

            // Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                clipBehavior: Clip.hardEdge,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Month/Year Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              _displayedMonth = DateTime(
                                _displayedMonth.year,
                                _displayedMonth.month - 1,
                              );
                            });
                          },
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_displayedMonth),
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              _displayedMonth = DateTime(
                                _displayedMonth.year,
                                _displayedMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Weekday Headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                          .map((day) => SizedBox(
                                width: 40,
                                child: Center(
                                  child: Text(
                                    day,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    
                    // Calendar Grid
                    _buildCalendarGrid(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Time Selection
            if (_selectedDate != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildTimeSlots(),
              ),
              const SizedBox(height: 24),
            ],

            // Appointment Type
            if (_selectedTime != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildFormField(
                  label: 'Appointment Type',
                  child: DropdownButtonFormField<AppointmentType>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      hintText: 'Select appointment type',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppColors.darkText,
                    ),
                    items: AppointmentType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getAppointmentTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Chief Complaints
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildFormField(
                  label: 'Chief Complaints',
                  child: TextField(
                    controller: _chiefComplaintController,
                    maxLines: 4,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppColors.darkText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Describe your main health concern in detail...',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Symptoms (Optional)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildFormField(
                  label: 'Symptoms (Optional)',
                  child: TextField(
                    controller: _symptomsController,
                    maxLines: 4,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppColors.darkText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'List any symptoms you\'re experiencing...',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _selectedTime != null
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _canBook && !_isBooking ? _bookAppointment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkText,
                      disabledBackgroundColor: AppColors.darkText.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isBooking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Book Appointment',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    int firstWeekday = firstDayOfMonth.weekday;
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    List<Widget> dayWidgets = [];
    
    // Add empty spaces for days before the first day of the month
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }
    
    // Add all days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isSelected = _selectedDate != null &&
          dateOnly.year == _selectedDate!.year &&
          dateOnly.month == _selectedDate!.month &&
          dateOnly.day == _selectedDate!.day;
      final isToday = dateOnly == todayDate;
      final isPast = dateOnly.isBefore(todayDate);

      dayWidgets.add(
        GestureDetector(
          onTap: isPast
              ? null
              : () {
                  setState(() {
                    _selectedDate = date;
                    _selectedTime = null;
                    _selectedTimeSlot = null;
                  });
                },
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                  color: isPast
                      ? AppColors.textSecondary.withOpacity(0.3)
                      : isSelected
                          ? Colors.white
                          : AppColors.darkText,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Organize into rows of 7
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayWidgets.sublist(
            i,
            i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
          ),
        ),
      );
      if (i + 7 < dayWidgets.length) {
        rows.add(const SizedBox(height: 4));
      }
    }

    return Column(children: rows);
  }

  Widget _buildTimeSlots() {
    final scheduleAsync = ref.watch(doctorScheduleProvider(widget.doctor.id));

    return scheduleAsync.when(
      data: (schedules) {
        if (schedules.isEmpty || _selectedDate == null) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No available time slots',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        // Get schedule for selected day (1 = Monday, 7 = Sunday)
        final dayOfWeek = _selectedDate!.weekday;
        final todaySchedule = schedules.where((s) => s.dayOfWeek == dayOfWeek && s.isAvailable).toList();
        
        if (todaySchedule.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Doctor not available on this day',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        // Generate time slots based on schedule
        final timeSlots = _generateTimeSlots(todaySchedule.first);

        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.darkText, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Select Time',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = slot;
                        final parts = slot.split(':');
                        _selectedTime = TimeOfDay(
                          hour: int.parse(parts[0]),
                          minute: int.parse(parts[1]),
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.darkText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Error loading schedule',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
  }

  List<String> _generateTimeSlots(DoctorScheduleModel schedule) {
    // Parse start and end times
    final startParts = schedule.startTime.split(':');
    final endParts = schedule.endTime.split(':');
    final startHour = int.parse(startParts[0]);
    final endHour = int.parse(endParts[0]);
    
    // Generate slots based on appointment duration
    List<String> slots = [];
    for (int hour = startHour; hour < endHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      if (schedule.appointmentDuration <= 30 && hour < endHour - 1) {
        slots.add('${hour.toString().padLeft(2, '0')}:30');
      }
    }
    return slots;
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  String _getAppointmentTypeName(AppointmentType type) {
    switch (type) {
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.followUp:
        return 'Follow-up';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.checkup:
        return 'Check-up';
    }
  }

  Future<void> _bookAppointment() async {
    if (!_canBook || _isBooking) return;

    setState(() {
      _isBooking = true;
    });

    try {
      // Get current user from Firebase Auth directly
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        throw Exception('Please login to book an appointment');
      }
      
      // Get user data directly from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }
      
      final currentUserData = UserModel.fromMap(userDoc.data()!, currentUser.uid);

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final appointment = AppointmentModel(
        id: '',
        patientId: currentUser.uid,
        patientName: currentUserData.fullName,
        patientPhone: currentUserData.phoneNumber ?? '',
        patientEmail: currentUserData.email,
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.fullName,
        doctorSpecialty: widget.doctor.specialty ?? 'General Practitioner',
        hospitalId: widget.hospital.id,
        hospitalName: widget.hospital.name,
        dateTime: dateTime,
        type: _selectedType!,
        status: AppointmentStatus.pending,
        chiefComplaint: _chiefComplaintController.text.trim(),
        symptoms: _symptomsController.text.trim().isEmpty 
            ? null 
            : _symptomsController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(appointmentRepositoryProvider).createAppointment(appointment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment booked successfully!',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigate back to hospital details or home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to book appointment: ${e.toString().replaceAll('Exception: ', '')}',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }
}
