import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'theme_flow.dart';
import 'rehab_plan.dart';

class RomReportScreen extends StatelessWidget {
  final Map userData;
  final double extAngle;
  final double flexAngle;
  final Uint8List extBytes;
  final Uint8List flexBytes;

  const RomReportScreen({
    super.key,
    required this.userData,
    required this.extAngle,
    required this.flexAngle,
    required this.extBytes,
    required this.flexBytes,
  });

  // TRUE CLINICAL LOGIC ENGINE
  Map<String, dynamic> _computeClinicalMetrics() {
    double totalArc = (extAngle - flexAngle).abs();
    
    // 1. Extension Lag (Straight Leg Deficit)
    double extLag = (180.0 - extAngle).abs();
    String lagSeverity = extLag <= 5.0 ? "Optimal Extension" : extLag <= 15.0 ? "Mild Extension Lag" : "Severe Extension Deficit";
    Color lagColor = extLag <= 5.0 ? Colors.green : extLag <= 15.0 ? Colors.orange : Colors.red;

    // 2. Flexion Deficit (Bent Leg Deficit)
    double flexDeficit = (135.0 - totalArc);
    if (flexDeficit < 0) flexDeficit = 0; 
    String flexSeverity = totalArc >= 120 ? "Optimal Flexion" : totalArc >= 90 ? "Restricted Flexion" : "Severe Restriction";
    Color flexColor = totalArc >= 120 ? Colors.green : totalArc >= 90 ? Colors.orange : Colors.red;

    // 3. True Global Health Index (0 - 100)
    // Standard healthy arc is 135 degrees.
    double score = (totalArc / 135.0) * 100.0;
    
    // Penalize score if extension lag is severe
    if (extLag > 10.0) score -= (extLag * 1.5);
    
    // Clamp score strictly between 0 and 100
    if (score > 100) score = 100;
    if (score < 0) score = 0;

    return {
      "extAngle": extAngle,
      "flexAngle": flexAngle,
      "arc": totalArc,
      "extLag": extLag,
      "lagStatus": lagSeverity,
      "lagColor": lagColor,
      "flexDeficit": flexDeficit,
      "flexStatus": flexSeverity,
      "flexColor": flexColor,
      "score": score,
    };
  }

  Widget _buildMetricTile(String title, String value, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _computeClinicalMetrics();
    final totalArc = metrics['arc'];
    final score = metrics['score'];
    final sColor = score > 80 ? Colors.green : score > 40 ? Colors.orange : Colors.red;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Clinical Assessment Report', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Color(0xFF1E293B))),
      body: AnimatedBlueFlow(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Score Ring
              Container(
                padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: sColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))]),
                child: Column(
                  children: [
                    const Text("OVERALL KNEE HEALTH INDEX", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(width: 150, height: 150, child: CircularProgressIndicator(value: score / 100, strokeWidth: 14, backgroundColor: const Color(0xFFF4F8FF), valueColor: AlwaysStoppedAnimation<Color>(sColor))),
                        Column(children: [Text("${score.toStringAsFixed(0)}", style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: sColor, height: 1.1)), const Text("out of 100", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))]),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Visual Annotated Evidence
              const Text("AI Visual Evidence", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(extBytes, fit: BoxFit.contain))),
                  const SizedBox(width: 16),
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(flexBytes, fit: BoxFit.contain))),
                ],
              ),
              const SizedBox(height: 32),

              // Detailed Biomechanics
              const Text("Biomechanical Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              _buildMetricTile("Total ROM Arc", "${totalArc.toStringAsFixed(1)}°", metrics['flexStatus'], metrics['flexColor']),
              _buildMetricTile("Extension Angle", "${extAngle.toStringAsFixed(1)}°", metrics['lagStatus'], metrics['lagColor']),
              _buildMetricTile("Flexion Angle", "${flexAngle.toStringAsFixed(1)}°", metrics['flexStatus'], metrics['flexColor']),
              
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RehabPlanScreen(metrics: metrics, userData: userData))),
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: const Text('Generate True AI Rehab Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E6FF3), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}