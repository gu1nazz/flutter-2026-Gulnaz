import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  static String? _validateName(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Required';
    return t.length < 2 ? 'At least 2 characters' : null;
  }

  static String? _validateUsername(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Required';
    return RegExp(r'^[A-Za-z0-9_.]{3,20}$').hasMatch(t)
        ? null
        : '3–20 letters, digits, _ or .';
  }

  static String? _validateEmail(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Required';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
        ? null
        : 'Not a valid email';
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final model = context.read<UsersModel>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final draft = User.draft(
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
    );

    try {
      await model.create(draft);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('Created ${draft.name}')));
    } on ApiException catch (e) {
      // The form stays open.
      final text = switch (e) {
        NoConnectionException() => 'No connection — try again',
        ServerException(:final status) => 'Server error ($status)',
        BadResponseException() => 'Could not read the server response',
        NotFoundException() || UnauthorizedException() => 'Request rejected',
      };
      messenger.showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<UsersModel>().saving;
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: _validateName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              textInputAction: TextInputAction.next,
              validator: _validateUsername,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 24),
            FilledButton(
              // Disabled while the request is in flight.
              onPressed: saving ? null : _save,
              child: saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
