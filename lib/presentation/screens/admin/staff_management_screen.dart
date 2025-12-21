// lib/presentation/screens/admin/staff_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/presentation/screens/admin/widgets/staff_details_dialog.dart';

// Provider for all staff members
final staffStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('userType', isEqualTo: 'hospitalStaff')
      .snapshots();
});

// Provider for selected hospital filter (using NotifierProvider pattern)
class SelectedHospitalNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void setHospital(String? hospital) {
    state = hospital;
  }
}

final selectedHospitalFilterProvider = NotifierProvider<SelectedHospitalNotifier, String?>(
  SelectedHospitalNotifier.new,
);

// Provider for filtered staff based on selected hospital
final filteredStaffProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final staffAsync = ref.watch(staffStreamProvider);
  final selectedHospital = ref.watch(selectedHospitalFilterProvider);

  return staffAsync.when(
    data: (snapshot) {
      final allStaff = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList();

      if (selectedHospital == null || selectedHospital == 'all') {
        return allStaff;
      }

      return allStaff.where((staff) {
        return staff['staffHospitalName'] == selectedHospital;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class StaffManagementScreen extends ConsumerWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(hospitalsStreamProvider);
    final selectedHospital = ref.watch(selectedHospitalFilterProvider);
    final filteredStaff = ref.watch(filteredStaffProvider);
    final staffAsync = ref.watch(staffStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Staff Management',
          style: GoogleFonts.dmSans(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: hospitalsAsync.when(
              data: (hospitals) {
                return Row(
                  children: [
                    Icon(Icons.filter_list, size: 20, color: AppColors.darkText.withOpacity(0.6)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkText.withOpacity(0.1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedHospital ?? 'all',
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.darkText),
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w500,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All Hospitals'),
                              ),
                              ...hospitals.map((hospital) {
                                return DropdownMenuItem(
                                  value: hospital.name,
                                  child: Text(hospital.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              ref.read(selectedHospitalFilterProvider.notifier).setHospital(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Results Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Text(
              '${filteredStaff.length} results',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.darkText.withOpacity(0.6),
              ),
            ),
          ),

          // Staff List
          Expanded(
            child: staffAsync.when(
              data: (snapshot) {
                if (snapshot.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: AppColors.darkText.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No staff members registered',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: AppColors.darkText.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredStaff.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: AppColors.darkText.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No staff found for selected hospital',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: AppColors.darkText.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(selectedHospitalFilterProvider.notifier).setHospital('all');
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Filter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredStaff.length,
                  itemBuilder: (context, index) {
                    final data = filteredStaff[index];
                    return _StaffCard(
                      staffData: data,
                      onRemove: () => _removeStaff(context, data),
                      onViewDetails: () => _viewStaffDetails(context, data),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Error: $error',
                  style: GoogleFonts.dmSans(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewStaffDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => StaffDetailsDialog(staffData: data),
    );
  }

  Future<void> _removeStaff(BuildContext context, Map<String, dynamic> data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Staff Member',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${data['fullName']}? This action cannot be undone.',
          style: GoogleFonts.dmSans(
            color: AppColors.darkText.withOpacity(0.8),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkText,
              side: BorderSide(color: AppColors.darkText.withOpacity(0.3)),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Remove',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(data['docId'])
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Staff member removed successfully',
                style: GoogleFonts.dmSans(),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e', style: GoogleFonts.dmSans()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _StaffCard extends StatelessWidget {
  final Map<String, dynamic> staffData;
  final VoidCallback onRemove;
  final VoidCallback onViewDetails;

  const _StaffCard({
    required this.staffData,
    required this.onRemove,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkText.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    staffData['fullName']?.substring(0, 1).toUpperCase() ?? 'S',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staffData['fullName'] ?? 'Unknown',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${staffData['position'] ?? 'Staff'} | ${staffData['staffHospitalName'] ?? 'N/A'}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.darkText.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staffData['email'] ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.darkText.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRemove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Remove',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Remove the _ActionButtons class - it's no longer needed