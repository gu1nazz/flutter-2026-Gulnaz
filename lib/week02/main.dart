import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library()..open();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }
  print(library.report());
  print('');

  print('All titles: ${library.allTitles.toList()}');
  print('Books after 2010: '
      '${library.booksAfter2010.map((b) => b.title).toList()}');
  print('Average pages: ${library.averagePages.toStringAsFixed(1)}');
  print('Books per author: ${library.booksPerAuthor}');
  print('Distinct authors: ${library.distinctAuthors}');
  print('Genres present: ${library.genresPresent}');
  print('');

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);
  print('Stats: count=${stats.count}, '
      'avgPages=${stats.avgPages.toStringAsFixed(1)}');
  print('');

  final states = <ShelfState>[
    const Empty(),
    Ready(books),
    const Broken('shelf collapsed'),
  ];
  for (final state in states) {
    print(describe(state));
  }
}