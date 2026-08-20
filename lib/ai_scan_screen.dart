import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'theme_flow.dart';
import 'rom_report.dart'; 

class AiScanScreen extends StatefulWidget {
  final Map userData; // Receives data from dashboard!
  const AiScanScreen({super.key, required this.userData});
  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen> {
  XFile? _extImg;
  XFile? _flexImg;
  bool _isLoading = false;
  String _statusMsg = "Awaiting image capture...";
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickCapture(bool isExtension) async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        setState(() {
          if (isExtension) _extImg = file;
          else _flexImg = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Camera not accessible.")));
    }
  }

  Future<Map<String, dynamic>> _callAiBackend(XFile file) async {
    var req = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/analyze'));
    if (kIsWeb) {
      var bytes = await file.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));
    } else {
      req.files.add(await http.MultipartFile.fromPath('file', file.path));
    }
    var res = await req.send();
    return jsonDecode(await res.stream.bytesToString());
  }

  Future<void> _processROM() async {
    if (_extImg == null || _flexImg == null) return;
    setState(() { _isLoading = true; _statusMsg = "Extracting Biomechanical Landmarks..."; });

    try {
      var extResult = await _callAiBackend(_extImg!);
      setState(() => _statusMsg = "Computing Trigonomic Joint Angles...");
      var flexResult = await _callAiBackend(_flexImg!);

      if (extResult['status'] == 'success' && flexResult['status'] == 'success') {
        double eAng = (extResult['angle'] as num).toDouble();
        double fAng = (flexResult['angle'] as num).toDouble();
        
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => RomReportScreen(
              userData: widget.userData, // Pass the data to the report!
              extAngle: eAng,
              flexAngle: fAng,
              extBytes: base64Decode(extResult['processed_image']),
              flexBytes: base64Decode(flexResult['processed_image']),
            )
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pose estimation failed. Please try again.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server error. Ensure Python backend is running.")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCaptureCard(String title, String subtitle, XFile? file, bool isExt) {
    return GestureDetector(
      onTap: () => _pickCapture(isExt),
      child: Container(
        constraints: const BoxConstraints(minHeight: 160, maxHeight: 400),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: file != null ? const Color(0xFF2E6FF3) : const Color(0xFF2E6FF3).withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: file != null
            ? ClipRRect(borderRadius: BorderRadius.circular(18), child: kIsWeb ? Image.network(file.path, fit: BoxFit.contain) : Image.file(File(file.path), fit: BoxFit.contain))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isExt ? Icons.straighten : Icons.directions_walk, size: 42, color: const Color(0xFF2E6FF3)),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Capture Phase', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Color(0xFF1E293B))),
      body: AnimatedBlueFlow(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCaptureCard("1. Maximum Extension", "Leg perfectly straight", _extImg, true),
              const SizedBox(height: 16),
              _buildCaptureCard("2. Maximum Flexion", "Knee bent as far as possible", _flexImg, false),
              const SizedBox(height: 28),
              
              if (_isLoading) ...[
                Center(child: Text(_statusMsg, style: const TextStyle(color: Color(0xFF2E6FF3), fontWeight: FontWeight.bold))),
                const SizedBox(height: 16),
                const LinearProgressIndicator(color: Color(0xFF2E6FF3), backgroundColor: Colors.white),
              ] else ...[
                ElevatedButton(
                  onPressed: (_extImg != null && _flexImg != null) ? _processROM : null,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E6FF3), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Generate Diagnostic Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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