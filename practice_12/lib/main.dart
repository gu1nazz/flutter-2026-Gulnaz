import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'dev_checks.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

Future<void> main() async {
  // 1. The binding — before any plugin.
  WidgetsFlutterBinding.ensureInitialized();

  // flutter run --dart-define=CHECKS=true → Level 2/3 checks of Practice 11.
  const checks = bool.fromEnvironment('CHECKS');
  if (checks) await devChecks();

  // 2. The disk — before the first frame, so there is no flash.
  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool(SettingsModel.darkKey) ?? false;
  final city = await prefs.getString(SettingsModel.cityKey); // String?
  final avatar = await prefs.getString(SettingsModel.avatarKey); // String?

  const store = SecureStore();

  // iOS keeps the Keychain after an uninstall: on the first run after an
  // install, forget any token left over from a previous install.
  if (await prefs.getBool('installed') == null) {
    await store.clear();
    await prefs.setBool('installed', true);
  }
  final token = await store.readToken();

  // The composition root: the only place that creates the http Client.
  final api = ApiClient(Client(), store);

  // 3. runApp.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              SettingsModel(prefs, dark: dark, city: city, avatarPath: avatar),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
        ChangeNotifierProvider(
          create: (_) => UsersModel(UserRepository(api, UsersCache()))..load(),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<SettingsModel>().dark;
    final signedIn = context.watch<AuthModel>().signedIn;
    return MaterialApp(
      title: 'Users API',
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: signedIn ? const UsersScreen() : const LoginScreen(),
    );
  }
}
