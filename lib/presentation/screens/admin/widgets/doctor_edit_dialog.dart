// lib/presentation/screens/admin/widgets/doctor_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/data/repositories/doctor_repository.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorEditDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorEditDialog({
    super.key,
    required this.doctorData,
  });

  @override
  ConsumerState<DoctorEditDialog> createState() => _DoctorEditDialogState();
}

class _DoctorEditDialogState extends ConsumerState<DoctorEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseController;
  
  String? _selectedHospitalId;
  String? _selectedHospitalName;
  final List<String> _selectedSpecialties = [];
  bool _isLoading = false;

  final List<String> _specialtyOptions = [
    'Cardiology',
    'Neurology',
    'Pediatrics',
    'Orthopedics',
    'General Medicine',
    'OB-GYN',
    'Psychiatry',
    'Dermatology',
    'ENT',
    'Ophthalmology',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.doctorData['name'] ?? '');
    _emailController = TextEditingController(text: widget.doctorData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.doctorData['phone'] ?? '');
    _licenseController = TextEditingController(text: widget.doctorData['licenseNumber'] ?? '');
    _selectedHospitalId = widget.doctorData['hospitalId'];
    
    // Initialize specialty
    if (widget.doctorData['specialty'] != null && widget.doctorData['specialty'].toString().isNotEmpty) {
      _selectedSpecialties.add(widget.doctorData['specialty']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsAsync = ref.watch(hospitalsStreamProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.darkText.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Doctor Details',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.darkText.withOpacity(0.6)),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _buildStyledTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildStyledTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (!value.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildStyledTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // License Number
                      _buildStyledTextField(
                        controller: _licenseController,
                        label: 'Medical License Number',
                        icon: Icons.badge_outlined,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),

                      // Hospital Affiliation
                      Text(
                        'Hospital Affiliation',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      hospitalsAsync.when(
                        data: (hospitals) {
                          // Get hospital name from ID
                          if (_selectedHospitalId != null && _selectedHospitalName == null) {
                            final hospital = hospitals.firstWhere(
                              (h) => h.id == _selectedHospitalId,
                              orElse: () => hospitals.first,
                            );
                            _selectedHospitalName = hospital.name;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.darkText.withOpacity(0.1),
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedHospitalId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.local_hospital_outlined,
                                  color: AppColors.darkText.withOpacity(0.4),
                                ),
                              ),
                              hint: Text(
                                'Select Hospital',
                                style: GoogleFonts.dmSans(
                                  color: AppColors.darkText.withOpacity(0.4),
                                ),
                              ),
                              items: hospitals.map((hospital) {
                                return DropdownMenuItem(
                                  value: hospital.id,
                                  child: Text(
                                    hospital.name,
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.darkText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedHospitalId = value;
                                  final hospital = hospitals.firstWhere((h) => h.id == value);
                                  _selectedHospitalName = hospital.name;
                                });
                              },
                              validator: (value) => value == null ? 'Please select a hospital' : null,
                            ),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading hospitals'),
                      ),
                      const SizedBox(height: 24),

                      // Specialty
                      Text(
                        'Specialty',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _specialtyOptions.map((specialty) {
                          final isSelected = _selectedSpecialties.contains(specialty);
                          return _buildChip(
                            label: specialty,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSpecialties.remove(specialty);
                                } else {
                                  _selectedSpecialties.clear();
                                  _selectedSpecialties.add(specialty);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.darkText.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkText,
                        side: BorderSide(color: AppColors.darkText.withOpacity(0.3), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
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
                      onPressed: _isLoading ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Update Details',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkText.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.dmSans(
          color: AppColors.darkText,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.dmSans(
            color: AppColors.darkText.withOpacity(0.4),
          ),
          prefixIcon: Icon(icon, color: AppColors.darkText.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: AppColors.darkText,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSpecialties.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one specialty', style: GoogleFonts.dmSans()),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final updatedData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'licenseNumber': _licenseController.text.trim(),
          'hospitalId': _selectedHospitalId,
          'specialty': _selectedSpecialties.first,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await DoctorRepository().updateDoctor(
          widget.doctorData['docId'],
          updatedData,
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Doctor updated successfully',
                style: GoogleFonts.dmSans(),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e', style: GoogleFonts.dmSans()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
