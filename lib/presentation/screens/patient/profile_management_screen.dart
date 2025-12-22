// lib/presentation/screens/patient/profile_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/core/constants/app_constants.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';
import 'package:pulse/utils/auth_utils.dart';

class ProfileManagementScreen extends ConsumerStatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  ConsumerState<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends ConsumerState<ProfileManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  String? _selectedBloodType;
  final _allergiesController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(String userId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'bloodType': _selectedBloodType,
        'emergencyContact': _emergencyContactController.text.trim(),
        'emergencyPhone': _emergencyPhoneController.text.trim(),
        'allergies': _allergiesController.text.trim(),
        'medicalConditions': _medicalConditionsController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
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
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          // Initialize controllers with user data
          if (!_isEditing) {
            _fullNameController.text = user.fullName;
            _phoneController.text = user.phoneNumber ?? '';
            _addressController.text = user.address ?? '';
            _selectedBloodType = user.bloodType;
            _emergencyContactController.text = user.emergencyContact ?? '';
            _emergencyPhoneController.text = user.emergencyPhone ?? '';
            _allergiesController.text = user.allergies ?? '';
            _medicalConditionsController.text = user.medicalConditions ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user.fullName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Information Section
                  _buildSectionHeader('Personal Information'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on,
                    enabled: _isEditing,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Medical Information Section
                  _buildSectionHeader('Medical Information'),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Blood Type',
                    icon: Icons.bloodtype,
                    value: _selectedBloodType,
                    items: AppConstants.bloodTypes,
                    enabled: _isEditing,
                    onChanged: (value) => setState(() => _selectedBloodType = value),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _allergiesController,
                    label: 'Allergies',
                    icon: Icons.warning_amber,
                    enabled: _isEditing,
                    maxLines: 2,
                    hint: 'List any known allergies',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _medicalConditionsController,
                    label: 'Medical Conditions',
                    icon: Icons.medical_information,
                    enabled: _isEditing,
                    maxLines: 2,
                    hint: 'List any chronic conditions',
                  ),
                  const SizedBox(height: 24),

                  // Emergency Contact Section
                  _buildSectionHeader('Emergency Contact'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emergencyContactController,
                    label: 'Contact Name',
                    icon: Icons.contact_emergency,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emergencyPhoneController,
                    label: 'Contact Phone',
                    icon: Icons.phone_in_talk,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isEditing = false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _updateProfile(user.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => AuthUtils.handleLogout(context, ref),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.error),
                      ),
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    int maxLines = 1,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: enabled ? AppColors.primary : Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
        ),
        validator: (value) {
          if (label.contains('Name') || label.contains('Phone')) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required bool enabled,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: enabled ? AppColors.primary : Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
