import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../design_tokens.dart';

/// Modal Construction Queue — daftar upgrade bangunan yang sedang berjalan.
/// Referensi: `Tampilan Button Construction Queue.jpg`.
///
/// Saat ini demo tidak punya queue builder; panel menampilkan slot yang
/// dikosongkan atau satu entri aktif (bila ada) dari `state.log` terakhir.
class ConstructionQueuePanel extends StatelessWidget {
  const ConstructionQueuePanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x55000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: const ConstructionQueuePanel(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    // Placeholder kartu pertama: upgrade Barrack Lv.(level+1) in-progress.
    final barrackLvl = state.capitalBuildings['barracks'] ?? 1;
    final nextLvl = barrackLvl + 1;

    return Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: ntaPanel(),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Construction Queue',
                    style: NtaText.title.copyWith(fontSize: 16)),
                const Spacer(),
                Row(
                  children: [
                    Text('Quick Complete',
                        style: NtaText.sm.copyWith(fontSize: 12)),
                    const SizedBox(width: 4),
                    const Icon(Icons.toll, size: 14, color: NtaColors.accentBorder),
                    const SizedBox(width: 2),
                    Text('30', style: NtaText.bodyBold.copyWith(fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _queueRow(
              icon: Icons.shield,
              title: 'Barrack Level $nextLvl',
              timeLeft: '1:58:51',
            ),
            const SizedBox(height: 8),
            _emptySlot(),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Unlock more construction queues.',
                style: NtaText.sm.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _queueRow({
    required IconData icon,
    required String title,
    required String timeLeft,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: NtaColors.accentSoft,
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(color: NtaColors.borderSoft),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: NtaColors.text),
          const SizedBox(width: 6),
          Expanded(
            child: Text(title,
                style: NtaText.bodyBold.copyWith(fontSize: 13)),
          ),
          Text(timeLeft,
              style: NtaText.bodyBold.copyWith(
                  fontSize: 13, color: NtaColors.success)),
          const SizedBox(width: 8),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: NtaColors.danger,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _emptySlot() {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: NtaColors.surfaceSunk,
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(color: NtaColors.borderSoft),
      ),
    );
  }
}
