/// Deterministic sample data for the parcel list. Given: do not change.
import 'dart:math';

import '../parcels/parcel.dart';

/// Always returns the same [n] parcels, in a scrambled stop order (so that
/// sorting by [Parcel.stopSequence] is not a no-op), for any run, any
/// submission, any seed.
List<Parcel> generateParcels(int n) {
  final rng = Random(42);
  final stopSequences = List<int>.generate(n, (i) => i)..shuffle(rng);
  return List<Parcel>.generate(
    n,
    (i) => Parcel(
      parcelId: 'P${(i + 1).toString().padLeft(5, '0')}',
      stopSequence: stopSequences[i],
      customerName: 'Customer ${i + 1}',
    ),
  );
}
