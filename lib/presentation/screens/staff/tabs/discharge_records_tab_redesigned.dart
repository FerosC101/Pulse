// lib/presentation/screens/staff/tabs/discharge_records_tab_redesigned.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/presentation/providers/patient_provider.dart';
import 'package:pulse/presentation/screens/staff/discharge_record_detail_screen_redesigned.dart';
import 'package:intl/intl.dart';

class DischargeRecordsTabRedesigned extends ConsumerStatefulWidget {
  final String hospitalId;

  const DischargeRecordsTabRedesigned({super.key, required this.hospitalId});

  @override
  ConsumerState<DischargeRecordsTabRedesigned> createState() => _DischargeRecordsTabRedesignedState();
}

class _DischargeRecordsTabRedesignedState extends ConsumerState<DischargeRecordsTabRedesigned> {
  String _searchQuery = '';
  String _filterDepartment = 'All Departments';

  final List<String> _departments = [
    'All Departments',
    'ICU',
    'Emergency',
    'General Ward',
    'Pediatrics',
    'Neurology',
  ];

  @override
  Widget build(BuildContext context) {
    final dischargedPatientsAsync = ref.watch(dischargedPatientsStreamProvider(widget.hospitalId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3), // Off-white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Discharge Records',
          style: GoogleFonts.openSansCondensed(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF002C3E), // Navy
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: const Color(0xFF002C3E),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for a patient',
                    hintStyle: GoogleFonts.dmSans(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF002C3E), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Department Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 20, color: const Color(0xFF002C3E).withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filterDepartment,
                            isExpanded: true,
                            isDense: true,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF002C3E),
                            ),
                            items: _departments.map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _filterDepartment = value!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.centerLeft,
            child: dischargedPatientsAsync.when(
              data: (patients) {
                final filteredCount = patients.where((patient) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      patient.fullName.toLowerCase().contains(_searchQuery);
                  final matchesDepartment = _filterDepartment == 'All Departments' ||
                      patient.department == _filterDepartment;
                  return matchesSearch && matchesDepartment;
                }).length;

                return Text(
                  '$filteredCount results',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
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
                  final matchesDepartment = _filterDepartment == 'All Departments' ||
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
                          _searchQuery.isNotEmpty || _filterDepartment != 'All Departments'
                              ? 'No discharge records found'
                              : 'No discharge records yet',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty || _filterDepartment != 'All Departments') ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _filterDepartment = 'All Departments';
                              });
                            },
                            child: Text(
                              'Clear Filters',
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFF002C3E),
                              ),
                            ),
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
                    return _DischargeRecordCardRedesigned(
                      patient: patient,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DischargeRecordDetailScreenRedesigned(
                              patient: patient,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002C3E)),
                ),
              ),
              error: (error, stack) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Color(0xFFF7444E),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load discharge records',
                        style: GoogleFonts.dmSans(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(dischargedPatientsStreamProvider(widget.hospitalId));
                        },
                        child: Text(
                          'Retry',
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF002C3E),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DischargeRecordCardRedesigned extends StatelessWidget {
  final dynamic patient;
  final VoidCallback onTap;

  const _DischargeRecordCardRedesigned({
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Avatar
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.fullName,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF002C3E), // Navy
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient.age} years | ${patient.gender}',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Info Grid (2x2)
              Row(
                children: [
                  Expanded(
                    child: _InfoItemRedesigned(
                      label: 'Discharged',
                      value: dischargeDate != null
                          ? DateFormat('MMM d, y').format(dischargeDate)
                          : 'N/A',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoItemRedesigned(
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
                    child: _InfoItemRedesigned(
                      label: 'Length of stay',
                      value: lengthOfStay,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoItemRedesigned(
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

class _InfoItemRedesigned extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItemRedesigned({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF002C3E), // Navy
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
