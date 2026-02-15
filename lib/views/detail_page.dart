import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_card.dart';

class DetailPage extends StatelessWidget {
  final PokemonCard card;

  const DetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image de la carte
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(20),
              child: Hero(
                tag: card.id,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: card.largeImageUrl.isNotEmpty 
                        ? card.largeImageUrl 
                        : card.imageUrl,
                    height: 400,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      height: 400,
                      child: Icon(Icons.error, size: 60),
                    ),
                  ),
                ),
              ),
            ),
            
            // Informations de la carte
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et rareté
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          card.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        label: Text(
                          card.rarity,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: _getRarityColor(card.rarity),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Statistiques de base
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistiques',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildStatRow(
                            'HP',
                            card.hp,
                            Icons.favorite,
                            Colors.red,
                          ),
                          if (card.types.isNotEmpty)
                            _buildStatRow(
                              'Type(s)',
                              card.types.join(', '),
                              Icons.category,
                              Colors.blue,
                            ),
                          if (card.artist != null)
                            _buildStatRow(
                              'Artiste',
                              card.artist!,
                              Icons.brush,
                              Colors.purple,
                            ),
                          _buildStatRow(
                            'ID',
                            card.id,
                            Icons.tag,
                            Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Attaques
                  if (card.attacks.isNotEmpty) ...[
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attaques',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            ...card.attacks.map((attack) => _buildAttackCard(attack)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttackCard(Attack attack) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  attack.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              if (attack.damage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    attack.damage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
          if (attack.cost.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: attack.cost.map((energy) {
                return Chip(
                  label: Text(
                    energy,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getEnergyColor(energy),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
          if (attack.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              attack.text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey.shade300;
      case 'uncommon':
        return Colors.green.shade200;
      case 'rare':
        return Colors.blue.shade200;
      case 'rare holo':
      case 'rare rainbow':
      case 'rare secret':
        return Colors.purple.shade200;
      default:
        return Colors.amber.shade200;
    }
  }

  Color _getEnergyColor(String energy) {
    switch (energy.toLowerCase()) {
      case 'fire':
        return Colors.orange.shade200;
      case 'water':
        return Colors.blue.shade200;
      case 'grass':
        return Colors.green.shade200;
      case 'lightning':
        return Colors.yellow.shade200;
      case 'psychic':
        return Colors.purple.shade200;
      case 'fighting':
        return Colors.brown.shade200;
      case 'darkness':
        return Colors.grey.shade700;
      case 'metal':
        return Colors.blueGrey.shade200;
      case 'fairy':
        return Colors.pink.shade200;
      case 'dragon':
        return Colors.deepOrange.shade200;
      case 'colorless':
        return Colors.grey.shade300;
      default:
        return Colors.grey.shade200;
    }
  }
}
