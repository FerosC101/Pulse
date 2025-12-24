// lib/presentation/screens/patient/patient_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/presentation/screens/patient/hospital_list_screen.dart';
import 'package:pulse/presentation/screens/patient/hospital_detail_screen.dart';
import 'package:pulse/presentation/screens/patient/patient_appointments_screen.dart';
import 'package:pulse/presentation/screens/patient/medical_records_screen.dart';
import 'package:pulse/presentation/screens/patient/patient_profile_screen.dart';
import 'package:pulse/presentation/screens/ai/ai_chat_screen.dart';
import 'package:pulse/presentation/screens/map/hospital_map_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _HomePage(),
    HospitalMapScreen(),
    AIChatScreen(),
    MedicalRecordsScreen(),
    PatientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.map_outlined, 'Map', 1),
                _buildNavItem(Icons.chat_bubble_outline, 'AI Chatbot', 2),
                _buildNavItem(Icons.folder_outlined, 'Records', 3),
                _buildNavItem(Icons.person_outline, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.darkText.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.darkText.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Page Content
class _HomePage extends ConsumerWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final hospitalsAsync = ref.watch(hospitalsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Header Banner
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/updated/gradient banner.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final userName = snapshot.data?.get('fullName') ?? 
                                               user?.displayName ?? 
                                               'Patient';
                                return Text(
                                  userName,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: user?.photoURL != null 
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Icon(Icons.person, color: AppColors.primary, size: 32)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.darkText.withOpacity(0.5)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HospitalListScreen(),
                                  ),
                                );
                              },
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Search hospital, services...',
                                hintStyle: GoogleFonts.dmSans(
                                  color: AppColors.darkText.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Quick Actions',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.emergency,
                        title: 'Emergency\nMode',
                        color: AppColors.error,
                        onTap: () {
                          // TODO: Implement emergency mode
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Book\nAppointment',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HospitalListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.event_note,
                        title: 'Manage\nAppointments',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PatientAppointmentsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quick Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Quick Stats',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              hospitalsAsync.when(
                data: (hospitals) {
                  final operationalHospitals = hospitals.where((h) => h.status.isOperational).length;
                  int totalICU = 0;
                  int totalER = 0;
                  int availableICU = 0;
                  int availableER = 0;

                  for (var hospital in hospitals) {
                    totalICU += hospital.status.icuTotal;
                    totalER += hospital.status.erTotal;
                    availableICU += (hospital.status.icuTotal - hospital.status.icuOccupied);
                    availableER += (hospital.status.erTotal - hospital.status.erOccupied);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF8B4A5A), // Burgundy/dark red
                            Color(0xFF2C5F6F), // Dark teal/blue
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                            title: 'Nearby\nHospitals',
                            value: operationalHospitals.toString(),
                          ),
                          _buildStatColumn(
                            title: 'Available\nICU',
                            value: availableICU.toString(),
                          ),
                          _buildStatColumn(
                            title: 'Available\nER',
                            value: availableER.toString(),
                          ),
                          _buildStatColumn(
                            title: 'Operational',
                            value: '${((operationalHospitals / hospitals.length) * 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 32),

              // Nearby Hospitals
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nearby Hospitals',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HospitalListScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'View all',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              hospitalsAsync.when(
                data: (hospitals) {
                  final nearbyHospitals = hospitals.take(3).toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: nearbyHospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = nearbyHospitals[index];
                      return _buildHospitalCard(context, hospital);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error loading hospitals')),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(BuildContext context, hospital) {
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: AppColors.primary,
                    size: 24,
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: hospital.type == 'public' 
                            ? AppColors.info.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hospital.type == 'public' ? 'Open' : 'Private',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: hospital.type == 'public' ? AppColors.info : AppColors.warning,
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

// Placeholder pages for other tabs
// Map page is now using HospitalMapScreen directly

class _ChatbotPage extends StatelessWidget {
  const _ChatbotPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'AI Chatbot',
          style: GoogleFonts.dmSans(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble, size: 80, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'AI Chatbot',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.darkText.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
