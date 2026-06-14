import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:caqol/services/rate_limit_service.dart';

void main() {
  group('RateLimitService', () {
    late RateLimitService service;

    setUp(() async {
      Hive.init('.');
      service = RateLimitService();
      await service.init();
      await Hive.box<List<dynamic>>('rate_limits').clear();
    });

    test('allows attempts up to limit', () {
      expect(service.recordAttempt('login', maxAttempts: 3), true);
      expect(service.recordAttempt('login', maxAttempts: 3), true);
      expect(service.recordAttempt('login', maxAttempts: 3), true);
      expect(service.recordAttempt('login', maxAttempts: 3), false); // 4th attempt blocked
    });

    test('getTimeUntilNextAttempt returns null if not blocked', () {
      service.recordAttempt('login', maxAttempts: 2);
      expect(service.getTimeUntilNextAttempt('login', maxAttempts: 2), null);
    });

    test('getTimeUntilNextAttempt returns duration if blocked', () {
      service.recordAttempt('login', maxAttempts: 1);
      final duration = service.getTimeUntilNextAttempt('login', maxAttempts: 1);
      expect(duration, isNotNull);
      expect(duration!.inMinutes, 14); // about 15 mins
    });
  });
}
