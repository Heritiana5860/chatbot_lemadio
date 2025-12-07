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

        // ✅ SYNCHRONISER LES QUESTIONS EN ATTENTE
        syncPendingQuestions();

        // ✅ SYNCHRONISER L'HISTORIQUE ANALYTICS
        syncAnalytics();

        _connectivityService.resetOfflineFlag();
      }
    });

    // 🆕 SYNCHRONISER AU DÉMARRAGE SI CONNECTÉ
    if (_connectivityService.isConnected) {
      debugPrint('📡 Connexion disponible au démarrage - Synchronisation...');
      Future.delayed(const Duration(seconds: 2), () {
        syncAnalytics();
        syncPendingQuestions();
      });
    }
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

        // 🆕 SYNCHRONISER IMMÉDIATEMENT L'HISTORIQUE
        Future.delayed(const Duration(milliseconds: 500), () {
          syncAnalytics();
        });
      } else {
        // 📵 MODE HORS LIGNE
        final faqAnswer = await _storageService.getFaqAnswer(text);

        final assistantMessage = Message.offline(faqAnswer);
        _messages.add(assistantMessage);

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

  /// SYNCHRONISATION AUTOMATIQUE DES QUESTIONS EN ATTENTE
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

      debugPrint('🎉 Questions: $successCount succès, $failCount échecs');

      if (successCount > 0) {
        _showSyncSuccessMessage(successCount);
      }
    } catch (e) {
      debugPrint('❌ Erreur synchronisation questions: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// SYNCHRONISATION AUTOMATIQUE DE L'HISTORIQUE ANALYTICS
  Future<void> syncAnalytics() async {
    if (_isSyncing) return;

    final isConnected = _connectivityService.isConnected;
    if (!isConnected) {
      debugPrint('📵 Pas de connexion - Analytics non synchronisées');
      return;
    }

    try {
      // ✅ 1. Synchroniser l'historique
      final unsyncedHistory = await _storageService.getUnsyncedHistory();

      if (unsyncedHistory.isNotEmpty) {
        debugPrint(
          '📊 Synchronisation de ${unsyncedHistory.length} entrées analytics...',
        );
        await _apiService.syncAnalytics(unsyncedHistory);

        for (final item in unsyncedHistory) {
          await _storageService.markAsSynced(item['id'] as int);
        }
        debugPrint(
          '✅ ${unsyncedHistory.length} entrées analytics synchronisées',
        );
      }

      // ✅ 2. Synchroniser les feedbacks
      final unsyncedFeedbacks = await _storageService.getUnsyncedFeedbacks();

      if (unsyncedFeedbacks.isNotEmpty) {
        debugPrint(
          '👍 Synchronisation de ${unsyncedFeedbacks.length} feedbacks...',
        );
        await _apiService.syncFeedbacks(unsyncedFeedbacks);

        for (final item in unsyncedFeedbacks) {
          await _storageService.markFeedbackAsSynced(
            item['message_id'] as String,
          );
        }
        debugPrint('✅ ${unsyncedFeedbacks.length} feedbacks synchronisés');
      }

      if (unsyncedHistory.isEmpty && unsyncedFeedbacks.isEmpty) {
        debugPrint('✅ Rien à synchroniser');
      }
    } catch (e) {
      debugPrint('❌ Erreur sync: $e');
    }
  }

  /// AFFICHER UN MESSAGE DE SUCCÈS DE SYNC
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

  Future<void> addFeedback(String messageId, String feedback) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final message = _messages[index];

      // Mettre à jour le message
      _messages[index] = _messages[index].copyWith(feedback: feedback);
      notifyListeners();
      await _saveMessages();

      // ✅ Sauvegarder le feedback avec question/réponse pour la sync
      await _storageService.saveFeedback(
        messageId,
        feedback,
        // Trouver la question correspondante (message précédent)
        index > 0 && _messages[index - 1].isUser
            ? _messages[index - 1].content
            : 'Question non disponible',
        message.content,
      );

      // ✅ SYNCHRONISER IMMÉDIATEMENT SI CONNECTÉ
      if (_connectivityService.isConnected) {
        debugPrint('👍 Synchronisation immédiate du feedback...');
        Future.delayed(const Duration(milliseconds: 500), () {
          syncAnalytics();
        });
      } else {
        debugPrint('👍 Feedback sauvegardé - sync lors de la reconnexion');
      }
    }
  }

  Future<void> clearConversation() async {
    _messages.clear();
    await _saveMessages();
    await _init();
    notifyListeners();
  }

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
