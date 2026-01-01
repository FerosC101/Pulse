// lib/presentation/screens/doctor/doctor_schedule_screen_redesigned.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/data/models/doctor_schedule_model.dart';
import 'package:pulse/presentation/providers/schedule_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorScheduleScreenRedesigned extends ConsumerStatefulWidget {
  final String doctorId;
  final String hospitalId;

  const DoctorScheduleScreenRedesigned({
    super.key,
    required this.doctorId,
    required this.hospitalId,
  });

  @override
  ConsumerState<DoctorScheduleScreenRedesigned> createState() => _DoctorScheduleScreenRedesignedState();
}

class _DoctorScheduleScreenRedesignedState extends ConsumerState<DoctorScheduleScreenRedesigned> {
  int _appointmentDuration = 30;
  int _maxAppointments = 16;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(doctorScheduleProvider(widget.doctorId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3), // Off-white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002C3E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Schedule',
          style: GoogleFonts.openSansCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF002C3E),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _createDefaultSchedule(),
            icon: const Icon(Icons.add, color: Color(0xFFF7444E)),
            label: Text(
              'Default',
              style: GoogleFonts.dmSans(
                color: const Color(0xFFF7444E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: scheduleAsync.when(
        data: (schedules) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Set your weekly availability. Patients can book appointments during these times.',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: const Color(0xFF002C3E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Calendar View
                Text(
                  'Calendar Overview',
                  style: GoogleFonts.openSansCondensed(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF002C3E),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCalendarCard(),
                const SizedBox(height: 24),

                // Weekly Schedule
                Text(
                  'Weekly Availability',
                  style: GoogleFonts.openSansCondensed(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF002C3E),
                  ),
                ),
                const SizedBox(height: 16),

                // Days of the Week
                ...List.generate(7, (dayIndex) {
                  final existingSchedule = schedules.firstWhere(
                    (s) => s.dayOfWeek == dayIndex,
                    orElse: () => DoctorScheduleModel(
                      id: '',
                      doctorId: widget.doctorId,
                      hospitalId: widget.hospitalId,
                      dayOfWeek: dayIndex,
                      startTime: '09:00',
                      endTime: '17:00',
                      isAvailable: false,
                    ),
                  );

                  return _buildDayScheduleCard(existingSchedule);
                }),
                const SizedBox(height: 24),

                // Settings
                Text(
                  'Appointment Settings',
                  style: GoogleFonts.openSansCondensed(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF002C3E),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingRow(
                        'Appointment Duration',
                        '$_appointmentDuration minutes',
                        Icons.timer,
                        () => _showDurationPicker(),
                      ),
                      const Divider(height: 32),
                      _buildSettingRow(
                        'Max Appointments per Day',
                        '$_maxAppointments appointments',
                        Icons.event_note,
                        () => _showMaxAppointmentsPicker(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFFF7444E).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF002C3E),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: GoogleFonts.dmSans(
            color: const Color(0xFFF7444E),
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF002C3E),
          ),
        ),
      ),
    );
  }

  Widget _buildDayScheduleCard(DoctorScheduleModel schedule) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.isAvailable
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: schedule.isAvailable,
            onChanged: (value) => _toggleDayAvailability(schedule, value ?? false),
            activeColor: const Color(0xFF002C3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          // Day and Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days[schedule.dayOfWeek],
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: schedule.isAvailable
                        ? const Color(0xFF002C3E)
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.isAvailable
                      ? '${schedule.startTime} - ${schedule.endTime}'
                      : 'Not available',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: schedule.isAvailable
                        ? Colors.grey[700]
                        : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          if (schedule.isAvailable)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7444E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () => _editSchedule(schedule),
                icon: const Icon(Icons.edit, size: 20),
                color: const Color(0xFFF7444E),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF002C3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF002C3E), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF002C3E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleDayAvailability(DoctorScheduleModel schedule, bool isAvailable) async {
    try {
      if (schedule.id.isEmpty) {
        // Create new schedule
        final newSchedule = DoctorScheduleModel(
          id: '',
          doctorId: widget.doctorId,
          hospitalId: widget.hospitalId,
          dayOfWeek: schedule.dayOfWeek,
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          isAvailable: isAvailable,
          maxAppointments: _maxAppointments,
          appointmentDuration: _appointmentDuration,
          createdAt: DateTime.now(),
        );
        await ref.read(scheduleControllerProvider.notifier).createSchedule(newSchedule);
      } else {
        // Update existing schedule
        await ref.read(scheduleControllerProvider.notifier).updateSchedule(
              schedule.id,
              {'isAvailable': isAvailable},
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Schedule updated', style: GoogleFonts.dmSans()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.dmSans()),
            backgroundColor: const Color(0xFFF7444E),
          ),
        );
      }
    }
  }

  Future<void> _editSchedule(DoctorScheduleModel schedule) async {
    TimeOfDay? startTime = TimeOfDay(
      hour: int.parse(schedule.startTime.split(':')[0]),
      minute: int.parse(schedule.startTime.split(':')[1]),
    );

    TimeOfDay? endTime = TimeOfDay(
      hour: int.parse(schedule.endTime.split(':')[0]),
      minute: int.parse(schedule.endTime.split(':')[1]),
    );

    final result = await showDialog<Map<String, TimeOfDay>>(
      context: context,
      builder: (context) => _TimeRangePickerDialog(
        dayName: schedule.dayName,
        initialStartTime: startTime,
        initialEndTime: endTime,
      ),
    );

    if (result != null) {
      final newStartTime = '${result['start']!.hour.toString().padLeft(2, '0')}:'
          '${result['start']!.minute.toString().padLeft(2, '0')}';
      final newEndTime = '${result['end']!.hour.toString().padLeft(2, '0')}:'
          '${result['end']!.minute.toString().padLeft(2, '0')}';

      try {
        await ref.read(scheduleControllerProvider.notifier).updateSchedule(
              schedule.id,
              {
                'startTime': newStartTime,
                'endTime': newEndTime,
              },
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Schedule updated', style: GoogleFonts.dmSans()),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e', style: GoogleFonts.dmSans()),
              backgroundColor: const Color(0xFFF7444E),
            ),
          );
        }
      }
    }
  }

  Future<void> _createDefaultSchedule() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Create Default Schedule',
          style: GoogleFonts.openSansCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will create a default schedule (Mon-Fri, 9AM-5PM). Existing schedules will not be affected.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002C3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Create', style: GoogleFonts.dmSans()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(scheduleControllerProvider.notifier).createDefaultSchedule(
              doctorId: widget.doctorId,
              hospitalId: widget.hospitalId,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Default schedule created', style: GoogleFonts.dmSans()),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e', style: GoogleFonts.dmSans()),
              backgroundColor: const Color(0xFFF7444E),
            ),
          );
        }
      }
    }
  }

  Future<void> _showDurationPicker() async {
    final durations = [15, 30, 45, 60];
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Appointment Duration',
          style: GoogleFonts.openSansCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        children: durations.map((duration) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, duration),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '$duration minutes',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: duration == _appointmentDuration
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: duration == _appointmentDuration
                      ? const Color(0xFFF7444E)
                      : const Color(0xFF002C3E),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        _appointmentDuration = selected;
      });
    }
  }

  Future<void> _showMaxAppointmentsPicker() async {
    final counts = [8, 12, 16, 20, 24];
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Max Appointments per Day',
          style: GoogleFonts.openSansCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        children: counts.map((count) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, count),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '$count appointments',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: count == _maxAppointments
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: count == _maxAppointments
                      ? const Color(0xFFF7444E)
                      : const Color(0xFF002C3E),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        _maxAppointments = selected;
      });
    }
  }
}

// Time Range Picker Dialog
class _TimeRangePickerDialog extends StatefulWidget {
  final String dayName;
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;

  const _TimeRangePickerDialog({
    required this.dayName,
    required this.initialStartTime,
    required this.initialEndTime,
  });

  @override
  State<_TimeRangePickerDialog> createState() => _TimeRangePickerDialogState();
}

class _TimeRangePickerDialogState extends State<_TimeRangePickerDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Edit ${widget.dayName}',
        style: GoogleFonts.openSansCondensed(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeRow('Start Time', _startTime, (time) {
            setState(() {
              _startTime = time;
            });
          }),
          const SizedBox(height: 16),
          _buildTimeRow('End Time', _endTime, (time) {
            setState(() {
              _endTime = time;
            });
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
          ),
          child: Text('Cancel', style: GoogleFonts.dmSans()),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'start': _startTime,
              'end': _endTime,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF002C3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Save', style: GoogleFonts.dmSans()),
        ),
      ],
    );
  }

  Widget _buildTimeRow(String label, TimeOfDay time, Function(TimeOfDay) onTimeSelected) {
    return InkWell(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (newTime != null) {
          onTimeSelected(newTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: const Color(0xFF002C3E)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Text(
              time.format(context),
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF7444E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
