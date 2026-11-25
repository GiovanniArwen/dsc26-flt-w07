import 'package:dsc26_flt_w07/cod/cod_reconciler.dart';
import 'package:flutter_test/flutter_test.dart';

CodLine delivered(String id, int expected, int collected) => CodLine(
  parcelId: id,
  status: DeliveryStatus.delivered,
  expectedPiasters: expected,
  collectedPiasters: collected,
);

CodLine failed(String id, int expected, int collected) => CodLine(
  parcelId: id,
  status: DeliveryStatus.failed,
  expectedPiasters: expected,
  collectedPiasters: collected,
);

CodLine returned(String id, int expected, int collected) => CodLine(
  parcelId: id,
  status: DeliveryStatus.returned,
  expectedPiasters: expected,
  collectedPiasters: collected,
);

void main() {
  group('tolerance boundary (short)', () {
    test('collected exactly expected - tolerance is not short', () {
      final r = reconcile([
        delivered('P1', 10000, 9950),
      ], tolerancePiasters: 50);
      expect(r.shortParcels, isEmpty);
      expect(r.overParcels, isEmpty);
    });

    test('one piaster below expected - tolerance is short', () {
      final r = reconcile([
        delivered('P1', 10000, 9949),
      ], tolerancePiasters: 50);
      expect(r.shortParcels, ['P1']);
      expect(r.overParcels, isEmpty);
    });

    test('with zero tolerance, one piaster short is short', () {
      final r = reconcile([delivered('P1', 10000, 9999)]);
      expect(r.shortParcels, ['P1']);
      expect(r.overParcels, isEmpty);
    });

    test('exact amount with zero tolerance is neither short nor over', () {
      final r = reconcile([delivered('P1', 10000, 10000)]);
      expect(r.shortParcels, isEmpty);
      expect(r.overParcels, isEmpty);
    });
  });

  group('tolerance boundary (over)', () {
    test('collected exactly expected + tolerance is not over', () {
      final r = reconcile([
        delivered('P1', 10000, 10050),
      ], tolerancePiasters: 50);
      expect(r.overParcels, isEmpty);
      expect(r.shortParcels, isEmpty);
    });

    test('one piaster above expected + tolerance is over', () {
      final r = reconcile([
        delivered('P1', 10000, 10051),
      ], tolerancePiasters: 50);
      expect(r.overParcels, ['P1']);
      expect(r.shortParcels, isEmpty);
    });

    test('with zero tolerance, one piaster over is over', () {
      final r = reconcile([delivered('P1', 10000, 10001)]);
      expect(r.overParcels, ['P1']);
      expect(r.shortParcels, isEmpty);
    });
  });

  group('only delivered lines count', () {
    test('valid failed and returned lines add nothing to totals', () {
      final r = reconcile([
        delivered('P1', 10000, 10000),
        failed('P2', 7000, 0),
        returned('P3', 3000, 0),
      ]);
      expect(r.expectedTotal, 10000);
      expect(r.collectedTotal, 10000);
      expect(r.invalidLines, isEmpty);
      expect(r.shortParcels, isEmpty);
      expect(r.overParcels, isEmpty);
      expect(r.balanced, isTrue);
    });

    test('a shift of only failed lines has zero totals and is balanced', () {
      final r = reconcile([failed('P1', 5000, 0), returned('P2', 5000, 0)]);
      expect(r.expectedTotal, 0);
      expect(r.collectedTotal, 0);
      expect(r.shortParcels, isEmpty);
      expect(r.balanced, isTrue);
    });
  });

  group('invalid lines', () {
    test('failed with collected == 0 is valid, collected == 1 is invalid', () {
      expect(reconcile([failed('P1', 5000, 0)]).invalidLines, isEmpty);
      final r = reconcile([failed('P1', 5000, 1)]);
      expect(r.invalidLines, ['P1']);
      expect(r.expectedTotal, 0);
      expect(r.collectedTotal, 0);
    });

    test('returned with collected == 1 is invalid', () {
      final r = reconcile([
        delivered('P1', 2000, 2000),
        returned('P2', 5000, 1),
      ]);
      expect(r.invalidLines, ['P2']);
      expect(r.expectedTotal, 2000);
      expect(r.collectedTotal, 2000);
      expect(r.balanced, isFalse);
    });

    test('negative collected is invalid and excluded from totals', () {
      final r = reconcile([
        delivered('P1', 2000, 2000),
        delivered('P2', 3000, -1),
      ]);
      expect(r.invalidLines, ['P2']);
      expect(r.expectedTotal, 2000);
      expect(r.collectedTotal, 2000);
      expect(r.shortParcels, isEmpty);
    });

    test('collected == 0 on a delivered line is valid (and short)', () {
      final r = reconcile([delivered('P1', 3000, 0)]);
      expect(r.invalidLines, isEmpty);
      expect(r.shortParcels, ['P1']);
      expect(r.expectedTotal, 3000);
      expect(r.collectedTotal, 0);
    });

    test('a repeated parcelId: first counts, the second is invalid', () {
      final r = reconcile([
        delivered('P1', 4000, 4000),
        delivered('P1', 9000, 1000),
      ]);
      expect(r.invalidLines, ['P1']);
      expect(r.expectedTotal, 4000);
      expect(r.collectedTotal, 4000);
      expect(r.shortParcels, isEmpty);
      expect(r.balanced, isFalse);
    });

    test('a third line with the same id is invalid too', () {
      final r = reconcile([
        delivered('P1', 4000, 4000),
        delivered('P1', 4000, 4000),
        delivered('P1', 4000, 4000),
      ]);
      expect(r.invalidLines, ['P1', 'P1']);
      expect(r.expectedTotal, 4000);
      expect(r.collectedTotal, 4000);
    });

    test('a duplicate after a failed line is still invalid', () {
      final r = reconcile([failed('P1', 4000, 0), delivered('P1', 4000, 4000)]);
      expect(r.invalidLines, ['P1']);
      expect(r.expectedTotal, 0);
      expect(r.collectedTotal, 0);
    });

    test('invalid lines never reach any total', () {
      final r = reconcile([
        delivered('P1', 1000, 1000),
        delivered('P2', 50000, -500),
        failed('P3', 70000, 700),
        delivered('P1', 90000, 90000),
      ]);
      expect(r.expectedTotal, 1000);
      expect(r.collectedTotal, 1000);
      expect(r.discrepancy, 0);
      expect(r.invalidLines, ['P1', 'P2', 'P3']);
    });
  });

  group('sorting', () {
    test('short, over and invalid lists are sorted by parcelId', () {
      final r = reconcile([
        delivered('P9', 1000, 0),
        delivered('P3', 1000, 0),
        delivered('P8', 1000, 2000),
        delivered('P2', 1000, 2000),
        failed('P7', 1000, 5),
        delivered('P4', 1000, -1),
      ]);
      expect(r.shortParcels, ['P3', 'P9']);
      expect(r.overParcels, ['P2', 'P8']);
      expect(r.invalidLines, ['P4', 'P7']);
    });
  });

  group('discrepancy and balanced', () {
    test('discrepancy is collected - expected (negative when short)', () {
      final r = reconcile([delivered('P1', 10000, 9000)]);
      expect(r.expectedTotal, 10000);
      expect(r.collectedTotal, 9000);
      expect(r.discrepancy, -1000);
      expect(r.balanced, isFalse);
    });

    test('discrepancy is positive when over', () {
      final r = reconcile([delivered('P1', 10000, 10250)]);
      expect(r.discrepancy, 250);
      expect(r.balanced, isFalse);
    });

    test('within tolerance but discrepancy != 0 is not balanced', () {
      final r = reconcile([
        delivered('P1', 10000, 9999),
      ], tolerancePiasters: 100);
      expect(r.shortParcels, isEmpty);
      expect(r.discrepancy, -1);
      expect(r.balanced, isFalse);
    });

    test('short and over cancelling out is balanced', () {
      final r = reconcile([
        delivered('P1', 10000, 9000),
        delivered('P2', 10000, 11000),
      ]);
      expect(r.discrepancy, 0);
      expect(r.shortParcels, ['P1']);
      expect(r.overParcels, ['P2']);
      expect(r.balanced, isTrue);
    });

    test('discrepancy 0 but an invalid line is not balanced', () {
      final r = reconcile([
        delivered('P1', 10000, 10000),
        failed('P2', 500, 1),
      ]);
      expect(r.discrepancy, 0);
      expect(r.balanced, isFalse);
    });

    test('an empty shift is balanced', () {
      final r = reconcile(const []);
      expect(r.discrepancy, 0);
      expect(r.balanced, isTrue);
    });

    test('balanced getter on a hand-built report', () {
      const ok = ReconciliationReport(
        expectedTotal: 500,
        collectedTotal: 500,
        shortParcels: [],
        overParcels: [],
        invalidLines: [],
      );
      const invalid = ReconciliationReport(
        expectedTotal: 500,
        collectedTotal: 500,
        shortParcels: [],
        overParcels: [],
        invalidLines: ['P1'],
      );
      const off = ReconciliationReport(
        expectedTotal: 500,
        collectedTotal: 499,
        shortParcels: [],
        overParcels: [],
        invalidLines: [],
      );
      expect(ok.balanced, isTrue);
      expect(invalid.balanced, isFalse);
      expect(off.balanced, isFalse);
      expect(off.discrepancy, -1);
    });
  });

  group('formatEgp', () {
    test('piasters are always two digits', () {
      expect(formatEgp(0), 'EGP 0.00');
      expect(formatEgp(1), 'EGP 0.01');
      expect(formatEgp(5), 'EGP 0.05');
      expect(formatEgp(9), 'EGP 0.09');
      expect(formatEgp(10), 'EGP 0.10');
      expect(formatEgp(50), 'EGP 0.50');
      expect(formatEgp(99), 'EGP 0.99');
      expect(formatEgp(100), 'EGP 1.00');
      expect(formatEgp(105), 'EGP 1.05');
      expect(formatEgp(45000), 'EGP 450.00');
    });

    test('thousands separators', () {
      expect(formatEgp(99999), 'EGP 999.99');
      expect(formatEgp(100000), 'EGP 1,000.00');
      expect(formatEgp(123450), 'EGP 1,234.50');
      expect(formatEgp(1234567), 'EGP 12,345.67');
      expect(formatEgp(12345678), 'EGP 123,456.78');
      expect(formatEgp(100000000), 'EGP 1,000,000.00');
      expect(formatEgp(123456789), 'EGP 1,234,567.89');
    });

    test('negative amounts put the sign before EGP', () {
      expect(formatEgp(-1200), '-EGP 12.00');
      expect(formatEgp(-5), '-EGP 0.05');
      expect(formatEgp(-1), '-EGP 0.01');
      expect(formatEgp(-123450), '-EGP 1,234.50');
      expect(formatEgp(-100000000), '-EGP 1,000,000.00');
    });
  });
}
