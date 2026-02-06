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

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // validation states
  bool has6Characters = false;
  bool hasSpecialCharacter = false;
  bool hasCapitalLetter = false;
  bool hasValidEmail = false;

  bool hasValidPhone = false;

  void validatePassword(String password) {
    setState(() {
      has6Characters = password.length >= 6;
      hasSpecialCharacter = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      hasCapitalLetter = password.isNotEmpty && password[0].toUpperCase() == password[0];
    });
  }

  void validateEmail(String email) {
    setState(() {
      hasValidEmail = email.contains('@');
    });
  }

  void validatePhone(String phone) {
    setState(() {
      hasValidPhone = phone.length == 10 && RegExp(r'^\d+$').hasMatch(phone);
    });
  }

  bool areAllValidationsMet() {
    if (!has6Characters || !hasSpecialCharacter || !hasCapitalLetter) {
      return false;
    }

    if (role != "government") {
      if (!hasValidEmail || !hasValidPhone) {
        return false;
      }
    }

    return true;
  }

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

    // Validate password requirements
    if (!has6Characters || !hasSpecialCharacter || !hasCapitalLetter) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password must have 6+ characters, a special character, and start with uppercase")),
      );
      return;
    }

    // Validate email (skip for government)
    if (role != "government") {
      if (!hasValidEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email must contain '@' symbol")),
        );
        return;
      }

      // Validate phone
      if (!hasValidPhone) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone number must be exactly 10 digits")),
        );
        return;
      }
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

  // Build validation row with tick symbol
  Widget _buildValidationRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isValid ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.grey,
            fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
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

            // Email Field (skip for government)
            if (role != "government")
              TextField(
                controller: emailCtrl,
                onChanged: validateEmail,
                decoration: InputDecoration(
                  labelText: loc.email,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
            const SizedBox(height: 15),
            // Email Validation Indicator (skip for government)
            if (role != "government")
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: _buildValidationRow("Email contains '@' symbol", hasValidEmail),
              ),
            if (role != "government") const SizedBox(height: 20),

            // Phone Field (skip for government)
            if (role != "government")
              TextField(
                controller: phoneCtrl,
                onChanged: validatePhone,
                decoration: InputDecoration(
                  labelText: loc.phone_number,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
            if (role != "government") const SizedBox(height: 15),

            // Phone Validation Indicator (skip for government)
            if (role != "government")
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: _buildValidationRow("Phone number is 10 digits", hasValidPhone),
              ),
            if (role != "government") const SizedBox(height: 20),

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

            // Auto-fetch Location Button (for citizens and hospitals)
            if (role == "citizen" || role == "hospital")
              ElevatedButton(
                onPressed: () => autoFetchLocation(loc),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(loc.auto_fetch_location),
              ),
            if (role == "citizen" || role == "hospital") const SizedBox(height: 15),

            // Latitude Field (for citizens and hospitals)
            if (role == "citizen" || role == "hospital")
              TextField(
                controller: latCtrl,
                decoration: InputDecoration(
                  labelText: "Latitude",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                keyboardType: TextInputType.number,
              ),
            if (role == "citizen" || role == "hospital") const SizedBox(height: 15),

            // Longitude Field (for citizens and hospitals)
            if (role == "citizen" || role == "hospital")
              TextField(
                controller: lngCtrl,
                decoration: InputDecoration(
                  labelText: "Longitude",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                keyboardType: TextInputType.number,
              ),
            if (role == "citizen" || role == "hospital") const SizedBox(height: 15),

            // Password Field
            TextField(
              controller: passCtrl,
              obscureText: true,
              onChanged: validatePassword,
              decoration: InputDecoration(
                labelText: loc.password,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 15),

            // Password Validation Indicators
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildValidationRow("At least 6 characters", has6Characters),
                  const SizedBox(height: 10),
                  _buildValidationRow("One special character (!@#\$%^&*...)", hasSpecialCharacter),
                  const SizedBox(height: 10),
                  _buildValidationRow("First letter is uppercase", hasCapitalLetter),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Register Button
            ElevatedButton(
              onPressed: (isLoading || !areAllValidationsMet()) ? null : () => register(loc),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: areAllValidationsMet() ? AppColors.primary : Colors.grey,
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
    super.dispose();
  }
}