import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gen/l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../providers/language_provider.dart';
import 'login.dart';
import 'registration.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.smart_health),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _LanguageMenu(languageProvider: languageProvider),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Text(
                  'SMART HEALTH',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.proposed_solution,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  loc.your_trusted_healthcare,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Feature Cards
                _FeatureCard(
                  icon: Icons.dashboard,
                  title: loc.unified_health_dashboard,
                  description: '${loc.digital_records_history}\n${loc.all_health_info}',
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.favorite,
                  title: loc.preventive_health_alerts,
                  description: '${loc.area_based_outbreak}\n${loc.city_wide_warnings}',
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.sos,
                  title: loc.emergency_sos,
                  description: '${loc.one_touch_sos}\n${loc.quick_emergency_help}',
                ),

                const SizedBox(height: 40),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 20),

                // System Overview
                Text(
                  loc.smart_integrated_system,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // System integration icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SystemIcon(Icons.local_hospital, loc.hospital_label),
                    Icon(Icons.arrow_forward, color: Colors.grey[400]),
                    _SystemIcon(Icons.phone_android, loc.app_label),
                    Icon(Icons.arrow_forward, color: Colors.grey[400]),
                    _SystemIcon(Icons.apartment, loc.government_label),
                  ],
                ),

                const SizedBox(height: 40),

                // Sign In / Sign Up Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegistrationPage()),
                          );
                        },
                        child: Text(loc.sign_up),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        child: Text(loc.sign_in),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SystemIcon(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  final LanguageProvider languageProvider;

  const _LanguageMenu({required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (String locale) {
        languageProvider.setLocale(Locale(locale));
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(value: 'en', child: Text('English')),
        const PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
        const PopupMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
        const PopupMenuItem(value: 'mr', child: Text('मराठी')),
      ],
    );
  }
}
