import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../constants/app_colors.dart';
import '../gen/l10n/app_localizations.dart';
import 'login.dart';
import 'hospital_profile_edit.dart';

class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({Key? key}) : super(key: key);

  @override
  State<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends State<HospitalDashboard> {
  Timer? _refreshTimer;
  late Future<List> _casesFuture;

  // For speed tracking per ambulance
  final Map<int, double> _ambulanceSpeedMap = {};
  final Map<int, Map<String, dynamic>> _prevLocationMap = {};

  @override
  void initState() {
    super.initState();
    _casesFuture = ApiService.getHospitalCases();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _casesFuture = ApiService.getHospitalCases();
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula to calculate distance in kilometers
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  int _calculateRemainingETA(Map<String, dynamic> caseData) {
    // Calculate ETA using Haversine formula and real-time speed tracking
    final status = caseData["status"] as String? ?? "";
    final alertId = caseData["id"] ?? caseData["alert_id"] ?? "unknown";

    // Show 0 when arrived or delivered
    if (status == "arrived" || status == "delivered") {
      print("[HospitalDashboard] ETA alert_id=$alertId: 0 (arrived/delivered)");
      return 0;
    }

    // Get ambulance and hospital locations with safe conversion
    final ambulanceLat = (caseData["ambulance_latitude"] as num?)?.toDouble() ?? 0.0;
    final ambulanceLon = (caseData["ambulance_longitude"] as num?)?.toDouble() ?? 0.0;
    final hospitalLat = (caseData["hospital_latitude"] as num?)?.toDouble() ?? 0.0;
    final hospitalLon = (caseData["hospital_longitude"] as num?)?.toDouble() ?? 0.0;
    
    // If we don't have valid coordinates, return API ETA or 0
    if (ambulanceLat == 0.0 || ambulanceLon == 0.0 || hospitalLat == 0.0 || hospitalLon == 0.0) {
      final eta = (caseData["eta"] as num?)?.toInt() ?? 0;
      print("[HospitalDashboard] ETA alert_id=$alertId: $eta (fallback, missing coordinates)");
      return eta;
    }

    // Update speed tracking if we have previous location
    if (_prevLocationMap.containsKey(alertId)) {
      final prevData = _prevLocationMap[alertId]!;
      final prevLat = prevData['lat'] as double;
      final prevLon = prevData['lon'] as double;
      final prevTime = prevData['time'] as DateTime;

      final distance = _calculateDistance(prevLat, prevLon, ambulanceLat, ambulanceLon);
      final timeDiffSeconds = DateTime.now().difference(prevTime).inSeconds;

      if (timeDiffSeconds > 0) {
        final timeDiffHours = timeDiffSeconds / 3600.0;
        final speedKmh = distance / timeDiffHours;

        // Use exponential moving average to smooth speed
        if (_ambulanceSpeedMap.containsKey(alertId)) {
          final prevSpeed = _ambulanceSpeedMap[alertId]!;
          _ambulanceSpeedMap[alertId] = (prevSpeed * 0.7) + (speedKmh * 0.3);
        } else {
          _ambulanceSpeedMap[alertId] = speedKmh;
        }

        print("[HospitalDashboard] Alert $alertId - Speed: ${speedKmh.toStringAsFixed(2)} km/h, Smoothed: ${_ambulanceSpeedMap[alertId]!.toStringAsFixed(2)} km/h");
      }
    }

    // Store current location for next calculation
    _prevLocationMap[alertId] = {
      'lat': ambulanceLat,
      'lon': ambulanceLon,
      'time': DateTime.now(),
    };

    // Calculate distance to hospital
    final distanceToHospital = _calculateDistance(
      ambulanceLat,
      ambulanceLon,
      hospitalLat,
      hospitalLon,
    );

    // Use calculated speed or default 45 km/h
    final speedToUse = _ambulanceSpeedMap[alertId] ?? 45.0;

    // Calculate ETA in minutes
    final etaMinutes = (distanceToHospital / speedToUse * 60).ceil();

    print("[HospitalDashboard] ETA alert_id=$alertId: Distance=${distanceToHospital.toStringAsFixed(2)} km, Speed=${speedToUse.toStringAsFixed(2)} km/h, ETA=$etaMinutes minutes");

    return etaMinutes.clamp(0, 999);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dispatched':
        return AppColors.warning;
      case 'on_the_way':
        return AppColors.info;
      case 'arrived':
        return AppColors.success;
      case 'picked_up':
        return AppColors.primary;
      case 'en_route_to_hospital':
        return AppColors.info;
      case 'delivered':
        return AppColors.statusCompleted;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.hospital_operations,
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () {
              setState(() {
                _casesFuture = ApiService.getHospitalCases();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: loc.edit_hospital_profile,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HospitalProfileEditScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.background,
            ],
          ),
        ),
        child: FutureBuilder(
          future: _casesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      loc.error,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _casesFuture = ApiService.getHospitalCases();
                        });
                      },
                      child: Text(loc.retry),
                    ),
                  ],
                ),
              );
            }

            final cases = snapshot.data as List? ?? [];

            if (cases.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.people_outline,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.no_patients,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.awaiting_ambulance,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: cases.length,
              itemBuilder: (context, index) {
                final c = cases[index];
                final displayEta = _calculateRemainingETA(c);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border(
                      left: BorderSide(
                        color: _getStatusColor(c["status"]),
                        width: 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(c["status"]).withOpacity(0.15),
                              ),
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _getStatusColor(c["status"]),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Patient: ${c["name"]}",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c["sex"],
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.phone_outlined, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    c["phone"],
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    "ETA: $displayEta min",
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(c["status"]).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c["status"].replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(c["status"]),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
