import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dashboard.dart';
import 'theme_flow.dart';

class HealthProfilePage extends StatefulWidget {
  final Map basicData; 
  const HealthProfilePage({super.key, required this.basicData});

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  final _ageController = TextEditingController();
  final _painMinsController = TextEditingController();
  
  // Interactive Wheel Picker States
  double _heightVal = 170.0;
  String _heightUnit = "cm";

  double _weightVal = 65.0;
  String _weightUnit = "kg";

  String? _gender;
  double _painLevel = 5.0; 
  String? _painDuration;
  String? _painTiming;
  String? _arthritisType;
  double _bmi = 0.0;
  String _bmiCategory = "";
  Color _bmiColor = const Color(0xFF64748B);
  
  String _prescriptionFile = "No file chosen";
  String _xrayFile = "No file chosen";
  bool _isSavingToDashboard = false;

  final List<String> _durations = ['0-1 year', '1-2 years', '2-3 years', '3-4 years', '4-5 years', '5+ years'];
  final List<String> _timings = ['Morning', 'Afternoon', 'Evening', 'Night'];
  final List<String> _arthritisOptions = ['Osteoarthritis', 'Rheumatoid', 'Gout', 'Not Diagnosed'];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.basicData['name']);
    _recalculateBMI();
  }

  void _recalculateBMI() {
    double hMeters = _heightUnit == "cm" ? (_heightVal / 100.0) : (_heightVal * 0.0254);
    double wKg = _weightUnit == "kg" ? _weightVal : (_weightVal * 0.453592);

    if (hMeters > 0) {
      double calc = wKg / (hMeters * hMeters);
      String cat = "";
      Color col = Colors.grey;
      if (calc < 18.5) { cat = "Underweight"; col = Colors.orange; }
      else if (calc < 25.0) { cat = "Normal (Healthy)"; col = Colors.green; }
      else if (calc < 30.0) { cat = "Overweight"; col = Colors.orange; }
      else { cat = "Obese Range"; col = Colors.red; }

      setState(() {
        _bmi = calc;
        _bmiCategory = cat;
        _bmiColor = col;
      });
    }
  }

  // --- INTERACTIVE WHEEL PICKER MODAL (LIGHT THEME) ---
  void _openWheelPickerModal({
    required String title,
    required double initialVal,
    required String currentUnit,
    required List<String> availableUnits,
    required int minInt,
    required int maxInt,
    required Function(double newVal, String newUnit) onSelected,
  }) {
    int selectedInt = initialVal.toInt();
    int selectedDec = ((initialVal - selectedInt) * 10).round() % 10;
    String activeUnit = currentUnit;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              height: 380,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // Scroll Pickers
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Integer Wheel
                        SizedBox(
                          width: 80,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: selectedInt - minInt),
                            itemExtent: 50,
                            selectionOverlay: Container(decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Color(0xFF2E6FF3), width: 1.5)))),
                            onSelectedItemChanged: (index) => setModalState(() => selectedInt = minInt + index),
                            children: List.generate(maxInt - minInt + 1, (i) => Center(child: Text("${minInt + i}", style: const TextStyle(color: Color(0xFF1E293B), fontSize: 28, fontWeight: FontWeight.bold)))),
                          ),
                        ),
                        const Text(".", style: TextStyle(color: Color(0xFF1E293B), fontSize: 32, fontWeight: FontWeight.bold)),
                        // Decimal Wheel
                        SizedBox(
                          width: 60,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: selectedDec),
                            itemExtent: 50,
                            selectionOverlay: Container(decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Color(0xFF2E6FF3), width: 1.5)))),
                            onSelectedItemChanged: (index) => setModalState(() => selectedDec = index),
                            children: List.generate(10, (i) => Center(child: Text("$i", style: const TextStyle(color: Color(0xFF1E293B), fontSize: 28, fontWeight: FontWeight.bold)))),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Unit Switcher
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: availableUnits.map((u) {
                            final isSel = activeUnit == u;
                            return GestureDetector(
                              onTap: () => setModalState(() => activeUnit = u),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF2E6FF3) : const Color(0xFFF4F8FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(u, style: TextStyle(color: isSel ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),

                  // Confirm Button
                  ElevatedButton(
                    onPressed: () {
                      double finalNum = selectedInt + (selectedDec / 10.0);
                      onSelected(finalNum, activeUnit);
                      _recalculateBMI();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6FF3),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("SET VALUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImageFile(bool isPrescription) async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        if (isPrescription) _prescriptionFile = img.name;
        else _xrayFile = img.name;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSavingToDashboard = true);
      await Future.delayed(const Duration(seconds: 2));

      Map<String, dynamic> finalUserData = {
        ...widget.basicData,
        'patientName': _nameController.text,
        'age': _ageController.text,
        'gender': _gender ?? 'Not Specified',
        'height': "$_heightVal $_heightUnit",
        'weight': "$_weightVal $_weightUnit",
        'bmi': _bmi.toStringAsFixed(1),
        'bmiCategory': _bmiCategory,
        'painLevel': _painLevel.toInt().toString(),
        'painDuration': _painDuration ?? 'Unknown',
        'painTiming': _painTiming ?? 'Unknown',
        'painMins': _painMinsController.text,
        'arthritis': _arthritisType ?? 'Not Diagnosed',
      };

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage(userData: finalUserData)));
      }
    }
  }

  InputDecoration _buildLightFieldDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B)),
      prefixIcon: Icon(icon, color: const Color(0xFF2E6FF3)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  Widget _buildWheelTriggerCard({required String title, required String value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2E6FF3)),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            Row(
              children: [
                Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 17, fontWeight: FontWeight.bold)),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Patient Biometric Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedBlueFlow(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Row(children: [Icon(Icons.monitor_heart, color: Color(0xFF2E6FF3)), SizedBox(width: 8), Text("Biometrics & Vitals", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
                const SizedBox(height: 20),

                TextFormField(controller: _nameController, style: const TextStyle(color: Color(0xFF1E293B)), decoration: _buildLightFieldDeco('Patient Full Name', Icons.person), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _ageController, keyboardType: TextInputType.number, style: const TextStyle(color: Color(0xFF1E293B)), decoration: _buildLightFieldDeco('Age', Icons.cake), validator: (v) => v!.isEmpty ? 'Req' : null)),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: DropdownButtonFormField<String>(dropdownColor: Colors.white, style: const TextStyle(color: Color(0xFF1E293B)), decoration: _buildLightFieldDeco('Gender', Icons.wc), items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) => setState(() => _gender = v), validator: (v) => v == null ? 'Req' : null)),
                  ],
                ),
                const SizedBox(height: 16),

                // Height & Weight Wheel Triggers
                _buildWheelTriggerCard(
                  title: "Height",
                  value: "$_heightVal $_heightUnit",
                  icon: Icons.height,
                  onTap: () => _openWheelPickerModal(
                    title: "Set height",
                    initialVal: _heightVal,
                    currentUnit: _heightUnit,
                    availableUnits: ["cm", "ft, in"],
                    minInt: 80,
                    maxInt: 230,
                    onSelected: (nVal, nUnit) => setState(() { _heightVal = nVal; _heightUnit = nUnit; }),
                  ),
                ),
                const SizedBox(height: 14),

                _buildWheelTriggerCard(
                  title: "Weight",
                  value: "$_weightVal $_weightUnit",
                  icon: Icons.scale,
                  onTap: () => _openWheelPickerModal(
                    title: "Set weight",
                    initialVal: _weightVal,
                    currentUnit: _weightUnit,
                    availableUnits: ["kg", "lb"],
                    minInt: 30,
                    maxInt: 200,
                    onSelected: (nVal, nUnit) => setState(() { _weightVal = nVal; _weightUnit = nUnit; }),
                  ),
                ),
                const SizedBox(height: 20),

                // Dynamic BMI Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _bmiColor.withOpacity(0.6), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Computed Body Mass Index", style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_bmiCategory.toUpperCase(), style: TextStyle(color: _bmiColor, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      Text(_bmi > 0 ? _bmi.toStringAsFixed(1) : "--", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _bmiColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Pain Section
                const Row(children: [Icon(Icons.accessibility_new, color: Color(0xFF2E6FF3)), SizedBox(width: 8), Text("Clinical Pain Status", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    children: [
                      Text("Pain Intensity: ${_painLevel.toInt()} / 10", style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
                      Slider(value: _painLevel, min: 0, max: 10, divisions: 10, activeColor: Colors.redAccent, inactiveColor: const Color(0xFFD1E3FF), onChanged: (v) => setState(() => _painLevel = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(dropdownColor: Colors.white, style: const TextStyle(color: Color(0xFF1E293B)), decoration: _buildLightFieldDeco('Pain History Duration', Icons.timeline), items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(), onChanged: (v) => setState(() => _painDuration = v)),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(dropdownColor: Colors.white, style: const TextStyle(color: Color(0xFF1E293B)), decoration: _buildLightFieldDeco('Peak Discomfort Timing', Icons.schedule), items: _timings.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _painTiming = v)),
                const SizedBox(height: 28),

                // Diagnosis & Documents
                const Row(children: [Icon(Icons.folder_shared, color: Color(0xFF2E6FF3)), SizedBox(width: 8), Text("Diagnostic Records", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(dropdownColor: Colors.white, style: const TextStyle(color: Color(0xFF1E293B)), decoration: _buildLightFieldDeco('Arthritis Classification', Icons.medical_information), items: _arthritisOptions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(), onChanged: (v) => setState(() => _arthritisType = v)),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () => _pickImageFile(true),
                  icon: const Icon(Icons.file_present, color: Color(0xFF2E6FF3)),
                  label: Text("Prescription: $_prescriptionFile", style: const TextStyle(color: Color(0xFF1E293B))),
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.6), padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickImageFile(false),
                  icon: const Icon(Icons.photo_library, color: Color(0xFF2E6FF3)),
                  label: Text("X-Ray Scan: $_xrayFile", style: const TextStyle(color: Color(0xFF1E293B))),
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.6), padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
                const SizedBox(height: 36),

                // Save & Transition
                _isSavingToDashboard
                    ? Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(16)),
                        child: const Column(
                          children: [
                            Text("Calibrating Dashboard Metrics...", style: TextStyle(color: Color(0xFF2E6FF3), fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            ClipRRect(borderRadius: BorderRadius.all(Radius.circular(8)), child: LinearProgressIndicator(color: Color(0xFF2E6FF3), backgroundColor: Color(0xFFD1E3FF), minHeight: 6)),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E6FF3), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4),
                        child: const Text('Save & Synchronize Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}