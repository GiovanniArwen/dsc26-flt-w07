/// One row in the parcel list. Given: do not change. `buildCount` is a test
/// counter: the hidden tests (and the public test) use it to check how many
/// rows actually got built, so leave it exactly where it is.
import 'package:flutter/material.dart';

import 'parcel.dart';

class ParcelTile extends StatelessWidget {
  const ParcelTile({super.key, required this.parcel});

  final Parcel parcel;

  static int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return ListTile(
      title: Text(parcel.customerName),
      subtitle: Text('Stop ${parcel.stopSequence}'),
    );
  }
}
