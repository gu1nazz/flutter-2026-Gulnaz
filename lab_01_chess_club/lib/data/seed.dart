import '../models/chess_category.dart';
import '../models/chess_night.dart';

List<ChessNight> buildSeed() {
  final now = DateTime.now();
  return [
    ChessNight(
      id: '1',
      title: 'Blitz Friday',
      category: ChessCategory.blitz,
      startsAt: now.add(const Duration(days: 2)),
      boards: 8,
      players: ['Aida', 'Dana'],
      online: false,
      place: 'KBTU, room 305',
      favourite: false,
    ),
    ChessNight(
      id: '2',
      title: 'KBTU Open Rapid Championship: Qualifier Rounds for Beginners',
      category: ChessCategory.rapid,
      startsAt: now.add(const Duration(days: 1)),
      boards: 4,
      players: ['Almas'],
      online: false,
      place: 'KBTU, 269 room',
      favourite: false,
    ),
    ChessNight(
      id: '3',
      title: 'Simul Tuesday',
      category: ChessCategory.simul,
      startsAt: now.subtract(const Duration(days: 1)),
      boards: 2,
      players: ['Naz'],
      online: false,
      place: 'KBTU, 150 room',
      favourite: false,
    ),
  ];
}
