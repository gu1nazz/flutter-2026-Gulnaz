import 'package:flutter/material.dart';

import 'data/seed.dart';
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

class NightsPage extends StatelessWidget {
  const NightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nights = buildSeed();
    return Scaffold(
      appBar: AppBar(title: const Text('ChessClub')),
      body: ListView.builder(
        itemCount: nights.length,
        itemBuilder: (context, index) {
          final night = nights[index];
          return ChessNightCard(night: night);
        },
      ),
    );
  }
}
