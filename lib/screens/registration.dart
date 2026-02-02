import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../gen/l10n/app_localizations.dart';
import '../services/api_services.dart';
import '../services/image_picker_service.dart';
import '../constants/app_colors.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

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

  Future<void> autoFetchLocation(AppLocalizations loc) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.location_permission_denied)),
          );
        }
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latCtrl.text = position.latitude.toString();
        lngCtrl.text = position.longitude.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.location_fetched)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${loc.loading} $e")),
        );
      }
    }
  }

  Future<void> captureProfilePicture(AppLocalizations loc) async {
    try {
      final result = await ImagePickerService.pickFromCamera();

      if (result != null) {
        setState(() {
          imageBytes = result.bytes;
          profilePicBase64 = result.base64;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.photo_captured)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.camera_error)),
        );
      }
    }
  }

  Future<void> pickProfilePicture(AppLocalizations loc) async {
    try {
      final result = await ImagePickerService.pickFromGallery();

      if (result != null) {
        setState(() {
          imageBytes = result.bytes;
          profilePicBase64 = result.base64;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.image_selected)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.gallery_error)),
        );
      }
    }
  }


  void register(AppLocalizations loc) async {
    if (nameCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.fill_required_fields)),
      );
      return;
    }

    // For hospitals, validate lat/lng if provided; for citizens auto-fetch will happen
    if (role == "hospital") {
      if (latCtrl.text.isNotEmpty || lngCtrl.text.isNotEmpty) {
        try {
          double.parse(latCtrl.text);
          double.parse(lngCtrl.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.valid_lat_lng)),
          );
          return;
        }
      }
    }

    setState(() => isLoading = true);

    try {
      // For citizens, auto-fetch location if not already set
      if (role == "citizen" && latCtrl.text.isEmpty) {
        await autoFetchLocation(loc);
        if (latCtrl.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.location_permission_denied)),
          );
          setState(() => isLoading = false);
          return;
        }
      }

      final data = <String, dynamic>{
        "role": role,
        "name": nameCtrl.text,
        "email": emailCtrl.text,
        "password": passCtrl.text,
      };

      // Add phone only for non-government roles
      if (role != "government") {
        data["phone"] = phoneCtrl.text;
      }

      if (role == "citizen") {
        data["sex"] = sex;
        data["latitude"] = double.parse(latCtrl.text);
        data["longitude"] = double.parse(lngCtrl.text);
        if (profilePicBase64 != null) data["profile_pic"] = profilePicBase64;
      } else if (role == "hospital") {
        if (latCtrl.text.isNotEmpty) data["latitude"] = double.parse(latCtrl.text);
        if (lngCtrl.text.isNotEmpty) data["longitude"] = double.parse(lngCtrl.text);
        data["total_beds"] = int.tryParse(totalBedsCtrl.text) ?? 0;
        data["icu_beds"] = int.tryParse(icuBedsCtrl.text) ?? 0;
        data["oxygen_available"] = oxygenAvailable;
        if (profilePicBase64 != null) data["profile_pic"] = profilePicBase64;
      } else if (role == "ambulance") {
        // For ambulance, location will be continuously updated after login
        if (latCtrl.text.isNotEmpty) data["latitude"] = double.parse(latCtrl.text);
        if (lngCtrl.text.isNotEmpty) data["longitude"] = double.parse(lngCtrl.text);
        if (profilePicBase64 != null) data["profile_pic"] = profilePicBase64;
      }

      final response = await ApiService.register(data);

      if (response && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.registration_successful)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.registration_failed)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${loc.error}: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.register),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture Section
            if (role != "government")
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          loc.add_profile_picture,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            captureProfilePicture(loc);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: Text(loc.take_photo),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            pickProfilePicture(loc);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.image),
                          label: Text(loc.choose_gallery),
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
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              loc.add_photo,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
            if (role != "government") const SizedBox(height: 20),

            // Role Selection
            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(
                labelText: loc.login_as,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  value: "government",
                  child: Text(loc.government),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  role = v!;
                  nameCtrl.clear();
                  emailCtrl.clear();
                  phoneCtrl.clear();
                });
              },
            ),
            const SizedBox(height: 15),

            // Name Field
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: role == "citizen"
                    ? loc.full_name
                    : (role == "hospital" ? loc.hospital_name : loc.username),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),

            // Email Field
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: loc.email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),

            // Phone Field (skip for government)
            if (role != "government")
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: loc.phone_number,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
            if (role != "government") const SizedBox(height: 15),

            // Gender Field (only for citizen)
            if (role == "citizen")
              DropdownButtonFormField<String>(
                value: sex,
                decoration: InputDecoration(
                  labelText: loc.gender,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: "Male", child: Text(loc.male)),
                  DropdownMenuItem(value: "Female", child: Text(loc.female)),
                  DropdownMenuItem(value: "Other", child: Text(loc.other)),
                ],
                onChanged: (v) => setState(() => sex = v!),
              ),
            if (role == "citizen") const SizedBox(height: 15),

            // Auto-fetch Location Button (only for citizens)
            if (role == "citizen")
              ElevatedButton(
                onPressed: () => autoFetchLocation(loc),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(loc.auto_fetch_location),
              ),
            if (role != "government") const SizedBox(height: 15),

            // Total Beds (only for hospital)
            if (role == "hospital")
              TextField(
                controller: totalBedsCtrl,
                decoration: InputDecoration(
                  labelText: loc.total_beds,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.hotel),
                ),
                keyboardType: TextInputType.number,
              ),
            if (role == "hospital") const SizedBox(height: 15),

            // ICU Beds (only for hospital)
            if (role == "hospital")
              TextField(
                controller: icuBedsCtrl,
                decoration: InputDecoration(
                  labelText: loc.icu_beds,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.hotel),
                ),
                keyboardType: TextInputType.number,
              ),
            if (role == "hospital") const SizedBox(height: 15),

            // Oxygen Available (only for hospital)
            if (role == "hospital")
              CheckboxListTile(
                title: Text(loc.oxygen_available),
                value: oxygenAvailable,
                onChanged: (v) => setState(() => oxygenAvailable = v!),
              ),
            if (role == "hospital") const SizedBox(height: 15),

            // Password Field
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: loc.password,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),

            // Register Button
            ElevatedButton(
              onPressed: isLoading ? null : () => register(loc),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(loc.register),
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