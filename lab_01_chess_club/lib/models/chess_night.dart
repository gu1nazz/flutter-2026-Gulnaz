import 'package:chess_club/models/chess_category.dart';

class ChessNight {
  final String id;
  final String title;
  final ChessCategory category;
  final DateTime startsAt;
  final int boards;
  final List<String> players;
  final bool online;
  final String place;
  final String? rules;
  final bool favourite;

  const ChessNight({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.boards,
    required this.players,
    required this.online,
    required this.place,
    this.rules,
    required this.favourite,
  });

  int get playersCount => players.length;
  int get freePlaces => boards - playersCount;
  bool get isFull => freePlaces <= 0;

  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => players.contains(name);

  ({int taken, int free}) get places => (taken: playersCount, free: freePlaces);

  ChessNight copyWith({
    String? id,
    String? title,
    ChessCategory? category,
    DateTime? startsAt,
    int? boards,
    List<String>? players,
    bool? online,
    String? place,
    String? rules,
    bool? favourite,
  }) {
    return ChessNight(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startsAt: startsAt ?? this.startsAt,
      boards: boards ?? this.boards,
      players: players ?? this.players,
      online: online ?? this.online,
      place: place ?? this.place,
      rules: rules ?? this.rules,
      favourite: favourite ?? this.favourite,
    );
  }

  ChessNight.empty()
    : id = '',
      title = '',
      category = ChessCategory.blitz,
      startsAt = DateTime.now(),
      boards = 8,
      players = const [],
      online = false,
      place = '',
      rules = null,
      favourite = false;
}
