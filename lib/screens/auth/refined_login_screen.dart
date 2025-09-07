import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// Social login packages removed - will be added in future releases
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:local_auth/local_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../services/app_data_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../root_tab_screen.dart';
import 'register_screen.dart';

class RefinedLoginScreen extends StatefulWidget {
  const RefinedLoginScreen({super.key});

  @override
  State<RefinedLoginScreen> createState() => _RefinedLoginScreenState();
}

class _RefinedLoginScreenState extends State<RefinedLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // LocalAuthentication removed - will be added in future releases
  // final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;
  bool _hasStoredCredentials = false;
  bool _isBiometricAvailable = false;
  
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;
  late Animation<double> _buttonPulse;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkStoredCredentials();
    // _checkBiometricAvailability(); // Removed - will be implemented in future releases
  }

  void _setupAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoAnimation = CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    );
    _formAnimation = CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    );
    _buttonPulse = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formAnimationController.forward();
    });
  }

  Future<void> _checkStoredCredentials() async {
    setState(() {
      _hasStoredCredentials = true; // Mock for demo
    });
  }

  // Biometric authentication removed - will be implemented in future releases
  // Future<void> _checkBiometricAvailability() async {
  //   try {
  //     final isAvailable = await _localAuth.canCheckBiometrics;
  //     final biometrics = await _localAuth.getAvailableBiometrics();
  //     setState(() {
  //       _isBiometricAvailable = isAvailable && biometrics.isNotEmpty;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isBiometricAvailable = false;
  //     });
  //   }
  // }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    _buttonAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        final isIOS = Platform.isIOS;
        
        if (isIOS) {
          return _buildIOSLogin(store, brightness);
        } else {
          return _buildMaterialLogin(store, brightness);
        }
      },
    );
  }

  Widget _buildIOSLogin(AppDataStore store, Brightness brightness) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: _buildLoginContent(store, brightness, isIOS: true),
    );
  }

  Widget _buildMaterialLogin(AppDataStore store, Brightness brightness) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildLoginContent(store, brightness, isIOS: false),
    );
  }

  Widget _buildLoginContent(AppDataStore store, Brightness brightness, {required bool isIOS}) {
    return Container(
      decoration: BoxDecoration(
        // Enhanced gradient following PixelPro/Spotify examples
        gradient: brightness == Brightness.dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0F23), // Deep navy
                  Color(0xFF1A1A2E), // Purple-navy
                  Color(0xFF16213E), // Blue-navy
                ],
                stops: [0.0, 0.5, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFC), // Light gray
                  Color(0xFFE2E8F0), // Subtle blue-gray
                  Color(0xFFCBD5E1), // Deeper gray
                ],
                stops: [0.0, 0.5, 1.0],
              ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildBrandedHeader(brightness),
                      const SizedBox(height: 48),
                      _buildLoginForm(store, brightness, isIOS),
                      const SizedBox(height: 32),
                      _buildAlternativeSignIns(store, brightness, isIOS),
                      const SizedBox(height: 24),
                      _buildSecondaryActions(brightness),
                    ],
                  ),
                ),
              ),
              _buildFooterLinks(brightness),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced branded header with Project Watchtower logo
  Widget _buildBrandedHeader(Brightness brightness) {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoAnimation.value,
          child: Opacity(
            opacity: _logoAnimation.value.clamp(0.0, 1.0),
            child: Column(
              children: [
                // Project Watchtower Logo/Brand Mark
                Hero(
                  tag: 'app-logo',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple, Colors.pink],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.movie_filter,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Project Watchtower',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 280.0, 70.0)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Watch Together, Discover Together',
                  style: TextStyle(
                    fontSize: 16,
                    color: brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppTheme.primaryText(brightness).withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your social movie & TV discovery platform',
                  style: TextStyle(
                    fontSize: 14,
                    color: brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppTheme.primaryText(brightness).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(AppDataStore store, Brightness brightness, bool isIOS) {
    return AnimatedBuilder(
      animation: _formAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _formAnimation.value)),
          child: Opacity(
            opacity: _formAnimation.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : AppTheme.primaryText(brightness).withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryText(brightness).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome text
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: brightness == Brightness.dark
                            ? Colors.white
                            : AppTheme.primaryText(brightness),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue discovering',
                      style: TextStyle(
                        fontSize: 16,
                        color: brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : AppTheme.primaryText(brightness).withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Error message with better styling
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email field with proper labeling
                    _buildAdaptiveTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      isIOS: isIOS,
                      brightness: brightness,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field with show/hide toggle
                    _buildAdaptiveTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: _obscurePassword,
                      isIOS: isIOS,
                      brightness: brightness,
                      suffixIcon: isIOS
                          ? CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Icon(
                                _obscurePassword
                                    ? CupertinoIcons.eye_slash
                                    : CupertinoIcons.eye,
                                color: AppTheme.secondaryText(brightness),
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.secondaryText(brightness),
                              ),
                            ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Remember Me and Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isIOS)
                                CupertinoCheckbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                )
                              else
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                              Flexible(
                                child: Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : AppTheme.primaryText(brightness).withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Enhanced Login Button
                    AnimatedBuilder(
                      animation: _buttonPulse,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _buttonPulse.value,
                          child: _buildLoginButton(store, brightness, isIOS),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Biometric login if available
                    if (_isBiometricAvailable && _hasStoredCredentials) ...[
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.secondaryText(brightness).withOpacity(0.5))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.6)
                                    : AppTheme.primaryText(brightness).withOpacity(0.6),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppTheme.secondaryText(brightness).withOpacity(0.5))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildBiometricButton(store, brightness, isIOS),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdaptiveTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required bool isIOS,
    required Brightness brightness,
    String? Function(String?)? validator,
  }) {
    if (isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.9)
                  : AppTheme.primaryText(brightness).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: controller,
            placeholder: 'Enter your ${labelText.toLowerCase()}',
            keyboardType: keyboardType,
            obscureText: obscureText,
            suffix: suffixIcon,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.2)
                    : AppTheme.primaryText(brightness).withOpacity(0.2),
              ),
            ),
            style: TextStyle(
              color: brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.primaryText(brightness),
              fontSize: 16,
            ),
          ),
        ],
      );
    } else {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: 'Enter your ${labelText.toLowerCase()}',
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.3)
                  : AppTheme.primaryText(brightness).withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.white,
          labelStyle: TextStyle(
            color: brightness == Brightness.dark
                ? Colors.white.withOpacity(0.8)
                : AppTheme.primaryText(brightness).withOpacity(0.7),
          ),
          hintStyle: TextStyle(
            color: brightness == Brightness.dark
                ? Colors.white.withOpacity(0.5)
                : AppTheme.primaryText(brightness).withOpacity(0.5),
          ),
        ),
        style: TextStyle(
          color: brightness == Brightness.dark
              ? Colors.white
              : AppTheme.primaryText(brightness),
          fontSize: 16,
        ),
      );
    }
  }

  Widget _buildLoginButton(AppDataStore store, Brightness brightness, bool isIOS) {
    final isEnabled = _emailController.text.isNotEmpty && 
                     _passwordController.text.isNotEmpty &&
                     !_isLoading;

    if (isIOS) {
      return CupertinoButton(
        onPressed: isEnabled ? () => _performLogin(store) : null,
        color: isEnabled ? Colors.blue : AppTheme.secondaryText(brightness),
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      );
    } else {
      return ElevatedButton(
        onPressed: isEnabled ? () => _performLogin(store) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.blue : AppTheme.secondaryText(brightness),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 3 : 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      );
    }
  }

  Widget _buildBiometricButton(AppDataStore store, Brightness brightness, bool isIOS) {
    return Container(
      width: double.infinity,
      child: isIOS
          ? CupertinoButton(
              onPressed: () => _performBiometricLogin(store),
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.lock_shield,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Use Face ID / Touch ID',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : OutlinedButton(
              onPressed: () => _performBiometricLogin(store),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fingerprint,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Use Biometric Login',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Enhanced social login section following brand guidelines
  Widget _buildAlternativeSignIns(AppDataStore store, Brightness brightness, bool isIOS) {
    return AnimatedBuilder(
      animation: _formAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _formAnimation.value)),
          child: Opacity(
            opacity: _formAnimation.value.clamp(0.0, 1.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.secondaryText(brightness).withOpacity(0.5))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          color: brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.6)
                              : AppTheme.primaryText(brightness).withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.secondaryText(brightness).withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Branded social login buttons
                Column(
                  children: [
                    _buildSocialButton(
                      'Continue with Google',
                      Colors.white,
                      AppTheme.primaryText(brightness),
                      Icons.g_mobiledata,
                      () => _signInWithGoogle(store),
                      brightness,
                      isIOS,
                    ),
                    const SizedBox(height: 12),
                    _buildSocialButton(
                      'Continue with Apple',
                      AppTheme.primaryText(brightness),
                      Colors.white,
                      Icons.apple,
                      () => _signInWithApple(store),
                      brightness,
                      isIOS,
                    ),
                    const SizedBox(height: 12),
                    _buildSocialButton(
                      'Continue with Facebook',
                      const Color(0xFF1877F2),
                      Colors.white,
                      Icons.facebook,
                      () => _signInWithFacebook(store),
                      brightness,
                      isIOS,
                    ),
                    const SizedBox(height: 24),
                    
                    // Guest login option (as per PixelPro example)
                    _buildGuestLoginButton(store, brightness, isIOS),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButton(
    String text,
    Color backgroundColor,
    Color textColor,
    IconData icon,
    VoidCallback onPressed,
    Brightness brightness,
    bool isIOS,
  ) {
    return Container(
      width: double.infinity,
      child: isIOS
          ? CupertinoButton(
              onPressed: onPressed,
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    ).animate().fadeIn(delay: Duration(milliseconds: 200)).slideX(begin: 0.1);
  }

  Widget _buildGuestLoginButton(AppDataStore store, Brightness brightness, bool isIOS) {
    return Container(
      width: double.infinity,
      child: isIOS
          ? CupertinoButton(
              onPressed: () => _continueAsGuest(store),
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Continue as Guest',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            )
          : TextButton(
              onPressed: () => _continueAsGuest(store),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Continue as Guest',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
    );
  }

  Widget _buildSecondaryActions(Brightness brightness) {
    return AnimatedBuilder(
      animation: _formAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _formAnimation.value)),
          child: Opacity(
            opacity: _formAnimation.value.clamp(0.0, 1.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        color: brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : AppTheme.primaryText(brightness).withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Help and support as per guidelines
                TextButton(
                  onPressed: _showHelpSupport,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 16,
                        color: AppTheme.secondaryText(brightness),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Need Help?',
                        style: TextStyle(
                          color: AppTheme.secondaryText(brightness),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooterLinks(Brightness brightness) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _showPrivacyPolicy,
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.6)
                      : AppTheme.primaryText(brightness).withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                color: brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.6)
                    : AppTheme.primaryText(brightness).withOpacity(0.6),
              ),
            ),
            TextButton(
              onPressed: _showTermsOfService,
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  color: brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.6)
                      : AppTheme.primaryText(brightness).withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Action methods
  Future<void> _performLogin(AppDataStore store) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Animate button
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    try {
      HapticFeedback.lightImpact();
      
      await Future.delayed(const Duration(milliseconds: 1500)); // Mock login
      
      final success = await store.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        HapticFeedback.mediumImpact();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const RootTabScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Incorrect email or password. Please try again.';
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
      HapticFeedback.heavyImpact();
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Biometric login removed - will be implemented in future releases
  Future<void> _performBiometricLogin(AppDataStore store) async {
    try {
      // final bool didAuthenticate = await _localAuth.authenticate(
      //   localizedReason: 'Use your biometric to sign in to Project Watch Tower',
      //   options: const AuthenticationOptions(biometricOnly: true),
      // );
      final bool didAuthenticate = false; // Placeholder

      if (didAuthenticate) {
        HapticFeedback.lightImpact();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const RootTabScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Biometric authentication failed or was cancelled.';
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biometric authentication is not available.';
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _signInWithGoogle(AppDataStore store) async {
    HapticFeedback.lightImpact();
    // TODO: Implement Google Sign-In
    _showComingSoon('Google Sign-In');
  }

  Future<void> _signInWithApple(AppDataStore store) async {
    HapticFeedback.lightImpact();
    // TODO: Implement Apple Sign-In
    _showComingSoon('Apple Sign-In');
  }

  Future<void> _signInWithFacebook(AppDataStore store) async {
    HapticFeedback.lightImpact();
    // TODO: Implement Facebook Sign-In
    _showComingSoon('Facebook Sign-In');
  }

  void _continueAsGuest(AppDataStore store) {
    HapticFeedback.lightImpact();
    // Set guest mode and navigate
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RootTabScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  void _forgotPassword() {
    HapticFeedback.lightImpact();
    _showComingSoon('Password Reset');
  }

  void _navigateToRegister() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: const Text(
          'For support, please contact us at:\n\n'
          '📧 support@projectwatchtower.com\n'
          '📞 1-800-WATCHTOWER\n\n'
          'Or visit our FAQ section at projectwatchtower.com/help',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    HapticFeedback.lightImpact();
    _showComingSoon('Privacy Policy');
  }

  void _showTermsOfService() {
    HapticFeedback.lightImpact();
    _showComingSoon('Terms of Service');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
