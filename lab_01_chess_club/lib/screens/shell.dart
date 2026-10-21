import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/chess_night.dart';
import '../models/profile.dart';
import '../routes.dart';
import 'favourites_tab.dart';
import 'nights_tab.dart';
import 'profile_tab.dart';

/// The shell owns the data: the list of items and the profile live in its
/// State. Tabs receive them as parameters and send changes up as callbacks.
class Shell extends StatefulWidget {
  const Shell({super.key, required this.themeMode, required this.onThemeMode});

  final ThemeMode themeMode;
  final void Function(ThemeMode mode) onThemeMode;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<ChessNight> _nights = buildSeed();
  Profile _profile = const Profile.empty();
  int _index = 0;

  void _goTo(int index) {
    setState(() => _index = index);
  }

  void _toggleFavourite(String id) {
    setState(() {
      _nights = [
        for (final n in _nights)
          if (n.id == id) n.copyWith(favourite: !n.favourite) else n,
      ];
    });
  }

  void _replace(ChessNight updated) {
    setState(() {
      _nights = [
        for (final n in _nights)
          if (n.id == updated.id) updated else n,
      ];
    });
  }

  void _delete(String id) {
    setState(() {
      _nights = _nights.where((n) => n.id != id).toList();
    });
  }

  void _setProfile(Profile profile) {
    setState(() => _profile = profile);
  }

  void _openDetail(ChessNight night) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        night: night,
        profile: _profile,
        onChanged: _replace,
        onDelete: _delete,
        onOpenProfile: () => _goTo(2),
      ),
    );
  }

  Future<void> _create() async {
    final created = await Navigator.pushNamed<ChessNight>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    setState(() => _nights = [..._nights, created]);
  }

  Future<void> _showAbout() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'ChessClub: a small app for chess club nights. '
          'All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'This restores the original nights and clears your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _nights = buildSeed();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['ChessClub', 'Favourites', 'Profile'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'ChessClub',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbout();
                },
              ),
              ListTile(
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _resetData();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          NightsTab(
            nights: _nights,
            onToggleFavourite: _toggleFavourite,
            onOpen: _openDetail,
          ),
          FavouritesTab(
            nights: _nights,
            onToggleFavourite: _toggleFavourite,
            onOpen: _openDetail,
            onBrowse: () => _goTo(0),
          ),
          ProfileTab(
            profile: _profile,
            nights: _nights,
            themeMode: widget.themeMode,
            onProfileChanged: _setProfile,
            onThemeMode: widget.onThemeMode,
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: _create,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Nights'),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
