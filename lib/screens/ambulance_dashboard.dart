import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'ambulance_tracking.dart';
import 'login.dart';

class AmbulanceDashboard extends StatefulWidget {
  const AmbulanceDashboard({Key? key}) : super(key: key);

  @override
  State<AmbulanceDashboard> createState() => _AmbulanceDashboardState();
}

class _AmbulanceDashboardState extends State<AmbulanceDashboard> {
  Timer? _refreshTimer;
  late Future<List> _casesFuture;

  @override
  void initState() {
    super.initState();
    _casesFuture = ApiService.getAmbulanceCases();
    // Auto-refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _casesFuture = ApiService.getAmbulanceCases();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambulance Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _casesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(
              child: Text("No active ambulance alerts"),
            );
          }

          final cases = snapshot.data as List;

          return ListView.builder(
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final alert = cases[index];
              final alertId = alert["alert_id"] ?? 0;
              final citizenId = alert["citizen_id"];
              final eta = alert["eta"] ?? 0;
              final status = alert["status"] ?? "pending";

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor(status),
                    ),
                    child: Center(
                      child: Text(
                        "${eta}m",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text("Alert #$alertId"),
                  subtitle: Text("Status: ${status.replaceAll('_', ' ').toUpperCase()}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AmbulanceTracking(
                            alertId: alertId,
                          ),
                        ),
                      );
                    },
                    child: const Text("Navigate"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dispatched':
        return Colors.orange;
      case 'on_the_way':
        return Colors.blue;
      case 'arrived':
        return Colors.green;
      case 'picked_up':
        return Colors.purple;
      case 'en_route_to_hospital':
        return Colors.indigo;
      case 'delivered':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
