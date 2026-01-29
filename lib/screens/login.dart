import 'package:flutter/material.dart';
import '../services/api_services.dart';
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
        const SnackBar(content: Text("Please enter all fields")),
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
        const SnackBar(
          content: Text("Invalid credentials or server error"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    Widget nextPage;
    switch (role) {
      case "hospital":
        nextPage = HospitalDashboard();
        break;
      case "ambulance":
        nextPage = AmbulanceDashboard();
        break;
      case "government":
        nextPage = GovernmentDashboard();
        break;
      default:
        nextPage = CitizenDashboard();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              /// ROLE SELECT
              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(
                  labelText: "Login As",
                  border: OutlineInputBorder(),
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

              /// IDENTIFIER
              TextField(
                controller: idCtrl,
                decoration: InputDecoration(
                  labelText: getPlaceholder(),
                  hintText: getPlaceholder(),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// PASSWORD
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              /// LOGIN BUTTON
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Login"),
              ),

              const SizedBox(height: 16),

              /// REGISTER LINE (CLEAN STYLE)
              if (role == "citizen" || role == "hospital" || role == "government")
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistrationPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
