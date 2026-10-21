import 'package:flutter/material.dart';

import '../models/chess_night.dart';
import '../utils/format.dart';

class ChessNightCard extends StatelessWidget {
  const ChessNightCard({
    super.key,
    required this.night,
    required this.onFavourite,
  });

  final ChessNight night;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: night.category.color(scheme),
                  child: Icon(night.category.icon),
                ),
                if (night.isFull)
                  const Positioned(
                    right: -8,
                    top: -8,
                    child: Badge(label: Text('FULL')),
                  )
                else if (night.freePlaces <= 5)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Badge(label: Text('${night.freePlaces} left')),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDateTime(night.startsAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    night.place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavourite,
              icon: Icon(
                night.favourite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
