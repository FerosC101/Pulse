// lib/presentation/screens/admin/widgets/staff_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class StaffDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> staffData;

  const StaffDetailsDialog({
    super.key,
    required this.staffData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      staffData['fullName']?.substring(0, 1).toUpperCase() ?? 'S',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staffData['fullName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${staffData['position']} • ${staffData['department']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Contact Information',
                      Icons.contact_mail,
                      [
                        _buildInfoRow('Email', staffData['email'] ?? 'N/A', Icons.email),
                        _buildInfoRow('Phone', staffData['phone'] ?? 'N/A', Icons.phone),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      'Employment Details',
                      Icons.work,
                      [
                        _buildInfoRow('Hospital', staffData['staffHospitalName'] ?? 'N/A', Icons.local_hospital),
                        _buildInfoRow('Position', staffData['position'] ?? 'N/A', Icons.badge),
                        _buildInfoRow('Department', staffData['department'] ?? 'N/A', Icons.business_center),
                        _buildInfoRow('Employee ID', staffData['employeeId'] ?? 'N/A', Icons.credit_card),
                        if (staffData['hireDate'] != null)
                          _buildInfoRow(
                            'Hire Date',
                            _formatDate(staffData['hireDate']),
                            Icons.calendar_today,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (staffData['credentials'] != null && (staffData['credentials'] as List).isNotEmpty)
                      ...[
                        _buildSection(
                          'Credentials & Certifications',
                          Icons.verified_user,
                          [
                            ...(staffData['credentials'] as List).map((credential) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.success.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        color: AppColors.success,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          credential.toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                    if (staffData['specializations'] != null && (staffData['specializations'] as List).isNotEmpty)
                      ...[
                        _buildSection(
                          'Specializations',
                          Icons.star,
                          [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (staffData['specializations'] as List).map((spec) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.info.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    spec.toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.info,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                    _buildSection(
                      'Account Information',
                      Icons.account_circle,
                      [
                        _buildInfoRow('User ID', staffData['uid'] ?? 'N/A', Icons.fingerprint),
                        _buildInfoRow('User Type', staffData['userType'] ?? 'N/A', Icons.person),
                        if (staffData['createdAt'] != null)
                          _buildInfoRow(
                            'Account Created',
                            _formatDate(staffData['createdAt']),
                            Icons.event,
                          ),
                        if (staffData['lastLogin'] != null)
                          _buildInfoRow(
                            'Last Login',
                            _formatDate(staffData['lastLogin']),
                            Icons.login,
                          ),
                      ],
                    ),

                    if (staffData['notes'] != null && staffData['notes'].toString().isNotEmpty)
                      ...[
                        const SizedBox(height: 24),
                        _buildSection(
                          'Additional Notes',
                          Icons.notes,
                          [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                staffData['notes'].toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    try {
      DateTime dateTime;
      if (date is DateTime) {
        dateTime = date;
      } else if (date is String) {
        dateTime = DateTime.parse(date);
      } else {
        return date.toString();
      }
      
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }
}
