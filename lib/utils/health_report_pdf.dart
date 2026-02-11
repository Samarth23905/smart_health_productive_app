import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> generateHealthReportPDF(
  Map<String, dynamic> report,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Smart Health – Health Report",
              style: pw.TextStyle(fontSize: 22)),
          pw.SizedBox(height: 12),

          pw.Text("Risk Percentage: ${report['risk_percentage']}%"),
          pw.Text("Risk Level: ${report['risk_level']}"),
          pw.SizedBox(height: 10),

          pw.Text("Symptoms:", style: pw.TextStyle(fontSize: 14)),
          ...List.from(report['current_symptoms'])
              .map((s) => pw.Text("- $s")),

          pw.SizedBox(height: 10),
          pw.Text("Precautions:", style: pw.TextStyle(fontSize: 14)),
          ...List.from(report['precautions'])
              .map((p) => pw.Text("- $p")),

          pw.SizedBox(height: 10),
          pw.Text("Required Hospital Facilities:",
              style: pw.TextStyle(fontSize: 14)),
          ...List.from(report['required_hospital_resources'])
              .map((r) => pw.Text("- ${r.toString().toUpperCase()}")),
        ],
      ),
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final file = File("${dir.path}/health_report.pdf");

  await file.writeAsBytes(await pdf.save());
  await OpenFile.open(file.path);
}
