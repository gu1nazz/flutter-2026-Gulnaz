import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({required this.user, super.key});

  final User user;

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
          ListTile(leading: const Icon(Icons.email), title: Text(user.email)),
          // Taps do nothing yet — Practice 12 adds url_launcher.
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(website ?? '—'),
            onTap: website == null ? null : () {},
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
        ],
      ),
    );
  }
}
