import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class HealthReportPDFService {
  /// Generate health report PDF from report data
  static Future<Uint8List> generateHealthReportPDF(
    Map<String, dynamic> healthReport, {
    String citizenName = 'Citizen',
    String? reportDate,
  }) async {
    try {
      final pdf = pw.Document();
      final now = reportDate ?? DateTime.now().toString().split(' ')[0];

      final risk = healthReport['risk_percentage'] ?? 0;
      final riskLevel = healthReport['risk_level'] ?? 'unknown';
      final symptoms = List<String>.from(healthReport['current_symptoms'] ?? []);
      final precautions = List<String>.from(healthReport['precautions'] ?? []);
      final resources = List<String>.from(healthReport['required_hospital_resources'] ?? []);

      // Determine header color based on risk level
      PdfColor headerColor;
      switch (riskLevel.toLowerCase()) {
        case 'critical':
          headerColor = PdfColors.red;
          break;
        case 'high':
          headerColor = PdfColors.deepOrange;
          break;
        case 'medium':
          headerColor = PdfColors.orange;
          break;
        default:
          headerColor = PdfColors.green;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SMART HEALTH',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                  pw.Text(
                    'Health Risk Report',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
            ],
          ),
          footer: (context) => pw.Column(
            children: [
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated on: $now',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          build: (context) => [
            // ===== HEADER SECTION =====
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border(left: pw.BorderSide(color: headerColor, width: 4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Citizen: $citizenName',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Report Date: $now',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // ===== RISK LEVEL SECTION =====
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'HEALTH RISK LEVEL',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        '$risk%',
                        style: pw.TextStyle(
                          fontSize: 48,
                          fontWeight: pw.FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Text(
                        riskLevel.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // ===== CURRENT SYMPTOMS =====
            _buildSection(
              title: '📋 CURRENT SYMPTOMS',
              items: symptoms.isEmpty ? ['No symptoms recorded'] : symptoms,
            ),
            pw.SizedBox(height: 16),

            // ===== PRECAUTIONS =====
            _buildSection(
              title: '⚠️  IMMEDIATE PRECAUTIONS',
              items: precautions.isEmpty ? ['No precautions'] : precautions,
            ),
            pw.SizedBox(height: 16),

            // ===== REQUIRED RESOURCES =====
            _buildSection(
              title: '🏥 REQUIRED HOSPITAL FACILITIES',
              items: resources.isEmpty
                  ? ['No specific resources']
                  : resources.map((r) => r.replaceAll('_', ' ').toUpperCase()).toList(),
            ),
            pw.SizedBox(height: 24),

            // ===== RECOMMENDATIONS =====
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.green, width: 3),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RECOMMENDATIONS',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '• Seek medical consultation at a nearby hospital with the required facilities.',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '• Follow all precautions strictly to prevent condition deterioration.',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '• Monitor symptoms closely and report any changes immediately.',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // ===== FOOTER NOTE =====
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                'This report is generated by Smart Health and should not replace professional medical advice. '
                'Always consult with a qualified healthcare provider for diagnosis and treatment.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      );

      return pdf.save();
    } catch (e) {
      rethrow;
    }
  }

  /// Build a section with title and items
  static pw.Widget _buildSection({
    required String title,
    required List<String> items,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Text(
                        item,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
