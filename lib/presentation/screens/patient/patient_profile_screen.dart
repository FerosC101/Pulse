// lib/presentation/screens/patient/patient_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';
import 'package:pulse/presentation/screens/patient/edit_profile_screen.dart';
import 'package:pulse/utils/auth_utils.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.darkText),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.fullName.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Edit Profile Button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              child: Text(
                                'Edit Profile',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Contact Information Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Contact Information',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _InfoRow(
                    label: 'Email',
                    value: user.email,
                    icon: Icons.email,
                  ),
                  _InfoRow(
                    label: 'Phone',
                    value: user.phoneNumber ?? 'Not provided',
                    icon: Icons.phone,
                  ),
                  _InfoRow(
                    label: 'Address',
                    value: user.address ?? 'Not provided',
                    icon: Icons.location_on,
                  ),
                ]),

                const SizedBox(height: 24),

                // Medical Information Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Medical Information',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _InfoRow(
                    label: 'Blood Type',
                    value: user.bloodType ?? 'N/A',
                    icon: Icons.bloodtype,
                  ),
                  _InfoRow(
                    label: 'Allergies',
                    value: user.allergies ?? 'N/A',
                    icon: Icons.warning_amber,
                  ),
                  _InfoRow(
                    label: 'Medical Conditions',
                    value: user.medicalConditions ?? 'N/A',
                    icon: Icons.medical_information,
                  ),
                ]),

                const SizedBox(height: 24),

                // Emergency Contact Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Emergency Contact',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _InfoRow(
                    label: 'Name',
                    value: user.emergencyContact ?? 'Not provided',
                    icon: Icons.person,
                  ),
                  _InfoRow(
                    label: 'Phone',
                    value: user.emergencyPhone ?? 'Not provided',
                    icon: Icons.phone_in_talk,
                  ),
                ]),

                const SizedBox(height: 32),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => AuthUtils.handleLogout(context, ref),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
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

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      rows[i].icon,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].label,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rows[i].value,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(
                height: 1,
                indent: 56,
                color: AppColors.background,
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final IconData icon;

  _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });
}
