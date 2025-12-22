// lib/presentation/screens/admin/doctor_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/data/repositories/doctor_repository.dart';
import 'package:pulse/presentation/screens/admin/widgets/doctor_edit_dialog.dart';

// Provider for all doctors (admin view - all hospitals)
final allDoctorsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('doctors')
      .snapshots();
});

// Provider for selected hospital filter
class SelectedDoctorHospitalNotifier extends Notifier<String?> {
  @override
  String? build() => 'all';
  
  void setHospital(String? hospital) {
    state = hospital;
  }
}

final selectedDoctorHospitalProvider = NotifierProvider<SelectedDoctorHospitalNotifier, String?>(
  SelectedDoctorHospitalNotifier.new,
);

// Provider for filtered doctors based on selected hospital
final filteredDoctorsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final doctorsAsync = ref.watch(allDoctorsStreamProvider);
  final selectedHospital = ref.watch(selectedDoctorHospitalProvider);

  return doctorsAsync.when(
    data: (snapshot) {
      final allDoctors = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList();

      if (selectedHospital == null || selectedHospital == 'all') {
        return allDoctors;
      }

      return allDoctors.where((doctor) {
        return doctor['hospitalId'] == selectedHospital;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class DoctorManagementScreen extends ConsumerWidget {
  const DoctorManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(hospitalsStreamProvider);
    final selectedHospital = ref.watch(selectedDoctorHospitalProvider);
    final filteredDoctors = ref.watch(filteredDoctorsProvider);
    final doctorsAsync = ref.watch(allDoctorsStreamProvider);

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
          'Doctor Management',
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
                                  value: hospital.id,
                                  child: Text(hospital.name),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              ref.read(selectedDoctorHospitalProvider.notifier).setHospital(value);
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
              '${filteredDoctors.length} results',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.darkText.withOpacity(0.6),
              ),
            ),
          ),

          // Doctors List
          Expanded(
            child: doctorsAsync.when(
              data: (snapshot) {
                if (snapshot.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 80,
                          color: AppColors.darkText.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors registered',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: AppColors.darkText.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredDoctors.isEmpty) {
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
                          'No doctors found for selected hospital',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: AppColors.darkText.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(selectedDoctorHospitalProvider.notifier).setHospital('all');
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
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final data = filteredDoctors[index];
                    return _DoctorCard(
                      doctorData: data,
                      onRemove: () => _removeDoctor(context, data),
                      onEditDetails: () => _editDoctorDetails(context, data),
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

  void _editDoctorDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => DoctorEditDialog(doctorData: data),
    );
  }

  Future<void> _removeDoctor(BuildContext context, Map<String, dynamic> data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Doctor',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        content: Text(
          'Are you sure you want to remove Dr. ${data['name']}? This action cannot be undone.',
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
        await DoctorRepository().deleteDoctor(data['docId']);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Doctor removed successfully',
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

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctorData;
  final VoidCallback onRemove;
  final VoidCallback onEditDetails;

  const _DoctorCard({
    required this.doctorData,
    required this.onRemove,
    required this.onEditDetails,
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
                    doctorData['name']?.substring(0, 1).toUpperCase() ?? 'D',
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
                      'Dr. ${doctorData['name'] ?? 'Unknown'}',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('hospitals')
                          .doc(doctorData['hospitalId'])
                          .get(),
                      builder: (context, snapshot) {
                        String hospitalName = 'Loading...';
                        if (snapshot.hasData && snapshot.data != null && snapshot.data!.data() != null) {
                          final hospitalData = snapshot.data!.data() as Map<String, dynamic>;
                          hospitalName = hospitalData['name'] ?? 'Unknown Hospital';
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          hospitalName = 'Unknown Hospital';
                        }
                        
                        return Text(
                          '${doctorData['specialty'] ?? 'General'} | $hospitalName',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.darkText.withOpacity(0.6),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctorData['email'] ?? '',
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
                  onPressed: onEditDetails,
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
                    'Edit Details',
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
