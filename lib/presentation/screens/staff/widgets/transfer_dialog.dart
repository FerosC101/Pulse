// lib/presentation/screens/staff/widgets/transfer_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/data/models/patient_model.dart';
import 'package:pulse/presentation/providers/patient_provider.dart';

class TransferDialog extends ConsumerStatefulWidget {
  final String hospitalId;

  const TransferDialog({super.key, required this.hospitalId});

  @override
  ConsumerState<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bedNumberController = TextEditingController();
  bool _isLoading = false;
  String? _selectedPatientId;
  String _selectedDepartment = 'ICU';
  
  final List<String> _departments = ['ICU', 'Emergency', 'General Ward', 'Pediatrics', 'Neurology'];

  @override
  void dispose() {
    _bedNumberController.dispose();
    super.dispose();
  }

  Future<void> _transferPatient() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(patientControllerProvider.notifier).transferPatient(
        _selectedPatientId!,
        _selectedDepartment,
        _bedNumberController.text.trim().isNotEmpty ? _bedNumberController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient transferred successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
    final patientsAsync = ref.watch(patientsStreamProvider(widget.hospitalId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transfer Patient',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Patient',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      patientsAsync.when(
                        data: (patients) {
                          return DropdownButtonFormField<String>(
                            value: _selectedPatientId,
                            decoration: InputDecoration(
                              hintText: 'Select a patient to transfer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: patients.map((patient) {
                              return DropdownMenuItem<String>(
                                value: patient.id,
                                child: Text('${patient.fullName} - ${patient.department}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedPatientId = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a patient';
                              }
                              return null;
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Text('Error loading patients: $error'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Transfer To Department',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _departments.map((dept) {
                          return DropdownMenuItem<String>(
                            value: dept,
                            child: Text(dept),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedDepartment = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bed Number (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bedNumberController,
                        decoration: InputDecoration(
                          hintText: 'e.g., ICU-101',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _transferPatient,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.warning,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : const Text('Transfer', style: TextStyle(color: Colors.white)),
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
}
