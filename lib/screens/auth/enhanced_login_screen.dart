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

class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;
  
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formAnimationController.forward();
    });
  }

  Future<void> _checkStoredCredentials() async {
    // Check if we have stored credentials for biometric login
    // This would typically check SharedPreferences or secure storage
    setState(() {
      // _hasStoredCredentials = true; // Mock for demo - removed as variable doesn't exist
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
      backgroundColor: AppTheme.appBackground(brightness),
      child: SafeArea(
        child: _buildLoginContent(store, brightness, isIOS: true),
      ),
    );
  }

  Widget _buildMaterialLogin(AppDataStore store, Brightness brightness) {
    return Scaffold(
      backgroundColor: AppTheme.appBackground(brightness),
      body: SafeArea(
        child: _buildLoginContent(store, brightness, isIOS: false),
      ),
    );
  }

  Widget _buildLoginContent(AppDataStore store, Brightness brightness, {required bool isIOS}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brightness == Brightness.dark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFEEF2F3),
                  const Color(0xFFF8FAFC),
                  const Color(0xFFFFFFFF),
                ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                       MediaQuery.of(context).padding.top - 
                       MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Animated Logo Section
              _buildAnimatedLogo(brightness),
              
              const SizedBox(height: 60),
              
              // Login Form
              _buildLoginForm(store, brightness, isIOS: isIOS),
              
              const SizedBox(height: 40),
              
              // Social Login Section
              _buildSocialLogins(brightness),
              
              const SizedBox(height: 30),
              
              // Biometric Login - Coming in future releases
              
              const SizedBox(height: 40),
              
              // Footer Links
              _buildFooterLinks(brightness),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(Brightness brightness) {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoAnimation.value,
          child: Column(
            children: [
              Hero(
                tag: 'app-logo',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryText(brightness).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.movie_creation_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ).animate().shimmer(
                  duration: const Duration(seconds: 2),
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Project Watch Tower',
                style: AppTheme.largeTitle.copyWith(
                  color: AppTheme.primaryText(brightness),
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
              const SizedBox(height: 8),
              Text(
                'Watch together, discover together',
                style: AppTheme.body.copyWith(
                  color: AppTheme.secondaryText(brightness),
                ),
              ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(AppDataStore store, Brightness brightness, {required bool isIOS}) {
    return AnimatedBuilder(
      animation: _formAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _formAnimation.value)),
          child: Opacity(
            opacity: _formAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : AppTheme.primaryText(brightness).withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryText(brightness).withOpacity(0.05),
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
                    // Email Field
                    _buildEmailField(brightness, isIOS: isIOS),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    _buildPasswordField(brightness, isIOS: isIOS),
                    const SizedBox(height: 16),
                    
                    // Remember Me & Forgot Password
                    _buildRememberMeRow(brightness, isIOS: isIOS),
                    const SizedBox(height: 24),
                    
                    // Error Message
                    if (_errorMessage != null)
                      _buildErrorMessage(brightness),
                    
                    // Login Button
                    _buildLoginButton(store, brightness),
                    const SizedBox(height: 16),
                    
                    // Guest Login
                    _buildGuestLoginButton(store, brightness, isIOS: isIOS),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailField(Brightness brightness, {required bool isIOS}) {
    if (isIOS) {
      return CupertinoTextField(
        controller: _emailController,
        placeholder: 'Email Address',
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        style: AppTheme.body.copyWith(
          color: AppTheme.primaryText(brightness),
        ),
        decoration: BoxDecoration(
          color: AppTheme.minimalSurface(brightness),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.minimalStroke(brightness),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.md),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(
            CupertinoIcons.mail,
            color: AppTheme.secondaryText(brightness),
            size: 20,
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        style: AppTheme.body.copyWith(
          color: AppTheme.primaryText(brightness),
        ),
        decoration: InputDecoration(
          labelText: 'Email Address',
          hintText: 'Enter your email',
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppTheme.secondaryText(brightness),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.minimalStroke(brightness),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.minimalStroke(brightness),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF667EEA),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppTheme.minimalSurface(brightness),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      );
    }
  }

  Widget _buildPasswordField(Brightness brightness, {required bool isIOS}) {
    if (isIOS) {
      return CupertinoTextField(
        controller: _passwordController,
        placeholder: 'Password',
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        style: AppTheme.body.copyWith(
          color: AppTheme.primaryText(brightness),
        ),
        decoration: BoxDecoration(
          color: AppTheme.minimalSurface(brightness),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.minimalStroke(brightness),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.md),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(
            CupertinoIcons.lock,
            color: AppTheme.secondaryText(brightness),
            size: 20,
          ),
        ),
        suffix: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              color: AppTheme.secondaryText(brightness),
              size: 20,
            ),
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        style: AppTheme.body.copyWith(
          color: AppTheme.primaryText(brightness),
        ),
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icon(
            Icons.lock_outline,
            color: AppTheme.secondaryText(brightness),
          ),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.secondaryText(brightness),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.minimalStroke(brightness),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.minimalStroke(brightness),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF667EEA),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppTheme.minimalSurface(brightness),
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
        onFieldSubmitted: (_) => _handleLogin(context.read<AppDataStore>()),
      );
    }
  }

  Widget _buildRememberMeRow(Brightness brightness, {required bool isIOS}) {
    return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (isIOS)
          CupertinoSwitch(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value),
            activeColor: const Color(0xFF667EEA),
          )
        else
          Checkbox(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
            activeColor: const Color(0xFF667EEA),
          ),
        const SizedBox(width: 8),
        Text(
          'Remember me',
          style: AppTheme.callout.copyWith(
            color: AppTheme.primaryText(brightness),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showForgotPassword,
          child: Text(
            'Forgot Password?',
            style: AppTheme.callout.copyWith(
              color: const Color(0xFF667EEA),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(Brightness brightness) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              style: AppTheme.callout.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(AppDataStore store, Brightness brightness) {
    final isValid = _emailController.text.isNotEmpty && 
                   _passwordController.text.isNotEmpty;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: PrimaryButton(
        title: _isLoading ? 'Signing In...' : 'Sign In',
        onPressed: isValid && !_isLoading ? () => _handleLogin(store) : null,
        isLoading: _isLoading,
        height: 56,
        icon: _isLoading ? null : Icons.login,
        backgroundColor: const Color(0xFF667EEA),
      ).animate(target: isValid ? 1 : 0).scaleXY(
        begin: 0.95,
        end: 1.0,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }

  Widget _buildGuestLoginButton(AppDataStore store, Brightness brightness, {required bool isIOS}) {
    if (isIOS) {
      return CupertinoButton(
        onPressed: () => _handleGuestLogin(store),
        child: Text(
          'Continue as Guest',
          style: AppTheme.callout.copyWith(
            color: AppTheme.secondaryText(brightness),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return TextButton(
        onPressed: () => _handleGuestLogin(store),
        child: Text(
          'Continue as Guest',
          style: AppTheme.callout.copyWith(
            color: AppTheme.secondaryText(brightness),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  Widget _buildSocialLogins(Brightness brightness) {
    return Column(
      children: [
        // Improved divider with better spacing
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: Divider(color: AppTheme.minimalDivider(brightness))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: AppTheme.caption1.copyWith(
                    overflow: TextOverflow.ellipsis,
                    color: AppTheme.secondaryText(brightness),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppTheme.minimalDivider(brightness))),
            ],
          ),
        ),
        const SizedBox(height: 24), // Increased spacing
        
        // Improved button layout with better spacing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Google Sign In (Placeholder)
              Expanded(
                child: _buildSocialButton(
                  onTap: () => _showComingSoonMessage('Google Sign In'),
                  icon: Icons.g_mobiledata,
                  label: 'Google',
                  color: const Color(0xFF4285F4),
                  brightness: brightness,
                  isPlaceholder: true,
                ),
              ),
              const SizedBox(width: 16), // Increased spacing between buttons
              
              // Apple Sign In (Placeholder - iOS only)
              if (Platform.isIOS)
                Expanded(
                  child: _buildSocialButton(
                    onTap: () => _showComingSoonMessage('Apple Sign In'),
                    icon: Icons.apple,
                    label: 'Apple',
                    color: brightness == Brightness.dark ? Colors.white : AppTheme.primaryText(brightness),
                    brightness: brightness,
                    isPlaceholder: true,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
    required Brightness brightness,
    bool isPlaceholder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12), // Increased padding
        decoration: BoxDecoration(
          color: isPlaceholder 
              ? AppTheme.minimalSurface(brightness).withOpacity(0.7) // Increased opacity for better visibility
              : AppTheme.minimalSurface(brightness),
          borderRadius: BorderRadius.circular(14), // Slightly larger radius
          border: Border.all(
            color: isPlaceholder
                ? AppTheme.minimalStroke(brightness).withOpacity(0.7) // Increased opacity
                : AppTheme.minimalStroke(brightness),
            width: 1.5, // Slightly thicker border
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryText(brightness).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isPlaceholder ? color.withOpacity(0.7) : color, // Increased opacity
              size: 26 // Slightly larger icon
            ),
            const SizedBox(height: 10), // Increased spacing
            Text(
              label,
              style: AppTheme.caption1.copyWith(
                    overflow: TextOverflow.ellipsis,
                color: isPlaceholder 
                    ? AppTheme.primaryText(brightness).withOpacity(0.7) // Increased opacity
                    : AppTheme.primaryText(brightness),
                fontWeight: FontWeight.w600,
                fontSize: 13, // Slightly larger text
              ),
            ),
            if (isPlaceholder) ...[
              const SizedBox(height: 6), // Increased spacing
              Text(
                'Coming Soon',
                style: AppTheme.caption2.copyWith(
                  color: AppTheme.secondaryText(brightness),
                  fontStyle: FontStyle.italic,
                  fontSize: 11, // Slightly larger text
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().scale(
      duration: const Duration(milliseconds: 150), // Slightly longer animation
      curve: Curves.easeInOut,
    );
  }

  // Biometric login widget removed - will be implemented in future releases

  Widget _buildFooterLinks(Brightness brightness) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              'Don\'t have an account? ',
              style: AppTheme.caption1.copyWith(
                    overflow: TextOverflow.ellipsis,
                color: AppTheme.secondaryText(brightness),
              ),
            ),
            GestureDetector(
              onTap: _navigateToSignUp,
              child: Text(
                'Sign Up',
                style: AppTheme.caption1.copyWith(
                    overflow: TextOverflow.ellipsis,
                  color: const Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            _buildFooterLink('Privacy Policy', () {}),
            Text(' • ', style: TextStyle(color: AppTheme.secondaryText(brightness))),
            _buildFooterLink('Terms of Service', () {}),
            Text(' • ', style: TextStyle(color: AppTheme.secondaryText(brightness))),
            _buildFooterLink('Need Help?', _showHelpDialog),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        return GestureDetector(
          onTap: onTap,
          child: Text(
            text,
            style: AppTheme.caption1.copyWith(
                    overflow: TextOverflow.ellipsis,
              color: AppTheme.secondaryText(store.brightness),
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }

  // Authentication Methods
  Future<void> _handleLogin(AppDataStore store) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      HapticFeedback.lightImpact();
      
      await Future.delayed(const Duration(milliseconds: 1500)); // Simulate network
      
      final success = await store.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        HapticFeedback.lightImpact();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const RootTabScreen()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password. Please try again.';
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showComingSoonMessage(String feature) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon! 🚀'),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Biometric login will be implemented in future releases

  Future<void> _handleGuestLogin(AppDataStore store) async {
    HapticFeedback.selectionClick();
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const RootTabScreen()),
      (route) => false,
    );
  }

  // Navigation Methods
  void _navigateToSignUp() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  // Dialog Methods
  void _showForgotPassword() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text('Password reset functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature is coming soon! Stay tuned for updates.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: const Text(
          'Having trouble signing in?\n\n'
          '• Check your internet connection\n'
          '• Verify your email and password\n'
          '• Contact support@fwb.app\n\n'
          'We\'re here to help!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
