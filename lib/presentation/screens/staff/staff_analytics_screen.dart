// lib/presentation/screens/staff/staff_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/presentation/screens/staff/staff_analytics_redesigned.dart';

class StaffAnalyticsScreen extends ConsumerStatefulWidget {
  final String hospitalId;

  const StaffAnalyticsScreen({
    super.key,
    required this.hospitalId,
  });

  @override
  ConsumerState<StaffAnalyticsScreen> createState() => _StaffAnalyticsScreenState();
}

class _StaffAnalyticsScreenState extends ConsumerState<StaffAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    // Use the redesigned version
    return StaffAnalyticsRedesigned(hospitalId: widget.hospitalId);
  }
}
