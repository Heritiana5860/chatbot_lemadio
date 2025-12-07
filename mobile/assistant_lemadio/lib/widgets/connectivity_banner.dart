import 'package:assistant_lemadio/models/message.dart';
import 'package:assistant_lemadio/services/api_service.dart';
import 'package:assistant_lemadio/services/connectivity_service.dart';
import 'package:assistant_lemadio/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _isSyncing = false;

  // Listener pour la connectivité
  StreamSubscription<bool>? _connectivitySubscription;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSyncing => _isSyncing;

  ChatProvider({
    required ApiService apiService,
    required StorageService storageService,
    required ConnectivityService connectivityService,
  }) : _apiService = apiService,
       _storageService = storageService,
       _connectivityService = connectivityService {
    _init();
  }

  Future<void> _init() async {
    await _loadMessages();

    // Message de bienvenue si aucun message
    if (_messages.isEmpty) {
      _messages.add(Message.welcome());
      await _saveMessages();
    }

    // 🆕 ÉCOUTER LES CHANGEMENTS DE CONNECTIVITÉ
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected && _connectivityService.wasOffline) {
        debugPrint('🔄 Connexion rétablie - Synchronisation automatique...');
        syncPendingQuestions();
        _connectivityService.resetOfflineFlag();
      }
    });
  }

  Future<void> _loadMessages() async {
    _messages = await _storageService.getMessages();
    notifyListeners();
  }

  Future<void> _saveMessages() async {
    await _storageService.saveMessages(_messages);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Ajouter le message de l'utilisateur
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
      sources: [],
    );

    _messages.add(userMessage);
    notifyListeners();
    await _saveMessages();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 🆕 VÉRIFICATION AMÉLIORÉE DE LA CONNECTIVITÉ
      final isConnected = _connectivityService.isConnected;

      if (isConnected) {
        // 🌐 MODE EN LIGNE
        final response = await _apiService.sendMessage(text);

        final assistantMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response['answer'] ?? 'Pas de réponse',
          isUser: false,
          timestamp: DateTime.now(),
          sources: List<String>.from(response['sources'] ?? []),
        );

        _messages.add(assistantMessage);
        await _storageService.saveToHistory(userMessage, assistantMessage);
      } else {
        // 📵 MODE HORS LIGNE
        final faqAnswer = await _storageService.getFaqAnswer(text);

        final assistantMessage = Message.offline(faqAnswer);
        _messages.add(assistantMessage);

        // 🆕 SAUVEGARDER EN ATTENTE SEULEMENT SI PAS DE FAQ
        if (faqAnswer == null) {
          await _storageService.savePendingQuestion(userMessage);
          debugPrint('📥 Question sauvegardée pour synchronisation ultérieure');
        }

        await _storageService.saveToHistory(userMessage, assistantMessage);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Erreur sendMessage: $e');

      final errorMessage = Message.error(
        'Une erreur s\'est produite. Veuillez réessayer.',
      );
      _messages.add(errorMessage);

      // 🆕 SAUVEGARDER EN ATTENTE EN CAS D'ERREUR RÉSEAU
      if (e.toString().contains('connexion') ||
          e.toString().contains('timeout')) {
        await _storageService.savePendingQuestion(userMessage);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      await _saveMessages();
    }
  }

  /// 🆕 SYNCHRONISATION AUTOMATIQUE AMÉLIORÉE
  Future<void> syncPendingQuestions() async {
    if (_isSyncing) {
      debugPrint('⏳ Synchronisation déjà en cours...');
      return;
    }

    final isConnected = _connectivityService.isConnected;
    if (!isConnected) {
      debugPrint('📵 Pas de connexion - Synchronisation annulée');
      return;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final pendingQuestions = await _storageService.getPendingQuestions();

      if (pendingQuestions.isEmpty) {
        debugPrint('✅ Aucune question en attente');
        return;
      }

      debugPrint(
        '🔄 Synchronisation de ${pendingQuestions.length} question(s)...',
      );

      int successCount = 0;
      int failCount = 0;

      for (final question in pendingQuestions) {
        try {
          final response = await _apiService.sendMessage(question.content);

          // 🆕 AJOUTER LA RÉPONSE DANS L'HISTORIQUE
          final assistantMessage = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: response['answer'] ?? 'Pas de réponse',
            isUser: false,
            timestamp: DateTime.now(),
            sources: List<String>.from(response['sources'] ?? []),
          );

          await _storageService.saveToHistory(question, assistantMessage);
          await _storageService.removePendingQuestion(question.id);

          successCount++;
          debugPrint(
            '✅ Question synchronisée: ${question.content.substring(0, 30)}...',
          );
        } catch (e) {
          failCount++;
          debugPrint('❌ Échec sync question ${question.id}: $e');
        }
      }

      debugPrint(
        '🎉 Synchronisation terminée: $successCount succès, $failCount échecs',
      );

      // 🆕 AFFICHER UN MESSAGE SI NÉCESSAIRE
      if (successCount > 0) {
        _showSyncSuccessMessage(successCount);
      }
    } catch (e) {
      debugPrint('❌ Erreur synchronisation globale: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// 🆕 AFFICHER UN MESSAGE DE SUCCÈS DE SYNC
  void _showSyncSuccessMessage(int count) {
    final syncMessage = Message(
      id: 'sync_${DateTime.now().millisecondsSinceEpoch}',
      content: '✅ $count question(s) synchronisée(s) avec succès !',
      isUser: false,
      timestamp: DateTime.now(),
      sources: ['Synchronisation'],
    );

    _messages.add(syncMessage);
    notifyListeners();
    _saveMessages();

    // Supprimer le message après 5 secondes
    Future.delayed(const Duration(seconds: 5), () {
      _messages.removeWhere((m) => m.id == syncMessage.id);
      notifyListeners();
      _saveMessages();
    });
  }

  // Future<void> addFeedback(String messageId, String feedback) async {
  //   final index = _messages.indexWhere((m) => m.id == messageId);
  //   if (index != -1) {
  //     _messages[index] = _messages[index].copyWith(feedback: feedback);
  //     notifyListeners();
  //     await _saveMessages();
  //     await _storageService.saveFeedback(messageId, feedback);
  //   }
  // }

  Future<void> clearConversation() async {
    _messages.clear();
    await _saveMessages();
    await _init();
    notifyListeners();
  }

  /// 🆕 RÉCUPÉRER LE NOMBRE DE QUESTIONS EN ATTENTE
  Future<int> getPendingQuestionsCount() async {
    final pending = await _storageService.getPendingQuestions();
    return pending.length;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
