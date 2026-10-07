class Player {
  final String id;
  final String name;
  final int colorIndex;

  const Player({
    required this.id,
    required this.name,
    this.colorIndex = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorIndex': colorIndex,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        colorIndex: (json['colorIndex'] as int?) ?? 0,
      );

  Player copyWith({
    String? id,
    String? name,
    int? colorIndex,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}
