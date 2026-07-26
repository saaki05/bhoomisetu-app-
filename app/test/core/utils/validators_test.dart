import 'package:bhoomisetu/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty input', () {
      expect(Validators.email(''), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('accepts a valid address', () {
      expect(Validators.email('farmer@example.com'), isNull);
    });
  });

  group('Validators.indianPhone', () {
    test('rejects numbers starting with 0-5', () {
      expect(Validators.indianPhone('5123456789'), isNotNull);
    });

    test('rejects numbers that are not 10 digits', () {
      expect(Validators.indianPhone('98765432'), isNotNull);
    });

    test('accepts a valid 10-digit number starting with 6-9', () {
      expect(Validators.indianPhone('9876543210'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects passwords under 8 characters', () {
      expect(Validators.password('Ab1defg'), isNotNull);
    });

    test('rejects passwords missing an uppercase letter', () {
      expect(Validators.password('abcdefg1'), isNotNull);
    });

    test('rejects passwords missing a digit', () {
      expect(Validators.password('Abcdefgh'), isNotNull);
    });

    test('accepts a password meeting all rules', () {
      expect(Validators.password('Passw0rd1'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects a mismatch', () {
      expect(Validators.confirmPassword('Passw0rd1', 'Passw0rd2'), isNotNull);
    });

    test('accepts a match', () {
      expect(Validators.confirmPassword('Passw0rd1', 'Passw0rd1'), isNull);
    });
  });

  group('Validators.otp', () {
    test('rejects a code of the wrong length', () {
      expect(Validators.otp('12345'), isNotNull);
    });

    test('rejects a non-numeric code', () {
      expect(Validators.otp('12a456'), isNotNull);
    });

    test('accepts a valid 6-digit code', () {
      expect(Validators.otp('123456'), isNull);
    });
  });
}
