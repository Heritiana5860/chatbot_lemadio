import 'package:equatable/equatable.dart';

/// Modèle représentant les statistiques du système
class AppStats extends Equatable {
  final int documentsIndexed;
  final String collectionName;
  final String embeddingModel;
  final String llmModel;
  final String? storageType;
  final int? chunkSize;
  final int? chunkOverlap;

  const AppStats({
    required this.documentsIndexed,
    required this.collectionName,
    required this.embeddingModel,
    required this.llmModel,
    this.storageType,
    this.chunkSize,
    this.chunkOverlap,
  });

  /// Créer depuis JSON de l'API
  factory AppStats.fromJson(Map<String, dynamic> json) {
    return AppStats(
      documentsIndexed: json['documents_indexed'] as int? ?? 0,
      collectionName: json['collection_name'] as String? ?? 'inconnu',
      embeddingModel: json['embedding_model'] as String? ?? 'inconnu',
      llmModel: json['llm_model'] as String? ?? 'inconnu',
      storageType: json['storage_type'] as String?,
      chunkSize: json['chunk_size'] as int?,
      chunkOverlap: json['chunk_overlap'] as int?,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'documents_indexed': documentsIndexed,
      'collection_name': collectionName,
      'embedding_model': embeddingModel,
      'llm_model': llmModel,
      if (storageType != null) 'storage_type': storageType,
      if (chunkSize != null) 'chunk_size': chunkSize,
      if (chunkOverlap != null) 'chunk_overlap': chunkOverlap,
    };
  }

  /// Vérifier si le système est prêt
  bool get isReady => documentsIndexed > 0;

  /// Obtenir un résumé lisible
  String get summary {
    return '$documentsIndexed documents indexés • Modèle: $llmModel';
  }

  @override
  List<Object?> get props => [
    documentsIndexed,
    collectionName,
    embeddingModel,
    llmModel,
    storageType,
    chunkSize,
    chunkOverlap,
  ];

  @override
  String toString() {
    return 'AppStats(documentsIndexed: $documentsIndexed, llmModel: $llmModel)';
  }
}

/// Modèle pour les statistiques de santé de l'API
class HealthStatus extends Equatable {
  final String status;
  final String ollama;
  final String chromadb;
  final bool documentsIndexed;

  const HealthStatus({
    required this.status,
    required this.ollama,
    required this.chromadb,
    required this.documentsIndexed,
  });

  /// Créer depuis JSON de l'API
  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] as String? ?? 'unknown',
      ollama: json['ollama'] as String? ?? 'unknown',
      chromadb: json['chromadb'] as String? ?? 'unknown',
      documentsIndexed: json['documents_indexed'] as bool? ?? false,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'ollama': ollama,
      'chromadb': chromadb,
      'documents_indexed': documentsIndexed,
    };
  }

  /// Vérifier si tout est sain
  bool get isHealthy => status == 'healthy';

  /// Vérifier si Ollama est connecté
  bool get isOllamaConnected => ollama == 'connected';

  /// Vérifier si ChromaDB est connecté
  bool get isChromaConnected => chromadb == 'connected';

  /// Obtenir un message de statut
  String get statusMessage {
    if (isHealthy) {
      return '✅ Système opérationnel';
    } else if (status == 'degraded') {
      return '⚠️ Système partiellement opérationnel';
    } else {
      return '❌ Système non disponible';
    }
  }

  /// Obtenir une couleur selon le statut
  String get statusColor {
    if (isHealthy) return 'green';
    if (status == 'degraded') return 'orange';
    return 'red';
  }

  @override
  List<Object?> get props => [status, ollama, chromadb, documentsIndexed];

  @override
  String toString() {
    return 'HealthStatus(status: $status, ollama: $ollama, chromadb: $chromadb)';
  }
}
