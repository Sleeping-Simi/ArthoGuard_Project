import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'health_profile.dart';
import 'login.dart';
import 'theme_flow.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  String _captcha = "";

  @override
  void initState() {
    super.initState();
    _genCaptcha();
  }

  void _genCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = math.Random();
    setState(() {
      _captcha = String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(r.nextInt(chars.length))));
      _captchaController.clear();
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HealthProfilePage(
        basicData: {'name': _nameController.text, 'email': _emailController.text}
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
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.app_registration, size: 56, color: Color(0xFF2E6FF3)),
                    const SizedBox(height: 16),
                    const Text('Create Patient Record', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 28),

                    TextFormField(controller: _nameController, style: const TextStyle(color: Color(0xFF1E293B)), decoration: InputDecoration(labelText: 'Full Name', labelStyle: const TextStyle(color: Color(0xFF64748B)), prefixIcon: const Icon(Icons.person, color: Color(0xFF2E6FF3)), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 14),
                    TextFormField(controller: _emailController, style: const TextStyle(color: Color(0xFF1E293B)), decoration: InputDecoration(labelText: 'Email Address', labelStyle: const TextStyle(color: Color(0xFF64748B)), prefixIcon: const Icon(Icons.email, color: Color(0xFF2E6FF3)), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null),
                    const SizedBox(height: 14),
                    TextFormField(controller: _passwordController, obscureText: true, style: const TextStyle(color: Color(0xFF1E293B)), decoration: InputDecoration(labelText: 'Password', labelStyle: const TextStyle(color: Color(0xFF64748B)), prefixIcon: const Icon(Icons.lock, color: Color(0xFF2E6FF3)), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(12)), child: Text(_captcha, style: const TextStyle(color: Color(0xFF2E6FF3), fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 4))),
                        IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF2E6FF3)), onPressed: _genCaptcha),
                        Expanded(child: TextFormField(controller: _captchaController, style: const TextStyle(color: Color(0xFF1E293B)), decoration: InputDecoration(labelText: 'Code', labelStyle: const TextStyle(color: Color(0xFF64748B)), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), validator: (v) => v != _captcha ? 'Invalid' : null)),
                      ],
                    ),
                    const SizedBox(height: 28),

                    ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E6FF3), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Proceed to Biometric Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                    const SizedBox(height: 16),
                    TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())), child: const Text('Already Registered? Login', style: TextStyle(color: Color(0xFF2E6FF3), fontWeight: FontWeight.bold))),
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