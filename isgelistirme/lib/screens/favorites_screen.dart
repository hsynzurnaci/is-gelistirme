import 'package:flutter/material.dart';
import '../models/business.dart';
import 'business_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Business> businesses;
  final Function(Business) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.businesses,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteBusinesses = businesses.where((b) => b.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: favoriteBusinesses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz favori işletmeniz yok.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favoriteBusinesses.length,
              itemBuilder: (context, index) {
                final business = favoriteBusinesses[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(business.name),
                    subtitle: Text(
                        '${business.address}\nPuan: ${business.rating.toStringAsFixed(1)}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: business.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => onToggleFavorite(business),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessDetailScreen(
                            business: business,
                            onUpdate: (updatedBusiness) {
                              onToggleFavorite(updatedBusiness);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
