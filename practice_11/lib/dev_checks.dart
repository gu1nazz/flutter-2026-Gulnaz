// Level 2 and Level 3 checks — run before runApp, no screen:
//   flutter run --dart-define=CHECKS=true
// Watch the output in the console / Debug Console.

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'core/api/api_client.dart';
import 'core/api/api_exception.dart';
import 'features/users/user.dart';
import 'features/users/user_repository.dart';

// The real JSON of /users/1, pasted from Postman.
const _user1 = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

Future<void> devChecks() async {
  // ---------- Level 2: the model ----------
  final user = User.fromJson(jsonDecode(_user1) as Map<String, dynamic>);
  debugPrint('L2 user: $user');
  debugPrint('L2 phoneDigits: ${user.phoneDigits}');
  final again = User.fromJson(user.toJson());
  debugPrint('L2 round-trip equal: ${again == user}');
  // Break it on purpose: in Geo.fromJson write `json['lat'] as double`,
  // or change "id": 1 to "id": "1" above → type 'String' is not a subtype…

  // ---------- Level 3: the repository ----------
  final repo = UserRepository(ApiClient(Client()));

  final all = await repo.getAll();
  debugPrint('L3 getAll: ${all.length} users');
  for (final u in all) {
    debugPrint('  ${u.id}. ${u.name}');
  }

  try {
    await repo.getById(999);
  } on NotFoundException {
    debugPrint('L3 getById(999): not found');
  }

  final created = await repo.create(
    const User.draft(name: 'Test User', username: 'test', email: 't@t.kz'),
  );
  debugPrint('L3 create: server assigned id ${created.id}');
}
