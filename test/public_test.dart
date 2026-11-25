import 'dart:io';

import 'package:dsc26_flt_w07/cod/cod_reconciler.dart';
import 'package:dsc26_flt_w07/parcels/parcel_list_app.dart';
import 'package:dsc26_flt_w07/parcels/parcel_sorter.dart';
import 'package:dsc26_flt_w07/parcels/parcel_tile.dart';
import 'package:dsc26_flt_w07/sample/generate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('example of the style we expect: a balanced shift', () {
    final report = reconcile([
      const CodLine(
        parcelId: 'P1',
        status: DeliveryStatus.delivered,
        expectedPiasters: 45000,
        collectedPiasters: 45000,
      ),
    ]);
    expect(report.balanced, isTrue);
    expect(formatEgp(report.expectedTotal), 'EGP 450.00');
  });

  testWidgets('builds only the rows on screen', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    ParcelTile.buildCount = 0;
    await tester.pumpWidget(ParcelListApp(parcels: generateParcels(2000)));
    await tester.pump();
    expect(ParcelTile.buildCount, lessThan(60));
  });

  testWidgets('does not sort again on every clock tick', (tester) async {
    ParcelSorter.calls = 0;
    await tester.pumpWidget(ParcelListApp(parcels: generateParcels(200)));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(ParcelSorter.calls, 1);
  });

  test('a CI workflow exists and runs the tests', () {
    final file = File('.github/workflows/ci.yml');
    expect(file.existsSync(), isTrue);
    expect(file.readAsStringSync(), contains('flutter test'));
  });
}
