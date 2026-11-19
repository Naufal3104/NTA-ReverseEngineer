import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../design_tokens.dart';

/// Modal March List — tim yang sedang march / move. Referensi:
/// `Tampilan Button March List.jpg`.
///
/// Demo offline tidak membangun harmoni march system penuh; panel menampilkan
/// entri dari `state.marches` + slot kosong fallback.
class MarchListPanel extends StatelessWidget {
  const MarchListPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x55000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: const MarchListPanel(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final marches = state.marches;

    // Fallback: sample 5 teams if no marches recorded, so this modal shows
    // the reference layout out of the box.
    final List<MapEntry<int, String>> rows;
    if (marches.isNotEmpty) {
      rows = [
        for (final m in marches)
          MapEntry(m['team'] as int? ?? 1,
              '${m['state'] ?? 'Move'} ${m['target'] ?? 'Capital'}'),
      ];
    } else {
      const teamList = [6, 8, 1, 3, 10];
      rows = [
        for (final t in teamList) MapEntry(t, 'Move Fortress(141,245)'),
      ];
    }

    return Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: ntaPanel(),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('March List',
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
            const SizedBox(height: 4),
            for (int i = 0; i < rows.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text('Team ${rows[i].key}',
                          style: NtaText.bodyBold.copyWith(fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(rows[i].value,
                          style: NtaText.sm.copyWith(
                              fontSize: 12, color: NtaColors.text)),
                    ),
                    Text(
                      '0:${(11 + i * 3).toString().padLeft(2, '0')}:'
                      '${(27 - i * 2).toString().padLeft(2, '0')}',
                      style: NtaText.sm.copyWith(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: NtaColors.danger,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
