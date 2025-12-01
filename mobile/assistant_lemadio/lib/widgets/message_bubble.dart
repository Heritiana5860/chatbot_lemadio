import 'package:flutter/material.dart';
import '../models/message.dart';
import '../config/constants.dart';
import '../services/tts_service.dart';

/// Widget pour afficher un message dans le chat
class MessageBubble extends StatefulWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    // Écouter les changements du service TTS
    ttsService.addListener(_onTtsStateChanged);
  }

  @override
  void dispose() {
    ttsService.removeListener(_onTtsStateChanged);
    super.dispose();
  }

  void _onTtsStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Gère la lecture/arrêt de la synthèse vocale
  Future<void> _toggleSpeak() async {
    if (ttsService.isSpeaking) {
      debugPrint("🛑 Arrêt de la lecture");
      await ttsService.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      debugPrint("▶️ Démarrage de la lecture");
      await ttsService.speak(widget.message.text);
      setState(() {
        isSpeaking = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      child: Row(
        mainAxisAlignment: widget.message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar pour le bot (à gauche)
          if (!widget.message.isUser) _buildAvatar(),

          const SizedBox(width: AppSizes.paddingSmall),

          // Bulle de message
          Flexible(
            child: Column(
              crossAxisAlignment: widget.message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Conteneur du message
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall + 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.message.isUser
                        ? AppColors.userMessage
                        : AppColors.botMessage,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppSizes.borderRadius),
                      topRight: const Radius.circular(AppSizes.borderRadius),
                      bottomLeft: Radius.circular(
                        widget.message.isUser ? AppSizes.borderRadius : 4,
                      ),
                      bottomRight: Radius.circular(
                        widget.message.isUser ? 4 : AppSizes.borderRadius,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Texte du message
                      Text(
                        widget.message.text,
                        style: widget.message.isUser
                            ? AppTextStyles.messageUser
                            : AppTextStyles.messageBot,
                      ),

                      // Bouton speaker et badge pour les messages du bot
                      if (!widget.message.isUser) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Badge RAG (si applicable)
                            if (widget.message.ragUsed) ...[
                              _buildRagBadge(),
                              const SizedBox(width: 8),
                            ],
                            // Bouton speaker
                            InkWell(
                              onTap: _toggleSpeak,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSpeaking ? Icons.stop : Icons.volume_up,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isSpeaking ? 'Arrêter' : 'Écouter',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Heure du message
                const SizedBox(height: 4),
                Text(
                  _formatTime(widget.message.timestamp),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSizes.paddingSmall),

          // Avatar pour l'utilisateur (à droite)
          if (widget.message.isUser) _buildAvatar(),
        ],
      ),
    );
  }

  /// Construit l'avatar
  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: widget.message.isUser
            ? AppColors.userMessage
            : AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.message.isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: AppSizes.iconSizeSmall,
      ),
    );
  }

  /// Badge indiquant que la réponse utilise RAG
  Widget _buildRagBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified, size: 12, color: AppColors.success),
          SizedBox(width: 4),
          Text(
            'Basé sur la doc',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Formate l'heure du message
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
