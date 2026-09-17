import 'models.dart';
class Library {
  final List<LibraryItem> items = [];
  void add(LibraryItem item) => items.add(item);
  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) return item;
    }
    return null;
  }
  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';
  late final DateTime openedAt;

  void open() => openedAt = DateTime.now();

  String? _cachedReport;

  List<Book> get _books => items.whereType<Book>().toList();

  Iterable<String> get allTitles => items.map((item) => item.title);
  List<Book> get booksAfter2010 =>
      _books.where((b) => b.year > 2010).toList();

  double get averagePages =>

      _books.isEmpty
          ? 0
          : _books.fold<int>(0, (sum, b) => sum + b.pages) / _books.length;

  Map<String, int> get booksPerAuthor => _books.fold<Map<String, int>>(
        {},
        (map, b) => map..update(b.author.name, (v) => v + 1, ifAbsent: () => 1),
      );

  Set<String> get distinctAuthors =>
      _books.map((b) => b.author.name).toSet();

  Set<Genre> get genresPresent => _books.map((b) => b.genre).toSet();

  List<String> get _catalogueLines => [
        'CATALOGUE',
        for (final b in _books) '${b.title} (${b.year})',
        ...distinctAuthors,
        if (_books.any((b) => b.pages == 0)) '(incomplete data)',
      ];

  String report() => _cachedReport ??= _catalogueLines.join('\n');
}