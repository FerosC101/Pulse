// lib/presentation/screens/admin/hospital_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/data/models/hospital_model.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/presentation/screens/admin/widgets/hospital_form_dialog.dart';
import 'package:pulse/services/model_3d_service.dart';
import 'package:pulse/services/image_upload_service.dart';
import 'package:file_picker/file_picker.dart';

class HospitalManagementScreen extends ConsumerWidget {
  const HospitalManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(hospitalsStreamProvider);

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
          'Hospital Management',
          style: GoogleFonts.dmSans(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: hospitalsAsync.when(
        data: (hospitals) {
          if (hospitals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hospitals yet',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: AppColors.darkText.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showHospitalDialog(context, ref, null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add First Hospital',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                itemCount: hospitals.length,
                itemBuilder: (context, index) {
                  final hospital = hospitals[index];
                  return _HospitalCard(
                    hospital: hospital,
                    onEdit: () => _showHospitalDialog(context, ref, hospital),
                    onDelete: () => _confirmDelete(context, ref, hospital),
                  );
                },
              ),
              // Floating Add Button
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: ElevatedButton(
                  onPressed: () => _showHospitalDialog(context, ref, null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: GoogleFonts.dmSans(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(hospitalsStreamProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHospitalDialog(BuildContext context, WidgetRef ref, HospitalModel? hospital) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => HospitalFormDialog(hospital: hospital),
    );

    if (result != null && context.mounted) {
      await _saveHospitalWithImageAndModel(
        context,
        ref,
        result['hospitalData'] as Map<String, dynamic>,
        hospital?.id,
        result['imageFile'] as PlatformFile?,
        result['existingImageUrl'] as String?,
        result['model3DFile'] as PlatformFile?,
        result['floors'] as int,
        result['existingModelUrl'] as String?,
      );
    }
  }

  Future<void> _saveHospitalWithImageAndModel(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> hospitalData,
    String? existingId,
    PlatformFile? imageFile,
    String? existingImageUrl,
    PlatformFile? modelFile,
    int floors,
    String? existingModelUrl,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final hospitalController = ref.read(hospitalControllerProvider.notifier);
      
      if (existingId != null) {
        // UPDATE EXISTING HOSPITAL
        
        // Upload new image if provided
        if (imageFile != null) {
          final imageUploadService = ImageUploadService();

          // Delete old image if exists
          if (existingImageUrl != null && existingImageUrl.contains('firebasestorage')) {
            try {
              await imageUploadService.deleteImage(existingImageUrl);
            } catch (e) {
              // ignore delete errors
            }
          }

          // Upload new image
          final imageUrl = await imageUploadService.uploadHospitalImage(
            platformFile: imageFile,
            hospitalId: existingId,
          );

          hospitalData['imageUrl'] = imageUrl;
        } else if (existingImageUrl != null) {
          // Keep existing image
          hospitalData['imageUrl'] = existingImageUrl;
        }
        
        // Check if we need to upload a new 3D model
        if (modelFile != null) {
          final model3DService = Model3DService();

          // Delete old model if exists
          if (existingModelUrl != null) {
            try {
              await model3DService.deleteModel(existingModelUrl);
            } catch (e) {
              // ignore delete errors
            }
          }

          // Upload new model
          final modelUrl = await model3DService.uploadModel(
            platformFile: modelFile,
            hospitalId: existingId,
          );

          // Add metadata
          hospitalData['model3dUrl'] = modelUrl;
          hospitalData['modelMetadata'] = {
            'floors': floors,
            'modelSizeBytes': modelFile.size,
            'modelFormat': _getModelFormatFromName(modelFile.name),
            'uploadedAt': FieldValue.serverTimestamp(),
            'departments': _generateDepartmentList(hospitalData, floors),
          };
        }
        
        await hospitalController.updateHospital(existingId, hospitalData);
        
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hospital updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // ADD NEW HOSPITAL
        
        // Generate temporary ID for uploads
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Upload image if provided
        if (imageFile != null) {
          final imageUploadService = ImageUploadService();
          final imageUrl = await imageUploadService.uploadHospitalImage(
            platformFile: imageFile,
            hospitalId: tempId,
          );
          hospitalData['imageUrl'] = imageUrl;
        }
        
        final hospitalId = await ref.read(hospitalRepositoryProvider).createHospital(hospitalData);

        // Upload 3D model if provided
        if (modelFile != null) {
          final model3DService = Model3DService();
          final modelUrl = await model3DService.uploadModel(
            platformFile: modelFile,
            hospitalId: hospitalId,
          );

          // Update hospital with 3D model data
          await hospitalController.updateHospital(hospitalId, {
            'model3dUrl': modelUrl,
            'modelMetadata': {
              'floors': floors,
              'modelSizeBytes': modelFile.size,
              'modelFormat': _getModelFormatFromName(modelFile.name),
              'uploadedAt': FieldValue.serverTimestamp(),
              'departments': _generateDepartmentList(hospitalData, floors),
            },
          });
        }
        
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hospital added successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _generateDepartmentList(Map<String, dynamic> hospitalData, int floors) {
    final departments = <Map<String, dynamic>>[];
    final status = hospitalData['status'] as Map<String, dynamic>;
    
    // ICU typically on higher floors
    if (status['icuTotal'] > 0) {
      departments.add({
        'name': 'Intensive Care Unit',
        'type': 'ICU',
        'floor': floors > 1 ? floors - 1 : 1,
        'bedCount': status['icuTotal'],
      });
    }
    
    // ER on ground floor
    if (status['erTotal'] > 0) {
      departments.add({
        'name': 'Emergency Room',
        'type': 'ER',
        'floor': 0,
        'bedCount': status['erTotal'],
      });
    }
    
    // Wards distributed across middle floors
    if (status['wardTotal'] > 0) {
      departments.add({
        'name': 'General Ward',
        'type': 'Ward',
        'floor': floors > 2 ? 1 : 0,
        'bedCount': status['wardTotal'],
      });
    }
    
    return departments;
  }

  String _getModelFormatFromName(String name) {
    final parts = name.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, HospitalModel hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hospital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${hospital.name}"?'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone. All hospital data will be permanently deleted.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Delete 3D model if exists
                if (hospital.model3dUrl != null) {
                  final model3DService = Model3DService();
                  try {
                    await model3DService.deleteModel(hospital.model3dUrl!);
                  } catch (e) {
                    print('Error deleting 3D model: $e');
                  }
                }
                
                await ref.read(hospitalControllerProvider.notifier).deleteHospital(hospital.id);
                
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hospital deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Hospital Card Widget
class _HospitalCard extends StatelessWidget {
  final HospitalModel hospital;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HospitalCard({
    required this.hospital,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hospital Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.darkText.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hospital.imageUrl != null && hospital.imageUrl!.isNotEmpty
                        ? Image.network(
                            hospital.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.local_hospital,
                              color: AppColors.darkText,
                              size: 36,
                            ),
                          )
                        : const Icon(
                            Icons.local_hospital,
                            color: AppColors.darkText,
                            size: 36,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Hospital Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hospital.name,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: AppColors.darkText),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                onEdit();
                              } else if (value == 'delete') {
                                onDelete();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hospital.address,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.darkText.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      
                      // Badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (hospital.has3dModel)
                            _BadgeChip(
                              label: '3D model',
                              color: AppColors.primary,
                            ),
                          _BadgeChip(
                            label: '${(hospital.status.totalOccupied / hospital.status.totalBeds * 100).toInt()}% occupied',
                            color: AppColors.primary,
                          ),
                          _BadgeChip(
                            label: '${hospital.status.totalBeds} beds',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Capacity Bars
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _CapacityBar(
                  label: 'ICU',
                  occupied: hospital.status.icuOccupied,
                  total: hospital.status.icuTotal,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _CapacityBar(
                  label: 'ER',
                  occupied: hospital.status.erOccupied,
                  total: hospital.status.erTotal,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _CapacityBar(
                  label: 'Ward',
                  occupied: hospital.status.wardOccupied,
                  total: hospital.status.wardTotal,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _CapacityBar extends StatelessWidget {
  final String label;
  final int occupied;
  final int total;
  final Color color;

  const _CapacityBar({
    required this.label,
    required this.occupied,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (occupied / total) : 0.0;
    
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$occupied/$total',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}