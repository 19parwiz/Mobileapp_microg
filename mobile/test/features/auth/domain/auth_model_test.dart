import 'package:flutter_test/flutter_test.dart';
import 'package:diploma_mobile_app/features/auth/domain/auth_model.dart';

void main() {
  group('AuthModel', () {
    test('fromJson reads accessToken as token fallback', () {
      final model = AuthModel.fromJson({
        'id': 5,
        'email': 'user@example.com',
        'accessToken': 'abc-123',
        'accountStatus': 'ACTIVE',
        'emailVerified': true,
      });

      expect(model.id, '5');
      expect(model.token, 'abc-123');
      expect(model.hasUsableToken, isTrue);
      expect(model.accountStatus, 'ACTIVE');
      expect(model.emailVerified, isTrue);
    });

    test('toJson keeps only defined optional fields', () {
      const model = AuthModel(
        id: '1',
        email: 'user@example.com',
        name: 'User',
      );

      final json = model.toJson();

      expect(json['id'], '1');
      expect(json['email'], 'user@example.com');
      expect(json['name'], 'User');
      expect(json.containsKey('message'), isFalse);
      expect(json.containsKey('accountStatus'), isFalse);
      expect(json.containsKey('emailVerified'), isFalse);
    });
  });
}
