/// The parcel list screen.
///
/// Performance fixes (Part B):
/// * rows are built lazily with [ListView.builder], so only the visible
///   rows (plus a small cache area) are built;
/// * the list is sorted once in [State.initState], and again only when a
///   different list is passed in ([State.didUpdateWidget]), never in build;
/// * the ticking shift clock is its own small widget, so its `setState`
///   rebuilds only the clock text, never the list.
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
  late List<Parcel> _sorted;

  @override
  void initState() {
    super.initState();
    _sorted = ParcelSorter.sort(widget.parcels);
  }

  @override
  void didUpdateWidget(covariant ParcelListApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.parcels, widget.parcels)) {
      _sorted = ParcelSorter.sort(widget.parcels);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const ShiftClock()),
        body: ListView.builder(
          itemCount: _sorted.length,
          itemBuilder: (context, index) {
            final parcel = _sorted[index];
            return ParcelTile(
              key: ValueKey('parcel-${parcel.parcelId}'),
              parcel: parcel,
            );
          },
        ),
      ),
    );
  }
}

/// Shows `Shift hh:mm:ss`, ticking every second. Lives in its own widget so
/// each tick rebuilds only this text.
class ShiftClock extends StatefulWidget {
  const ShiftClock({super.key});

  @override
  State<ShiftClock> createState() => _ShiftClockState();
}

class _ShiftClockState extends State<ShiftClock> {
  late final Timer _timer;
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
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');
    return Text('Shift $hh:$mm:$ss');
  }
}
