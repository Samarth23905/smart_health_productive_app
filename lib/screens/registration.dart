import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../services/api_services.dart';
import '../services/image_picker_service.dart';
import '../constants/app_colors.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String role = "citizen";
  String sex = "Male";
  Uint8List? imageBytes;
  String? profilePicBase64;
  bool isLoading = false;
  bool oxygenAvailable = false; 

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final totalBedsCtrl = TextEditingController();
  final icuBedsCtrl = TextEditingController();

  Future<void> autoFetchLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied forever. Enable in settings.')),
          );
        }
        return;
      }

      // Get current location
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        latCtrl.text = position.latitude.toString();
        lngCtrl.text = position.longitude.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location: ${position.latitude}, ${position.longitude}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> captureProfilePicture() async {
    try {
      final result = await ImagePickerService.pickFromCamera();
      
      if (result != null) {
        setState(() {
          imageBytes = result.bytes;
          profilePicBase64 = result.base64;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo captured successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> pickProfilePicture() async {
    try {
      final result = await ImagePickerService.pickFromGallery();
      
      if (result != null) {
        setState(() {
          imageBytes = result.bytes;
          profilePicBase64 = result.base64;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image selected successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: ${e.toString()}')),
        );
      }
    }
  }

  void register() async {
    if (nameCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Build payload depending on role. Government does not need lat/lng.
      final Map<String, dynamic> payload = {
        "role": role,
        "name": nameCtrl.text,
        "password": passCtrl.text,
        "profile_pic": profilePicBase64,
        "phone": role == "government" ? null : phoneCtrl.text,
      };

      if (role == "citizen" || role == "hospital") {
        // Parse latitude and longitude as doubles for citizen/hospital
        final lat = double.tryParse(latCtrl.text);
        final lng = double.tryParse(lngCtrl.text);

        if (lat == null || lng == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid latitude and longitude')),
          );
          setState(() => isLoading = false);
          return;
        }

        payload["latitude"] = lat;
        payload["longitude"] = lng;

        if (role == "citizen") {
          payload["email"] = emailCtrl.text.isEmpty ? null : emailCtrl.text;
          payload["sex"] = sex;
        } else if (role == "hospital") {
          payload["total_beds"] = int.tryParse(totalBedsCtrl.text) ?? 0;
          payload["icu_beds"] = int.tryParse(icuBedsCtrl.text) ?? 0;
          payload["oxygen_available"] = oxygenAvailable;
        }
      }

      final ok = await ApiService.register(payload);

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture Section (not for Government)
            if (role != "government")
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Add Profile Picture',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            captureProfilePicture();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            pickProfilePicture();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Choose from Gallery'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: imageBytes != null
                      ? ClipOval(
                          child: Image.memory(imageBytes!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                            SizedBox(height: 5),
                            Text('Add Photo', textAlign: TextAlign.center),
                          ],
                        ),
                ),
              ),
            if (role != "government") const SizedBox(height: 20),

            // Role Selection
            DropdownButton<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: "citizen", child: Text("Citizen")),
                DropdownMenuItem(value: "hospital", child: Text("Hospital")),
                DropdownMenuItem(value: "government", child: Text("Government")),
              ],
              onChanged: (v) => setState(() => role = v!),
            ),
            const SizedBox(height: 15),

            // Name Field / Username Field
            if (role != "government")
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: role == "citizen" ? "Full Name" : "Hospital Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            if (role == "government")
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            const SizedBox(height: 15),

            // Phone Field (for both Citizen and Hospital only)
            if (role != "government")
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            if (role != "government") const SizedBox(height: 15),

            // Citizen-specific fields
            if (role == "citizen") ...[
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
              const SizedBox(height: 15),
              DropdownButton<String>(
                value: sex,
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (v) => setState(() => sex = v!),
              ),
              const SizedBox(height: 15),
            ],

            // Hospital-specific fields
            if (role == "hospital") ...[
              TextField(
                controller: totalBedsCtrl,
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
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Oxygen Available", style: TextStyle(fontSize: 16)),
                    Switch(
                      value: oxygenAvailable,
                      onChanged: (v) => setState(() => oxygenAvailable = v),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],

            // Government-specific fields
            if (role == "government") ...[],

            // Location Fields (not for Government)
            if (role != "government")
              TextField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Latitude",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                  hintText: "e.g., 17.6599",
                ),
              ),
            if (role != "government") const SizedBox(height: 15),
            if (role != "government")
              TextField(
                controller: lngCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Longitude",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                  hintText: "e.g., 75.9064",
                ),
              ),
            if (role != "government") const SizedBox(height: 15),

            // Auto-fetch Location Button (not for Government)
            if (role != "government")
              ElevatedButton.icon(
                onPressed: autoFetchLocation,
                icon: const Icon(Icons.location_searching),
                label: const Text("📍 Auto-fetch Location"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            if (role != "government") const SizedBox(height: 15),

            // Password Field
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),

            // Register Button
            ElevatedButton(
              onPressed: isLoading ? null : register,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text(
                      "Create Account",
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
    emailCtrl.dispose();
    phoneCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();
    passCtrl.dispose();
    totalBedsCtrl.dispose();
    icuBedsCtrl.dispose();
    super.dispose();
  }
}