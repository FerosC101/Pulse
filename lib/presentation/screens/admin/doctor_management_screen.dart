// lib/presentation/screens/admin/doctor_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/data/repositories/doctor_repository.dart';
import 'package:pulse/presentation/screens/staff/widgets/doctor_form_dialog.dart';

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
      appBar: AppBar(
        title: const Text('Doctor Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: hospitalsAsync.when(
              data: (hospitals) {
                return Row(
                  children: [
                    const Icon(Icons.filter_list, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter by Hospital:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedHospital ?? 'all',
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: [
                              const DropdownMenuItem(
                                value: 'all',
                                child: Text(
                                  'All Hospitals',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${filteredDoctors.length} doctors',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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
        ),
      ),
      floatingActionButton: selectedHospital != null && selectedHospital != 'all'
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => DoctorFormDialog(
                    hospitalId: selectedHospital,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Doctor'),
              backgroundColor: AppColors.primary,
            )
          : null,
      body: doctorsAsync.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No doctors registered',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a hospital and tap + to add doctors',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
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
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No doctors found for selected hospital',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(selectedDoctorHospitalProvider.notifier).setHospital('all');
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Filter'),
                  ),
                ],
              ),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ListView.builder(
              key: ValueKey(selectedHospital),
              padding: const EdgeInsets.all(16),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final data = filteredDoctors[index];

                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          data['name']?.substring(0, 1).toUpperCase() ?? 'D',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        data['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.medical_services,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(data['specialty'] ?? 'General'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(data['phone'] ?? 'No phone'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('hospitals')
                                .doc(data['hospitalId'])
                                .get(),
                            builder: (context, snapshot) {
                              String hospitalName = 'Loading...';
                              if (snapshot.hasData && snapshot.data != null && snapshot.data!.data() != null) {
                                final hospitalData = snapshot.data!.data() as Map<String, dynamic>;
                                hospitalName = hospitalData['name'] ?? 'Unknown Hospital';
                              } else if (snapshot.hasError) {
                                hospitalName = 'Unknown Hospital';
                              }
                              
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_hospital,
                                      size: 12,
                                      color: AppColors.info,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      hospitalName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (data['available'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: data['available']
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                data['available'] ? 'Available' : 'Not Available',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: data['available']
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            showDialog(
                              context: context,
                              builder: (context) => DoctorFormDialog(
                                hospitalId: data['hospitalId'],
                                doctorId: data['docId'],
                                doctorData: data,
                              ),
                            );
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Doctor'),
                                content: Text(
                                  'Are you sure you want to delete Dr. ${data['name']}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              try {
                                await DoctorRepository().deleteDoctor(data['docId']);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Doctor deleted successfully'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading doctors',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
