import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_scan_screen.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'history_screen.dart';
import 'theme_flow.dart';
import 'rom_guide.dart';

class DashboardPage extends StatefulWidget {
  final Map userData;

  const DashboardPage({
    super.key,
    required this.userData,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  String _mobileNumber = "Not Set";
  XFile? _profileImage;

  final ImagePicker _picker = ImagePicker();

  bool _mode1Active = false;
  bool _mode2Active = false;
  bool _mode3Active = false;
  bool _airCompressionActive = false;

  // Stores history of started therapies as detailed Maps
  final List<Map<String, dynamic>> _therapyHistory = [];
  DateTime? _modeStartTime;

  final BoxShadow _softShadow = BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 15,
    spreadRadius: 0,
    offset: const Offset(0, 5),
  );

  // ============================================================
  // AI SCAN
  // ============================================================

  // Make sure to add this import at the top of dashboard.dart!
 

  void _openAiScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Pass the user data into the guide, which passes it to the scanner, which passes it to the report!
        builder: (context) => RomGuideScreen(userData: widget.userData), 
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      _openAiScan();
      setState(() => _selectedIndex = 0);
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HistoryScreen(historyLogs: _therapyHistory),
        ),
      );
      setState(() => _selectedIndex = 0);
    } else if (index == 3) {
      _showProfileDetails();
      setState(() => _selectedIndex = 0);
    }
  }

  // ============================================================
  // THERAPY MODE LOGIC (WITH PRECISE TIMERS)
  // ============================================================

  void _toggleVibrationMode(int mode, bool isOn) {
    setState(() {
      if (isOn) {
        if (_modeStartTime != null) {
          _logTherapySession();
        }
        _mode1Active = mode == 1;
        _mode2Active = mode == 2;
        _mode3Active = mode == 3;
        _modeStartTime = DateTime.now();
      } else {
        if (_modeStartTime != null) {
          _logTherapySession();
        }
        if (mode == 1) _mode1Active = false;
        if (mode == 2) _mode2Active = false;
        if (mode == 3) _mode3Active = false;
        _modeStartTime = null;
      }
    });
  }

  void _logTherapySession() {
    final duration = DateTime.now().difference(_modeStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    String timeStr = DateFormat('dd MMM yyyy, HH:mm:ss').format(_modeStartTime!);
    String durationStr = "${minutes}m ${seconds}s";
    
    int activeMode = _mode1Active ? 1 : _mode2Active ? 2 : 3;
    String mName = activeMode == 1 ? "Mode 1: Gentle Recovery" : 
                   activeMode == 2 ? "Mode 2: Moderate Stimulation" : "Mode 3: Deep Tissue Rehab";
    
    _therapyHistory.add({'timestamp': timeStr, 'duration': durationStr, 'modeName': mName});
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  void _pickProfileImage(StateSetter setDialogState) async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        setState(() => _profileImage = image);
        setDialogState(() {});
      }
    } catch (e) {
      print("Gallery Error: $e");
    }
  }

  // ============================================================
  // PROFILE DETAILS
  // ============================================================

  void _showProfileDetails() {
    final Map wData = widget.userData;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Center(
                child: Text(
                  'Complete Patient Profile',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: const Color(0xFFE8F0FE),
                          backgroundImage: _profileImage != null
                              ? FileImage(
                                  File(_profileImage!.path),
                                )
                              : null,
                          child: _profileImage == null
                              ? Text(
                                  wData['patientName'] != null &&
                                          wData['patientName']
                                              .toString()
                                              .isNotEmpty
                                      ? wData['patientName'][0]
                                          .toUpperCase()
                                      : "P",
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E6FF3),
                                  ),
                                )
                              : null,
                        ),
                        GestureDetector(
                          onTap: () =>
                              _pickProfileImage(setDialogState),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E6FF3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Identity & Contact",
                      style: TextStyle(
                        color: Color(0xFF2E6FF3),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),

                    _buildProfileRow(
                      'Name',
                      wData['patientName'] ?? 'N/A',
                    ),

                    _buildProfileRow(
                      'Email',
                      wData['email'] ?? 'N/A',
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mobile',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _mobileNumber,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                TextEditingController ctrl =
                                    TextEditingController(
                                  text: _mobileNumber == "Not Set"
                                      ? ""
                                      : _mobileNumber,
                                );

                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text(
                                      'Update Mobile',
                                    ),
                                    content: TextField(
                                      controller: ctrl,
                                      keyboardType:
                                          TextInputType.phone,
                                      decoration:
                                          const InputDecoration(
                                        filled: true,
                                        fillColor:
                                            Color(0xFFF4F7FB),
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(
                                            () => _mobileNumber =
                                                ctrl.text.isEmpty
                                                    ? "Not Set"
                                                    : ctrl.text,
                                          );

                                          setDialogState(() {});

                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('SAVE'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Color(0xFF2E6FF3),
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(
                      color: Color(0xFFF4F7FB),
                      height: 30,
                      thickness: 2,
                    ),

                    const Text(
                      "Physiological Data",
                      style: TextStyle(
                        color: Color(0xFF2E6FF3),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),

                    _buildProfileRow(
                      'Age',
                      "${wData['age']} yrs",
                    ),

                    _buildProfileRow(
                      'Gender',
                      wData['gender'] ?? 'N/A',
                    ),

                    _buildProfileRow(
                      'Height',
                      "${wData['height']} cm",
                    ),

                    _buildProfileRow(
                      'Weight',
                      "${wData['weight']} kg",
                    ),

                    _buildProfileRow(
                      'BMI',
                      "${wData['bmi']} (${wData['bmiCategory']})",
                    ),

                    const Divider(
                      color: Color(0xFFF4F7FB),
                      height: 30,
                      thickness: 2,
                    ),

                    const Text(
                      "Clinical Assessment",
                      style: TextStyle(
                        color: Color(0xFF2E6FF3),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),

                    _buildProfileRow(
                      'Pain Level',
                      "${wData['painLevel']}/10",
                    ),

                    _buildProfileRow(
                      'Diagnosis',
                      wData['arthritis'] ?? 'N/A',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSESSMENT TEST
  // ============================================================

  void _showAssessmentTest() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Knee Assessment Test",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.favorite_outline,
                  color: Colors.red,
                ),
                title: Text("Pain Assessment"),
                subtitle: Text(
                  "Evaluate current pain level",
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.straighten,
                  color: Colors.teal,
                ),
                title: Text("Range of Motion"),
                subtitle: Text(
                  "Evaluate knee movement",
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.directions_walk,
                  color: Colors.blue,
                ),
                title: Text("Mobility Test"),
                subtitle: Text(
                  "Evaluate walking and movement",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Assessment test started",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6FF3),
              ),
              child: const Text(
                "START",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ASSESSMENT ITEM
  // ============================================================

  Widget _buildAssessmentItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2E6FF3),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final String userName =
        widget.userData['patientName'] ?? 'Patient';

    final String dynamicPainLevel =
        widget.userData['painLevel'] ?? '0';

    final screenWidth =
        MediaQuery.of(context).size.width;

    final bool isDesktop = screenWidth > 800;

    final int gridColumns = isDesktop ? 4 : 2;

    return Scaffold(
      backgroundColor: Colors.white,

      // Wraps the body to provide the animated blue gradient flow
      body: AnimatedBlueFlow(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // ==================================================
                    // HEADER
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF2E6FF3),
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.shield,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome,",
                                  style: TextStyle(
                                    color:
                                        Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color:
                                        Color(0xFF1E293B),
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        GestureDetector(
                          onTap: _showProfileDetails,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                _profileImage != null
                                    ? FileImage(
                                        File(
                                          _profileImage!.path,
                                        ),
                                      )
                                    : null,
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.person,
                                    color:
                                        Color(0xFF2E6FF3),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // AI KNEE SCAN HERO
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E6FF3),
                        borderRadius:
                            BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E6FF3)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            offset:
                                const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Clinical ROM Scan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Capture your knee extension and flexion.\n"
                            "Our AI will automatically compute your\n"
                            "Range of Motion arc.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton.icon(
                            onPressed: _openAiScan,
                            icon: const Icon(
                              Icons.camera,
                              color:
                                  Color(0xFF2E6FF3),
                              size: 18,
                            ),
                            label: const Text(
                              "Scan Now",
                              style: TextStyle(
                                color:
                                    Color(0xFF2E6FF3),
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // LIVE SENSOR STATUS
                    // ==================================================

                    const Text(
                      "Live Sensor Status",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: gridColumns,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          isDesktop ? 1.5 : 1.1,
                      children: [
                        _buildGridCard(
                          icon: Icons.square_foot,
                          iconColor: Colors.teal,
                          bgColor: Colors.teal.shade50,
                          title: "ROM Angle",
                          value: "124°",
                          valueColor: Colors.teal,
                        ),

                        _buildGridCard(
                          icon: Icons.favorite,
                          iconColor: Colors.red,
                          bgColor: Colors.red.shade50,
                          title: "Pain",
                          value:
                              "$dynamicPainLevel / 10",
                          valueColor: Colors.red,
                        ),

                        _buildGridCard(
                          icon: Icons.air,
                          iconColor: Colors.blue,
                          bgColor: Colors.blue.shade50,
                          title: "Pressure",
                          value: "Normal",
                          valueColor: Colors.blue,
                        ),

                        _buildGridCard(
                          icon: Icons.vibration,
                          iconColor: Colors.purple,
                          bgColor:
                              Colors.purple.shade50,
                          title: "Vibration",
                          value: _mode1Active ||
                                  _mode2Active ||
                                  _mode3Active
                              ? "Active"
                              : "Off",
                          valueColor: Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // SMART THERAPY MODES
                    // ==================================================

                    const Text(
                      "Smart Therapy Modes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildTherapyModeCard(
                      modeNumber: 1,
                      title: "Gentle Recovery",
                      intensity: "Low",
                      curingTarget:
                          "Superficial Ligaments",
                      mechanism:
                          "Low-frequency vibration.",
                      isActive: _mode1Active,
                      onToggle: (val) =>
                          _toggleVibrationMode(
                        1,
                        val,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildTherapyModeCard(
                      modeNumber: 2,
                      title: "Moderate Stimulation",
                      intensity: "Medium",
                      curingTarget:
                          "Meniscus & Cartilage",
                      mechanism:
                          "Mid-level frequency.",
                      isActive: _mode2Active,
                      onToggle: (val) =>
                          _toggleVibrationMode(
                        2,
                        val,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildTherapyModeCard(
                      modeNumber: 3,
                      title: "Deep Tissue Rehab",
                      intensity: "High",
                      curingTarget:
                          "Deep Muscle Tissues",
                      mechanism:
                          "High-intensity vibration.",
                      isActive: _mode3Active,
                      onToggle: (val) =>
                          _toggleVibrationMode(
                        3,
                        val,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // ASSESSMENT TEST
                    // ==================================================

                    const Text(
                      "Assessment Test",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        boxShadow: [_softShadow],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange
                                      .withOpacity(0.1),
                                  shape:
                                      BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons
                                      .assignment_outlined,
                                  color: Colors.orange,
                                  size: 26,
                                ),
                              ),

                              const SizedBox(width: 12),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      "Knee Assessment",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: Color(
                                            0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Complete a quick assessment "
                                      "to evaluate your current condition.",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(
                                            0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child:
                                    _buildAssessmentItem(
                                  icon: Icons
                                      .favorite_outline,
                                  title: "Pain Level",
                                  value:
                                      "$dynamicPainLevel / 10",
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child:
                                    _buildAssessmentItem(
                                  icon: Icons.straighten,
                                  title: "ROM",
                                  value: "124°",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child:
                                    _buildAssessmentItem(
                                  icon: Icons
                                      .directions_walk,
                                  title: "Mobility",
                                  value: "Normal",
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child:
                                    _buildAssessmentItem(
                                  icon: Icons
                                      .warning_amber_outlined,
                                  title: "Risk",
                                  value: "Low",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _showAssessmentTest,
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Start Assessment Test",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                    const Color(
                                        0xFF2E6FF3),
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 14,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // QUICK ACCESS
                    // ==================================================

                    const Text(
                      "Quick Access",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: gridColumns,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          isDesktop ? 2.0 : 1.3,
                      children: [
                        _buildSmallGridCard(
                          icon: Icons.square_foot,
                          iconColor: Colors.teal,
                          title: "ROM Analysis",
                          onTap: _openAiScan,
                        ),

                        _buildSmallGridCard(
                          icon: Icons.history,
                          iconColor: Colors.purple,
                          title: "History",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryScreen(historyLogs: _therapyHistory),
                            ),
                          ),
                        ),

                        _buildSmallGridCard(
                          icon: Icons.article,
                          iconColor: Colors.blue,
                          title: "Reports",
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Reports section coming soon",
                                ),
                              ),
                            );
                          },
                        ),

                        _buildSmallGridCard(
                          icon: Icons.psychology,
                          iconColor: Colors.orange,
                          title: "AI Review",
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "AI Review coming soon",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION BAR
      // ============================================================

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor:
              const Color(0xFF2E6FF3),
          unselectedItemColor:
              const Color(0xFF94A3B8),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.camera_alt_outlined,
              ),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // THERAPY MODE CARD
  // ============================================================

  Widget _buildTherapyModeCard({
    required int modeNumber,
    required String title,
    required String intensity,
    required String curingTarget,
    required String mechanism,
    required bool isActive,
    required Function(bool) onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFF2E6FF3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [_softShadow],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E6FF3)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.vibration,
                      color:
                          Color(0xFF2E6FF3),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    "MODE $modeNumber: $title",
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                      color:
                          Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),

              Switch(
                value: isActive,
                activeColor:
                    const Color(0xFF2E6FF3),
                onChanged: onToggle,
              ),
            ],
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            child: Divider(
              color: Color(0xFFF4F7FB),
            ),
          ),

          Row(
            children: [
              const Icon(
                Icons.bolt,
                size: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                "Intensity: $intensity",
                style: const TextStyle(
                  color:
                      Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(
                Icons.healing,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Target: $curingTarget",
                  style: const TextStyle(
                    color:
                        Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  mechanism,
                  style: const TextStyle(
                    color:
                        Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SENSOR GRID CARD
  // ============================================================

  Widget _buildGridCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [_softShadow],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF64748B),
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: valueColor,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACCESS CARD
  // ============================================================

  Widget _buildSmallGridCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: [_softShadow],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF1E293B),
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}