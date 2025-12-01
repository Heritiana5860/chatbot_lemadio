import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/tts_service.dart';

/// Dialog pour configurer les paramètres TTS
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  double _speechRate = 0.5;
  double _volume = 1.0;
  String _selectedTtsLanguage = 'fr-FR';
  String _selectedSttLanguage = 'fr-FR';
  bool _autoSendVoice = true; // Option pour envoi automatique

  final List<Map<String, String>> _languages = [
    {'code': 'fr-FR', 'name': 'Français'},
    {'code': 'mg-MG', 'name': 'Malagasy'},
    {'code': 'en-US', 'name': 'English'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                const Icon(
                  Icons.settings_voice,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                const Text('Paramètres Voix', style: AppTextStyles.heading2),
              ],
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            // Vitesse de lecture
            const Text('Vitesse de lecture', style: AppTextStyles.body),
            const SizedBox(height: AppSizes.paddingSmall),
            Row(
              children: [
                const Icon(
                  Icons.speed,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                Expanded(
                  child: Slider(
                    value: _speechRate,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _getSpeechRateLabel(_speechRate),
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _speechRate = value;
                      });
                      ttsService.setSpeechRate(value);
                    },
                  ),
                ),
                Text(
                  _getSpeechRateLabel(_speechRate),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Volume
            const Text('Volume', style: AppTextStyles.body),
            const SizedBox(height: AppSizes.paddingSmall),
            Row(
              children: [
                const Icon(
                  Icons.volume_up,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_volume * 100).toInt()}%',
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                      });
                      ttsService.setVolume(value);
                    },
                  ),
                ),
                Text(
                  '${(_volume * 100).toInt()}%',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Langue TTS (Synthèse vocale)
            const Text(
              'Langue - Synthèse vocale (écouter)',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            DropdownButtonFormField<String>(
              value: _selectedTtsLanguage,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.volume_up,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
              ),
              items: _languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['code'],
                  child: Text(lang['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTtsLanguage = value;
                  });
                  ttsService.setLanguage(value);
                }
              },
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Langue STT (Reconnaissance vocale)
            const Text(
              'Langue - Reconnaissance vocale (parler)',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            DropdownButtonFormField<String>(
              value: _selectedSttLanguage,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.mic,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
              ),
              items: _languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['code'],
                  child: Text(lang['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSttLanguage = value;
                  });
                  // La langue STT sera utilisée lors du prochain startListening
                }
              },
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            // Bouton test
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _testVoice,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Tester la voix'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMedium,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.paddingSmall),

            // Bouton fermer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSpeechRateLabel(double rate) {
    if (rate < 0.3) return 'Très lent';
    if (rate < 0.5) return 'Lent';
    if (rate < 0.7) return 'Normal';
    if (rate < 0.9) return 'Rapide';
    return 'Très rapide';
  }

  void _testVoice() {
    final testText = _selectedTtsLanguage == 'fr-FR'
        ? 'Bonjour, je suis votre assistant ADES. Comment puis-je vous aider aujourd\'hui ?'
        : _selectedTtsLanguage == 'mg-MG'
        ? 'Salama, izaho dia mpanampy ADES. Ahoana no afaka hanampiana anao androany?'
        : 'Hello, I am your ADES assistant. How can I help you today?';

    ttsService.speak(testText);
  }
}
