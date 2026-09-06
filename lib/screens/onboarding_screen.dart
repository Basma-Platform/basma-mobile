import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'تبادل بسهولة',
      subtitle: 'شارك واحصل على ما تحتاج',
      description:
          'اعرض سلعتك أو خدمتك، وابحث عن ما يلبي احتياجاتك في مكان واحد موثوق',
      imagePath: 'assets/images/step_01.png',
    ),
    OnboardingPage(
      title: 'مجتمع موثوق',
      subtitle: 'تعامل بأمان وثقة',
      description:
          'جميع المستخدمين موثقون، مع نظام تقييمات شفاف يضمن لك تجربة آمنة وموثوقة',
      imagePath: 'assets/images/step_02.png',
    ),
    OnboardingPage(
      title: 'تواصل بسرعة',
      subtitle: 'تواصل فوري ومباشر',
      description:
          'تواصل مباشر مع الآخرين عبر واتساب، واتفق على التفاصيل بكل سهولة وسرعة',
      imagePath: 'assets/images/step_03.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _skipOnboarding() {
    _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            // Page View
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _pages.asMap().entries.map((entry) {
                final index = entry.key;
                final page = entry.value;
                return OnboardingPageWidget(
                  page: page,
                  isFirstPage: index == 0,
                  isLastPage: index == _pages.length - 1,
                  animation: _fadeAnimation,
                );
              }).toList(),
            ),
            // Skip button visible only before the final onboarding page
            if (_currentPage < _pages.length - 1)
              Positioned(
                top: 16,
                right: 24,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'تخطي',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ),
              ),
            // Bottom controls
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 32 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _currentPage == index
                                ? AppColors.primaryOrange
                                : AppColors.lightBrown,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons row - Dynamic based on page
                    Row(
                      children: [
                        // Previous button - Only show on page 2 and 3
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _goToPreviousPage,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primaryOrange,
                                ),
                                foregroundColor: AppColors.primaryOrange,
                                backgroundColor: Colors.transparent,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('السابق'),
                            ),
                          ),
                        // Spacer when previous is hidden
                        if (_currentPage == 0) const SizedBox(width: 0),
                        const SizedBox(width: 10),
                        // Next/Start button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _goToNextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: AppColors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                              shadowColor: AppColors.primaryOrange.withValues(
                                alpha: 0.3,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'ابدأ الآن'
                                  : 'التالي',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final bool isFirstPage;
  final bool isLastPage;
  final Animation<double> animation;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    this.isFirstPage = false,
    this.isLastPage = false,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          // Title with animation
          FadeTransition(
            opacity: animation,
            child: Text(
              page.title,
              style: AppTextStyles.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Image with scale animation
          FadeTransition(
            opacity: animation,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.9, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    page.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primaryOrange.withValues(alpha: 0.05),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: AppColors.primaryOrange.withValues(alpha: 0.5),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Subtitle
          FadeTransition(
            opacity: animation,
            child: Text(
              page.subtitle,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // Description
          FadeTransition(
            opacity: animation,
            child: Text(
              page.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mediumGray,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
