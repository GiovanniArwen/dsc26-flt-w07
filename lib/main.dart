/// Demo app. Not graded: the grader never runs this file. Shows the parcel
/// list (Part B) and, behind a button, the shift summary screen (Part A)
/// built from a couple of made-up cash lines.
import 'package:flutter/material.dart';

import 'cod/cod_reconciler.dart';
import 'cod/shift_summary_screen.dart';
import 'parcels/parcel_list_app.dart';
import 'sample/generate.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ParcelListApp(parcels: generateParcels(2000)),
      routes: {
        '/summary': (context) => ShiftSummaryScreen(report: _demoReport()),
      },
    );
  }

  ReconciliationReport _demoReport() => reconcile(const [
        CodLine(
            parcelId: 'P00001',
            status: DeliveryStatus.delivered,
            expectedPiasters: 45000,
            collectedPiasters: 45000),
        CodLine(
            parcelId: 'P00002',
            status: DeliveryStatus.failed,
            expectedPiasters: 12000,
            collectedPiasters: 0),
        CodLine(
            parcelId: 'P00003',
            status: DeliveryStatus.delivered,
            expectedPiasters: 30000,
            collectedPiasters: 28000),
      ]);
}
