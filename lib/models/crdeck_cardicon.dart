class CrDeckCardIcon {
  final String? evolutionMedium;
  final String medium;

  CrDeckCardIcon({
    this.evolutionMedium,
    required this.medium,
  });

  factory CrDeckCardIcon.fromJson(Map<String, dynamic> json) {
    return CrDeckCardIcon(
      evolutionMedium: json['evolutionMedium'],
      medium: json['medium'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evolutionMedium': evolutionMedium,
      'medium': medium,
    };
  }
}