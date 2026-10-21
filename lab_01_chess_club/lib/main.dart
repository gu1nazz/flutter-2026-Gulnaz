import 'package:flutter/material.dart';

import 'data/seed.dart';
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

  void _toggleFavourite(String id) {
    setState(() {
      _nights = [
        for (final n in _nights)
          if (n.id == id) n.copyWith(favourite: !n.favourite) else n,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChessClub')),
      body: ListView.builder(
        itemCount: _nights.length,
        itemBuilder: (context, index) {
          final night = _nights[index];
          return ChessNightCard(
            night: night,
            onFavourite: () => _toggleFavourite(night.id),
          );
        },
      ),
    );
  }
}
