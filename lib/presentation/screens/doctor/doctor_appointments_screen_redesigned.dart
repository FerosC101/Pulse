// lib/presentation/screens/doctor/doctor_appointments_screen_redesigned.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/data/models/appointment_model.dart';
import 'package:pulse/data/models/appointment_status.dart' show AppointmentStatus;
import 'package:pulse/presentation/providers/appointment_provider.dart';
import 'package:pulse/presentation/screens/doctor/appointment_detail_screen.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentsScreenRedesigned extends ConsumerStatefulWidget {
  final String doctorId;

  const DoctorAppointmentsScreenRedesigned({
    super.key,
    required this.doctorId,
  });

  @override
  ConsumerState<DoctorAppointmentsScreenRedesigned> createState() => _DoctorAppointmentsScreenRedesignedState();
}

class _DoctorAppointmentsScreenRedesignedState extends ConsumerState<DoctorAppointmentsScreenRedesigned>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider(widget.doctorId));

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
          'All Appointments',
          style: GoogleFonts.openSansCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF002C3E),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF002C3E),
                labelStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                indicator: BoxDecoration(
                  color: const Color(0xFF002C3E), // Navy
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Confirmed'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          if (appointments.isEmpty) {
            return _buildEmptyState();
          }

          final now = DateTime.now();
          
          // All appointments
          final allAppointments = appointments.toList();
          
          // Pending appointments
          final pendingAppointments = appointments.where((a) => 
            a.status == AppointmentStatus.pending
          ).toList();
          
          // Confirmed appointments  
          final confirmedAppointments = appointments.where((a) => 
            a.status == AppointmentStatus.confirmed
          ).toList();
          
          // Completed appointments
          final completedAppointments = appointments.where((a) => 
            a.status == AppointmentStatus.completed
          ).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentsList(allAppointments, title: 'All'),
              _buildAppointmentsList(pendingAppointments, title: 'Pending'),
              _buildAppointmentsList(confirmedAppointments, title: 'Confirmed'),
              _buildAppointmentsList(completedAppointments, title: 'Completed'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF002C3E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Patients can book appointments with you',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments, {required String title}) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No $title appointments',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Group appointments by date
    final groupedAppointments = <DateTime, List<AppointmentModel>>{};
    for (var appointment in appointments) {
      final date = DateTime(
        appointment.dateTime.year,
        appointment.dateTime.month,
        appointment.dateTime.day,
      );
      groupedAppointments.putIfAbsent(date, () => []).add(appointment);
    }

    final sortedDates = groupedAppointments.keys.toList()..sort((a, b) => a.compareTo(b));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(doctorAppointmentsProvider(widget.doctorId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dayAppointments = groupedAppointments[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _getDateLabel(date),
                  style: GoogleFonts.openSansCondensed(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF002C3E),
                  ),
                ),
              ),
              ...dayAppointments.map((appointment) {
                return _buildAppointmentCard(appointment);
              }),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) {
      return 'Today - ${DateFormat('MMMM d, y').format(date)}';
    } else if (date == tomorrow) {
      return 'Tomorrow - ${DateFormat('MMMM d, y').format(date)}';
    } else {
      return DateFormat('EEEE, MMMM d, y').format(date);
    }
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final statusColor = switch (appointment.status) {
      AppointmentStatus.pending => Colors.amber,
      AppointmentStatus.confirmed => Colors.blue,
      AppointmentStatus.completed => Colors.green,
      AppointmentStatus.cancelled || AppointmentStatus.noShow => const Color(0xFFF7444E),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailScreen(appointment: appointment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Time badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7444E).withOpacity(0.1), // Primary Red
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('hh:mm a').format(appointment.dateTime),
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF7444E),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      appointment.status.displayName,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002C3E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF002C3E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patientName,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF002C3E),
                          ),
                        ),
                        if (appointment.patientPhone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            appointment.patientPhone,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              if (appointment.chiefComplaint != null && appointment.chiefComplaint!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.medical_information_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chief Complaint',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appointment.chiefComplaint!,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: const Color(0xFF002C3E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
