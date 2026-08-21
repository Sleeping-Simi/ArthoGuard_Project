import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
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

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  StreamSubscription<GoogleSignInAuthenticationEvent>?
      _googleAuthSubscription;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _googleInitialized = false;

  // ============================================================
  // GOOGLE WEB CLIENT ID
  // ============================================================

  static const String _webClientId =
      '603200734835-repk0v9ricijms50bgbpr92gll2omc51.apps.googleusercontent.com';

  // Prevent Google Sign-In from being initialized multiple times.
  static Future<void>? _googleInitializationFuture;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _initializeGoogleSignIn();
  }

  // ============================================================
  // GOOGLE SIGN-IN INITIALIZATION
  // ============================================================

  Future<void> _initializeGoogleSignIn() async {
    try {
      _googleInitializationFuture ??=
          GoogleSignIn.instance.initialize(
        serverClientId: _webClientId,
      );

      await _googleInitializationFuture;

      if (!mounted) return;

      _googleAuthSubscription =
          GoogleSignIn.instance.authenticationEvents.listen(
        _handleGoogleAuthenticationEvent,
        onError: _handleGoogleAuthenticationError,
      );

      setState(() {
        _googleInitialized = true;
      });

      debugPrint(
        'Google Sign-In initialized successfully.',
      );
    } catch (e) {
      debugPrint(
        'Google Sign-In initialization failed: $e',
      );

      if (!mounted) return;

      setState(() {
        _googleInitialized = false;
      });
    }
  }

  // ============================================================
  // CHECK WHETHER HEALTH PROFILE IS ALREADY COMPLETED
  // ============================================================

  Future<bool> _isHealthProfileCompleted() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          'health_profile_completed',
        ) ??
        false;
  }

  // ============================================================
  // GET SAVED USER INFORMATION
  // ============================================================

  Future<Map<String, dynamic>> _getSavedUserData({
    String? fallbackName,
    String? fallbackEmail,
    String? authProvider,
  }) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final String name =
        prefs.getString('logged_in_name') ??
            fallbackName ??
            'ArthoGuard User';

    final String email =
        prefs.getString('logged_in_email') ??
            fallbackEmail ??
            '';

    return {
      'name': name,
      'patientName': name,
      'email': email,
      'authProvider':
          authProvider ??
          prefs.getString('authProvider') ??
          'unknown',
    };
  }

  // ============================================================
  // SAVE CURRENT LOGIN INFORMATION
  // ============================================================

  Future<void> _saveLoginInformation({
    required String name,
    required String email,
    required String authProvider,
  }) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'logged_in_name',
      name,
    );

    await prefs.setString(
      'logged_in_email',
      email,
    );

    await prefs.setString(
      'authProvider',
      authProvider,
    );
  }

  // ============================================================
  // NAVIGATION AFTER SUCCESSFUL LOGIN
  // ============================================================

  Future<void> _navigateAfterLogin({
    required String name,
    required String email,
    required String authProvider,
  }) async {
    if (!mounted) return;

    await _saveLoginInformation(
      name: name,
      email: email,
      authProvider: authProvider,
    );

    final bool profileCompleted =
        await _isHealthProfileCompleted();

    if (!mounted) return;

    final Map<String, dynamic> userData =
        await _getSavedUserData(
      fallbackName: name,
      fallbackEmail: email,
      authProvider: authProvider,
    );

    if (!mounted) return;

    if (profileCompleted) {
      // ========================================================
      // RETURNING USER
      // ========================================================
      //
      // The user has already completed the health profile.
      // DO NOT SHOW HEALTH PROFILE AGAIN.
      //
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            userData: userData,
          ),
        ),
      );
    } else {
      // ========================================================
      // NEW USER
      // ========================================================
      //
      // First successful login -> Health Profile.
      //
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HealthProfilePage(
            basicData: userData,
          ),
        ),
      );
    }
  }

  // ============================================================
  // GOOGLE AUTHENTICATION EVENT
  // ============================================================

  Future<void> _handleGoogleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event
        is GoogleSignInAuthenticationEventSignIn) {
      final GoogleSignInAccount account =
          event.user;

      debugPrint(
        '========================================',
      );

      debugPrint(
        'GOOGLE LOGIN SUCCESS',
      );

      debugPrint(
        'Name: ${account.displayName}',
      );

      debugPrint(
        'Email: ${account.email}',
      );

      debugPrint(
        '========================================',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final String name =
          account.displayName?.trim().isNotEmpty == true
              ? account.displayName!.trim()
              : 'Google User';

      await _navigateAfterLogin(
        name: name,
        email: account.email,
        authProvider: 'google',
      );
    }
  }

  // ============================================================
  // GOOGLE ERROR
  // ============================================================

  void _handleGoogleAuthenticationError(
    Object error,
  ) {
    debugPrint(
      'Google authentication error: $error',
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Google Sign-In failed: $error',
        ),
      ),
    );
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  String? _validateEmail(String? value) {
    final String email =
        value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email address is required';
    }

    final RegExp emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  String? _validatePassword(String? value) {
    final String password =
        value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    /*
      IMPORTANT:

      Your current email/password backend is not connected yet.

      Therefore this section intentionally does NOT pretend that
      the credentials were authenticated.

      Once your backend login API is connected, call:

        _navigateAfterLogin(
          name: userNameFromBackend,
          email: email,
          authProvider: 'email',
        );

      after the backend confirms the credentials.
    */

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Email authentication is not connected yet.',
        ),
      ),
    );
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _continueWithGoogle() async {
    if (!_googleInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Sign-In is still initializing. Please try again.',
          ),
        ),
      );

      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final GoogleSignIn googleSignIn =
          GoogleSignIn.instance;

      if (!googleSignIn.supportsAuthenticate()) {
        throw Exception(
          'Google authentication is not supported on this platform.',
        );
      }

      await googleSignIn.authenticate();

      /*
        DO NOT NAVIGATE HERE.

        The authentication event listener receives the
        successful Google account and calls:

          _navigateAfterLogin()

        which decides:

        NEW USER
          -> Health Profile

        RETURNING USER
          -> Dashboard
      */
    } on GoogleSignInException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint(
        'Google Sign-In exception: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In failed: '
            '${e.description ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint(
        'Google Sign-In error: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In failed: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  void _register() {
    if (_isLoading) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const RegisterPage(),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _googleAuthSubscription?.cancel();

    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
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
              padding:
                  const EdgeInsets.all(32),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [

                    // ==================================================
                    // LOGO
                    // ==================================================

                    Container(
                      padding:
                          const EdgeInsets.all(22),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white
                                .withOpacity(0.6),
                        shape:
                            BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.shield,
                        size: 64,
                        color:
                            Color(0xFF2E6FF3),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    const Text(
                      'ArthoGuard AI',
                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Clinical Knee Recovery & ROM Analytics',
                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color:
                            Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ==================================================
                    // EMAIL
                    // ==================================================

                    TextFormField(
                      controller:
                          _emailController,

                      keyboardType:
                          TextInputType
                              .emailAddress,

                      textInputAction:
                          TextInputAction.next,

                      style:
                          const TextStyle(
                        color:
                            Color(0xFF1E293B),
                      ),

                      decoration:
                          InputDecoration(
                        labelText:
                            'Email Address',

                        labelStyle:
                            const TextStyle(
                          color:
                              Color(0xFF64748B),
                        ),

                        prefixIcon:
                            const Icon(
                          Icons
                              .email_outlined,
                          color:
                              Color(0xFF2E6FF3),
                        ),

                        filled: true,

                        fillColor:
                            Colors.white
                                .withOpacity(0.6),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),

                      validator:
                          _validateEmail,
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    TextFormField(
                      controller:
                          _passwordController,

                      obscureText:
                          _obscurePassword,

                      textInputAction:
                          TextInputAction.done,

                      style:
                          const TextStyle(
                        color:
                            Color(0xFF1E293B),
                      ),

                      decoration:
                          InputDecoration(
                        labelText:
                            'Password',

                        labelStyle:
                            const TextStyle(
                          color:
                              Color(0xFF64748B),
                        ),

                        prefixIcon:
                            const Icon(
                          Icons
                              .lock_outline,
                          color:
                              Color(0xFF2E6FF3),
                        ),

                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },

                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,

                            color:
                                const Color(
                              0xFF64748B,
                            ),
                          ),
                        ),

                        filled: true,

                        fillColor:
                            Colors.white
                                .withOpacity(0.6),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),

                      validator:
                          _validatePassword,
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // EMAIL LOGIN BUTTON
                    // ==================================================

                    SizedBox(
                      height: 56,

                      child:
                          ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _login,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF2E6FF3,
                          ),

                          disabledBackgroundColor:
                              const Color(
                            0xFF93B4F5,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
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
                                    'Sign In to Clinical Dashboard',

                                    style:
                                        TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color:
                                          Colors.white,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // OR DIVIDER
                    // ==================================================

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color:
                                Colors.white
                                    .withOpacity(
                              0.5,
                            ),
                          ),
                        ),

                        const Padding(
                          padding:
                              EdgeInsets
                                  .symmetric(
                            horizontal: 14,
                          ),

                          child: Text(
                            'OR',

                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFF64748B,
                              ),
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Divider(
                            color:
                                Colors.white
                                    .withOpacity(
                              0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // GOOGLE LOGIN
                    // ==================================================

                    SizedBox(
                      height: 54,

                      child:
                          OutlinedButton.icon(
                        onPressed:
                            _isLoading
                                ? null
                                : _continueWithGoogle,

                        icon:
                            const Icon(
                          Icons
                              .account_circle_outlined,
                          color:
                              Colors.black87,
                        ),

                        label:
                            const Text(
                          'Continue with Google',

                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF1E293B,
                            ),
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        style:
                            OutlinedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.white
                                  .withOpacity(
                            0.75,
                          ),

                          disabledBackgroundColor:
                              Colors.white
                                  .withOpacity(
                            0.45,
                          ),

                          side:
                              BorderSide(
                            color:
                                Colors.white
                                    .withOpacity(
                              0.8,
                            ),
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // REGISTER
                    // ==================================================

                    TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _register,

                      child:
                          const Text(
                        "Don't have an account? Register Here",

                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF2E6FF3,
                          ),
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