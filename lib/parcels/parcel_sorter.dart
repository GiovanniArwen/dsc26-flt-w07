/// Sorts parcels by stop order. Given: do not change. `calls` is a test
/// counter: the hidden tests use it to check how often sorting actually
/// runs, so leave it exactly where it is.
import 'parcel.dart';

class ParcelSorter {
  ParcelSorter._();

  static int calls = 0;

  /// By [Parcel.stopSequence], ties broken by [Parcel.parcelId].
  static List<Parcel> sort(List<Parcel> parcels) {
    calls++;
    final sorted = List<Parcel>.of(parcels);
    sorted.sort((a, b) {
      final byStop = a.stopSequence.compareTo(b.stopSequence);
      if (byStop != 0) return byStop;
      return a.parcelId.compareTo(b.parcelId);
    });
    return sorted;
  }
}
