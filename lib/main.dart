import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const BasmaApp());
}

class BasmaApp extends StatelessWidget {
  const BasmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بصمة - Basma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), // Arabic
      ],
      locale: const Locale('ar'),
      home: const SplashScreen(),
    );
  }
}
