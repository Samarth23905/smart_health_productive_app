import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../gen/l10n/app_localizations.dart';
import 'citizen_profile_edit.dart';

class CitizenProfileScreen extends StatefulWidget {
  @override
  State<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends State<CitizenProfileScreen> {
  bool isLoading = true;
  String? error;

  String name = '';
  String email = '';
  String phone = '';
  String sex = '';
  double? latitude;
  double? longitude;
  String? profilePic; // base64 or URL depending on backend

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final profile = await ApiService.getCitizenProfile();
      if (profile == null) {
        setState(() {
          error = 'Failed to load profile';
          isLoading = false;
        });
        return;
      }
      setState(() {
        name = profile['name'] ?? '';
        email = profile['email'] ?? '';
        phone = profile['phone'] ?? '';
        sex = profile['sex'] ?? '';
        latitude = (profile['latitude'] is num) ? (profile['latitude'] as num).toDouble() : null;
        longitude = (profile['longitude'] is num) ? (profile['longitude'] as num).toDouble() : null;
        profilePic = profile['profile_pic'];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _openEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CitizenProfileEditScreen()),
    );
    // refresh after edit
    if (mounted) _loadProfile();
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.my_profile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.my_profile),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _openEdit),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Text(error ?? '', style: const TextStyle(color: Colors.red)),
              ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.grey[200],
                        backgroundImage: (profilePic != null && profilePic!.isNotEmpty)
                          ? MemoryImage(base64Decode(profilePic!))
                          : null,
                      child: (profilePic == null || profilePic!.isEmpty) ? const Icon(Icons.person, size: 40) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(email),
                          const SizedBox(height: 4),
                          Text(phone),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(loc.full_name, name),
                    _infoRow(loc.email, email),
                    _infoRow(loc.phone_number, phone),
                    _infoRow(loc.gender, sex),
                    _infoRow(loc.latitude, latitude?.toStringAsFixed(6) ?? loc.not_set),
                    _infoRow(loc.longitude, longitude?.toStringAsFixed(6) ?? loc.not_set),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit_location),
              label: Text(loc.edit_profile),
              onPressed: _openEdit,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(loc.refresh),
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}