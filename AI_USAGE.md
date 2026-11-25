# AI usage: dsc26-flt-w07

AI tools are allowed in this task. Fill in every section in your own words. This file is read by your Track Mentor, not by the grader.

## 1. Tools I used

Claude Code (Claude Opus 5.5) in the Claude desktop app. It read the template, wrote the test suite, the `ParcelListApp` fix and the CI workflow, and ran `flutter analyze`, `dart format` and `flutter test` locally.

## 2. My best prompts

1. "Finish this task" with the full week-7 brief pasted in (all three parts and the grading table).
2. Asking it to check the suite against bugs before submitting: it wrote about 24 small mutants of `lib/cod/` in a scratch copy (for example `<` changed to `<=` at the tolerance check, the `repeated` check removed, `padLeft` removed, the sign moved after `EGP`, the balanced banner shown when only `discrepancy == 0`) and ran the suite against each one. All 24 were killed.

## 3. The edge cases I tested, and who thought of each

"Brief" means the task brief listed the edge case and the AI turned it into a test.

| Edge case | Who |
|---|---|
| collected exactly `expected - tolerance` is not short; one piaster less is short | brief |
| collected exactly `expected + tolerance` is not over; one piaster more is over | brief |
| zero tolerance: off by 1 piaster is short/over, exact is neither | AI |
| failed line with `collected == 0` is valid, with `collected == 1` is invalid; same for returned | brief |
| valid failed/returned lines add nothing to `expectedTotal`/`collectedTotal` | brief |
| negative `collected` is invalid and excluded from totals; `collected == 0` on a delivered line is valid and short | brief / AI |
| repeated `parcelId`: the first line counts, the second is invalid; a third copy is listed again | brief / AI |
| a delivered line with the same id after a failed line is still a duplicate | AI |
| invalid lines (duplicate, negative, failed with cash) never reach any total | brief |
| `shortParcels`, `overParcels`, `invalidLines` sorted by id, given in scrambled order | brief |
| discrepancy sign (`collected - expected`), negative and positive | brief |
| within tolerance but discrepancy -1 is **not** balanced | AI |
| short and over cancelling out to 0 **is** balanced | AI |
| discrepancy 0 plus an invalid line is not balanced; an empty shift is balanced | brief / AI |
| `formatEgp`: 0, 1, 5, 9, 10, 50, 99, 100, 105 piasters | brief / AI |
| `formatEgp`: 999.99, 1,000.00, 1,234.50, 12,345.67, 123,456.78, 1,000,000.00 | brief / AI |
| `formatEgp` negatives: -EGP 12.00, -EGP 0.05, -EGP 0.01, -EGP 1,234.50 | brief / AI |
| screen: expected/collected/discrepancy text, negative and positive discrepancy | brief |
| screen: banner shown only when balanced; hidden for discrepancy 0 with an invalid line, and for -0.01 with no issues | brief / AI |
| screen: `summary-issue-<id>` for short, over and invalid parcels, not for a valid returned parcel | brief / AI |

## 4. One AI-suggested test I deleted or changed, and why

<!-- TODO: write your own example here. -->

A design choice worth noting: the screen tests do **not** compare `summary-discrepancy` against `formatEgp(report.discrepancy)`. If `formatEgp` had a bug, such a test would compute the same wrong value on both sides and still pass. The tests instead build a `ReconciliationReport` by hand and assert hard-coded strings such as `'-EGP 12.00'` and `'EGP 0.05'`.

## 5. Before and after my performance fix

Measured with the build counters in a widget test at 400×800, 2,000 parcels, then 5 clock ticks (`pump(1 s)` five times):

| | `ParcelTile.buildCount` on first display | `buildCount` after 5 ticks | `ParcelSorter.calls` |
|---|---|---|---|
| Before (Column in SingleChildScrollView, sort in `build`, clock in the list's state) | 2,000 | 12,000 | 6 |
| After (`ListView.builder`, sort in `initState`/`didUpdateWidget`, `ShiftClock` widget) | 14 | 14 | 1 |

Before the fix, every tick rebuilt all 2,000 rows and sorted the list again. After it, a tick rebuilds only the clock's `Text`.
