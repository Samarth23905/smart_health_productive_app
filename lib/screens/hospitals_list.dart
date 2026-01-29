import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../services/api_services.dart';
import '../constants/app_colors.dart';

class HospitalsList extends StatefulWidget {
  const HospitalsList({Key? key}) : super(key: key);

  @override
  State<HospitalsList> createState() => _HospitalsListState();
}

class _HospitalsListState extends State<HospitalsList> {
  late Future<List<Map<String, dynamic>>> _hospitalsFuture;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _hospitalsFuture = _loadUserLocationAndFetchHospitals();
  }

  Future<List<Map<String, dynamic>>> _loadUserLocationAndFetchHospitals() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userPosition = position;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location error: $e")),
        );
      }
    }
    
    return _fetchAndSortHospitals();
  }

  Future<List<Map<String, dynamic>>> _fetchAndSortHospitals() async {
    try {
      final hospitals = await ApiService.getHospitals();

      List<Map<String, dynamic>> hospitalsWithDistance = [];

      for (var hospital in hospitals) {
        double distance = 0;
        if (_userPosition != null) {
          distance = _calculateDistance(
            _userPosition!.latitude,
            _userPosition!.longitude,
            (hospital['latitude'] as num).toDouble(),
            (hospital['longitude'] as num).toDouble(),
          );
        }

        hospitalsWithDistance.add({
          'id': hospital['id'],
          'name': hospital['name'],
          'phone': hospital['phone'],
          'latitude': (hospital['latitude'] as num).toDouble(),
          'longitude': (hospital['longitude'] as num).toDouble(),
          'beds_available': hospital['beds_available'],
          'oxygen_available': hospital['oxygen_available'],
          'distance': distance,
        });
      }

      hospitalsWithDistance.sort((a, b) => 
        (a['distance'] as num).compareTo(b['distance'] as num)
      );

      return hospitalsWithDistance;
    } catch (e) {
      throw Exception("Failed to load hospitals: $e");
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏥 Nearby Hospitals"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _hospitalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hospitalsFuture = _loadUserLocationAndFetchHospitals();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hospitals found"));
          }

          final hospitals = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
              final hospital = hospitals[index];
              return _buildHospitalCard(hospital);
            },
          );
        },
      ),
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital) {
    final distance = hospital['distance'] as double;
    final distanceText = "${distance.toStringAsFixed(1)} km";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_hospital, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hospital['name'] as String? ?? 'Hospital',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  distanceText,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  hospital['phone'] as String? ?? 'N/A',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  "Beds: ${hospital['beds_available'] ?? 0}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.opacity, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  "Oxygen: ${hospital['oxygen_available'] == true ? 'Yes' : 'No'}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMap(
                  hospital['latitude'] as double,
                  hospital['longitude'] as double,
                ),
                icon: const Icon(Icons.navigation),
                label: const Text("📍 Navigate"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}