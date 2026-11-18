import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: const _UsersBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
    );
  }
}

class _UsersBody extends StatelessWidget {
  const _UsersBody();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    if (m.loading) return const LoadingView();

    // Exhaustive: ApiException is sealed, so no default.
    return switch (m.error) {
      null => UserList(m.items, onRefresh: m.load),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const MessageView(
        icon: Icons.block,
        text: 'The request was rejected (4xx).',
      ),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class UserList extends StatelessWidget {
  const UserList(this.users, {required this.onRefresh, super.key});

  final List<User> users;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${u.id}')),
            title: Text(u.name),
            subtitle: Text(
              u.address.city.isEmpty
                  ? u.email
                  : '${u.email} · ${u.address.city}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserDetailScreen(user: u),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    required this.icon,
    required this.text,
    this.onRetry,
    super.key,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            if (retry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Offline extends StatelessWidget {
  const Offline({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: Icons.wifi_off,
    text: 'No connection.\nCheck the network and try again.',
    onRetry: onRetry,
  );
}

class ServerError extends StatelessWidget {
  const ServerError(this.status, {required this.onRetry, super.key});

  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: Icons.cloud_off,
    text: 'The server is having trouble ($status).',
    onRetry: onRetry,
  );
}

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  // A bug report, not a Retry.
  @override
  Widget build(BuildContext context) => const MessageView(
    icon: Icons.bug_report,
    text: 'Could not read the server response.',
  );
}
