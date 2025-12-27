// lib/presentation/screens/staff/tabs/overview_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/presentation/screens/staff/tabs/overview_tab_redesigned.dart';

class OverviewTab extends ConsumerWidget {
  final String hospitalId;

  const OverviewTab({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the redesigned version
    return OverviewTabRedesigned(hospitalId: hospitalId);
  }
}
