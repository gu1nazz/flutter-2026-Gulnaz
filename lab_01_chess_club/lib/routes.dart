import 'package:flutter/material.dart';

import 'models/chess_night.dart';
import 'models/profile.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

/// Every route name lives here and nowhere else.
class Routes {
  const Routes._();

  static const shell = '/';
  static const detail = '/detail';
  static const form = '/form';
}

/// What the detail screen needs: the item, the profile and callbacks that
/// send changes back up to the shell.
class DetailArgs {
  const DetailArgs({
    required this.night,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final ChessNight night;
  final Profile profile;
  final void Function(ChessNight night) onChanged;
  final void Function(String id) onDelete;
  final VoidCallback onOpenProfile;
}

/// The form edits [night], or creates a new item when it is null.
/// It hands the result back through Navigator.pop.
class FormArgs {
  const FormArgs({this.night});

  final ChessNight? night;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  if (settings.name == Routes.detail && args is DetailArgs) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => DetailScreen(args: args),
    );
  }
  if (settings.name == Routes.form && args is FormArgs) {
    return MaterialPageRoute<ChessNight>(
      settings: settings,
      builder: (context) => FormScreen(args: args),
    );
  }
  return null;
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
