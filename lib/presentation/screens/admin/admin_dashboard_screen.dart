import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/presentation/screens/admin/doctor_management_screen.dart';
import 'package:pulse/presentation/screens/admin/staff_management_screen.dart';
import 'package:pulse/presentation/screens/admin/hospital_management_screen.dart';
import 'package:pulse/presentation/screens/admin/system_analytics_screen.dart';
import 'package:pulse/utils/auth_utils.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final hospitalsAsync = ref.watch(hospitalsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('No user data'));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with red-tinted background
                _buildHeader(context, ref, user.fullName),
                
                const SizedBox(height: 24),

                // System Overview Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Overview',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Stats Card
                      hospitalsAsync.when(
                        data: (hospitals) {
                          int totalBeds = 0;
                          int occupiedBeds = 0;
                          int totalStaff = hospitals.length * 15; // Placeholder

                          for (var hospital in hospitals) {
                            totalBeds += hospital.status.totalBeds;
                            occupiedBeds += hospital.status.totalOccupied;
                          }
                          
                          int occupancyPercent = totalBeds > 0 
                              ? (occupiedBeds / totalBeds * 100).toInt() 
                              : 0;

                          return _buildStatsCard(
                            hospitals.length,
                            totalBeds,
                            totalStaff,
                            occupancyPercent,
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Text('Error: $error'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // System Management Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Management',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _ManagementCard(
                        title: 'Hospital Management',
                        subtitle: 'Add, edit, or remove hospitals from the system',
                        icon: Icons.local_hospital,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HospitalManagementScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _ManagementCard(
                        title: 'Staff Management',
                        subtitle: 'Manage hospital staff accounts and permissions',
                        icon: Icons.people,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StaffManagementScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _ManagementCard(
                        title: 'Doctor Management',
                        subtitle: 'Manage doctors across all hospitals',
                        icon: Icons.medical_services,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorManagementScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _ManagementCard(
                        title: 'Digital Twin Viewer',
                        subtitle: 'View 3D Hospital models and run simulations',
                        icon: Icons.view_in_ar,
                        onTap: () {
                          _showHospitalSelectorForDigitalTwin(context, ref);
                        },
                      ),
                      const SizedBox(height: 12),

                      _ManagementCard(
                        title: 'System Analytics',
                        subtitle: 'View comprehensive system wide analytics',
                        icon: Icons.analytics,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SystemAnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
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

  // Header with red-tinted background and profile
  Widget _buildHeader(BuildContext context, WidgetRef ref, String userName) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        image: const DecorationImage(
          image: AssetImage('assets/updated/red banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Back/Menu Icon
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
                    'Admin Dashboard',
                    style: GoogleFonts.openSansCondensed(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  // Logout Icon
                  InkWell(
                    onTap: () => AuthUtils.handleLogout(context, ref),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 22,
                      ),
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
                  ),
                  const SizedBox(width: 16),
                  // Name and Role
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'System Administrator',
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
            ],
          ),
        ),
      ),
    );
  }

  // System Overview Stats Card
  Widget _buildStatsCard(int hospitals, int beds, int staff, int occupancy) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Hospitals', hospitals.toString()),
          _buildStatItem('Beds', beds.toString()),
          _buildStatItem('Staff', staff.toString()),
          _buildStatItem('Occupancy', '$occupancy%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
      ],
    );
  }

  void _showHospitalSelectorForDigitalTwin(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.read(hospitalsStreamProvider);
  
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Hospital',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: hospitalsAsync.when(
            data: (hospitals) {
              final hospitalsWithModels = hospitals
                  .where((h) => h.has3dModel)
                  .toList();
              
              if (hospitalsWithModels.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No hospitals with 3D models yet',
                      style: GoogleFonts.dmSans(
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: hospitalsWithModels.length,
                itemBuilder: (context, index) {
                  final hospital = hospitalsWithModels[index];
                  return ListTile(
                    leading: const Icon(Icons.view_in_ar, color: AppColors.primary),
                    title: Text(
                      hospital.name,
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${hospital.modelMetadata?.floors ?? 0} floors',
                      style: GoogleFonts.dmSans(),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DigitalTwinScreen(
                            hospitalId: hospital.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// Management Card Widget
class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.darkText.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.darkText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkText.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chevron
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.darkText.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A simple placeholder DigitalTwinScreen so the referenced screen exists.
// Replace this with the real implementation when available.
class DigitalTwinScreen extends StatelessWidget {
  final String hospitalId;

  const DigitalTwinScreen({Key? key, required this.hospitalId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Digital Twin Viewer',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: Center(
        child: Text(
          'Digital Twin for hospital: $hospitalId',
          style: GoogleFonts.dmSans(color: AppColors.darkText),
        ),
      ),
    );
  }
}