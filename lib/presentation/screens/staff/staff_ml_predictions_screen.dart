// lib/presentation/screens/staff/staff_ml_predictions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/presentation/screens/staff/staff_ml_predictions_redesigned.dart';

class StaffMLPredictionsScreen extends ConsumerWidget {
  final String hospitalId;

  const StaffMLPredictionsScreen({
    super.key,
    required this.hospitalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the redesigned version
    return StaffMLPredictionsRedesigned(hospitalId: hospitalId);
  }
}
