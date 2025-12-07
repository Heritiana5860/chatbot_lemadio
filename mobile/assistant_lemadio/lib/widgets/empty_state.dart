import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Empty state pour l'historique vide
  factory EmptyState.history({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.history,
      title: 'Aucun historique',
      message:
          'Vous n\'avez pas encore posé de questions.\nCommencez une conversation pour voir l\'historique.',
      actionLabel: onAction != null ? 'Poser une question' : null,
      onAction: onAction,
    );
  }

  /// Empty state pour recherche sans résultats
  factory EmptyState.searchResults({required String query}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'Aucun résultat',
      message:
          'Aucun résultat trouvé pour "$query".\nEssayez avec d\'autres mots-clés.',
    );
  }

  /// Empty state pour connexion perdue
  factory EmptyState.offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'Pas de connexion',
      message:
          'Vous êtes actuellement hors ligne.\nSeules les FAQ sont disponibles.',
      actionLabel: onRetry != null ? 'Réessayer' : null,
      onAction: onRetry,
    );
  }

  /// Empty state pour erreur
  factory EmptyState.error({required String message, VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Une erreur s\'est produite',
      message: message,
      actionLabel: onRetry != null ? 'Réessayer' : null,
      onAction: onRetry,
    );
  }
}
