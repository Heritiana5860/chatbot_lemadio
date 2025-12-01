import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Service pour gérer la reconnaissance vocale (Speech-to-Text)
class SttService extends ChangeNotifier {
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  String _errorMessage = '';

  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  double get confidence => _confidence;
  String get errorMessage => _errorMessage;

  /// Initialise le service STT
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Vérifier et demander la permission du microphone
      final permissionStatus = await _requestMicrophonePermission();
      if (!permissionStatus) {
        _errorMessage = 'Permission microphone refusée';
        notifyListeners();
        return false;
      }

      // Initialiser le service de reconnaissance vocale
      _isInitialized = await _speechToText.initialize(
        onStatus: (status) {
          debugPrint('📢 STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('❌ STT Error: $error');
          _errorMessage = error.errorMsg;
          _isListening = false;
          notifyListeners();
        },
      );

      if (_isInitialized) {
        debugPrint('✅ STT initialisé avec succès');
      } else {
        debugPrint('❌ Échec de l\'initialisation STT');
        _errorMessage = 'Impossible d\'initialiser la reconnaissance vocale';
      }

      notifyListeners();
      return _isInitialized;
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation STT: $e');
      _errorMessage = e.toString();
      _isInitialized = false;
      notifyListeners();
      return false;
    }
  }

  /// Demande la permission d'accès au microphone
  Future<bool> _requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Erreur demande permission: $e');
      return false;
    }
  }

  /// Démarre l'écoute
  Future<void> startListening({
    String localeId = 'fr-FR',
    Function(String)? onResult,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return;
      }
    }

    if (_isListening) {
      debugPrint('⚠️ Écoute déjà en cours');
      return;
    }

    try {
      _recognizedText = '';
      _confidence = 0.0;
      _errorMessage = '';
      notifyListeners();

      debugPrint('🎤 Démarrage de l\'écoute...');

      await _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          _confidence = result.confidence;

          debugPrint(
            '🎤 Texte reconnu: $_recognizedText (confiance: ${(_confidence * 100).toInt()}%)',
          );

          notifyListeners();

          // Appeler le callback si fourni
          if (onResult != null && result.finalResult) {
            onResult(_recognizedText);
          }
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30), // Durée max d'écoute
        pauseFor: const Duration(seconds: 3), // Pause après silence
        partialResults: true, // Résultats partiels pendant l'écoute
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      _isListening = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur lors du démarrage de l\'écoute: $e');
      _errorMessage = e.toString();
      _isListening = false;
      notifyListeners();
    }
  }

  /// Arrête l'écoute
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      debugPrint('🛑 Arrêt de l\'écoute');
      await _speechToText.stop();
      _isListening = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'arrêt de l\'écoute: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  /// Annule l'écoute en cours
  Future<void> cancel() async {
    if (!_isListening) return;

    try {
      debugPrint('❌ Annulation de l\'écoute');
      await _speechToText.cancel();
      _isListening = false;
      _recognizedText = '';
      _confidence = 0.0;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'annulation: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  /// Obtient les langues disponibles
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final locales = await _speechToText.locales();
      return locales;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des langues: $e');
      return [];
    }
  }

  /// Réinitialise le texte reconnu
  void clearRecognizedText() {
    _recognizedText = '';
    _confidence = 0.0;
    _errorMessage = '';
    notifyListeners();
  }

  /// Vérifie si la reconnaissance vocale est disponible
  Future<bool> isAvailable() async {
    try {
      return await _speechToText.initialize();
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

/// Instance globale du service STT (singleton)
final SttService sttService = SttService();
