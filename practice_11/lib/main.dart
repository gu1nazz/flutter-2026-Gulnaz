import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'dev_checks.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // flutter run --dart-define=CHECKS=true → Level 2/3 checks before runApp.
  const checks = bool.fromEnvironment('CHECKS');
  if (checks) await devChecks();

  // The composition root: the only place that creates the http Client.
  runApp(
    ChangeNotifierProvider(
      create: (_) => UsersModel(UserRepository(ApiClient(Client())))..load(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const UsersScreen(),
    );
  }
}
