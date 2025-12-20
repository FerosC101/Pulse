// lib/presentation/screens/staff/staff_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/presentation/providers/hospital_provider.dart';
import 'package:pulse/presentation/screens/staff/staff_ml_predictions_screen.dart';
import 'package:fl_chart/fl_chart.dart';

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
  String _timePeriod = 'today';

  @override
  Widget build(BuildContext context) {
    final hospitalAsync = ref.watch(hospitalStreamProvider(widget.hospitalId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _timePeriod,
            onSelected: (value) {
              setState(() {
                _timePeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Today')),
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
            ],
          ),
        ],
      ),
      body: hospitalAsync.when(
        data: (hospital) {
          if (hospital == null) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(hospitalStreamProvider(widget.hospitalId));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Population Health Overview
                  _buildSectionHeader('Population Health Trends'),
                  const SizedBox(height: 16),
                  _buildPopulationHealthCards(hospital),
                  const SizedBox(height: 24),

                  // ML Predictions Button
                  _buildMLButton(context),
                  const SizedBox(height: 24),

                  // Bed Management Insights
                  _buildSectionHeader('Predictive Bed Management'),
                  const SizedBox(height: 16),
                  _buildBedManagementChart(hospital),
                  const SizedBox(height: 24),

                  // Department Performance
                  _buildSectionHeader('Department Performance'),
                  const SizedBox(height: 16),
                  _buildDepartmentPerformance(hospital),
                  const SizedBox(height: 24),

                  // Capacity Alerts
                  _buildSectionHeader('Capacity Alerts'),
                  const SizedBox(height: 16),
                  _buildCapacityAlerts(hospital),
                  const SizedBox(height: 24),

                  // AI Insights
                  _buildSectionHeader('AI Insights'),
                  const SizedBox(height: 16),
                  _buildAIInsights(hospital),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No data available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Analytics will appear when hospital data is available',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPopulationHealthCards(hospital) {
    final totalBeds = hospital.status.totalBeds;
    final totalOccupied = hospital.status.totalOccupied;
    final availableBeds = totalBeds - totalOccupied;
    final occupancyRate = totalBeds > 0 ? (totalOccupied / totalBeds * 100).toInt() : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Total Capacity',
                '$totalBeds',
                '$occupancyRate% occupied',
                Icons.hotel,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'Available Beds',
                '$availableBeds',
                'beds open',
                Icons.check_circle,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'ICU Status',
                '${hospital.status.icuOccupied}/${hospital.status.icuTotal}',
                '${((hospital.status.icuOccupied / hospital.status.icuTotal) * 100).toInt()}% full',
                Icons.local_hospital,
                AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'Avg Wait Time',
                '${hospital.status.waitTimeMinutes} min',
                'current time',
                Icons.access_time,
                AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMLButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffMLPredictionsScreen(hospitalId: widget.hospitalId),
            ),
          );
        },
        icon: const Icon(Icons.psychology, size: 24),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'View ML Predictions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '4 Models',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBedManagementChart(hospital) {
    final icuOccupied = hospital.status.icuOccupied;
    final icuTotal = hospital.status.icuTotal;
    final erOccupied = hospital.status.erOccupied;
    final erTotal = hospital.status.erTotal;
    final wardOccupied = hospital.status.wardOccupied;
    final wardTotal = hospital.status.wardTotal;

    final double icuRate = icuTotal > 0 ? (icuOccupied / icuTotal * 100) : 0.0;
    final double erRate = erTotal > 0 ? (erOccupied / erTotal * 100) : 0.0;
    final double wardRate = wardTotal > 0 ? (wardOccupied / wardTotal * 100) : 0.0;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: icuRate,
                  color: AppColors.error,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: erRate,
                  color: AppColors.warning,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: wardRate,
                  color: AppColors.success,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('ICU', style: TextStyle(fontSize: 12));
                    case 1:
                      return const Text('ER', style: TextStyle(fontSize: 12));
                    case 2:
                      return const Text('Ward', style: TextStyle(fontSize: 12));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildDepartmentPerformance(hospital) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDepartmentRow('ICU', hospital.status.icuOccupied, hospital.status.icuTotal, AppColors.error),
          const Divider(height: 24),
          _buildDepartmentRow('Emergency Room', hospital.status.erOccupied, hospital.status.erTotal, AppColors.warning),
          const Divider(height: 24),
          _buildDepartmentRow('General Ward', hospital.status.wardOccupied, hospital.status.wardTotal, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildDepartmentRow(String name, int occupied, int total, Color color) {
    final percentage = total > 0 ? (occupied / total * 100).toInt() : 0;
    
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$occupied / $total beds',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityAlerts(hospital) {
    final alerts = <Map<String, dynamic>>[];

    // ICU alert
    final icuPercentage = (hospital.status.icuOccupied / hospital.status.icuTotal * 100).toInt();
    if (icuPercentage > 85) {
      alerts.add({
        'title': 'ICU Near Capacity',
        'message': 'ICU is at $icuPercentage% capacity. Consider preparing overflow protocols.',
        'severity': 'high',
        'icon': Icons.local_hospital,
      });
    }

    // ER alert
    final erPercentage = (hospital.status.erOccupied / hospital.status.erTotal * 100).toInt();
    if (erPercentage > 80) {
      alerts.add({
        'title': 'ER High Volume',
        'message': 'Emergency room is experiencing high patient volume.',
        'severity': 'medium',
        'icon': Icons.emergency,
      });
    }

    // Wait time alert
    if (hospital.status.waitTimeMinutes > 60) {
      alerts.add({
        'title': 'Long Wait Times',
        'message': 'Current wait time exceeds 1 hour. Additional staff may be needed.',
        'severity': 'medium',
        'icon': Icons.schedule,
      });
    }

    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'All systems operating normally',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: alerts.map((alert) {
        final color = alert['severity'] == 'high' ? AppColors.error : AppColors.warning;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(alert['icon'] as IconData, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert['message'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAIInsights(hospital) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.info.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI-Powered Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            'High probability of ER surge in 2 hours',
            'Based on historical patterns and current trends',
            Icons.trending_up,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'Readmission risk alerts for 3 patients',
            'Consider follow-up care plans for discharged patients',
            Icons.warning_amber,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'Optimal staffing: +2 nurses recommended',
            'Predicted demand increase during evening shift',
            Icons.people,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
