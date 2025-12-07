import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SuggestedQuestionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const SuggestedQuestionCard({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.borderLight, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.05),
                AppColors.accent.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget pour une grille de questions suggérées
class SuggestedQuestionsGrid extends StatelessWidget {
  final Function(String) onQuestionTap;

  const SuggestedQuestionsGrid({super.key, required this.onQuestionTap});

  @override
  Widget build(BuildContext context) {
    final questions = [
      {
        'icon': Icons.login,
        'text': "Comment s'authentifier ?",
        'color': Colors.blue,
      },
      {
        'icon': Icons.shopping_cart,
        'text': 'Comment créer une vente ?',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.inventory,
        'text': 'Comment gérer le stock ?',
        'color': Colors.purple,
      },
      {
        'icon': Icons.cancel,
        'text': 'Comment annuler une vente ?',
        'color': Colors.red,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return SuggestedQuestionCard(
          icon: question['icon'] as IconData,
          text: question['text'] as String,
          color: question['color'] as Color,
          onTap: () => onQuestionTap(question['text'] as String),
        );
      },
    );
  }
}
