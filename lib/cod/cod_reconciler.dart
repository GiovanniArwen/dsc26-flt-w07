/// Reconciles a Tawseel courier's end-of-shift cash against what was
/// expected. Given, correct: do not change it (the grader replaces this
/// file with its own copy regardless).
///
/// Rules:
/// * Only `delivered` lines count towards `expectedTotal` and
///   `collectedTotal`.
/// * A line is invalid, and excluded from every total, if: its
///   `collectedPiasters` is negative; it is the second or later line with
///   the same `parcelId`; or it is `failed`/`returned` with
///   `collectedPiasters` above 0. Invalid lines are listed in
///   `invalidLines`.
/// * A valid `delivered` line is short if
///   `collected < expected - tolerance`, over if
///   `collected > expected + tolerance`.
/// * `shortParcels`, `overParcels` and `invalidLines` are sorted by
///   `parcelId`.
/// * `discrepancy = collectedTotal - expectedTotal`; `balanced` is true
///   only when the discrepancy is 0 and there are no invalid lines.
library;

enum DeliveryStatus { delivered, failed, returned }

class CodLine {
  const CodLine({
    required this.parcelId,
    required this.status,
    required this.expectedPiasters,
    required this.collectedPiasters,
  });

  final String parcelId;
  final DeliveryStatus status;
  final int expectedPiasters;
  final int collectedPiasters;
}

class ReconciliationReport {
  const ReconciliationReport({
    required this.expectedTotal,
    required this.collectedTotal,
    required this.shortParcels,
    required this.overParcels,
    required this.invalidLines,
  });

  final int expectedTotal;
  final int collectedTotal;
  final List<String> shortParcels;
  final List<String> overParcels;
  final List<String> invalidLines;

  int get discrepancy => collectedTotal - expectedTotal;

  bool get balanced => discrepancy == 0 && invalidLines.isEmpty;
}

ReconciliationReport reconcile(
  List<CodLine> lines, {
  int tolerancePiasters = 0,
}) {
  final seen = <String>{};
  final invalid = <String>[];
  final short = <String>[];
  final over = <String>[];
  var expectedTotal = 0;
  var collectedTotal = 0;

  for (final line in lines) {
    final repeated = seen.contains(line.parcelId);
    seen.add(line.parcelId);

    final negativeAmount = line.collectedPiasters < 0;
    final nonDeliveredWithCash =
        line.status != DeliveryStatus.delivered && line.collectedPiasters > 0;

    if (repeated || negativeAmount || nonDeliveredWithCash) {
      invalid.add(line.parcelId);
      continue;
    }

    if (line.status != DeliveryStatus.delivered) {
      continue; // a valid failed/returned line: excluded from every total.
    }

    expectedTotal += line.expectedPiasters;
    collectedTotal += line.collectedPiasters;

    if (line.collectedPiasters < line.expectedPiasters - tolerancePiasters) {
      short.add(line.parcelId);
    } else if (line.collectedPiasters >
        line.expectedPiasters + tolerancePiasters) {
      over.add(line.parcelId);
    }
  }

  short.sort();
  over.sort();
  invalid.sort();

  return ReconciliationReport(
    expectedTotal: expectedTotal,
    collectedTotal: collectedTotal,
    shortParcels: short,
    overParcels: over,
    invalidLines: invalid,
  );
}

String _withThousands(int n) {
  final digits = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Formats [piasters] (1/100 of an EGP) as e.g. `EGP 1,234.50`, `EGP 0.05`
/// or, for a negative amount, `-EGP 12.00`.
String formatEgp(int piasters) {
  final negative = piasters < 0;
  final magnitude = piasters.abs();
  final pounds = magnitude ~/ 100;
  final cents = magnitude % 100;
  final sign = negative ? '-' : '';
  return '${sign}EGP ${_withThousands(pounds)}.${cents.toString().padLeft(2, '0')}';
}
