import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class ApiService {
  static const String baseUrl = 'http://192.168.1.52:8080';
  final Duration timeout = const Duration(seconds: 60);

  /// Envoyer un message au chatbot
  Future<Map<String, dynamic>> sendMessage(String question) async {
    try {
      final url = Uri.parse('$baseUrl/chat');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'question': question,
              'conversation_id':
                  'mobile_${DateTime.now().millisecondsSinceEpoch}',
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'answer': data['answer'] ?? 'Aucune réponse disponible',
          'sources': data['sources'] ?? [],
          'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
        };
      } else if (response.statusCode == 503) {
        throw Exception('Le système n\'est pas encore initialisé.');
      } else {
        throw Exception('Erreur du serveur (${response.statusCode}).');
      }
    } on TimeoutException {
      throw Exception('La requête a pris trop de temps (>60s).');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue : $e');
    }
  }

  /// 🆕 Envoyer l'historique pour analytics
  Future<void> syncAnalytics(List<Map<String, dynamic>> historyItems) async {
    try {
      final url = Uri.parse('$baseUrl/analytics/sync-mobile');

      // ✅ LOG 1: Afficher le nombre d'items
      debugPrint(
        '📤 [SYNC] Tentative de sync de ${historyItems.length} entrées',
      );

      // ✅ LOG 2: Afficher le premier item pour debug
      if (historyItems.isNotEmpty) {
        debugPrint('📋 [SYNC] Premier item: ${jsonEncode(historyItems.first)}');
      }

      final body = jsonEncode({
        'data': historyItems,
        'synced_at': DateTime.now().toIso8601String(),
      });

      // ✅ LOG 3: Afficher la taille du body
      debugPrint('📦 [SYNC] Taille du body: ${body.length} caractères');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      // ✅ LOG 4: Afficher la réponse
      debugPrint('📥 [SYNC] Status: ${response.statusCode}');
      debugPrint('📥 [SYNC] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint(
          '✅ [SYNC] Succès: ${responseData['inserted']}/${responseData['total']} entrées synchronisées',
        );
      } else {
        debugPrint('❌ [SYNC] Erreur ${response.statusCode}: ${response.body}');
        throw Exception(
          'Erreur synchronisation (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ [SYNC] Exception: $e');
      throw Exception('Erreur sync analytics : $e');
    }
  }

  /// Vérifier l'état de santé de l'API
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('API non disponible (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Impossible de se connecter à l\'API : $e');
    }
  }

  /// Obtenir les statistiques du système
  Future<Map<String, dynamic>> getStats() async {
    try {
      final url = Uri.parse('$baseUrl/stats');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Impossible de récupérer les statistiques');
      }
    } catch (e) {
      throw Exception('Erreur stats : $e');
    }
  }

  // Synchroniser les feedbacks
  Future<void> syncFeedbacks(List<Map<String, dynamic>> feedbacks) async {
    try {
      final url = Uri.parse('$baseUrl/analytics/sync-feedbacks');

      debugPrint(
        '👍 [SYNC] Tentative de sync de ${feedbacks.length} feedbacks',
      );

      final body = jsonEncode({
        'data': feedbacks,
        'synced_at': DateTime.now().toIso8601String(),
      });

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('👍 [SYNC] Status: ${response.statusCode}');
      debugPrint('👍 [SYNC] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint(
          '✅ [SYNC] Feedbacks: ${responseData['inserted']}/${responseData['total']} synchronisés',
        );
      } else {
        debugPrint('❌ [SYNC] Erreur ${response.statusCode}: ${response.body}');
        throw Exception('Erreur sync feedbacks (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ [SYNC] Exception feedbacks: $e');
      throw Exception('Erreur sync feedbacks : $e');
    }
  }

  /// Tester la connectivité
  Future<bool> testConnection() async {
    try {
      await checkHealth();
      return true;
    } catch (e) {
      return false;
    }
  }

  String getBaseUrl() => baseUrl;
}
