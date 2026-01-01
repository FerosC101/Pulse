// lib/presentation/screens/doctor/appointment_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:pulse/data/models/appointment_model.dart';
import 'appointment_detail_screen_redesigned.dart';

/// Wrapper for backward compatibility
/// Redirects to the redesigned appointment detail screen
class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return AppointmentDetailScreenRedesigned(appointment: appointment);
  }
}
