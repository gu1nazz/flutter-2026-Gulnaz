# NOTES — Practice 9

## Level 1: total in the badge (the honest way)
- Constructors touched: **2** — `BooksScreen` (new `total`), `CartBadge` (new `total`)
- Files touched: **3** — `main.dart`, `books_screen.dart`, `cart_badge.dart`
- BooksScreen does not use `total` itself — it only passes it down (prop drilling).

## Level 1: one tap on Add
- Console lines: **7** = 1 × `BooksScreen build` + 6 × `row ...`
- `setState` in Shell rebuilds everything below it.

## Level 3: provider errors
- Loud (watch in onPressed): *"Tried to listen to a value exposed with provider,
  from outside of the widget tree."* → fix: use `read` / `listen: false`.
- Silent (read in build): no error, but the badge stays at **0** forever —
  nobody subscribed.

## Level 4: badge rebuilds, 3 presses on +
- With `watch`: **3** × `badge build`
- With `select`: **0** (removing a book → 1)

## Where does it live?
- **Cart** → provided: two routes need it.
- **Search text** → ephemeral: only the Books screen uses it.
- **Total expanded/collapsed** → ephemeral: only the Cart screen cares.
- **Theme mode** → provided (or lifted above MaterialApp): MaterialApp itself needs it.
