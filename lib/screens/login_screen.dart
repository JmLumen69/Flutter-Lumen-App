import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // controllers
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _idNumberCtrl = TextEditingController();
  final _sectionCtrl = TextEditingController();

  final _authService = AuthService();
  final _profileService = ProfileService();

  // state
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // palette
  static const _navy = Color(0xFF0F0A1E);
  static const _indigo = Color(0xFF2D1060);
  static const _accent = Color(0xFF8B5CF6);
  static const _errorRed = Color(0xFFEF5350);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    _idNumberCtrl.dispose();
    _sectionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await _authService.signUp(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
        await _profileService.createProfile(
          name: _nameCtrl.text,
          idNumber: _idNumberCtrl.text,
          section: _sectionCtrl.text,
        );
      } else {
        await _authService.signIn(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = AuthService.friendlyError(e));
    } catch (_) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Enter your email above first.');
      return;
    }
    try {
      await _authService.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset link sent to $email'),
          backgroundColor: _accent,
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = AuthService.friendlyError(e));
    }
  }

  void _toggleMode(bool toSignUp) {
    if (_isSignUp == toSignUp) return;
    setState(() {
      _isSignUp = toSignUp;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
    _fadeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: Stack(
        children: [
          // New Abstract Background Geometry
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _accent.withValues(alpha: 0.4), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: _indigo.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _indigo.withValues(alpha: 0.6), blurRadius: 120, spreadRadius: 60)
                ],
              ),
            ),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSegmentedControl(),
                              const SizedBox(height: 32),
                              _buildHeader(),
                              const SizedBox(height: 32),
                              _buildEmailField(),
                              const SizedBox(height: 16),
                              _buildPasswordField(),
                              if (_isSignUp) ...[
                                const SizedBox(height: 16),
                                _buildConfirmField(),
                                const SizedBox(height: 16),
                                _StyledField(
                                  controller: _nameCtrl,
                                  hint: 'Full Name',
                                  icon: Icons.person_outline,
                                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StyledField(
                                        controller: _idNumberCtrl,
                                        hint: 'ID Number',
                                        icon: Icons.badge_outlined,
                                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _StyledField(
                                        controller: _sectionCtrl,
                                        hint: 'Section',
                                        icon: Icons.class_outlined,
                                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (!_isSignUp)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _forgotPassword,
                                    child: const Text('Forgot Password?', style: TextStyle(color: _accent)),
                                  ),
                                ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _errorRed.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(_errorMessage!, style: const TextStyle(color: _errorRed)),
                                ),
                              ],
                              const SizedBox(height: 32),
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _isSignUp ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: _accent.withValues(alpha: 0.5), blurRadius: 12)
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleMode(false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: _isSignUp ? Colors.white54 : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleMode(true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: !_isSignUp ? Colors.white54 : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bolt_rounded, size: 48, color: _accent),
        ),
        const SizedBox(height: 16),
        Text(
          _isSignUp ? 'Join Lumen' : 'Welcome to Lumen',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp ? 'Unlock your productivity potential' : 'Sign in to continue to your dashboard',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() => _StyledField(
        controller: _emailCtrl,
        hint: 'Email Address',
        icon: Icons.alternate_email_rounded,
        keyboardType: TextInputType.emailAddress,
        validator: (v) => v!.contains('@') ? null : 'Invalid email',
      );

  Widget _buildPasswordField() => _StyledField(
        controller: _passwordCtrl,
        hint: 'Password',
        icon: Icons.lock_outline_rounded,
        obscure: _obscurePassword,
        toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
        validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
      );

  Widget _buildConfirmField() => _StyledField(
        controller: _confirmCtrl,
        hint: 'Confirm Password',
        icon: Icons.lock_outline_rounded,
        obscure: _obscureConfirm,
        toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
        validator: (v) => v != _passwordCtrl.text ? 'Mismatch' : null,
      );

  Widget _buildSubmitButton() {
    return InkWell(
      onTap: _isLoading ? null : _submit,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_accent, Color(0xFF6D28D9)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: _accent.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.toggleObscure,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? toggleObscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
        ),
      ),
    );
  }
}
