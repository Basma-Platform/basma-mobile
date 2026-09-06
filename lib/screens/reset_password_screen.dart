import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // TODO: Implement actual reset password logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _navigateToLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildWelcomeSection(),
                      const SizedBox(height: 32),
                      _buildForm(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: AppColors.cream),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: _navigateBack,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryOrange,
                size: 28,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                hoverColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Logo
          Image.asset(
            'assets/images/logo.jpeg',
            height: 40,
            width: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryOrange,
                  size: 24,
                ),
              );
            },
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إعادة تعيين كلمة المرور', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'أدخل كلمة المرور الجديدة لحساب ${widget.email}',
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkGray),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // New Password
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            textAlign: TextAlign.right,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'كلمة المرور الجديدة مطلوبة';
              }
              if (value.length < 8) {
                return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'كلمة المرور الجديدة',
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primaryOrange,
                size: 20,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.mediumGray,
                  size: 20,
                ),
              ),
            ),
          ),
          if (_newPasswordController.text.isNotEmpty &&
              _newPasswordController.text.length < 8)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warningYellow,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'يجب أن تحتوي على 8 أحرف على الأقل',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warningYellow,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textAlign: TextAlign.right,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'تأكيد كلمة المرور مطلوب';
              }
              if (value != _newPasswordController.text) {
                return 'كلمة المرور غير متطابقة';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primaryOrange,
                size: 20,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.mediumGray,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppColors.primaryOrange.withValues(alpha: 0.3),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('تغيير كلمة المرور'),
            ),
          ),
        ],
      ),
    );
  }
}
