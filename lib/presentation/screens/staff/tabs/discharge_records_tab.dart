// lib/presentation/screens/staff/tabs/discharge_records_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/presentation/providers/patient_provider.dart';
import 'package:pulse/presentation/screens/staff/discharge_record_detail_screen.dart';
import 'package:intl/intl.dart';

class DischargeRecordsTab extends ConsumerStatefulWidget {
  final String hospitalId;

  const DischargeRecordsTab({super.key, required this.hospitalId});

  @override
  ConsumerState<DischargeRecordsTab> createState() => _DischargeRecordsTabState();
}

class _DischargeRecordsTabState extends ConsumerState<DischargeRecordsTab> {
  String _searchQuery = '';
  String _filterDepartment = 'All';

  final List<String> _departments = [
    'All',
    'ICU',
    'Emergency',
    'General Ward',
    'Pediatrics',
    'Neurology',
  ];

  @override
  Widget build(BuildContext context) {
    final dischargedPatientsAsync = ref.watch(dischargedPatientsStreamProvider(widget.hospitalId));

    return Column(
      children: [
        // Header with Search and Filter
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Title
              Row(
                children: [
                  Icon(Icons.receipt_long, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Discharge Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Search Bar
              TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Search by patient name...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 12),
              
              // Department Filter
              Row(
                children: [
                  const Text(
                    'Department:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterDepartment,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _departments.map((dept) {
                        return DropdownMenuItem(value: dept, child: Text(dept));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _filterDepartment = value!);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Discharge Records List
        Expanded(
          child: dischargedPatientsAsync.when(
            data: (patients) {
              // Apply filters
              var filteredPatients = patients.where((patient) {
                final matchesSearch = _searchQuery.isEmpty ||
                    patient.fullName.toLowerCase().contains(_searchQuery);
                final matchesDepartment = _filterDepartment == 'All' ||
                    patient.department == _filterDepartment;
                return matchesSearch && matchesDepartment;
              }).toList();

              // Sort by discharge date (most recent first)
              filteredPatients.sort((a, b) {
                final aDate = a.dischargeDate;
                final bDate = b.dischargeDate;
                if (aDate == null && bDate == null) return 0;
                if (aDate == null) return 1;
                if (bDate == null) return -1;
                return bDate.compareTo(aDate);
              });

              if (filteredPatients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _filterDepartment != 'All'
                            ? 'No discharge records found'
                            : 'No discharge records yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _filterDepartment != 'All') ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _filterDepartment = 'All';
                            });
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = filteredPatients[index];
                  return _DischargeRecordCard(
                    patient: patient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DischargeRecordDetailScreen(
                            patient: patient,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              debugPrint('Error loading discharge records: $error');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load discharge records',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(dischargedPatientsStreamProvider(widget.hospitalId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DischargeRecordCard extends StatelessWidget {
  final dynamic patient;
  final VoidCallback onTap;

  const _DischargeRecordCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dischargeDate = patient.dischargeDate;
    final admissionDate = patient.admissionDate;

    // Calculate length of stay
    String lengthOfStay = 'N/A';
    if (admissionDate != null && dischargeDate != null) {
      final duration = dischargeDate.difference(admissionDate);
      if (duration.inDays > 0) {
        lengthOfStay = '${duration.inDays} days';
      } else {
        lengthOfStay = '${duration.inHours} hours';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient.age} years • ${patient.gender}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const Divider(height: 24),
              
              // Info Grid
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.calendar_today,
                      label: 'Discharged',
                      value: dischargeDate != null
                          ? DateFormat('MMM d, y').format(dischargeDate)
                          : 'N/A',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.local_hospital,
                      label: 'Department',
                      value: patient.department,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.timer,
                      label: 'Length of Stay',
                      value: lengthOfStay,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.medical_information,
                      label: 'Condition',
                      value: patient.condition,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
