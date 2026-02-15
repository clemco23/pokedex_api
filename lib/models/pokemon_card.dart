class PokemonCard {
  final String id;
  final String name;
  final String imageUrl;
  final String largeImageUrl;
  final String hp;
  final List<String> types;
  final String rarity;
  final String? artist;
  final List<Attack> attacks;
  final String? setName;
  final String? number;

  PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.largeImageUrl,
    required this.hp,
    required this.types,
    required this.rarity,
    this.artist,
    this.attacks = const [],
    this.setName,
    this.number,
  });


  static String _buildTcgDexCardImage(
    String base, {
    required String quality,
    String ext = "webp",
  }) {
    if (base.isEmpty) return "";

    final lower = base.toLowerCase();

    
    if (lower.endsWith(".png") ||
        lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".webp")) {
      return base;
    }

    return "$base/$quality.$ext";
  }

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
  
    String smallImage = '';
    String largeImage = '';

    if (json['image'] != null) {
      if (json['image'] is String) {
        final base = json['image'] as String;
        smallImage = _buildTcgDexCardImage(base, quality: "low");
        largeImage = _buildTcgDexCardImage(base, quality: "high");
      } else if (json['image'] is Map) {
        final img = json['image'] as Map;
        final base =
            (img['small'] ??
                    img['thumb'] ??
                    img['large'] ??
                    img['high'] ??
                    '')
                ?.toString() ??
            '';

        smallImage = _buildTcgDexCardImage(base, quality: "low");
        largeImage = _buildTcgDexCardImage(base, quality: "high");
      }
    }

    List<String> cardTypes = [];
    if (json['types'] != null && json['types'] is List) {
      cardTypes =
          (json['types'] as List<dynamic>).map((e) => e.toString()).toList();
    }

  
    List<Attack> cardAttacks = [];
    if (json['attacks'] != null && json['attacks'] is List) {
      cardAttacks = (json['attacks'] as List<dynamic>)
          .map((e) => Attack.fromJson(e))
          .toList();
    }

   
    String cardRarity = 'Common';
    if (json['rarity'] != null) {
      if (json['rarity'] is String) {
        cardRarity = json['rarity'];
      } else if (json['rarity'] is Map &&
          json['rarity']['name'] != null) {
        cardRarity = json['rarity']['name'];
      }
    }

    
    String cardHp = 'N/A';
    if (json['hp'] != null) {
      cardHp = json['hp'].toString();
    }

   
    String? setName;
    if (json['set'] != null) {
      if (json['set'] is String) {
        setName = json['set'];
      } else if (json['set'] is Map &&
          json['set']['name'] != null) {
        setName = json['set']['name'];
      }
    }

    return PokemonCard(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: smallImage,
      largeImageUrl: largeImage,
      hp: cardHp,
      types: cardTypes,
      rarity: cardRarity,
      artist: json['illustrator'] ?? json['artist'],
      attacks: cardAttacks,
      setName: setName,
      number: json['localId'] ?? json['dexId']?.toString(),
    );
  }
}

class Attack {
  final String name;
  final String damage;
  final List<String> cost;
  final String text;

  Attack({
    required this.name,
    required this.damage,
    required this.cost,
    required this.text,
  });

  factory Attack.fromJson(Map<String, dynamic> json) {
    List<String> energyCost = [];
    if (json['cost'] != null && json['cost'] is List) {
      energyCost =
          (json['cost'] as List<dynamic>).map((e) => e.toString()).toList();
    }

    String damageValue = '';
    if (json['damage'] != null) {
      if (json['damage'] is String) {
        damageValue = json['damage'];
      } else if (json['damage'] is int) {
        damageValue = json['damage'].toString();
      }
    }

    String effectText = json['effect'] ?? json['text'] ?? '';

    return Attack(
      name: json['name'] ?? '',
      damage: damageValue,
      cost: energyCost,
      text: effectText,
    );
  }
}
