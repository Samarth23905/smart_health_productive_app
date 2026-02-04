import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../gen/l10n/app_localizations.dart';
import '../services/api_services.dart';
import '../constants/app_colors.dart';
import '../providers/language_provider.dart';
import 'registration.dart';
import 'forgot_password.dart';
import 'citizen_dashboard.dart';
import 'hospital_dashboard.dart';
import 'ambulance_dashboard.dart';
import 'government_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String role = "citizen";
  bool _obscurePassword = true;

  final TextEditingController idCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  String getPlaceholder(AppLocalizations loc) {
    switch (role) {
      case "hospital":
        return loc.placeholder_hospital;
      case "ambulance":
        return loc.placeholder_ambulance;
      case "government":
        return loc.placeholder_government;
      default:
        return loc.placeholder_citizen;
    }
  }

  void login(BuildContext context, AppLocalizations loc) async {
    if (idCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.enter_all_fields),
          backgroundColor: AppColors.emergency,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final success = await ApiService.login(
      idCtrl.text.trim(),
      passCtrl.text.trim(),
      role,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.invalid_credentials),
          backgroundColor: AppColors.emergency,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Widget nextPage;
    switch (role) {
      case "hospital":
        nextPage = const HospitalDashboard();
        break;
      case "ambulance":
        nextPage = const AmbulanceDashboard();
        break;
      case "government":
        nextPage = const GovernmentDashboard();
        break;
      default:
        nextPage = const CitizenDashboard();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.08),
              AppColors.background,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.info,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        loc.smart_health,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.your_trusted_healthcare,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Role Select
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: InputDecoration(
                    labelText: loc.login_as,
                    labelStyle: const TextStyle(color: AppColors.primary),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "citizen",
                      child: Text(loc.citizen),
                    ),
                    DropdownMenuItem(
                      value: "hospital",
                      child: Text(loc.hospital),
                    ),
                    DropdownMenuItem(
                      value: "ambulance",
                      child: Text(loc.ambulance),
                    ),
                    DropdownMenuItem(
                      value: "government",
                      child: Text(loc.government),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      role = value!;
                      idCtrl.clear();
                      passCtrl.clear();
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Identifier
                TextField(
                  controller: idCtrl,
                  decoration: InputDecoration(
                    labelText: getPlaceholder(loc),
                    hintText: getPlaceholder(loc),
                    labelStyle: const TextStyle(color: AppColors.primary),
                    prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password
                TextField(
                  controller: passCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: loc.password,
                    labelStyle: const TextStyle(color: AppColors.primary),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      loc.forgot_password,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                ElevatedButton.icon(
                  onPressed: () => login(context, loc),
                  icon: const Icon(Icons.login_outlined),
                  label: Text(
                    loc.sign_in,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        loc.or_text,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),

                const SizedBox(height: 24),

                // Register Link
                if (role == "citizen" || role == "hospital" || role == "government")
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "${loc.no_account} ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegistrationPage(),
                                  ),
                                );
                              },
                              child: Text(
                                loc.sign_up,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    idCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}