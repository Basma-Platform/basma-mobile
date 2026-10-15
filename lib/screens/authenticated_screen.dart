import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

/// Minimal authenticated landing until the platform's actual feature screens exist.
class AuthenticatedScreen extends StatefulWidget {
  const AuthenticatedScreen({super.key, required this.user});
  final BasmaUser user;

  @override
  State<AuthenticatedScreen> createState() => _AuthenticatedScreenState();
}

class _AuthenticatedScreenState extends State<AuthenticatedScreen> {
  bool _loading = false;

  Future<void> _logout() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on AuthApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(title: const Text('بصمة')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 60,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(height: 16),
            Text(
              'مرحبًا ${widget.user.name}',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(widget.user.email),
            const SizedBox(height: 24),
            const Text(
              'تم تسجيل الدخول. ستتوفر خدمات المنصة في التحديثات القادمة.',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _logout,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    ),
  );
}
