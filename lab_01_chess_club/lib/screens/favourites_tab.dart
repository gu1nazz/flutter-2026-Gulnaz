import 'package:flutter/material.dart';

import '../models/chess_night.dart';
import '../widgets/chess_night_card.dart';
import '../widgets/empty_state.dart';

/// Tab 2. Shows only the favourites of the list that the shell owns.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.nights,
    required this.onToggleFavourite,
    required this.onOpen,
    required this.onBrowse,
  });

  final List<ChessNight> nights;
  final void Function(String id) onToggleFavourite;
  final void Function(ChessNight night) onOpen;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = nights.where((n) => n.favourite).toList();
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse nights',
        onAction: onBrowse,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: favourites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final night = favourites[index];
        return ChessNightCard(
          night: night,
          onFavourite: () => onToggleFavourite(night.id),
          onTap: () => onOpen(night),
        );
      },
    );
  }
}
