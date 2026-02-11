import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_services.dart';
import '../services/download_service.dart';
import '../constants/app_colors.dart';
import '../gen/l10n/app_localizations.dart';
import 'login.dart';
import 'citizen_profile_edit.dart';

class GovernmentDashboard extends StatefulWidget {
  const GovernmentDashboard({Key? key}) : super(key: key);

  @override
  State<GovernmentDashboard> createState() => _GovernmentDashboardState();
}

class _GovernmentDashboardState extends State<GovernmentDashboard> {
  late Future<Map<String, dynamic>> _analyticsFuture;
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = ApiService.getGovernmentAnalytics();
    
    // Auto-refresh analytics every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 120), (_) {
      if (mounted) {
        setState(() {
          _analyticsFuture = ApiService.getGovernmentAnalytics();
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> _downloadAnalyticsCSV() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing ETA Analysis Report...')),
      );

      // Get JWT token from ApiService
      final authToken = await ApiService.getToken();
      print('[Download] Token retrieved: ${authToken != null ? "YES" : "NO"}');

      if (authToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication required. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Build the API URL
      final apiUrl = '${ApiService.baseUrl}/government/download/analytics-csv';
      print('[Download] URL: $apiUrl');
      print('[Download] Token: ${authToken.substring(0, 20)}...');

      // Make HTTP request with JWT authentication
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'text/csv',
        },
      ).timeout(const Duration(seconds: 30));

      print('[Download] Status Code: ${response.statusCode}');
      print('[Download] Response Length: ${response.bodyBytes.length} bytes');

      if (response.statusCode == 200) {
        print('[Download] CSV Data received: ${response.body.length} characters');

        if (mounted) {
          // Use unified DownloadService for cross-platform support
          await DownloadService.downloadFile(
            'ETA_Analysis_Report_${DateTime.now().millisecondsSinceEpoch}.csv',
            response.bodyBytes,
            mimeType: 'text/csv',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report downloaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (response.statusCode == 403) {
        print('[Download] Unauthorized - Status 403');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unauthorized: Government access required'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('[Download] Failed - Status ${response.statusCode}');
        print('[Download] Response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('[Download] Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadHospitalsCSV() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing Hospital Details Report...')),
      );

      // Get JWT token from ApiService
      final authToken = await ApiService.getToken();
      print('[Download] Token retrieved: ${authToken != null ? "YES" : "NO"}');

      if (authToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication required. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Build the API URL
      final apiUrl = '${ApiService.baseUrl}/government/download/hospitals-csv';
      print('[Download] URL: $apiUrl');
      print('[Download] Token: ${authToken.substring(0, 20)}...');

      // Make HTTP request with JWT authentication
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'text/csv',
        },
      ).timeout(const Duration(seconds: 30));

      print('[Download] Status Code: ${response.statusCode}');
      print('[Download] Response Length: ${response.bodyBytes.length} bytes');

      if (response.statusCode == 200) {
        print('[Download] CSV Data received: ${response.body.length} characters');

        if (mounted) {
          // Use unified DownloadService for cross-platform support
          await DownloadService.downloadFile(
            'Hospital_Details_Report_${DateTime.now().millisecondsSinceEpoch}.csv',
            response.bodyBytes,
            mimeType: 'text/csv',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report downloaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (response.statusCode == 403) {
        print('[Download] Unauthorized - Status 403');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unauthorized: Government access required'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('[Download] Failed - Status ${response.statusCode}');
        print('[Download] Response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('[Download] Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.health_analytics,
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: loc.refresh_data,
            onPressed: () {
              setState(() {
                _analyticsFuture = ApiService.getGovernmentAnalytics();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emergency.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.emergency,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _analyticsFuture = ApiService.getGovernmentAnalytics();
                      });
                    },
                    child: Text(loc.retry),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: Text(loc.no_data));
          }

          final data = snapshot.data!;

          Widget buildRow(String label, String value) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }

          Widget buildNested(String label, Map m) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...m.keys.map((k) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(k),
                              Text('${m[k]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  buildRow(loc.active_hospitals, '${data['active_hospitals'] ?? 0}'),
                  buildRow(loc.ambulance_count, '${data['ambulance_count'] ?? 0}'),
                  buildRow(loc.avg_eta, '${data['avg_eta'] ?? 0}'),
                  buildRow(loc.completed_alerts, '${data['completed_alerts'] ?? 0}'),
                  buildRow(loc.digital_adoption, '${data['digital_adoption'] ?? 0}'),
                  buildRow(loc.icu_beds, '${data['icu_beds'] ?? 0}'),
                  buildRow(loc.oxygen_hospitals, '${data['oxygen_hospitals'] ?? 0}'),
                  buildRow(loc.registered_citizens, '${data['registered_citizens'] ?? 0}'),
                  buildNested('ETA Statistics', Map<String, dynamic>.from(data['eta_statistics'] ?? {})),
                  buildNested('Severity Distribution', Map<String, dynamic>.from(data['severity_distribution'] ?? {})),
                  buildNested('Status Distribution', Map<String, dynamic>.from(data['status_distribution'] ?? {})),
                  buildRow(loc.total_alerts, '${data['total_alerts'] ?? 0}'),
                  buildRow(loc.total_beds, '${data['total_beds'] ?? 0}'),
                  buildRow(loc.total_citizens, '${data['total_citizens'] ?? 0}'),
                  const SizedBox(height: 20),
                  // Download buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _downloadAnalyticsCSV,
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download Analysis'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _downloadHospitalsCSV,
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download Hospitals'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadReport(Map<String, dynamic> data) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report generation in progress...')),
      );
      // TODO: Implement report download via API
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV data copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: Colors.blue[600]!,
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildMetricGrid(List<Widget> tiles) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.0,
      children: tiles,
    );
  }

  Widget _buildSeverityDistribution(Map<String, dynamic> data) {
    final severity = data['severity_distribution'] ?? {};
    final low = (severity['low'] ?? 0).toDouble();
    final medium = (severity['medium'] ?? 0).toDouble();
    final high = (severity['high'] ?? 0).toDouble();
    final total = low + medium + high;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alert Severity Distribution',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _SeverityBar('Low Risk', total > 0 ? (low / total) * 100 : 0, Colors.green),
          const SizedBox(height: 12),
          _SeverityBar(
              'Medium Risk', total > 0 ? (medium / total) * 100 : 0, Colors.orange),
          const SizedBox(height: 12),
          _SeverityBar('High Risk', total > 0 ? (high / total) * 100 : 0, Colors.red),
          const SizedBox(height: 16),
          Text(
            'Total Alerts: ${low.toInt() + medium.toInt() + high.toInt()}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(Map<String, dynamic> data) {
    final completed = (data['completed_alerts'] ?? 0).toInt();
    final total = (data['total_alerts'] ?? 1).toInt();
    final completionRate = total > 0 ? (completed / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alert Completion Rate',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '$completionRate%',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[600]),
              ),
              Text('$completed / $total alerts completed',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Icon(Icons.trending_up, size: 40, color: Colors.green[400]),
        ],
      ),
    );
  }

  Widget _buildEngagementMetrics(Map<String, dynamic> data) {
    final avgEta = data['avg_eta'] ?? 0;
    // Build dynamic values from API data; avoid hard-coded placeholders
    final totalAlerts = (data['total_alerts'] ?? 0).toString();
    final totalCitizens = (data['total_citizens'] ?? 0).toString();
    final avgEtaStr = (avgEta ?? 0).toString();

    String digitalAdoptionStr = 'N/A';
    if (data.containsKey('digital_adoption') && data['digital_adoption'] != null) {
      digitalAdoptionStr = '${data['digital_adoption']}%';
    } else if (data.containsKey('registered_citizens') && data['registered_citizens'] != null && (data['total_citizens'] ?? 0) is num && (data['total_citizens'] as num) > 0) {
      try {
        final reg = (data['registered_citizens'] as num).toDouble();
        final total = (data['total_citizens'] as num).toDouble();
        digitalAdoptionStr = '${((reg / total) * 100).toStringAsFixed(1)}%';
      } catch (_) {
        digitalAdoptionStr = 'N/A';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricRow('Total SOS Calls', totalAlerts, '📞'),
          _MetricRow('Active Citizens', totalCitizens, '🏥'),
          _MetricRow('Avg Response Time', '$avgEtaStr min', '⏱️'),
          _MetricRow('Digital Adoption', digitalAdoptionStr, '📱'),
        ],
      ),
    );
  }

  Widget _buildInfrastructureStatus(Map<String, dynamic> data) {
    final totalBeds = data['total_beds'] ?? 0;
    final icuBeds = data['icu_beds'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hospital Infrastructure Status',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _InfraRow('Total Hospital Beds', '$totalBeds', Colors.blue),
          _InfraRow('ICU Beds', '$icuBeds', Colors.orange),
          _InfraRow('Oxygen-Ready Hospitals', '${data['oxygen_hospitals'] ?? 0}', Colors.red),
          _InfraRow('Active Hospitals', '${data['active_hospitals'] ?? 0}', Colors.green),
        ],
      ),
    );
  }

  Widget _buildResourceAllocation(Map<String, dynamic> data) {
    final totalBeds = (data['total_beds'] ?? 1).toInt();
    final icuBeds = (data['icu_beds'] ?? 0).toInt();
    final occupancyRate =
        totalBeds > 0 ? ((icuBeds / totalBeds) * 100).toStringAsFixed(1) : '0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resource Load Balancing',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'City-wide capacity utilization is being monitored in real-time. '
            'Hospitals with >80% occupancy are flagged for resource rebalancing.',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (double.parse(occupancyRate) / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.amber[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
          ),
          const SizedBox(height: 8),
          Text(
            'Average City Occupancy: $occupancyRate%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaAnalytics(Map<String, dynamic> data) {
    final etaStats = data['eta_statistics'] ?? {};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ambulance Response Performance',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _StatRow('Mean ETA', '${etaStats['mean'] ?? 'N/A'} min'),
          _StatRow('Median ETA', '${etaStats['median'] ?? 'N/A'} min'),
          _StatRow('95th Percentile', '${etaStats['p95'] ?? 'N/A'} min'),
          _StatRow('Max ETA Recorded', '${etaStats['max'] ?? 'N/A'} min'),
        ],
      ),
    );
  }

  Widget _buildResponseStatus(Map<String, dynamic> data) {
    final statusDist = data['status_distribution'] ?? {};
    final dispatched = statusDist['dispatched'] ?? 0;
    final onTheWay = statusDist['on_the_way'] ?? 0;
    final arrived = statusDist['arrived'] ?? 0;
    final completed = data['completed_alerts'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alert Status Distribution',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _StatusBadge('Dispatched', '$dispatched', Colors.orange),
          const SizedBox(height: 8),
          _StatusBadge('On The Way', '$onTheWay', Colors.blue),
          const SizedBox(height: 8),
          _StatusBadge('Arrived', '$arrived', Colors.green),
          const SizedBox(height: 8),
          _StatusBadge('Completed', '$completed', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<String> points,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
          ),
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✔ ', style: TextStyle(color: Colors.green[600])),
                Expanded(child: Text(point, style: const TextStyle(fontSize: 12))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String desc;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SeverityBar extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const _SeverityBar(this.label, this.percentage, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          minHeight: 8,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _MetricRow(this.label, this.value, this.emoji);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _InfraRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfraRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String count;
  final Color color;

  const _StatusBadge(this.status, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(
            count,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}