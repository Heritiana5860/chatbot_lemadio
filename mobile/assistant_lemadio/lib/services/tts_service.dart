import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Service pour gérer la synthèse vocale (Text-to-Speech)
class TtsService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Obtient l'état de lecture
  bool get isSpeaking => _isSpeaking;

  /// Obtient l'état d'initialisation
  bool get isInitialized => _isInitialized;

  /// Initialise le service TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configuration pour Android et iOS
      await _flutterTts.setLanguage("fr-FR"); // Français
      await _flutterTts.setSpeechRate(0.5); // Vitesse (0.0 à 1.0)
      await _flutterTts.setVolume(1.0); // Volume (0.0 à 1.0)
      await _flutterTts.setPitch(1.0); // Tonalité (0.5 à 2.0)

      // Configuration spécifique iOS
      await _flutterTts
          .setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ]);

      // Callbacks pour suivre l'état
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
        debugPrint("🔊 TTS: Démarrage de la lecture");
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
        debugPrint("✅ TTS: Lecture terminée");
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        notifyListeners();
        debugPrint("⏹️ TTS: Lecture annulée");
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint("❌ Erreur TTS: $msg");
        _isSpeaking = false;
        notifyListeners();
      });

      _isInitialized = true;
      debugPrint("✅ TTS initialisé avec succès");
    } catch (e) {
      debugPrint("❌ Erreur lors de l'initialisation TTS: $e");
    }
  }

  /// Lit un texte à voix haute
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Arrêter toute lecture en cours
      await stop();

      // Changer la langue si spécifiée
      if (language != null) {
        await _flutterTts.setLanguage(language);
      }

      debugPrint(
        "🔊 TTS: Lecture de ${text.substring(0, text.length > 50 ? 50 : text.length)}...",
      );

      // Lire le texte
      _isSpeaking = true;
      notifyListeners();

      final result = await _flutterTts.speak(text);

      if (result == 0) {
        debugPrint("❌ TTS: Échec de la lecture");
        _isSpeaking = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Erreur lors de la lecture: $e");
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Arrête la lecture en cours
  Future<void> stop() async {
    try {
      debugPrint("⏹️ TTS: Arrêt demandé");
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Erreur lors de l'arrêt: $e");
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Met en pause la lecture
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Erreur lors de la pause: $e");
    }
  }

  /// Change la vitesse de lecture
  Future<void> setSpeechRate(double rate) async {
    try {
      // Rate entre 0.0 (très lent) et 1.0 (rapide)
      await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
      debugPrint("🎚️ Vitesse changée: $rate");
    } catch (e) {
      debugPrint("❌ Erreur lors du changement de vitesse: $e");
    }
  }

  /// Change le volume
  Future<void> setVolume(double volume) async {
    try {
      // Volume entre 0.0 (muet) et 1.0 (max)
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
      debugPrint("🔊 Volume changé: $volume");
    } catch (e) {
      debugPrint("❌ Erreur lors du changement de volume: $e");
    }
  }

  /// Change la langue
  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      debugPrint("🌍 Langue changée: $language");
    } catch (e) {
      debugPrint("❌ Erreur lors du changement de langue: $e");
    }
  }

  /// Obtient les langues disponibles
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      debugPrint("❌ Erreur lors de la récupération des langues: $e");
      return ['fr-FR', 'en-US'];
    }
  }

  /// Nettoie les ressources
  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Instance globale du service TTS (singleton)
final TtsService ttsService = TtsService();
