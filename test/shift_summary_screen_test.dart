import 'package:dsc26_flt_w07/cod/cod_reconciler.dart';
import 'package:dsc26_flt_w07/cod/shift_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpReport(WidgetTester tester, ReconciliationReport r) async {
  await tester.pumpWidget(MaterialApp(home: ShiftSummaryScreen(report: r)));
}

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  testWidgets('shows totals and a negative discrepancy, no banner', (
    tester,
  ) async {
    const r = ReconciliationReport(
      expectedTotal: 123450,
      collectedTotal: 122250,
      shortParcels: ['P1'],
      overParcels: [],
      invalidLines: [],
    );
    await pumpReport(tester, r);
    expect(textOf(tester, 'summary-expected'), 'EGP 1,234.50');
    expect(textOf(tester, 'summary-collected'), 'EGP 1,222.50');
    expect(textOf(tester, 'summary-discrepancy'), '-EGP 12.00');
    expect(find.byKey(const Key('summary-balanced')), findsNothing);
    expect(find.byKey(const Key('summary-issue-P1')), findsOneWidget);
  });

  testWidgets('shows a positive discrepancy when over', (tester) async {
    const r = ReconciliationReport(
      expectedTotal: 1000,
      collectedTotal: 1005,
      shortParcels: [],
      overParcels: ['P2'],
      invalidLines: [],
    );
    await pumpReport(tester, r);
    expect(textOf(tester, 'summary-expected'), 'EGP 10.00');
    expect(textOf(tester, 'summary-collected'), 'EGP 10.05');
    expect(textOf(tester, 'summary-discrepancy'), 'EGP 0.05');
    expect(find.byKey(const Key('summary-balanced')), findsNothing);
    expect(find.byKey(const Key('summary-issue-P2')), findsOneWidget);
  });

  testWidgets('balanced report shows the banner and zero discrepancy', (
    tester,
  ) async {
    const r = ReconciliationReport(
      expectedTotal: 45000,
      collectedTotal: 45000,
      shortParcels: [],
      overParcels: [],
      invalidLines: [],
    );
    await pumpReport(tester, r);
    expect(textOf(tester, 'summary-discrepancy'), 'EGP 0.00');
    expect(find.byKey(const Key('summary-balanced')), findsOneWidget);
    expect(find.byKey(const Key('summary-issue-P1')), findsNothing);
  });

  testWidgets('zero discrepancy with an invalid line hides the banner', (
    tester,
  ) async {
    const r = ReconciliationReport(
      expectedTotal: 45000,
      collectedTotal: 45000,
      shortParcels: [],
      overParcels: [],
      invalidLines: ['P7'],
    );
    await pumpReport(tester, r);
    expect(textOf(tester, 'summary-discrepancy'), 'EGP 0.00');
    expect(find.byKey(const Key('summary-balanced')), findsNothing);
    expect(find.byKey(const Key('summary-issue-P7')), findsOneWidget);
  });

  testWidgets('nonzero discrepancy with no issues hides the banner', (
    tester,
  ) async {
    const r = ReconciliationReport(
      expectedTotal: 10000,
      collectedTotal: 9999,
      shortParcels: [],
      overParcels: [],
      invalidLines: [],
    );
    await pumpReport(tester, r);
    expect(textOf(tester, 'summary-discrepancy'), '-EGP 0.01');
    expect(find.byKey(const Key('summary-balanced')), findsNothing);
  });

  testWidgets('end to end: reconcile then show every issue', (tester) async {
    final r = reconcile([
      const CodLine(
        parcelId: 'P1',
        status: DeliveryStatus.delivered,
        expectedPiasters: 10000,
        collectedPiasters: 9000,
      ),
      const CodLine(
        parcelId: 'P2',
        status: DeliveryStatus.delivered,
        expectedPiasters: 10000,
        collectedPiasters: 10500,
      ),
      const CodLine(
        parcelId: 'P3',
        status: DeliveryStatus.failed,
        expectedPiasters: 5000,
        collectedPiasters: 1,
      ),
      const CodLine(
        parcelId: 'P4',
        status: DeliveryStatus.returned,
        expectedPiasters: 5000,
        collectedPiasters: 0,
      ),
    ]);
    await pumpReport(tester, r);
    expect(textOf(tester, 'summary-expected'), 'EGP 200.00');
    expect(textOf(tester, 'summary-collected'), 'EGP 195.00');
    expect(textOf(tester, 'summary-discrepancy'), '-EGP 5.00');
    expect(find.byKey(const Key('summary-balanced')), findsNothing);
    for (final id in ['P1', 'P2', 'P3']) {
      expect(find.byKey(Key('summary-issue-$id')), findsOneWidget);
    }
    expect(find.byKey(const Key('summary-issue-P4')), findsNothing);
  });
}
