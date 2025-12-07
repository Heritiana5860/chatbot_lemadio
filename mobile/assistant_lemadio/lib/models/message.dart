import 'package:equatable/equatable.dart';

/// Modèle représentant un message dans le chat
class Message extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String> sources;
  final String? feedback;

  const Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.sources,
    this.feedback,
  });

  /// Créer une copie du message avec des modifications
  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<String>? sources,
    String? feedback,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sources: sources ?? this.sources,
      feedback: feedback ?? this.feedback,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'is_user': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'sources': sources.join(','),
      'feedback': feedback,
    };
  }

  /// Créer depuis un Map de la base de données
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      content: map['content'] as String,
      isUser: (map['is_user'] as int) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      sources: map['sources'] != null && map['sources'].toString().isNotEmpty
          ? (map['sources'] as String).split(',')
          : [],
      feedback: map['feedback'] as String?,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'sources': sources,
      'feedback': feedback,
    };
  }

  /// Créer depuis JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sources: List<String>.from(json['sources'] ?? []),
      feedback: json['feedback'] as String?,
    );
  }

  /// Créer un message de bienvenue
  factory Message.welcome() {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content:
          'Bonjour ! Je suis votre assistant de formation Lemadio. Posez-moi vos questions sur l\'utilisation de l\'application et je vous guiderai avec plaisir !',
      isUser: false,
      timestamp: DateTime.now(),
      sources: [],
    );
  }

  /// Créer un message d'erreur
  factory Message.error(String errorMessage) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '❌ $errorMessage',
      isUser: false,
      timestamp: DateTime.now(),
      sources: [],
    );
  }

  /// Créer un message hors ligne
  factory Message.offline(String? faqAnswer) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: faqAnswer ??
          '📵 Vous êtes hors ligne. Je ne peux pas répondre à cette question pour le moment. '
          'Veuillez vous connecter à internet pour obtenir une réponse ou consulter les questions fréquentes.',
      isUser: false,
      timestamp: DateTime.now(),
      sources: faqAnswer != null ? ['FAQ Hors ligne'] : [],
    );
  }

  /// Vérifier si le message a des sources
  bool get hasSources => sources.isNotEmpty;

  /// Vérifier si le message a un feedback
  bool get hasFeedback => feedback != null;

  /// Vérifier si le feedback est positif
  bool get isPositiveFeedback => feedback == 'positive';

  /// Vérifier si le feedback est négatif
  bool get isNegativeFeedback => feedback == 'negative';

  @override
  List<Object?> get props => [id, content, isUser, timestamp, sources, feedback];

  @override
  String toString() {
    return 'Message(id: $id, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}..., '
        'isUser: $isUser, timestamp: $timestamp, sources: $sources, feedback: $feedback)';
  }
}