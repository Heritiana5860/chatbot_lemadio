import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/constants.dart';
import 'screens/splash_screen.dart';

void main() {
  // Configurer l'orientation et la barre de statut
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AdesChatbotApp());
}

class AdesChatbotApp extends StatelessWidget {
  const AdesChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: ThemeData(
        // Couleurs principales
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          error: AppColors.error,
        ),

        // Fond
        scaffoldBackgroundColor: AppColors.background,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),

        // Boutons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: AppSizes.paddingMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            elevation: 2,
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),

        // Texte
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.heading1,
          displayMedium: AppTextStyles.heading2,
          bodyLarge: AppTextStyles.body,
          bodyMedium: AppTextStyles.bodySmall,
          labelSmall: AppTextStyles.caption,
        ),

        // Polices
        fontFamily: 'Roboto',
      ),

      // Page initiale
      home: const SplashScreen(),
    );
  }
}
