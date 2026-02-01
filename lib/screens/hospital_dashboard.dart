import 'dart:async';
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

  @override
  void initState() {
    super.initState();
    _casesFuture = ApiService.getHospitalCases();
    // Auto-refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
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
                    Text("${snapshot.error}"),
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
                                    "ETA: ${c["eta"]} min",
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
