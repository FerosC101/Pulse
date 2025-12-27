// lib/presentation/screens/staff/tabs/bed_status_tab_redesigned.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/presentation/providers/patient_provider.dart';
import 'package:pulse/presentation/screens/staff/widgets/bed_card_redesigned.dart';

class BedStatusTabRedesigned extends ConsumerStatefulWidget {
  final String hospitalId;

  const BedStatusTabRedesigned({super.key, required this.hospitalId});

  @override
  ConsumerState<BedStatusTabRedesigned> createState() => _BedStatusTabRedesignedState();
}

class _BedStatusTabRedesignedState extends ConsumerState<BedStatusTabRedesigned> {
  String _selectedDepartment = 'All Departments';
  String _selectedStatus = 'All Status';

  final Map<String, bool> _expandedDepartments = {
    'ICU': true,
    'Emergency': true,
    'General Ward': true,
    'Pediatrics': true,
    'Neurology': true,
  };

  final Map<String, int> _departmentCapacity = {
    'ICU': 3,
    'Emergency': 3,
    'General Ward': 3,
    'Pediatrics': 3,
    'Neurology': 3,
  };

  final List<String> _departments = [
    'All Departments',
    'ICU',
    'Emergency',
    'General Ward',
    'Pediatrics',
    'Neurology',
  ];

  final List<String> _statuses = [
    'All Status',
    'Occupied',
    'Available',
  ];

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsStreamProvider(widget.hospitalId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Bed Status',
          style: GoogleFonts.openSansCondensed(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.darkNavy,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    icon: Icons.filter_list,
                    value: _selectedDepartment,
                    items: _departments,
                    onChanged: (value) {
                      setState(() => _selectedDepartment = value!);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown(
                    icon: Icons.filter_alt_outlined,
                    value: _selectedStatus,
                    items: _statuses,
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.centerLeft,
            child: patientsAsync.when(
              data: (patients) {
                var filteredPatients = patients.where((p) {
                  if (_selectedDepartment != 'All Departments' && p.department != _selectedDepartment) {
                    return false;
                  }
                  return true;
                }).toList();

                int totalBeds = 0;
                if (_selectedDepartment == 'All Departments') {
                  totalBeds = _departmentCapacity.values.reduce((a, b) => a + b);
                } else {
                  totalBeds = _departmentCapacity[_selectedDepartment] ?? 0;
                }

                return Text(
                  '$totalBeds results',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Bed List
          Expanded(
            child: patientsAsync.when(
              data: (patients) {
                if (_selectedDepartment == 'All Departments') {
                  // Show all departments with accordion
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: _departments.skip(1).map((dept) {
                      final deptPatients = patients.where((p) => p.department == dept).toList();
                      final capacity = _departmentCapacity[dept] ?? 3;
                      final isExpanded = _expandedDepartments[dept] ?? false;

                      return _buildDepartmentSection(
                        department: dept,
                        patients: deptPatients,
                        capacity: capacity,
                        isExpanded: isExpanded,
                        onToggle: () {
                          setState(() {
                            _expandedDepartments[dept] = !isExpanded;
                          });
                        },
                      );
                    }).toList(),
                  );
                } else {
                  // Show single department
                  final deptPatients = patients.where((p) => p.department == _selectedDepartment).toList();
                  final capacity = _departmentCapacity[_selectedDepartment] ?? 3;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      _buildDepartmentSection(
                        department: _selectedDepartment,
                        patients: deptPatients,
                        capacity: capacity,
                        isExpanded: true,
                        onToggle: null,
                      ),
                    ],
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Error: $error',
                  style: GoogleFonts.dmSans(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.darkNavy.withOpacity(0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkNavy,
                ),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentSection({
    required String department,
    required List patients,
    required int capacity,
    required bool isExpanded,
    required VoidCallback? onToggle,
  }) {
    final availableCount = capacity - patients.length;
    final shouldShowContent = _selectedStatus == 'All Status' || 
                               (_selectedStatus == 'Occupied' && patients.isNotEmpty) ||
                               (_selectedStatus == 'Available' && availableCount > 0);

    if (!shouldShowContent && _selectedDepartment == 'All Departments') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Department Header
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (onToggle != null)
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    color: AppColors.darkNavy,
                  ),
                const SizedBox(width: 8),
                Text(
                  department,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bed Cards
        if (isExpanded) ...[
          const SizedBox(height: 12),
          // Occupied beds
          if (_selectedStatus == 'All Status' || _selectedStatus == 'Occupied')
            ...patients.map((patient) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BedCardRedesigned(
                    patient: patient,
                    isOccupied: true,
                    hospitalId: widget.hospitalId,
                  ),
                )),

          // Available beds
          if (_selectedStatus == 'All Status' || _selectedStatus == 'Available')
            ...List.generate(availableCount, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BedCardRedesigned(
                  patient: null,
                  isOccupied: false,
                  bedNumber: 'Bed ${patients.length + index + 1}',
                  department: department,
                  hospitalId: widget.hospitalId,
                ),
              );
            }),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
