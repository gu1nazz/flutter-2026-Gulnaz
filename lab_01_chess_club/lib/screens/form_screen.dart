import 'package:flutter/material.dart';

import '../models/chess_category.dart';
import '../models/chess_night.dart';
import '../routes.dart';
import '../utils/format.dart';

/// New and edit in one screen. Receives [FormArgs] (an item or null) and
/// returns a [ChessNight] through Navigator.pop.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final ChessNight _base;
  late final DateTime? _initialDate;
  late final TimeOfDay? _initialTime;

  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _boardsController;
  late final TextEditingController _rulesController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _boardsFocus = FocusNode();
  final _rulesFocus = FocusNode();

  late ChessCategory _category;
  late bool _online;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  bool get _isNew => widget.args.night == null;

  @override
  void initState() {
    super.initState();
    final existing = widget.args.night;
    final base = existing ?? ChessNight.empty();
    _base = base;
    _initialDate = existing == null
        ? null
        : DateTime(
            existing.startsAt.year,
            existing.startsAt.month,
            existing.startsAt.day,
          );
    _initialTime = existing == null
        ? null
        : TimeOfDay.fromDateTime(existing.startsAt);
    _date = _initialDate;
    _time = _initialTime;
    _category = base.category;
    _online = base.online;
    _titleController = TextEditingController(text: base.title);
    _placeController = TextEditingController(text: base.place);
    _boardsController = TextEditingController(text: base.boards.toString());
    _rulesController = TextEditingController(text: base.rules ?? '');
    _dateController = TextEditingController(text: _dateText(_date));
    _timeController = TextEditingController(text: _timeText(_time));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _boardsController.dispose();
    _rulesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _boardsFocus.dispose();
    _rulesFocus.dispose();
    super.dispose();
  }

  String _dateText(DateTime? date) => date == null ? '' : formatDate(date);

  String _timeText(TimeOfDay? time) =>
      time == null ? '' : formatTime(time.hour, time.minute);

  /// Current values compared with the ones the form opened with.
  bool get _dirty =>
      _titleController.text != _base.title ||
      _placeController.text != _base.place ||
      _boardsController.text != _base.boards.toString() ||
      _rulesController.text != (_base.rules ?? '') ||
      _category != _base.category ||
      _online != _base.online ||
      _date != _initialDate ||
      _time != _initialTime;

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  String? _validateTitle(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 3 || text.length > 60) {
      return 'Title must be 3-60 characters';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _online ? 'Meeting link is required' : 'Place is required';
    }
    if (_online && !text.contains('://')) {
      return 'The link must contain ://';
    }
    return null;
  }

  String? _validateBoards(String? value) {
    final number = int.tryParse((value ?? '').trim());
    if (number == null) return 'Enter a whole number';
    if (number < 1 || number > 500) return 'Between 1 and 500';
    final current = widget.args.night?.playersCount ?? 0;
    if (number < current) return 'Not below the current $current players';
    return null;
  }

  String? _validateDate(String? value) {
    return _date == null ? 'Pick a date' : null;
  }

  String? _validateTime(String? value) {
    final date = _date;
    final time = _time;
    if (time == null) return 'Pick a time';
    if (_isNew && date != null) {
      if (_combine(date, time).isBefore(DateTime.now())) {
        return 'Must be in the future';
      }
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: _isNew ? now : DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateController.text = formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeController.text = formatTime(picked.hour, picked.minute);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    final date = _date;
    final time = _time;
    if (date == null || time == null) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final rules = _rulesController.text.trim();
    final item = ChessNight(
      id:
          widget.args.night?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _category,
      startsAt: _combine(date, time),
      boards: int.parse(_boardsController.text.trim()),
      players: _base.players,
      online: _online,
      place: _placeController.text.trim(),
      rules: rules.isEmpty ? null : rules,
      favourite: _base.favourite,
    );
    Navigator.pop(context, item);
  }

  Future<bool?> _confirmDiscard() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (discard != true || !context.mounted) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New night' : 'Edit night')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: () => setState(() {}),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  decoration: const InputDecoration(labelText: 'Title'),
                  maxLength: 60,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  validator: _validateTitle,
                ),
                DropdownButtonFormField<ChessCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final c in ChessCategory.values)
                      DropdownMenuItem(value: c, child: Text(c.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                  validator: (value) =>
                      value == null ? 'Pick a category' : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online'),
                  subtitle: const Text('The place becomes a meeting link'),
                  value: _online,
                  onChanged: (value) => setState(() => _online = value),
                ),
                TextFormField(
                  controller: _placeController,
                  focusNode: _placeFocus,
                  decoration: InputDecoration(
                    labelText: _online ? 'Meeting link' : 'Place',
                  ),
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onFieldSubmitted: (_) => _boardsFocus.requestFocus(),
                  validator: _validatePlace,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _boardsController,
                  focusNode: _boardsFocus,
                  decoration: const InputDecoration(
                    labelText: 'Boards (1-500)',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onFieldSubmitted: (_) => _rulesFocus.requestFocus(),
                  validator: _validateBoards,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickDate,
                  validator: _validateDate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: _pickTime,
                  validator: _validateTime,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rulesController,
                  focusNode: _rulesFocus,
                  decoration: const InputDecoration(
                    labelText: 'Rules (optional)',
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
