import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/features/users/user.dart';

void main() {
  const json = <String, dynamic>{
    'id': 1,
    'name': 'Leanne Graham',
    'username': 'Bret',
    'email': 'Sincere@april.biz',
    'address': {
      'street': 'Kulas Light',
      'suite': 'Apt. 556',
      'city': 'Gwenborough',
      'zipcode': '92998-3874',
      'geo': {'lat': '-37.3159', 'lng': '81.1496'},
    },
    'phone': '1-770-736-8031 x56442',
    'website': 'hildegard.org',
    'company': {
      'name': 'Romaguera-Crona',
      'catchPhrase': 'Multi-layered client-server neural-net',
      'bs': 'harness real-time e-markets',
    },
  };

  test('fromJson parses nested objects and geo as double', () {
    final u = User.fromJson(json);
    expect(u.id, 1);
    expect(u.address.city, 'Gwenborough');
    expect(u.address.geo.lat, -37.3159);
    expect(u.company.name, 'Romaguera-Crona');
    expect(u.phoneDigits, '1770736803156442');
  });

  test('toJson round-trip gives the same JSON and an equal user', () {
    final u = User.fromJson(json);
    expect(u.toJson(), json);
    expect(User.fromJson(u.toJson()), u);
  });

  test('a wrong type throws at the cast', () {
    final broken = Map<String, dynamic>.of(json)..['id'] = '1';
    expect(() => User.fromJson(broken), throwsA(isA<TypeError>()));
  });
}
