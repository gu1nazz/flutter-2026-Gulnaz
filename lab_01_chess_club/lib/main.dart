import 'package:chess_club/utils/format.dart';
import 'package:flutter/material.dart';

import 'data/seed.dart';

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
          return ListTile(
            title: Text(night.title),
            subtitle: Text(formatDateTime(night.startsAt)),
          );
        },
      ),
    );
  }
}
