import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/battle_engine.dart';
import '../models/game_state.dart';
import '../../data/game_data.dart';
import '../ui/asset_manager.dart';
import '../ui/design_tokens.dart';

class CapitalInteriorView extends StatefulWidget {
  const CapitalInteriorView({super.key});

  @override
  State<CapitalInteriorView> createState() => _CapitalInteriorViewState();
}

class _CapitalInteriorViewState extends State<CapitalInteriorView> {
  String _marketFromRes = 'crop';
  String _marketToRes = 'wood';
  int _marketAmount = 100;

  // Union join candidates are cached so the list is stable across rebuilds;
  // "Re-roll" redraws them (free, unlimited).
  List<Map<String, dynamic>> _unionChoices = [];

  // NEW 17x17 Grid Constants
    static const int gridSize = 17;
    static const int cellSize = 24; // 408px total
    static const int courtStart = 5;
    static const int courtEnd = 11; // inclusive (7x7 court)
    static const int gatePos = 8; // center position

    // Find which capital facility occupies cell (r, c)
  Map<String, dynamic>? _getFacilityAt(int r, int c) {
    for (var b in GameData.CAPITAL_BUILDINGS) {
      final br = b['r'] as int;
      final bc = b['c'] as int;
      final bw = b['w'] as int;
      final bh = b['h'] as int;
      if (r >= br && r < br + bh && c >= bc && c < bc + bw) {
        return b;
      }
    }
    return null;
  }

    Widget _buildCell(int r, int c, Map<String, int> capitalBuildings, GameState state) {
            // 1. OUTER City Wall: outer ring (row 0, row 16, col 0, col 16) - white bordered brown
            final bool isTopWall = (r == 0 && c >= 1 && c <= 15);
            final bool isBottomWall = (r == 16 && c >= 1 && c <= 15);
            final bool isLeftWall = (c == 0 && r >= 1 && r <= 15);
            final bool isRightWall = (c == 16 && r >= 1 && r <= 15);
            final bool isOuterWall = isTopWall || isBottomWall || isLeftWall || isRightWall;

            // 2. Gates on OUTER wall (center of each side)
            final bool isNorthGate = (r == 0 && c == gatePos); // (0, 8)
            final bool isSouthGate = (r == gridSize - 1 && c == gatePos); // (16, 8)
            final bool isWestGate = (r == gatePos && c == 0); // (8, 0)
            final bool isEastGate = (r == gatePos && c == gridSize - 1); // (8, 16)
            final bool isGate = isNorthGate || isSouthGate || isWestGate || isEastGate;

            // 3. Entrance Avenues (from outer gates inward to court edge)
            // North: rows 1-4, col 8; South: rows 12-15, col 8; West: row 8, cols 1-4; East: row 8, cols 12-15
            final bool isNorthAvenue = (r >= 1 && r <= 4 && c == gatePos);
            final bool isSouthAvenue = (r >= 12 && r <= 15 && c == gatePos);
            final bool isWestAvenue = (r == gatePos && c >= 1 && c <= 4);
            final bool isEastAvenue = (r == gatePos && c >= 12 && c <= 15);
            final bool isAvenue = isNorthAvenue || isSouthAvenue || isWestAvenue || isEastAvenue;

            // 4. Central Citadel Court: rows 5..11, cols 5..11 (7x7 area)
            // CITY WALL (white line) = outer ring of court itself
            final bool inCourt = (r >= courtStart && r <= courtEnd && c >= courtStart && c <= courtEnd);

            // 5. Inner area (between outer ring and court, excluding avenues) - plain brown
            final bool isInnerArea = !inCourt && !isOuterWall && !isGate && !isAvenue;

            // 6. CITY WALL on court perimeter (white line in ref image 1)
            final bool isCityTopWall = (r == courtStart && c >= courtStart && c <= courtEnd);
            final bool isCityBottomWall = (r == courtEnd && c >= courtStart && c <= courtEnd);
            final bool isCityLeftWall = (c == courtStart && r >= courtStart && r <= courtEnd);
            final bool isCityRightWall = (c == courtEnd && r >= courtStart && r <= courtEnd);
            final bool isCityWall = isCityTopWall || isCityBottomWall || isCityLeftWall || isCityRightWall;

            // City wall gates / hitbox (green dots in ref): center of each wall side
            final bool isCityNorthGate = (r == courtStart && c == gatePos);
            final bool isCitySouthGate = (r == courtEnd && c == gatePos);
            final bool isCityWestGate = (r == gatePos && c == courtStart);
            final bool isCityEastGate = (r == gatePos && c == courtEnd);
            final bool isCityGate = isCityNorthGate || isCitySouthGate || isCityWestGate || isCityEastGate;

            // Inner cross roads inside court (rows 6..10, cols 6..10), full cross incl. center
            final bool isInnerNorthAvenue = (r >= courtStart + 1 && r <= gatePos - 1 && c == gatePos);
            final bool isInnerSouthAvenue = (r >= gatePos + 1 && r <= courtEnd - 1 && c == gatePos);
            final bool isInnerWestAvenue = (r == gatePos && c >= courtStart + 1 && c <= gatePos - 1);
            final bool isInnerEastAvenue = (r == gatePos && c >= gatePos + 1 && c <= courtEnd - 1);
            final bool isInnerCenter = (r == gatePos && c == gatePos);
            final bool isInnerAvenue = isInnerNorthAvenue || isInnerSouthAvenue || isInnerWestAvenue || isInnerEastAvenue || isInnerCenter;

                                    // 7. Facility occupation
                        final facility = _getFacilityAt(r, c);

                        if (isGate) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: NtaColors.success, // Dark green for gates (per reference image 2)
                                          border: Border.all(color: NtaColors.text, width: 1.5),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.door_front_door, size: 11, color: NtaColors.textOnDark),
                                      );
                                    }

                                    if (isOuterWall) {
                                      // Outer ring: plain brown ground (outer white tiles removed per user)
                                      // Outer gates (isGate) handled above and kept
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF8B4513),
                                        ),
                                        alignment: Alignment.center,
                                        child: null,
                                      );
                                    }

                                    if (isCityGate) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: NtaColors.success, // Dark green for city gates
                                          border: Border.all(color: NtaColors.text, width: 1.5),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.door_front_door, size: 11, color: NtaColors.textOnDark),
                                      );
                                    }

                                    if (isCityWall) {
                                      // City wall: white-bordered brown (white line in ref image 1)
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF9C8B6E),
                                          border: Border.all(color: NtaColors.text, width: 1.5),
                                        ),
                                        alignment: Alignment.center,
                                        child: null,
                                      );
                                    }

                                    if (isInnerArea) {
                                      // Inner area between wall and court - medium brown (same as wall but no border)
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB9A783),
                                        ),
                                        alignment: Alignment.center,
                                        child: null,
                                      );
                                    }

                                    if (facility != null) {
      final id = facility['id'] as String;
      final br = facility['r'] as int;
      final bc = facility['c'] as int;
      final bw = facility['w'] as int;
      final bh = facility['h'] as int;

      // Check if facility is built
      final int buildLevel = capitalBuildings[id] ?? 0;
      if (buildLevel > 0) {
        // Center cell renders the facility marker.
        // Use Material Icons (same _facilityIcon map as the dialogs), not the
        // GameData emoji string: several emoji glyphs (crown, crossed swords,
        // etc.) are missing from the device font and render as "??"/"???".
        final bool isCenterCell = (r == br + (bh ~/ 2) && c == bc + (bw ~/ 2));

        Color baseColor;
        switch (id) {
          case 'palace':
            baseColor = const Color(0xFFF3D98C);
            break;
          case 'barracks':
            baseColor = const Color(0xFFE3A79B);
            break;
          case 'smithy':
            baseColor = const Color(0xFFE0B98F);
            break;
          case 'hall_of_heroes':
            baseColor = const Color(0xFFC9B3E0);
            break;
          case 'drill_ground':
            baseColor = const Color(0xFFC7D39A);
            break;
          case 'clinic':
            baseColor = const Color(0xFF9ECFBB);
            break;
          case 'market':
            baseColor = const Color(0xFF9FCBD6);
            break;
          case 'union_market':
            baseColor = const Color(0xFF8FBFC9);
            break;
          case 'embassy':
            baseColor = const Color(0xFFD6C3A0);
            break;
          case 'barn':
            baseColor = const Color(0xFFE7D3A0);
            break;
          case 'warehouse':
            baseColor = const Color(0xFFA9B7D2);
            break;
          default:
            baseColor = const Color(0xFFC4C6CE);
        }

        final spritePath = NtaAssets.facilitySprite(id);

        return GestureDetector(
          onTap: () => _onTileTapped(context, state, r, c, capitalBuildings),
          child: Container(
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.7),
              border: Border(
                right: BorderSide(color: NtaColors.borderSoft, width: 0.2),
                bottom: BorderSide(color: NtaColors.borderSoft, width: 0.2),
              ),
            ),
            alignment: Alignment.center,
            child: isCenterCell
                ? (spritePath != null
                    ? Padding(
                        padding: const EdgeInsets.all(1),
                        child: Image.asset(
                          spritePath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                        ),
                      )
                    : Icon(
                        _facilityIcon(id),
                        size: 14,
                        color: NtaColors.text,
                      ))
                : null,
          ),
        );
      }
      // Facility slot exists but not built yet - show as empty court tile
    }

    // Paved Stone Road / Court Walkway
        if (isAvenue) {
          return Container(
            decoration: BoxDecoration(
              color: NtaColors.mapRoad,
              border: Border.all(color: const Color(0xFF9C8B6E), width: 0.5),
            ),
            alignment: Alignment.center,
            child: null,
          );
        }

            if (isInnerAvenue) {
              return Container(
                decoration: BoxDecoration(
                  color: NtaColors.mapRoad,
                  border: Border.all(color: const Color(0xFFC9BB9C), width: 0.5),
                ),
                alignment: Alignment.center,
                child: null,
              );
            }

            return Container(
          decoration: BoxDecoration(
            color: inCourt ? const Color(0xFFCFC2A4) : const Color(0xFFB9A783),
            border: Border(
              right: BorderSide(color: const Color(0xFFB6A98C), width: 0.2),
              bottom: BorderSide(color: const Color(0xFFB6A98C), width: 0.2),
            ),
          ),
          alignment: Alignment.center,
          child: null,
        );
  }

  Widget _buildFacilityPopupContent(GameState state, String id, int level) {
      return _buildFacilityContent(state, id, level);
    }

  Widget _resStat(String resource, int perHour) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NtaResIcon(resource, size: 12),
        const SizedBox(width: 3),
        Text('+$perHour/h', style: NtaText.xs),
      ],
    );
  }

  Widget _infoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NtaColors.surfaceSunk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: NtaColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // --- FACILITY POPUP CONTENT ---
  // All bodies use bounded scroll (fixed dialog size) to avoid unbounded ListView in AlertDialog.
  Widget _buildFacilityContent(GameState state, String id, int level) {
    switch (id) {
      case 'palace':
        return _buildPalaceView(state, level);
      case 'barracks':
        return _buildBarracksView(state);
      case 'smithy':
        return _buildSmithyView(state);
      case 'hall_of_heroes':
        return _buildHeroesView(state);
      case 'drill_ground':
        return _buildDrillGroundView(state);
      case 'clinic':
        return _buildClinicView(state);
      case 'market':
        return _buildMarketView(state);
      case 'union_market':
        return _buildMarketView(state, union: true);
      case 'embassy':
        return _buildEmbassyView(state, level);
      case 'barn':
        return _buildBarnView(state, level);
      case 'warehouse':
        return _buildWarehouseView(state, level);
      default:
        return const Center(child: Text('Citadel Facility Operating Normally'));
    }
  }

  Widget _facilityScroll(Widget child) {
    return SingleChildScrollView(child: child);
  }

  // Current -> next line + expandable full Lv.1-20 table from levelStats().
  Widget _levelRow(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NtaColors.surfaceSunk,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: NtaColors.accentBorder)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 11, color: NtaColors.textMuted)),
        ],
      ),
    );
  }

  Widget _levelTable(String id, List<String> keys) {
    return ExpansionTile(
      dense: true,
      tilePadding: EdgeInsets.zero,
      title: const Text('Full Lv.1–20 table', style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NtaColors.mapGreenB,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            [
              for (int l = 1; l <= 20; l++)
                'Lv.$l: ${keys.map((k) => '$k=${GameData.levelStats(id, l)[k]}').join(' · ')}',
            ].join('\n'),
            style: const TextStyle(fontSize: 10, color: NtaColors.textMuted, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  // 1. PALACE: Seat of Power, Realm Command, Tribute & Tax
  Widget _buildPalaceView(GameState state, int level) {
    final stats = GameData.levelStats('palace', level);
    final next = GameData.levelStats('palace', (level + 1).clamp(1, 20));
    final rates = state.getHourlyProduction();

    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Throne of the Capital - Realm Administration',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NtaColors.text),
        ),
        const SizedBox(height: 6),
        const Text(
          'The Imperial Palace is the single core seat of your empire. It commands maximum army teams, collects realm taxes, and anchors your sovereignty.',
          style: TextStyle(fontSize: 12, color: NtaColors.textMuted),
        ),
        const SizedBox(height: 12),

        // Status grid
        Row(
          children: [
            Expanded(
              child: _infoCard('Army Cap', '${state.armyCap} Teams', Icons.groups, NtaColors.heroNamePill),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Territory', '${stats['territory']} Plots', Icons.flag, NtaColors.success),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Army Capacity', '${stats['armyCapacity']}', Icons.shield, NtaColors.accentBottom),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPolicyPanel(state, level),
        const SizedBox(height: 12),
        _levelRow('Lv.$level -> Lv.${(level + 1).clamp(1, 20)}',
            'Army Cap ${state.armyCap} -> ${next['armyCap']} · Territory ${stats['territory']} -> ${next['territory']} · ${next['note']}'),
        const SizedBox(height: 8),
        _levelTable('palace', ['armyCap', 'territory']),
        const SizedBox(height: 14),

        // Base Realm Tax Breakdown
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: NtaColors.surfaceSunk,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Realm Output per Hour:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: NtaColors.accentBorder)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _resStat('crop', rates["crop"]!.toInt()),
                  _resStat('wood', rates["wood"]!.toInt()),
                  _resStat('stone', rates["stone"]!.toInt()),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final r in ['iron', 'exp_scroll', 'scroll', 'nail'])
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: NtaResIcon(r, size: 12, color: NtaColors.textMuted),
                        ),
                      const SizedBox(width: 3),
                      Text('chest-only', style: NtaText.xs.copyWith(color: NtaColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Collect Imperial Tribute button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => state.collectPalaceTribute(),
            icon: const Icon(Icons.monetization_on, color: NtaColors.onAccent),
            label: Text('Collect Imperial Realm Tribute (Lv. $level)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NtaColors.accent,
              foregroundColor: NtaColors.onAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    ));
  }

  // --- POLICY SLOTS (policy.json + ceri.json) ---
  Widget _buildPolicyPanel(GameState state, int level) {
    final slots = state.policySlots;
    final nextSlotLv = GameData.POLICY_SLOT_LEVELS
        .firstWhere((l) => l > level, orElse: () => 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Policy Slots',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NtaColors.text)),
            Text('$slots slot${slots == 1 ? '' : 's'} · Capital Lv.$level',
                style: const TextStyle(fontSize: 11, color: NtaColors.textMuted)),
          ],
        ),
        if (nextSlotLv > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('Next slot unlocks at Capital Lv.$nextSlotLv',
                style: const TextStyle(fontSize: 11, color: NtaColors.accentBorder)),
          ),
        const SizedBox(height: 8),
        for (int i = 0; i < GameData.POLICY_SLOT_LEVELS.length; i++)
          _policySlotRow(state, i, unlocked: i < slots),
        const SizedBox(height: 10),
        _buildResearchList(state),
      ],
    );
  }

  Widget _policySlotRow(GameState state, int slot, {required bool unlocked}) {
    final entry = state.activePolicies[slot];
    final policy = entry == null ? null : GameData.policyById(entry['policyId'] ?? 0);
    final tier = entry?['tier'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NtaColors.surfaceSunk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: unlocked ? NtaColors.borderSoft : NtaColors.disabled),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text('${slot + 1}',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: unlocked ? NtaColors.accentBorder : NtaColors.disabled)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  policy == null
                      ? (unlocked ? 'Empty slot' : 'Locked (Capital Lv.${GameData.POLICY_SLOT_LEVELS[slot]})')
                      : '${policy['name']} · Tier ${tier + 1}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: policy == null ? NtaColors.textMuted : NtaColors.text),
                ),
                if (policy != null)
                  Text(GameData.policyDesc(policy, tier),
                      style: const TextStyle(fontSize: 11, color: NtaColors.textMuted)),
              ],
            ),
          ),
          if (unlocked && policy == null)
            TextButton(
              onPressed: state.canEnactInto(slot)
                  ? () => _showPolicyPicker(state, slot)
                  : null,
              style: TextButton.styleFrom(
                  foregroundColor: NtaColors.accentBorder),
              child: const Text('Enact',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          if (policy != null)
            TextButton(
              onPressed: () {
                setState(() => state.resetPolicySlot(slot));
              },
              child: const Text('Reset',
                  style: TextStyle(fontSize: 11, color: NtaColors.danger)),
            ),
        ],
      ),
    );
  }

  void _showPolicyPicker(GameState state, int slot) {
    var choices = state.drawPolicyChoices();
    var tiers = List<int>.filled(choices.length, 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          return AlertDialog(
            backgroundColor: NtaColors.surface,
            title: const Text('Pilih Kebijakan'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < choices.length; i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: NtaColors.surfaceSunk,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: NtaColors.borderSoft),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(choices[i]['name'] as String,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(GameData.policyDesc(choices[i], tiers[i]),
                                style: const TextStyle(
                                    fontSize: 11, color: NtaColors.textMuted)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: [
                                for (int t = 0; t < 3; t++)
                                  ChoiceChip(
                                    label: Text('Tier ${t + 1}'),
                                    selected: tiers[i] == t,
                                    onSelected: (_) =>
                                        setDialog(() => tiers[i] = t),
                                    labelStyle: const TextStyle(fontSize: 10),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  state.enactPolicy(
                                      slot, choices[i]['id'] as int, tiers[i]);
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: NtaColors.accent,
                                  foregroundColor: NtaColors.onAccent,
                                ),
                                child: const Text('Terbitkan',
                                    style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (choices.isEmpty)
                      const Text('No eligible policies right now.',
                          style: TextStyle(fontSize: 12, color: NtaColors.textMuted)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => setDialog(
                    () => choices = state.drawPolicyChoices()),
                child: const Text('Acak Ulang'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResearchList(GameState state) {
    final palaceLvl = state.capitalBuildings['palace'] ?? 1;
    final researched = state.researchedPolicies;
    final rows = GameData.POLICY_RESEARCH.entries.toList()
      ..sort((a, b) => (a.value['needLv'] as int)
          .compareTo(b.value['needLv'] as int));

    return ExpansionTile(
      dense: true,
      tilePadding: EdgeInsets.zero,
      title: Text(
        'Research Institute · ${researched.length}/${rows.length} unlocked',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NtaColors.accentBorder),
      ),
      children: [
        for (final e in rows)
          Builder(builder: (ctx) {
            final id = e.key;
            final row = e.value;
            final policy = GameData.policyById(id);
            final needLv = row['needLv'] as int;
            final done = researched.contains(id);
            final gated = palaceLvl < needLv;
            final cost = (row['cost'] as Map).entries
                .map((c) => '${c.value} ${c.key}')
                .join(', ');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(policy?['name'] as String? ?? 'Policy $id',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: done
                                    ? NtaColors.success
                                    : gated
                                        ? NtaColors.textMuted
                                        : NtaColors.text)),
                        Text('Capital Lv.$needLv · $cost · ${row['time']}s',
                            style: const TextStyle(
                                fontSize: 10, color: NtaColors.textMuted)),
                      ],
                    ),
                  ),
                  if (done)
                    const Icon(Icons.check_circle,
                        size: 18, color: NtaColors.success)
                  else
                    TextButton(
                      onPressed: gated ? null : () => setState(() => state.researchPolicy(id)),
                      child: const Text('Riset', style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // 2. BARRACKS: Soldier Training & Strict Advantage Wheel
  // One entry per unit in SoldierAttribute.md, grouped by category tab.
  Widget _buildBarracksView(GameState state) {
    final lvl = state.capitalBuildings['barracks'] ?? 1;
    final stats = GameData.levelStats('barracks', lvl);
    final next = GameData.levelStats('barracks', (lvl + 1).clamp(1, 20));
    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Barracks - Train Standing Army (26 Units)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NtaColors.danger),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: NtaColors.danger.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Lv.$lvl', style: const TextStyle(fontSize: 10, color: NtaColors.danger)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: NtaColors.danger.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('Counter: Spear > Cav > Shield > Bow > Spear (40% ATK, ignore 20% DEF)', style: TextStyle(fontSize: 10, color: NtaColors.danger)),
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$lvl -> Lv.${(lvl + 1).clamp(1, 20)}',
            'Recruit SPD -${stats['recruitSpd']}% -> -${next['recruitSpd']}% · Soldier Cap Lv.${stats['soldierCap']} -> Lv.${next['soldierCap']} · ${next['note']}'),
        _levelTable('barracks', ['recruitSpd', 'soldierCap']),
        const SizedBox(height: 8),
        _buildTroopCategorySection(state, 'spear', '🔱 Spearman'),
        _buildTroopCategorySection(state, 'shield', '🛡️ Shieldman'),
        _buildTroopCategorySection(state, 'bow', '🏹 Bowman'),
        _buildTroopCategorySection(state, 'cavalry', '🐎 Cavalry'),
        _buildTroopCategorySection(state, 'weaponry', '🏗️ Weaponry (vs Buildings)'),
      ],
    ));
  }

  /// Potret pasukan asli 64x64 dari bundle `role/<pawnId>`.
  Widget _troopIcon(String troopId) {
    final pawnId = BattleEngine.troopCombatIds[troopId];
    if (pawnId == null) {
      return const Icon(Icons.shield, color: NtaColors.danger, size: 20);
    }
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Image.asset(
        NtaAssets.unitSprite(pawnId),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.shield, color: NtaColors.danger, size: 20),
      ),
    );
  }

  Widget _buildTroopCategorySection(GameState state, String category, String title) {    final units = GameData.TROOPS.where((t) => t['category'] == category).toList();
    if (units.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(
            '$title (${units.length})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NtaColors.accentBorder),
          ),
        ),
        Column(
          children: [
            for (var troop in units)
              Builder(builder: (context) {
              final id = troop['id'] as String;
              final count = state.troops[id] ?? 0;
              final tLvl = state.troopLevel(id);
              final tStats = state.troopStats(id);
              final costMap = GameData.recruitCost(id);
              final base = GameData.PAWN_BASE[BattleEngine.troopCombatIds[id]];

              return Card(
                color: NtaColors.surfaceSunk,
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  dense: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  leading: CircleAvatar(
                    backgroundColor: NtaColors.danger.withValues(alpha: 0.2),
                    child: _troopIcon(id),
                  ),
                  title: Text('${troop["name"]} (x$count · Lv.$tLvl)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    'Lv.$tLvl HP ${tStats['hp']} | ATK ${tStats['atk']} (Lv.6: ${troop['hp6']}·${troop['atk6']}) | DEF ${troop["def"]} | Rage ${troop["rage"]} | R${troop["range"]}/M${troop["move"]}\nCost: ${costMap.entries.map((e) => "${e.value} ${e.key}").join(", ")}',
                    style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _recruitTroopPrompt(state, troop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NtaColors.danger,
                      foregroundColor: NtaColors.textOnDark,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(64, 32),
                    ),
                    child: const Text('Train', style: TextStyle(fontSize: 12)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: NtaColors.mapGreenB,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Counters: ${troop["counter"]} (+40% ATK). ATK SPD ${base?['attackSpeed'] ?? '-'} · '
                              'Upkeep ${base?['cerealCost'] ?? troop["upkeep"]} crop · '
                              'March ${base?['marchSpeed'] ?? troop["march"]} · '
                              'Bag ${base?['bagCap'] ?? '-'} · Unlock Barrack Lv.${(base?['unlockAt'] as List?)?.join("/") ?? '-'}',
                              style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Skill: ${troop["skill"]}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NtaColors.accentBorder),
                            ),
                            Text(
                              '${troop["skillDesc"]}',
                              style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  void _recruitTroopPrompt(GameState state, Map<String, dynamic> troop) {
    int quantity = 10;
    final base = GameData.PAWN_BASE[BattleEngine.troopCombatIds[troop['id']]];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setPromptState) {
          final costMap = GameData.recruitCost(troop['id'] as String);
          final totalCost = <String, int>{};
          for (var entry in costMap.entries) {
            totalCost[entry.key] = entry.value * quantity;
          }
          // Cost Coefficient: recruit/upg/heal ratio from SoldierAttribute.md.
          final coef = ((troop['coef'] as int?) ?? 50) / 100.0;
          final coefNote = 'Cost coef ${(coef * 100).round()}% already in base cost.';
          final canAfford = state.hasResources(totalCost);

          return AlertDialog(
            backgroundColor: NtaColors.surface,
            title: Text('Train ${troop["name"]}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lv.${state.troopLevel(troop['id'] as String)} HP ${state.troopStats(troop['id'] as String)['hp']} | ATK ${state.troopStats(troop['id'] as String)['atk']} | DEF ${troop["def"]} | Rage ${troop["rage"]} (coef ${(troop['coef'] as int?) ?? 50}%)',
                  style: const TextStyle(fontSize: 12, color: NtaColors.textMuted),
                ),
                Text(
                  'Range ${troop["range"]} · Move ${troop["move"]} · ATK SPD ${base?['attackSpeed'] ?? '-'} · '
                  'Upkeep ${base?['cerealCost'] ?? troop["upkeep"]} crop · March ${base?['marchSpeed'] ?? troop["march"]}',
                  style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  'Skill: ${troop["skill"]} — ${troop["skillDesc"]}',
                  style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: NtaColors.danger),
                      onPressed: quantity > 1 ? () => setPromptState(() => quantity -= 1) : null,
                    ),
                    Text('$quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: NtaColors.success),
                      onPressed: () => setPromptState(() => quantity += 1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Cost: ${totalCost.entries.map((e) => "${e.value} ${e.key}").join(", ")}\n$coefNote',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canAfford ? NtaColors.success : NtaColors.danger,
                  ),
                ),
                Text(
                  'Recruit time ${(GameData.recruitTime(troop['id'] as String) * state.recruitTimeMult).round()}s'
                  ' (policy -${((1 - state.recruitTimeMult) * 100).round()}%)',
                  style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: canAfford
                    ? () {
                        state.trainTroops(troop['id'] as String, quantity);
                        Navigator.pop(ctx);
                      }
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: NtaColors.success, foregroundColor: NtaColors.textOnDark),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 3. SMITHY: Forging Equipment (common tiers + exclusive + smelt)
  Widget _buildSmithyView(GameState state) {
    final smithyLvl = state.capitalBuildings['smithy'] ?? 0;
    const tiers = [1, 3, 5, 7, 10, 12, 14];
    final unlocked = tiers.where((t) => smithyLvl >= t).toList();
    final nextTier = tiers.firstWhere((t) => smithyLvl < t, orElse: () => -1);

    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Smithy - Forge Battlefield Gear',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NtaColors.accentBorder),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: NtaColors.accentSoft,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Lv.$smithyLvl', style: const TextStyle(fontSize: 10, color: NtaColors.accentBorder)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          unlocked.isEmpty
              ? 'No tiers unlocked yet — upgrade Smithy to Lv.1.'
              : 'Unlocked: Lv.${unlocked.join(" · Lv.")}${nextTier == -1 ? " (MAX)" : " — next Lv.$nextTier"}',
          style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
        ),
        const SizedBox(height: 6),
        _levelRow('Lv.$smithyLvl -> Lv.${(smithyLvl + 1).clamp(1, 20)}',
            'Craft SPD -${GameData.levelStats('smithy', smithyLvl.clamp(1, 20))['craftSpd']}% -> -${GameData.levelStats('smithy', (smithyLvl + 1).clamp(1, 20))['craftSpd']}% · Exclusive + Smelt ${smithyLvl >= 10 ? "UNLOCKED" : "at Lv.10"}'),
        _levelTable('smithy', ['craftSpd']),
        const SizedBox(height: 8),
        for (final tier in tiers.where((t) => t != 10))
          _buildSmithyTierSection(state, tier, smithyLvl),
        _buildExclusiveSection(state, smithyLvl),
      ],
    ));
  }

  Widget _buildSmithyTierSection(GameState state, int tier, int smithyLvl) {
    final items = GameData.EQUIP_MASTER.where((e) => GameData.equipmentSmithyLevel(e) == tier).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final locked = smithyLvl < tier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: [
              Text(
                'Common — Smithy Lv.$tier (${items.length})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NtaColors.accentBorder),
              ),
              if (locked)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text('🔒 locked', style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
                ),
            ],
          ),
        ),
        Column(
          children: [
            for (var eq in items)
              Builder(builder: (context) {
              final id = '${eq['id']}';
              final owned = state.equipment[id] ?? 0;
              final cost = (eq['cost'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int));
              final canAfford = !locked && state.hasResources(cost);
              final recastable = state.recastCounts.containsKey(id) ||
                  GameData.equipById(id)?['recastMax'] != 0;

              return Card(
                color: NtaColors.surfaceSunk,
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  dense: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  leading: const Icon(Icons.shield, color: NtaColors.accentBorder, size: 26),
                  title: Text('${eq['nameIdl']} (x$owned)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    'Cost: ${cost.entries.map((e) => "${e.value} ${e.key}").join(", ")}',
                    style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                  ),
                  trailing: SizedBox(
                    width: 76,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: canAfford ? () => state.craftEquipment(id) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NtaColors.accent,
                            foregroundColor: NtaColors.onAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(72, 30),
                          ),
                          child: const Text('Forge', style: TextStyle(fontSize: 12)),
                        ),
                        if (smithyLvl >= 10 && owned > 0)
                          TextButton(
                            onPressed: () => state.smeltEquipment(id),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(72, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Smelt ½', style: TextStyle(fontSize: 10, color: NtaColors.danger)),
                          ),
                      ],
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: NtaColors.mapGreenB,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${eq['hp'] != '' ? 'HP ${eq['hp']}  ' : ''}${eq['atk'] != '' ? 'ATK ${eq['atk']}' : ''}',
                              style: const TextStyle(fontSize: 11, color: NtaColors.accentBorder),
                            ),
                            const SizedBox(height: 4),
                            Text(GameData.equipEffectText(eq, idl: true),
                                style: const TextStyle(fontSize: 11, color: NtaColors.textMuted)),
                            if (recastable)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Recasts: ${state.recastCounts[id] ?? 0}/50',
                                        style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: owned > 0 ? () => state.recastEquipment(id) : null,
                                      child: const Text('Recast (20 iron + 20 stone)', style: TextStyle(fontSize: 10)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildExclusiveSection(GameState state, int smithyLvl) {
    final forged = state.exclusiveOrder;

    String costText(String id) {
      final eq = GameData.exclusiveById(id);
      if (eq == null) return '';
      final cost = eq['cost'] as Map<String, dynamic>;
      return cost.entries.map((e) => '${e.value} ${e.key}').join(', ');
    }

    Widget picker() {
      final options = GameData.EXCLUSIVE_EQUIPMENT.where(
        (e) => !state.exclusiveEquipment.containsKey('${e['id']}'),
      ).toList();
      return Column(
        children: [
          for (var eq in options)
            Builder(builder: (context) {
              final id = '${eq['id']}';
              final blocker = state.exclusiveForgeBlocker(id);
              final troop = GameData.TROOPS.firstWhere(
                (t) => t['id'] == eq['subtype'],
                orElse: () => <String, dynamic>{'name': eq['subtype']},
              );
              final ownedTroop = (state.troops[eq['subtype']] ?? 0) > 0;
              final intensify = (eq['skillIntensify'] as String).split(',');
              return Card(
                color: NtaColors.surfaceCard,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    ownedTroop ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: ownedTroop ? NtaColors.heroNamePill : NtaColors.borderInput,
                  ),
                  title: Text(
                    '${eq["nameIdl"]} — ${troop["name"]}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text(
                    'Skill +${int.tryParse(intensify.last) ?? 1} lv (family ${intensify.first})\nCost: ${costText(id)}',
                    style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: blocker == null ? () => state.craftEquipment(id) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NtaColors.heroNamePill,
                      foregroundColor: NtaColors.onAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(72, 30),
                    ),
                    child: const Text('Forge', style: TextStyle(fontSize: 12)),
                  ),
                ),
              );
            }),
        ],
      );
    }

    Widget pieceCard(String id) {
      final p = state.exclusiveEquipment[id]!;
      final smeltBlocker = state.exclusiveSmeltBlocker(id);
      final effectNames = Map<String, String>.fromEntries(
        GameData.EQUIP_MASTER.map((e) => MapEntry('${e['id']}', e['nameIdl'] as String)),
      );
      final effects = List<Map<String, dynamic>>.from((p['effects'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
      final smelt = List<Map<String, dynamic>>.from(((p['smelt'] as List?) ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
      final locked = (p['locked'] as int?) ?? -1;
      return Card(
        color: NtaColors.surfaceCard,
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          leading: const Icon(Icons.stars, color: NtaColors.heroNamePill, size: 26),
          title: Text('${p["name"]} ✅', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text('${p["subtype"]} · ${(p['effects'] as List).length} random effects',
              style: const TextStyle(fontSize: 11, color: NtaColors.heroNamePill)),
          trailing: ElevatedButton(
            onPressed: () => state.recastExclusive(id),
            style: ElevatedButton.styleFrom(
              backgroundColor: NtaColors.heroNamePill,
              foregroundColor: NtaColors.textOnDark,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(64, 30),
            ),
            child: const Text('Recast', style: TextStyle(fontSize: 12)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: NtaColors.surfaceCard, borderRadius: BorderRadius.circular(6)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skill: ${p["skillIntensify"]} (intensify)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NtaColors.accentBorder)),
                    const SizedBox(height: 4),
                    for (var i = 0; i < effects.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                                '🎲 ${GameData.equipRolledEffectText(effects[i]["id"] as int, idl: true)}${i == locked ? " 🔒" : ""}',
                                style: const TextStyle(fontSize: 11, color: NtaColors.textMuted)),
                          ),
                          TextButton(
                            onPressed: () => state.toggleExclusiveLock(id, i),
                            child: Text(i == locked ? 'Unlock' : 'Lock (1 nail)',
                                style: const TextStyle(fontSize: 10)),
                          ),
                        ],
                      ),
                    if (smelt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const Text('Smelted:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NtaColors.accentBorder)),
                      for (var s in smelt)
                        Text('🔥 ${GameData.equipRolledEffectText(s["effectId"] as int, idl: true)}',
                            style: const TextStyle(fontSize: 11, color: NtaColors.accentBorder)),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Smelt common -> here (1 nail):',
                            style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Builder(builder: (context) {
                            final commons = state.equipment.entries.toList();
                            return DropdownButton<String>(
                              value: null,
                              isExpanded: true,
                              hint: Text(
                                smeltBlocker ?? 'Pick piece',
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                              dropdownColor: NtaColors.surfaceRaised,
                              items: [
                                for (var e in commons)
                                  DropdownMenuItem(
                                    value: e.key,
                                    child: Text(
                                      '${effectNames[e.key] ?? e.key} (x${e.value})',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                              ],
                              onChanged: (smeltBlocker == null && commons.isNotEmpty)
                                  ? (commonId) {
                                      if (commonId != null) state.smeltIntoExclusive(id, commonId);
                                    }
                                  : null,
                            );
                          }),
                        ),
                      ],
                    ),
                    if (smeltBlocker != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(smeltBlocker, style: const TextStyle(fontSize: 11, color: NtaColors.danger)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final showPicker = forged.length < 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: [
              Text(
                'Exclusive — forged ${forged.length}/2',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NtaColors.heroNamePill),
              ),
              if (smithyLvl < 10)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text('🔒 Smithy Lv.10', style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
                ),
            ],
          ),
        ),
        Text(
          forged.isEmpty
              ? '1st piece: Smithy Lv.10, free pick among owned troop subtypes (wood+stone+iron). 2nd piece unlocks at Smithy Lv.18.'
              : forged.length == 1
                  ? '2nd piece unlocks at Smithy Lv.18. Smelt: 1st piece at Smithy Lv.14, 2nd at Lv.18 (1 nail each).'
                  : 'Max 2 pieces per session. Smelt: 1st piece at Smithy Lv.14, 2nd at Lv.18 (1 nail each).',
          style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
        ),
        const SizedBox(height: 6),
        for (var id in forged) pieceCard(id),
        if (showPicker) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Text(
              forged.isEmpty ? 'Choose your 1st exclusive:' : 'Choose your 2nd exclusive:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NtaColors.textMuted),
            ),
          ),
          picker(),
        ],
      ],
    );
  }

  // 4. HALL OF HEROES: Worship & Permanently Bind Generals
  Widget _buildHeroesView(GameState state) {
    final lvl = state.capitalBuildings['hall_of_heroes'] ?? 0;
    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hall of Heroes - Worship & Bind Legendary Generals',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NtaColors.heroNamePill),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: NtaColors.heroTeal.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Lv.$lvl', style: const TextStyle(fontSize: 10, color: NtaColors.heroNamePill)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Notice: Once a hero is Worshipped, they are permanently bound to your campaign command.',
          style: TextStyle(fontSize: 11, color: NtaColors.accentBottom),
        ),
        const SizedBox(height: 6),
        _levelRow('Lv.$lvl -> Lv.${(lvl + 1).clamp(1, 20)}',
            'Worship slots ${state.worshipSlots}/4 · next slot at Lv.${GameState.worshipSlotLevels.firstWhere((n) => n > lvl, orElse: () => 20)}'),
        const SizedBox(height: 8),
        Column(
          children: [
            for (final hero in GameData.HEROES)
              _heroWorshipTile(state, hero),
          ],
        ),
      ],
    ));
  }

  Widget _heroWorshipTile(GameState state, Map<String, dynamic> hero) {
    final id = hero['id'] as int;
    final repaired = state.hasPortrait(id);
    final isWorshipped = state.worshippedHeroes.contains(id);
    final grade = state.portraitGrade(id);
    final gradeLabel = GameData.PORTRAIT_GRADE_LABELS[grade];
    final skill = GameData.HERO_SKILLS[hero['skill']];

    return Card(
      color: NtaColors.surfaceSunk,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        onTap: repaired ? () => _showHeroDetail(state, hero) : null,
        leading: SizedBox(
          width: 36,
          height: 36,
          child: Image.asset(
            NtaAssets.heroPortrait(id),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
            errorBuilder: (_, _, _) => Icon(
              isWorshipped ? Icons.stars : Icons.person_add,
              color: isWorshipped ? NtaColors.accentBorder : NtaColors.heroNamePill,
              size: 28,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                GameState.heroName(id),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isWorshipped ? NtaColors.text : NtaColors.textMuted,
                ),
              ),
            ),
            if (repaired)
              Text(gradeLabel, style: const TextStyle(fontSize: 10, color: NtaColors.heroNamePill)),
          ],
        ),
        subtitle: Text(
          repaired
              ? 'HP ${hero['hp'][grade]} · ATK ${hero['atk'][grade]} · Skill: ${skill?['name'] ?? '-'}'
              : 'Fragments ${state.fragmentsOf(id)}/${GameState.portraitFragmentCost}',
          style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
        ),
        trailing: isWorshipped
            ? const Chip(
                label: Text('BOUND', style: TextStyle(fontSize: 10, color: NtaColors.text, fontWeight: FontWeight.bold)),
                backgroundColor: NtaColors.surfaceSunk,
              )
            : !repaired
                ? ElevatedButton(
                    onPressed: state.fragmentsOf(id) >= GameState.portraitFragmentCost
                        ? () => state.repairPortrait(id)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NtaColors.accentBorder,
                      foregroundColor: NtaColors.textOnDark,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Repair', style: TextStyle(fontSize: 12)),
                  )
                : ElevatedButton(
                    onPressed: () => state.worshipHero(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NtaColors.heroNamePill,
                      foregroundColor: NtaColors.textOnDark,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Worship', style: TextStyle(fontSize: 12)),
                  ),
      ),
    );
  }

  /// Portrait detail: grade ladder, redraw, expertise list (portrayal_desc_1..6).
  void _showHeroDetail(GameState state, Map<String, dynamic> hero) {
    final id = hero['id'] as int;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final grade = state.portraitGrade(id);
          final gradeLabel = GameData.PORTRAIT_GRADE_LABELS[grade];
          final expertise = state.portraitExpertise(id);
          final frags = state.fragmentsOf(id);
          final skill = GameData.HERO_SKILLS[hero['skill']];
          final nextPity = GameData.PORTRAIT_UPGRADE_PITY - state.portraitPity(id);
          return AlertDialog(
            backgroundColor: NtaColors.surface,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            title: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Image.asset(NtaAssets.heroPortrait(id),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, _, _) => const Icon(Icons.person, size: 32)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(GameState.heroName(id),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NtaColors.text)),
                      Text('$gradeLabel · redraw ${state.portraitRedraws(id)}x',
                          style: const TextStyle(fontSize: 11, color: NtaColors.heroNamePill)),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HP ${hero['hp'][grade]} · ATK ${hero['atk'][grade]}',
                      style: const TextStyle(fontSize: 12, color: NtaColors.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Skill: ${skill?['name'] ?? '-'} (${skill?['values']?[grade]}${skill?['suffix'] ?? ''})',
                      style: const TextStyle(fontSize: 12, color: NtaColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expertise ${expertise.length}/${GameData.portraitExpertiseSlots(grade)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NtaColors.accentBorder),
                    ),
                    const SizedBox(height: 4),
                    if (expertise.isEmpty)
                      const Text('No expertise unlocked — reach Grade 6/4/2 to open slots.',
                          style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
                    for (var i = 0; i < expertise.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: InkWell(
                          onTap: grade == 7
                              ? () async {
                                  await _pickChosenExpertise(state, id, i);
                                  setLocal(() {});
                                }
                              : null,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${GameData.STRATEGY_RARITY_NAMES[expertise[i]['lv'] - 1]}: ',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NtaColors.text),
                              ),
                              Expanded(
                                child: Text(
                                  GameData.strategyDesc(expertise[i]['id'] as int,
                                      idl: true, pawnId: hero['pawn']?.toString()),
                                  style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                                ),
                              ),
                              if (grade == 7)
                                const Icon(Icons.edit, size: 13, color: NtaColors.accentBorder),
                            ],
                          ),
                        ),
                      ),
                    if (grade < 7) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Grade up guaranteed in $nextPity redraw(s).',
                        style: const TextStyle(fontSize: 10, color: NtaColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: frags >= GameState.portraitFragmentCost
                    ? () {
                        state.redrawPortrait(id);
                        setLocal(() {});
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NtaColors.accent,
                  foregroundColor: NtaColors.onAccent,
                ),
                child: Text('Redraw ($frags/${GameState.portraitFragmentCost})'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickChosenExpertise(GameState state, int heroId, int slotIdx) async {
    final hero = GameState.heroById(heroId);
    final pool = ((hero?['strategy'] as List?) ?? const []).cast<int>();
    final current = state.portraitStrategies[heroId] ?? const <int?>[];
    final rarity = slotIdx < 3 ? slotIdx + 1 : 3;
    final chosen = <int?>{};
    for (var i = 0; i < current.length; i++) {
      if (i != slotIdx) chosen.add(current[i]);
    }
    final options = pool
        .where((sid) => (GameData.STRATEGIES[sid]?['lv'] as int?) == rarity)
        .where((sid) => !chosen.contains(sid))
        .toList();
    if (options.isEmpty) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NtaColors.surface,
        title: Text('Pick ${GameData.STRATEGY_RARITY_NAMES[rarity - 1]}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final sid in options)
                ListTile(
                  dense: true,
                  title: Text(
                      GameData.strategyDesc(sid,
                          idl: true,
                          pawnId: GameState.heroById(heroId)?['pawn']?.toString()),
                      style: const TextStyle(fontSize: 12)),
                  onTap: () {
                    state.pickExpertise(heroId, slotIdx, sid);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. DRILL GROUND: train individual troops Lv.1 -> Lv.6
  Widget _buildDrillGroundView(GameState state) {
    final lvl = state.capitalBuildings['drill_ground'] ?? 0;
    final stats = GameData.levelStats('drill_ground', lvl.clamp(1, 20));
    final next = GameData.levelStats('drill_ground', (lvl + 1).clamp(1, 20));

    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drill Ground - Train Troops Lv.1 -> Lv.6',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NtaColors.success),
        ),
        const SizedBox(height: 6),
        const Text(
          "Train owned troops up through Lv.6 (HP/ATK scale per SoldierAttribute.md). Weaponry cannot train. Cost = Cost Coefficient × crop + EXP scrolls. A Scroll item grants one instant level.",
          style: TextStyle(fontSize: 12, color: NtaColors.textMuted),
        ),
        const SizedBox(height: 8),
        _levelRow('Drill Bldg Lv.$lvl -> Lv.${(lvl + 1).clamp(1, 20)}',
            'March SPD -${stats['marchSpd']}% -> -${next['marchSpd']}% · raise soldier level + SPD, queue 0/6'),
        _levelTable('drill_ground', ['marchSpd']),
        const SizedBox(height: 8),
        _infoCard('Scrolls', 'EXP ${state.expScroll} · Instant ${state.scroll}', Icons.auto_stories, NtaColors.heroNamePill),
        const SizedBox(height: 8),
        for (final entry in state.troops.entries)
          _buildDrillTroopRow(state, entry.key, entry.value),
      ],
    ));
  }

  Widget _buildDrillTroopRow(GameState state, String troopId, int count) {
    if (count <= 0) return const SizedBox.shrink();
    final troop = GameData.TROOPS.firstWhere(
      (t) => t['id'] == troopId,
      orElse: () => {},
    );
    if (troop.isEmpty) return const SizedBox.shrink();
    final id = troopId;
    final tLvl = state.troopLevel(id);
    final cur = state.troopStats(id);
    final isWeaponry = id == 'catapult' || id == 'trebuchet';
    final cost = state.drillCostFor(id);
    final canTrain = !isWeaponry && tLvl < 6 && state.hasResources(cost);
    final canInstant = !isWeaponry && tLvl < 6 && state.scroll > 0;

    return Card(
      color: NtaColors.surfaceSunk,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${troop['name']} (x$count) · Lv.$tLvl',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                if (isWeaponry)
                  const Text('Cannot train', style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'HP ${cur['hp']} · ATK ${cur['atk']} · coef ${troop['coef']}%',
              style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canTrain ? () => state.drillTroop(id) : null,
                    icon: const Icon(Icons.fitness_center, size: 14),
                    label: Text(
                      tLvl >= 6
                          ? 'MAX Lv.6'
                          : 'Train -> Lv.${tLvl + 1} (${cost['crop']} crop + ${cost['exp_scroll']} exp scroll)',
                      style: const TextStyle(fontSize: 11),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NtaColors.accent,
                      foregroundColor: NtaColors.onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: canInstant ? () => state.drillTroopInstant(id) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NtaColors.heroNamePill,
                    foregroundColor: NtaColors.textOnDark,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  child: const Text('+1 scroll', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 6. CLINIC: Treat and Restore Wounded Soldiers
  Widget _buildClinicView(GameState state) {
    final wounded = state.woundedTroops;
    final clinicLvl = state.capitalBuildings['clinic'] ?? 1;
    final costCrop = math.max(10, (wounded * 4) ~/ clinicLvl);
    final canAfford = (state.crop >= costCrop && wounded > 0);

    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clinic - Wounded Troop Infirmary',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NtaColors.heroNamePill),
        ),
        const SizedBox(height: 6),
        const Text(
          'Casualties from world plot assaults are transferred here as wounded soldiers. Brew herbal remedies to restore them to active standing army.',
          style: TextStyle(fontSize: 12, color: NtaColors.textMuted),
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$clinicLvl -> Lv.${(clinicLvl + 1).clamp(1, 20)}',
            'Heal -${GameData.levelStats('clinic', clinicLvl.clamp(1, 20))['healSpd']}% -> -${GameData.levelStats('clinic', (clinicLvl + 1).clamp(1, 20))['healSpd']}% · return Severe 50% / Minor 30% (Lv.1: 40%/0%) · severe -1 lvl · queue 0/6'),
        _levelTable('clinic', ['healSpd', 'minorChance', 'severeChance', 'queue']),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _infoCard('Wounded Troops', '$wounded Soldiers', Icons.healing, wounded > 0 ? NtaColors.danger : NtaColors.success),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Clinic Efficiency', 'Lv. $clinicLvl (${clinicLvl * 25}% Cost Discount)', Icons.medical_services, NtaColors.heroNamePill),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NtaColors.surfaceSunk,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Medical Brew Supply:', style: TextStyle(fontWeight: FontWeight.bold, color: NtaColors.accentBorder, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                wounded > 0
                    ? 'Requires $costCrop crop to treat all $wounded casualties.'
                    : 'All soldiers are healthy and fit for battlefield deployment.',
                style: const TextStyle(fontSize: 12, color: NtaColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canAfford ? () => state.healWoundedTroops() : null,
            icon: const Icon(Icons.local_hospital),
            label: Text(wounded > 0 ? 'Treat & Restore $wounded Wounded Soldiers' : 'No Wounded Soldiers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NtaColors.heroTeal,
              foregroundColor: NtaColors.onAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    ));
  }

  // 6b. EMBASSY: union membership + union policy
  Widget _buildEmbassyView(GameState state, int level) {
    final slots = GameData.embassyMemberSlots(level);
    final joined = state.unionJoined;
    final leader = state.unionIsLeader;
    if (_unionChoices.isEmpty) _unionChoices = state.drawUnionChoices();
    final choices = _unionChoices;

    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Embassy - Union Affairs',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NtaColors.heroNamePill),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: NtaColors.heroTeal.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$slots member slots', style: const TextStyle(fontSize: 11, color: NtaColors.heroNamePill)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Join a union at Lv.1; create your own as leader at Lv.3. Union member slots follow the leader embassy level (buildAttr effect 6).',
          style: TextStyle(fontSize: 12, color: NtaColors.textMuted),
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$level -> Lv.${(level + 1).clamp(1, 20)}',
            'Member slots $slots -> ${GameData.embassyMemberSlots((level + 1).clamp(1, 20))} · ${level >= 3 ? 'can create union' : 'create union at Lv.3'}'),
        _levelTable('embassy', ['memberSlots']),
        const SizedBox(height: 10),

        if (!joined) ...[
          if (level < 1)
            const Text('Build the Embassy to join a union.', style: TextStyle(fontSize: 12, color: NtaColors.textMuted))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Available Unions:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NtaColors.text)),
                    TextButton.icon(
                      onPressed: () => setState(() => _unionChoices = state.drawUnionChoices()),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Re-roll (free)'),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                ...choices.map((c) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NtaColors.surfaceSunk,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: NtaColors.borderSoft),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${c['name']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NtaColors.text)),
                                Text(
                                  'Leader embassy Lv.${c['leaderEmbassy']} · ${c['members']}/${c['slots']} members · union embassy total ${c['totalEmbassy']}',
                                  style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => state.joinUnion(c),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NtaColors.accent,
                              foregroundColor: NtaColors.onAccent,
                            ),
                            child: const Text('Join'),
                          ),
                        ],
                      ),
                    )),
                if (level >= 3) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCreateUnionDialog(state),
                      icon: const Icon(Icons.group_add),
                      label: const Text('Create Your Own Union (Leader)'),
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Creating a union unlocks at Embassy Lv.3.', style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
                  ),
              ],
            ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NtaColors.surfaceSunk,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NtaColors.heroTeal.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups, size: 18, color: NtaColors.heroTeal),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        state.unionName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NtaColors.text),
                      ),
                    ),
                    Text(leader ? 'LEADER' : 'MEMBER', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NtaColors.heroNamePill)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${state.unionMemberCount}/${state.unionMemberSlots} members · leader embassy Lv.${state.unionLeaderEmbassy} · union embassy total ${state.totalUnionEmbassyLevel}',
                  style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                ),
                const SizedBox(height: 6),
                ...state.unionMembers.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '· ${m['name']} (embassy Lv.${m['embassy']})',
                        style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                      ),
                    )),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => state.leaveUnion(),
                    child: const Text('Leave Union'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Union Policy Slots: ${state.unionPolicySlots}/3 (total union embassy 1 / 200 / 400)',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NtaColors.text),
          ),
          const SizedBox(height: 6),
          if (!leader)
            const Text('Only the union leader can enact union policy.', style: TextStyle(fontSize: 11, color: NtaColors.textMuted))
          else
            ...List.generate(state.unionPolicySlots, (slot) {
              final active = state.unionPolicies[slot];
              final p = active == null ? null : GameData.policyById(active['policyId'] ?? 0);
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: NtaColors.surfaceSunk,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p == null
                            ? 'Slot ${slot + 1}: empty'
                            : 'Slot ${slot + 1}: ${p['name']} (Tier ${(active!['tier'] ?? 0) + 1}) — ${GameData.policyDesc(p, active['tier'] ?? 0)}',
                        style: const TextStyle(fontSize: 11, color: NtaColors.text),
                      ),
                    ),
                    if (p == null)
                      TextButton(
                        onPressed: state.canEnactIntoUnion(slot)
                            ? () => _showUnionPolicyDialog(state, slot)
                            : null,
                        child: const Text('Choose'),
                      )
                    else
                      TextButton(
                        onPressed: () => state.resetUnionPolicySlot(slot),
                        child: const Text('Reset'),
                      ),
                  ],
                ),
              );
            }),
        ],
      ],
    ));
  }

  void _showCreateUnionDialog(GameState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NtaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Union'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Union name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (state.createUnion(controller.text)) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showUnionPolicyDialog(GameState state, int slot) {
    final choices = state.drawPolicyChoices();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NtaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Union Policy Slot ${slot + 1}'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: choices.map((p) {
                final values = (p['values'] as List).cast<int>();
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NtaColors.surfaceSunk,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${p['name']}', style: const TextStyle(fontWeight: FontWeight.bold, color: NtaColors.text)),
                      const SizedBox(height: 4),
                      ...List.generate(values.length, (t) => Text(
                            'Tier ${t + 1}: ${GameData.policyDesc(p, t)}',
                            style: const TextStyle(fontSize: 11, color: NtaColors.textMuted),
                          )),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(values.length, (t) => Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: TextButton(
                                onPressed: () {
                                  if (state.enactUnionPolicy(slot, p['id'] as int, t)) Navigator.pop(ctx);
                                },
                                child: Text('Tier ${t + 1}'),
                              ),
                            )),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  // 7. MARKET / UNION MARKET: merchant trade channel
  Widget _buildMarketView(GameState state, {bool union = false}) {
    final buildingId = union ? 'union_market' : 'market';
    final rate = state.marketRateFor(buildingId);
    final merchants = state.tradeMerchantsFor(buildingId);
    final basicCap = merchants * GameData.MERCHANT_BASIC_CAP;
    final specialCap = merchants * GameData.MERCHANT_SPECIAL_CAP;
    final isBasic = const {'crop', 'wood', 'stone'}.contains(_marketFromRes);
    final cap = isBasic ? basicCap : specialCap;
    final amount = _marketAmount.clamp(1, cap);
    final received = isBasic ? math.max(1, (amount * rate).round()) : amount;
    final canAfford = state.hasResources({_marketFromRes: amount});
    final needsUnion = union && state.unionMarketNeedsUnion;
    final channelLabel = state.unionMarketShared
        ? 'Free Market (any player)'
        : 'Union Market (union members only)';

    final resOptions = [
      {'id': 'crop', 'name': 'Crop', 'icon': 'crop'},
      {'id': 'wood', 'name': 'Wood', 'icon': 'wood'},
      {'id': 'stone', 'name': 'Stone', 'icon': 'stone'},
      {'id': 'iron', 'name': 'Iron', 'icon': 'iron'},
      {'id': 'exp_scroll', 'name': 'EXP Scroll', 'icon': 'exp_scroll'},
      {'id': 'scroll', 'name': 'Scroll', 'icon': 'scroll'},
      {'id': 'nail', 'name': 'Nail', 'icon': 'nail'},
    ];
    // Basics and specials trade only within their own tier.
    final toOptions = resOptions
        .where((r) => const {'crop', 'wood', 'stone'}.contains(r['id']) == isBasic)
        .toList();
    final toRes = toOptions.any((r) => r['id'] == _marketToRes)
        ? _marketToRes
        : (toOptions.firstWhere((r) => r['id'] != _marketFromRes,
                orElse: () => toOptions.first)['id'] as String);

    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              union ? 'Union Market - Trade Caravan' : 'Market - Caravan Exchange',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NtaColors.heroNamePill),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: NtaColors.heroTeal.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Efficiency: ${(rate * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: NtaColors.heroNamePill)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '$channelLabel · $merchants merchant(s). Each carries up to $basicCap basics or $specialCap specials per shipment.',
          style: const TextStyle(fontSize: 12, color: NtaColors.textMuted),
        ),
        if (needsUnion)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NtaColors.surfaceSunk,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: NtaColors.borderSoft),
            ),
            child: const Text(
              'Join a union at the Embassy to use the Union Market.',
              style: TextStyle(fontSize: 12, color: NtaColors.textMuted),
            ),
          ),
        const SizedBox(height: 8),
        _levelRow(
          'Lv.${state.capitalBuildings[buildingId] ?? 1}',
          '$merchants merchant(s) · $basicCap basics / $specialCap specials per shipment',
        ),
        _levelTable(buildingId, ['merchants']),
        const SizedBox(height: 8),

        // Trade selection
        Row(
          children: [
            // Sell dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Give Commodity:', style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: NtaColors.surfaceSunk,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButton<String>(
                      value: _marketFromRes,
                      dropdownColor: NtaColors.surfaceSunk,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: resOptions.map((r) {
                        return DropdownMenuItem(
                          value: r['id'],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NtaResIcon(r['icon'] as String, size: 14),
                              const SizedBox(width: NtaSpace.x3),
                              Text(r['name'] as String, style: NtaText.body),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() {
                          _marketFromRes = val;
                          // Keep the amount legal when switching basic <-> special.
                          final basic = const {'crop', 'wood', 'stone'}.contains(val);
                          final lim = basic
                              ? state.tradeMerchantsFor(buildingId) * GameData.MERCHANT_BASIC_CAP
                              : state.tradeMerchantsFor(buildingId) * GameData.MERCHANT_SPECIAL_CAP;
                          if (_marketAmount > lim) _marketAmount = lim;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.arrow_forward, color: NtaColors.heroNamePill),
            ),
            // Receive dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Receive Commodity:', style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: NtaColors.surfaceSunk,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButton<String>(
                      value: toRes,
                      dropdownColor: NtaColors.surfaceSunk,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: toOptions.map((r) {
                        return DropdownMenuItem(
                          value: r['id'],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NtaResIcon(r['icon'] as String, size: 14),
                              const SizedBox(width: NtaSpace.x3),
                              Text(r['name'] as String, style: NtaText.body),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _marketToRes = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Trade amount buttons (clamped to the merchant payload)
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: (isBasic ? [100, 300, 500, 1000] : [1, 3, 5, 10]).map((amt) {
            final legal = amt <= cap;
            final isSel = (_marketAmount == amt);
            return ChoiceChip(
              label: Text('$amt'),
              selected: isSel,
              selectedColor: NtaColors.heroNamePill,
              labelStyle: TextStyle(
                color: isSel ? NtaColors.onAccent : (legal ? NtaColors.textMuted : NtaColors.textMuted.withValues(alpha: 0.4)),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              onSelected: legal ? (val) { if (val) setState(() => _marketAmount = amt); } : null,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: NtaColors.surfaceSunk,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Trade $amount ${_marketFromRes.toUpperCase()} to receive $received ${toRes.toUpperCase()} (Rate ${(rate * 100).toInt()}%)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NtaColors.accentBorder),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (toRes != _marketFromRes && canAfford && !needsUnion)
                ? () => state.marketTrade(_marketFromRes, toRes, amount,
                    buildingId: buildingId)
                : null,
            icon: const Icon(Icons.swap_horiz),
            label: Text('Execute Merchant Trade ($received ${toRes.toUpperCase()})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NtaColors.heroTeal,
              foregroundColor: NtaColors.onAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    ));
  }

  // 8. BARN: Granary Storage Facility
  Widget _buildBarnView(GameState state, int level) {
    final double pct = (state.crop / state.cropCapacity).clamp(0.0, 1.0);

    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Barn - Imperial Granary',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: NtaColors.accentBottom),
        ),
        const SizedBox(height: 6),
        const Text(
          'Stores harvested crops from your realm. Real capacity from buildAttr (Lv.3 5700 -> Lv.4 7400).',
          style: TextStyle(fontSize: 12, color: NtaColors.textMuted),
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$level -> Lv.${(level + 1).clamp(1, 20)}',
            'Crop Cap ${GameData.levelStats('barn', level.clamp(1, 20))['cropCap']} -> ${GameData.levelStats('barn', (level + 1).clamp(1, 20))['cropCap']} '),
        _levelTable('barn', ['cropCap']),
        const SizedBox(height: 8),

        _infoCard('Crop Storage', '${state.crop} / ${state.cropCapacity} (Level $level)', Icons.warehouse, NtaColors.accentBottom),
        const SizedBox(height: 16),

        const Text('Storage Capacity:', style: TextStyle(fontSize: 11, color: NtaColors.textMuted)),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          minHeight: 12,
          backgroundColor: NtaColors.borderSoft,
          valueColor: const AlwaysStoppedAnimation<Color>(NtaColors.accentBottom),
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 6),
        Text('${(pct * 100).toInt()}% Full', style: const TextStyle(fontSize: 11, color: NtaColors.textMuted)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NtaColors.surfaceSunk,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Upgrade to Level ${level + 1} to increase crop capacity to ${state.cropCapacity + 3000}.',
            style: const TextStyle(fontSize: 12, color: NtaColors.accentBorder),
          ),
        ),
      ],
    ));
  }

  // 9. WAREHOUSE: Sturdy Materials Depot
  Widget _buildWarehouseView(GameState state, int level) {
    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Warehouse - Special Vault',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
        ),
        const SizedBox(height: 6),
        const Text(
          'Holds wood & stone from controlled plots (capacity grows per level). Chest-only specials (iron, EXP scroll, scroll, nail) have no cap.',
          style: TextStyle(fontSize: 12, color: NtaColors.textMuted),
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$level -> Lv.${(level + 1).clamp(1, 20)}',
            'Wood ${GameData.levelStats('warehouse', level.clamp(1, 20))['woodCap']} -> ${GameData.levelStats('warehouse', (level + 1).clamp(1, 20))['woodCap']} · Stone same '),
        _levelTable('warehouse', ['woodCap', 'stoneCap']),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _infoCard('Wood Stock', '${state.wood} / ${state.materialCapacity}', Icons.forest, Colors.lightBlueAccent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Stone Stock', '${state.stone} / ${state.materialCapacity}', Icons.landscape, Colors.lightBlueAccent),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _infoCard('Iron (chest)', '${state.iron}', Icons.construction, NtaColors.textMuted),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('EXP Scroll (chest)', '${state.expScroll}', Icons.auto_stories, NtaColors.heroNamePill),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _infoCard('Scroll (chest)', '${state.scroll}', Icons.receipt_long, NtaColors.heroNamePill),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Nail (chest)', '${state.nail}', Icons.push_pin, NtaColors.danger),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NtaColors.surfaceSunk,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Upgrade to Level ${level + 1} to increase material capacity to ${state.materialCapacity + 2500}.',
            style: const TextStyle(fontSize: 12, color: NtaColors.accentBorder),
          ),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final capitalBuildings = state.capitalBuildings;
    final capitalLevel = capitalBuildings['palace'] ?? 1;

    return Scaffold(
      backgroundColor: NtaColors.bg,
      body: Column(
              children: [
                // Capital skin asli per level (city_1001 = lv1 .. city_10011NN).
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        NtaAssets.capitalSkin(capitalLevel),
                        height: 64,
                        filterQuality: FilterQuality.none,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Capital Lv.$capitalLevel', style: NtaText.bodyBold),
                          Text('Territory: ${state.conqueredPlots.length} plots',
                              style: NtaText.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                // 17x17 Interactive Grid - Pure tile display, click tile to interact
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        child: ClipRect(
                          child: Container(
                            width: (gridSize * cellSize).toDouble() + 4, // +4 for borders
                            height: (gridSize * cellSize).toDouble() + 4,
                            decoration: BoxDecoration(
                              color: NtaColors.mapGreenA,
                              border: Border.all(color: NtaColors.border, width: NtaBorder.panel),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x33000000),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRect(
                              child: Column(
                                children: List.generate(gridSize, (r) {
                                  return SizedBox(
                                    height: cellSize.toDouble(),
                                    child: ClipRect(
                                      child: Row(
                                        children: List.generate(gridSize, (c) {
                                          return GestureDetector(
                                            onTap: () => _onTileTapped(context, state, r, c, capitalBuildings),
                                            child: SizedBox(
                                              width: cellSize.toDouble(),
                                              height: cellSize.toDouble(),
                                              child: _buildCell(r, c, capitalBuildings, state),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      );
    }

  IconData _facilityIcon(String id) {
    switch (id) {
      case 'palace':
        return Icons.account_balance;
      case 'barracks':
        return Icons.shield;
      case 'smithy':
        return Icons.handyman;
      case 'hall_of_heroes':
        return Icons.auto_awesome;
      case 'drill_ground':
        return Icons.flag;
      case 'clinic':
        return Icons.local_hospital;
      case 'market':
        return Icons.store;
      case 'union_market':
        return Icons.storefront;
      case 'embassy':
        return Icons.handshake;
      case 'barn':
        return Icons.home;
      case 'warehouse':
        return Icons.inventory_2;
      default:
        return Icons.help_outline;
    }
  }

  IconData _troopCategoryIcon(String category) {
    switch (category) {
      case 'shield':
        return Icons.shield;
      case 'bow':
        return Icons.location_searching;
      case 'cavalry':
        return Icons.directions_walk;
      case 'weaponry':
        return Icons.construction;
      case 'spear':
      default:
        return Icons.sports_martial_arts;
    }
  }

  void _showNotBuiltDialog(BuildContext context, GameState state, String id, String name) {
    final req = state.capitalBuildRequirement(id);
    String? reqText;
    if (req != null) {
      reqText = state.capitalRequirementText(id);
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NtaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_facilityIcon(id), size: 28, color: NtaColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$name (Not built)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NtaColors.textMuted),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: NtaColors.textMuted),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This building has not been constructed yet.',
              style: TextStyle(fontSize: 13, color: NtaColors.textMuted),
            ),
            if (reqText != null && reqText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Requires: $reqText',
                style: const TextStyle(fontSize: 13, color: NtaColors.danger),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Open the Build menu (hammer button, bottom right) to construct it.',
              style: TextStyle(fontSize: 12, color: NtaColors.accentBorder),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Upgrade bar pinned at bottom of every facility popup.
  Widget _upgradeBar(BuildContext context, GameState state, String id, int level, int r, int c) {
    if (level >= 20) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: NtaColors.surfaceSunk,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('MAX LEVEL (Lv.20)', style: TextStyle(fontWeight: FontWeight.bold, color: NtaColors.accentBorder)),
      );
    }
    final cost = GameData.upgradeCost(id, level + 1);
    final canAfford = state.hasResources(cost);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NtaColors.surfaceSunk,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Upgrade -> Lv.${level + 1}:\n🪵 ${cost['wood']} + 🪨 ${cost['stone']}',
              style: const TextStyle(fontSize: 12, color: NtaColors.text),
            ),
          ),
          ElevatedButton(
            onPressed: canAfford
                ? () {
                    final ok = state.upgradeCapitalBuilding(id);
                    if (ok) {
                      Navigator.pop(context);
                      _onTileTapped(context, state, r, c, state.capitalBuildings);
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: NtaColors.accent,
              foregroundColor: NtaColors.onAccent,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _onTileTapped(BuildContext context, GameState state, int r, int c, Map<String, int> buildings) {
      // Check if it's a facility tile first
    for (var b in GameData.CAPITAL_BUILDINGS) {
      final br = b['r'] as int;
      final bc = b['c'] as int;
      final bw = b['w'] as int;
      final bh = b['h'] as int;
      if (r >= br && r < br + bh && c >= bc && c < bc + bw) {
        final id = b['id'] as String;
        final name = b['name'] as String;
        final level = buildings[id] ?? 0;
        if (level <= 0) {
          _showNotBuiltDialog(context, state, id, name);
          return;
        }
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: NtaColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            titlePadding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            title: Row(
              children: [
                Icon(_facilityIcon(id), size: 28, color: NtaColors.text),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$name (Lv. $level)',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NtaColors.text),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: NtaColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: SizedBox(
              width: 460,
              height: 520,
              child: Column(
                children: [
                  Expanded(
                    child: Consumer<GameState>(
                      builder: (context, liveState, child) =>
                          _buildFacilityPopupContent(liveState, id, level),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _upgradeBar(context, state, id, level, r, c),
                ],
              ),
            ),
          ),
        );
        return;
      }
    }

      // If not a facility, check if it's an empty cell in the court for garrison
      final bool inCourt = (r >= courtStart && r <= courtEnd && c >= courtStart && c <= courtEnd);
      final bool isGate = (r == 0 && c == gatePos) || (r == gridSize - 1 && c == gatePos) ||
                          (r == gatePos && c == 0) || (r == gatePos && c == gridSize - 1);
      final bool isAvenue = (r >= 1 && r <= 4 && c == gatePos) || (r >= 12 && r <= 15 && c == gatePos) ||
                            (r == gatePos && c >= 1 && c <= 4) || (r == gatePos && c >= 12 && c <= 15);
      final bool isWall = !inCourt && !isAvenue && !isGate;

      if (inCourt && !isWall && !isAvenue) {
        _showGarrisonDialog(context, state, r, c);
      }
    }

    void _showGarrisonDialog(BuildContext context, GameState state, int r, int c) {
      final key = '$r,$c';
      final existingGarrison = state.capitalGarrison[key];

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: NtaColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            existingGarrison != null
                ? 'Garrison at ($r, $c)'
                : 'Place Garrison at ($r, $c)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NtaColors.text),
          ),
          content: SingleChildScrollView(
            child: existingGarrison != null
                ? _buildExistingGarrisonContent(state, r, c, existingGarrison)
                : _buildPlaceGarrisonContent(state, r, c),
          ),
        ),
      );
    }

    Widget _buildExistingGarrisonContent(GameState state, int r, int c, Map<String, dynamic> garrison) {
      final troopId = garrison['troopId'] as String;
      final count = garrison['count'] as int;
      final troop = GameData.TROOPS.firstWhere((t) => t['id'] == troopId, orElse: () => {'name': troopId, 'category': 'spear'});
      final category = (troop['category'] as String?) ?? 'spear';

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_troopCategoryIcon(category), size: 32, color: NtaColors.text),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(troop['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NtaColors.text)),
                  Text('Count: $count', style: const TextStyle(fontSize: 14, color: NtaColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              state.moveCapitalGarrison(r, c, r, c); // This is just to refresh, actual move needs target
              // Actually show move dialog
              _showMoveGarrisonDialog(context, state, r, c);
            },
            icon: const Icon(Icons.swap_horiz, color: NtaColors.onAccent),
            label: const Text('Move Garrison', style: TextStyle(color: NtaColors.onAccent)),
            style: ElevatedButton.styleFrom(backgroundColor: NtaColors.accent),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              state.recallCapitalGarrison(r, c);
            },
            icon: const Icon(Icons.arrow_back, color: NtaColors.text),
            label: const Text('Recall to Army', style: TextStyle(color: NtaColors.text)),
            style: ElevatedButton.styleFrom(backgroundColor: NtaColors.danger),
          ),
        ],
      );
    }

    void _showMoveGarrisonDialog(BuildContext context, GameState state, int fromR, int fromC) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: NtaColors.surface,
          title: Text('Move Garrison from ($fromR, $fromC)', style: const TextStyle(color: NtaColors.text)),
          content: const Text('Tap target cell on the grid to move. Gate areas are blocked.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ],
        ),
      );
    }

    Widget _buildPlaceGarrisonContent(GameState state, int r, int c) {
      final availableTroops = GameData.TROOPS.where((t) => (state.troops[t['id'] as String] ?? 0) > 0).toList();

      if (availableTroops.isEmpty) {
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No troops available in main army.', style: TextStyle(color: NtaColors.textMuted)),
            SizedBox(height: 8),
            Text('Train troops at Barracks first.', style: TextStyle(fontSize: 12, color: NtaColors.danger)),
          ],
        );
      }

      String selectedTroopId = availableTroops.first['id'] as String;
      int quantity = 10;

      return StatefulBuilder(
              builder: (ctx, setPromptState) {
                final available = state.troops[selectedTroopId] ?? 0;
          final canPlace = available >= quantity && !state.isCapitalGarrisonBlocked(r, c);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select troop type:', style: TextStyle(color: NtaColors.textMuted)),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedTroopId,
                dropdownColor: NtaColors.surface,
                style: const TextStyle(color: NtaColors.text),
                items: availableTroops.map((t) => DropdownMenuItem(
                  value: t['id'] as String,
                  child: Text('${t['name']} (Army: ${state.troops[t['id']] ?? 0})'),
                )).toList(),
                onChanged: (val) => setPromptState(() => selectedTroopId = val!),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: NtaColors.danger),
                    onPressed: quantity > 5 ? () => setPromptState(() => quantity -= 5) : null,
                  ),
                  Text('$quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: NtaColors.text)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: NtaColors.success),
                    onPressed: () => setPromptState(() => quantity += 5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Available in army: ${state.troops[selectedTroopId] ?? 0}',
                style: const TextStyle(fontSize: 12, color: NtaColors.textMuted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canPlace
                          ? () {
                              Navigator.pop(context);
                              state.placeCapitalGarrison(selectedTroopId, quantity, r, c);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(backgroundColor: NtaColors.success),
                      child: const Text('Place', style: TextStyle(color: NtaColors.text)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: NtaColors.disabled),
                      child: const Text('Cancel', style: TextStyle(color: NtaColors.text)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }