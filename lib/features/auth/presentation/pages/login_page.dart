import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import 'package:fk_salesman/features/auth/presentation/providers/auth_provider.dart';
import 'package:fk_salesman/core/utils/session_manager.dart';
import 'package:fk_salesman/core/widgets/app_alert.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _phoneController = TextEditingController();
  String? _errorText;
  String _selectedClient = 'laxmipratima';

  @override
  void initState() {
    super.initState();
    _selectedClient = 'laxmipratima';
    SessionManager.setClient('laxmipratima');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  Future<void> _validateAndNavigate() async {
    if (_phoneController.text.length != 10) {
      setState(() {
        _errorText = 'Please enter a valid 10-digit number';
      });
      return;
    }

    setState(() => _errorText = null);
    
    final authProvider = context.read<AuthProvider>();
    authProvider.setPhoneNumber(_phoneController.text);
    
    final success = await authProvider.sendOtp();
    if (success && mounted) {
      await AppAlert.showSuccess(
        context,
        message: 'OTP sent successfully!',
      );
      if (mounted) {
        context.push('/otp', extra: _phoneController.text);
      }
    } else if (!success && mounted) {
      AppAlert.showError(
        context,
        message: authProvider.error ?? 'Something went wrong',
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background subtle design elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.03),
              ),
            ),
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // Branding Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logoo.png',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'FK SALESMAN',
                              style: TextStyle(
                                letterSpacing: 6,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 30,
                              height: 2,
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Login Content Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: AppColors.primary.withOpacity(0.08), width: 1.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Welcome Back',
                              style: AppTextStyles.h1.copyWith(color: AppColors.textDark, fontSize: 28),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Enter your mobile number to get started',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.black45,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Client / Station Selector
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.business_rounded, color: AppColors.primary, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'SELECT STATION',
                                      style: AppTextStyles.labelBold.copyWith(
                                        color: AppColors.primary,
                                        letterSpacing: 1.2,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FB),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedClient,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.primary,
                                      ),
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      dropdownColor: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'laxmipratima',
                                          child: Text('Laxmi Pratima'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'shaktiksk',
                                          child: Text('Shakti KSK'),
                                        ),
                                      ],
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedClient = newValue;
                                          });
                                          SessionManager.setClient(newValue);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Phone Input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.phone_android_rounded, color: AppColors.primary, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'MOBILE NUMBER',
                                      style: AppTextStyles.labelBold.copyWith(
                                        color: AppColors.primary,
                                        letterSpacing: 1.2,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 56,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FB),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            '+91',
                                            style: TextStyle(
                                              color: AppColors.textDark,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: AppColors.primary.withOpacity(0.5),
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                        onChanged: (value) {
                                          if (_errorText != null) {
                                            setState(() => _errorText = null);
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: '00000 00000',
                                          errorText: _errorText,
                                          counterText: "",
                                          filled: true,
                                          fillColor: const Color(0xFFF8F9FB),
                                          errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
                                          hintStyle: TextStyle(color: Colors.black26, letterSpacing: 1),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 38),

                            isLoading 
                              ? const Column(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Authenticating...',
                                      style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _validateAndNavigate,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: AppColors.primary.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('SEND OTP', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w900, fontSize: 14)),
                                        SizedBox(width: 12),
                                        Icon(Icons.arrow_forward_rounded, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.black38,
                              height: 1.6,
                              fontSize: 12,
                            ),
                            children: [
                              const TextSpan(text: 'By signing in, you agree to our\n'),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: AppColors.primary.withOpacity(0.8),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const TextSpan(text: ' and  '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primary.withOpacity(0.8),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
