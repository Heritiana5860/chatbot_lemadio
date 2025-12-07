import 'package:equatable/equatable.dart';

/// Modèle représentant un centre de vente
class SalesCenter extends Equatable {
  final String id;
  final String name;
  final String region;
  final String? address;

  const SalesCenter({
    required this.id,
    required this.name,
    required this.region,
    this.address,
  });

  /// Créer une copie avec des modifications
  SalesCenter copyWith({
    String? id,
    String? name,
    String? region,
    String? address,
  }) {
    return SalesCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      address: address ?? this.address,
    );
  }

  /// Convertir en Map pour stockage local
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'region': region, 'address': address};
  }

  /// Créer depuis un Map
  factory SalesCenter.fromMap(Map<String, dynamic> map) {
    return SalesCenter(
      id: map['id'] as String,
      name: map['name'] as String,
      region: map['region'] as String,
      address: map['address'] as String?,
    );
  }

  /// Convertir en JSON pour API
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'region': region, 'address': address};
  }

  /// Créer depuis JSON
  factory SalesCenter.fromJson(Map<String, dynamic> json) {
    return SalesCenter(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      address: json['address'] as String?,
    );
  }

  /// Liste des centres de vente disponibles à Madagascar
  static List<SalesCenter> get availableCenters => [
    const SalesCenter(
      id: 'TANA_CENTRE',
      name: 'Centre de vente ANTANANARIVO',
      region: 'Analamanga',
      address: 'Mahamasina, Antananarivo',
    ),
    const SalesCenter(
      id: 'FIANARA_CENTRE',
      name: 'Centre de vente FIANARANTSOA',
      region: 'Haute Matsiatra',
      address: 'Anjoma, Fianarantsoa',
    ),
    const SalesCenter(
      id: 'TULEAR_CENTRE',
      name: 'Centre de vente TULEAR',
      region: 'Atsimo-Andrefana',
      address: 'Toliara',
    ),
    const SalesCenter(
      id: 'MANAKARA_CENTRE',
      name: 'Centre de vente MANAKARA',
      region: '7 Vinagny',
      address: 'Tanambao, Manakara',
    ),
    const SalesCenter(
      id: 'TAMATAVE_CENTRE',
      name: 'Centre de vente TAMATAVE',
      region: 'Atsinanana',
      address: 'Boulevard Joffre, Toamasina',
    ),
    const SalesCenter(
      id: 'ANTSIRABE_CENTRE',
      name: 'Centre de vente ANTSIRABE',
      region: 'Vakinankaratra',
      address: 'Centre-ville, Antsirabe',
    ),
    const SalesCenter(
      id: 'ANTALAHA_CENTRE',
      name: 'Centre de vente ANTALAHA',
      region: 'Sava',
      address: 'Antalaha',
    ),
    const SalesCenter(
      id: 'ANTSOHIHY_CENTRE',
      name: 'Centre de vente ANTSOHIHY',
      region: 'Sofia',
      address: 'Antsohihy',
    ),
    const SalesCenter(
      id: 'DIEGO_CENTRE',
      name: 'Centre de vente DIEGO',
      region: 'Diana',
      address: 'Antsiranana',
    ),
    const SalesCenter(
      id: 'FORT_DAUPHIN_CENTRE',
      name: 'Centre de vente FORT DAUPHIN',
      region: 'Anosy',
      address: 'Tolagnaro',
    ),
    const SalesCenter(
      id: 'MAJUNGA_CENTRE',
      name: 'Centre de vente MAJUNGA',
      region: 'Boeny',
      address: 'Boulevard Poincaré, Mahajanga',
    ),
    const SalesCenter(
      id: 'MORONDAVA_CENTRE',
      name: 'Centre de vente MORONDAVA',
      region: 'Menabe',
      address: 'Morondava',
    ),
  ];

  /// Rechercher un centre par ID
  static SalesCenter? findById(String id) {
    try {
      return availableCenters.firstWhere((center) => center.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filtrer les centres par région
  static List<SalesCenter> filterByRegion(String region) {
    return availableCenters
        .where(
          (center) =>
              center.region.toLowerCase().contains(region.toLowerCase()),
        )
        .toList();
  }

  @override
  List<Object?> get props => [id, name, region, address];

  @override
  String toString() => 'SalesCenter(id: $id, name: $name, region: $region)';
}
