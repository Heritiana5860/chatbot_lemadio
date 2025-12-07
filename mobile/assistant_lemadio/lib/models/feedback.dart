import 'package:equatable/equatable.dart';

/// Type de feedback
enum FeedbackType {
  positive,
  negative;

  /// Convertir en string
  String get value => name;

  /// Créer depuis string
  static FeedbackType? fromString(String? value) {
    if (value == null) return null;
    return FeedbackType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FeedbackType.positive,
    );
  }

  /// Obtenir une icône
  String get icon {
    switch (this) {
      case FeedbackType.positive:
        return '👍';
      case FeedbackType.negative:
        return '👎';
    }
  }

  /// Obtenir une couleur
  String get color {
    switch (this) {
      case FeedbackType.positive:
        return 'green';
      case FeedbackType.negative:
        return 'red';
    }
  }
}

/// Modèle représentant un feedback utilisateur
class UserFeedback extends Equatable {
  final String messageId;
  final FeedbackType type;
  final DateTime timestamp;
  final String? comment;

  const UserFeedback({
    required this.messageId,
    required this.type,
    required this.timestamp,
    this.comment,
  });

  /// Créer une copie avec des modifications
  UserFeedback copyWith({
    String? messageId,
    FeedbackType? type,
    DateTime? timestamp,
    String? comment,
  }) {
    return UserFeedback(
      messageId: messageId ?? this.messageId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      comment: comment ?? this.comment,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'feedback': type.value,
      'timestamp': timestamp.toIso8601String(),
      if (comment != null) 'comment': comment,
    };
  }

  /// Créer depuis un Map de la base de données
  factory UserFeedback.fromMap(Map<String, dynamic> map) {
    return UserFeedback(
      messageId: map['message_id'] as String,
      type:
          FeedbackType.fromString(map['feedback'] as String?) ??
          FeedbackType.positive,
      timestamp: DateTime.parse(map['timestamp'] as String),
      comment: map['comment'] as String?,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'type': type.value,
      'timestamp': timestamp.toIso8601String(),
      if (comment != null) 'comment': comment,
    };
  }

  /// Créer depuis JSON
  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      messageId: json['messageId'] as String,
      type:
          FeedbackType.fromString(json['type'] as String?) ??
          FeedbackType.positive,
      timestamp: DateTime.parse(json['timestamp'] as String),
      comment: json['comment'] as String?,
    );
  }

  /// Créer un feedback positif
  factory UserFeedback.positive(String messageId, {String? comment}) {
    return UserFeedback(
      messageId: messageId,
      type: FeedbackType.positive,
      timestamp: DateTime.now(),
      comment: comment,
    );
  }

  /// Créer un feedback négatif
  factory UserFeedback.negative(String messageId, {String? comment}) {
    return UserFeedback(
      messageId: messageId,
      type: FeedbackType.negative,
      timestamp: DateTime.now(),
      comment: comment,
    );
  }

  /// Vérifier si c'est un feedback positif
  bool get isPositive => type == FeedbackType.positive;

  /// Vérifier si c'est un feedback négatif
  bool get isNegative => type == FeedbackType.negative;

  /// Vérifier si un commentaire est présent
  bool get hasComment => comment != null && comment!.isNotEmpty;

  @override
  List<Object?> get props => [messageId, type, timestamp, comment];

  @override
  String toString() {
    return 'UserFeedback(messageId: $messageId, type: ${type.value}, hasComment: $hasComment)';
  }
}
