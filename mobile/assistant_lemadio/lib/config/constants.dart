import 'package:flutter/material.dart';

/// Couleurs de l'application Lemadio ADES
class AppColors {
  // Couleurs primaires ADES
  static const Color primary = Color(0xFF2E7D32); // Vert ADES
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);

  // Couleurs pour les messages
  static const Color userMessage = Color(0xFF2196F3); // Bleu pour utilisateur
  static const Color botMessage = Color(0xFFE8E8E8); // Gris clair pour bot

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;

  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Fond
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
}

/// Tailles et espacements
class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;

  static const double iconSize = 24.0;
  static const double iconSizeSmall = 18.0;
  static const double iconSizeLarge = 32.0;
}

/// Styles de texte
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle messageUser = TextStyle(
    fontSize: 16,
    color: AppColors.textLight,
  );

  static const TextStyle messageBot = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
}

/// Messages de l'application
class AppStrings {
  static const String appName = 'ADES Formation Bot';
  static const String appSubtitle = 'Assistant pour l\'application de vente';

  // Écran d'accueil
  static const String welcomeTitle = 'Bienvenue !';
  static const String welcomeMessage =
      'Je suis votre assistant pour apprendre à utiliser l\'application Lemadio. '
      'Posez-moi toutes vos questions !';

  static const String startButton = 'Commencer';

  // Chat
  static const String inputHint = 'Posez votre question...';
  static const String sendButton = 'Envoyer';
  static const String emptyChat = 'Aucune conversation pour le moment';
  static const String typing = 'En train d\'écrire...';

  // Erreurs
  static const String errorConnection =
      'Impossible de se connecter au serveur. '
      'Vérifiez votre connexion internet.';
  static const String errorTimeout = 'Le serveur met trop de temps à répondre.';
  static const String errorUnknown =
      'Une erreur est survenue. Veuillez réessayer.';

  // Questions suggérées
  static const List<String> suggestedQuestions = [
    'Comment créer une vente directe ?',
    'Comment créer une vente revendeur ?',
    'Comment annuler une vente ?',
    'Quels sont les types de réchauds ?',
    'Comment je me connecte à Lemadio ?',
    'Je n\'ai pas de compte, que faire ?',
    'Que faire si j\'ai oublié mon mot de passe ?',
    'C\'est quoi Assistant Lemadio ?',
  ];
}
