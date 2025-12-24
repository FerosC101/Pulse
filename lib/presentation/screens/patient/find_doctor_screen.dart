// lib/presentation/screens/patient/find_doctor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/data/models/hospital_model.dart';
import 'package:pulse/data/models/user_model.dart';
import 'package:pulse/presentation/providers/user_provider.dart';
import 'package:pulse/presentation/screens/patient/booking_details_screen.dart';

class FindDoctorScreen extends ConsumerStatefulWidget {
  final HospitalModel hospital;

  const FindDoctorScreen({
    super.key,
    required this.hospital,
  });

  @override
  ConsumerState<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends ConsumerState<FindDoctorScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsByHospitalProvider(widget.hospital.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Appointment',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.darkText,
              ),
              decoration: InputDecoration(
                hintText: 'Search doctor, specialty...',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Doctor List
          Expanded(
            child: doctorsAsync.when(
              data: (doctors) {
                if (doctors.isEmpty) {
                  return _buildNoDoctorsState();
                }

                final filteredDoctors = doctors.where((doctor) {
                  if (_searchQuery.isEmpty) return true;
                  final name = doctor.fullName.toLowerCase();
                  final specialty = (doctor.specialty ?? '').toLowerCase();
                  return name.contains(_searchQuery) || specialty.contains(_searchQuery);
                }).toList();

                if (filteredDoctors.isEmpty) {
                  return _buildNoResultsState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    return _buildDoctorCard(context, filteredDoctors[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading doctors',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, UserModel doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsScreen(
                hospital: widget.hospital,
                doctor: doctor,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${doctor.fullName}',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty ?? 'General Practitioner',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.email,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDoctorsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No doctors available',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This hospital has no doctors registered yet',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
