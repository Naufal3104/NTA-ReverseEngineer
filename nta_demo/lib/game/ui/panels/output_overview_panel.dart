import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/game_data.dart';
import '../../models/game_state.dart';
import '../design_tokens.dart';

/// Modal Output Overview — rincian produksi per resource
/// (crop / wood / stone). Referensi: `Tampilan Rincian Resource *.jpg`.
class OutputOverviewPanel extends StatefulWidget {
  const OutputOverviewPanel({super.key, this.initialRes = 'crop'});

  final String initialRes;

  static Future<void> show(BuildContext context, {String initialRes = 'crop'}) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: OutputOverviewPanel(initialRes: initialRes),
      ),
    );
  }

  @override
  State<OutputOverviewPanel> createState() => _OutputOverviewPanelState();
}

class _OutputOverviewPanelState extends State<OutputOverviewPanel> {
  late String _res;

  @override
  void initState() {
    super.initState();
    _res = widget.initialRes;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final rates = state.getHourlyProduction();
    final rate = (rates[_res] ?? 0).round();

    final value = switch (_res) {
      'wood' => state.wood,
      'stone' => state.stone,
      _ => state.crop,
    };
    final cap = switch (_res) {
      'crop' => state.cropCapacity,
      _ => state.materialCapacity,
    };

    final levelRows = _levelRows(state, _res);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 70),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 680),
        child: Container(
          decoration: ntaPanel(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 6, 6),
                child: Row(
                  children: [
                    Text('Output Overview',
                        style: NtaText.title.copyWith(fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: 'Close',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  children: [
                    _tableHeader(),
                    const Divider(height: 4, color: NtaColors.borderSoft),
                    for (final r in levelRows) _tableRow(r),
                    const SizedBox(height: 10),
                    _statLine('Basic Output', rate),
                    _statLine('Resources Land Output', 0),
                    _statLine('Green bonus (not active)', 0,
                        color: NtaColors.danger),
                    _statLine('Soldier Consumption', 0, negative: true),
                    Divider(height: 10, color: NtaColors.borderSoft),
                    _statLine('Total output/h', rate, bold: true),
                    const SizedBox(height: 6),
                    Text(
                      'Current Resources/Capacity: $value/$cap',
                      style: NtaText.sm.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _resBtn('Crop', _res == 'crop')),
                        const SizedBox(width: 6),
                        Expanded(child: _resBtn('Wood', _res == 'wood')),
                        const SizedBox(width: 6),
                        Expanded(child: _resBtn('Stone', _res == 'stone')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Land',
                style: NtaText.bodyBold.copyWith(fontSize: 12)),
          ),
          SizedBox(
            width: 60,
            child: Text('Output',
                textAlign: TextAlign.right,
                style: NtaText.bodyBold.copyWith(fontSize: 12)),
          ),
          SizedBox(
            width: 60,
            child: Text('Qty',
                textAlign: TextAlign.right,
                style: NtaText.bodyBold.copyWith(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(_OutRow r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: NtaResIcon(_res, size: 14),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(r.label,
                      style: NtaText.body.copyWith(fontSize: 12)),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(r.output,
                textAlign: TextAlign.right,
                style: NtaText.body.copyWith(fontSize: 12)),
          ),
          SizedBox(
            width: 60,
            child: Text(r.qty,
                textAlign: TextAlign.right,
                style: NtaText.body.copyWith(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _statLine(String label, int value,
      {bool bold = false, bool negative = false, Color? color}) {
    final text = bold
        ? NtaText.bodyBold.copyWith(fontSize: 13)
        : NtaText.body.copyWith(fontSize: 12);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: text)),
          Text(
            negative ? '-$value' : '$value',
            style: text.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _resBtn(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _res = label.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NtaColors.accentTop : NtaColors.surfaceRaised,
          borderRadius: BorderRadius.circular(NtaRadius.button),
          border: Border.all(color: NtaColors.border, width: NtaBorder.card),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: NtaText.bodyBold.copyWith(fontSize: 13)),
      ),
    );
  }

  /// Kelompokkan plot dikuasai per level dan hitung kontribusinya ke resource
  /// terpilih. Lv.1 (wasteland) diabaikan di tabel (bukan produksi khusus).
  static List<_OutRow> _levelRows(GameState state, String res) {
    final groups = <int, List<Map<String, dynamic>>>{};
    for (final k in state.conqueredPlots) {
      final r = int.tryParse(k.split(',')[0]) ?? 0;
      final c = int.tryParse(k.split(',')[1]) ?? 0;
      final p = state.getPlotData(r, c);
      if (p == null) continue;
      final lv = p['level'] as int? ?? 1;
      groups.putIfAbsent(lv, () => []).add(p);
    }
    final out = <_OutRow>[];
    for (int lv = 5; lv >= 2; lv--) {
      final list = groups[lv] ?? const [];
      int sum = 0;
      for (final p in list) {
        final landType = p['landType'] as int? ?? 3;
        final y = GameData.landYield(landType, lv);
        sum += (y[res] ?? 0).round();
      }
      final qty = list.isEmpty ? '-' : '${list.length}';
      out.add(_OutRow(
        label: 'Lv.$lv ${_resTitle(res)} Plot',
        output: list.isEmpty ? '-' : '$sum',
        qty: qty,
      ));
    }
    return out;
  }

  static String _resTitle(String res) =>
      res == 'wood' ? 'Wood' : (res == 'stone' ? 'Stone' : 'Crop');
}

class _OutRow {
  const _OutRow({required this.label, required this.output, required this.qty});
  final String label;
  final String output;
  final String qty;
}
