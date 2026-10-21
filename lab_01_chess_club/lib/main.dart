import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'models/chess_category.dart';
import 'models/chess_night.dart';
import 'widgets/chess_night_card.dart';

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

  List<ChessNight> get _visible => _nights
      .where(
        (n) =>
    n.title.toLowerCase().contains(_query.toLowerCase()) &&
        (_category == null || n.category == _category),
  )
      .toList();

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
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _visible.length,
              itemBuilder: (context, index) {
                final night = _visible[index];
                return ChessNightCard(
                  night: night,
                  onFavourite: () => _toggleFavourite(night.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}