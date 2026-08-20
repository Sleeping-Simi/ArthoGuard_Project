import 'package:flutter/material.dart';
import 'health_profile.dart';
import 'register.dart';
import 'theme_flow.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HealthProfilePage(
        basicData: {'name': 'Aditya Naskar', 'email': 'aditya@example.com'}
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBlueFlow(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle), child: const Icon(Icons.shield, size: 64, color: Color(0xFF2E6FF3))),
                    const SizedBox(height: 28),
                    const Text('ArthoGuard AI', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 8),
                    const Text('Clinical Knee Recovery & ROM Analytics', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
                    const SizedBox(height: 36),

                    TextFormField(controller: _emailController, style: const TextStyle(color: Color(0xFF1E293B)), decoration: InputDecoration(labelText: 'Email Address', labelStyle: const TextStyle(color: Color(0xFF64748B)), prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2E6FF3)), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null),
                    const SizedBox(height: 16),
                    TextFormField(controller: _passwordController, obscureText: true, style: const TextStyle(color: Color(0xFF1E293B)), decoration: InputDecoration(labelText: 'Password', labelStyle: const TextStyle(color: Color(0xFF64748B)), prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2E6FF3)), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null),
                    const SizedBox(height: 28),

                    ElevatedButton(onPressed: _login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E6FF3), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Sign In to Clinical Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                    const SizedBox(height: 18),
                    TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage())), child: const Text("Don't have an account? Register Here", style: TextStyle(color: Color(0xFF2E6FF3), fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}