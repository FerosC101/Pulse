// lib/presentation/screens/staff/staff_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';
import 'package:pulse/presentation/screens/staff/tabs/overview_tab.dart';
import 'package:pulse/presentation/screens/staff/tabs/bed_status_tab_redesigned.dart';
import 'package:pulse/presentation/screens/staff/tabs/queue_tab.dart';
import 'package:pulse/presentation/screens/staff/tabs/discharge_records_tab.dart';
import 'package:pulse/presentation/screens/staff/staff_analytics_screen.dart';
import 'package:pulse/utils/auth_utils.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen> {
  int _selectedIndex = 0;

  // Screens matching Patient Dashboard structure
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No user data')),
          );
        }

        // Check if staff has hospital assigned
        if (user.staffHospitalId == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: AppColors.error,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Hospital Assigned',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please contact your administrator to assign you to a hospital.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => AuthUtils.handleLogout(context, ref),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        // Create tabs with hospital ID
        final tabs = [
          OverviewTab(hospitalId: user.staffHospitalId!),
          BedStatusTabRedesigned(hospitalId: user.staffHospitalId!),
          QueueTab(hospitalId: user.staffHospitalId!),
          DischargeRecordsTab(hospitalId: user.staffHospitalId!),
        ];

        return Scaffold(
          body: tabs[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.dashboard_outlined, 'Overview', 0),
                    _buildNavItem(Icons.bed_outlined, 'Bed Status', 1),
                    _buildNavItem(Icons.queue_outlined, 'Queue', 2),
                    _buildNavItem(Icons.receipt_long_outlined, 'Discharge', 3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 60, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.darkNavy.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.darkNavy.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}