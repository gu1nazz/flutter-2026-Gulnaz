import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_model.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({required this.user, super.key});

  final User user;

  /// launchUrl answers with a bool: false = no app can open this.
  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    bool ok;
    try {
      ok = await launchUrl(uri);
    } on PlatformException {
      ok = false;
    }
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No app can open this')),
      );
    }
  }

  /// Debug only: proves the token exists without ever logging it.
  Future<void> _copyToken(BuildContext context) async {
    final token = context.read<AuthModel>().token;
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: token ?? ''));
    messenger.showSnackBar(
      SnackBar(content: Text(token == null ? 'No token' : 'Token copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.badge),
            title: Text('@${user.username}'),
            subtitle: Text('id ${user.id}'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(user.email),
            trailing: const Icon(Icons.open_in_new),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            trailing: const Icon(Icons.open_in_new),
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(website ?? '—'),
            trailing: website == null ? null : const Icon(Icons.open_in_new),
            onTap: website == null
                ? null
                : () => _open(context, Uri.parse('https://$website')),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('${a.street}, ${a.suite}'),
            subtitle: Text('${a.city} ${a.zipcode}'),
          ),
          ListTile(
            leading: const Icon(Icons.place),
            title: Text('lat ${a.geo.lat}, lng ${a.geo.lng}'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(user.company.name),
            subtitle: Text('${user.company.catchPhrase}\n${user.company.bs}'),
            isThreeLine: true,
          ),
          if (kDebugMode) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Copy token to clipboard'),
              subtitle: const Text('debug only'),
              onTap: () => _copyToken(context),
            ),
          ],
        ],
      ),
    );
  }
}
