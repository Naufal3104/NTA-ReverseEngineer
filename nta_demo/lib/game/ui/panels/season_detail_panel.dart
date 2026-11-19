import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/game_data.dart';
import '../../models/game_state.dart';
import '../asset_manager.dart';
import '../design_tokens.dart';

/// Modal Season Detail — nama musim berjalan, sisa waktu ke musim
/// berikutnya, buff yang sedang aktif, aturan kemenangan.
/// Referensi: `Tampilan Rincian Season.jpg`.
class SeasonDetailPanel extends StatelessWidget {
  const SeasonDetailPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: const SeasonDetailPanel(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final idx = switch (state.season) {
      'Spring' => 0,
      'Summer' => 1,
      'Autumn' => 2,
      _ => 3,
    };
    final nextIdx = (idx + 1) % 4;
    final nextSeason = const ['Spring', 'Summer', 'Autumn', 'Winter'][nextIdx];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 60),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 680),
        child: Container(
          decoration: ntaPanel(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: NtaColors.surfaceCard,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Image.asset(
                      NtaAssets.season(idx),
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(state.season, style: NtaText.title),
                  const Spacer(),
                  Text('$nextSeason in ${state.seasonTimeLeftLabel}',
                      style: NtaText.sm.copyWith(fontSize: 12)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _seasonTile(i, i == idx),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                '+ Mystic remains showed up. Try to explore!\n'
                '+ Remains\' conqueror cannot leave the Union.\n'
                '+ If a force occupies 2 remains, Truce will not be available for the force anymore.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: NtaColors.textMuted,
                ),
              ),
              const Divider(height: 16, color: NtaColors.borderSoft),
              Row(
                children: [
                  Text('Victory rules: ${state.victoryCondition}',
                      style: NtaText.bodyBold.copyWith(fontSize: 13)),
                  const SizedBox(width: 6),
                  const Icon(Icons.help_outline, size: 14),
                ],
              ),
              const Divider(height: 16, color: NtaColors.borderSoft),
              Text('Active Policies this Season',
                  style: NtaText.bodyBold.copyWith(fontSize: 13)),
              const SizedBox(height: 6),
              _activePolicies(state),
              const Divider(height: 16, color: NtaColors.borderSoft),
              Text('+ Server Activeness:  3D10H',
                  style: NtaText.sm.copyWith(fontSize: 12)),
              Text(
                '+ Server Time:  ${_fmt(DateTime.now())}',
                style: NtaText.sm.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _activePolicies(GameState state) {
    final policies = state.activePolicies;
    if (policies.isEmpty) {
      return Text('No active policies this season.',
          style: NtaText.sm.copyWith(fontSize: 12, color: NtaColors.textMuted));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: policies.entries.map((e) {
        final slot = e.key;
        final info = e.value;
        final pid = info['policyId'];
        final tier = info['tier'] ?? 0;
        if (pid == null) return const SizedBox.shrink();
        final pol = GameData.policyById(pid);
        if (pol == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: NtaColors.surfaceRaised,
              borderRadius: BorderRadius.circular(NtaRadius.card),
              border: Border.all(color: NtaColors.borderSoft),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Slot ${slot + 1}: ',
                    style: NtaText.sm
                        .copyWith(fontSize: 11, fontWeight: FontWeight.w700)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pol['name'] as String,
                          style: NtaText.sm.copyWith(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        GameData.policyDesc(pol, tier),
                        style: NtaText.sm.copyWith(
                            fontSize: 11, color: NtaColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _seasonTile(int idx, bool active) {
    final available = active || idx == 0;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: active ? NtaColors.accentSoft : NtaColors.surfaceRaised,
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(
          color: active ? NtaColors.accentBorder : NtaColors.borderSoft,
          width: active ? 1.5 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: available
          ? Image.asset(
              NtaAssets.season(idx),
              width: 26,
              height: 26,
              filterQuality: FilterQuality.none,
            )
          : const Icon(Icons.lock, size: 20, color: NtaColors.textMuted),
    );
  }

  static String _fmt(DateTime t) =>
      '${t.month}/${t.day} ${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}';
}
