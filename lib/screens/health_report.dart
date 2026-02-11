import 'package:flutter/material.dart';
import '../services/download_service.dart';
import '../services/health_report_pdf_service.dart';

class HealthReportScreen extends StatelessWidget {
  final Map<String, dynamic> healthReport;
  final int severityId;

  const HealthReportScreen({
    Key? key,
    required this.healthReport,
    required this.severityId,
  }) : super(key: key);

  Color _riskColor(int risk) {
    if (risk < 30) return Colors.green;
    if (risk < 50) return Colors.lightGreen;
    if (risk < 70) return Colors.orange;
    if (risk < 85) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final int risk = healthReport['risk_percentage'];
    final String riskLevel = healthReport['risk_level'];
    final List symptoms = healthReport['current_symptoms'];
    final List precautions = healthReport['precautions'];
    final List resources = healthReport['required_hospital_resources'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Risk Report"),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= RISK CARD =================
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Health Risk Level",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: risk / 100,
                            strokeWidth: 10,
                            valueColor: AlwaysStoppedAnimation(
                              _riskColor(risk),
                            ),
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "$risk%",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _riskColor(risk),
                              ),
                            ),
                            Text(
                              riskLevel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= SYMPTOMS =================
            _sectionCard(
              title: "Current Symptoms",
              icon: Icons.sick,
              items: symptoms,
            ),

            // ================= PRECAUTIONS =================
            _sectionCard(
              title: "Immediate Precautions",
              icon: Icons.warning_amber_rounded,
              items: precautions,
            ),

            // ================= RESOURCES =================
            _sectionCard(
              title: "Required Hospital Facilities",
              icon: Icons.local_hospital,
              items: resources.map((e) => e.toString().replaceAll("_", " ").toUpperCase()).toList(),
            ),

            const SizedBox(height: 16),

            // ================= PDF DOWNLOAD =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Download Health Report (PDF)"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.orange[700],
                ),
                onPressed: () => _generateHealthReportPDF(context, healthReport),
              ),
            ),

            const SizedBox(height: 24),

            // ================= ACTION =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_hospital),
                label: const Text("View Recommended Hospitals"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue[700],
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    "/hospitals",
                    arguments: severityId,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= REUSABLE SECTION CARD =================
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "No items recorded",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              )
            else
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text("• $item"),
                  )),
          ],
        ),
      ),
    );
  }

  void _generateHealthReportPDF(BuildContext context, Map<String, dynamic> report) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating Health Report PDF...'),
              ],
            ),
          ),
        ),
      );

      // Generate PDF
      final pdfBytes = await HealthReportPDFService.generateHealthReportPDF(
        report,
        citizenName: 'Citizen',
        reportDate: DateTime.now().toString().split(' ')[0],
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Download file across all platforms
      await DownloadService.downloadFile(
        'HealthReport_${DateTime.now().millisecondsSinceEpoch}.pdf',
        pdfBytes,
        mimeType: 'application/pdf',
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health report downloaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading report: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
