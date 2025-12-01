/// Modèle représentant un message dans le chat
class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool ragUsed;

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.ragUsed = false,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convertir en Map pour stockage
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'ragUsed': ragUsed,
    };
  }

  /// Créer depuis Map
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ragUsed: json['ragUsed'] as bool? ?? false,
    );
  }

  /// Créer un message utilisateur
  factory Message.user(String text) {
    return Message(text: text, isUser: true);
  }

  /// Créer un message bot
  factory Message.bot(String text, {bool ragUsed = false}) {
    return Message(text: text, isUser: false, ragUsed: ragUsed);
  }

  @override
  String toString() {
    return 'Message(text: ${text.substring(0, text.length > 20 ? 20 : text.length)}..., isUser: $isUser)';
  }
}
