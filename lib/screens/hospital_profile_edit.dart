import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../constants/app_colors.dart';

class HospitalProfileEditScreen extends StatefulWidget {
  @override
  State<HospitalProfileEditScreen> createState() =>
      _HospitalProfileEditScreenState();
}

class _HospitalProfileEditScreenState extends State<HospitalProfileEditScreen> {
  bool isLoading = true;
  bool isSaving = false;
  String? error;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final bedsCtrl = TextEditingController();
  final icuBedsCtrl = TextEditingController();
  bool oxygenAvailable = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    try {
      final profile = await ApiService.getHospitalProfile();
      if (profile != null) {
        setState(() {
          nameCtrl.text = profile['name'] ?? '';
          phoneCtrl.text = profile['phone'] ?? '';
          emailCtrl.text = profile['email'] ?? '';
          bedsCtrl.text = profile['total_beds']?.toString() ?? '0';
          icuBedsCtrl.text = profile['icu_beds']?.toString() ?? '0';
          oxygenAvailable = profile['oxygen_available'] ?? false;
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
    setState(() => isSaving = true);
    try {
      final updated = await ApiService.updateHospitalProfile({
        "name": nameCtrl.text,
        "phone": phoneCtrl.text,
        "email": emailCtrl.text,
        "total_beds": int.tryParse(bedsCtrl.text) ?? 0,
        "icu_beds": int.tryParse(icuBedsCtrl.text) ?? 0,
        "oxygen_available": oxygenAvailable,
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Edit Hospital Profile")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Hospital Profile")),
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
            
            // Hospital Resources Section
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
                  const Text(
                    '🏥 Hospital Resources',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: "Hospital Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.local_hospital),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 15),
                  const Text(
                    'Bed Capacity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bedsCtrl,
                    decoration: InputDecoration(
                      labelText: "Total Beds",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.bed),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: icuBedsCtrl,
                    decoration: InputDecoration(
                      labelText: "ICU Beds",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.medical_services),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 15),
                  const Text(
                    'Medical Supplies',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: oxygenAvailable ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: oxygenAvailable ? Colors.green[50] : Colors.grey[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "🫁 Oxygen Available",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              oxygenAvailable ? "✓ Available" : "✗ Not available",
                              style: TextStyle(
                                fontSize: 14,
                                color: oxygenAvailable ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: oxygenAvailable,
                          onChanged: (v) => setState(() => oxygenAvailable = v),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Enable oxygen if available for emergency SOS dispatch",
                            style: TextStyle(fontSize: 13, color: Colors.orange),
                          ),
                        ),
                      ],
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
                  : const Text(
                      "💾 Save Changes",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
    phoneCtrl.dispose();
    emailCtrl.dispose();
    bedsCtrl.dispose();
    icuBedsCtrl.dispose();
    super.dispose();
  }
}
