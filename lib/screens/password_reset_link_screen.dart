import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'reset_password_screen.dart';

/// Laravel password recovery sends a link containing a reset token.
/// This is intentionally NOT an OTP verification screen.
class PasswordResetLinkScreen extends StatefulWidget {
  const PasswordResetLinkScreen({super.key, required this.email});
  final String email;

  @override
  State<PasswordResetLinkScreen> createState() =>
      _PasswordResetLinkScreenState();
}

class _PasswordResetLinkScreenState extends State<PasswordResetLinkScreen> {
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _resending = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await AuthService.instance.forgotPassword(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم طلب إرسال رابط جديد إلى بريدك')),
      );
    } on AuthApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(title: const Text('استعادة كلمة المرور')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.primaryOrange,
                size: 70,
              ),
              const SizedBox(height: 16),
              Text(
                'تحقق من بريدك الإلكتروني',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'أرسلنا رابط إعادة تعيين كلمة المرور إلى ${widget.email}. يمكنك فتح الرابط في المتصفح لإكمال العملية.',
              ),
              const SizedBox(height: 24),
              const Text('إذا كان لديك رمز الاستعادة من الرابط، ألصقه هنا:'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tokenController,
                autocorrect: false,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'رمز الاستعادة مطلوب'
                    : null,
                decoration: const InputDecoration(labelText: 'رمز الاستعادة'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResetPasswordScreen(
                        email: widget.email,
                        token: _tokenController.text.trim(),
                      ),
                    ),
                  );
                },
                child: const Text('متابعة إعادة تعيين كلمة المرور'),
              ),
              TextButton(
                onPressed: _resending ? null : _resend,
                child: const Text('إعادة إرسال رابط الاستعادة'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
