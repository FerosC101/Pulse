// lib/presentation/screens/admin/staff_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse/core/constants/app_colors.dart';
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
      appBar: AppBar(
        title: const Text('Staff Management'),
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${filteredStaff.length} staff',
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
      body: staffAsync.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No staff members registered',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
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
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No staff found for selected hospital',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(selectedHospitalFilterProvider.notifier).setHospital('all');
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
              itemCount: filteredStaff.length,
              itemBuilder: (context, index) {
                final data = filteredStaff[index];

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
                      leading: Hero(
                        tag: 'staff-avatar-${data['docId']}',
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            data['fullName']?.substring(0, 1).toUpperCase() ?? 'S',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        data['fullName'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(data['email'] ?? ''),
                          const SizedBox(height: 4),
                          Text(
                            '${data['position']} • ${data['department']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (data['staffHospitalName'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
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
                                    data['staffHospitalName'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.info,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, color: AppColors.primary),
                            tooltip: 'View Details',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => StaffDetailsDialog(
                                  staffData: data,
                                ),
                              );
                            },
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, size: 20),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: AppColors.error),
                                    SizedBox(width: 8),
                                    Text('Remove', style: TextStyle(color: AppColors.error)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'view') {
                                showDialog(
                                  context: context,
                                  builder: (context) => StaffDetailsDialog(
                                    staffData: data,
                                  ),
                                );
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove Staff Member'),
                                    content: Text(
                                      'Are you sure you want to remove ${data['fullName']}?',
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
                                        child: const Text('Remove'),
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
                                        const SnackBar(
                                          content: Text('Staff member removed successfully'),
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}