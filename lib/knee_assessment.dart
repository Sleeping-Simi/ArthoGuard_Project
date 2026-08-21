import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KneeAssessmentScreen extends StatefulWidget {
  final Map userData;

  const KneeAssessmentScreen({
    super.key,
    required this.userData,
  });

  @override
  State<KneeAssessmentScreen> createState() =>
      _KneeAssessmentScreenState();
}

class _KneeAssessmentScreenState
    extends State<KneeAssessmentScreen> {

  // ============================================================
  // FLOW
  // 0 = Reference + Capture
  // 1 = Preview + Rotate
  // 2 = Reference + User Knee + Pain Zones
  // ============================================================

  int _step = 0;

  final ImagePicker _picker = ImagePicker();

  XFile? _patientImage;

  int _rotationTurns = 0;

  final Set<String> _selectedZones = {};

  // ============================================================
  // PAIN ZONES
  // ============================================================

  final Map<String, ZoneInfo> _zones = {
    "femur": const ZoneInfo(
      name: "Femur",
      description: "Thigh bone",
      color: Color(0xFF8E3CC7),
    ),
    "patella": const ZoneInfo(
      name: "Patella",
      description: "Kneecap",
      color: Color(0xFFFFB300),
    ),
    "tibia": const ZoneInfo(
      name: "Tibia",
      description: "Shin bone",
      color: Color(0xFF1976D2),
    ),
    "medial": const ZoneInfo(
      name: "Medial",
      description: "Inner side",
      color: Color(0xFFE62E5C),
    ),
    "lateral": const ZoneInfo(
      name: "Lateral",
      description: "Outer side",
      color: Color(0xFF269B4A),
    ),
  };

  // ============================================================
  // CAPTURE
  // ============================================================

  Future<void> _captureKnee() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _patientImage = image;
        _rotationTurns = 0;
        _selectedZones.clear();
        _step = 1;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to open camera: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // ROTATION
  // ============================================================

  void _rotateLeft() {
    setState(() {
      _rotationTurns =
          (_rotationTurns - 1) % 4;
    });
  }

  void _rotateRight() {
    setState(() {
      _rotationTurns =
          (_rotationTurns + 1) % 4;
    });
  }

  // ============================================================
  // NEXT
  // ============================================================

  void _goToPainLocation() {
    if (_patientImage == null) {
      return;
    }

    setState(() {
      _step = 2;
    });
  }

  // ============================================================
  // SELECT PAIN ZONE
  // ============================================================

  void _toggleZone(String zone) {
    setState(() {
      if (_selectedZones.contains(zone)) {
        _selectedZones.remove(zone);
      } else {
        _selectedZones.add(zone);
      }
    });
  }

  // ============================================================
  // START ASSESSMENT
  // ============================================================

  void _startAssessment() {
    if (_selectedZones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select at least one painful area.",
          ),
        ),
      );
      return;
    }

    final selectedNames = _selectedZones
        .map((zone) => _zones[zone]!.name)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            "Pain Location Confirmed",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Selected areas:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              ...selectedNames.map(
                (name) => Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF2E6FF3),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(name),
                    ],
                  ),
                ),
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Assessment started.",
                    ),
                  ),
                );

                // Future:
                // Send selected zones + image to backend.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2E6FF3),
                foregroundColor: Colors.white,
              ),
              child: const Text("CONTINUE"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1E293B),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Knee Assessment",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: AnimatedSwitcher(
          duration:
              const Duration(milliseconds: 300),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  // ============================================================
  // SCREEN FLOW
  // ============================================================

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildReferenceScreen();

      case 1:
        return _buildPreviewScreen();

      case 2:
        return _buildPainLocationScreen();

      default:
        return _buildReferenceScreen();
    }
  }

  // ============================================================
  // STEP 1
  // REFERENCE + CAPTURE
  // ============================================================

  Widget _buildReferenceScreen() {
    return SingleChildScrollView(
      key: const ValueKey("reference"),
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          _buildStepIndicator(
            current: 1,
            total: 3,
          ),

          const SizedBox(height: 20),

          const Text(
            "Position Your Knee",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Use the reference image as a guide "
            "and position your knee similarly before taking the photo.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // REFERENCE IMAGE
          // ======================================================

          Container(
            width: double.infinity,
            constraints:
                const BoxConstraints(
              maxHeight: 480,
            ),

            padding:
                const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.06),
                  blurRadius: 18,
                  offset:
                      const Offset(0, 6),
                ),
              ],
            ),

            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(18),

              child: Image.asset(
                "assets/images/reference_knee.png",
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding:
                const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color:
                  const Color(0xFFEFF6FF),
              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color:
                      Color(0xFF2E6FF3),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Try to keep your knee centered "
                    "and match the orientation shown above.",
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,

            child: ElevatedButton.icon(
              onPressed: _captureKnee,

              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),

              label: const Text(
                "TAKE KNEE PHOTO",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2E6FF3),
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 2
  // PREVIEW + ROTATE
  // ============================================================

  Widget _buildPreviewScreen() {
    return SingleChildScrollView(
      key: const ValueKey("preview"),
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          _buildStepIndicator(
            current: 2,
            total: 3,
          ),

          const SizedBox(height: 20),

          const Text(
            "Preview Your Photo",
            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Rotate the image until the knee orientation "
            "matches the reference.",
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Color(0xFF64748B),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            height: 480,

            padding:
                const EdgeInsets.all(12),

            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.06),
                  blurRadius: 18,
                  offset:
                      const Offset(0, 6),
                ),
              ],
            ),

            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(18),

              child:
                  _patientImage == null
                      ? const Center(
                          child:
                              Text("No image"),
                        )
                      : InteractiveViewer(
                          minScale: 1,
                          maxScale: 3,

                          child:
                              RotatedBox(
                            quarterTurns:
                                _rotationTurns,

                            child:
                                Image.file(
                              File(
                                _patientImage!
                                    .path,
                              ),
                              fit:
                                  BoxFit.contain,
                            ),
                          ),
                        ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed:
                      _rotateLeft,

                  icon:
                      const Icon(
                    Icons.rotate_left,
                  ),

                  label:
                      const Text(
                    "ROTATE LEFT",
                  ),

                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        const Color(
                      0xFF2E6FF3,
                    ),
                    side:
                        const BorderSide(
                      color:
                          Color(
                        0xFF2E6FF3,
                      ),
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed:
                      _rotateRight,

                  icon:
                      const Icon(
                    Icons.rotate_right,
                  ),

                  label:
                      const Text(
                    "ROTATE RIGHT",
                  ),

                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        const Color(
                      0xFF2E6FF3,
                    ),
                    side:
                        const BorderSide(
                      color:
                          Color(
                        0xFF2E6FF3,
                      ),
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 56,

            child: ElevatedButton.icon(
              onPressed:
                  _goToPainLocation,

              icon:
                  const Icon(
                Icons.arrow_forward,
                color:
                    Colors.white,
              ),

              label:
                  const Text(
                "NEXT",
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF2E6FF3,
                ),
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 3
  // REFERENCE + USER PHOTO + CIRCLES
  // ============================================================

  Widget _buildPainLocationScreen() {
    return SingleChildScrollView(
      key:
          const ValueKey(
        "pain-location",
      ),

      padding:
          const EdgeInsets.all(16),

      child: Column(
        children: [
          _buildStepIndicator(
            current: 3,
            total: 3,
          ),

          const SizedBox(height: 16),

          const Text(
            "Identify Your Pain Location",
            style:
                TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Use the reference on the left to understand "
            "the colors. Tap the corresponding colored "
            "circle on YOUR KNEE on the right.",
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF64748B),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          // ======================================================
          // SIDE BY SIDE
          // ======================================================

          SizedBox(
            height: 440,

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,

              children: [
                // ==================================================
                // REFERENCE
                // NON-INTERACTIVE
                // ==================================================

                Expanded(
                  child:
                      _buildComparisonCard(
                    title:
                        "REFERENCE",

                    child:
                        ClipRRect(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),

                      child:
                          Image.asset(
                        "assets/images/reference_knee.png",
                        fit:
                            BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    width: 10),

                // ==================================================
                // USER KNEE
                // INTERACTIVE
                // ==================================================

                Expanded(
                  child:
                      _buildComparisonCard(
                    title:
                        "YOUR KNEE",

                    child:
                        _buildUserKneeWithZones(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _buildColorLegend(),

          const SizedBox(height: 18),

          _buildSelectedZones(),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 56,

            child:
                ElevatedButton.icon(
              onPressed:
                  _startAssessment,

              icon:
                  const Icon(
                Icons.play_arrow,
                color:
                    Colors.white,
              ),

              label:
                  const Text(
                "START ASSESSMENT",
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF2E6FF3,
                ),
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============================================================
  // USER KNEE + SELECTABLE CIRCLES
  //
  // IMPORTANT:
  // THE CIRCLES ARE ONLY ON THE USER'S PHOTO.
  // ============================================================

  Widget _buildUserKneeWithZones() {
    if (_patientImage == null) {
      return const Center(
        child: Text("No photo"),
      );
    }

    return LayoutBuilder(
      builder:
          (context, constraints) {

        return Stack(
          fit: StackFit.expand,

          children: [
            // ====================================================
            // USER PHOTO
            // ====================================================

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),

              child: RotatedBox(
                quarterTurns:
                    _rotationTurns,

                child: Image.file(
                  File(
                    _patientImage!.path,
                  ),
                  fit:
                      BoxFit.contain,
                ),
              ),
            ),

            // ====================================================
            // PAIN CIRCLES
            // ====================================================

            _buildPainCircle(
              zone: "femur",
              color:
                  const Color(
                0xFF8E3CC7,
              ),
              left:
                  constraints.maxWidth *
                          0.50 -
                      22,
              top:
                  constraints.maxHeight *
                          0.24 -
                      22,
            ),

            _buildPainCircle(
              zone: "patella",
              color:
                  const Color(
                0xFFFFB300,
              ),
              left:
                  constraints.maxWidth *
                          0.50 -
                      22,
              top:
                  constraints.maxHeight *
                          0.43 -
                      22,
            ),

            _buildPainCircle(
              zone: "tibia",
              color:
                  const Color(
                0xFF1976D2,
              ),
              left:
                  constraints.maxWidth *
                          0.50 -
                      22,
              top:
                  constraints.maxHeight *
                          0.62 -
                      22,
            ),

            _buildPainCircle(
              zone: "medial",
              color:
                  const Color(
                0xFFE62E5C,
              ),
              left:
                  constraints.maxWidth *
                          0.68 -
                      22,
              top:
                  constraints.maxHeight *
                          0.43 -
                      22,
            ),

            _buildPainCircle(
              zone: "lateral",
              color:
                  const Color(
                0xFF269B4A,
              ),
              left:
                  constraints.maxWidth *
                          0.32 -
                      22,
              top:
                  constraints.maxHeight *
                          0.43 -
                      22,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // INDIVIDUAL PAIN CIRCLE
  // ============================================================

  Widget _buildPainCircle({
    required String zone,
    required Color color,
    required double left,
    required double top,
  }) {
    final bool selected =
        _selectedZones.contains(
      zone,
    );

    return Positioned(
      left: left,
      top: top,

      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque,

        onTap: () {
          _toggleZone(zone);
        },

        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),

          width:
              selected ? 54 : 44,

          height:
              selected ? 54 : 44,

          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,

            color:
                color.withOpacity(
              selected
                  ? 0.95
                  : 0.78,
            ),

            border:
                Border.all(
              color:
                  Colors.white,
              width:
                  selected ? 4 : 2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    color.withOpacity(
                  0.45,
                ),
                blurRadius:
                    selected ? 14 : 8,
                spreadRadius:
                    selected ? 3 : 1,
              ),
            ],
          ),

          child:
              selected
                  ? const Icon(
                      Icons.check,
                      color:
                          Colors.white,
                      size: 28,
                    )
                  : null,
        ),
      ),
    );
  }

  // ============================================================
  // COMPARISON CARD
  // ============================================================

  Widget _buildComparisonCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(8),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.05,
            ),
            blurRadius:
                12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            width:
                double.infinity,

            padding:
                const EdgeInsets.symmetric(
              vertical: 8,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF1F5F9,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),

            child:
                Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(
                  0xFF475569,
                ),
              ),
            ),
          ),

          const SizedBox(
              height: 8),

          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLOR LEGEND
  //
  // This is explanatory only.
  // The actual selection happens on USER KNEE.
  // ============================================================

  Widget _buildColorLegend() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        14,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "Color Guide",
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 14,
              color:
                  Color(
                0xFF1E293B,
              ),
            ),
          ),

          const SizedBox(
              height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 10,

            children:
                _zones.entries.map(
              (entry) {
                final zone =
                    entry.value;

                return Row(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Container(
                      width: 14,
                      height: 14,

                      decoration:
                          BoxDecoration(
                        color:
                            zone.color,
                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                        width: 5),

                    Text(
                      zone.name,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Color(
                          0xFF475569,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED ZONES
  // ============================================================

  Widget _buildSelectedZones() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          BoxDecoration(
        color:
            _selectedZones.isEmpty
                ? Colors.white
                : const Color(
                    0xFFEFF6FF,
                  ),

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color:
              _selectedZones.isEmpty
                  ? const Color(
                      0xFFE2E8F0,
                    )
                  : const Color(
                      0xFFBFDBFE,
                    ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "Selected Pain Areas",
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(
                0xFF1E293B,
              ),
            ),
          ),

          const SizedBox(
              height: 8),

          if (_selectedZones.isEmpty)
            const Text(
              "Tap a colored circle on your knee.",
              style:
                  TextStyle(
                fontSize: 13,
                color:
                    Color(
                  0xFF64748B,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,

              children:
                  _selectedZones.map(
                (zoneKey) {
                  final zone =
                      _zones[zoneKey]!;

                  return Chip(
                    avatar:
                        CircleAvatar(
                      backgroundColor:
                          zone.color,
                      radius: 8,
                    ),

                    label:
                        Text(
                      zone.name,
                    ),

                    deleteIcon:
                        const Icon(
                      Icons.close,
                      size: 16,
                    ),

                    onDeleted:
                        () =>
                            _toggleZone(
                      zoneKey,
                    ),
                  );
                },
              ).toList(),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP INDICATOR
  // ============================================================

  Widget _buildStepIndicator({
    required int current,
    required int total,
  }) {
    return Row(
      children:
          List.generate(
        total,
        (index) {
          final int step =
              index + 1;

          final bool active =
              step <= current;

          return Expanded(
            child: Container(
              margin:
                  EdgeInsets.only(
                right:
                    index == total - 1
                        ? 0
                        : 6,
              ),

              height: 5,

              decoration:
                  BoxDecoration(
                color: active
                    ? const Color(
                        0xFF2E6FF3,
                      )
                    : const Color(
                        0xFFE2E8F0,
                      ),

                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================================================================
// ZONE MODEL
// ================================================================

class ZoneInfo {
  final String name;
  final String description;
  final Color color;

  const ZoneInfo({
    required this.name,
    required this.description,
    required this.color,
  });
}