import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../services/api_services.dart';
import '../constants/app_colors.dart';
import '../gen/l10n/app_localizations.dart';

class HospitalsList extends StatefulWidget {
  final int? severityId;  // NEW: Accept severity_id for dynamic ranking

  const HospitalsList({Key? key, this.severityId}) : super(key: key);

  @override
  State<HospitalsList> createState() => _HospitalsListState();
}

class _HospitalsListState extends State<HospitalsList> {
  late Future<List<Map<String, dynamic>>> _hospitalsFuture;
  String _sortBy = "relevance";  // relevance or distance
  bool _isDynamic = false;  // Track if showing dynamic ranking

  @override
  void initState() {
    super.initState();

    // If severity_id provided, fetch dynamic hospitals
    // Otherwise, fall back to static hospitals
    if (widget.severityId != null) {
      _isDynamic = true;
      _hospitalsFuture = _fetchDynamicHospitals();
    } else {
      _isDynamic = false;
      _hospitalsFuture = _loadUserLocationAndFetchHospitals();
    }
  }

  // ===== NEW: Dynamic Hospital Fetching =====
  Future<List<Map<String, dynamic>>> _fetchDynamicHospitals() async {
    try {
      final response = await ApiService.getDynamicHospitals(widget.severityId!);

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      List<Map<String, dynamic>> hospitals =
          List<Map<String, dynamic>>.from(response['hospitals'] ?? []);

      // Default: sort by relevance (already done by backend)
      if (_sortBy == "distance") {
        hospitals.sort((a, b) => (a['distance_km'] as num).compareTo(b['distance_km'] as num));
      }

      print("[HospitalsList] Dynamic hospitals loaded: ${hospitals.length} hospitals");
      return hospitals;
    } catch (e) {
      print("[HospitalsList Error] $e");
      throw Exception("Failed to load hospitals: $e");
    }
  }

  // ===== OLD: Static Hospital Fetching =====
  Future<List<Map<String, dynamic>>> _loadUserLocationAndFetchHospitals() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.location_error}$e")),
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
        hospitalsWithDistance.add({
          'id': hospital['id'],
          'name': hospital['name'],
          'phone': hospital['phone'],
          'latitude': (hospital['latitude'] as num).toDouble(),
          'longitude': (hospital['longitude'] as num).toDouble(),
          'beds_available': hospital['beds_available'],
          'oxygen_available': hospital['oxygen_available'],
          'distance_km': 0.0,  // Not used in dynamic mode
        });
      }

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

  Color _getMatchColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getRankColor(int rank) {
    if (rank == 0) return Colors.amber[600]!;      // Gold
    if (rank == 1) return Colors.grey[500]!;       // Silver
    if (rank == 2) return Colors.orange[600]!;     // Bronze
    return Colors.blue[400]!;                      // Other
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isDynamic ? "Recommended Hospitals" : loc.nearby_hospitals),
        backgroundColor: _isDynamic ? Colors.blue[700] : Colors.green[700],
        centerTitle: true,
        elevation: 0,
        actions: _isDynamic
            ? [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange),
                          SizedBox(width: 8),
                          Text("By Relevance"),
                        ],
                      ),
                      value: "relevance",
                      onTap: () {
                        setState(() => _sortBy = "relevance");
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue),
                          SizedBox(width: 8),
                          Text("By Distance"),
                        ],
                      ),
                      value: "distance",
                      onTap: () {
                        setState(() => _sortBy = "distance");
                      },
                    ),
                  ],
                ),
              ]
            : null,
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
                  Text("${loc.error_loading}${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_isDynamic) {
                          _hospitalsFuture = _fetchDynamicHospitals();
                        } else {
                          _hospitalsFuture = _loadUserLocationAndFetchHospitals();
                        }
                      });
                    },
                    child: Text(loc.retry),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(loc.no_hospitals_found_message));
          }

          final hospitals = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
              final hospital = hospitals[index];
              return _isDynamic
                  ? _buildDynamicHospitalCard(hospital, index)
                  : _buildHospitalCard(hospital);
            },
          );
        },
      ),
    );
  }

  // ===== NEW: Dynamic Hospital Card with Match %= =====
  Widget _buildDynamicHospitalCard(Map<String, dynamic> hospital, int rank) {
    int matchPercentage = hospital['match_percentage'] ?? 0;
    double distance = (hospital['distance_km'] as num?)?.toDouble() ?? 0.0;
    String hospitalName = hospital['name'] ?? 'Hospital';
    String phone = hospital['phone'] ?? 'N/A';
    String reason = hospital['recommendation'] ?? hospital['reason'] ?? 'Suitable for your condition';

    Color matchColor = _getMatchColor(matchPercentage);
    Color rankColor = _getRankColor(rank);

    bool hasICU = hospital['icu_available'] ?? hospital['has_icu'] ?? false;
    bool hasOxygen = hospital['oxygen_available'] ?? false;
    bool hasCT = hospital['has_ct'] ?? false;
    bool hasMRI = hospital['has_mri'] ?? false;
    bool emergency24x7 = hospital['emergency_24x7'] ?? false;
    int bedsAvailable = hospital['beds_available'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header with rank, name, match %
          Container(
            decoration: BoxDecoration(
              color: matchColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: matchColor, width: 3),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Rank badge (Gold, Silver, Bronze)
                CircleAvatar(
                  backgroundColor: rankColor,
                  child: Text(
                    "${rank + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  radius: 20,
                ),
                const SizedBox(width: 12),

                // Hospital name & reason
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospitalName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Match percentage circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: matchPercentage / 100,
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(matchColor),
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "$matchPercentage%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: matchColor,
                          ),
                        ),
                        Text(
                          "MATCH",
                          style: TextStyle(fontSize: 8, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Hospital details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance & Phone
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      distance < 999
                          ? "${distance.toStringAsFixed(1)} km away"
                          : "Distance unknown",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.phone, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      phone,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Facilities chips
                Wrap(
                  spacing: 6,
                  children: [
                    if (hasICU)
                      Chip(
                        label: const Text("🏥 ICU"),
                        backgroundColor: Colors.orange[100],
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                    if (hasOxygen)
                      Chip(
                        label: const Text("💨 Oxygen"),
                        backgroundColor: Colors.blue[100],
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                    if (hasCT || hasMRI)
                      Chip(
                        label: const Text("🔬 Diagnostics"),
                        backgroundColor: Colors.purple[100],
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                    if (emergency24x7)
                      Chip(
                        label: const Text("24/7"),
                        backgroundColor: Colors.red[100],
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text("DIRECTIONS"),
                    onPressed: () => _openMap(
                      (hospital['latitude'] as num).toDouble(),
                      (hospital['longitude'] as num).toDouble(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text("SELECT"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Selected: $hospitalName"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      // TODO: Handle hospital selection (call ambulance, etc.)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: matchColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== OLD: Static Hospital Card =====
  Widget _buildHospitalCard(Map<String, dynamic> hospital) {
    final loc = AppLocalizations.of(context)!;
    final distanceText = "${hospital['distance_km']?.toStringAsFixed(1) ?? 'N/A'} km";

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
                  "${loc.beds_label}${hospital['beds_available'] ?? 0}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.opacity, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  "${loc.oxygen_label}${hospital['oxygen_available'] == true ? loc.oxygen_yes : loc.oxygen_no}",
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
                label: Text(loc.navigate_button),
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
