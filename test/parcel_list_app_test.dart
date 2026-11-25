import 'package:dsc26_flt_w07/parcels/parcel.dart';
import 'package:dsc26_flt_w07/parcels/parcel_list_app.dart';
import 'package:dsc26_flt_w07/parcels/parcel_sorter.dart';
import 'package:dsc26_flt_w07/parcels/parcel_tile.dart';
import 'package:dsc26_flt_w07/sample/generate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('rows are in stop order and the last one is reachable', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);

    final parcels = generateParcels(2000);
    final expected = ParcelSorter.sort(parcels);
    await tester.pumpWidget(ParcelListApp(parcels: parcels));
    await tester.pump();

    final shown = tester
        .widgetList<ParcelTile>(find.byType(ParcelTile))
        .map((t) => t.parcel.parcelId)
        .take(5)
        .toList();
    expect(shown, expected.take(5).map((p) => p.parcelId).toList());
    expect(
      find.byKey(ValueKey('parcel-${expected.first.parcelId}')),
      findsOneWidget,
    );

    final last = find.byKey(ValueKey('parcel-${expected.last.parcelId}'));
    await tester.scrollUntilVisible(
      last,
      700,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 1000,
    );
    expect(last, findsOneWidget);
  });

  testWidgets('ties on stopSequence are broken by parcelId', (tester) async {
    const parcels = [
      Parcel(parcelId: 'B', stopSequence: 1, customerName: 'Bee'),
      Parcel(parcelId: 'C', stopSequence: 0, customerName: 'Cee'),
      Parcel(parcelId: 'A', stopSequence: 1, customerName: 'Ay'),
    ];
    await tester.pumpWidget(const ParcelListApp(parcels: parcels));
    final ids = tester
        .widgetList<ParcelTile>(find.byType(ParcelTile))
        .map((t) => t.parcel.parcelId)
        .toList();
    expect(ids, ['C', 'A', 'B']);
  });

  testWidgets('sorts again only when a new list arrives', (tester) async {
    ParcelSorter.calls = 0;
    final first = generateParcels(50);
    await tester.pumpWidget(ParcelListApp(parcels: first));
    await tester.pumpWidget(ParcelListApp(parcels: first));
    expect(ParcelSorter.calls, 1);
    await tester.pumpWidget(ParcelListApp(parcels: generateParcels(60)));
    expect(ParcelSorter.calls, 2);
  });
}
