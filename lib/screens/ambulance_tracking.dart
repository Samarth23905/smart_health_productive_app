import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_services.dart';
import '../constants/app_colors.dart';

class AmbulanceTracking extends StatefulWidget {
  final int alertId;
  const AmbulanceTracking({required this.alertId, Key? key}) : super(key: key);

  @override
  State<AmbulanceTracking> createState() => _AmbulanceTrackingState();
}

class _AmbulanceTrackingState extends State<AmbulanceTracking> {
  Timer? _timer;
  bool _isLoading = true;
  int eta = 0;
  int initialEta = 15;
  String status = "dispatched";
  double citizenLat = 0.0;
  double citizenLon = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchInitialStatus();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _fetchStatus();
    });
  }

  Future<void> _fetchInitialStatus() async {
    try {
      final data = await ApiService.getAmbulanceStatus(widget.alertId);
      if (data != null && mounted) {
        setState(() {
          eta = data["eta_minutes"] as int? ?? 0;
          initialEta = data["eta_minutes"] as int? ?? 15;
          status = data["status"] as String? ?? "dispatched";
          citizenLat = (data["citizen_latitude"] as num?)?.toDouble() ?? 0.0;
          citizenLon = (data["citizen_longitude"] as num?)?.toDouble() ?? 0.0;
          _isLoading = false;
        });

        // If already delivered/arrived, stop the timer
        if (status == "delivered" || status == "arrived") {
          _timer?.cancel();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Unable to fetch ambulance status")),
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print("Error fetching initial status: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchStatus() async {
    try {
      final data = await ApiService.getAmbulanceStatus(widget.alertId);
      if (data != null && mounted) {
        setState(() {
          eta = data["eta_minutes"] as int? ?? eta;
          status = data["status"] as String? ?? status;
          citizenLat = (data["citizen_latitude"] as num?)?.toDouble() ?? citizenLat;
          citizenLon = (data["citizen_longitude"] as num?)?.toDouble() ?? citizenLon;
          _isLoading = false;
        });

        if (status == "delivered" || status == "arrived") {
          _timer?.cancel();
        }
      }
    } catch (e) {
      print("Error polling ambulance status: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double getProgress() {
    if (initialEta == 0) return 1.0;
    return (initialEta - eta) / initialEta;
  }

  String getStatusLabel() {
    switch (status) {
      case "dispatched":
        return "Ambulance Dispatched";
      case "on_the_way":
        return "On the Way";
      case "arrived":
        return "Arrived at Location";
      case "delivered":
        return "Delivered";
      default:
        return status;
    }
  }

  Future<void> _openMapsApp(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open maps")),
        );
      }
    }
  }

  Future<void> _markAsArrived() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Confirm Arrival'),
        content: const Text('Mark ambulance as arrived at hospital?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingCtx) => PopScope(
          canPop: false,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    try {
      final success = await ApiService.completeAlert(widget.alertId);

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Cancel timer to stop polling
        _timer?.cancel();
        
        // Update status
        setState(() => status = "delivered");

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient delivered successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Wait a moment then navigate back to dashboard
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to complete delivery'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error in _markAsArrived: $e");
      if (mounted) {
        try {
          Navigator.pop(context); // Try to close loading dialog
        } catch (_) {}
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get step index based on status
  int _getStepIndex() {
    switch (status.toLowerCase()) {
      case 'dispatched':
        return 0;
      case 'on_the_way':
        return 1;
      case 'arrived':
        return 2;
      case 'delivered':
        return 5;
      default:
        return 0;
    }
  }

  Widget _buildTrackingTimeline() {
    final steps = [
      'Dispatched',
      'On the Way',
      'Arrived',
      'Delivered'
    ];
    
    final currentStep = _getStepIndex();

    return Column(
      children: List.generate(steps.length, (index) {
        bool isCompleted = index < currentStep;
        bool isCurrent = index == currentStep;
        bool isPending = index > currentStep;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circle indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green
                        : isCurrent
                            ? Colors.blue
                            : Colors.grey[300],
                    border: isCurrent
                        ? Border.all(color: Colors.blue, width: 3)
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : isCurrent
                            ? const Icon(Icons.location_on,
                                color: Colors.white, size: 20)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isPending ? Colors.grey : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: 16),
                // Step label
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isPending ? Colors.grey : Colors.black,
                          ),
                        ),
                        if (isCurrent)
                          const Text(
                            'In progress',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Connector line
            if (index < steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 19),
                child: Container(
                  height: 20,
                  width: 2,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
              ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Ambulance Tracking',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ambulance Tracking',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Delivery Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hospital Delivery',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Patient delivery in progress',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tracking Timeline
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tracking Timeline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTrackingTimeline(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ETA Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated Time of Arrival',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$eta minutes',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: getProgress(),
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(Colors.green[700]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      getStatusLabel(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMapsApp(citizenLat, citizenLon),
                icon: const Icon(Icons.map),
                label: const Text('Navigate to Citizen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _markAsArrived,
                icon: const Icon(Icons.check_circle),
                label: Text(status == "delivered" ? 'Delivered' : 'Mark as Arrived at Hospital'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == "delivered" ? Colors.grey : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Live Updates Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Updates in real-time every 5 seconds',
                      style: TextStyle(
                        color: Colors.amber[900],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
