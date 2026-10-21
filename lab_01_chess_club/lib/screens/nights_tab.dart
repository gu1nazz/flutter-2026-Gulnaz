import 'package:flutter/material.dart';

import '../models/chess_category.dart';
import '../models/chess_night.dart';
import '../widgets/chess_night_card.dart';
import '../widgets/empty_state.dart';

/// Tab 1. The list is owned by the shell: it arrives as a parameter and every
/// change goes back up through a callback. Only the search and the filters
/// live here, because nobody else needs them.
class NightsTab extends StatefulWidget {
  const NightsTab({
    super.key,
    required this.nights,
    required this.onToggleFavourite,
    required this.onOpen,
  });

  final List<ChessNight> nights;
  final void Function(String id) onToggleFavourite;
  final void Function(ChessNight night) onOpen;

  @override
  State<NightsTab> createState() => _NightsTabState();
}

class _NightsTabState extends State<NightsTab> {
  final _searchController = TextEditingController();
  String _query = '';
  ChessCategory? _category;
  bool _showPast = false;

  List<ChessNight> get _visible {
    final list = widget.nights
        .where(
          (n) =>
              n.title.toLowerCase().contains(_query.toLowerCase()) &&
              (_category == null || n.category == _category) &&
              (_showPast || !n.isPast),
        )
        .toList();
    list.sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
      return a.startsAt.compareTo(b.startsAt);
    });
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCard(ChessNight night) {
    return ChessNightCard(
      night: night,
      onFavourite: () => widget.onToggleFavourite(night.id),
      onTap: () => widget.onOpen(night),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in ChessCategory.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(c.icon),
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
              ],
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final items = _visible;
              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off,
                  message: widget.nights.isEmpty
                      ? 'No nights yet. Tap + to add one'
                      : 'No nights match your search',
                  actionLabel: _query.isEmpty ? null : 'Clear search',
                  onAction: _query.isEmpty
                      ? null
                      : () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                );
              }
              if (constraints.maxWidth >= 600) {
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisExtent: 150,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildCard(items[index]),
                );
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) => _buildCard(items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
