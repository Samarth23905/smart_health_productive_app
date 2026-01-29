import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'hospitals_list.dart';

class SymptomsFormPage extends StatefulWidget {
  const SymptomsFormPage({Key? key}) : super(key: key);

  @override
  State<SymptomsFormPage> createState() => _SymptomsFormPageState();
}

class _SymptomsFormPageState extends State<SymptomsFormPage> {
  final Map<String, List<String>> symptomsBySystem = {
    "❤️ Heart (Cardiovascular System)": [
      "Chest pain or pressure",
      "Feeling your heart beating fast or irregularly",
      "Getting breathless easily",
      "Trouble breathing when lying flat",
      "Waking up at night feeling breathless",
      "Fainting or feeling like you may faint",
      "Swelling of feet or ankles",
      "Bluish lips or fingers",
      "Feeling very tired",
      "Leg pain while walking",
    ],
    "🧠 Brain & Nerves (Nervous System)": [
      "Headache",
      "Feeling dizzy or spinning",
      "Blacking out",
      "Fits / seizures",
      "Weakness in arms or legs",
      "Numbness or 'pins and needles' feeling",
      "Trouble speaking",
      "Blurred or double vision",
      "Memory problems or confusion",
      "Shaking of hands",
      "Difficulty walking or keeping balance",
    ],
    "🫁 Lungs (Respiratory System)": [
      "Cough",
      "Mucus/phlegm while coughing",
      "Blood in cough",
      "Breathlessness",
      "Whistling sound while breathing",
      "Chest pain while breathing deeply",
      "Noisy breathing",
      "Fever with cough",
      "Night sweating",
      "Weight loss",
    ],
    "🍽️ Stomach & Digestion (Digestive System)": [
      "Poor appetite",
      "Feeling like vomiting",
      "Vomiting",
      "Burning in chest or throat (acidity)",
      "Stomach pain",
      "Bloated stomach",
      "Difficulty swallowing food",
      "Loose motions",
      "Constipation",
      "Blood in stools or black stools",
      "Yellowing of eyes/skin (jaundice)",
      "Weight loss",
    ],
    "🚽 Urine & Private Parts (Urinary System)": [
      "Burning while passing urine",
      "Going to the toilet very often",
      "Sudden urge to pass urine",
      "Waking up at night to pass urine",
      "Blood in urine",
      "Passing very little urine",
      "Pain in lower back or sides",
      "Leakage of urine",
      "Sexual problems",
    ],
    "🦴 Bones & Muscles": [
      "Joint pain",
      "Swelling of joints",
      "Stiffness in the morning",
      "Muscle pain",
      "Weak muscles",
      "Difficulty moving joints",
      "Bent or changed shape of bones",
      "Back pain",
    ],
    "🩸 Blood-Related Problems": [
      "Feeling weak or tired",
      "Pale skin",
      "Getting bruises easily",
      "Bleeding from gums",
      "Getting infections often",
      "Swollen glands in neck/armpit/groin",
      "Weight loss",
    ],
    "🌡️ General & Hormone-Related": [
      "Fever",
      "Sudden weight gain or loss",
      "Feeling too hot or too cold",
      "Feeling very thirsty",
      "Passing urine very often",
      "Feeling very hungry",
      "Excess sweating",
      "Hair fall",
      "Irregular periods",
    ],
  };

  // Track selected symptoms with their details
  Map<String, SymptomDetail> selectedSymptomsWithDetails = {};
  Map<String, bool> expandedCategories = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize all categories as collapsed
    for (var category in symptomsBySystem.keys) {
      expandedCategories[category] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🩺 Symptom Check"),
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
              child: const Text(
                "Expand categories and select symptoms with details:",
                style: TextStyle(
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
                        const Text(
                          "✅ Selected Symptoms:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${selectedSymptomsWithDetails.length} selected",
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        selectedSymptomsWithDetails.remove(symptom);
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
                                "Duration: ${detail.days} days",
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                "Severity: ${detail.severity}",
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                onPressed: selectedSymptomsWithDetails.isEmpty ? null : _submitSymptoms,
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
                  _isLoading ? "Submitting..." : "Submit Symptoms",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                bool isSelected = selectedSymptomsWithDetails.containsKey(symptom);
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.green[800] : Colors.black87,
                    ),
                  ),
                  if (isSelected)
                    Text(
                      "${selectedSymptomsWithDetails[symptom]!.days} days • ${selectedSymptomsWithDetails[symptom]!.severity}",
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
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            symptom,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Days Input
                const Text(
                  "How many days?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter number of days",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      suffix: Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Text("days"),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && int.tryParse(value) != null) {
                        days = int.parse(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Severity Radio Buttons
                const Text(
                  "Severity Level:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    _buildRadioOption(
                      label: "🟢 Mild",
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
                      label: "🟡 Moderate",
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
                      label: "🔴 Severe",
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
              child: const Text("Cancel"),
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
              child: const Text("Add Symptom"),
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
            color: groupValue == value ? Colors.orange[400]! : Colors.grey[300]!,
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
                fontWeight: groupValue == value ? FontWeight.bold : FontWeight.normal,
                color: groupValue == value ? Colors.orange[800] : Colors.black87,
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
      // Format symptoms with details for backend
      List<String> symptomsList = selectedSymptomsWithDetails.entries.map((e) {
        return "${e.key} (${e.value.days} days, ${e.value.severity})";
      }).toList();

      final symptomsText = symptomsList.join(" | ");

      final result = await ApiService.submitSymptoms(symptomsText);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Symptoms submitted successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to Hospitals List
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) =>  HospitalsList()),
          );
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
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