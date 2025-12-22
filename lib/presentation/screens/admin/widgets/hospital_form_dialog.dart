// lib/presentation/screens/admin/widgets/hospital_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/data/models/hospital_model.dart';
import 'package:pulse/services/model_3d_service.dart';
import 'package:pulse/services/image_upload_service.dart';
import 'package:file_picker/file_picker.dart';

class HospitalFormDialog extends ConsumerStatefulWidget {
  final HospitalModel? hospital;

  const HospitalFormDialog({
    super.key,
    this.hospital,
  });

  @override
  ConsumerState<HospitalFormDialog> createState() => _HospitalFormDialogState();
}

class _HospitalFormDialogState extends ConsumerState<HospitalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final Model3DService _model3DService = Model3DService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _longController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _icuTotalController;
  late TextEditingController _erTotalController;
  late TextEditingController _wardTotalController;
  late TextEditingController _floorsController;
  
  String _selectedType = 'public';
  List<String> _selectedServices = [];
  List<String> _selectedSpecialties = [];
  
  // Image Upload State
  PlatformFile? _selectedImage;
  String? _selectedImageFileName;
  
  // 3D Model Upload State
  PlatformFile? _selected3DModel;
  String? _selectedModelFileName;
  final bool _isUploadingModel = false;
  final double _uploadProgress = 0.0;
  
  final List<String> _hospitalTypes = ['public', 'private', 'specialty'];
  final List<String> _availableServices = [
    'Emergency',
    'ICU',
    'Surgery',
    'Pharmacy',
    'Laboratory',
    'Radiology',
    'Outpatient',
    'Inpatient',
  ];
  final List<String> _availableSpecialties = [
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Oncology',
    'General Surgery',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hospital?.name ?? '');
    _addressController = TextEditingController(text: widget.hospital?.address ?? '');
    _latController = TextEditingController(text: widget.hospital?.latitude.toString() ?? '');
    _longController = TextEditingController(text: widget.hospital?.longitude.toString() ?? '');
    _phoneController = TextEditingController(text: widget.hospital?.phone ?? '');
    _emailController = TextEditingController(text: widget.hospital?.email ?? '');
    
    _icuTotalController = TextEditingController(
      text: widget.hospital?.status.icuTotal.toString() ?? ''
    );
    _erTotalController = TextEditingController(
      text: widget.hospital?.status.erTotal.toString() ?? ''
    );
    _wardTotalController = TextEditingController(
      text: widget.hospital?.status.wardTotal.toString() ?? ''
    );
    _floorsController = TextEditingController(
      text: widget.hospital?.modelMetadata?.floors.toString() ?? ''
    );
    
    if (widget.hospital != null) {
      _selectedType = widget.hospital!.type;
      _selectedServices = List.from(widget.hospital!.services);
      _selectedSpecialties = List.from(widget.hospital!.specialties);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _longController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _icuTotalController.dispose();
    _erTotalController.dispose();
    _wardTotalController.dispose();
    _floorsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pf = await _imageUploadService.pickImageFile();
      if (pf != null) {
        setState(() {
          _selectedImage = pf;
          _selectedImageFileName = pf.name;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image selected: $_selectedImageFileName'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pick3DModel() async {
    try {
      final pf = await _model3DService.pickModelFile();
      if (pf != null) {
        setState(() {
          _selected3DModel = pf;
          _selectedModelFileName = pf.name;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected: $_selectedModelFileName'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Return hospital data + image file + 3D model file
      Navigator.pop(context, {
        'hospitalData': {
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'latitude': double.tryParse(_latController.text) ?? 0.0,
          'longitude': double.tryParse(_longController.text) ?? 0.0,
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'type': _selectedType,
          'services': _selectedServices,
          'specialties': _selectedSpecialties,
          'status': {
            'icuTotal': int.tryParse(_icuTotalController.text) ?? 0,
            'icuOccupied': widget.hospital?.status.icuOccupied ?? 0,
            'erTotal': int.tryParse(_erTotalController.text) ?? 0,
            'erOccupied': widget.hospital?.status.erOccupied ?? 0,
            'wardTotal': int.tryParse(_wardTotalController.text) ?? 0,
            'wardOccupied': widget.hospital?.status.wardOccupied ?? 0,
            'waitTimeMinutes': widget.hospital?.status.waitTimeMinutes ?? 15,
            'isOperational': widget.hospital?.status.isOperational ?? true,
          },
        },
        'imageFile': _selectedImage,
        'existingImageUrl': widget.hospital?.imageUrl,
        'model3DFile': _selected3DModel,
        'floors': int.tryParse(_floorsController.text) ?? 3,
        'existingModelUrl': widget.hospital?.model3dUrl,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      widget.hospital == null ? 'Add Hospital' : 'Edit Hospital',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.darkText),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload
                      Row(
                        children: [
                          Text(
                            'Hospital Image',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            ' *',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDashedButton(
                        label: _selectedImageFileName ?? (widget.hospital?.imageUrl != null ? 'Change Image' : 'Select Image'),
                        icon: widget.hospital?.imageUrl != null ? Icons.edit : Icons.add,
                        onTap: _pickImage,
                        hasExistingFile: widget.hospital?.imageUrl != null,
                      ),
                      const SizedBox(height: 20),
                      
                      // 3D Model Section
                      Text(
                        '3D Building Model (optional)',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDashedButton(
                        label: _selectedModelFileName ?? (widget.hospital?.model3dUrl != null ? 'Change Model' : 'Upload Model'),
                        icon: widget.hospital?.model3dUrl != null ? Icons.edit : Icons.add,
                        onTap: _pick3DModel,
                        hasExistingFile: widget.hospital?.model3dUrl != null,
                      ),
                      const SizedBox(height: 12),
                      _buildStyledTextField(
                        controller: _floorsController,
                        hint: 'Number of floors',
                        keyboardType: TextInputType.number,
                        suffixIcon: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                int current = int.tryParse(_floorsController.text) ?? 0;
                                _floorsController.text = (current + 1).toString();
                              },
                              child: const Icon(Icons.arrow_drop_up, size: 20),
                            ),
                            InkWell(
                              onTap: () {
                                int current = int.tryParse(_floorsController.text) ?? 0;
                                if (current > 0) {
                                  _floorsController.text = (current - 1).toString();
                                }
                              },
                              child: const Icon(Icons.arrow_drop_down, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Hospital Information
                      Text(
                        'Hospital Information',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildStyledTextField(
                        controller: _nameController,
                        hint: 'Hospital Name',
                        icon: Icons.local_hospital_outlined,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildStyledTextField(
                        controller: _addressController,
                        hint: 'Address',
                        icon: Icons.location_on_outlined,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStyledTextField(
                              controller: _latController,
                              hint: 'Longtitude',
                              icon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStyledTextField(
                              controller: _longController,
                              hint: 'Latitude',
                              icon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      _buildStyledTextField(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildStyledTextField(
                        controller: _phoneController,
                        hint: 'Phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      
                      // Hospital Type Dropdown
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            hintText: 'Hospital Type',
                            hintStyle: GoogleFonts.dmSans(
                              color: AppColors.darkText.withOpacity(0.4),
                            ),
                            prefixIcon: Icon(
                              Icons.water_drop_outlined,
                              color: AppColors.darkText.withOpacity(0.4),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          items: _hospitalTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Bed Capacity
                      Text(
                        'Bed Capacity',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildNumberField('ICU', _icuTotalController),
                      const SizedBox(height: 12),
                      _buildNumberField('ER', _erTotalController),
                      const SizedBox(height: 12),
                      _buildNumberField('Ward', _wardTotalController),
                      const SizedBox(height: 24),
                      
                      // Services
                      Text(
                        'Services',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableServices.map((service) {
                          final isSelected = _selectedServices.contains(service);
                          return _buildChip(
                            label: service,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedServices.remove(service);
                                } else {
                                  _selectedServices.add(service);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Specialties
                      Text(
                        'Specialties',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableSpecialties.map((specialty) {
                          final isSelected = _selectedSpecialties.contains(specialty);
                          return _buildChip(
                            label: specialty,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSpecialties.remove(specialty);
                                } else {
                                  _selectedSpecialties.add(specialty);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Add Hospital',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
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
      ),
    );
  }

  Widget _buildDashedButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool hasExistingFile = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasExistingFile ? AppColors.success : AppColors.darkText.withOpacity(0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasExistingFile ? AppColors.success.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: hasExistingFile ? AppColors.success : AppColors.darkText.withOpacity(0.6), 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hasExistingFile ? AppColors.success : AppColors.darkText.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
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
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
            color: AppColors.darkText.withOpacity(0.4),
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.darkText.withOpacity(0.4))
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkText.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.darkText.withOpacity(0.6),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  int current = int.tryParse(controller.text) ?? 0;
                  controller.text = (current + 1).toString();
                },
                child: const Icon(Icons.arrow_drop_up, size: 24),
              ),
              InkWell(
                onTap: () {
                  int current = int.tryParse(controller.text) ?? 0;
                  if (current > 0) {
                    controller.text = (current - 1).toString();
                  }
                },
                child: const Icon(Icons.arrow_drop_down, size: 24),
              ),
            ],
          ),
        ],
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
}
