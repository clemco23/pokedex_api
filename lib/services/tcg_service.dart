import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_card.dart';

class TcgService {
  final String _host = "api.tcgdex.net";
  final String _basePath = "/v2/en";

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
  };

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.https(_host, "$_basePath$path", query);
  }

  Future<List<PokemonCard>> fetchCards({int page = 1, int pageSize = 20}) async {
    final response = await http.get(
      _uri("/cards", {
        "pagination:page": "$page",
        "pagination:itemsPerPage": "$pageSize",
      }),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur ${response.statusCode}: Impossible de charger les cartes");
    }

    final List<dynamic> cards = json.decode(response.body);

    
    final ids = cards
        .map((c) => (c as Map<String, dynamic>)["id"]?.toString() ?? "")
        .where((id) => id.isNotEmpty && !id.contains("?"))
        .toList();

    
    final detailed = await Future.wait(
      ids.map((id) async {
        try {
          return await fetchCardById(id);
        } catch (_) {
          return null; // ignore carte non trouvée
        }
      }),
    );

    return detailed.whereType<PokemonCard>().toList();
  }

  Future<List<PokemonCard>> searchCards(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final response = await http.get(
      _uri("/cards", {
        "name": q, // filtrage côté API
        "pagination:page": "1",
        "pagination:itemsPerPage": "20",
      }),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur ${response.statusCode}: Recherche impossible");
    }

    final List<dynamic> cards = json.decode(response.body);

    final ids = cards
        .map((c) => (c as Map<String, dynamic>)["id"]?.toString() ?? "")
        .where((id) => id.isNotEmpty && !id.contains("?"))
        .toList();

    final detailed = await Future.wait(
      ids.map((id) async {
        try {
          return await fetchCardById(id);
        } catch (_) {
          return null;
        }
      }),
    );

    return detailed.whereType<PokemonCard>().toList();
  }

  Future<PokemonCard> fetchCardById(String id) async {
    final response = await http.get(
      _uri("/cards/$id"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PokemonCard.fromJson(data);
    }

    if (response.statusCode == 404) {
      throw Exception("Carte non trouvée ($id)");
    }

    throw Exception("Erreur ${response.statusCode} sur $id");
  }
}
