/// Shows a [ReconciliationReport] to the courier. Given, correct: do not
/// change it (the grader replaces this file with its own copy regardless).
import 'package:flutter/material.dart';

import 'cod_reconciler.dart';

class ShiftSummaryScreen extends StatelessWidget {
  const ShiftSummaryScreen({super.key, required this.report});

  final ReconciliationReport report;

  @override
  Widget build(BuildContext context) {
    final issues = <String>{
      ...report.shortParcels,
      ...report.overParcels,
      ...report.invalidLines,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('End-of-shift summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Expected', style: Theme.of(context).textTheme.labelMedium),
          Text(
            formatEgp(report.expectedTotal),
            key: const Key('summary-expected'),
          ),
          const SizedBox(height: 12),
          Text('Collected', style: Theme.of(context).textTheme.labelMedium),
          Text(
            formatEgp(report.collectedTotal),
            key: const Key('summary-collected'),
          ),
          const SizedBox(height: 12),
          Text('Discrepancy', style: Theme.of(context).textTheme.labelMedium),
          Text(
            formatEgp(report.discrepancy),
            key: const Key('summary-discrepancy'),
          ),
          if (report.balanced)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Balanced', key: Key('summary-balanced')),
            ),
          if (issues.isNotEmpty) const SizedBox(height: 12),
          for (final parcelId in issues)
            Text(parcelId, key: Key('summary-issue-$parcelId')),
        ],
      ),
    );
  }
}
