// lib/presentation/screens/staff/widgets/add_to_queue_dialog_redesigned.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulse/data/models/patient_model.dart';
import 'package:pulse/presentation/providers/queue_provider.dart';

class AddToQueueDialogRedesigned extends ConsumerStatefulWidget {
  final String hospitalId;

  const AddToQueueDialogRedesigned({super.key, required this.hospitalId});

  @override
  ConsumerState<AddToQueueDialogRedesigned> createState() => _AddToQueueDialogRedesignedState();
}

class _AddToQueueDialogRedesignedState extends ConsumerState<AddToQueueDialogRedesigned> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedDepartment = 'Emergency';
  TriageLevel _selectedTriage = TriageLevel.semiUrgent;
  bool _isLoading = false;

  final List<String> _departments = ['ICU', 'Emergency', 'General Ward', 'Pediatrics', 'Neurology'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Future<void> _addToQueue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final queueData = {
        'patientName': _nameController.text.trim(),
        'age': int.parse(_ageController.text),
        'gender': _selectedGender,
        'condition': _conditionController.text.trim(),
        'department': _selectedDepartment,
        'triageLevel': _selectedTriage.name,
        'hospitalId': widget.hospitalId,
        'arrivalTime': DateTime.now().toIso8601String(),
      };

      await ref.read(queueControllerProvider.notifier).addToQueue(queueData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added to queue successfully',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: const Color(0xFF10B981), // Success green
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: const Color(0xFFF7444E), // Primary Red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getTriageColor(TriageLevel level) {
    switch (level) {
      case TriageLevel.critical:
        return const Color(0xFFF7444E); // Primary Red
      case TriageLevel.urgent:
        return Colors.orange;
      case TriageLevel.semiUrgent:
        return Colors.amber;
      case TriageLevel.nonUrgent:
        return const Color(0xFF10B981); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Add to Queue',
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002C3E), // Navy
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF002C3E)),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Name
                      Text(
                        'Patient Name*',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF002C3E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF002C3E)),
                        decoration: InputDecoration(
                          hintText: 'Enter patient name',
                          hintStyle: GoogleFonts.dmSans(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF002C3E), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patient name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Age and Gender Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Age*',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF002C3E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _ageController,
                                  style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF002C3E)),
                                  decoration: InputDecoration(
                                    hintText: 'Age',
                                    hintStyle: GoogleFonts.dmSans(color: Colors.grey[400]),
                                    prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF002C3E), width: 2),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gender*',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF002C3E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF002C3E)),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.wc_outlined, size: 20),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF002C3E), width: 2),
                                    ),
                                  ),
                                  items: ['Male', 'Female', 'Other'].map((gender) {
                                    return DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedGender = value!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Condition
                      Text(
                        'Condition/Complaint*',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF002C3E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _conditionController,
                        style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF002C3E)),
                        decoration: InputDecoration(
                          hintText: 'Enter condition or complaint',
                          hintStyle: GoogleFonts.dmSans(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.medical_information_outlined, size: 20),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF002C3E), width: 2),
                          ),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter condition';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Department
                      Text(
                        'Department*',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF002C3E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF002C3E)),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF002C3E), width: 2),
                          ),
                        ),
                        items: _departments.map((dept) {
                          return DropdownMenuItem(value: dept, child: Text(dept));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedDepartment = value!);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Triage Level
                      Text(
                        'Priority Level*',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF002C3E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...TriageLevel.values.map((level) {
                        final color = _getTriageColor(level);
                        final isSelected = _selectedTriage == level;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedTriage = level);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Radio button
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? color : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: color,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      level.displayName,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF002C3E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF002C3E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF002C3E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addToQueue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF002C3E), // Navy
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                              'Add to Queue',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
}
