import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_services.dart';
import '../gen/l10n/app_localizations.dart';
import 'login.dart';
import 'citizen_profile_edit.dart';
import 'symptoms_form.dart';
import 'ambulance_tracking.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({Key? key}) : super(key: key);

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    // Start continuous location tracking when citizen logs in
    _startLocationTracking();
  }

  void _startLocationTracking() {
    _locationTimer?.cancel();
    // Update location every 5 seconds in database
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // Send location to server
          await ApiService.updateCitizenLocation(position.latitude, position.longitude);
          print("[CitizenDashboard] Location updated: (${position.latitude}, ${position.longitude})");
        }
      } catch (e) {
        print("[CitizenDashboard] Location tracking error: $e");
      }
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.smart_health,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            tooltip: loc.edit_profile,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CitizenProfileEditScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            tooltip: loc.logout,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF5F7FA),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WELCOME SECTION
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.welcome_back,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D47A1),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.health_priority,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ========== DIRECT SOS - EMERGENCY ==========
              _buildEmergencyCard(context, loc),
              const SizedBox(height: 32),

              // QUICK ACTIONS HEADER
              Text(
                loc.healthcare_services,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 16),

              // ========== SYMPTOMS CHECK ==========
              _buildDashboardCard(
                context,
                icon: Icons.medical_services_outlined,
                title: loc.symptom_checker,
                description: loc.instant_assessment,
                color: const Color(0xFF1976D2),
                onTap: () => _checkSymptoms(context),
              ),
              const SizedBox(height: 14),

              // ========== HOSPITAL LOCATOR ==========
              _buildDashboardCard(
                context,
                icon: Icons.local_hospital_outlined,
                title: loc.find_hospital,
                description: loc.locate_facility,
                color: const Color(0xFF00897B),
                onTap: () => _showAboutApp(context, loc),
              ),
              const SizedBox(height: 14),

              // ========== HEALTH TRACKING ==========
              _buildDashboardCard(
                context,
                icon: Icons.favorite_outline,
                title: loc.health_records,
                description: loc.medical_history,
                color: const Color(0xFFD32F2F),
                onTap: () => _showAboutApp(context, loc),
              ),
              const SizedBox(height: 14),

              // ========== ABOUT THE APP ==========
              _buildDashboardCard(
                context,
                icon: Icons.info_outline,
                title: loc.about_app,
                description: loc.learn_more,
                color: const Color(0xFF5E35B1),
                onTap: () => _showAboutApp(context, loc),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, AppLocalizations loc) {
    return GestureDetector(
      onTap: () => _directSOS(context, loc),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFD32F2F),
              Color(0xFFB71C1C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD32F2F).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emergency_outlined,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.emergency_sos,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.dispatch_ambulance,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.12),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A237E),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_outlined, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _directSOS(BuildContext context, AppLocalizations loc) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "🚨 ${loc.emergency_sos}",
            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
          ),
          content: Text("${loc.loading} ${loc.dispatch_ambulance}..."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
          ],
        ),
      );

      final alertId = await ApiService.directSOS();
      Navigator.pop(context);

      if (alertId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ ${loc.ambulance_dispatch}"),
            backgroundColor: const Color(0xFF00897B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AmbulanceTracking(alertId: alertId),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✗ ${loc.dispatch_failed}"),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${loc.error}: $e"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _checkSymptoms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SymptomsFormPage()),
    );
  }

  void _showAboutApp(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.about_app,
          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D47A1)),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Digital Health Surveillance Platform",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${loc.healthcare_services}:",
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 10),
              Text("🚨 ${loc.emergency_sos} - ${loc.dispatch_ambulance}"),
              Text("🩺 ${loc.symptom_checker} - AI-powered health assessment"),
              Text("🏥 ${loc.find_hospital} - ${loc.locate_facility}"),
              Text("📋 ${loc.health_records} - ${loc.medical_history}"),
              const SizedBox(height: 16),
              Text(
                "${loc.learn_more}:",
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 10),
              Text("1. ${loc.dispatch_ambulance} ${loc.emergency_sos}"),
              Text("2. ${loc.symptom_checker} ${loc.instant_assessment}"),
              Text("3. ${loc.find_hospital} and book appointments"),
              Text("4. ${loc.health_records} ${loc.medical_history}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
        ],
      ),
    );
  }
}
