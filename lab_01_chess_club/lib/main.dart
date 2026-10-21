import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'models/chess_category.dart';
import 'models/chess_night.dart';
import 'widgets/chess_night_card.dart';
import 'widgets/empty_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NightsPage());
  }
}

class NightsPage extends StatefulWidget {
  const NightsPage({super.key});

  @override
  State<NightsPage> createState() => _NightsPageState();
}

class _NightsPageState extends State<NightsPage> {
  List<ChessNight> _nights = buildSeed();
  final _searchController = TextEditingController();
  String _query = '';
  ChessCategory? _category;
  bool _showPast = false;

  List<ChessNight> get _visible {
    final list = _nights
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

  void _toggleFavourite(String id) {
    setState(() {
      _nights = [
        for (final n in _nights)
          if (n.id == id) n.copyWith(favourite: !n.favourite) else n,
      ];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCard(ChessNight night) {
    return ChessNightCard(
      night: night,
      onFavourite: () => _toggleFavourite(night.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChessClub')),
      body: Column(
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
                    message: 'No nights match your search',
                    actionLabel: 'Clear search',
                    onAction: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  );
                }
                if (constraints.maxWidth >= 600) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 360,
                          childAspectRatio: 3,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _buildCard(items[index]),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) => _buildCard(items[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
