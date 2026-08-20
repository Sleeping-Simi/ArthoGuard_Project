import 'package:flutter/material.dart';
import 'theme_flow.dart';
import 'ai_scan_screen.dart';

class RomGuideScreen extends StatelessWidget {
  final Map userData;
  const RomGuideScreen({super.key, required this.userData});

  Widget _buildStep(String number, String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF2E6FF3).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))]),
            child: Text(number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E6FF3))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFF2E6FF3), size: 20),
                    const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Assessment Protocol', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Color(0xFF1E293B))),
      body: AnimatedBlueFlow(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Clinical Accuracy Guidelines", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),
                const Text("To ensure our MediaPipe Pose AI calculates your exact joint vectors, please follow these 3 steps carefully.", style: TextStyle(color: Color(0xFF64748B), fontSize: 15, height: 1.5)),
                const SizedBox(height: 32),
                
                Expanded(
                  child: ListView(
                    children: [
                      _buildStep("1", "Camera Placement", "Place your device on the floor or a low stand. The camera lens must be at exact knee height.", Icons.phone_android),
                      _buildStep("2", "Clear Visibility", "Ensure your Hip, Knee, and Ankle are all clearly visible in the frame. Wear shorts or tight clothing.", Icons.visibility),
                      _buildStep("3", "Side Profile Only", "Stand perfectly sideways to the camera. Do not face the camera directly.", Icons.accessibility_new),
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFE0ECFF), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2E6FF3).withOpacity(0.3))),
                  child: const Row(children: [Icon(Icons.privacy_tip, color: Color(0xFF2E6FF3)), SizedBox(width: 12), Expanded(child: Text("All image processing is done locally via Edge AI. Your photos are never stored.", style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w500)))]),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AiScanScreen(userData: userData))),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E6FF3), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4),
                  child: const Text('I Understand, Start Scanner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}