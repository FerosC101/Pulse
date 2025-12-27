// lib/presentation/screens/staff/tabs/overview_tab_redesigned.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';
import 'package:pulse/presentation/providers/patient_provider.dart';
import 'package:pulse/presentation/providers/queue_provider.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/presentation/screens/staff/widgets/patient_admission_dialog.dart';
import 'package:pulse/presentation/screens/staff/widgets/discharge_dialog.dart';
import 'package:pulse/presentation/screens/staff/widgets/transfer_dialog.dart';
import 'package:pulse/presentation/screens/staff/widgets/emergency_admission_dialog.dart';
import 'package:pulse/presentation/screens/staff/staff_analytics_screen.dart';
import 'package:pulse/presentation/screens/staff/staff_digital_twin_screen.dart';
import 'package:pulse/utils/auth_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OverviewTabRedesigned extends ConsumerWidget {
  final String hospitalId;

  const OverviewTabRedesigned({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsStreamProvider(hospitalId));
    final queueAsync = ref.watch(queueStreamProvider(hospitalId));
    final hospitalAsync = ref.watch(hospitalStreamProvider(hospitalId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(patientsStreamProvider(hospitalId));
        ref.invalidate(queueStreamProvider(hospitalId));
        ref.invalidate(hospitalStreamProvider(hospitalId));
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // White space for status bar
            Container(
              height: MediaQuery.of(context).padding.top,
              color: Colors.white,
            ),
            // Header with gradient banner and logout button
            _buildGradientHeader(context, ref),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions Grid
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionsGrid(context),
                      const SizedBox(height: 28),

                      // System Management & Tasks
                      const Text(
                        'System Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSystemManagementCards(context),
                      const SizedBox(height: 28),

                      // Pending Tasks
                      const Text(
                        'Pending Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      patientsAsync.when(
                        data: (patients) => _buildPendingTasksCard(patients),
                        loading: () => _buildLoadingCard(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 28),

                      // Staff on Duty
                      const Text(
                        'Staff on Duty',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStaffOnDutyCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods matching Patient Dashboard style
  Widget _buildGradientHeader(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/updated/gradient banner.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Staff Portal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Open Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daily Summary',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
            onPressed: () => AuthUtils.handleLogout(context, ref),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                icon: Icons.person_add,
                label: 'Admit Patient',
                color: AppColors.primary,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => PatientAdmissionDialog(
                      hospitalId: hospitalId,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                icon: Icons.exit_to_app,
                label: 'Discharge',
                color: AppColors.primary,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => DischargeDialog(
                      hospitalId: hospitalId,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                icon: Icons.swap_horiz,
                label: 'Transfer',
                color: AppColors.primary,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => TransferDialog(
                      hospitalId: hospitalId,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                icon: Icons.medical_services,
                label: 'Emergency',
                color: AppColors.primary,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => EmergencyAdmissionDialog(
                      hospitalId: hospitalId,
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

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemManagementCards(BuildContext context) {
    return Column(
      children: [
        _buildManagementCard(
          context: context,
          icon: Icons.analytics_outlined,
          title: 'Analytics',
          subtitle: 'ML-driven insights',
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StaffAnalyticsScreen(hospitalId: hospitalId),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildManagementCard(
          context: context,
          icon: Icons.view_in_ar_outlined,
          title: 'Digital Twin',
          subtitle: 'Hospital 3D view',
          color: AppColors.mutedBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StaffDigitalTwinScreen(hospitalId: hospitalId),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildManagementCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTasksCard(List patients) {
    final pendingDischarges = patients.where((p) => 
      p.condition.toLowerCase().contains('stable') && 
      p.admissionDate != null &&
      DateTime.now().difference(p.admissionDate!).inDays > 3
    ).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assignment_outlined, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Discharges: $pendingDischarges',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review and process today',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildStaffOnDutyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStaffRow('Nurses', '12/15'),
          const SizedBox(height: 12),
          _buildStaffRow('Doctors', '8/10'),
          const SizedBox(height: 12),
          _buildStaffRow('Support Staff', '5/8'),
        ],
      ),
    );
  }

  Widget _buildStaffRow(String role, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          role,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'DM Sans',
          ),
        ),
        Text(
          count,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontFamily: 'DM Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
