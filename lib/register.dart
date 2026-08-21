import 'dart:math' as math;
import 'package:flutter/material.dart';

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
  final _confirmPasswordController = TextEditingController();
  final _captchaController = TextEditingController();

  String _captcha = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  // ============================================================
  // CAPTCHA
  // ============================================================

  void _generateCaptcha() {
    const characters =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final random = math.Random();

    final generated = String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => characters.codeUnitAt(
          random.nextInt(characters.length),
        ),
      ),
    );

    setState(() {
      _captcha = generated;
      _captchaController.clear();
    });
  }

  // ============================================================
  // NAME VALIDATION
  // ============================================================

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Full name is required';
    }

    if (name.length < 2) {
      return 'Name must contain at least 2 characters';
    }

    if (name.length > 60) {
      return 'Name is too long';
    }

    final nameRegex = RegExp(
      r"^[a-zA-Z]+(?:[\s'-][a-zA-Z]+)*$",
    );

    if (!nameRegex.hasMatch(name)) {
      return 'Enter a valid name';
    }

    return null;
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email address is required';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    if (email.length > 120) {
      return 'Email address is too long';
    }

    return null;
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    if (password.length > 64) {
      return 'Password is too long';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Include at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Include at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=]').hasMatch(password)) {
      return 'Include at least one special character';
    }

    return null;
  }

  // ============================================================
  // CONFIRM PASSWORD
  // ============================================================

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ============================================================
  // CAPTCHA VALIDATION
  // ============================================================

  String? _validateCaptcha(String? value) {
    final entered = value?.trim().toUpperCase() ?? '';

    if (entered.isEmpty) {
      return 'Enter the verification code';
    }

    if (entered != _captcha) {
      return 'Incorrect verification code';
    }

    return null;
  }

  // ============================================================
  // SUBMIT REGISTRATION
  // ============================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    /*
      TEMPORARY PROTOTYPE FLOW

      PostgreSQL registration is not connected yet.

      Once your teammate provides the backend endpoint,
      this section will send:

      {
        "name": "...",
        "email": "...",
        "password": "..."
      }

      to the backend.

      IMPORTANT:
      Password should eventually be handled by the backend
      and never stored directly in Flutter.
    */

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HealthProfilePage(
          basicData: {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'authProvider': 'email-demo',
          },
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _captchaController.dispose();

    super.dispose();
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,

      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
      ),

      prefixIcon: Icon(
        icon,
        color: const Color(0xFF2E6FF3),
      ),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor: Colors.white.withOpacity(0.65),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF2E6FF3),
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: AnimatedBlueFlow(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 24,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [

                    // ==================================================
                    // ICON
                    // ==================================================

                    const Icon(
                      Icons.app_registration,
                      size: 56,
                      color: Color(0xFF2E6FF3),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    const Text(
                      'Create Patient Record',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Create your ArthoGuard account',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // FULL NAME
                    // ==================================================

                    TextFormField(
                      controller: _nameController,

                      textCapitalization:
                          TextCapitalization.words,

                      keyboardType:
                          TextInputType.name,

                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                      ),

                      decoration: _inputDecoration(
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),

                      validator: _validateName,
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // EMAIL
                    // ==================================================

                    TextFormField(
                      controller: _emailController,

                      keyboardType:
                          TextInputType.emailAddress,

                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                      ),

                      decoration: _inputDecoration(
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                      ),

                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    TextFormField(
                      controller: _passwordController,

                      obscureText:
                          _obscurePassword,

                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                      ),

                      decoration: _inputDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline,

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },

                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,

                            color:
                                const Color(0xFF64748B),
                          ),
                        ),
                      ),

                      validator: _validatePassword,
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // PASSWORD REQUIREMENTS
                    // ==================================================

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 4,
                      ),

                      child: Text(
                        'Password must contain 8+ characters, '
                        'uppercase, lowercase, number and special character.',

                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // CONFIRM PASSWORD
                    // ==================================================

                    TextFormField(
                      controller:
                          _confirmPasswordController,

                      obscureText:
                          _obscureConfirmPassword,

                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                      ),

                      decoration: _inputDecoration(
                        label: 'Confirm Password',
                        icon: Icons.lock_reset_outlined,

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },

                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,

                            color:
                                const Color(0xFF64748B),
                          ),
                        ),
                      ),

                      validator:
                          _validateConfirmPassword,
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // CAPTCHA
                    // ==================================================

                    const Text(
                      'Verification',

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // CAPTCHA DISPLAY
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.8),

                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),

                          child: Text(
                            _captcha,

                            style:
                                const TextStyle(
                              color:
                                  Color(0xFF2E6FF3),

                              fontWeight:
                                  FontWeight.bold,

                              fontSize: 18,

                              letterSpacing: 4,
                            ),
                          ),
                        ),

                        // REFRESH
                        IconButton(
                          tooltip:
                              'Generate new code',

                          icon: const Icon(
                            Icons.refresh,
                            color:
                                Color(0xFF2E6FF3),
                          ),

                          onPressed:
                              _isLoading
                                  ? null
                                  : _generateCaptcha,
                        ),

                        // INPUT
                        Expanded(
                          child:
                              TextFormField(
                            controller:
                                _captchaController,

                            textCapitalization:
                                TextCapitalization.characters,

                            style:
                                const TextStyle(
                              color:
                                  Color(0xFF1E293B),
                            ),

                            decoration:
                                _inputDecoration(
                              label: 'Enter Code',
                              icon:
                                  Icons.verified_user_outlined,
                            ),

                            validator:
                                _validateCaptcha,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // REGISTER BUTTON
                    // ==================================================

                    SizedBox(
                      height: 56,

                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _submit,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2E6FF3),

                          disabledBackgroundColor:
                              const Color(0xFF93B4F5),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),

                        child:
                            _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,

                                    child:
                                        CircularProgressIndicator(
                                      color:
                                          Colors.white,
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Text(
                                    'Proceed to Biometric Profile',

                                    style:
                                        TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          Colors.white,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // LOGIN
                    // ==================================================

                    TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                  Navigator
                                      .pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const LoginPage(),
                                    ),
                                  );
                                },

                      child: const Text(
                        'Already Registered? Login',

                        style: TextStyle(
                          color:
                              Color(0xFF2E6FF3),
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
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