import 'package:flutter_test/flutter_test.dart';
import 'package:playx/playx.dart';

void main() {
  group('AreEqual', () {
    test('matches equal text case sensitively by default', () {
      final rule = AreEqual(other: () => 'Secret');
      expect(rule.isValid('Secret'), isTrue);
      expect(rule.isValid('secret'), isFalse);
    });

    test('ignores case when caseSensitive is false', () {
      final rule = AreEqual(other: () => 'Secret', caseSensitive: false);
      expect(rule.isValid('sECRET'), isTrue);
      expect(rule.isValid('other'), isFalse);
    });

    test('reads the other value lazily', () {
      var other = 'a';
      final rule = AreEqual(other: () => other);
      expect(rule.isValid('a'), isTrue);
      other = 'b';
      expect(rule.isValid('a'), isFalse);
    });
  });

  group('AreNotEqual', () {
    test('rejects equal text case sensitively by default', () {
      final rule = AreNotEqual(other: () => 'Secret');
      expect(rule.isValid('Secret'), isFalse);
      expect(rule.isValid('secret'), isTrue);
    });

    test('ignores case when caseSensitive is false', () {
      final rule = AreNotEqual(other: () => 'Secret', caseSensitive: false);
      expect(rule.isValid('SECRET'), isFalse);
      expect(rule.isValid('other'), isTrue);
    });
  });
}
