import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_services.dart';
import '../constants/app_colors.dart';
import '../gen/l10n/app_localizations.dart';
import 'health_report.dart';

class SymptomsFormPage extends StatefulWidget {
  const SymptomsFormPage({Key? key}) : super(key: key);

  @override
  State<SymptomsFormPage> createState() => _SymptomsFormPageState();
}

class _SymptomsFormPageState extends State<SymptomsFormPage> {
  Map<String, List<String>> _getLocalizedSymptoms(AppLocalizations loc) {
    return {
      loc.cardiovascular_system: [
        loc.chest_pain,
        loc.heart_beating_fast,
        loc.breathlessness,
        loc.trouble_breathing_lying,
        loc.waking_breathless,
        loc.fainting,
        loc.swelling_extremities,
        loc.bluish_lips,
        loc.very_tired,
        loc.leg_pain_walking,
      ],
      loc.nervous_system: [
        loc.headache,
        loc.dizziness,
        loc.blacking_out,
        loc.seizures,
        loc.weakness_limbs,
        loc.numbness,
        loc.trouble_speaking,
        loc.blurred_vision,
        loc.memory_problems,
        loc.shaking_hands,
        loc.difficulty_walking,
      ],
      loc.respiratory_system: [
        loc.cough,
        loc.mucus_cough,
        loc.blood_cough,
        loc.breathlessness,
        loc.whistling_breathing,
        loc.chest_pain_breathing,
        loc.noisy_breathing,
        loc.fever_cough,
        loc.night_sweating,
        loc.weight_loss,
      ],
      loc.digestive_system: [
        loc.poor_appetite,
        loc.feeling_nausea,
        loc.vomiting,
        loc.burning_chest,
        loc.stomach_pain,
        loc.bloated_stomach,
        loc.difficulty_swallowing,
        loc.loose_motions,
        loc.constipation,
        loc.blood_stools,
        loc.jaundice,
        loc.weight_loss,
      ],
      loc.urinary_system: [
        loc.burning_urination,
        loc.frequent_urination,
        loc.sudden_urge,
        loc.nocturia,
        loc.blood_urine,
        loc.low_urine,
        loc.lower_back_pain,
        loc.urine_leakage,
        loc.sexual_problems,
      ],
      loc.musculoskeletal_system: [
        loc.joint_pain,
        loc.joint_swelling,
        loc.morning_stiffness,
        loc.muscle_pain,
        loc.weak_muscles,
        loc.difficulty_joint_movement,
        loc.bent_bones,
        loc.back_pain,
      ],
      loc.blood_system: [
        loc.feeling_weak_tired,
        loc.pale_skin,
        loc.easy_bruising,
        loc.gum_bleeding,
        loc.frequent_infections,
        loc.swollen_glands,
        loc.weight_loss,
      ],
      loc.general_hormone_system: [
        loc.fever,
        loc.sudden_weight_change,
        loc.temperature_sensitivity,
        loc.excessive_thirst,
        loc.excessive_urination,
        loc.excessive_hunger,
        loc.excess_sweating,
        loc.hair_fall,
        loc.irregular_periods,
      ],
    };
  }

  // Track selected symptoms with their details
  Map<String, SymptomDetail> selectedSymptomsWithDetails = {};
  Map<String, bool> expandedCategories = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final symptomsBySystem = _getLocalizedSymptoms(loc);

    // Initialize categories as collapsed on first build
    if (expandedCategories.isEmpty) {
      for (var category in symptomsBySystem.keys) {
        expandedCategories[category] = false;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.symptom_check),
        backgroundColor: Colors.orange[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Text(
                loc.select_symptoms_with_details,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Expandable Categories
            ...symptomsBySystem.entries.map((entry) {
              return _buildExpandableCategory(entry.key, entry.value);
            }).toList(),

            const SizedBox(height: 24),

            // Selected Symptoms Display
            if (selectedSymptomsWithDetails.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selected_symptoms,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${selectedSymptomsWithDetails
                                .length} ${AppLocalizations.of(context)!
                                .selected}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...selectedSymptomsWithDetails.entries.map((entry) {
                      final symptom = entry.key;
                      final detail = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      symptom,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedSymptomsWithDetails.remove(
                                            symptom);
                                      });
                                    },
                                    icon: const Icon(Icons.close, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${AppLocalizations.of(context)!
                                    .duration}: ${detail
                                    .days} ${AppLocalizations.of(context)!
                                    .days}",
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                "${AppLocalizations.of(context)!
                                    .severity}: ${detail.severity}",
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedSymptomsWithDetails.isEmpty
                    ? null
                    : _submitSymptoms,
                icon: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.check),
                label: Text(
                  _isLoading
                      ? AppLocalizations.of(context)!.submitting
                      : AppLocalizations.of(context)!.submit_symptoms,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCategory(String category, List<String> symptoms) {
    bool isExpanded = expandedCategories[category] ?? false;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              expandedCategories[category] = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: isExpanded ? Colors.orange[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isExpanded ? Colors.orange[400]! : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isExpanded ? Colors.orange[800] : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: isExpanded ? Colors.orange[800] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: symptoms.map((symptom) {
                bool isSelected = selectedSymptomsWithDetails.containsKey(
                    symptom);
                return _buildSymptomOption(symptom, isSelected);
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSymptomOption(String symptom, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          setState(() {
            selectedSymptomsWithDetails.remove(symptom);
          });
        } else {
          _showSymptomDetailsDialog(symptom);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.green[300]! : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Colors.green : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symptom,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight
                          .normal,
                      color: isSelected ? Colors.green[800] : Colors.black87,
                    ),
                  ),
                  if (isSelected)
                    Text(
                      "${selectedSymptomsWithDetails[symptom]!
                          .days} days • ${selectedSymptomsWithDetails[symptom]!
                          .severity}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSymptomDetailsDialog(String symptom) {
    int days = 1;
    String severity = "mild";

    showDialog(
      context: context,
      builder: (_) =>
          StatefulBuilder(
            builder: (context, setState) =>
                AlertDialog(
                  title: Text(
                    symptom,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Days Input
                        Text(
                          AppLocalizations.of(context)!.how_many_days,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .enter_number_of_days,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              suffix: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text(AppLocalizations.of(context)!.days),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && int.tryParse(value) !=
                                  null) {
                                days = int.parse(value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Severity Radio Buttons
                        Text(
                          AppLocalizations.of(context)!.severity_level,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            _buildRadioOption(
                              label: "🟢 ${AppLocalizations.of(context)!.mild}",
                              value: "mild",
                              groupValue: severity,
                              onChanged: (value) {
                                setState(() {
                                  severity = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildRadioOption(
                              label: "🟡 ${AppLocalizations.of(context)!
                                  .moderate}",
                              value: "moderate",
                              groupValue: severity,
                              onChanged: (value) {
                                setState(() {
                                  severity = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildRadioOption(
                              label: "🔴 ${AppLocalizations.of(context)!
                                  .severe}",
                              value: "severe",
                              groupValue: severity,
                              onChanged: (value) {
                                setState(() {
                                  severity = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSymptomsWithDetails[symptom] = SymptomDetail(
                            days: days,
                            severity: severity,
                          );
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text(AppLocalizations.of(context)!.add_symptom),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildRadioOption({
    required String label,
    required String value,
    required String groupValue,
    required Function(String) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: groupValue == value ? Colors.orange[50] : Colors.white,
          border: Border.all(
            color: groupValue == value ? Colors.orange[400]! : Colors
                .grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: (val) => onChanged(val!),
              activeColor: Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: groupValue == value ? FontWeight.bold : FontWeight
                    .normal,
                color: groupValue == value ? Colors.orange[800] : Colors
                    .black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSymptoms() async {
    if (selectedSymptomsWithDetails.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ================= LOCATION UPDATE =================
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        await ApiService.updateCitizenLocation(
          position.latitude,
          position.longitude,
        );
      } catch (locErr) {
        debugPrint("[SubmitSymptoms] Location error: $locErr");
      }

      // ================= FORMAT SYMPTOMS =================
      final symptomsText = selectedSymptomsWithDetails.entries
          .map((e) => "${e.key} (${e.value.days} days, ${e.value.severity})")
          .join(" | ");

      // ================= API CALL =================
      final result = await ApiService.submitSymptoms(symptomsText);

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.symptoms_submitted_successfully,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        final int severityId = result['severity_id'];
        final int riskPercentage = result['risk_percentage'] ?? 0;

        final Map<String, dynamic> healthReport =
        result['health_report'] != null
            ? Map<String, dynamic>.from(result['health_report'])
            : {};

        healthReport['risk_percentage'] = riskPercentage;

        // ================= NAVIGATE =================
        Future.delayed(const Duration(milliseconds: 400), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  HealthReportScreen(
                    healthReport: healthReport,
                    severityId: severityId,
                  ),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${AppLocalizations.of(context)!.error_message}$e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}

// Model class to store symptom details
class SymptomDetail {
  final int days;
  final String severity;

  SymptomDetail({
    required this.days,
    required this.severity,
  });
}