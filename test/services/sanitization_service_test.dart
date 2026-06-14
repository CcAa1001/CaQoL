import 'package:flutter_test/flutter_test.dart';
import 'package:caqol/services/sanitization_service.dart';

void main() {
  group('SanitizationService', () {
    test('removes control characters', () {
      final input = 'Hello\x00World\x0B!';
      final result = SanitizationService.sanitizeText(input);
      expect(result, 'HelloWorld!');
    });

    test('enforces max length', () {
      final input = 'A' * 6000;
      final result = SanitizationService.sanitizeText(input, maxLength: 5000);
      expect(result.length, 5000);
      expect(result, 'A' * 5000);
    });

    test('trims whitespace', () {
      final input = '   Hello World   ';
      final result = SanitizationService.sanitizeText(input);
      expect(result, 'Hello World');
    });

    test('handles empty strings', () {
      expect(SanitizationService.sanitizeText(''), '');
    });
  });
}
