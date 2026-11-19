import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../asset_manager.dart';
import '../design_tokens.dart';

/// Modal "Battle Rankings" — daftar peringkat pemain dalam sesi.
/// Referensi: `Tampilan Button Battle Rankings di Sesi Saat ini.jpg`.
///
/// Data: top-10 bot fiktif + baris pemain (poin = rewardPoints + tierWinPoints).
/// Bot AI mengisi papan sesuai difficulty index saat sesi berjalan.
class BattleRankingsPanel extends StatefulWidget {
  const BattleRankingsPanel({super.key, this.initialTab = 0});

  /// 0 = Personal, 1 = Union.
  final int initialTab;

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: BattleRankingsPanel(initialTab: initialTab),
      ),
    );
  }

  @override
  State<BattleRankingsPanel> createState() => _BattleRankingsPanelState();
}

class _BattleRankingsPanelState extends State<BattleRankingsPanel> {
  late int _tab;

  // Pre-generated ranking list so the panel doesn't reshuffle on rebuild.
  static final List<_RankRow> _botRows = _generateBots();

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final playerPts = state.rewardPoints + state.tierWinPoints;
    final playerLeague = state.rankTier.isNotEmpty ? state.rankTier : 'Diệp';

    final rows = <_RankRow>[
      for (final r in _botRows)
        if (r.points > playerPts) r,
    ];
    rows.sort((a, b) => b.points.compareTo(a.points));
    final top10 = rows.take(10).toList();
    final playerRow = _RankRow(
      rank: rows.length + 1,
      name: state.playerName,
      league: playerLeague,
      points: playerPts,
      isPlayer: true,
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 60),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 660),
        child: Container(
          decoration: ntaPanel(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(context),
              const Divider(height: 1, color: NtaColors.borderSoft),
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  itemCount: top10.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (_, i) {
                    if (i == top10.length) return _row(playerRow);
                    return _row(top10[i]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _tabBtn('Personal', 0),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _tabBtn('Union', 1),
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

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
      child: Row(
        children: [
          const Icon(Icons.emoji_events,
              size: 20, color: NtaColors.accentBorder),
          const SizedBox(width: 6),
          Text('Battle Rankings', style: NtaText.title.copyWith(fontSize: 16)),
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

  Widget _row(_RankRow r) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: r.isPlayer ? const Color(0xFFF6E2A4) : NtaColors.surfaceRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: r.isPlayer ? NtaColors.accentBorder : NtaColors.borderSoft,
          width: r.isPlayer ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text('${r.rank}',
                textAlign: TextAlign.center,
                style: NtaText.bodyBold.copyWith(fontSize: 14)),
          ),
          _avatar(r.rank, r.isPlayer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              r.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NtaText.body.copyWith(
                fontSize: 13,
                fontWeight: r.isPlayer ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: NtaColors.surfaceCard,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.military_tech, size: 12),
                const SizedBox(width: 2),
                Text(r.league, style: NtaText.xs.copyWith(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Icon(Icons.toll, size: 14, color: NtaColors.accentBorder),
              const SizedBox(width: 2),
              SizedBox(
                width: 42,
                child: Text('${r.points}',
                    textAlign: TextAlign.right,
                    style: NtaText.bodyBold.copyWith(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(int rank, bool isPlayer) {
    if (isPlayer) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: NtaColors.surfaceCard,
          border: Border.all(color: NtaColors.border, width: 1.5),
        ),
        child: const Icon(Icons.person, size: 18),
      );
    }
    final idx = (rank - 1) % 20;
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        NtaAssets.heroAvatar(_heroIds[idx % _heroIds.length]),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) => Container(
          color: NtaColors.surfaceCard,
          child: const Icon(Icons.person, size: 16),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final selected = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
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

  static const List<int> _heroIds = [
    310101, 310202, 310301, 310401, 310502, 310601,
    320101, 320202, 320301, 320402, 320502, 320602,
    310103, 310203, 310303, 310403, 310503, 310603,
    320103, 320203,
  ];

  static List<_RankRow> _generateBots() {
    const names = [
      'Mythsk', '枯れた彼岸花', '大四喜', '發發發', '眾裏尋她千百度',
      '汁男而上', 'kẻ hủy diệt', '半兵衛', '壹壹四五壹四', 'lu92149',
      'Dopamine', 'Jinlong', '徒手摘光', '青灯古寺', '苏格拉底',
    ];
    const leagues = ['Diệp', '蛋 倾城之剑', 'Ấu Long', 'Phi Phong'];
    final rnd = math.Random(42);
    final out = <_RankRow>[];
    for (int i = 0; i < names.length; i++) {
      out.add(_RankRow(
        rank: i + 1,
        name: names[i],
        league: leagues[i % leagues.length],
        points: 1450 - i * 38 - rnd.nextInt(10),
        isPlayer: false,
      ));
    }
    return out;
  }
}

class _RankRow {
  _RankRow({
    required this.rank,
    required this.name,
    required this.league,
    required this.points,
    required this.isPlayer,
  });

  final int rank;
  final String name;
  final String league;
  final int points;
  final bool isPlayer;
}
