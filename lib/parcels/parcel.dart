/// A stop on a courier's route. Given: do not change.
class Parcel {
  const Parcel({
    required this.parcelId,
    required this.stopSequence,
    required this.customerName,
  });

  final String parcelId;
  final int stopSequence;
  final String customerName;
}
