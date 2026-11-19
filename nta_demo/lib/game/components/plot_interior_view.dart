import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/game_data.dart';
import '../models/battle_engine.dart';
import '../models/game_state.dart';
import '../ui/asset_manager.dart';
import '../ui/design_tokens.dart';

class PlotInteriorView extends StatefulWidget {
  const PlotInteriorView({super.key});

  @override
  State<PlotInteriorView> createState() => _PlotInteriorViewState();
}

class _PlotInteriorViewState extends State<PlotInteriorView>
    with SingleTickerProviderStateMixin {
  bool _isBattling = false;
  Map<String, dynamic>? _battleResult;

  // Replay state: index into events/frames, -1 = pre-battle layout.
  int _replayIndex = -1;
  Timer? _replayTimer;
  AnimationController? _clipController;

  /// Current plot coordinates (read from GameState to support IndexedStack reuse)
  int get _row => context.read<GameState>().plotViewRow;
  int get _col => context.read<GameState>().plotViewCol;

  @override
  void initState() {
    super.initState();
    _clipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 130))
      ..addStatusListener(_onClipStatus);
  }

  /// Frame animation loop: restart while the current event's action needs it.
  void _onClipStatus(AnimationStatus s) {
    if (s != AnimationStatus.completed) return;
    final act = _currentAction;
    if (act == 'attack' || act == 'skill') {
      _clipController!.forward(from: 0);
    }
  }

  /// `attack`/`skill` events replay the `drill` clip once; moves replay `walk`.
  String? get _currentAction =>
      _replayIndex >= 0 && _replayIndex < _events.length
          ? _events[_replayIndex].action
          : null;

  /// Snapshot unit pelaku event saat ini (dari frame replay).
  UnitSnapshot? get _actor {
    if (_replayIndex < 0 ||
        _replayIndex >= _events.length ||
        _replayIndex >= _frames.length) {
      return null;
    }
    final uid = _events[_replayIndex].actorUid;
    if (uid == null) return null;
    for (final u in _frames[_replayIndex]) {
      if (u.id == uid) return u;
    }
    return null;
  }

  /// Klip yang dipakai pelaku: walk saat bergerak, drill saat menyerang.
  String? get _actorClip {
    switch (_currentAction) {
      case 'move':
        return 'walk';
      case 'attack':
      case 'skill':
        return 'drill';
      default:
        return null;
    }
  }

  /// Mulai animasi pelaku untuk event terpilih (durasi = count / fps asli).
  void _startClip() {
    final c = _clipController;
    if (c == null) return;
    final u = _actor;
    final key = _actorClip;
    if (u == null || key == null) {
      c.stop();
      return;
    }
    final info = NtaAssets.unitClip(u.pawnId, key);
    if (info == null) {
      c.stop();
      return;
    }
    final count = info[0].toDouble();
    final fps = info[1].toDouble();
    c.duration = Duration(milliseconds: (1000 * count / fps).round());
    c.forward(from: 0);
  }

  /// Frame animasi ke-`i` untuk unit, kalau unit itu pelaku event sekarang.
  String? _animFrameFor(UnitSnapshot u) {
    final c = _clipController;
    final key = _actorClip;
    final actor = _actor;
    if (c == null || key == null || actor == null || actor.id != u.id) return null;
    final info = NtaAssets.unitClip(u.pawnId, key);
    if (info == null) return null;
    final count = info[0].toInt();
    final i = (c.value * count).floor().clamp(0, count - 1);
    return NtaAssets.unitAnimFrame(u.pawnId, key, i);
  }

  @override
  void dispose() {
    _replayTimer?.cancel();
    _clipController?.dispose();
    super.dispose();
  }

  List<BattleEvent> get _events =>
      (_battleResult?['events'] as List<BattleEvent>?) ?? const [];

  List<List<UnitSnapshot>> get _frames =>
      (_battleResult?['frames'] as List<List<UnitSnapshot>>?) ?? const [];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final remains = state.remainsAt(_row, _col);
    if (remains != null) return _buildRemainsScaffold(state, remains);

    final isConquered = state.isTileConquered(_row, _col);
    final plotData = state.getPlotData(_row, _col);
    final plotLvl = plotData?['level'] as int? ?? 1;
    final resType = plotData?['resource'] as String? ?? 'crop';
    final garrisonName = plotData?['garrisonName'] as String? ?? 'Wild Wolf Pack';
    final difficulty = plotData?['difficulty'] as String? ?? 'Easy 1';

    return Scaffold(
      backgroundColor: NtaColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(NtaSpace.panelPad),
              decoration: BoxDecoration(
                color: NtaColors.surfaceCard,
                border: const Border(
                  bottom: BorderSide(color: NtaColors.border, width: NtaBorder.panel),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: NtaColors.textMuted,
                          tooltip: 'Back to map',
                          onPressed: () {
                            _replayTimer?.cancel();
                            state.goToMap();
                          },
                        ),
                        Icon(
                          isConquered ? Icons.flag : Icons.crisis_alert,
                          color: isConquered ? NtaColors.success : NtaColors.danger,
                        ),
                        const SizedBox(width: NtaSpace.itemGap),
                        Flexible(
                          child: Text(
                            'Plot ($_row, $_col)',
                            style: NtaText.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: NtaSpace.x5, vertical: NtaSpace.x2),
                    decoration: BoxDecoration(
                      color: isConquered
                          ? NtaColors.success.withValues(alpha: 0.12)
                          : NtaColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(NtaRadius.pill),
                      border: Border.all(
                        color: isConquered ? NtaColors.success : NtaColors.danger,
                        width: NtaBorder.hairline,
                      ),
                    ),
                    child: Text(
                      isConquered ? 'Controlled Territory' : 'Hostile Plot (Lv. $plotLvl)',
                      style: NtaText.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isConquered ? NtaColors.success : NtaColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(NtaSpace.x5),
              color: NtaColors.surfaceSunk,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _infoBadge(
                      'Resource',
                      _productionLabel(plotLvl, resType),
                      sprite: NtaAssets.plotIcon(resType, plotLvl),
                    ),
                  ),
                  Flexible(
                    child: _infoBadge('Terrain', state.getTileTerrainName(_row, _col)),
                  ),
                  Flexible(
                    child: _infoBadge(
                      'Status',
                      isConquered ? 'Secured (Watchtower & Flag)' : '$garrisonName [$difficulty]',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(NtaSpace.panelPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isConquered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: NtaSpace.panelPad),
                        child: _buildGroundBuildingCard(state, resType),
                      ),
                    Center(
                      child: Container(
                        width: 330,
                        height: 330,
                        decoration: BoxDecoration(
                          color: NtaColors.mapGreenA,
                          border: Border.all(color: NtaColors.border, width: NtaBorder.card),
                          borderRadius: BorderRadius.circular(NtaRadius.card),
                        ),
                        child: _buildBattleGrid(isConquered, plotLvl, state),
                      ),
                    ),
                    if (_battleResult != null) ...[
                      const SizedBox(height: NtaSpace.panelPad),
                      _buildBattleSummary(_battleResult!),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(NtaSpace.panelPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isConquered)
                    NtaGoldButton(
                      _isBattling ? 'Engaging Enemy...' : 'Assault Plot (Automated Turns)',
                      onTap: _isBattling ? null : () => _executeAssault(context),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NtaSpace.panelPad,
                        vertical: NtaSpace.x5,
                      ),
                      decoration: BoxDecoration(
                        color: NtaColors.disabled,
                        border: Border.all(color: NtaColors.borderSoft, width: NtaBorder.button),
                        borderRadius: BorderRadius.circular(NtaRadius.button),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 18, color: NtaColors.textMuted),
                          const SizedBox(width: NtaSpace.x3),
                          Builder(builder: (context) {
                            final tower = state.plotTowerStats(_row, _col);
                            final isFortress =
                                state.getGroundBuilding(_row, _col)?['type'] == 'fortress';
                            return Text(
                              isFortress
                                  ? 'Secured by Fortress (HP ${tower['hp']} / ATK ${tower['atk']})'
                                  : 'Secured with Watchtower (HP ${tower['hp']} / ATK ${tower['atk']})',
                              style: NtaText.body.copyWith(color: NtaColors.textMuted),
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Remains interior: same 11x11 grid layout as a normal plot, but the
  /// garrison is the neutral Lv.6 neutral-capital army and the win condition
  /// is capturing/levelling the Remains instead of a plot flag.
  Widget _buildRemainsScaffold(GameState state, Map<String, dynamic> remains) {
    final int id = remains['id'] as int;
    final bool owned = remains['owner'] == 'player';
    final int level = remains['level'] as int;
    final String owner = remains['owner'] as String;
    final Map<String, int> cost = state.remainsUpgradeCost(id);
    final bool atMax = level >= GameData.REMAINS_MAX_LEVEL;
    final bool canAfford = cost.isNotEmpty && state.hasResources(cost);
    final String costText =
        cost.entries.map((e) => '${e.value} ${e.key}').join(', ');

    return Scaffold(
      backgroundColor: NtaColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(NtaSpace.panelPad),
              decoration: BoxDecoration(
                color: NtaColors.surfaceCard,
                border: const Border(
                  bottom: BorderSide(color: NtaColors.border, width: NtaBorder.panel),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: NtaColors.textMuted,
                    tooltip: 'Back to map',
                    onPressed: () {
                      _replayTimer?.cancel();
                      state.goToMap();
                    },
                  ),
                  Icon(
                    owned ? Icons.account_balance : Icons.gavel,
                    color: owned ? NtaColors.success : NtaColors.danger,
                  ),
                  const SizedBox(width: NtaSpace.itemGap),
                  Flexible(
                    child: Text(
                      '${remains['name']} Remains',
                      style: NtaText.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: NtaSpace.x5, vertical: NtaSpace.x2),
                    decoration: BoxDecoration(
                      color: owned
                          ? NtaColors.success.withValues(alpha: 0.12)
                          : NtaColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(NtaRadius.pill),
                      border: Border.all(
                        color: owned ? NtaColors.success : NtaColors.danger,
                        width: NtaBorder.hairline,
                      ),
                    ),
                    child: Text(
                      owned ? 'Your Remains (Lv.$level)' : 'Lv.$level · $owner',
                      style: NtaText.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: owned ? NtaColors.success : NtaColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(NtaSpace.x5),
              color: NtaColors.surfaceSunk,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(child: _infoBadge('Level', 'Lv.$level / ${GameData.REMAINS_MAX_LEVEL}')),
                  Flexible(child: _infoBadge('Held by', owned ? 'You' : owner)),
                  Flexible(
                    child: _infoBadge(
                      'Garrison',
                      owned ? 'Your army' : 'Neutral Lv.6 soldiers',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(NtaSpace.panelPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (owned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: NtaSpace.sectionGap, vertical: NtaSpace.itemGap),
                        decoration: ntaCard(),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Remains Construction (Level $level)',
                                      style: NtaText.bodyBold
                                          .copyWith(color: NtaColors.success)),
                                  Text(
                                    atMax
                                        ? 'Maximum level reached.'
                                        : 'Next level: $costText',
                                    style: NtaText.caption,
                                  ),
                                ],
                              ),
                            ),
                            if (!atMax)
                              NtaGoldButton(
                                'Upgrade to Lv.${level + 1}',
                                fontSize: 12,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
                                onTap: canAfford ? () => state.upgradeRemains(id) : null,
                              )
                            else
                              Text('Max Lv.${GameData.REMAINS_MAX_LEVEL}',
                                  style: NtaText.caption),
                          ],
                        ),
                      ),
                    const SizedBox(height: NtaSpace.panelPad),
                    Center(
                      child: Container(
                        width: 330,
                        height: 330,
                        decoration: BoxDecoration(
                          color: NtaColors.mapGreenA,
                          border: Border.all(color: NtaColors.border, width: NtaBorder.card),
                          borderRadius: BorderRadius.circular(NtaRadius.card),
                        ),
                        child: _buildRemainsGrid(state, owned),
                      ),
                    ),
                    if (_battleResult != null) ...[
                      const SizedBox(height: NtaSpace.panelPad),
                      _buildBattleSummary(_battleResult!),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(NtaSpace.panelPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!owned)
                    NtaGoldButton(
                      _isBattling ? 'Engaging Garrison...' : 'Assault Remains (Automated Turns)',
                      onTap: _isBattling ? null : () => _executeRemainsAssault(context, id),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: NtaSpace.panelPad, vertical: NtaSpace.x5),
                      decoration: BoxDecoration(
                        color: NtaColors.disabled,
                        border: Border.all(color: NtaColors.borderSoft, width: NtaBorder.button),
                        borderRadius: BorderRadius.circular(NtaRadius.button),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 18, color: NtaColors.textMuted),
                          const SizedBox(width: NtaSpace.x3),
                          Text(
                            'Secured — Lv.$level remains under your control',
                            style: NtaText.body.copyWith(color: NtaColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainsGrid(GameState state, bool owned) {
    final frames = _frames;
    final hasReplay = frames.isNotEmpty && _replayIndex >= 0;
    final units = hasReplay
        ? frames[_replayIndex].where((u) => u.hp > 0).toList()
        : const <UnitSnapshot>[];

    final stacks = <String, List<UnitSnapshot>>{};
    for (final u in units) {
      stacks.putIfAbsent('${u.row},${u.col}', () => []).add(u);
    }

    const cell = 330 / 11;

    // RepaintBoundary isolates the static grid from unit token animations.
    return RepaintBoundary(
      child: Stack(
        children: [
          Column(
            children: List.generate(11, (r) {
              return Expanded(
                child: Row(
                  children: List.generate(11, (c) {
                    return Expanded(
                      child: _buildRemainsCell(r, c, owned),
                    );
                  }),
                ),
              );
            }),
          ),
          for (final entry in stacks.entries)
            for (var i = 0; i < entry.value.length; i++)
              Positioned(
                left: int.parse(entry.key.split(',')[1]) * cell + i * 2.0,
                top: int.parse(entry.key.split(',')[0]) * cell + i * 2.0,
                width: cell - 2 - i * 2.0,
                height: cell - 2 - i * 2.0,
                child: IgnorePointer(child: _buildUnitToken(entry.value[i])),
              ),
        ],
      ),
    );
  }

  Widget _buildRemainsCell(int r, int c, bool owned) {
    final bool isCenter = (r == 5 && c == 5);
    final bool isNorthGate = (r == 0 && c == 5);
    final bool isSouthGate = (r == 10 && c == 5);
    final bool isWestGate = (r == 5 && c == 0);
    final bool isEastGate = (r == 5 && c == 10);
    final bool isRoad = (r == 5 || c == 5);

    if (isCenter) {
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: owned ? NtaColors.accent : NtaColors.danger,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: owned ? NtaColors.accentBorder : NtaColors.border,
            width: NtaBorder.card,
          ),
        ),
        child: Center(
          child: Icon(
            owned ? Icons.account_balance : Icons.castle,
            size: 16,
            color: owned ? NtaColors.onAccent : NtaColors.textOnDark,
          ),
        ),
      );
    }

    if (isNorthGate || isSouthGate || isWestGate || isEastGate) {
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: NtaColors.borderInput,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: NtaColors.accentBorder, width: NtaBorder.hairline),
        ),
        child: const Center(
          child: Icon(Icons.meeting_room, size: 12, color: NtaColors.textOnDark),
        ),
      );
    }

    if (isRoad) {
      return Container(margin: const EdgeInsets.all(0.5), color: NtaColors.mapRoad);
    }

    return Container(
      margin: const EdgeInsets.all(0.5),
      color: ((r + c) % 2 == 0) ? NtaColors.mapGreenA : NtaColors.mapGreenB,
    );
  }

  void _executeRemainsAssault(BuildContext context, int id) {
    setState(() => _isBattling = true);

    final state = context.read<GameState>();
    final result = state.attackRemains(id);

    _replayTimer?.cancel();
    _replayTimer = null;
    setState(() {
      _isBattling = false;
      _battleResult = result;
      final events = (result['events'] as List<BattleEvent>?) ?? const [];
      _replayIndex = events.isEmpty ? -1 : events.length - 1;
    });
    _startClip();
  }

  Widget _buildGroundBuildingCard(GameState state, String resType) {
    final building = state.getGroundBuilding(_row, _col);

    if (building != null) {
      final type = building['type'] as String;
      final lvl = building['level'] as int? ?? 1;
      final bDef = GameData.GROUND_BUILDINGS.firstWhere(
        (b) => b['id'] == type,
        orElse: () => GameData.GROUND_BUILDINGS[0],
      );
      final isFortress = type == 'fortress';
      final maxLevel = state.groundBuildingMaxLevel(type);
      final tower = isFortress ? state.plotTowerStats(_row, _col) : null;
      final costMap = (bDef['cost'] as Map<String, dynamic>).cast<String, int>();
      final nextCost = <String, int>{};
      for (var e in costMap.entries) {
        nextCost[e.key] = e.value * (lvl + 1);
      }
      final canAfford = state.hasResources(nextCost);
      final atMax = lvl >= maxLevel;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.itemGap),
        decoration: ntaCard(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ground Facility: ${bDef['name']} (Level $lvl)',
                    style: NtaText.bodyBold.copyWith(color: NtaColors.success),
                  ),
                  Text(
                    isFortress
                        ? 'Tower HP ${tower!['hp']} / ATK ${tower['atk']} · 3x march speed · field heal'
                        : 'Resource Output: ${(bDef['production'] as Map<String, dynamic>?)?['${bDef['resource']}'] ?? 0}/h · Level $lvl',
                    style: NtaText.caption,
                  ),
                ],
              ),
            ),
            if (isFortress && state.woundedTroops > 0)
              Padding(
                padding: const EdgeInsets.only(right: NtaSpace.x3),
                child: NtaGoldButton(
                  'Field Heal',
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: NtaSpace.itemGap, vertical: NtaSpace.x3),
                  onTap: () => state.fieldHealAtFortress(_row, _col),
                ),
              ),
            if (!atMax)
              NtaGoldButton(
                'Upgrade to Lv.${lvl + 1}',
                fontSize: 12,
                padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
                onTap: canAfford ? () => state.upgradeGroundBuilding(_row, _col) : null,
              )
            else
              Text('Max Lv.$maxLevel', style: NtaText.caption),
          ],
        ),
      );
    }

    final targetType = state.defaultGroundBuildingType(_row, _col);
    final farmDef = GameData.GROUND_BUILDINGS.firstWhere(
      (b) => b['id'] == targetType,
      orElse: () => GameData.GROUND_BUILDINGS[0],
    );
    final fortressDef = GameData.GROUND_BUILDINGS.firstWhere((b) => b['id'] == 'fortress');

    return Column(
      children: [
        _constructRow(state, farmDef, targetType),
        const SizedBox(height: NtaSpace.itemGap),
        _constructRow(state, fortressDef, 'fortress'),
      ],
    );
  }

  Widget _constructRow(GameState state, Map<String, dynamic> bDef, String type) {
    final costMap = (bDef['cost'] as Map<String, dynamic>).cast<String, int>();
    final canAfford = state.hasResources(costMap);
    final costText = costMap.entries.map((e) => '${e.value} ${e.key}').join(', ');
    final isFortress = type == 'fortress';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.itemGap),
      decoration: ntaRaisedCard(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Facility: ${bDef['name']}', style: NtaText.bodyBold),
                Text(
                  isFortress
                      ? 'Replaces the Watchtower (HP 80 / ATK 16). Cost: $costText'
                      : 'Produces ${(bDef['production'] as Map<String, dynamic>?)?['${bDef['resource']}'] ?? 0}/h. Cost: $costText',
                  style: NtaText.caption,
                ),
              ],
            ),
          ),
          NtaGoldButton(
            'Construct ${bDef['name']}',
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
            onTap: canAfford
                ? () => state.constructGroundBuilding(_row, _col, type: type)
                : null,
          ),
        ],
      ),
    );
  }

  /// Grid 11x11 + token unit di atasnya (saat replay) atau dekorasi plot.
  /// Unit di tile sama digambar bertumpuk (cascade) — aturan asli: army
  /// penyerang menumpuk di 1 tile gerbang. Unit mati disembunyikan.
  Widget _buildBattleGrid(bool isConquered, int plotLvl, GameState state) {
    final frames = _frames;
    final hasReplay = frames.isNotEmpty && _replayIndex >= 0;
    final units = hasReplay
        ? frames[_replayIndex].where((u) => u.hp > 0).toList()
        : const <UnitSnapshot>[];

    final stacks = <String, List<UnitSnapshot>>{};
    for (final u in units) {
      stacks.putIfAbsent('${u.row},${u.col}', () => []).add(u);
    }

    const cell = 330 / 11;

    // RepaintBoundary isolates the static grid from unit token animations.
    return RepaintBoundary(
      child: Stack(
        children: [
          Column(
            children: List.generate(11, (r) {
              return Expanded(
                child: Row(
                  children: List.generate(11, (c) {
                    return Expanded(
                      child: _buildInnerCell(r, c, isConquered, plotLvl, state),
                    );
                  }),
                ),
              );
            }),
          ),
          for (final entry in stacks.entries)
            for (var i = 0; i < entry.value.length; i++)
              Positioned(
                left: int.parse(entry.key.split(',')[1]) * cell + i * 2.0,
                top: int.parse(entry.key.split(',')[0]) * cell + i * 2.0,
                width: cell - 2 - i * 2.0,
                height: cell - 2 - i * 2.0,
                child: IgnorePointer(
                  child: _buildUnitToken(entry.value[i]),
                ),
              ),
        ],
      ),
    );
  }

  bool _isAnimating(UnitSnapshot u) {
    final actor = _actor;
    final key = _actorClip;
    return actor != null &&
        key != null &&
        actor.id == u.id &&
        !u.pawnId.startsWith('hero_') &&
        _clipController != null &&
        NtaAssets.unitClip(u.pawnId, key) != null;
  }

  Widget _buildUnitToken(UnitSnapshot u) {
    final staticSprite = NtaAssets.unitSprite(u.pawnId);
    if (!_isAnimating(u)) {
      return _tokenShell(u, !u.pawnId.startsWith('hero_'), staticSprite);
    }
    return AnimatedBuilder(
      animation: _clipController!,
      builder: (_, _) => _tokenShell(u, true, _animFrameFor(u) ?? staticSprite),
    );
  }

  Widget _tokenShell(UnitSnapshot u, bool hasSprite, String sprite) {
    final color = u.isAttacker ? NtaColors.accent : NtaColors.danger;
    final hpFrac = u.maxHp <= 0 ? 0.0 : (u.hp / u.maxHp).clamp(0.0, 1.0);
    final label = '${u.aliveCount}';
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: NtaColors.textOnDark, width: 0.5),
      ),
      child: Stack(
        children: [
          if (hasSprite)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Image.asset(
                  sprite,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          Positioned(
            left: 1,
            bottom: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 7,
                height: 1.0,
                fontWeight: FontWeight.w700,
                color: NtaColors.textOnDark,
                shadows: [Shadow(color: Colors.black87, blurRadius: 2)],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 2,
              color: NtaColors.disabled,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: hpFrac,
                child: Container(color: hpFrac > 0.35 ? NtaColors.success : NtaColors.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerCell(int r, int c, bool isConquered, int plotLvl, GameState state) {
    final bool isCenter = (r == 5 && c == 5);
    final bool isNorthGate = (r == 0 && c == 5);
    final bool isSouthGate = (r == 10 && c == 5);
    final bool isWestGate = (r == 5 && c == 0);
    final bool isEastGate = (r == 5 && c == 10);
    final bool isRoad = (r == 5 || c == 5);

    final groundB = isConquered ? state.getGroundBuilding(_row, _col) : null;
    final bool isGroundBuildingCell = (r == 3 && c == 3 && groundB != null);

    if (isGroundBuildingCell) {
      final bType = groundB['type'] as String? ?? 'farm';
      final bRes = (bType == 'sawmill') ? 'wood' : (bType == 'quarry') ? 'stone' : 'crop';
      final bLvl = groundB['level'] as int? ?? 1;
      final sprite = bType == 'sawmill'
          ? 'assets/images/capital/city_2202.png'
          : bType == 'quarry'
              ? 'assets/images/capital/city_2203.png'
              : 'assets/images/capital/city_2201.png';

      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: NtaColors.accentSoft,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: NtaColors.success, width: NtaBorder.card),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(1),
              child: Image.asset(sprite, fit: BoxFit.contain, filterQuality: FilterQuality.none),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                color: NtaColors.success,
                child: Text(
                  '$bLvl',
                  style: const TextStyle(
                    fontSize: 7,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: NtaColors.textOnDark,
                  ),
                ),
              ),
            ),
            Positioned(left: 0, top: 0, child: NtaResIcon(bRes, size: 8)),
          ],
        ),
      );
    }

    if (isCenter) {
      final centerRes = state.getPlotData(_row, _col)?['resource'] as String? ?? 'crop';
      final plotSprite = isConquered ? null : NtaAssets.plotIcon(centerRes, plotLvl);
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isConquered ? NtaColors.accent : NtaColors.danger,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isConquered ? NtaColors.accentBorder : NtaColors.border,
            width: NtaBorder.card,
          ),
        ),
        child: Center(
          child: plotSprite != null
              ? Padding(
                  padding: const EdgeInsets.all(1),
                  child: Image.asset(plotSprite, fit: BoxFit.contain, filterQuality: FilterQuality.none),
                )
              : Icon(
                  isConquered ? Icons.tour : Icons.pest_control_rodent,
                  size: 16,
                  color: isConquered ? NtaColors.onAccent : NtaColors.textOnDark,
                ),
        ),
      );
    }

    if (isNorthGate || isSouthGate || isWestGate || isEastGate) {
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: NtaColors.borderInput,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: NtaColors.accentBorder, width: NtaBorder.hairline),
        ),
        child: const Center(
          child: Icon(Icons.meeting_room, size: 12, color: NtaColors.textOnDark),
        ),
      );
    }

    if (isRoad) {
      return Container(
        margin: const EdgeInsets.all(0.5),
        color: NtaColors.mapRoad,
      );
    }

    return Container(
      margin: const EdgeInsets.all(0.5),
      color: ((r + c) % 2 == 0) ? NtaColors.mapGreenA : NtaColors.mapGreenB,
    );
  }

  static String _productionLabel(int plotLvl, String resType) {
    // land.json (data in-game): lv1 = 1/jam semua resource, lv2-5 = 4/7/10/14.
    const yields = {1: 1, 2: 4, 3: 7, 4: 10, 5: 14};
    final perHour = yields[plotLvl] ?? 1;
    if (plotLvl <= 1) return 'Wasteland (+$perHour/h all)';
    return '${resType.toUpperCase()} (+$perHour/h)';
  }

  Widget _infoBadge(String label, String value, {String? sprite}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NtaText.xs.copyWith(color: NtaColors.textMuted)),
        Row(
          children: [
            if (sprite != null) ...[
              Image.asset(sprite, width: 20, height: 20, filterQuality: FilterQuality.none),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                value,
                style: NtaText.bodyBold,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBattleSummary(Map<String, dynamic> res) {
    final bool victory = res['victory'] == true;
    final int rounds = res['rounds'] as int? ?? 0;
    final events = _events;
    final atEnd = events.isEmpty || _replayIndex >= events.length - 1;

    return Container(
      padding: const EdgeInsets.all(NtaSpace.x5),
      decoration: BoxDecoration(
        color: victory ? NtaColors.success.withValues(alpha: 0.10) : NtaColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(color: victory ? NtaColors.success : NtaColors.danger, width: NtaBorder.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                victory ? Icons.military_tech : Icons.dangerous,
                color: victory ? NtaColors.success : NtaColors.danger,
              ),
              const SizedBox(width: NtaSpace.itemGap),
              Expanded(
                child: Text(
                  victory ? 'Battle Won!' : 'Defeat in Battle!',
                  style: NtaText.title.copyWith(color: victory ? NtaColors.success : NtaColors.danger),
                ),
              ),
              IconButton(
                icon: Icon(
                  _replayTimer != null ? Icons.pause_circle : Icons.play_circle,
                  color: NtaColors.accent,
                ),
                tooltip: 'Replay',
                onPressed: events.isEmpty ? null : _toggleReplay,
              ),
            ],
          ),
          Text(
            'Target: ${res['enemyName']} (Level ${res['plotLevel']}) — '
            '$rounds rounds, ${events.length} actions.',
            style: NtaText.caption,
          ),
          const SizedBox(height: NtaSpace.x3),
          if (events.isNotEmpty) ...[
            Text(
              'Turn ${events[_replayIndex.clamp(0, events.length - 1)].round}: '
              '${_describeEvent(events[_replayIndex.clamp(0, events.length - 1)])}',
              style: NtaText.xs.copyWith(color: NtaColors.textMuted),
            ),
            const SizedBox(height: NtaSpace.x2),
            Row(
              children: [
                Text('Action ${_replayIndex + 1}/${events.length}',
                    style: NtaText.xs.copyWith(color: NtaColors.textMuted)),
                Expanded(
                  child: Slider(
                    value: _replayIndex.toDouble(),
                    min: 0,
                    max: (events.length - 1).toDouble().clamp(0, double.infinity),
                    divisions: (events.length - 1).clamp(1, 1000),
                    onChanged: (v) {
                      _replayTimer?.cancel();
                      _replayTimer = null;
                      setState(() => _replayIndex = v.round());
                      _startClip();
                    },
                  ),
                ),
              ],
            ),
          ],
          if (atEnd)
            Text(
              'Losses: ${_lossText(res['attackerLosses'] as Map<String, int>?)}'
              '${(res['wounded'] as int? ?? 0) > 0 ? ' · ${res['wounded']} wounded' : ''}',
              style: NtaText.xs.copyWith(color: NtaColors.textMuted),
            ),
        ],
      ),
    );
  }

  static String _describeEvent(BattleEvent e) {
    switch (e.action) {
      case 'move':
        return '${e.actor} moves ${e.detail}';
      case 'skill':
        return '${e.actor} uses skill on ${e.target} — ${e.damage} DMG';
      case 'die':
        return '${e.actor} is defeated';
      default:
        return '${e.actor} hits ${e.target} — ${e.damage} DMG';
    }
  }

  static String _lossText(Map<String, int>? losses) {
    if (losses == null || losses.isEmpty) return 'none';
    return losses.entries.map((e) {
      final base = e.key.split('_').first;
      final def = GameData.SOLDIER_COMBAT.firstWhere(
        (u) => u['id'] == base,
        orElse: () => const {},
      );
      final name = def['name'] as String? ?? base;
      return '${e.value}x $name';
    }).join(', ');
  }

  void _toggleReplay() {
    if (_replayTimer != null) {
      _replayTimer!.cancel();
      setState(() => _replayTimer = null);
      return;
    }
    final events = _events;
    if (events.isEmpty) return;
    if (_replayIndex >= events.length - 1) _replayIndex = -1;
    setState(() {
      _replayTimer = Timer.periodic(const Duration(milliseconds: 520), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (_replayIndex >= events.length - 1) {
          t.cancel();
          setState(() => _replayTimer = null);
          return;
        }
        setState(() => _replayIndex++);
        _startClip();
      });
    });
  }

  void _executeAssault(BuildContext context) {
    setState(() => _isBattling = true);

    final state = context.read<GameState>();
    final result = state.attackPlot(_row, _col);

    _replayTimer?.cancel();
    _replayTimer = null;
    setState(() {
      _isBattling = false;
      _battleResult = result;
      final events = (result['events'] as List<BattleEvent>?) ?? const [];
      _replayIndex = events.isEmpty ? -1 : events.length - 1;
    });
    _startClip();
  }
}
