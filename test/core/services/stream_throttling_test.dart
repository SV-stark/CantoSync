import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  group('RxDart Stream Throttling for Library Books', () {
    test('throttleTime emits first value immediately and throttles steady writes', () async {
      final subject = PublishSubject<int>();
      final emitted = <int>[];

      final sub = subject
          .throttleTime(
            const Duration(milliseconds: 100),
            leading: true,
            trailing: true,
          )
          .listen(emitted.add);

      // Initial event (like Isar watch fireImmediately)
      subject.add(1);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(emitted, [1]);

      // Burst of periodic writes within throttle window
      subject.add(2);
      subject.add(3);
      await Future.delayed(const Duration(milliseconds: 150));

      // Trailing event should be emitted
      expect(emitted, [1, 3]);

      // Next steady state write after window should emit immediately
      subject.add(4);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(emitted, [1, 3, 4]);

      await sub.cancel();
      await subject.close();
    });
  });
}
