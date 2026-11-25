import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../profile/profile_screen.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final auth = context.read<AuthModel>();
    final navigator = Navigator.of(context);
    await auth.logout(); // deletes the token from the secure store
    navigator.popUntil((route) => route.isFirst); // back to the login screen
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsModel>();
    final cities = context.watch<UsersModel>().cities;
    final selected = cities.contains(s.city) ? s.city : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            secondary: const Icon(Icons.dark_mode),
            value: s.dark,
            onChanged: s.setDark,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String?>(
              key: ValueKey(selected),
              initialValue: selected,
              decoration: const InputDecoration(
                labelText: 'City filter',
                prefixIcon: Icon(Icons.location_city),
              ),
              items: [
                const DropdownMenuItem<String?>(child: Text('All cities')),
                for (final c in cities)
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: s.setCity,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile photo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
