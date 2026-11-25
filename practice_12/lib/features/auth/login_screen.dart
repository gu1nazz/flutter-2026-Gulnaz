import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../users/users_model.dart';
import 'auth_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  static String? _validateEmail(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Required';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
        ? null
        : 'Not a valid email';
  }

  static String? _validatePassword(String? v) {
    final t = v ?? '';
    if (t.isEmpty) return 'Required';
    return t.length < 8 ? 'At least 8 characters' : null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final auth = context.read<AuthModel>();
    final users = context.read<UsersModel>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await auth.login(_email.text.trim(), _password.text);
      // Reload so the next request carries "Authorization: Bearer …".
      unawaited(users.load());
    } on InvalidCredentialsException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Wrong email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthModel>().busy;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: 24),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: _validatePassword,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: busy ? null : _submit,
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Fake login: any email and a password of 8+ characters.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
