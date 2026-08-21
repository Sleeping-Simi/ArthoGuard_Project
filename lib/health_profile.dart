import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dashboard.dart';
import 'theme_flow.dart';

class HealthProfilePage extends StatefulWidget {
  final Map<String, dynamic> basicData;

  const HealthProfilePage({
    super.key,
    required this.basicData,
  });

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  final TextEditingController _ageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // ------------------------------------------------------------
  // BIOMETRIC VALUES
  // ------------------------------------------------------------

  double _heightVal = 170.0;
  String _heightUnit = "cm";

  double _weightVal = 65.0;
  String _weightUnit = "kg";

  String? _gender;

  // ------------------------------------------------------------
  // CLINICAL VALUES
  // ------------------------------------------------------------

  double _painLevel = 5.0;

  String? _painDuration;
  String? _painTiming;
  String? _arthritisType;

  // ------------------------------------------------------------
  // BMI
  // ------------------------------------------------------------

  double _bmi = 0.0;
  String _bmiCategory = "";
  Color _bmiColor = const Color(0xFF64748B);

  // ------------------------------------------------------------
  // OPTIONAL FILES
  // ------------------------------------------------------------

  String _prescriptionFile = "No file chosen";
  String _xrayFile = "No file chosen";

  bool _isSavingToDashboard = false;

  // ------------------------------------------------------------
  // OPTIONS
  // ------------------------------------------------------------

  final List<String> _durations = [
    '0–3 months',
    '3–6 months',
    '6 months–1 year',
    '1–5 years',
    'More than 5 years',
  ];

  final List<String> _timings = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night',
    'During activities',
    'During exercise',
    'During walking',
    'All the time',
    'Other',
  ];

  // IMPORTANT:
  // "Not Diagnosed" is intentionally retained.
  // Gout is intentionally excluded.
  final List<String> _arthritisOptions = [
    'Osteoarthritis',
    'Rheumatoid',
    'Not Diagnosed',
  ];

  // ------------------------------------------------------------
  // INITIALIZATION
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    final String loggedInName =
        widget.basicData['name']?.toString().trim() ?? '';

    _nameController = TextEditingController(
      text: loggedInName,
    );

    _recalculateBMI();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // BMI CALCULATION
  // ------------------------------------------------------------

  void _recalculateBMI() {
    double heightMeters;

    if (_heightUnit == "cm") {
      heightMeters = _heightVal / 100.0;
    } else {
      // For the current picker representation,
      // this treats the selected value as inches.
      heightMeters = _heightVal * 0.0254;
    }

    final double weightKg = _weightUnit == "kg"
        ? _weightVal
        : _weightVal * 0.45359237;

    if (heightMeters <= 0 || weightKg <= 0) {
      return;
    }

    final double calculatedBMI =
        weightKg / (heightMeters * heightMeters);

    String category;
    Color color;

    if (calculatedBMI < 18.5) {
      category = "Underweight";
      color = Colors.orange;
    } else if (calculatedBMI < 25.0) {
      category = "Normal (Healthy)";
      color = Colors.green;
    } else if (calculatedBMI < 30.0) {
      category = "Overweight";
      color = Colors.orange;
    } else {
      category = "Obese Range";
      color = Colors.red;
    }

    if (!mounted) {
      _bmi = calculatedBMI;
      _bmiCategory = category;
      _bmiColor = color;
      return;
    }

    setState(() {
      _bmi = calculatedBMI;
      _bmiCategory = category;
      _bmiColor = color;
    });
  }

  // ------------------------------------------------------------
  // WHEEL PICKER
  // ------------------------------------------------------------

  void _openWheelPickerModal({
    required String title,
    required double initialVal,
    required String currentUnit,
    required List<String> availableUnits,
    required int minInt,
    required int maxInt,
    required Function(double value, String unit) onSelected,
  }) {
    int selectedInt = initialVal.toInt();

    int selectedDec =
        ((initialVal - selectedInt) * 10).round().clamp(0, 9);

    String activeUnit = currentUnit;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                height: 380,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          // INTEGER PICKER
                          SizedBox(
                            width: 80,
                            child: CupertinoPicker(
                              scrollController:
                                  FixedExtentScrollController(
                                initialItem:
                                    (selectedInt - minInt)
                                        .clamp(
                                  0,
                                  maxInt - minInt,
                                ),
                              ),
                              itemExtent: 50,
                              selectionOverlay:
                                  Container(
                                decoration:
                                    const BoxDecoration(
                                  border: Border.symmetric(
                                    horizontal:
                                        BorderSide(
                                      color:
                                          Color(0xFF2E6FF3),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              onSelectedItemChanged:
                                  (index) {
                                setModalState(() {
                                  selectedInt =
                                      minInt + index;
                                });
                              },
                              children: List.generate(
                                maxInt - minInt + 1,
                                (index) {
                                  return Center(
                                    child: Text(
                                      "${minInt + index}",
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(0xFF1E293B),
                                        fontSize: 28,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const Text(
                            ".",
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // DECIMAL PICKER
                          SizedBox(
                            width: 60,
                            child: CupertinoPicker(
                              scrollController:
                                  FixedExtentScrollController(
                                initialItem: selectedDec,
                              ),
                              itemExtent: 50,
                              selectionOverlay:
                                  Container(
                                decoration:
                                    const BoxDecoration(
                                  border: Border.symmetric(
                                    horizontal:
                                        BorderSide(
                                      color:
                                          Color(0xFF2E6FF3),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              onSelectedItemChanged:
                                  (index) {
                                setModalState(() {
                                  selectedDec = index;
                                });
                              },
                              children: List.generate(
                                10,
                                (index) {
                                  return Center(
                                    child: Text(
                                      "$index",
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(0xFF1E293B),
                                        fontSize: 28,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          // UNIT SELECTOR
                          Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children:
                                availableUnits.map((unit) {
                              final bool isSelected =
                                  activeUnit == unit;

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    activeUnit = unit;
                                  });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: isSelected
                                        ? const Color(
                                            0xFF2E6FF3,
                                          )
                                        : const Color(
                                            0xFFF4F8FF,
                                          ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child: Text(
                                    unit,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(
                                              0xFF64748B,
                                            ),
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        final double finalValue =
                            selectedInt +
                                (selectedDec / 10.0);

                        onSelected(
                          finalValue,
                          activeUnit,
                        );

                        Navigator.pop(ctx);

                        // Recalculate after modal closes.
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) {
                          if (mounted) {
                            _recalculateBMI();
                          }
                        });
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2E6FF3),
                        minimumSize:
                            const Size.fromHeight(52),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "SET VALUE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // IMAGE PICKER
  // OPTIONAL ONLY
  // ------------------------------------------------------------

  Future<void> _pickImageFile(
    bool isPrescription,
  ) async {
    try {
      final XFile? image =
          await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        if (isPrescription) {
          _prescriptionFile = image.name;
        } else {
          _xrayFile = image.name;
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to select image: $e',
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // SUBMIT PROFILE
  // ------------------------------------------------------------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int? age =
        int.tryParse(_ageController.text.trim());

    if (age == null || age < 1 || age > 120) {
      return;
    }

    if (_gender == null ||
        _painDuration == null ||
        _painTiming == null ||
        _arthritisType == null) {
      return;
    }

    setState(() {
      _isSavingToDashboard = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    final Map<String, dynamic> finalUserData = {
      // Preserve login data.
      ...widget.basicData,

      // Patient identity.
      'name': _nameController.text.trim(),
      'patientName': _nameController.text.trim(),

      // Biometrics.
      'age': age,
      'gender': _gender,
      'height': "$_heightVal $_heightUnit",
      'weight': "$_weightVal $_weightUnit",

      // BMI.
      'bmi': _bmi.toStringAsFixed(1),
      'bmiCategory': _bmiCategory,

      // Pain information.
      'painLevel': _painLevel.toInt(),
      'painDuration': _painDuration,
      'painTiming': _painTiming,

      // Diagnosis.
      // "Not Diagnosed" is a valid value.
      'arthritis': _arthritisType,

      // Optional records.
      'prescriptionFile': _prescriptionFile,
      'xrayFile': _xrayFile,
    };

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(
          userData: finalUserData,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FIELD DECORATION
  // ------------------------------------------------------------

  InputDecoration _buildLightFieldDeco(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF2E6FF3),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF2E6FF3),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // WHEEL TRIGGER CARD
  // ------------------------------------------------------------

  Widget _buildWheelTriggerCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF2E6FF3),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          'Patient Biometric Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: AnimatedBlueFlow(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // BIOMETRICS
                // ==================================================

                const Row(
                  children: [
                    Icon(
                      Icons.monitor_heart,
                      color: Color(0xFF2E6FF3),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Biometrics & Vitals",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // NAME
                TextFormField(
                  controller: _nameController,
                  readOnly: true,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                  ),
                  decoration: _buildLightFieldDeco(
                    'Patient Full Name',
                    Icons.person,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Patient name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // AGE + GENDER
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType:
                            TextInputType.number,
                        inputFormatters: const [],
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                        ),
                        decoration:
                            _buildLightFieldDeco(
                          'Age',
                          Icons.cake,
                        ),
                        validator: (value) {
                          final text =
                              value?.trim() ?? '';

                          if (text.isEmpty) {
                            return 'Required';
                          }

                          final int? age =
                              int.tryParse(text);

                          if (age == null) {
                            return 'Invalid age';
                          }

                          if (age < 1 ||
                              age > 120) {
                            return '1–120 only';
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      flex: 2,
                      child:
                          DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                        ),
                        decoration:
                            _buildLightFieldDeco(
                          'Gender',
                          Icons.wc,
                        ),
                        items: [
                          'Male',
                          'Female',
                          'Other',
                        ]
                            .map(
                              (gender) =>
                                  DropdownMenuItem(
                                value: gender,
                                child:
                                    Text(gender),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Required';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // HEIGHT
                _buildWheelTriggerCard(
                  title: "Height",
                  value:
                      "$_heightVal $_heightUnit",
                  icon: Icons.height,
                  onTap: () =>
                      _openWheelPickerModal(
                    title: "Set height",
                    initialVal: _heightVal,
                    currentUnit: _heightUnit,
                    availableUnits: [
                      "cm",
                      "ft, in",
                    ],
                    minInt: 80,
                    maxInt: 230,
                    onSelected:
                        (value, unit) {
                      setState(() {
                        _heightVal = value;
                        _heightUnit = unit;
                      });
                      _recalculateBMI();
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // WEIGHT
                _buildWheelTriggerCard(
                  title: "Weight",
                  value:
                      "$_weightVal $_weightUnit",
                  icon: Icons.scale,
                  onTap: () =>
                      _openWheelPickerModal(
                    title: "Set weight",
                    initialVal: _weightVal,
                    currentUnit: _weightUnit,
                    availableUnits: [
                      "kg",
                      "lb",
                    ],
                    minInt: 30,
                    maxInt: 200,
                    onSelected:
                        (value, unit) {
                      setState(() {
                        _weightVal = value;
                        _weightUnit = unit;
                      });
                      _recalculateBMI();
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // BMI
                Container(
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.7),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: _bmiColor
                          .withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Computed Body Mass Index",
                            style: TextStyle(
                              color:
                                  Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _bmiCategory
                                .toUpperCase(),
                            style: TextStyle(
                              color: _bmiColor,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _bmi > 0
                            ? _bmi
                                .toStringAsFixed(1)
                            : "--",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight:
                              FontWeight.bold,
                          color: _bmiColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // PAIN
                // ==================================================

                const Row(
                  children: [
                    Icon(
                      Icons.accessibility_new,
                      color: Color(0xFF2E6FF3),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Clinical Pain Status",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // PAIN LEVEL
                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.6),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Pain Intensity: "
                        "${_painLevel.toInt()} / 10",
                        style: const TextStyle(
                          color:
                              Color(0xFF1E293B),
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Slider(
                        value: _painLevel,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        activeColor:
                            Colors.redAccent,
                        inactiveColor:
                            Color(0xFFD1E3FF),
                        onChanged: (value) {
                          setState(() {
                            _painLevel = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // PAIN DURATION
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                  ),
                  decoration:
                      _buildLightFieldDeco(
                    'Pain History Duration',
                    Icons.timeline,
                  ),
                  items: _durations
                      .map(
                        (duration) =>
                            DropdownMenuItem(
                          value: duration,
                          child: Text(duration),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _painDuration = value;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please select duration';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // PEAK PAIN TIMING
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                  ),
                  decoration:
                      _buildLightFieldDeco(
                    'Peak Discomfort Timing',
                    Icons.schedule,
                  ),
                  items: _timings
                      .map(
                        (timing) =>
                            DropdownMenuItem(
                          value: timing,
                          child: Text(timing),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _painTiming = value;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please select timing';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // ==================================================
                // DIAGNOSTIC RECORDS
                // ==================================================

                const Row(
                  children: [
                    Icon(
                      Icons.folder_shared,
                      color: Color(0xFF2E6FF3),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Diagnostic Records",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ARTHRITIS CLASSIFICATION
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                  ),
                  decoration:
                      _buildLightFieldDeco(
                    'Arthritis Classification',
                    Icons.medical_information,
                  ),
                  items: _arthritisOptions
                      .map(
                        (arthritis) =>
                            DropdownMenuItem(
                          value: arthritis,
                          child: Text(arthritis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _arthritisType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please select classification';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // OPTIONAL PRESCRIPTION
                OutlinedButton.icon(
                  onPressed: () =>
                      _pickImageFile(true),
                  icon: const Icon(
                    Icons.file_present,
                    color: Color(0xFF2E6FF3),
                  ),
                  label: Text(
                    "Prescription: "
                    "$_prescriptionFile",
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    backgroundColor:
                        Colors.white
                            .withOpacity(0.6),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    side: BorderSide.none,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // OPTIONAL X-RAY
                OutlinedButton.icon(
                  onPressed: () =>
                      _pickImageFile(false),
                  icon: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF2E6FF3),
                  ),
                  label: Text(
                    "X-Ray Scan: $_xrayFile",
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    backgroundColor:
                        Colors.white
                            .withOpacity(0.6),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    side: BorderSide.none,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ==================================================
                // SUBMIT
                // ==================================================

                _isSavingToDashboard
                    ? Container(
                        padding:
                            const EdgeInsets.all(
                          18,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.8),
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Calibrating Dashboard Metrics...",
                              style: TextStyle(
                                color:
                                    Color(0xFF2E6FF3),
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(
                                Radius.circular(8),
                              ),
                              child:
                                  LinearProgressIndicator(
                                color:
                                    Color(0xFF2E6FF3),
                                backgroundColor:
                                    Color(0xFFD1E3FF),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submit,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF2E6FF3,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 18,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Save & Synchronize Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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