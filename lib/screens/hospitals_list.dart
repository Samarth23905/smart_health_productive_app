import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../services/api_services.dart';
import '../gen/l10n/app_localizations.dart';

class HospitalsList extends StatefulWidget {
  final int? severityId;
  final Map<String, dynamic>? healthReport;

  const HospitalsList({
    Key? key,
    this.severityId,
    this.healthReport,
  }) : super(key: key);

  @override
  State<HospitalsList> createState() => _HospitalsListState();
}

class _HospitalsListState extends State<HospitalsList> {
  late Future<List<Map<String, dynamic>>> _hospitalsFuture;
  String _sortBy = "relevance";
  bool _isDynamic = false;

  List<String> requiredResources = [];

  @override
  void initState() {
    super.initState();

    requiredResources = List<String>.from(
      widget.healthReport?['required_hospital_resources'] ?? [],
    );

    if (widget.severityId != null) {
      _isDynamic = true;
      _hospitalsFuture = _fetchDynamicHospitals();
    } else {
      _isDynamic = false;
      _hospitalsFuture = _loadUserLocationAndFetchHospitals();
    }
  }

  // ================= FETCH DYNAMIC =================
  Future<List<Map<String, dynamic>>> _fetchDynamicHospitals() async {
    final response = await ApiService.getDynamicHospitals(widget.severityId!);
    List<Map<String, dynamic>> hospitals =
        List<Map<String, dynamic>>.from(response['hospitals'] ?? []);

    if (_sortBy == "distance") {
      hospitals.sort(
        (a, b) => (a['distance_km'] as num).compareTo(b['distance_km'] as num),
      );
    }
    return hospitals;
  }

  // ================= STATIC =================
  Future<List<Map<String, dynamic>>> _loadUserLocationAndFetchHospitals() async {
    try {
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {}
    final data = await ApiService.getHospitals();
    if (data is List) {
      try {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        return <Map<String, dynamic>>[];
      }
    }
    return <Map<String, dynamic>>[];
  }

  // ================= UTIL =================
  Future<void> _openMap(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    await launchUrl(Uri.parse(url));
  }

  Color _matchColor(int p) {
    if (p >= 80) return Colors.green;
    if (p >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _rankColor(int r) {
    if (r == 0) return Colors.amber;
    if (r == 1) return Colors.grey;
    if (r == 2) return Colors.orange;
    return Colors.blue;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isDynamic ? "Recommended Hospitals" : loc.nearby_hospitals),
        backgroundColor: _isDynamic ? Colors.blue : Colors.green,
        actions: _isDynamic
            ? [
                PopupMenuButton(
                  onSelected: (val) {
                    setState(() {
                      _sortBy = val;
                      _hospitalsFuture = _fetchDynamicHospitals();
                    });
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "relevance", child: Text("By Relevance")),
                    PopupMenuItem(value: "distance", child: Text("By Distance")),
                  ],
                )
              ]
            : null,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _hospitalsFuture,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text("No hospitals found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snap.data!.length,
            itemBuilder: (_, i) {
              final h = snap.data![i];
              return _isDynamic
                  ? _dynamicCard(h, i)
                  : _staticCard(h);
            },
          );
        },
      ),
    );
  }

  // ================= DYNAMIC CARD =================
  Widget _dynamicCard(Map<String, dynamic> h, int rank) {
    int match = h['match_percentage'] ?? 0;
    double dist = (h['distance_km'] ?? 0).toDouble();

    bool hasICU = h['has_icu'] ?? false;
    bool hasOxygen = h['oxygen_available'] ?? false;
    bool hasCT = h['has_ct'] ?? false;
    bool hasMRI = h['has_mri'] ?? false;
    bool emergency = h['emergency_24x7'] ?? false;

    final hospitalResources = <String>[
      if (hasICU) 'icu',
      if (hasOxygen) 'oxygen',
      if (hasCT) 'ct_scan',
      if (hasMRI) 'mri',
      if (emergency) '24x7_emergency',
    ];

    final matched = hospitalResources
        .where((r) => requiredResources.contains(r))
        .toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _matchColor(match).withOpacity(.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _rankColor(rank),
                  child: Text("${rank + 1}"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    h['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: match / 100),
                  duration: const Duration(seconds: 1),
                  builder: (_, v, __) => CircularProgressIndicator(
                    value: v,
                    strokeWidth: 4,
                    valueColor:
                        AlwaysStoppedAnimation(_matchColor(match)),
                  ),
                ),
                const SizedBox(width: 6),
                Text("$match%"),
              ],
            ),
          ),

          // ===== DETAILS =====
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📍 ${dist.toStringAsFixed(1)} km away"),
                const SizedBox(height: 6),

                if (matched.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Why this hospital?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...matched.map(
                          (r) => Text(
                            "✔ Supports ${r.replaceAll('_', ' ').toUpperCase()}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.navigation),
                        label: const Text("Directions"),
                        onPressed: () => _openMap(
                          h['latitude'],
                          h['longitude'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("Select"),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Selected ${h['name']}")),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATIC CARD =================
  Widget _staticCard(Map<String, dynamic> h) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_hospital),
        title: Text(h['name']),
        subtitle: Text(h['phone'] ?? ""),
        trailing: IconButton(
          icon: const Icon(Icons.navigation),
          onPressed: () => _openMap(h['latitude'], h['longitude']),
        ),
      ),
    );
  }
}
