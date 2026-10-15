import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';
import 'authenticated_screen.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  String _selectedGovernorate = '';
  String _selectedCity = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<BasmaRegion> _governorates = [];
  List<BasmaRegion> _cities = [];
  String? _regionError;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  Future<void> _loadGovernorates() async {
    try {
      final regions = await AuthService.instance.getGovernorates();
      if (mounted) {
        setState(() {
          _governorates = regions;
          _regionError = null;
        });
      }
    } on AuthApiException catch (error) {
      if (mounted) setState(() => _regionError = error.message);
    }
  }

  Future<void> _loadCities(String governorateId) async {
    setState(() {
      _selectedCity = '';
      _cities = [];
      _regionError = null;
    });
    try {
      final cities = await AuthService.instance.getCities(
        int.parse(governorateId),
      );
      if (mounted && _selectedGovernorate == governorateId) {
        setState(() => _cities = cities);
      }
    } on AuthApiException catch (error) {
      if (mounted && _selectedGovernorate == governorateId) {
        setState(() => _regionError = error.message);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على شروط الاستخدام')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      var phone = _whatsappController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (phone.startsWith('970')) {
        phone = '+$phone';
      } else {
        if (phone.startsWith('0')) phone = phone.substring(1);
        phone = '+970$phone';
      }
      final user = await AuthService.instance.register(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        whatsapp: phone,
        governorateId: int.parse(_selectedGovernorate),
        cityId: int.parse(_selectedCity),
        termsAccepted: _agreeToTerms,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => user.isEmailVerified
              ? AuthenticatedScreen(user: user)
              : VerifyEmailScreen(email: user.email),
        ),
        (_) => false,
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
      if (mounted) setState(() => _isLoading = false);
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
                      const SizedBox(height: 24),
                      _buildForm(),
                      const SizedBox(height: 16),
                      _buildFooter(),
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
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: AppColors.cream),
      child: Center(
        child: Image.asset(
          'assets/images/logo.jpeg',
          height: 56,
          width: 56,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryOrange,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('إنشاء حساب جديد', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'انضم إلى مجتمع بصمة',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkGray),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.all(20),
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
              TextFormField(
                controller: _fullNameController,
                textAlign: TextAlign.right,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الاسم الكامل مطلوب';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  hintText: 'أحمد العرابيد',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رقم واتساب مطلوب';
                  }
                  if (value.length < 9) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'رقم واتساب',
                  hintText: '٥٩٩١٢٣٤٥٦',
                  prefixIcon: const Icon(
                    Icons.phone_android_outlined,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                  prefix: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+970',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkGray,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.mediumGray,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.right,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'البريد الإلكتروني مطلوب';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  hintText: 'example@email.com',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textAlign: TextAlign.right,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'كلمة المرور مطلوبة';
                  }
                  if (value.length < 8) {
                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  hintText: '••••••••',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.mediumGray,
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (_passwordController.text.isNotEmpty &&
                  _passwordController.text.length < 8)
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
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textAlign: TextAlign.right,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'تأكيد كلمة المرور مطلوب';
                  }
                  if (value != _passwordController.text) {
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedGovernorate.isEmpty
                    ? null
                    : _selectedGovernorate,
                hint: const Text('اختر المحافظة'),
                items: _governorates.map((BasmaRegion region) {
                  return DropdownMenuItem<String>(
                    value: region.id.toString(),
                    child: Text(region.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGovernorate = newValue ?? '';
                    _selectedCity = '';
                  });
                  if (newValue != null) _loadCities(newValue);
                },
                decoration: const InputDecoration(
                  labelText: 'المحافظة',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'المحافظة مطلوبة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity.isEmpty ? null : _selectedCity,
                hint: const Text('اختر المدينة/الحي'),
                items: _selectedGovernorate.isNotEmpty
                    ? _cities.map((BasmaRegion region) {
                        return DropdownMenuItem<String>(
                          value: region.id.toString(),
                          child: Text(region.name),
                        );
                      }).toList()
                    : [],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCity = newValue ?? '';
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'المدينة/الحي',
                  prefixIcon: Icon(
                    Icons.home_outlined,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'المدينة/الحي مطلوب';
                  }
                  return null;
                },
              ),
              if (_regionError != null)
                Text(
                  _regionError!,
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: AppColors.primaryOrange,
                    checkColor: AppColors.white,
                    side: const BorderSide(
                      color: AppColors.outlineVariant,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'أوافق على ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.mediumGray,
                        ),
                        children: [
                          TextSpan(
                            text: 'شروط الاستخدام',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' و ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.mediumGray,
                            ),
                          ),
                          TextSpan(
                            text: 'سياسة الخصوصية',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
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
                      : const Text('إنشاء الحساب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب؟',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mediumGray),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: _navigateToLogin,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryOrange,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('تسجيل الدخول'),
        ),
      ],
    );
  }
}
