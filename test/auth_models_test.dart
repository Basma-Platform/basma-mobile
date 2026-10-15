import 'package:basma_app/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basma API data models', () {
    test('parses the backend user and verified email state', () {
      final user = BasmaUser.fromJson({
        'name': 'مستخدم',
        'email': 'person@example.com',
        'email_verified_at': '2026-10-15T12:00:00Z',
      });

      expect(user.name, 'مستخدم');
      expect(user.email, 'person@example.com');
      expect(user.isEmailVerified, isTrue);
    });

    test('treats an unverified account as unverified', () {
      final user = BasmaUser.fromJson({
        'name': 'مستخدم',
        'email': 'person@example.com',
        'email_verified_at': null,
      });

      expect(user.isEmailVerified, isFalse);
    });

    test('uses numeric governorate and city IDs', () {
      final region = BasmaRegion.fromJson({'id': 7, 'name': 'غزة'});
      expect(region.id, 7);
      expect(region.name, 'غزة');
    });
  });
}
