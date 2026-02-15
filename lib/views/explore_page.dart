import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/pokemon_viewmodel.dart';
import 'widgets/app_drawer.dart';
import 'detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Charger les données initiales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PokemonViewModel>(context, listen: false);
      if (viewModel.exploreCards.isEmpty) {
        viewModel.loadExploreCards();
      }
    });

    // Écouter le scroll pour le scroll infini
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final viewModel = Provider.of<PokemonViewModel>(context, listen: false);
      if (!viewModel.isLoading && viewModel.hasMore) {
        viewModel.loadExploreCards();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PokemonViewModel>(context, listen: false)
                  .loadExploreCards(refresh: true);
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<PokemonViewModel>(
        builder: (context, viewModel, child) {
          // État initial de chargement
          if (viewModel.isLoading && viewModel.exploreCards.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des cartes...'),
                ],
              ),
            );
          }

          // État d'erreur
          if (viewModel.errorMessage != null && viewModel.exploreCards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      viewModel.loadExploreCards(refresh: true);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Affichage de la grille
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.loadExploreCards(refresh: true);
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Grille de cartes
                SliverPadding(
                  padding: const EdgeInsets.all(10),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final card = viewModel.exploreCards[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(card: card),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Hero(
                              tag: card.id,
                              child: CachedNetworkImage(
                                imageUrl: card.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, size: 40),
                                      SizedBox(height: 8),
                                      Text(
                                        'Erreur de chargement',
                                        style: TextStyle(fontSize: 10),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: viewModel.exploreCards.length,
                    ),
                  ),
                ),
                
                // Indicateur de chargement en bas
                if (viewModel.isLoading && viewModel.exploreCards.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                
                // Message "Plus de cartes"
                if (!viewModel.hasMore && viewModel.exploreCards.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Toutes les cartes ont été chargées',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
