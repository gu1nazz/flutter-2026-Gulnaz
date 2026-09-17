class Author {
  final String name;
  final String? country;

  const Author(this.name, {this.country});
  @override
  String toString() => country == null ? name : '$name ($country)';
}
enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  final String label;
  const Genre(this.label);
  static Genre fromString(String? raw) {
    for (final g in Genre.values) {
      if (g.name == raw) return g;
    }
    return Genre.unknown;
  }
}
abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});
  String describe();
  bool get isOld => year < 1990;
}
mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow "$title"';
}
class Book extends LibraryItem with Borrowable {
  final Author author;
  final int pages;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.author,
    required this.pages,
    required this.genre,
    this.description,
  });
    factory Book.fromJson(Map<String, dynamic> json) {
    final authorName = json['author'] as String? ?? 'Unknown';
    final country = json['country'] as String?;
    return Book(
      title: json['title'] as String? ?? 'Untitled',
      year: json['year'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      author: Author(authorName, country: country),
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?,
    );
  }
  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    Author? author,
    int? pages,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      author: author ?? this.author,
      pages: pages ?? this.pages,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }
  @override
  String describe() => '$title by $author ($year, $pages pages)';
  @override
  String toString() => 'Book(title: $title, year: $year, author: $author, '
      'pages: $pages, genre: ${genre.label})';
}
class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() => '$title, issue #$issue ($year)';
}
class Ghost implements LibraryItem {
  @override
  final String title;
  @override
  final int year;

  const Ghost({required this.title, required this.year});
  @override
  String describe() => '$title — record incomplete, details lost';
  @override
  bool get isOld => year < 1990;
}