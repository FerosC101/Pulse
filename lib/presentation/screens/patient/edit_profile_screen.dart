// lib/presentation/screens/patient/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/core/constants/app_constants.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  
  String? _selectedBloodType;
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      setState(() {
        _userId = user.id;
        _fullNameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
        _addressController.text = user.address ?? '';
        _selectedBloodType = user.bloodType;
        _allergiesController.text = user.allergies ?? '';
        _medicalConditionsController.text = user.medicalConditions ?? '';
        _emergencyContactController.text = user.emergencyContact ?? '';
        _emergencyPhoneController.text = user.emergencyPhone ?? '';
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'bloodType': _selectedBloodType,
        'allergies': _allergiesController.text.trim(),
        'medicalConditions': _medicalConditionsController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'emergencyPhone': _emergencyPhoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating profile: $e',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
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

  @override
  Widget build(BuildContext context) {
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
          'Profile',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check, color: AppColors.primary),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement image picker
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add Image',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Full Name
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email (Read-only)
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                enabled: false,
              ),

              const SizedBox(height: 16),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              // Address
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Blood Type Dropdown
              _buildDropdownField(
                label: 'Blood type (Optional)',
                icon: Icons.bloodtype,
                value: _selectedBloodType,
                items: AppConstants.bloodTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Allergies
              _buildTextField(
                controller: _allergiesController,
                label: 'Allergies',
                icon: Icons.warning_amber,
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Medical Conditions
              _buildTextField(
                controller: _medicalConditionsController,
                label: 'Medical Conditions',
                icon: Icons.medical_information,
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Emergency Contact Name
              _buildTextField(
                controller: _emergencyContactController,
                label: 'Emergency Contact Name',
                icon: Icons.contact_emergency,
              ),

              const SizedBox(height: 16),

              // Emergency Contact Phone
              _buildTextField(
                controller: _emergencyPhoneController,
                label: 'Emergency Contact',
                icon: Icons.phone_in_talk,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              // Relationship (placeholder for future)
              _buildTextField(
                controller: TextEditingController(),
                label: 'Relationship with Emergency Contact',
                icon: Icons.people,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.darkText,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.darkText,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
