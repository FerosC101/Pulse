import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';

/// Role selection page - User chooses their role (Patient, Doctor, Staff, Admin)
class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({Key? key}) : super(key: key);

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole;
  String? _hoveredRole;

  @override
  void initState() {
    super.initState();
    // Ensure clean state - reset role selection
    _selectedRole = null;
    _hoveredRole = null;
  }

  final List<Map<String, dynamic>> _roles = [
    {
      'name': 'Patient',
      'value': AppConstants.rolePatient,
      'icon': Icons.person,
    },
    {
      'name': 'Doctor',
      'value': AppConstants.roleDoctor,
      'icon': Icons.medical_services,
    },
    {
      'name': 'Staff',
      'value': AppConstants.roleStaff,
      'icon': Icons.badge,
    },
    {
      'name': 'Admin',
      'value': AppConstants.roleAdmin,
      'icon': Icons.admin_panel_settings,
    },
  ];

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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              const SizedBox(height: 40),
              // Title
              Center(
                child: Text(
                  'Select user type',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 40),
              // Role cards column
              Expanded(
                child: ListView.builder(
                  itemCount: _roles.length,
                  itemBuilder: (context, index) {
                    final role = _roles[index];
                    final isSelected = _selectedRole == role['value'];
                    final isHovered = _hoveredRole == role['value'];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _hoveredRole = role['value']),
                        onExit: (_) => setState(() => _hoveredRole = null),
                        child: _buildRoleCard(
                          role: role['name'],
                          icon: role['icon'],
                          isSelected: isSelected,
                          isHovered: isHovered,
                          onTap: () {
                            setState(() {
                              _selectedRole = role['value'];
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Next button
              PrimaryButton(
                text: 'Next',
                onPressed: _selectedRole != null
                    ? () {
                        Navigator.pushNamed(
                          context,
                          AppConstants.registerRoute,
                          arguments: _selectedRole,
                        );
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a user type'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required bool isSelected,
    required bool isHovered,
    required VoidCallback onTap,
  }) {
    Color getCardColor() {
      if (isSelected) return AppColors.primary;
      if (isHovered) return AppColors.secondary;
      return AppColors.white;
    }

    Color getIconColor() {
      if (isSelected || isHovered) return AppColors.white;
      return AppColors.grey;
    }

    Color getTextColor() {
      if (isSelected || isHovered) return AppColors.white;
      return AppColors.darkText;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: getCardColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: getIconColor(),
            ),
            const SizedBox(width: 16),
            Text(
              role,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: getTextColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_drop_down,
              size: 24,
              color: getIconColor(),
            ),
          ],
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
            color: AppColors.darkText,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
