import 'package:assistant_lemadio/widgets/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../config/constants.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_field.dart';
import '../widgets/typing_indicator.dart';

/// Écran principal de conversation avec le chatbot
class ChatScreen extends StatefulWidget {
  final String? initialMessage;

  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // GlobalKeys pour le tutoriel
  final GlobalKey _inputFieldKey = GlobalKey();
  final GlobalKey _settingsButtonKey = GlobalKey();
  final GlobalKey _clearButtonKey = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialiser le service TTS
    ttsService.initialize();

    // Si un message initial est fourni, l'envoyer automatiquement
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialMessage!);
      });
    } else {
      // Si pas de message initial, afficher le tutoriel
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          _checkAndShowTutorial();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    tutorialCoachMark?.finish();
    ttsService.stop();
    super.dispose();
  }

  /// Vérifier et afficher le tutoriel du chat
  Future<void> _checkAndShowTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenChatTutorial = prefs.getBool('hasSeenChatTutorial') ?? false;

      if (!hasSeenChatTutorial && mounted) {
        _createTutorial();
        await prefs.setBool('hasSeenChatTutorial', true);
      }
    } catch (e) {
      debugPrint('Erreur tutoriel chat: $e');
    }
  }

  /// Créer le tutoriel
  void _createTutorial() {
    final inputFieldContext = _inputFieldKey.currentContext;
    final settingsButtonContext = _settingsButtonKey.currentContext;

    if (inputFieldContext == null || settingsButtonContext == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _createTutorial();
      });
      return;
    }

    List<TargetFocus> targets = [];

    // ÉTAPE 1 : Champ de saisie
    targets.add(
      TargetFocus(
        identify: "inputField",
        keyTarget: _inputFieldKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildTutorialContent(
                step: 1,
                totalSteps: 2,
                title: "Posez votre question",
                description:
                    "Tapez votre question ici et appuyez sur le bouton d'envoi pour obtenir une réponse instantanée.",
                icon: Icons.keyboard,
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
              );
            },
          ),
        ],
      ),
    );

    // ÉTAPE 2 : Bouton paramètres voix
    targets.add(
      TargetFocus(
        identify: "settingsButton",
        keyTarget: _settingsButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildTutorialContent(
                step: 2,
                totalSteps: 2,
                title: "Paramètres de la voix",
                description:
                    "Activez la lecture audio des réponses et ajustez la vitesse et le volume selon vos préférences.",
                icon: Icons.settings_voice,
                isLast: true,
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
              );
            },
          ),
        ],
      ),
    );

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.primary,
      opacityShadow: 0.85,
      paddingFocus: 8,
      hideSkip: true,
      onFinish: () {
        debugPrint('✅ Tutoriel chat terminé');
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        tutorialCoachMark?.show(context: context);
      }
    });
  }

  /// Widget pour le contenu du tutoriel
  Widget _buildTutorialContent({
    required int step,
    required int totalSteps,
    required String title,
    required String description,
    required IconData icon,
    bool isLast = false,
    required VoidCallback onNext,
    required VoidCallback onSkip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Étape $step sur $totalSteps',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Indicateur de progression
                Row(
                  children: List.generate(totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < totalSteps - 1 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index < step
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Boutons d'action
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text('Passer', style: TextStyle(fontSize: 15)),
                ),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLast ? 'Compris !' : 'Suivant',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isLast ? Icons.check : Icons.arrow_forward,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Affiche le dialog des paramètres TTS
  void _showSettingsDialog() {
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }

  /// Envoie un message au chatbot
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = Message.user(text);
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _errorMessage = null;
    });

    _scrollToBottom();

    try {
      final botMessage = await _apiService.sendMessage(text);

      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      _showErrorSnackBar(_errorMessage!);
    }
  }

  /// Scroll automatique vers le bas
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Affiche un message d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: () {
            if (_messages.isNotEmpty && _messages.last.isUser) {
              _sendMessage(_messages.last.text);
            }
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Efface la conversation
  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer la conversation ?'),
        content: const Text(
          'Tous les messages seront supprimés. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Assistant Lemadio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Toujours prêt à aider',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Bouton paramètres voix avec key
          IconButton(
            key: _settingsButtonKey,
            icon: const Icon(Icons.settings_voice),
            onPressed: _showSettingsDialog,
            tooltip: 'Paramètres de la voix',
          ),
          if (_messages.isNotEmpty)
            IconButton(
              key: _clearButtonKey,
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearConversation,
              tooltip: 'Effacer la conversation',
            ),
        ],
      ),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingSmall,
                    ),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const TypingIndicator();
                      }
                      return MessageBubble(message: _messages[index]);
                    },
                  ),
          ),

          // Champ de saisie avec key
          Container(
            key: _inputFieldKey,
            child: InputField(onSend: _sendMessage, isLoading: _isLoading),
          ),
        ],
      ),
    );
  }

  /// État vide (quand il n'y a pas de messages)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            const Text(
              AppStrings.emptyChat,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.paddingSmall),

            const Text(
              'Posez votre première question sur l\'application Lemadio',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            // Suggestions rapides
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickSuggestion('Comment créer une vente directe?'),
                _buildQuickSuggestion('Comment créer une vente revendeur?'),
                _buildQuickSuggestion('Comment annuler une vente?'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour une suggestion rapide
  Widget _buildQuickSuggestion(String text) {
    return InkWell(
      onTap: () => _sendMessage(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: AppColors.primary),
        ),
      ),
    );
  }
}
