import 'package:flutter/material.dart';
import 'theme_flow.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> historyLogs;
  const HistoryScreen({super.key, required this.historyLogs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28), onPressed: () => Navigator.pop(context)),
        title: const Text('Therapy History', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: AnimatedBlueFlow(
        child: historyLogs.isEmpty
            ? const Center(child: Text("No therapy data recorded yet.", style: TextStyle(color: Colors.grey, fontSize: 16)))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: historyLogs.length,
                itemBuilder: (context, index) {
                  final log = historyLogs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildHistoryCard(
                      date: log['timestamp'],
                      duration: log['duration'],
                      therapyName: log['modeName'],
                      pillColor: const Color(0xFFF3E8FF),
                      pillTextColor: const Color(0xFF8B5CF6),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHistoryCard({required String date, required String duration, required String therapyName, required Color pillColor, required Color pillTextColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: pillColor, borderRadius: BorderRadius.circular(20)), child: Text(duration, style: TextStyle(color: pillTextColor, fontWeight: FontWeight.bold, fontSize: 14))),
            ],
          ),
          const SizedBox(height: 12),
          Text(therapyName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {}, icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF64748B), size: 18),
            label: const Text("Download Report", style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), side: const BorderSide(color: Color(0xFFCBD5E1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
          ),
        ],
      ),
    );
  }
}