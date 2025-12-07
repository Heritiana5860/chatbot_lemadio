import 'package:equatable/equatable.dart';

/// Modèle représentant un élément de l'historique des conversations
class HistoryItem extends Equatable {
  final int? id;
  final String question;
  final String answer;
  final List<String> sources;
  final DateTime timestamp;

  const HistoryItem({
    this.id,
    required this.question,
    required this.answer,
    required this.sources,
    required this.timestamp,
  });

  /// Créer une copie avec des modifications
  HistoryItem copyWith({
    int? id,
    String? question,
    String? answer,
    List<String>? sources,
    DateTime? timestamp,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      sources: sources ?? this.sources,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'answer': answer,
      'sources': sources.join(','),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Créer depuis un Map de la base de données
  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] as int?,
      question: map['question'] as String,
      answer: map['answer'] as String,
      sources: map['sources'] != null && map['sources'].toString().isNotEmpty
          ? (map['sources'] as String).split(',')
          : [],
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'answer': answer,
      'sources': sources,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Créer depuis JSON
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as int?,
      question: json['question'] as String,
      answer: json['answer'] as String,
      sources: List<String>.from(json['sources'] ?? []),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Vérifier si l'item a des sources
  bool get hasSources => sources.isNotEmpty;

  /// Obtenir un aperçu de la question (50 premiers caractères)
  String get questionPreview {
    if (question.length <= 50) return question;
    return '${question.substring(0, 47)}...';
  }

  /// Obtenir un aperçu de la réponse (100 premiers caractères)
  String get answerPreview {
    if (answer.length <= 100) return answer;
    return '${answer.substring(0, 97)}...';
  }

  /// Formater la date en format lisible
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }

  @override
  List<Object?> get props => [id, question, answer, sources, timestamp];

  @override
  String toString() {
    return 'HistoryItem(id: $id, question: $questionPreview, timestamp: $timestamp)';
  }
}
