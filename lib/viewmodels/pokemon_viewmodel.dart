
import 'package:flutter/material.dart';
import '../models/pokemon_card.dart';
import '../services/tcg_service.dart';

class PokemonViewModel extends ChangeNotifier {
  final TcgService _service = TcgService();

  // États pour Explore
  final List<PokemonCard> _exploreCards = [];
  List<PokemonCard> get exploreCards => _exploreCards;
  
  // États pour Search
  List<PokemonCard> _searchResults = [];
  List<PokemonCard> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // Charger les cartes initiales pour Explorer
  Future<void> loadExploreCards({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _exploreCards.clear();
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCards = await _service.fetchCards(page: _currentPage, pageSize: 20);
      
      if (newCards.isEmpty) {
        _hasMore = false;
      } else {
        _exploreCards.addAll(newCards);
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rechercher des cartes par nom
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _errorMessage = null;
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    _searchResults.clear();
    notifyListeners();

    try {
      _searchResults = await _service.searchCards(query);
      
      if (_searchResults.isEmpty) {
        _errorMessage = "Aucune carte trouvée pour '$query'";
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _searchResults.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Réinitialiser les résultats de recherche
  void clearSearch() {
    _searchResults.clear();
    _errorMessage = null;
    notifyListeners();
  }

  // Réinitialiser l'état d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
