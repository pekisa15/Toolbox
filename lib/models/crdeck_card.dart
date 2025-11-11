import 'package:toolbox/models/crdeck_cardicon.dart';

class CrDeckCard {
  final int? elixirCost;
  final CrDeckCardIcon iconUrls;
  final int id;
  final int? maxEvolutionLevel;
  final int maxLevel;
  final String name;
  final String rarity;

  CrDeckCard({
    required this.elixirCost,
    required this.iconUrls,
    required this.id,
    this.maxEvolutionLevel,
    required this.maxLevel,
    required this.name,
    required this.rarity,
  });

  factory CrDeckCard.fromJson(Map<String, dynamic> json) {
    return CrDeckCard(
      elixirCost: json['elixirCost'],
      iconUrls: CrDeckCardIcon.fromJson(json['iconUrls'] as Map<String, dynamic>),
      id: json['id'] ?? -1,
      maxEvolutionLevel: json['maxEvolutionLevel'],
      maxLevel: json['maxLevel'] ?? 0,
      name: json['name'] ?? '',
      rarity: json['rarity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elixirCost': elixirCost,
      'iconUrls': iconUrls.toJson(),
      'id': id,
      'maxEvolutionLevel': maxEvolutionLevel,
      'maxLevel': maxLevel,
      'name': name,
      'rarity': rarity,
    };
  }
}
