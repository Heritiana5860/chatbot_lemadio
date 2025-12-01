import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/stt_service.dart';

/// Widget pour saisir un message
class InputField extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const InputField({super.key, required this.onSend, this.isLoading = false});

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    sttService.addListener(_onSttStateChanged);

    // Initialiser le service STT
    sttService.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    sttService.removeListener(_onSttStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _onSttStateChanged() {
    if (mounted) {
      setState(() {
        // Mettre à jour le texte si la reconnaissance a donné un résultat
        if (sttService.recognizedText.isNotEmpty && !sttService.isListening) {
          _controller.text = sttService.recognizedText;
        }
      });
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSend(text);
      _controller.clear();
      sttService.clearRecognizedText();
    }
  }

  /// Gère le bouton microphone
  Future<void> _toggleMicrophone() async {
    if (sttService.isListening) {
      // Arrêter l'écoute
      await sttService.stopListening();
    } else {
      // Démarrer l'écoute
      await sttService.startListening(
        localeId: 'fr-FR',
        onResult: (text) {
          // Quand l'écoute est terminée, envoyer automatiquement
          if (mounted && text.isNotEmpty) {
            setState(() {
              _controller.text = text;
            });

            // Feedback visuel rapide
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text('Question envoyée !')),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 1),
              ),
            );

            // Envoyer automatiquement après un court délai
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _handleSend();
              }
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur de reconnaissance vocale
            if (sttService.isListening) _buildListeningIndicator(),

            // Champ de texte et boutons
            Row(
              children: [
                // Bouton microphone
                Material(
                  color: sttService.isListening
                      ? AppColors.error
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: widget.isLoading ? null : _toggleMicrophone,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: Icon(
                        sttService.isListening ? Icons.mic : Icons.mic_none,
                        color: sttService.isListening
                            ? Colors.white
                            : AppColors.primary,
                        size: AppSizes.iconSize,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSizes.paddingSmall),

                // Champ de texte
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: !widget.isLoading && !sttService.isListening,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: sttService.isListening
                            ? 'Écoute en cours...'
                            : AppStrings.inputHint,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: sttService.isListening
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),

                const SizedBox(width: AppSizes.paddingSmall),

                // Bouton d'envoi
                Material(
                  color:
                      _hasText && !widget.isLoading && !sttService.isListening
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap:
                        _hasText && !widget.isLoading && !sttService.isListening
                        ? _handleSend
                        : null,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: AppSizes.iconSize,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour l'indicateur d'écoute
  Widget _buildListeningIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Animation micro
          const SizedBox(width: 24, height: 24, child: _PulsingMicIcon()),

          const SizedBox(width: AppSizes.paddingSmall),

          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Écoute en cours...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (sttService.recognizedText.isNotEmpty)
                  Text(
                    sttService.recognizedText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Bouton annuler
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.error,
            onPressed: () => sttService.cancel(),
            tooltip: 'Annuler',
          ),
        ],
      ),
    );
  }
}

/// Widget d'animation pour l'icône micro
class _PulsingMicIcon extends StatefulWidget {
  const _PulsingMicIcon();

  @override
  State<_PulsingMicIcon> createState() => _PulsingMicIconState();
}

class _PulsingMicIconState extends State<_PulsingMicIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: const Icon(Icons.mic, color: AppColors.primary, size: 24),
        );
      },
    );
  }
}
