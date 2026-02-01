import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../constants/app_colors.dart';
import '../gen/l10n/app_localizations.dart';

class CitizenProfileEditScreen extends StatefulWidget {
  @override
  State<CitizenProfileEditScreen> createState() =>
      _CitizenProfileEditScreenState();
}

class _CitizenProfileEditScreenState extends State<CitizenProfileEditScreen> {
  bool isLoading = true;
  bool isSaving = false;
  String? error;
  String sex = "Male";

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    try {
      final profile = await ApiService.getCitizenProfile();
      if (profile != null) {
        setState(() {
          nameCtrl.text = profile['name'] ?? '';
          emailCtrl.text = profile['email'] ?? '';
          phoneCtrl.text = profile['phone'] ?? '';
          sex = profile['sex'] ?? 'Male';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void saveProfile() async {
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.fill_required_fields)),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      final updated = await ApiService.updateCitizenProfile({
        "name": nameCtrl.text,
        "email": emailCtrl.text,
        "phone": phoneCtrl.text,
        "sex": sex,
      });

      if (updated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.edit_profile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.edit_profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            if (error != null) const SizedBox(height: 15),
            
            // Personal Information Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.personal_information,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: loc.full_name,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: loc.email,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: loc.phone_number,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 15),
                  Text(
                    loc.gender,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: sex,
                      isExpanded: true,
                      underline: Container(),
                      items: [
                        DropdownMenuItem(value: "Male", child: Text(loc.male)),
                        DropdownMenuItem(value: "Female", child: Text(loc.female)),
                        DropdownMenuItem(value: "Other", child: Text(loc.other)),
                      ],
                      onChanged: (v) => setState(() => sex = v!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSaving ? null : saveProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      loc.save_changes,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }
}
