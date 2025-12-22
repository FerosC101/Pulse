import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/auth_service.dart';
import '../../../data/models/user_type.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';
import '../doctor/doctor_dashboard_screen.dart';
import '../staff/staff_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

/// Register page - Dynamic registration form based on user role
class RegisterPage extends StatefulWidget {
  final String? userRole;

  const RegisterPage({Key? key, this.userRole}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  
  // Common fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Patient-specific fields
  final _addressController = TextEditingController();
  String? _selectedBloodType;
  
  // Doctor-specific fields
  final _specialtyController = TextEditingController();
  final _licenseController = TextEditingController();
  String? _selectedHospitalId;
  String? _selectedHospitalName;
  
  // Staff-specific fields
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  
  // Terms and conditions
  bool _agreesToTerms = false;

  @override
  void initState() {
    super.initState();
    // Reset all form fields to ensure clean state
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _addressController.clear();
    _specialtyController.clear();
    _licenseController.clear();
    _positionController.clear();
    _departmentController.clear();
    _selectedBloodType = null;
    _selectedHospitalId = null;
    _selectedHospitalName = null;
    _agreesToTerms = false;
    
    // Fetch hospitals for doctor and staff roles
    if (widget.userRole == AppConstants.roleDoctor || 
        widget.userRole == AppConstants.roleStaff) {
      _fetchFirstHospital();
    }
  }

  Future<void> _fetchFirstHospital() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('hospitals')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty && mounted) {
        setState(() {
          _selectedHospitalId = snap.docs.first.id;
          _selectedHospitalName = snap.docs.first.data()['name'] as String?;
        });
      }
    } catch (_) {
      // Ignore errors - StreamBuilder will handle it
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specialtyController.dispose();
    _licenseController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreesToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare role-specific data
      final Map<String, dynamic> additionalData = {};

      switch (widget.userRole) {
        case AppConstants.rolePatient:
          additionalData['address'] = _addressController.text;
          if (_selectedBloodType != null) {
            additionalData['bloodType'] = _selectedBloodType;
          }
          break;
        case AppConstants.roleDoctor:
          additionalData['specialty'] = _specialtyController.text;
          additionalData['licenseNumber'] = _licenseController.text;
          additionalData['hospitalId'] = _selectedHospitalId;
          break;
        case AppConstants.roleStaff:
          additionalData['position'] = _positionController.text;
          additionalData['department'] = _departmentController.text;
          additionalData['staffHospitalId'] = _selectedHospitalId;
          additionalData['staffHospitalName'] = _selectedHospitalName;
          additionalData['permissions'] = ['bed_management', 'patient_management'];
          break;
        case AppConstants.roleAdmin:
          additionalData['permissions'] = ['full_access'];
          break;
      }

      // Register with Firebase
      final userModel = await _authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        userType: _getUserType(widget.userRole),
        phoneNumber: _phoneController.text.trim(),
        additionalData: additionalData,
      );

      if (!mounted) return;

      if (userModel != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${userModel.fullName}! Registration successful.'),
            backgroundColor: AppColors.secondary,
          ),
        );

        // Route to appropriate dashboard
        Widget dashboard;
        switch (widget.userRole) {
          case AppConstants.rolePatient:
            dashboard = const HomeScreen();
            break;
          case AppConstants.roleDoctor:
            dashboard = const DoctorDashboardScreen();
            break;
          case AppConstants.roleStaff:
            dashboard = const StaffDashboardScreen();
            break;
          case AppConstants.roleAdmin:
            dashboard = const AdminDashboardScreen();
            break;
          default:
            dashboard = const HomeScreen();
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => dashboard),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  UserType _getUserType(String? role) {
    switch (role) {
      case AppConstants.roleDoctor:
        return UserType.doctor;
      case AppConstants.roleStaff:
        return UserType.hospitalStaff;
      case AppConstants.roleAdmin:
        return UserType.admin;
      case AppConstants.rolePatient:
      default:
        return UserType.patient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                _buildProgressIndicator(),
                const SizedBox(height: 32),
                // Dynamic Title based on role
                Center(
                  child: Text(
                    'Register as ${_getRoleDisplayName()}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Fill in your details to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Full Name field
                CustomTextField(
                  controller: _fullNameController,
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email field
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                // Phone field
                CustomTextField(
                  controller: _phoneController,
                  hintText: '+63 XXX XXX XXXX',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                
                // Dynamic role-specific fields
                ..._buildRoleSpecificFields(),
                
                // Password field
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Create a strong password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                // Confirm Password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 16),
                // Terms and Conditions checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreesToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreesToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            'I agree to the ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Open Terms and Conditions
                            },
                            child: Text(
                              'Terms and Conditions',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Text(
                            ' and ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Open Privacy Policy
                            },
                            child: Text(
                              'Privacy Policy',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Register button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: 'Register',
                        onPressed: _handleRegister,
                      ),
                const SizedBox(height: 16),
                // Already have account
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppConstants.loginRoute);
                        },
                        child: Text(
                          'Login',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.darkText,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  /// Dynamic form field injection based on user role
  List<Widget> _buildRoleSpecificFields() {
    switch (widget.userRole) {
      case AppConstants.rolePatient:
        return _buildPatientFields();
      case AppConstants.roleDoctor:
        return _buildDoctorFields();
      case AppConstants.roleStaff:
        return _buildStaffFields();
      case AppConstants.roleAdmin:
        return _buildAdminFields();
      default:
        return [];
    }
  }

  /// Patient-specific fields: Address and Blood Type
  List<Widget> _buildPatientFields() {
    return [
      CustomTextField(
        controller: _addressController,
        hintText: 'Enter your complete address',
        prefixIcon: Icons.location_on_outlined,
        maxLines: 1,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Address is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        hintText: 'Enter your blood type',
        prefixIcon: Icons.bloodtype_outlined,
        isDropdown: true,
        dropdownItems: AppConstants.bloodTypes,
        dropdownValue: _selectedBloodType,
        onDropdownChanged: (value) {
          setState(() {
            _selectedBloodType = value;
          });
        },
      ),
      const SizedBox(height: 16),
    ];
  }

  /// Doctor-specific fields: Hospital, Specialty, License Number
  List<Widget> _buildDoctorFields() {
    return [
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final hospitals = snapshot.data?.docs ?? [];

          return DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hospitals.isEmpty 
                  ? 'No hospitals available - Contact admin' 
                  : 'Enter your hospital',
                  prefixIcon: const Icon(Icons.local_hospital, color: AppColors.grey, size: 20),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey),
                dropdownColor: AppColors.white,
                style: Theme.of(context).textTheme.bodyLarge,
                items: hospitals.isEmpty
                    ? null
                    : hospitals.map((doc) {
                        final data = doc.data() as Map<String, dynamic>? ?? {};
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(
                            data['name'] ?? 'Unknown Hospital',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                onChanged: hospitals.isEmpty ? null : (value) {
                  setState(() {
                    _selectedHospitalId = value;
                    final hospitalDoc = hospitals.firstWhere((doc) => doc.id == value);
                    final data = hospitalDoc.data() as Map<String, dynamic>? ?? {};
                    _selectedHospitalName = data['name'] as String?;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a hospital';
                  }
                  return null;
                },
              );
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _specialtyController,
        hintText: 'e.g., Cardiology, Pediatrics',
        prefixIcon: Icons.medical_services_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Specialty is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _licenseController,
        hintText: 'Enter your medical license number',
        prefixIcon: Icons.badge_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'License number is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
    ];
  }

  /// Staff-specific fields: Hospital, Position, Department
  List<Widget> _buildStaffFields() {
    return [
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final hospitals = snapshot.data?.docs ?? [];

          return DropdownButtonFormField<String>(
            value: hospitals.isEmpty ? null : _selectedHospitalId,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hospitals.isEmpty 
                  ? 'No hospitals available - Contact admin' 
                  : 'Enter your hospital',
                  prefixIcon: const Icon(Icons.local_hospital, color: AppColors.grey, size: 20),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey),
                dropdownColor: AppColors.white,
                style: Theme.of(context).textTheme.bodyLarge,
                items: hospitals.isEmpty
                    ? null
                    : hospitals.map((doc) {
                        final data = doc.data() as Map<String, dynamic>? ?? {};
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(
                            data['name'] ?? 'Unknown Hospital',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                onChanged: hospitals.isEmpty ? null : (value) {
                  setState(() {
                    _selectedHospitalId = value;
                    final hospitalDoc = hospitals.firstWhere((doc) => doc.id == value);
                    final data = hospitalDoc.data() as Map<String, dynamic>? ?? {};
                    _selectedHospitalName = data['name'] as String?;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your workplace';
                  }
                  return null;
                },
              );
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _positionController,
        hintText: 'e.g., Nurse, Receptionist',
        prefixIcon: Icons.work_outline,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Position is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _departmentController,
        hintText: 'e.g., Emergency, ICU',
        prefixIcon: Icons.apartment_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Department is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
    ];
  }

  /// Admin-specific fields (none required)
  List<Widget> _buildAdminFields() {
    return [];
  }

  Widget _buildRoleBadge() {
    IconData roleIcon;
    String roleText;
    
    switch (widget.userRole) {
      case AppConstants.rolePatient:
        roleIcon = Icons.person;
        roleText = 'Register as Patient';
        break;
      case AppConstants.roleDoctor:
        roleIcon = Icons.medical_services;
        roleText = 'Register as Doctor';
        break;
      case AppConstants.roleStaff:
        roleIcon = Icons.badge;
        roleText = 'Register as Hospital Staff';
        break;
      case AppConstants.roleAdmin:
        roleIcon = Icons.admin_panel_settings;
        roleText = 'Register as System Administrator';
        break;
      default:
        roleIcon = Icons.person;
        roleText = 'Register as Patient';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            roleIcon,
            size: 20,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            roleText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName() {
    switch (widget.userRole) {
      case AppConstants.rolePatient:
        return 'Patient';
      case AppConstants.roleDoctor:
        return 'Doctor';
      case AppConstants.roleStaff:
        return 'Hospital Staff';
      case AppConstants.roleAdmin:
        return 'Admin';
      default:
        return 'Patient';
    }
  }
}
