import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_schedule_screen.dart';
import 'doctor_patients_screen.dart';

/// Redesigned Doctor Dashboard Screen
/// Following Pulse Design System
class DoctorDashboardScreenRedesigned extends ConsumerWidget {
  const DoctorDashboardScreenRedesigned({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3), // Off-white background
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Gradient Header
            _buildGradientHeader(context, userId),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Card
                    _buildQuickStatsCard(userId),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(context, userId),
                    const SizedBox(height: 24),
                    
                    // Today's Schedule
                    _buildTodaysSchedule(context, userId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gradient Header
  Widget _buildGradientHeader(BuildContext context, String userId) {
    return SliverAppBar(
      expandedHeight: 240,
      floating: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/updated/red banner.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: FlexibleSpaceBar(
          background: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final fullName = data?['fullName'] ?? 'Doctor';
              final specialty = data?['specialty'] ?? 'General Medicine';
              
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      // Top Row: Menu, Title, Logout
                      Row(
                        children: [
                          // Hamburger Menu Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          // Title - Centered
                          Text(
                            'Doctor Dashboard',
                            style: GoogleFonts.openSansCondensed(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const Spacer(),
                          // Logout Icon - Translucent Circular
                          InkWell(
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.logout, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Profile Section
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'D',
                                style: GoogleFonts.dmSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Name and Role
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. $fullName',
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                specialty,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Search Bar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: AppColors.darkText.withOpacity(0.5)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search patients, appointments...',
                                        hintStyle: GoogleFonts.dmSans(
                                          color: AppColors.darkText.withOpacity(0.5),
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Quick Stats Card with Gradient
  Widget _buildQuickStatsCard(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        final appointments = snapshot.data?.docs ?? [];
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final todayEnd = todayStart.add(const Duration(days: 1));
        
        final todayAppointments = appointments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final dateTime = (data['dateTime'] as Timestamp?)?.toDate();
          return dateTime != null && 
                 dateTime.isAfter(todayStart) && 
                 dateTime.isBefore(todayEnd);
        }).toList();
        
        final pendingCount = appointments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'pending';
        }).length;
        
        final confirmedCount = todayAppointments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'confirmed';
        }).length;
        
        final completedCount = todayAppointments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'completed';
        }).length;
        
        final todayPendingCount = todayAppointments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'pending';
        }).length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A3A4A),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF7444E), // Red
                    Color(0xFF78BCC4), // Muted Teal
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        title: 'Total\nToday',
                        value: todayAppointments.length.toString(),
                      ),
                      _buildStatItem(
                        title: 'Pending',
                        value: todayPendingCount.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        title: 'Confirmed',
                        value: confirmedCount.toString(),
                      ),
                      _buildStatItem(
                        title: 'Completed',
                        value: completedCount.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Actions - Only 3 buttons
  Widget _buildQuickActions(BuildContext context, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.openSansCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF002C3E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'All\nAppointments',
                Icons.event_note_outlined,
                AppColors.primary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorAppointmentsScreen(doctorId: userId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'My\nPatients',
                Icons.groups_outlined,
                AppColors.primary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorPatientsScreen(doctorId: userId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Manage\nSchedule',
                Icons.calendar_month_outlined,
                AppColors.primary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorScheduleScreen(
                        doctorId: userId,
                        hospitalId: '', // TODO: Get from user profile
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
                height: 1.3,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Today's Schedule
  Widget _buildTodaysSchedule(BuildContext context, String userId) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Appointments',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A3A4A),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorAppointmentsScreen(doctorId: userId),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'View all',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No appointments Today!',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }
            
            final todayAppointments = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final dateTime = (data['dateTime'] as Timestamp?)?.toDate();
              return dateTime != null && 
                     dateTime.isAfter(todayStart) && 
                     dateTime.isBefore(todayEnd);
            }).toList();
            
            todayAppointments.sort((a, b) {
              final aTime = ((a.data() as Map<String, dynamic>)['dateTime'] as Timestamp).toDate();
              final bTime = ((b.data() as Map<String, dynamic>)['dateTime'] as Timestamp).toDate();
              return aTime.compareTo(bTime);
            });
            
            if (todayAppointments.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No appointments Today!',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayAppointments.length,
              itemBuilder: (context, index) {
                final appointment = todayAppointments[index].data() as Map<String, dynamic>;
                final dateTime = (appointment['dateTime'] as Timestamp).toDate();
                final status = appointment['status'] ?? 'pending';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment['patientName'] ?? 'Unknown Patient',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF002C3E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appointment['reason'] ?? 'No reason provided',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.openSansCondensed(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF7444E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
