// lib/presentation/screens/patient/hospital_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/data/models/hospital_model.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/presentation/screens/patient/hospital_detail_screen.dart';

class HospitalListScreen extends ConsumerStatefulWidget {
  const HospitalListScreen({super.key});

  @override
  ConsumerState<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends ConsumerState<HospitalListScreen> {
  String _searchQuery = '';
  String _filterType = 'All';

  String? _getHospitalImage(HospitalModel hospital) {
    // Use uploaded image if available, otherwise use default based on name
    if (hospital.imageUrl != null && hospital.imageUrl!.isNotEmpty) {
      return hospital.imageUrl;
    }
    
    // Fallback to default images
    final n = hospital.name.toLowerCase();
    if (n.contains('metro') && n.contains('general')) {
      return 'https://res.cloudinary.com/dhqosbqeh/image/upload/v1763996688/hospital_metro_general_ver2ot.jpg';
    }
    if (n.contains('batangas') && n.contains('medical')) {
      return 'https://res.cloudinary.com/dhqosbqeh/image/upload/v1763996689/hospital_batangas_medical_la9gna.jpg';
    }
    return 'https://res.cloudinary.com/dhqosbqeh/image/upload/v1763996689/icon_hospital_ekdup6.png';
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsAsync = ref.watch(hospitalsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Find Hospitals',
          style: GoogleFonts.dmSans(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filters Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                    decoration: InputDecoration(
                      hintText: 'Search hospital, services...',
                      hintStyle: GoogleFonts.dmSans(
                        color: AppColors.darkText.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.darkText.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Chips
                Row(
                  children: ['All', 'Public', 'Private', 'Specialty'].map((type) {
                    final isSelected = _filterType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _filterType = type);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.darkText : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.darkText : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            type,
                            style: GoogleFonts.dmSans(
                              color: isSelected ? Colors.white : AppColors.darkText,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Hospital List
          Expanded(
            child: hospitalsAsync.when(
              data: (hospitals) {
                // Filter hospitals
                var filteredHospitals = hospitals.where((hospital) {
                  final matchesSearch = hospital.name.toLowerCase().contains(_searchQuery) ||
                      hospital.address.toLowerCase().contains(_searchQuery);
                  
                  String typeFilter = _filterType.toLowerCase();
                  if (typeFilter == 'all') {
                    return matchesSearch;
                  }
                  
                  final matchesType = hospital.type.toLowerCase() == typeFilter;
                  return matchesSearch && matchesType;
                }).toList();

                if (filteredHospitals.isEmpty) {
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
                          'No hospitals found',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredHospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = filteredHospitals[index];
                    return _buildHospitalCard(context, hospital);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Error loading hospitals',
                  style: GoogleFonts.dmSans(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(BuildContext context, HospitalModel hospital) {
    final icuOccupancy = hospital.status.icuTotal > 0 ? hospital.status.icuOccupied / hospital.status.icuTotal : 0.0;
    final erOccupancy = hospital.status.erTotal > 0 ? hospital.status.erOccupied / hospital.status.erTotal : 0.0;
    final wardOccupancy = hospital.status.wardTotal > 0 ? hospital.status.wardOccupied / hospital.status.wardTotal : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              builder: (context) => HospitalDetailScreen(hospital: hospital),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _getHospitalImage(hospital) != null
                        ? Image.network(
                            _getHospitalImage(hospital)!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.local_hospital,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          )
                        : const Icon(
                            Icons.local_hospital,
                            color: AppColors.primary,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hospital.address,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.darkText.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: hospital.type == 'public' 
                            ? Colors.transparent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hospital.type == 'public' ? AppColors.success : AppColors.warning,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        hospital.type == 'public' ? 'Open' : 'Private',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: hospital.type == 'public' ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '30 min wait',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOccupancyBar('ICU', icuOccupancy, hospital.status.icuOccupied, hospital.status.icuTotal),
            const SizedBox(height: 8),
            _buildOccupancyBar('ER', erOccupancy, hospital.status.erOccupied, hospital.status.erTotal),
            const SizedBox(height: 8),
            _buildOccupancyBar('Ward', wardOccupancy, hospital.status.wardOccupied, hospital.status.wardTotal),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyBar(String label, double occupancy, int occupied, int total) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: occupancy.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 45,
          child: Text(
            '$occupied/$total',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.darkText.withOpacity(0.6),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}