import 'package:flutter/material.dart';
import '../services/api_services.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Health",
          style: TextStyle(
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
            tooltip: "Edit Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CitizenProfileEditScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            tooltip: "Logout",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
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
                      "Welcome Back",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D47A1),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your health is our priority. Quick access to healthcare services.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ========== DIRECT SOS - EMERGENCY ==========
              _buildEmergencyCard(context),
              const SizedBox(height: 32),

              // QUICK ACTIONS HEADER
              Text(
                "Healthcare Services",
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
                title: "Symptom Checker",
                description: "Get instant health assessment",
                color: const Color(0xFF1976D2),
                onTap: () => _checkSymptoms(context),
              ),
              const SizedBox(height: 14),

              // ========== HOSPITAL LOCATOR ==========
              _buildDashboardCard(
                context,
                icon: Icons.local_hospital_outlined,
                title: "Find Hospital",
                description: "Locate nearest medical facility",
                color: const Color(0xFF00897B),
                onTap: () => _showAboutApp(context),
              ),
              const SizedBox(height: 14),

              // ========== HEALTH TRACKING ==========
              _buildDashboardCard(
                context,
                icon: Icons.favorite_outline,
                title: "Health Records",
                description: "View your medical history",
                color: const Color(0xFFD32F2F),
                onTap: () => _showAboutApp(context),
              ),
              const SizedBox(height: 14),

              // ========== ABOUT THE APP ==========
              _buildDashboardCard(
                context,
                icon: Icons.info_outline,
                title: "About Smart Health",
                description: "Learn more about our platform",
                color: const Color(0xFF5E35B1),
                onTap: () => _showAboutApp(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _directSOS(context),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD32F2F),
              const Color(0xFFB71C1C),
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
                    "Emergency SOS",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Tap to dispatch ambulance immediately",
                    style: TextStyle(
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

  void _directSOS(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "🚨 Emergency SOS",
            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
          ),
          content: const Text("Dispatching ambulance to your location..."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );

      final alertId = await ApiService.directSOS();
      Navigator.pop(context);

      if (alertId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✓ Emergency alert sent! Ambulance en route."),
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
            content: const Text("✗ Failed to send emergency alert"),
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
          content: Text("Error: $e"),
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

  void _showAboutApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "About Smart Health",
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D47A1)),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Digital Health Surveillance Platform",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A237E)),
              ),
              SizedBox(height: 16),
              Text(
                "Services:",
                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0D47A1)),
              ),
              SizedBox(height: 10),
              Text("🚨 Emergency SOS - Immediate ambulance dispatch"),
              Text("🩺 Symptom Checker - AI-powered health assessment"),
              Text("🏥 Hospital Locator - Find nearby facilities"),
              Text("📋 Health Records - Complete medical history"),
              SizedBox(height: 16),
              Text(
                "Getting Started:",
                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0D47A1)),
              ),
              SizedBox(height: 10),
              Text("1. Tap Emergency SOS during medical emergencies"),
              Text("2. Use Symptom Checker for health insights"),
              Text("3. Locate hospitals and book appointments"),
              Text("4. Keep your health records updated"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}