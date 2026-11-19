import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../design_tokens.dart';
import '../troop_catalog.dart';

/// Modal "Armies" — 3 tab sesuai referensi `Tampilan Button Armies ...`:
///   1. All Armies   — daftar army/team (Capital / Fortress target + status)
///   2. Territory    — jumlah land per level + poin yang didapat
///   3. Battle Report— entri battle terakhir (Victory/Defeat, kills, fallen)
class ArmiesPanel extends StatefulWidget {
  const ArmiesPanel({super.key, this.initialTab = 0});

  final int initialTab;

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: ArmiesPanel(initialTab: initialTab),
      ),
    );
  }

  @override
  State<ArmiesPanel> createState() => _ArmiesPanelState();
}

class _ArmiesPanelState extends State<ArmiesPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final capitalLvl = state.capitalBuildings['palace'] ?? 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tabBar(context),
            Flexible(
              child: Container(
                decoration: ntaPanel(radius: 0),
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _AllArmiesTab(
                      state: state,
                      capitalLvl: capitalLvl,
                    ),
                    _TerritoryTab(state: state),
                    _BattleReportTab(state: state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: NtaColors.surfaceSunk),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _tab.index = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _tab.index == i
                        ? NtaColors.surface
                        : NtaColors.surfaceCard,
                    border: Border(
                      bottom: BorderSide(
                        color: _tab.index == i
                            ? NtaColors.border
                            : Colors.transparent,
                        width: NtaBorder.button,
                      ),
                    ),
                  ),
                  child: Text(
                    const ['All Armies', 'Territory', 'Battle Report'][i],
                    textAlign: TextAlign.center,
                    style: NtaText.bodyBold.copyWith(
                      fontSize: 13,
                      color: _tab.index == i
                          ? NtaColors.text
                          : NtaColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =========================================================================
// Tab 1 — All Armies
// =========================================================================

class _AllArmiesTab extends StatelessWidget {
  const _AllArmiesTab({required this.state, required this.capitalLvl});

  final GameState state;
  final int capitalLvl;

  @override
  Widget build(BuildContext context) {
    final cap = state.armyCap;
    final marches = state.marches;
    final teams = <int>{for (int i = 1; i <= cap; i++) i};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(context, cap),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            itemCount: teams.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final teamNo = teams.elementAt(i);
              final march = marches.firstWhere(
                (m) => m['team'] == teamNo,
                orElse: () => const {},
              );
              return _TeamCard(
                teamNo: teamNo,
                state: state,
                capitalLvl: capitalLvl,
                march: march.isEmpty ? null : march,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, int cap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        children: [
          Text('Owned Armies (${state.armyCap}/$cap)',
              style: NtaText.bodyBold.copyWith(fontSize: 13)),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 22),
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.teamNo,
    required this.state,
    required this.capitalLvl,
    required this.march,
  });

  final int teamNo;
  final GameState state;
  final int capitalLvl;
  final Map<String, dynamic>? march;

  @override
  Widget build(BuildContext context) {
    final target = (march?['target'] as String?) ?? 'Capital';
    final st = (march?['state'] as String?) ?? 'Idle';
    final chest = march?['chest'] as int?;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: ntaCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Team $teamNo', style: NtaText.bodyBold),
              const Spacer(),
              Text(target,
                  style: NtaText.sm.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            child: Row(
              children: [
                for (final e in state.troops.entries)
                  if (e.value > 0)
                    _troopBadge(e.key, e.value),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  st == 'Idle'
                      ? 'Idle · Lv.$capitalLvl capital'
                      : '$st ${_fmt((march?['secondsLeft'] as int?) ?? 0)}',
                  style: NtaText.sm.copyWith(
                    fontSize: 12,
                    color: st == 'Idle' ? NtaColors.textMuted : NtaColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (chest != null)
                Row(
                  children: [
                    const Icon(Icons.card_giftcard,
                        size: 16, color: NtaColors.accentBorder),
                    const SizedBox(width: 2),
                    Text('Obtained Chest*$chest',
                        style: NtaText.sm.copyWith(
                            fontSize: 12,
                            color: NtaColors.success,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _troopBadge(String id, int count) {
    return Tooltip(
      message: '${TroopCatalog.nameOf(id)} x$count',
      child: Container(
        margin: const EdgeInsets.only(right: 3),
        width: 26,
        height: 28,
        decoration: BoxDecoration(
          color: NtaColors.surfaceRaised,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: NtaColors.border, width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              TroopCatalog.shortOf(id),
              style: NtaText.xs.copyWith(
                  fontSize: 9, fontWeight: FontWeight.w700),
            ),
            Positioned(
              bottom: 0,
              right: 1,
              child: Text('$count',
                  style: NtaText.xs.copyWith(
                      fontSize: 8, color: NtaColors.success)),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// Tab 2 — Territory
// =========================================================================

class _TerritoryTab extends StatelessWidget {
  const _TerritoryTab({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final counts = _countsByLevel(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(context),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            children: [
              _truceBanner(),
              const SizedBox(height: 10),
              for (int lv = 1; lv <= 5; lv++) ...[
                _levelRow(lv, counts[lv] ?? 0),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: _filterBtn('Home', selected: true)),
                  const SizedBox(width: 6),
                  Expanded(child: _filterBtn('Crop')),
                  const SizedBox(width: 6),
                  Expanded(child: _filterBtn('Wood')),
                  const SizedBox(width: 6),
                  Expanded(child: _filterBtn('Stone')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        children: [
          const Icon(Icons.flag, size: 18, color: NtaColors.text),
          const SizedBox(width: 6),
          Text('Territory: ${state.conqueredPlots.length}',
              style: NtaText.bodyBold.copyWith(fontSize: 13)),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 22),
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _truceBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NtaColors.surfaceRaised,
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(color: NtaColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance,
                  size: 16, color: NtaColors.text),
              const SizedBox(width: 6),
              Text('Truce in Capital',
                  style: NtaText.bodyBold.copyWith(fontSize: 13)),
              const SizedBox(width: 6),
              Text('🛡 ${state.seasonTimeLeftLabel}',
                  style: NtaText.sm.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'If there are more than 200 territories, the Capital\'s truce time will be reduced by 48h.',
            style: NtaText.sm.copyWith(
                fontSize: 11, color: NtaColors.danger),
          ),
        ],
      ),
    );
  }

  Widget _levelRow(int lv, int owned) {
    final caps = const [120, 80, 40, 24, 20];
    final points = const [2, 2, 6, 8, 5];
    final earned = (owned * points[lv - 1]).clamp(0, 9999);
    final maxPts = (caps[lv - 1] * points[lv - 1]).clamp(1, 9999);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: ntaCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Lv.$lv Land: $owned', style: NtaText.bodyBold),
              const Spacer(),
              Text('Obtained 🛡 $earned/$maxPts',
                  style: NtaText.sm.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 2),
          Text(_rangeLabel(lv, caps[lv - 1], points[lv - 1]),
              style: NtaText.sm.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _filterBtn(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: selected ? NtaColors.accentTop : NtaColors.surfaceRaised,
        borderRadius: BorderRadius.circular(NtaRadius.button),
        border: Border.all(color: NtaColors.border, width: NtaBorder.card),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: NtaText.sm.copyWith(fontWeight: FontWeight.w700)),
    );
  }

  /// Teks rentang poin per level, mengikuti referensi
  /// `Tampilan Button Armies ... Panel 2 Territory.jpg`:
  ///   Lv.1 "100+: No more points to earn."
  ///   Lv.2 "(41~80: Each land +2 Point(s))"
  ///   Lv.3 "(0~30: Each land +6 Point(s))"
  ///   Lv.4 "(0~20: Each land +8 Point(s))"
  ///   Lv.5 "(11~20: Each land +5 Point(s))"
  static String _rangeLabel(int lv, int cap, int pts) {
    if (lv == 1) return '100+: No more points to earn.';
    final int lo = const [0, 41, 0, 0, 11][lv - 1];
    final int hi = const [0, 80, 30, 20, 20][lv - 1];
    return '(${lv == 1 ? '100+' : '$lo~$hi'}): Each land +$pts Point(s)';
  }

  static Map<int, int> _countsByLevel(GameState state) {
    final out = <int, int>{};
    for (final k in state.conqueredPlots) {
      final p = state.getPlotData(
        int.tryParse(k.split(',')[0]) ?? 0,
        int.tryParse(k.split(',')[1]) ?? 0,
      );
      final lv = (p?['level'] as int?) ?? 1;
      out[lv] = (out[lv] ?? 0) + 1;
    }
    return out;
  }
}

// =========================================================================
// Tab 3 — Battle Report
// =========================================================================

class _BattleReportTab extends StatelessWidget {
  const _BattleReportTab({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final reports = state.battleReports;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(context),
        Expanded(
          child: reports.isEmpty
              ? Center(
                  child: Text('No battles yet. Conquer a plot to fill this list.',
                      style: NtaText.sm, textAlign: TextAlign.center),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  itemCount: reports.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _reportCard(reports[i]),
                ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        children: [
          const Icon(Icons.article, size: 18, color: NtaColors.text),
          const SizedBox(width: 6),
          Text('Battle Report', style: NtaText.bodyBold.copyWith(fontSize: 13)),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 22),
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _reportCard(Map<String, dynamic> r) {
    final victory = r['victory'] == true;
    final t = r['time'] as DateTime?;
    final timeStr = t == null
        ? ''
        : '${t.year}-${_two(t.month)}-${_two(t.day)} '
            '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
    final rounds = (r['rounds'] as int?) ?? 0;
    final kills = (r['kills'] as int?) ?? 0;
    final fallen = (r['fallen'] as int?) ?? 0;
    final armies = (r['armies'] as int?) ?? 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: ntaCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(victory ? '🏆 Victory' : '💀 Defeat',
                  style: NtaText.bodyBold.copyWith(
                      fontSize: 13,
                      color: victory ? NtaColors.success : NtaColors.danger)),
              const Spacer(),
              Text(timeStr, style: NtaText.sm.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Battled at ${r['targetLabel'] ?? ''}', style: NtaText.sm.copyWith(fontSize: 12)),
          Text('Battle time cost: 0:${_two(rounds)}',
              style: NtaText.sm.copyWith(fontSize: 12)),
          Text('There are $armies armies that participated in the battle.',
              style: NtaText.sm.copyWith(fontSize: 12)),
          Text('Kills: $kills', style: NtaText.sm.copyWith(fontSize: 12)),
          Text('Fallen units: $fallen',
              style: NtaText.sm.copyWith(fontSize: 12)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: NtaColors.accentTop,
                borderRadius: BorderRadius.circular(NtaRadius.button),
                border: Border.all(color: NtaColors.accentBorder),
              ),
              child: Text('Replay',
                  style: NtaText.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: NtaColors.onAccent)),
            ),
          ),
        ],
      ),
    );
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
