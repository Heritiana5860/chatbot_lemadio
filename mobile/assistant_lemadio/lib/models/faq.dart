import 'package:equatable/equatable.dart';

/// Modèle représentant une question fréquente (FAQ)
class Faq extends Equatable {
  final int? id;
  final String question;
  final String answer;
  final List<String> keywords;

  const Faq({
    this.id,
    required this.question,
    required this.answer,
    required this.keywords,
  });

  /// Créer une copie avec des modifications
  Faq copyWith({
    int? id,
    String? question,
    String? answer,
    List<String>? keywords,
  }) {
    return Faq(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      keywords: keywords ?? this.keywords,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'answer': answer,
      'keywords': keywords.join(','),
    };
  }

  /// Créer depuis un Map de la base de données
  factory Faq.fromMap(Map<String, dynamic> map) {
    return Faq(
      id: map['id'] as int?,
      question: map['question'] as String,
      answer: map['answer'] as String,
      keywords: (map['keywords'] as String).split(','),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'answer': answer,
      'keywords': keywords,
    };
  }

  /// Créer depuis JSON
  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] as int?,
      question: json['question'] as String,
      answer: json['answer'] as String,
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  /// Vérifier si la FAQ correspond à une recherche
  bool matches(String searchQuery) {
    final query = searchQuery.toLowerCase().trim();

    // Rechercher dans la question
    if (question.toLowerCase().contains(query)) {
      return true;
    }

    // Rechercher dans les mots-clés
    return keywords.any(
      (keyword) =>
          keyword.toLowerCase().contains(query) ||
          query.contains(keyword.toLowerCase()),
    );
  }

  /// Calculer un score de pertinence (0-100)
  int relevanceScore(String searchQuery) {
    final query = searchQuery.toLowerCase().trim();
    int score = 0;

    // Correspondance exacte dans la question : +50
    if (question.toLowerCase() == query) {
      score += 50;
    }
    // Correspondance partielle dans la question : +30
    else if (question.toLowerCase().contains(query)) {
      score += 30;
    }

    // Comptez les mots-clés qui correspondent
    final matchingKeywords = keywords
        .where(
          (keyword) =>
              keyword.toLowerCase().contains(query) ||
              query.contains(keyword.toLowerCase()),
        )
        .length;

    // +10 points par mot-clé correspondant
    score += matchingKeywords * 10;

    // Bonus si plusieurs mots de la recherche sont dans les keywords
    final queryWords = query.split(' ');
    for (final word in queryWords) {
      if (word.length > 3) {
        // Ignorer les petits mots
        final keywordMatches = keywords
            .where((k) => k.toLowerCase().contains(word))
            .length;
        score += keywordMatches * 5;
      }
    }

    return score > 100 ? 100 : score;
  }

  /// Liste des FAQs par défaut
  static List<Faq> get defaults => [
    const Faq(
      question: 'Comment se connecter à Lemadio ?',
      answer:
          'Pour vous connecter à Lemadio, suivez ces étapes :\n'
          '1. Ouvrez l\'application\n'
          '2. Si c\'est votre première connexion, entrez votre nom utilisateur et mot de passe sinon entrez juste votre mot de passe.\n'
          '3. Cliquez sur "Se connecter"\n'
          '\n\n'
          'Note :\n'
          '- Assurez-vous d\'avoir une connexion internet active la première connexion avec l\'application.\n'
          '- Vos identifiants vous ont été fournis par votre administrateur.',
      keywords: [
        'connexion',
        'login',
        'authentification',
        'se connecter',
        'mot de passe',
        'identifiant',
      ],
    ),
    const Faq(
      question: 'Comment créer une vente ?',
      answer:
          'Pour vous donner une réponse précise, Veillez préciser quelle vente voulez vous créer :\n'
          '- Vente directe (client final)\n'
          '- Vente revendeur (Approvisionnement)\n',
      keywords: ['vente', 'créer', 'nouvelle'],
    ),
    const Faq(
      question: 'Comment créer une vente directe?',
      answer:
          'Pour créer une vente directe, suivez ces étapes :\n'
          '1. Allez dans la page de vente\n'
          '2. Cliquez le bouton rond vert (+) en haut de la barre de navigation\n'
          '3. Sélectionnez "Vente directe"\n'
          '4. Remplissez les informations du client\n'
          '5. Sélectionnez un numéro facture\n'
          '6. Vérifiez bien les informations de client\n'
          '7. Scannez les codes barres de réchaud\n'
          '8. Dans la condition de garantie: "\n'
          '- Cochez la case "Je cede d\'accepter"\n'
          '- Scrollez puis demande le client de signer dans la zone de signature\n'
          '9. Cliquez "Sauvegarder"\n\n'
          'Note :\n'
          '- Assurez-vous d\'avoir une connexion internet active pour synchroniser la vente immédiatement.\n'
          '- Vous pouvez aussi créer la vente en mode hors ligne, mais nous vous suggérons de synchroniser la vente manuelement lorsque la connexion internet sera rétablie.\n'
          ,
      keywords: ['vente directe', 'directe', 'nouvelle vente directe', 'client final'],
    ),
    const Faq(
      question: 'Comment créer une vente revendeur?',
      answer:
          'Pour créer une vente revendeur, suivez ces étapes :\n'
          '1. Allez dans la page de vente\n'
          '2. Cliquez le bouton rond vert (+) en haut de la barre de navigation\n'
          '3. Sélectionnez "Vente revendeur"\n'
          '4. Sélectionnez un numéro facture\n'
          '5. Sélectionnez le revendeur dans la liste des revendeurs\n'
          '6. Scannez tous les codes barres de réchaud à approvisionner\n'
          '7. Dans la condition de garantie: "\n'
          '- Cochez la case "Je cede d\'accepter"\n'
          '- Scrollez puis demande le client de signer dans la zone de signature\n'
          '9. Cliquez "Sauvegarder"\n\n'
          'Note :\n'
          '- Assurez-vous d\'avoir une connexion internet active pour synchroniser la vente immédiatement.\n'
          ,
      keywords: ['vente revendeur', 'revendeur', 'nouvelle vente revendeur', 'approvisionnement'],
    ),
    const Faq(
      question: 'Comment gérer le stock ?',
      answer:
      "Pour gérer le stock dans Lemadio, suivez ces étapes :\n"
          '1. Allez dans la barre de navigation en bas\n'
          '2. Cliquez la deuxième icône\n\n'
      "Par defaut, vous rendrez dans la page qui affiche la liste des réchauds en stock.\n"
      "Note :\n"
      "Les deux onglets en haut vous permettent de basculer entre les réchauds en stock et les numéro facture.\n"
      "Les réchauds avec une bordure verre sont disponible pour la vente tandis que ceux en rouges sont déjà vendus.\n"
          ,
      keywords: [
        'stock',
        'inventaire',
        'produit',
        'quantité',
        'gérer',
        'disponible',
        'réchaud',
        'poele',
      ],
    ),
    const Faq(
      question: 'Comment annuler une vente ?',
      answer:
      "Pour annuler une vente, suivez ces étapes :\n"
          '1. Rendre dans la page de vente\n'
          '2. Localiser la vente que vous souhaitez annuler\n'
          '3. Clicker sur le bouton "Annuler" sur la carte de la vente\n'
          '4. L\'app vous demandera de remplir le motif d\'annulation\n'
          '5. Validez l\'annulation\n\n'
          'Note:\n'
          '- Une vente est apte pour annulation juste le jour de la création de la vente.'
          '- Après annulation, le stock sera mis à jour automatiquement.'
          '- La connexion internet est requise pour annuler une vente.'
          '- Informez toujours votre ADV pour une annulation de vente.'
          ,
      keywords: [
        'annuler',
        'supprimer',
        'erreur',
        'annulation',
        'problème',
      ],
    ),
    const Faq(
      question: 'Que faire si l\'application ne se synchronise pas ?',
      answer:
          '1. Vérifiez votre connexion internet (WiFi ou données mobiles) et ressayez\n'
          'Si le problème persiste, redémarrez l\'application\n'
          '2. déconnectez-vous puis reconnectez-vous\n'
          'Si ça ne fonctionne toujours pas, contactez le support.\n\n'
          'Note :\n'
          '- En mode hors ligne, la synchronisation des données ne fonctionne pas.',
      keywords: [
        'synchronisation',
        'sync',
        'envoie',
        'synchroniser',
        'mettre à jour',
      ],
    ),
    const Faq(
      question: 'Comment consulter le prix de réchaud ?',
      answer:
          '1. Cliquez le trois point en haut à droite à côté de votre nom d\'utilisateur\n'
          '2. Selectionnez "Catalogue de prix"\n'
          '3. Chaque "zone" s\'affichera\n'
          '4. Cliquez la zone souhaitée pour voir les prix des réchauds.\n\n'
          'Note :\n'
          '- Chaque zone correspond à une région spécifique avec ses propres tarifs.'
          '- Contactez le support en cas de faute de prix de réchaud.',
      keywords: [
        'catalogue',
        'prix',
        'zone',
        'tarif',
      ],
    ),
  ];

  @override
  List<Object?> get props => [id, question, answer, keywords];

  @override
  String toString() {
    return 'Faq(id: $id, question: $question, keywords: ${keywords.length})';
  }
}
