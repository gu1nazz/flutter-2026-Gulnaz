import 'package:flutter/material.dart';

enum ChessCategory {
  blitz('Blitz', Icons.bolt),
  rapid('Rapid', Icons.timer),
  puzzle('Puzzle', Icons.extension),
  lecture('Lecture', Icons.school),
  simul('Simul', Icons.group);

  const ChessCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}
