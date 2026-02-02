import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../constants/app_colors.dart';
import '../gen/l10n/app_localizations.dart';

class HospitalProfileEditScreen extends StatefulWidget {
  @override
  State<HospitalProfileEditScreen> createState() =>
      _HospitalProfileEditScreenState();
}

class _HospitalProfileEditScreenState extends State<HospitalProfileEditScreen> {
  bool isLoading = true;
  bool isSaving = false;
  String? error;
  bool expandAll = false;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final bedsCtrl = TextEditingController();
  final availableBedsCtrl = TextEditingController();
  final icuBedsCtrl = TextEditingController();
  bool oxygenAvailable = false;
  String hospitalType = 'Private';

  // Ward resources
  final generalTotalCtrl = TextEditingController();
  final generalAvailableCtrl = TextEditingController();
  final semiTotalCtrl = TextEditingController();
  final semiAvailableCtrl = TextEditingController();
  final privateTotalCtrl = TextEditingController();
  final privateAvailableCtrl = TextEditingController();
  final isolationTotalCtrl = TextEditingController();
  final isolationAvailableCtrl = TextEditingController();

  // ICU resources (MICU, SICU, NICU, CCU, PICU)
  final micuTotalCtrl = TextEditingController();
  final micuAvailableCtrl = TextEditingController();
  final micuVentCtrl = TextEditingController();
  final micuMonitorCtrl = TextEditingController();
  bool micuOxygen = false;

  final sicuTotalCtrl = TextEditingController();
  final sicuAvailableCtrl = TextEditingController();
  final sicuVentCtrl = TextEditingController();
  final sicuMonitorCtrl = TextEditingController();
  bool sicuOxygen = false;

  final nicuTotalCtrl = TextEditingController();
  final nicuAvailableCtrl = TextEditingController();
  final nicuVentCtrl = TextEditingController();
  final nicuMonitorCtrl = TextEditingController();
  bool nicuOxygen = false;

  final ccuTotalCtrl = TextEditingController();
  final ccuAvailableCtrl = TextEditingController();
  final ccuVentCtrl = TextEditingController();
  final ccuMonitorCtrl = TextEditingController();
  bool ccuOxygen = false;

  final picuTotalCtrl = TextEditingController();
  final picuAvailableCtrl = TextEditingController();
  final picuVentCtrl = TextEditingController();
  final picuMonitorCtrl = TextEditingController();
  bool picuOxygen = false;

  // Emergency & life-saving
  bool emergency24 = false;
  bool ambulanceAvailable = false;
  final ambulanceCountCtrl = TextEditingController();
  bool defibrillator = false;
  bool centralO2 = false;

  // Diagnostic
  bool lab = false;
  bool xray = false;
  bool ecg = false;
  bool ultrasound = false;
  bool ctScan = false;
  bool mri = false;

  // Pharmacy & supplies
  bool inHousePharmacy = false;
  bool pharmacy24 = false;
  final oxygenCylindersCtrl = TextEditingController();
  bool essentialDrugs = false;

  // Human resources
  final doctorsCountCtrl = TextEditingController();
  final nursesCountCtrl = TextEditingController();
  bool icuTrainedStaff = false;
  bool anesthetistAvailable = false;

  // Support resources
  bool bloodBank = false;
  bool dialysisUnit = false;
  bool cssd = false;
  bool mortuary = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    try {
      final profile = await ApiService.getHospitalProfile();
      if (profile != null) {
        setState(() {
          nameCtrl.text = profile['name'] ?? '';
          phoneCtrl.text = profile['phone'] ?? '';
          emailCtrl.text = profile['email'] ?? '';
          bedsCtrl.text = profile['total_beds']?.toString() ?? '0';
          availableBedsCtrl.text = profile['available_beds']?.toString() ?? '';
          icuBedsCtrl.text = profile['icu_beds']?.toString() ?? '0';
          oxygenAvailable = profile['oxygen_available'] ?? false;
          hospitalType = profile['hospital_type'] ?? hospitalType;

          // wards
          generalTotalCtrl.text = profile['general_total']?.toString() ?? '';
          generalAvailableCtrl.text = profile['general_available']?.toString() ?? '';
          semiTotalCtrl.text = profile['semi_total']?.toString() ?? '';
          semiAvailableCtrl.text = profile['semi_available']?.toString() ?? '';
          privateTotalCtrl.text = profile['private_total']?.toString() ?? '';
          privateAvailableCtrl.text = profile['private_available']?.toString() ?? '';
          isolationTotalCtrl.text = profile['isolation_total']?.toString() ?? '';
          isolationAvailableCtrl.text = profile['isolation_available']?.toString() ?? '';

          // MICU
          micuTotalCtrl.text = profile['micu_total']?.toString() ?? '';
          micuAvailableCtrl.text = profile['micu_available']?.toString() ?? '';
          micuVentCtrl.text = profile['micu_ventilators']?.toString() ?? '';
          micuMonitorCtrl.text = profile['micu_monitors']?.toString() ?? '';
          micuOxygen = profile['micu_oxygen'] ?? false;

          // SICU
          sicuTotalCtrl.text = profile['sicu_total']?.toString() ?? '';
          sicuAvailableCtrl.text = profile['sicu_available']?.toString() ?? '';
          sicuVentCtrl.text = profile['sicu_ventilators']?.toString() ?? '';
          sicuMonitorCtrl.text = profile['sicu_monitors']?.toString() ?? '';
          sicuOxygen = profile['sicu_oxygen'] ?? false;

          // NICU
          nicuTotalCtrl.text = profile['nicu_total']?.toString() ?? '';
          nicuAvailableCtrl.text = profile['nicu_available']?.toString() ?? '';
          nicuVentCtrl.text = profile['nicu_ventilators']?.toString() ?? '';
          nicuMonitorCtrl.text = profile['nicu_monitors']?.toString() ?? '';
          nicuOxygen = profile['nicu_oxygen'] ?? false;

          // CCU
          ccuTotalCtrl.text = profile['ccu_total']?.toString() ?? '';
          ccuAvailableCtrl.text = profile['ccu_available']?.toString() ?? '';
          ccuVentCtrl.text = profile['ccu_ventilators']?.toString() ?? '';
          ccuMonitorCtrl.text = profile['ccu_monitors']?.toString() ?? '';
          ccuOxygen = profile['ccu_oxygen'] ?? false;

          // PICU
          picuTotalCtrl.text = profile['picu_total']?.toString() ?? '';
          picuAvailableCtrl.text = profile['picu_available']?.toString() ?? '';
          picuVentCtrl.text = profile['picu_ventilators']?.toString() ?? '';
          picuMonitorCtrl.text = profile['picu_monitors']?.toString() ?? '';
          picuOxygen = profile['picu_oxygen'] ?? false;

          // Emergency & life-saving
          emergency24 = profile['emergency_24x7'] ?? false;
          ambulanceAvailable = profile['ambulance_available'] ?? false;
          ambulanceCountCtrl.text = profile['ambulance_count']?.toString() ?? '';
          defibrillator = profile['defibrillator'] ?? false;
          centralO2 = profile['central_oxygen'] ?? false;

          // Diagnostic
          lab = profile['lab'] ?? false;
          xray = profile['xray'] ?? false;
          ecg = profile['ecg'] ?? false;
          ultrasound = profile['ultrasound'] ?? false;
          ctScan = profile['ct_scan'] ?? false;
          mri = profile['mri'] ?? false;

          // Pharmacy
          inHousePharmacy = profile['in_house_pharmacy'] ?? false;
          pharmacy24 = profile['pharmacy_24x7'] ?? false;
          oxygenCylindersCtrl.text = profile['oxygen_cylinders']?.toString() ?? '';
          essentialDrugs = profile['essential_drugs'] ?? false;

          // Human resources
          doctorsCountCtrl.text = profile['doctors_count']?.toString() ?? '';
          nursesCountCtrl.text = profile['nurses_count']?.toString() ?? '';
          icuTrainedStaff = profile['icu_trained_staff'] ?? false;
          anesthetistAvailable = profile['anesthetist_available'] ?? false;

          // Support
          bloodBank = profile['blood_bank'] ?? false;
          dialysisUnit = profile['dialysis_unit'] ?? false;
          cssd = profile['cssd'] ?? false;
          mortuary = profile['mortuary'] ?? false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void saveProfile() async {
    setState(() => isSaving = true);
    try {
      final updated = await ApiService.updateHospitalProfile({
        "name": nameCtrl.text,
        "phone": phoneCtrl.text,
        "email": emailCtrl.text,
        "hospital_type": hospitalType,
        "total_beds": int.tryParse(bedsCtrl.text) ?? 0,
        "available_beds": int.tryParse(availableBedsCtrl.text) ?? 0,
        "icu_beds": int.tryParse(icuBedsCtrl.text) ?? 0,
        "oxygen_available": oxygenAvailable,

        // Wards
        "general_total": int.tryParse(generalTotalCtrl.text) ?? 0,
        "general_available": int.tryParse(generalAvailableCtrl.text) ?? 0,
        "semi_total": int.tryParse(semiTotalCtrl.text) ?? 0,
        "semi_available": int.tryParse(semiAvailableCtrl.text) ?? 0,
        "private_total": int.tryParse(privateTotalCtrl.text) ?? 0,
        "private_available": int.tryParse(privateAvailableCtrl.text) ?? 0,
        "isolation_total": int.tryParse(isolationTotalCtrl.text) ?? 0,
        "isolation_available": int.tryParse(isolationAvailableCtrl.text) ?? 0,

        // MICU
        "micu_total": int.tryParse(micuTotalCtrl.text) ?? 0,
        "micu_available": int.tryParse(micuAvailableCtrl.text) ?? 0,
        "micu_ventilators": int.tryParse(micuVentCtrl.text) ?? 0,
        "micu_monitors": int.tryParse(micuMonitorCtrl.text) ?? 0,
        "micu_oxygen": micuOxygen,

        // SICU
        "sicu_total": int.tryParse(sicuTotalCtrl.text) ?? 0,
        "sicu_available": int.tryParse(sicuAvailableCtrl.text) ?? 0,
        "sicu_ventilators": int.tryParse(sicuVentCtrl.text) ?? 0,
        "sicu_monitors": int.tryParse(sicuMonitorCtrl.text) ?? 0,
        "sicu_oxygen": sicuOxygen,

        // NICU
        "nicu_total": int.tryParse(nicuTotalCtrl.text) ?? 0,
        "nicu_available": int.tryParse(nicuAvailableCtrl.text) ?? 0,
        "nicu_ventilators": int.tryParse(nicuVentCtrl.text) ?? 0,
        "nicu_monitors": int.tryParse(nicuMonitorCtrl.text) ?? 0,
        "nicu_oxygen": nicuOxygen,

        // CCU
        "ccu_total": int.tryParse(ccuTotalCtrl.text) ?? 0,
        "ccu_available": int.tryParse(ccuAvailableCtrl.text) ?? 0,
        "ccu_ventilators": int.tryParse(ccuVentCtrl.text) ?? 0,
        "ccu_monitors": int.tryParse(ccuMonitorCtrl.text) ?? 0,
        "ccu_oxygen": ccuOxygen,

        // PICU
        "picu_total": int.tryParse(picuTotalCtrl.text) ?? 0,
        "picu_available": int.tryParse(picuAvailableCtrl.text) ?? 0,
        "picu_ventilators": int.tryParse(picuVentCtrl.text) ?? 0,
        "picu_monitors": int.tryParse(picuMonitorCtrl.text) ?? 0,
        "picu_oxygen": picuOxygen,

        // Emergency & life-saving
        "emergency_24x7": emergency24,
        "ambulance_available": ambulanceAvailable,
        "ambulance_count": int.tryParse(ambulanceCountCtrl.text) ?? 0,
        "defibrillator": defibrillator,
        "central_oxygen": centralO2,

        // Diagnostics
        "lab": lab,
        "xray": xray,
        "ecg": ecg,
        "ultrasound": ultrasound,
        "ct_scan": ctScan,
        "mri": mri,

        // Pharmacy
        "in_house_pharmacy": inHousePharmacy,
        "pharmacy_24x7": pharmacy24,
        "oxygen_cylinders": int.tryParse(oxygenCylindersCtrl.text) ?? 0,
        "essential_drugs": essentialDrugs,

        // Human resources
        "doctors_count": int.tryParse(doctorsCountCtrl.text) ?? 0,
        "nurses_count": int.tryParse(nursesCountCtrl.text) ?? 0,
        "icu_trained_staff": icuTrainedStaff,
        "anesthetist_available": anesthetistAvailable,

        // Support
        "blood_bank": bloodBank,
        "dialysis_unit": dialysisUnit,
        "cssd": cssd,
        "mortuary": mortuary,
      });

      if (updated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  Widget _numberField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: Icon(icon),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _boolTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.edit_hospital_profile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.edit_hospital_profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            if (error != null) const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 8),
                Text(expandAll ? 'Collapse all' : 'Expand all'),
                const SizedBox(width: 8),
                Switch(
                  value: expandAll,
                  onChanged: (v) => setState(() => expandAll = v),
                ),
              ],
            ),
            
            // Hospital Resources Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.hospital_resources,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: loc.hospital_name,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.local_hospital),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: loc.phone_number,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: loc.email,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 15),
                  Text(
                    loc.bed_capacity,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bedsCtrl,
                    decoration: InputDecoration(
                      labelText: loc.total_beds,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.bed),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: icuBedsCtrl,
                    decoration: InputDecoration(
                      labelText: loc.icu_beds,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.medical_services),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 15),
                  Text(
                    loc.medical_supplies,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: oxygenAvailable ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: oxygenAvailable ? Colors.green[50] : Colors.grey[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.oxygen_available,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              oxygenAvailable ? loc.available : loc.not_available,
                              style: TextStyle(
                                fontSize: 14,
                                color: oxygenAvailable ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: oxygenAvailable,
                          onChanged: (v) => setState(() => oxygenAvailable = v),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            loc.oxygen_info_message,
                            style: const TextStyle(fontSize: 13, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // More resources grouped below: Wards, ICU, Emergency, Diagnostics, Pharmacy, HR, Support
                  ExpansionTile(
                    title: Text(loc.bed_capacity),
                    initiallyExpanded: expandAll,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            _numberField(generalTotalCtrl, '${loc.beds_label} General - Total', Icons.meeting_room),
                            _numberField(generalAvailableCtrl, 'General - ${loc.available}', Icons.event_available),
                            _numberField(semiTotalCtrl, 'Semi-private - Total', Icons.meeting_room),
                            _numberField(semiAvailableCtrl, 'Semi-private - ${loc.available}', Icons.event_available),
                            _numberField(privateTotalCtrl, 'Private - Total', Icons.meeting_room),
                            _numberField(privateAvailableCtrl, 'Private - ${loc.available}', Icons.event_available),
                            _numberField(isolationTotalCtrl, 'Isolation - Total', Icons.shield),
                            _numberField(isolationAvailableCtrl, 'Isolation - ${loc.available}', Icons.event_available),
                          ],
                        ),
                      )
                    ],
                  ),

                  ExpansionTile(
                    title: const Text('ICU Resources'),
                    initiallyExpanded: expandAll,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(children: [
                          Text('MICU', style: const TextStyle(fontWeight: FontWeight.bold)),
                          _numberField(micuTotalCtrl, 'MICU - Total', Icons.bed),
                          _numberField(micuAvailableCtrl, 'MICU - Available', Icons.event_available),
                          _numberField(micuVentCtrl, 'MICU - Ventilators', Icons.air),
                          _numberField(micuMonitorCtrl, 'MICU - Monitors', Icons.monitor),
                          _boolTile('MICU - Oxygen', micuOxygen, (v) => setState(() => micuOxygen = v)),

                          const Divider(),
                          Text('SICU', style: const TextStyle(fontWeight: FontWeight.bold)),
                          _numberField(sicuTotalCtrl, 'SICU - Total', Icons.bed),
                          _numberField(sicuAvailableCtrl, 'SICU - Available', Icons.event_available),
                          _numberField(sicuVentCtrl, 'SICU - Ventilators', Icons.air),
                          _numberField(sicuMonitorCtrl, 'SICU - Monitors', Icons.monitor),
                          _boolTile('SICU - Oxygen', sicuOxygen, (v) => setState(() => sicuOxygen = v)),

                          const Divider(),
                          Text('NICU', style: const TextStyle(fontWeight: FontWeight.bold)),
                          _numberField(nicuTotalCtrl, 'NICU - Total', Icons.bed),
                          _numberField(nicuAvailableCtrl, 'NICU - Available', Icons.event_available),
                          _numberField(nicuVentCtrl, 'NICU - Ventilators', Icons.air),
                          _numberField(nicuMonitorCtrl, 'NICU - Monitors', Icons.monitor),
                          _boolTile('NICU - Oxygen', nicuOxygen, (v) => setState(() => nicuOxygen = v)),

                          const Divider(),
                          Text('CCU', style: const TextStyle(fontWeight: FontWeight.bold)),
                          _numberField(ccuTotalCtrl, 'CCU - Total', Icons.bed),
                          _numberField(ccuAvailableCtrl, 'CCU - Available', Icons.event_available),
                          _numberField(ccuVentCtrl, 'CCU - Ventilators', Icons.air),
                          _numberField(ccuMonitorCtrl, 'CCU - Monitors', Icons.monitor),
                          _boolTile('CCU - Oxygen', ccuOxygen, (v) => setState(() => ccuOxygen = v)),

                          const Divider(),
                          Text('PICU', style: const TextStyle(fontWeight: FontWeight.bold)),
                          _numberField(picuTotalCtrl, 'PICU - Total', Icons.bed),
                          _numberField(picuAvailableCtrl, 'PICU - Available', Icons.event_available),
                          _numberField(picuVentCtrl, 'PICU - Ventilators', Icons.air),
                          _numberField(picuMonitorCtrl, 'PICU - Monitors', Icons.monitor),
                          _boolTile('PICU - Oxygen', picuOxygen, (v) => setState(() => picuOxygen = v)),
                        ]),
                      )
                    ],
                  ),

                  ExpansionTile(
                    title: const Text('Emergency & Life-saving'),
                    initiallyExpanded: expandAll,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(children: [
                          _boolTile(loc.emergency_sos, emergency24, (v) => setState(() => emergency24 = v)),
                          _boolTile('Ambulance Available', ambulanceAvailable, (v) => setState(() => ambulanceAvailable = v)),
                          _numberField(ambulanceCountCtrl, loc.ambulance_count, Icons.local_hospital),
                          _boolTile('Defibrillator', defibrillator, (v) => setState(() => defibrillator = v)),
                          _boolTile('Central Oxygen', centralO2, (v) => setState(() => centralO2 = v)),
                        ]),
                      )
                    ],
                  ),

                  ExpansionTile(
                    title: const Text('Diagnostics'),
                    initiallyExpanded: expandAll,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(children: [
                          _boolTile('Lab', lab, (v) => setState(() => lab = v)),
                          _boolTile('X-Ray', xray, (v) => setState(() => xray = v)),
                          _boolTile('ECG', ecg, (v) => setState(() => ecg = v)),
                          _boolTile('Ultrasound', ultrasound, (v) => setState(() => ultrasound = v)),
                          _boolTile('CT Scan', ctScan, (v) => setState(() => ctScan = v)),
                          _boolTile('MRI', mri, (v) => setState(() => mri = v)),
                        ]),
                      )
                    ],
                  ),

                  ExpansionTile(
                    title: const Text('Pharmacy & Supplies'),
                    initiallyExpanded: expandAll,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(children: [
                          _boolTile('In-house Pharmacy', inHousePharmacy, (v) => setState(() => inHousePharmacy = v)),
                          _boolTile('Pharmacy 24x7', pharmacy24, (v) => setState(() => pharmacy24 = v)),
                          _numberField(oxygenCylindersCtrl, 'Oxygen Cylinders', Icons.local_gas_station),
                          _boolTile('Essential Drugs Available', essentialDrugs, (v) => setState(() => essentialDrugs = v)),
                        ]),
                      )
                    ],
                  ),

                  ExpansionTile(
                    title: const Text('Human Resources'),
                    initiallyExpanded: expandAll,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(children: [
                          _numberField(doctorsCountCtrl, 'Doctors Count', Icons.medical_services),
                          _numberField(nursesCountCtrl, 'Nurses Count', Icons.groups),
                          _boolTile('ICU Trained Staff', icuTrainedStaff, (v) => setState(() => icuTrainedStaff = v)),
                          _boolTile('Anesthetist Available', anesthetistAvailable, (v) => setState(() => anesthetistAvailable = v)),
                        ]),
                      )
                    ],
                  ),

                  ExpansionTile(
                    title: const Text('Support Resources'),
                    initiallyExpanded: expandAll,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(children: [
                          _boolTile('Blood Bank', bloodBank, (v) => setState(() => bloodBank = v)),
                          _boolTile('Dialysis Unit', dialysisUnit, (v) => setState(() => dialysisUnit = v)),
                          _boolTile('CSSD', cssd, (v) => setState(() => cssd = v)),
                          _boolTile('Mortuary', mortuary, (v) => setState(() => mortuary = v)),
                        ]),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSaving ? null : saveProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      loc.save_changes,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    bedsCtrl.dispose();
    icuBedsCtrl.dispose();
    availableBedsCtrl.dispose();
    generalTotalCtrl.dispose();
    generalAvailableCtrl.dispose();
    semiTotalCtrl.dispose();
    semiAvailableCtrl.dispose();
    privateTotalCtrl.dispose();
    privateAvailableCtrl.dispose();
    isolationTotalCtrl.dispose();
    isolationAvailableCtrl.dispose();

    micuTotalCtrl.dispose();
    micuAvailableCtrl.dispose();
    micuVentCtrl.dispose();
    micuMonitorCtrl.dispose();
    sicuTotalCtrl.dispose();
    sicuAvailableCtrl.dispose();
    sicuVentCtrl.dispose();
    sicuMonitorCtrl.dispose();
    nicuTotalCtrl.dispose();
    nicuAvailableCtrl.dispose();
    nicuVentCtrl.dispose();
    nicuMonitorCtrl.dispose();
    ccuTotalCtrl.dispose();
    ccuAvailableCtrl.dispose();
    ccuVentCtrl.dispose();
    ccuMonitorCtrl.dispose();
    picuTotalCtrl.dispose();
    picuAvailableCtrl.dispose();
    picuVentCtrl.dispose();
    picuMonitorCtrl.dispose();

    ambulanceCountCtrl.dispose();
    oxygenCylindersCtrl.dispose();

    doctorsCountCtrl.dispose();
    nursesCountCtrl.dispose();
    super.dispose();
  }
}
