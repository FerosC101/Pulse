// lib/presentation/screens/admin/system_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Analytics Data Providers
final totalHospitalsProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('hospitals')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

final totalDoctorsProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('doctors')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

final totalStaffProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('userType', isEqualTo: 'hospitalStaff')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

final totalPatientsProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('userType', isEqualTo: 'patient')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// Staff distribution per hospital
final staffDistributionProvider = StreamProvider<Map<String, int>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('userType', isEqualTo: 'hospitalStaff')
      .snapshots()
      .map((snapshot) {
    final distribution = <String, int>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final hospital = data['staffHospitalName'] ?? 'Unassigned';
      distribution[hospital] = (distribution[hospital] ?? 0) + 1;
    }
    return distribution;
  });
});

// Monthly registration trends (last 6 months)
final monthlyRegistrationProvider = StreamProvider<List<MonthlyData>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    final monthlyData = <String, MonthlyData>{};
    final now = DateTime.now();
    
    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('MMM yyyy').format(month);
      monthlyData[monthKey] = MonthlyData(month: monthKey, count: 0);
    }
    
    // Count registrations
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['createdAt'] != null) {
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final monthKey = DateFormat('MMM yyyy').format(createdAt);
        
        if (monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = MonthlyData(
            month: monthKey,
            count: monthlyData[monthKey]!.count + 1,
          );
        }
      }
    }
    
    return monthlyData.values.toList();
  });
});

class MonthlyData {
  final String month;
  final int count;
  
  MonthlyData({required this.month, required this.count});
}

class SystemAnalyticsScreen extends ConsumerWidget {
  const SystemAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsCount = ref.watch(totalHospitalsProvider);
    final doctorsCount = ref.watch(totalDoctorsProvider);
    final staffCount = ref.watch(totalStaffProvider);
    final patientsCount = ref.watch(totalPatientsProvider);
    final staffDistribution = ref.watch(staffDistributionProvider);
    final monthlyRegistration = ref.watch(monthlyRegistrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Platform Overview',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time system metrics and trends',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Hospitals',
                    value: hospitalsCount.when(
                      data: (count) => count.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    icon: Icons.local_hospital,
                    color: AppColors.primary,
                    context: context,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Doctors',
                    value: doctorsCount.when(
                      data: (count) => count.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    icon: Icons.medical_services,
                    color: AppColors.success,
                    context: context,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Nurses',
                    value: staffCount.when(
                      data: (count) => count.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    icon: Icons.people,
                    color: AppColors.info,
                    context: context,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Patients',
                    value: patientsCount.when(
                      data: (count) => count.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    icon: Icons.person,
                    color: AppColors.warning,
                    context: context,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Charts Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Staff Distribution Chart
                Expanded(
                  flex: 5,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.bar_chart,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Staff Distribution per Hospital',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          staffDistribution.when(
                            data: (distribution) {
                              if (distribution.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Text('No staff data available'),
                                  ),
                                );
                              }
                              return SizedBox(
                                height: 300,
                                child: _buildStaffDistributionChart(distribution),
                              );
                            },
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (_, __) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('Error loading data'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Monthly Registration Trends
                Expanded(
                  flex: 5,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.trending_up,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Monthly Registration Trends',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          monthlyRegistration.when(
                            data: (data) {
                              if (data.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Text('No registration data available'),
                                  ),
                                );
                              }
                              return SizedBox(
                                height: 300,
                                child: _buildRegistrationTrendsChart(data),
                              );
                            },
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (_, __) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('Error loading data'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffDistributionChart(Map<String, int> distribution) {
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final maxValue = sortedEntries.isEmpty ? 10 : sortedEntries.first.value;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue.toDouble() * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${sortedEntries[group.x.toInt()].key}\n${rod.toY.toInt()} staff',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedEntries.length) {
                  return const Text('');
                }
                final entry = sortedEntries[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    entry.key.length > 10
                        ? '${entry.key.substring(0, 10)}...'
                        : entry.key,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 5,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          sortedEntries.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: sortedEntries[index].value.toDouble(),
                color: AppColors.primary,
                width: 32,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationTrendsChart(List<MonthlyData> data) {
    final maxValue = data.isEmpty ? 10 : data.map((e) => e.count).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue > 0 ? maxValue / 5 : 1,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) {
                  return const Text('');
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[value.toInt()].month,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxValue.toDouble() * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (index) => FlSpot(index.toDouble(), data[index].count.toDouble()),
            ),
            isCurved: true,
            color: AppColors.success,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: AppColors.success,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.success.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${data[spot.x.toInt()].month}\n${spot.y.toInt()} registrations',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
