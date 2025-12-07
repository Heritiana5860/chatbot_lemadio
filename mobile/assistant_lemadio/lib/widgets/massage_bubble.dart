import 'package:assistant_lemadio/models/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(String)? onFeedback;

  const MessageBubble({super.key, required this.message, this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isUser ? AppColors.primaryGradient : null,
                    color: isUser ? null : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isUser
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (message.sources.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.borderLight, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.description,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Sources :',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: message.sources
                              .map(
                                (source) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        AppColors.accent.withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '📄 $source',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!isUser && onFeedback != null) ...[
                      const SizedBox(width: 12),
                      _buildFeedbackButtons(),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 12),
          if (isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: message.isUser ? AppColors.primaryGradient : null,
        color: message.isUser ? null : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: message.isUser
            ? null
            : Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: message.isUser
            ? const Text(
                'V',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            : const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 18,
              ),
      ),
    );
  }

  Widget _buildFeedbackButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFeedbackButton(
          icon: Icons.thumb_up,
          feedback: 'positive',
          isSelected: message.feedback == 'positive',
        ),
        const SizedBox(width: 4),
        _buildFeedbackButton(
          icon: Icons.thumb_down,
          feedback: 'negative',
          isSelected: message.feedback == 'negative',
        ),
      ],
    );
  }

  Widget _buildFeedbackButton({
    required IconData icon,
    required String feedback,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onFeedback?.call(feedback),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? (feedback == 'positive'
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isSelected
              ? (feedback == 'positive' ? AppColors.success : AppColors.error)
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
