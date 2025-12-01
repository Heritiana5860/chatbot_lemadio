import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../config/constants.dart';
import 'chat_screen.dart';

/// Écran d'accueil avec introduction et questions suggérées
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // GlobalKeys pour cibler les widgets
  final GlobalKey _startButtonKey = GlobalKey();
  final GlobalKey _suggestedQuestionsKey = GlobalKey();
  final GlobalKey _infoSectionKey = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        _checkAndShowTutorial();
      }
    });
  }

  Future<void> _checkAndShowTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

      if (isFirstLaunch && mounted) {
        _createTutorial();
        await prefs.setBool('isFirstLaunch', false);
      }
    } catch (e) {
      debugPrint('Erreur tutoriel: $e');
    }
  }

  void _createTutorial() {
    final startButtonContext = _startButtonKey.currentContext;
    final suggestedQuestionsContext = _suggestedQuestionsKey.currentContext;
    final infoSectionContext = _infoSectionKey.currentContext;

    if (startButtonContext == null ||
        suggestedQuestionsContext == null ||
        infoSectionContext == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _createTutorial();
      });
      return;
    }

    List<TargetFocus> targets = [];

    // ÉTAPE 1 : Bouton principal
    targets.add(
      TargetFocus(
        identify: "startButton",
        keyTarget: _startButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildTutorialContent(
                step: 1,
                title: "Démarrez une conversation",
                description:
                    "Appuyez sur ce bouton pour commencer à poser vos questions à l'assistant IA.",
                icon: Icons.chat_bubble_outline,
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
              );
            },
          ),
        ],
      ),
    );

    // ÉTAPE 2 : Questions suggérées
    targets.add(
      TargetFocus(
        identify: "suggestedQuestions",
        keyTarget: _suggestedQuestionsKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.all(20),
            builder: (context, controller) {
              return _buildTutorialContent(
                step: 2,
                title: "Questions rapides",
                description:
                    "Cliquez sur une question pour obtenir une réponse immédiate sans avoir à la taper.",
                icon: Icons.lightbulb_outline,
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
              );
            },
          ),
        ],
      ),
    );

    // ÉTAPE 3 : Section Infos
    targets.add(
      TargetFocus(
        identify: "infoSection",
        keyTarget: _infoSectionKey,
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
                step: 3,
                title: "Informations importantes",
                description:
                    "Consultez cette section pour connaître les détails sur les sources de données et la disponibilité.",
                icon: Icons.info_outline,
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
      hideSkip: true, // Cacher le bouton skip par défaut
      onFinish: () {
        debugPrint('✅ Tutoriel terminé');
      },
      onClickTarget: (target) {
        debugPrint('Clic sur: ${target.identify}');
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        tutorialCoachMark?.show(context: context);
      }
    });
  }

  Widget _buildTutorialContent({
    required int step,
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec progression
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
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
                        'Étape $step sur $_totalSteps',
                        style: TextStyle(
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
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < _totalSteps - 1 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index < step
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.2),
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
                // Bouton Passer
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text('Passer', style: TextStyle(fontSize: 15)),
                ),

                // Bouton Suivant/Terminer
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
                        isLast ? 'Terminer' : 'Suivant',
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

  @override
  void dispose() {
    tutorialCoachMark?.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSizes.paddingLarge * 2),
              _buildWelcomeCard(),
              const SizedBox(height: AppSizes.paddingLarge),

              // Bouton principal avec key
              ElevatedButton(
                key: _startButtonKey,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMedium + 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat_bubble_outline, size: AppSizes.iconSize),
                    SizedBox(width: AppSizes.paddingSmall),
                    Text(
                      AppStrings.startButton,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingLarge * 2),

              // Questions suggérées avec key
              Column(
                key: _suggestedQuestionsKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Questions fréquentes',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  const Text(
                    'Cliquez sur une question pour commencer',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  ...AppStrings.suggestedQuestions.map(
                    (question) =>
                        _buildSuggestedQuestionCard(context, question),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingLarge),

              // Section informations avec key
              Container(
                key: _infoSectionKey,
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: AppSizes.iconSize,
                        ),
                        SizedBox(width: AppSizes.paddingSmall),
                        Text(
                          'À savoir',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    _buildInfoItem(
                      Icons.verified_outlined,
                      'Réponses basées sur la documentation officielle ADES',
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    _buildInfoItem(
                      Icons.access_time,
                      'Disponible 24/7, même hors ligne après la première utilisation',
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    _buildInfoItem(
                      Icons.update,
                      'Mis à jour régulièrement avec les nouvelles fonctionnalités',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Bouton d'aide flottant pour relancer le tutoriel
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isFirstLaunch', true);
          _checkAndShowTutorial();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.help_outline, size: 20, color: Colors.white),
        label: const Text('Aide', style: TextStyle(
          color: Colors.white
        ),),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.smart_toy, size: 56, color: Colors.white),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        const Text(
          AppStrings.appName,
          style: AppTextStyles.heading1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Text(
          AppStrings.appSubtitle,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.waving_hand, color: Colors.amber, size: 32),
              SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: Text(
                  AppStrings.welcomeTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          const Text(
            AppStrings.welcomeMessage,
            style: TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestionCard(BuildContext context, String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(initialMessage: question),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                    size: AppSizes.iconSize,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(child: Text(question, style: AppTextStyles.body)),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.info),
        const SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
