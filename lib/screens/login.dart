import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../constants/app_colors.dart';
import 'registration.dart';
import 'citizen_dashboard.dart';
import 'hospital_dashboard.dart';
import 'ambulance_dashboard.dart';
import 'government_dashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String role = "citizen";
  bool _obscurePassword = true;

  final TextEditingController idCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  String getPlaceholder() {
    switch (role) {
      case "hospital":
        return "Hospital Name";
      case "ambulance":
        return "Hospital Name";
      case "government":
        return "Admin Username";
      default:
        return "Name / Email / Phone";
    }
  }

  void login() async {
    if (idCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter all fields"),
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
          content: const Text("Invalid credentials or server error"),
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // HEADER
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
                        "Smart Health",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your trusted healthcare companion",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // ROLE SELECT
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: InputDecoration(
                    labelText: "Login As",
                    labelStyle: const TextStyle(color: AppColors.primary),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "citizen", child: Text("Citizen")),
                    DropdownMenuItem(value: "hospital", child: Text("Hospital")),
                    DropdownMenuItem(value: "ambulance", child: Text("Ambulance")),
                    DropdownMenuItem(value: "government", child: Text("Government")),
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

                // IDENTIFIER
                TextField(
                  controller: idCtrl,
                  decoration: InputDecoration(
                    labelText: getPlaceholder(),
                    hintText: getPlaceholder(),
                    labelStyle: const TextStyle(color: AppColors.primary),
                    prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD
                TextField(
                  controller: passCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: AppColors.primary),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // FORGOT PASSWORD
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // LOGIN BUTTON
                ElevatedButton.icon(
                  onPressed: login,
                  icon: const Icon(Icons.login_outlined),
                  label: const Text(
                    "Sign In",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // DIVIDER
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),

                const SizedBox(height: 24),

                // REGISTER LINK
                if (role == "citizen" || role == "hospital")
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
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
                                    builder: (_) => RegistrationPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
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