import 'dart:async';

import 'package:flutter/material.dart';

import '../models/chess_night.dart';
import '../models/countdown.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

/// Pushed from a card. It gets the item and callbacks through [DetailArgs].
/// It keeps a local copy of the item so the screen updates at once, and sends
/// every change up through the callbacks.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late ChessNight _night;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _night = widget.args.night;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _update(ChessNight updated) {
    widget.args.onChanged(updated);
    setState(() => _night = updated);
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }

  String _countdownLabel(Countdown countdown) => switch (countdown) {
    Upcoming(:final remaining) => 'Starts in ${_formatDuration(remaining)}',
    Started(:final elapsed) => 'Started ${_formatDuration(elapsed)} ago',
    Ended() => 'Ended',
  };

  Future<void> _join() async {
    final name = widget.args.profile.name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              if (mounted) Navigator.of(context).pop();
              widget.args.onOpenProfile();
            },
          ),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Join this night?'),
        content: Text('Add "$name" to "${_night.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _update(_night.copyWith(players: [..._night.players, name]));
  }

  void _leave() {
    final name = widget.args.profile.name;
    _update(
      _night.copyWith(
        players: [
          for (final player in _night.players)
            if (player != name) player,
        ],
      ),
    );
  }

  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<ChessNight>(
      context,
      Routes.form,
      arguments: FormArgs(night: _night),
    );
    if (edited == null || !mounted) return;
    _update(edited);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this night?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.args.onDelete(_night.id);
    Navigator.pop(context);
  }

  void _onMenu(_MenuAction action) {
    switch (action) {
      case _MenuAction.edit:
        _edit();
      case _MenuAction.delete:
        _delete();
    }
  }

  Widget _buildAbout() {
    final (:taken, :free) = _night.places;
    return ListView(
      children: [
        ListTile(
          title: const Text('When'),
          subtitle: Text(formatDateTime(_night.startsAt)),
        ),
        ListTile(
          title: Text(_night.online ? 'Link' : 'Place'),
          subtitle: Text(_night.place),
        ),
        ListTile(
          title: const Text('Boards'),
          subtitle: Text('$taken taken, $free free'),
        ),
        if (_night.rules case final rules?)
          ListTile(title: const Text('Rules'), subtitle: Text(rules)),
      ],
    );
  }

  Widget _buildPlayers(String myName) {
    final players = _night.players;
    if (players.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Nobody has joined yet',
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        for (final player in players)
          ListTile(
            title: Text(
              player == myName ? 'You' : player,
              style: player == myName
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
            tileColor: player == myName ? scheme.primaryContainer : null,
          ),
      ],
    );
  }

  Widget _buildAction(bool joined) {
    if (joined) {
      return OutlinedButton(onPressed: _leave, child: const Text('Leave'));
    }
    final blocked = _night.isFull || _night.isPast;
    final label = _night.isFull
        ? 'Full'
        : _night.isPast
        ? 'Already started'
        : 'Join';
    return FilledButton(onPressed: blocked ? null : _join, child: Text(label));
  }

  @override
  Widget build(BuildContext context) {
    final myName = widget.args.profile.name;
    final joined = _night.contains(myName);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _night.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: _onMenu,
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(
              night: _night,
              countdownLabel: _countdownLabel(_night.countdown),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Players (${_night.playersCount}/${_night.boards})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [_buildAbout(), _buildPlayers(myName)],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildAction(joined),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.night, required this.countdownLabel});

  final ChessNight night;
  final String countdownLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/header.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                ColoredBox(color: scheme.surfaceContainerHighest),
          ),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: night.category.color(scheme),
              child: Icon(night.category.icon, size: 36),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Chip(label: Text(night.category.label)),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Chip(label: Text(countdownLabel)),
          ),
        ],
      ),
    );
  }
}
