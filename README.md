# dsc26-flt-w07 · Prove it: tests that catch bugs, a list that stays smooth, CI that runs

DSC Summer Internship 2026 · Flutter track · Week 7 · **Flutter 3.47.6, Dart 3.13** · expected time 3–4 hours (about 2 h tests, 1 h performance, 20 min CI)

## Scenario

At the end of each shift, a Tawseel courier hands in the cash collected. The app shows a shift summary: how much should have been collected, how much was, and which parcels do not match. DSC gives you a correct implementation. Your job is to **prove it is correct** with tests strong enough to catch bugs someone might introduce later, to **fix a parcel list** that is far too slow on an old phone, and to **add CI**.

## Getting started

1. **Use this template** → a **public** repository in your own account named exactly **`dsc26-flt-w07`**.
2. `flutter pub get`, then `flutter test` (the public tests fail until you implement the task).

Do **not** rename the package (`name: dsc26_flt_w07`). A renamed package scores 0.

## File layout

```text
lib/
  cod/cod_reconciler.dart        CodLine, DeliveryStatus, ReconciliationReport, reconcile, formatEgp (given, correct; do not change — the grader replaces it anyway)
  cod/shift_summary_screen.dart  ShiftSummaryScreen (given, correct; do not change — the grader replaces it anyway)
  parcels/parcel.dart            Parcel (given)
  parcels/parcel_sorter.dart     ParcelSorter.sort, ParcelSorter.calls (given, a test counter)
  parcels/parcel_tile.dart       ParcelTile, ParcelTile.buildCount (given, a test counter)
  parcels/parcel_list_app.dart   ParcelListApp: works, but far too slow (you fix it)
  sample/generate.dart           generateParcels(int n), deterministic (given)
test/
  public_test.dart               the curriculum's example; you add your own files ending _test.dart
AI_USAGE.md
```

You may restructure `lib/parcels/` freely, but keep `ParcelListApp`'s constructor, `ParcelSorter.calls` and `ParcelTile.buildCount` exactly where the hidden tests expect them.

## Part A: tests (`test/`, any file names ending `_test.dart`)

Write tests for `lib/cod/cod_reconciler.dart` and `lib/cod/shift_summary_screen.dart`. The rules, documented in `cod_reconciler.dart`:

- Only `delivered` lines count towards `expectedTotal` and `collectedTotal`.
- A line is **invalid** (listed in `invalidLines`, excluded from every total) if: `collectedPiasters` is negative; it is the **second or later** line with the same `parcelId`; or it is `failed`/`returned` with `collectedPiasters` above 0.
- A valid `delivered` line is **short** if `collected < expected − tolerance`, **over** if `collected > expected + tolerance`. `shortParcels`, `overParcels` and `invalidLines` are sorted by `parcelId`.
- `discrepancy = collectedTotal − expectedTotal`. `balanced` is true only if the discrepancy is 0 **and** there are no invalid lines.
- `formatEgp(123450)` is `EGP 1,234.50`; `formatEgp(5)` is `EGP 0.05`; negatives are `-EGP 12.00`.
- `ShiftSummaryScreen` shows the report with keys `summary-expected`, `summary-collected`, `summary-discrepancy` (formatted with `formatEgp`), `summary-balanced` (shown only when balanced), and `summary-issue-<parcelId>` for each short, over or invalid parcel.

**Rules for your suite:** at least 6 test cases; all must pass against the provided code; they must finish within 90 seconds; **they must not read files under `lib/`** (a test file that mentions `lib/` together with `dart:io`'s `File(`/`Directory(` scores H01–H11 as 0 and is flagged for your Track Mentor — write assertions on behaviour, not on the source text).

Your suite is graded by **mutation testing**, not by line coverage: DSC runs it against the correct code (it must pass, in full, within 90 s — this gate is worth its own row) and then against ten mutants you cannot see, each one small deliberate bug in `lib/cod/`. A mutant is *killed* when your suite fails against it. The public example test alone kills none of them: test every rule above **at its boundary** (the exact tolerance value, the exact threshold, a repeated id, a failed line with ⁠`collected == 0` versus `collected == 1`, the smallest two-digit cents case, a negative amount) to have a chance at all ten.

## Part B: performance (`lib/parcels/`)

The provided `ParcelListApp({required List<Parcel> parcels})` builds every row eagerly, sorts in `build`, and rebuilds the whole list every second because of a shift clock. Fix it **without changing what it shows**:

- At 400×800 with 2,000 parcels, fewer than 60 `ParcelTile` builds on first display (`ParcelTile.buildCount`).
- `ParcelSorter.sort` (`ParcelSorter.calls`) runs once per new list, not once per frame or per clock tick.
- Order unchanged (by `stopSequence`, then `parcelId`); every row keyed `parcel-<id>` and reachable by scrolling.

The usual fixes: `ListView.builder` instead of `Column` inside a `SingleChildScrollView`; sort once (in `initState`/when the list actually changes), not inside `build`; move the ticking clock into its own small widget so its `setState` never touches the list.

## Part C: CI

Add `.github/workflows/ci.yml` that runs on `push` and `pull_request`, pins Flutter `3.47.6`, and runs `dart format --output=none --set-exit-if-changed .`, `flutter analyze` and `flutter test`. Make it pass on GitHub; your Track Mentor will look at the run.

## How grading works

Push, then press **Submit for grading** on DSC Hex (5 attempts per task per day).

- **H01–H11** (your Part A suite): the grader runs `flutter test test/` once against the reference `lib/cod/` and once per mutant (each mutant replaces one file under `lib/cod/`). A mutant is **killed** when your suite fails or exceeds 90 s against it.
- **H12–H15**: run as `flutter test test/hidden --reporter json` against your `lib/parcels/` and `.github/workflows/ci.yml`.

Network off, Flutter 3.47.6, 20-minute limit for the whole task.

| Row | Public name | Weight |
|---|---|---|
| H01 | your tests: pass on correct code | 10 |
| H02 | mutant: tolerance boundary | 5 |
| H03 | mutant: non-delivered counted | 5 |
| H04 | mutant: duplicates | 5 |
| H05 | mutant: invalid lines in totals | 5 |
| H06 | mutant: over tolerance | 5 |
| H07 | mutant: balanced | 5 |
| H08 | mutant: formatting, piasters | 5 |
| H09 | mutant: formatting, thousands and sign | 5 |
| H10 | mutant: screen, discrepancy | 5 |
| H11 | mutant: screen, balanced banner | 5 |
| H12 | performance: lazy list | 10 |
| H13 | performance: no repeated sorting | 10 |
| H14 | performance: still correct | 5 |
| H15 | CI workflow | 15 |

A suite that fails on the correct code (H01) scores 0 for H01–H11, so "tests that always fail" do not work. Tests that read `lib/` source score 0 for H01–H11 too, flagged for your Track Mentor. H15 accepts any reasonable formatting of the YAML.

Late policy: ×1.0 within 72 hours of the session starting, ×0.6 for the following 7 days, ×0.5 after that. Best attempt counts.

## `AI_USAGE.md` (required)

Fill in: the tools you used; your best prompts; the edge cases you chose to test and which of them you thought of yourself versus the AI; one AI-suggested test you deleted or changed and why; and what you saw in DevTools (or in the build counters) before and after your performance fix.
