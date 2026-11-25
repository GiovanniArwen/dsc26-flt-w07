/// The parcel list screen. Works, but is far too slow on an old phone:
/// every row is built eagerly, sorting happens inside `build`, and the
/// shift clock lives high enough in the tree that every tick rebuilds the
/// whole list. Fix it without changing what it shows.
///
/// TODO(intern): see the README, Part B.
import 'dart:async';

import 'package:flutter/material.dart';

import 'parcel.dart';
import 'parcel_sorter.dart';
import 'parcel_tile.dart';

class ParcelListApp extends StatefulWidget {
  const ParcelListApp({super.key, required this.parcels});

  final List<Parcel> parcels;

  @override
  State<ParcelListApp> createState() => _ParcelListAppState();
}

class _ParcelListAppState extends State<ParcelListApp> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sorts again every time build() runs - including on every clock tick.
    final sorted = ParcelSorter.sort(widget.parcels);
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Shift $hh:$mm:$ss')),
        // A Column inside a SingleChildScrollView builds every row
        // eagerly, however many thousand parcels there are.
        body: SingleChildScrollView(
          child: Column(
            children: [
              for (final parcel in sorted)
                ParcelTile(
                  key: ValueKey('parcel-${parcel.parcelId}'),
                  parcel: parcel,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
