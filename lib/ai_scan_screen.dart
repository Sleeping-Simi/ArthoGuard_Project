import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'theme_flow.dart';
import 'rom_report.dart';

class AiScanScreen extends StatefulWidget {
  final Map userData;

  const AiScanScreen({
    super.key,
    required this.userData,
  });

  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen> {
  // ============================================================
  // DEPLOYED BACKEND
  // ============================================================

  static const String _backendBaseUrl =
      'https://arthoguard-ai-backend.onrender.com';

  static const String _analyzeEndpoint =
      '$_backendBaseUrl/analyze';

  // ============================================================
  // STATE
  // ============================================================

  XFile? _extImg;
  XFile? _flexImg;

  bool _isLoading = false;

  String _statusMsg = "Awaiting image capture...";

  final ImagePicker _picker = ImagePicker();

  // ============================================================
  // CAMERA
  // ============================================================

  Future<void> _pickCapture(bool isExtension) async {
    if (_isLoading) return;

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (file == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        if (isExtension) {
          _extImg = file;
        } else {
          _flexImg = file;
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Camera could not be accessed. Please check camera permission.",
          ),
        ),
      );
    }
  }

  // ============================================================
  // BACKEND CALL
  // ============================================================

  Future<Map<String, dynamic>> _callAiBackend(
    XFile file,
  ) async {
    try {
      final uri = Uri.parse(_analyzeEndpoint);

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      // --------------------------------------------------------
      // WEB
      // --------------------------------------------------------

      if (kIsWeb) {
        final bytes = await file.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: file.name,
          ),
        );
      }

      // --------------------------------------------------------
      // ANDROID / IOS / DESKTOP
      // --------------------------------------------------------

      else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
          ),
        );
      }

      // --------------------------------------------------------
      // SEND REQUEST
      //
      // Render free instances can take some time to wake up.
      // Therefore we allow a longer timeout.
      // --------------------------------------------------------

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 90),
      );

      final responseBody =
          await streamedResponse.stream.bytesToString();

      // --------------------------------------------------------
      // HTTP ERROR
      // --------------------------------------------------------

      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode >= 300) {
        throw Exception(
          'Backend returned HTTP ${streamedResponse.statusCode}: '
          '$responseBody',
        );
      }

      // --------------------------------------------------------
      // EMPTY RESPONSE
      // --------------------------------------------------------

      if (responseBody.trim().isEmpty) {
        throw Exception(
          'Backend returned an empty response.',
        );
      }

      // --------------------------------------------------------
      // JSON RESPONSE
      // --------------------------------------------------------

      final decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response received from ROM backend.',
        );
      }

      return decoded;
    }

    // ----------------------------------------------------------
    // TIMEOUT
    // ----------------------------------------------------------

    on HttpException catch (e) {
      throw Exception(
        'Network error while contacting ROM backend: $e',
      );
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network.',
      );
    } on FormatException {
      throw Exception(
        'Backend returned an invalid response.',
      );
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception(
        'Unexpected backend error: $e',
      );
    }
  }

  // ============================================================
  // ROM PROCESSING
  // ============================================================

  Future<void> _processROM() async {
    if (_extImg == null || _flexImg == null) {
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMsg = "Connecting to ArthroGuard AI...";
    });

    try {
      // ========================================================
      // EXTENSION IMAGE
      // ========================================================

      setState(() {
        _statusMsg =
            "Analyzing maximum extension...";
      });

      final extResult = await _callAiBackend(
        _extImg!,
      );

      // ========================================================
      // FLEXION IMAGE
      // ========================================================

      setState(() {
        _statusMsg =
            "Analyzing maximum flexion...";
      });

      final flexResult = await _callAiBackend(
        _flexImg!,
      );

      // ========================================================
      // CHECK BACKEND STATUS
      // ========================================================

      if (extResult['status'] != 'success' ||
          flexResult['status'] != 'success') {
        throw Exception(
          'Pose estimation failed for one or both images.',
        );
      }

      // ========================================================
      // ANGLES
      // ========================================================

      final extAngleValue = extResult['angle'];
      final flexAngleValue = flexResult['angle'];

      if (extAngleValue is! num ||
          flexAngleValue is! num) {
        throw Exception(
          'Backend did not return valid ROM angles.',
        );
      }

      final double extAngle =
          extAngleValue.toDouble();

      final double flexAngle =
          flexAngleValue.toDouble();

      // ========================================================
      // PROCESSED IMAGES
      // ========================================================

      final String? extProcessed =
          extResult['processed_image']?.toString();

      final String? flexProcessed =
          flexResult['processed_image']?.toString();

      if (extProcessed == null ||
          extProcessed.isEmpty ||
          flexProcessed == null ||
          flexProcessed.isEmpty) {
        throw Exception(
          'Backend did not return processed images.',
        );
      }

      final Uint8List extBytes =
          base64Decode(extProcessed);

      final Uint8List flexBytes =
          base64Decode(flexProcessed);

      // ========================================================
      // OPEN ROM REPORT
      // ========================================================

      if (!mounted) return;

      setState(() {
        _statusMsg = "ROM analysis completed.";
      });

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RomReportScreen(
            userData: widget.userData,
            extAngle: extAngle,
            flexAngle: flexAngle,
            extBytes: extBytes,
            flexBytes: flexBytes,
          ),
        ),
      );
    } on TimeoutException {
      if (!mounted) return;

      _showError(
        "The AI backend took too long to respond. "
        "The server may be waking up. Please try again.",
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        _cleanErrorMessage(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('SocketException')) {
      return "No internet connection. Please check your network.";
    }

    if (message.contains('TimeoutException')) {
      return "The AI backend timed out. Please try again.";
    }

    if (message.contains('HTTP 404')) {
      return "ROM analysis endpoint was not found on the server.";
    }

    if (message.contains('HTTP 500')) {
      return "The AI backend encountered an internal error.";
    }

    if (message.contains('HTTP 502') ||
        message.contains('HTTP 503')) {
      return "The AI backend is temporarily unavailable. "
          "Please try again in a moment.";
    }

    if (message.contains('Pose estimation failed')) {
      return "The knee could not be detected clearly. "
          "Please retake the image with the full leg visible.";
    }

    if (message.contains('processed images')) {
      return "The AI server did not return the processed image.";
    }

    return "ROM analysis failed. Please check your internet "
        "connection and try again.";
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "OK",
          onPressed: () {},
        ),
      ),
    );
  }

  // ============================================================
  // CAPTURE CARD
  // ============================================================

  Widget _buildCaptureCard(
    String title,
    String subtitle,
    XFile? file,
    bool isExt,
  ) {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => _pickCapture(isExt),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 160,
          maxHeight: 400,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: file != null
                ? const Color(0xFF2E6FF3)
                : const Color(0xFF2E6FF3)
                    .withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: kIsWeb
                    ? Image.network(
                        file.path,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        File(file.path),
                        fit: BoxFit.contain,
                      ),
              )
            : Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    isExt
                        ? Icons.straighten
                        : Icons.directions_walk,
                    size: 42,
                    color: const Color(0xFF2E6FF3),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          'Capture Phase',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color(0xFF1E293B),
        ),
      ),

      body: AnimatedBlueFlow(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // EXTENSION
              // ==================================================

              _buildCaptureCard(
                "1. Maximum Extension",
                "Leg perfectly straight",
                _extImg,
                true,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // FLEXION
              // ==================================================

              _buildCaptureCard(
                "2. Maximum Flexion",
                "Knee bent as far as possible",
                _flexImg,
                false,
              ),

              const SizedBox(height: 28),

              // ==================================================
              // LOADING
              // ==================================================

              if (_isLoading) ...[
                Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFF2E6FF3),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        _statusMsg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF2E6FF3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Please keep this screen open.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ]

              // ==================================================
              // GENERATE BUTTON
              // ==================================================

              else ...[
                ElevatedButton(
                  onPressed:
                      (_extImg != null &&
                              _flexImg != null)
                          ? _processROM
                          : null,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2E6FF3),
                    disabledBackgroundColor:
                        Colors.grey.shade300,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Generate Diagnostic Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}