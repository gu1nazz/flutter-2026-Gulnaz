import 'package:flutter/material.dart';

import '../models/chess_night.dart';
import '../models/profile.dart';

/// Tab 3. The profile and the theme mode are owned higher up; this tab only
/// edits them through callbacks.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.nights,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeMode,
  });

  final Profile profile;
  final List<ChessNight> nights;
  final ThemeMode themeMode;
  final void Function(Profile profile) onProfileChanged;
  final void Function(ThemeMode mode) onThemeMode;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Za-z]{2,5}-\d{4}$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The profile can change from outside (Reset data): keep the fields in sync.
    if (widget.profile.name != oldWidget.profile.name) {
      _nameController.text = widget.profile.name;
    }
    if (widget.profile.group != oldWidget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return _groupPattern.hasMatch(text) ? null : 'Use a format like IT-2401';
  }

  void _saveName(String value) {
    widget.onProfileChanged(widget.profile.copyWith(name: value.trim()));
  }

  void _saveGroup(String value) {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    widget.onProfileChanged(widget.profile.copyWith(group: value.trim()));
  }

  String _modeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name;
    final lists = name.isEmpty
        ? 0
        : widget.nights.where((n) => n.contains(name)).length;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onFieldSubmitted: _saveName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupController,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'IT-2401',
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                validator: _validateGroup,
                onFieldSubmitted: _saveGroup,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Theme', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_modeLabel(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeMode(mode),
              ),
          ],
        ),
      ],
    );
  }
}
