import 'dart:async';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

/// Écran de démarrage avec vérification de la connexion
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ApiService _apiService = ApiService();

  String _statusMessage = 'Initialisation...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Animation de fade in
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Vérifier la connexion au backend
    _checkConnection();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    // Attendre un peu pour l'animation
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _statusMessage = 'Connexion au serveur...';
    });

    try {
      // Vérifier la santé du backend
      final health = await _apiService.checkHealth();

      final backendStatus = health['backend'] == 'running';
      final ragStatus = health['rag'] == 'ok';

      debugPrint("Health check: $health");
      debugPrint("Backend status: $backendStatus, RAG status: $ragStatus");

      if (backendStatus) {
        if (ragStatus) {
          setState(() {
            _statusMessage = 'Système RAG complet prêt !';
          });
        } else {
          setState(() {
            // Le serveur est là, mais le RAG ne l'est pas (message informatif)
            _statusMessage = 'Serveur opérationnel, mais RAG désactivé.';
          });
        }

        // Attendre un peu puis naviguer
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } else {
        // Le serveur a répondu, mais il n'est pas en état 'running'
        _showError('Le serveur est inactif ou en erreur.');
      }
    } catch (e) {
      // Erreur de connexion (Timeout, Socket, etc.)
      _showError('Impossible de se connecter au serveur.');
    }
  }

  void _showError(String message) {
    debugPrint('SPLASH ERROR: $message');
    setState(() {
      // Fournir le contexte de l'URL pour faciliter le débogage
      _statusMessage = '$message\n(Vérifiez l\'URL: ${ApiService.baseUrl})';
      _hasError = true;
    });
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _statusMessage = 'Nouvelle tentative...';
    });
    _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo ou icône
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.2,
                        ), // Utilisation correcte de withOpacity
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Titre
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.paddingSmall),

                // Sous-titre
                const Text(
                  AppStrings.appSubtitle,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Statut et indicateur
                if (!_hasError) ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                ],

                // Message de statut
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: _hasError ? AppColors.error : Colors.white,
                    fontWeight: _hasError ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Bouton réessayer
                if (_hasError) ...[
                  const SizedBox(height: AppSizes.paddingMedium),
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingLarge,
                        vertical: AppSizes.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      'Continuer sans connexion',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],

                const SizedBox(height: AppSizes.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
