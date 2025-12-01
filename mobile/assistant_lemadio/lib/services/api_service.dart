import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.52:5000';

  /// Envoie un message au chatbot et retourne la réponse
  Future<Message> sendMessage(String userMessage) async {
    try {
      final url = Uri.parse('$baseUrl/api/chat');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': userMessage}),
          )
          .timeout(
            const Duration(seconds: 60), // Timeout de 60 secondes
          );

      debugPrint("Response: $response");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Health response: $data");

        return Message.bot(
          data['reply'] as String,
          ragUsed: data['rag_used'] as bool? ?? false,
        );
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception(
        'Erreur de connexion: Impossible de joindre le serveur. Vérifiez votre connexion internet.',
      );
    } on TimeoutException {
      throw Exception(
        'Le serveur met trop de temps à répondre. Veuillez réessayer.',
      );
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Vérifie la santé du backend
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final url = Uri.parse('$baseUrl/api/health');
      debugPrint("Vérification santé sur : $url");

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Réponse health : $data");

        // ADAPTÉ À TA VRAIE RÉPONSE BACKEND
        return {
          'backend': data['status'] == 'running' ? 'running' : 'error',
          'rag': data['rag'] == true ? 'ok' : 'error', // rag est un booléen
          'ollama': data['llm'] ?? 'unknown',
        };
      } else {
        debugPrint("Health HTTP error: ${response.statusCode}");
        return {'backend': 'error', 'rag': 'error'};
      }
    } catch (e) {
      debugPrint("Health check exception: $e");
      return {'backend': 'disconnected', 'rag': 'error', 'error': e.toString()};
    }
  }

  /// Teste la recherche RAG (pour déboguer)
  Future<List<String>> searchDocumentation(String query) async {
    try {
      final url = Uri.parse('$baseUrl/api/search');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'query': query, 'top_k': 3}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;

        return results.map((r) => r['preview'] as String).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Erreur recherche: $e');
      return [];
    }
  }
}
