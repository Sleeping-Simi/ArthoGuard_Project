import 'package:flutter/material.dart';
import 'theme_flow.dart';

class RehabPlanScreen extends StatelessWidget {
  final Map metrics;
  final Map userData;

  const RehabPlanScreen({super.key, required this.metrics, required this.userData});

  // 1. DYNAMIC AI CONTEXT GENERATOR
  String _generateDynamicContext() {
    double extAngle = metrics['extAngle'];
    double arc = metrics['arc'];
    double score = metrics['score'];
    String bmiCat = userData['bmiCategory'] ?? "Normal";

    String contextStr = "The MediaPipe scan captured an Extension Angle of ${extAngle.toStringAsFixed(1)}° and a Total Arc of ${arc.toStringAsFixed(1)}°. ";

    if (score < 10.0) {
      contextStr += "Critical ROM Failure detected. The assessment calculated near-zero movement between the two images. Please ensure the second image captures the knee bent as far back as possible. If this restriction is accurate, seek immediate medical consultation. ";
    } else if (score < 50.0) {
      contextStr += "Severe joint stiffness is present. ";
      if (extAngle < 165.0) contextStr += "A massive extension lag was found, which will cause a severe limp. ";
      if (bmiCat == "Obese" || bmiCat == "Overweight") contextStr += "Current BMI classification ($bmiCat) places excessive kinematic stress on the weakened joint. ";
    } else if (score < 85.0) {
      contextStr += "Moderate mobility restriction detected. Functional movement is present, but the joint lacks full range. ";
    } else {
      contextStr += "Your joint articulation is optimal! The biomechanics fall within the healthy human parameter of 135°-145° of movement. ";
    }

    return contextStr;
  }

  // 2. DYNAMIC AI PRESCRIPTION GENERATOR
  List<Map<String, String>> _generatePrescription() {
    List<Map<String, String>> plan = [];
    double extLag = metrics['extLag'];
    double flexDeficit = metrics['flexDeficit'];
    double score = metrics['score'];

    // Handle "Zero Movement" invalid scans explicitly
    if (score < 10.0) {
      plan.add({"title": "Re-Take Assessment", "desc": "The previous scan detected less than 10 degrees of motion. Retake the scan ensuring the 'Flexion' picture shows the heel pulled back toward the glutes.", "time": "Immediate"});
      plan.add({"title": "ArthoGuard Mode 3: Deep Tissue", "desc": "Apply high-intensity vibration to the surrounding tissue to alleviate total lock-up before re-scanning.", "time": "15 mins / daily"});
      return plan;
    }

    // Dynamic Logic for Extension Lag
    if (extLag > 10.0) {
      plan.add({"title": "Prone Hangs (Extension Target)", "desc": "Lie face down with your legs hanging off the edge of a bed to let gravity force the knee past the ${metrics['extAngle'].toStringAsFixed(1)}° mark.", "time": "5 mins / 3x daily"});
    } else if (extLag > 3.0) {
      plan.add({"title": "Quad Sets", "desc": "Press the back of your knee firmly into a rolled towel to correct the mild ${extLag.toStringAsFixed(1)}° extension lag.", "time": "20 reps / 2x daily"});
    }

    // Dynamic Logic for Flexion Deficit
    if (flexDeficit > 40.0) {
      plan.add({"title": "Wall Slides (Flexion Target)", "desc": "Lie on your back with feet on the wall. Slowly slide your heel down to push past your current ${metrics['arc'].toStringAsFixed(1)}° limit.", "time": "10 mins / daily"});
      plan.add({"title": "ArthoGuard Mode 2: Moderate Stimulation", "desc": "Apply mid-level frequency vibration directly to the joint line to warm up synovial fluid before attempting wall slides.", "time": "10 mins / pre-workout"});
    } else if (flexDeficit > 15.0) {
      plan.add({"title": "Heel Slides", "desc": "Sit on the floor and use a towel to pull your heel toward your glutes, increasing your flexion arc.", "time": "15 reps / 2x daily"});
    }

    // If completely healthy
    if (plan.isEmpty) {
      plan.add({"title": "ArthoGuard Mode 1: Gentle Recovery", "desc": "Your ROM score of ${score.toStringAsFixed(0)} indicates prime joint health. Use low-frequency vibration to maintain cartilage hydration.", "time": "15 mins / daily"});
      plan.add({"title": "Bodyweight Squats", "desc": "Maintain full range of motion mechanics.", "time": "3 sets of 15 / daily"});
    }

    return plan;
  }

  @override
  Widget build(BuildContext context) {
    final plan = _generatePrescription();
    final String dynamicContext = _generateDynamicContext();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Targeted AI Rehab Protocol', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Color(0xFF1E293B))),
      body: AnimatedBlueFlow(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The dynamic text box
                Container(
                  padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF2E6FF3), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF2E6FF3).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [Icon(Icons.psychology, color: Colors.white), SizedBox(width: 8), Text("AI Clinical Context", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
                      const SizedBox(height: 12),
                      Text(dynamicContext, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Prescribed Biomechanical Exercises", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 16),
                
                // The dynamic list of tasks
                Expanded(
                  child: ListView.builder(
                    itemCount: plan.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Expanded(child: Text(plan[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)))), 
                              const SizedBox(width: 8),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF4F8FF), borderRadius: BorderRadius.circular(8)), child: Text(plan[index]['time']!, style: const TextStyle(color: Color(0xFF2E6FF3), fontSize: 12, fontWeight: FontWeight.bold)))
                            ]),
                            const SizedBox(height: 8),
                            Text(plan[index]['desc']!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0, side: const BorderSide(color: Color(0xFF2E6FF3))),
                  child: const Text('Back to Home Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E6FF3))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}