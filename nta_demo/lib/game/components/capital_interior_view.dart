import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/game_state.dart';
import '../../data/game_data.dart';

class CapitalInteriorView extends StatefulWidget {
  const CapitalInteriorView({super.key});

  @override
  State<CapitalInteriorView> createState() => _CapitalInteriorViewState();
}

class _CapitalInteriorViewState extends State<CapitalInteriorView> {
  String _marketFromRes = 'crop';
  String _marketToRes = 'wood';
  int _marketAmount = 100;

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
                                          color: const Color(0xFF1B5E20), // Dark green for gates (per reference image 2)
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text('🚪', style: TextStyle(fontSize: 10)),
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
                                          color: const Color(0xFF1B5E20), // Dark green for city gates
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text('🚪', style: TextStyle(fontSize: 10)),
                                      );
                                    }

                                    if (isCityWall) {
                                      // City wall: white-bordered brown (white line in ref image 1)
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF5C4033),
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        alignment: Alignment.center,
                                        child: null,
                                      );
                                    }

                                    if (isInnerArea) {
                                      // Inner area between wall and court - medium brown (same as wall but no border)
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B4513),
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
        // Determine center cell of facility to render icon
        final bool isCenterCell = (r == br + (bh ~/ 2) && c == bc + (bw ~/ 2));

        Color baseColor;
        switch (id) {
          case 'palace':
            baseColor = const Color(0xFF7A5812);
            break;
          case 'barracks':
            baseColor = const Color(0xFF6B1D1D);
            break;
          case 'smithy':
            baseColor = const Color(0xFF7D4311);
            break;
          case 'hall_of_heroes':
            baseColor = const Color(0xFF4A1F6E);
            break;
          case 'drill_ground':
            baseColor = const Color(0xFF48541E);
            break;
          case 'clinic':
            baseColor = const Color(0xFF145437);
            break;
          case 'market':
            baseColor = const Color(0xFF194C57);
            break;
          case 'barn':
            baseColor = const Color(0xFF6E5616);
            break;
          case 'warehouse':
            baseColor = const Color(0xFF2D3C5C);
            break;
          default:
            baseColor = const Color(0xFF2E344A);
        }

        return GestureDetector(
          onTap: () => _onTileTapped(context, state, r, c, capitalBuildings),
          child: Container(
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.7),
              border: Border(
                right: BorderSide(color: Colors.white12, width: 0.2),
                bottom: BorderSide(color: Colors.white12, width: 0.2),
              ),
            ),
            alignment: Alignment.center,
            child: isCenterCell
                ? Text(
                    facility['icon'] as String,
                    style: const TextStyle(fontSize: 12),
                  )
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
              color: const Color(0xFF3D3328),
              border: Border.all(color: const Color(0xFF5C4033), width: 0.5),
            ),
            alignment: Alignment.center,
            child: const Text('·', style: TextStyle(color: Colors.white38, fontSize: 16)),
          );
        }

            if (isInnerAvenue) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3328),
                  border: Border.all(color: const Color(0xFF4A3728), width: 0.5),
                ),
                alignment: Alignment.center,
                child: const Text('·', style: TextStyle(color: Colors.white38, fontSize: 16)),
              );
            }

            return Container(
          decoration: BoxDecoration(
            color: inCourt ? const Color(0xFF252B3B) : const Color(0xFF8B4513),
            border: Border(
              right: BorderSide(color: const Color(0xFF3A445C), width: 0.2),
              bottom: BorderSide(color: const Color(0xFF3A445C), width: 0.2),
            ),
          ),
          alignment: Alignment.center,
          child: null,
        );
  }

  // Popup facility content router
  Widget _buildFacilityPopupContent(GameState state, String id, int level) {
      return _buildFacilityContent(state, id, level);
    }

    void _showCapitalInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F30),
        title: const Text('Capital Citadel', style: TextStyle(color: Colors.amber)),
        content: const SingleChildScrollView(
          child: Text(
            'Capital Citadel Interior — 17×17 Strategic Layout\n\n'
            '• Single-tile Gates at center of each wall (N/S/E/W)\n'
            '• 5-Petak Avenues from gates to Central Court\n'
            '• 7×7 Central Citadel Court (rows 5–11, cols 5–11)\n'
            '• Fortified Bastion Walls enclosing the Court\n'
            '• 9 Citadel Facilities inside the Court:\n'
            '  🏛️ Palace — Realm command, tribute, team limit\n'
            '  ⚔️ Barracks — Train standing army (Spear/Cav/Shield/Bow)\n'
            '  🔨 Smithy — Forge battlefield equipment\n'
            '  ⭐ Hall of Heroes — Worship & permanently bind generals\n'
            '  🎖️ Drill Ground — Elevate army potency & morale\n'
            '  🏥 Clinic — Treat & restore wounded soldiers\n'
            '  🏪 Market — Merchant caravan commodity exchange\n'
            '  🌾 Barn — Imperial granary (crop storage)\n'
            '  📦 Warehouse — Material depot (wood/stone/iron/gold)\n\n'
            'Tap a facility on the grid or select from chips below to open its function popup.',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String icon, String label, Color color) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
        ],
      );
    }

  Widget _infoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2838),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
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

  // Current → next line + expandable full Lv.1-20 table from levelStats().
  Widget _levelRow(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _levelTable(String id, List<String> keys) {
    return ExpansionTile(
      dense: true,
      tilePadding: EdgeInsets.zero,
      title: const Text('Full Lv.1–20 table', style: TextStyle(fontSize: 11, color: Colors.white70)),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF141927),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            [
              for (int l = 1; l <= 20; l++)
                'Lv.$l: ${keys.map((k) => '$k=${GameData.levelStats(id, l)[k]}').join(' · ')}',
            ].join('\n'),
            style: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'monospace'),
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        const SizedBox(height: 6),
        const Text(
          'The Imperial Palace is the single core seat of your empire. It commands maximum army teams, collects realm taxes, and anchors your sovereignty.',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 12),

        // Status grid
        Row(
          children: [
            Expanded(
              child: _infoCard('Army Cap', '${stats['armyCap']} Teams', Icons.groups, Colors.blueAccent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Territory', '${stats['territory']} Plots', Icons.flag, Colors.greenAccent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Army Capacity', '${stats['armyCapacity']}', Icons.shield, Colors.amberAccent),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$level → Lv.${(level + 1).clamp(1, 20)}',
            'Army Cap ${stats['armyCap']} → ${next['armyCap']} · Territory ${stats['territory']} → ${next['territory']} · ${next['note']}'),
        const SizedBox(height: 8),
        _levelTable('palace', ['armyCap', 'territory']),
        const SizedBox(height: 14),

        // Base Realm Tax Breakdown
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2638),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Realm Output per Hour:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('🌾 +${rates["crop"]!.toInt()}/h', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  Text('🪵 +${rates["wood"]!.toInt()}/h', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  Text('🪨 +${rates["stone"]!.toInt()}/h', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  const Text('⚔️ —', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const Text('🪙 —', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
            icon: const Icon(Icons.monetization_on, color: Colors.black),
            label: Text('Collect Imperial Realm Tribute (Lv. $level)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    ));
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Lv.$lvl', style: const TextStyle(fontSize: 10, color: Colors.redAccent)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('Counter: Spear > Cav > Shield > Bow > Spear (40% ATK, ignore 20% DEF)', style: TextStyle(fontSize: 10, color: Colors.redAccent)),
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$lvl → Lv.${(lvl + 1).clamp(1, 20)}',
            'Recruit SPD -${stats['recruitSpd']}% → -${next['recruitSpd']}% · Soldier Cap Lv.${stats['soldierCap']} → Lv.${next['soldierCap']} · ${next['note']}'),
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

  Widget _buildTroopCategorySection(GameState state, String category, String title) {
    final units = GameData.TROOPS.where((t) => t['category'] == category).toList();
    if (units.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(
            '$title (${units.length})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber),
          ),
        ),
        Column(
          children: [
            for (var troop in units)
              Builder(builder: (context) {
              final id = troop['id'] as String;
              final count = state.troops[id] ?? 0;
              final costMap = troop['cost'] as Map<String, dynamic>;

              return Card(
                color: const Color(0xFF1B2133),
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  dense: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                    child: Text(
                      (troop['skill'] as String).isNotEmpty ? (troop['skill'] as String)[0] : '?',
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  title: Text('${troop["name"]} (x$count)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    'HP ${troop["hp"]} | ATK ${troop["atk"]} | DEF ${troop["def"]} | Rage ${troop["rage"]} | R${troop["range"]}/M${troop["move"]}\nCost: ${costMap.entries.map((e) => "${e.value} ${e.key}").join(", ")}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _recruitTroopPrompt(state, troop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
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
                          color: const Color(0xFF141927),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Counters: ${troop["counter"]} (+40% ATK). Upkeep ${troop["upkeep"]} crop · March ${troop["march"]} tiles/h.',
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Skill: ${troop["skill"]}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                            Text(
                              '${troop["skillDesc"]}',
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
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
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setPromptState) {
          final costMap = troop['cost'] as Map<String, dynamic>;
          final totalCost = <String, int>{};
          for (var entry in costMap.entries) {
            totalCost[entry.key] = (entry.value as int) * quantity;
          }
          final canAfford = state.hasResources(totalCost);

          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F30),
            title: Text('Train ${troop["name"]}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HP ${troop["hp"]} | ATK ${troop["atk"]} | DEF ${troop["def"]} | Rage ${troop["rage"]}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  'Range ${troop["range"]} · Move ${troop["move"]} · Upkeep ${troop["upkeep"]} crop · March ${troop["march"]}/h',
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
                const SizedBox(height: 4),
                Text(
                  'Skill: ${troop["skill"]} — ${troop["skillDesc"]}',
                  style: const TextStyle(fontSize: 11, color: Colors.amber),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: quantity > 1 ? () => setPromptState(() => quantity -= 1) : null,
                    ),
                    Text('$quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () => setPromptState(() => quantity += 1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Cost: ${totalCost.entries.map((e) => "${e.value} ${e.key}").join(", ")}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canAfford ? Colors.lightGreenAccent : Colors.redAccent,
                  ),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Lv.$smithyLvl', style: const TextStyle(fontSize: 10, color: Colors.orangeAccent)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          unlocked.isEmpty
              ? 'No tiers unlocked yet — upgrade Smithy to Lv.1.'
              : 'Unlocked: Lv.${unlocked.join(" · Lv.")}${nextTier == -1 ? " (MAX)" : " — next Lv.$nextTier"}',
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
        const SizedBox(height: 6),
        _levelRow('Lv.$smithyLvl → Lv.${(smithyLvl + 1).clamp(1, 20)}',
            'Craft SPD -${GameData.levelStats('smithy', smithyLvl.clamp(1, 20))['craftSpd']}% → -${GameData.levelStats('smithy', (smithyLvl + 1).clamp(1, 20))['craftSpd']}% · Exclusive + Smelt ${smithyLvl >= 10 ? "UNLOCKED" : "at Lv.10"}'),
        _levelTable('smithy', ['craftSpd']),
        const SizedBox(height: 8),
        for (final tier in tiers.where((t) => t != 10))
          _buildSmithyTierSection(state, tier, smithyLvl),
        _buildExclusiveSection(state, smithyLvl),
      ],
    ));
  }

  Widget _buildSmithyTierSection(GameState state, int tier, int smithyLvl) {
    final items = GameData.EQUIPMENT.where((e) => e['tier'] == tier).toList();
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
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              if (locked)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text('🔒 locked', style: TextStyle(fontSize: 11, color: Colors.white54)),
                ),
            ],
          ),
        ),
        Column(
          children: [
            for (var eq in items)
              Builder(builder: (context) {
              final id = eq['id'] as String;
              final owned = state.equipment[id] ?? 0;
              final cost = eq['cost'] as Map<String, dynamic>;
              final costParsed = cost.map((k, v) => MapEntry(k, v as int));
              final canAfford = !locked && state.hasResources(costParsed);

              return Card(
                color: const Color(0xFF1B2133),
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  dense: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  leading: const Icon(Icons.shield, color: Colors.orangeAccent, size: 26),
                  title: Text('${eq["name"]} ${eq["roll"]} (x$owned)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    'Cost: ${costParsed.entries.map((e) => "${e.value} ${e.key}").join(", ")}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  trailing: SizedBox(
                    width: 76,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: canAfford ? () => state.craftEquipment(id) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
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
                            child: const Text('Smelt ½', style: TextStyle(fontSize: 10, color: Colors.redAccent)),
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
                          color: const Color(0xFF141927),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${eq["effect"]}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                            if (id == 'radiant_plate' || id == 'thousand_tempered')
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Recasts: ${state.recastCounts[id] ?? 0}/50',
                                        style: const TextStyle(fontSize: 11, color: Colors.amber),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: owned > 0 ? () => state.recastEquipment(id) : null,
                                      child: const Text('Recast (20🪙+20🧱)', style: TextStyle(fontSize: 10)),
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
    final items = GameData.EXCLUSIVE_EQUIPMENT;
    final locked = smithyLvl < 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: [
              Text(
                'Exclusive — Smithy Lv.10 (${items.length})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
              ),
              if (locked)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text('🔒 locked', style: TextStyle(fontSize: 11, color: Colors.white54)),
                ),
            ],
          ),
        ),
        const Text(
          'One per soldier sub-type: rolled HP/ATK + 2 random common passives + fixed skill upgrade.',
          style: TextStyle(fontSize: 11, color: Colors.white70),
        ),
        const SizedBox(height: 6),
        Column(
          children: [
            for (var eq in items)
              Builder(builder: (context) {
              final id = eq['id'] as String;
              final owned = state.exclusiveEquipment[id];
              final cost = eq['cost'] as Map<String, dynamic>;
              final costParsed = cost.map((k, v) => MapEntry(k, v as int));
              final canAfford = !locked && state.hasResources(costParsed) && owned == null;
              final troop = GameData.TROOPS.firstWhere(
                (t) => t['id'] == eq['subtype'],
                orElse: () => <String, dynamic>{},
              );

              return Card(
                color: const Color(0xFF221B33),
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  dense: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  leading: const Icon(Icons.stars, color: Colors.purpleAccent, size: 26),
                  title: Text('${eq["name"]} — ${troop.isNotEmpty ? troop["name"] : eq["subtype"]} ${owned != null ? "✅" : ""}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    '+${eq["hp"]} HP / +${eq["atk"]} ATK',
                    style: const TextStyle(fontSize: 11, color: Colors.purpleAccent),
                  ),
                  trailing: ElevatedButton(
                    onPressed: canAfford ? () => state.craftEquipment(id) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(72, 30),
                    ),
                    child: Text(owned != null ? 'Owned' : 'Forge', style: const TextStyle(fontSize: 12)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171226),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Skill: ${eq["skillMod"]}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                            const SizedBox(height: 4),
                            const Text('Plus 2 random effects from the common pool.', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(
                              'Cost: ${costParsed.entries.map((e) => "${e.value} ${e.key}").join(", ")}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: canAfford ? Colors.lightGreenAccent : Colors.redAccent,
                              ),
                            ),
                            if (owned != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('Rolled: $owned', style: const TextStyle(fontSize: 11, color: Colors.lightGreenAccent)),
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

  // 4. HALL OF HEROES: Worship & Permanently Bind Generals
  Widget _buildHeroesView(GameState state) {
    final lvl = state.capitalBuildings['hall_of_heroes'] ?? 0;
    final stats = GameData.levelStats('hall_of_heroes', lvl.clamp(1, 20));
    final next = GameData.levelStats('hall_of_heroes', (lvl + 1).clamp(1, 20));
    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hall of Heroes - Worship & Bind Legendary Generals',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Lv.$lvl', style: const TextStyle(fontSize: 10, color: Colors.purpleAccent)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Notice: Once a hero is Worshipped, they are permanently bound to your campaign command.',
          style: TextStyle(fontSize: 11, color: Colors.amberAccent),
        ),
        const SizedBox(height: 6),
        _levelRow('Lv.$lvl → Lv.${(lvl + 1).clamp(1, 20)}',
            'Portraits ${stats['portraits']} → ${next['portraits']}${(lvl + 1) == 10 ? " · +1 slot at Lv.10" : stats['portraits'] != next['portraits'] ? " · slot up" : ""}'),
        _levelTable('hall_of_heroes', ['portraits']),
        const SizedBox(height: 8),
        Column(
          children: [
            for (int index = 0; index < GameData.HEROES.length; index++)
              Builder(builder: (context) {
              final hero = GameData.HEROES[index];
              final id = hero['id'] as String;
              final isWorshipped = state.worshippedHeroes.contains(id);

              return Card(
                color: const Color(0xFF1B2133),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    isWorshipped ? Icons.stars : Icons.person_add,
                    color: isWorshipped ? Colors.amber : Colors.purpleAccent,
                    size: 28,
                  ),
                  title: Text(
                    '${hero["name"]} - ${hero["title"]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isWorshipped ? Colors.amber : Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    'ATK: ${hero["atk"]} | DEF: ${hero["def"]} | HP: ${hero["hp"]} Skill: ${hero["skill"]}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  trailing: isWorshipped
                      ? const Chip(
                          label: Text('BOUND', style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.black45,
                        )
                      : ElevatedButton(
                          onPressed: () => state.worshipHero(id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: const Text('Worship', style: TextStyle(fontSize: 12)),
                        ),
                ),
              );
            }),
          ],
        ),
      ],
    ));
  }

  // 5. DRILL GROUND: Elevate Troop Morale & Combat Potency
  Widget _buildDrillGroundView(GameState state) {
    final costCrop = 80 * state.drillLevel;
    final costWood = 50 * state.drillLevel;
    final canAfford = state.hasResources({'crop': costCrop, 'wood': costWood});
    final lvl = state.capitalBuildings['drill_ground'] ?? 0;
    final stats = GameData.levelStats('drill_ground', lvl.clamp(1, 20));
    final next = GameData.levelStats('drill_ground', (lvl + 1).clamp(1, 20));

    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drill Ground - Elevate Army Potency',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent),
        ),
        const SizedBox(height: 6),
        const Text(
          "Conduct rigorous formation drills to permanently amplify your soldiers' battle prowess and morale.",
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        _levelRow('Drill Bldg Lv.$lvl → Lv.${(lvl + 1).clamp(1, 20)}',
            'March SPD -${stats['marchSpd']}% → -${next['marchSpd']}% · raise soldier level + SPD, queue 0/6'),
        _levelTable('drill_ground', ['marchSpd']),
        const SizedBox(height: 8),

        _infoCard('Current Army Potency', 'Tier ${state.drillLevel} (+${state.drillLevel * 10}% Combat DMG)', Icons.military_tech, Colors.lightGreenAccent),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2838),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Next Drill Requirements:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13)),
              const SizedBox(height: 6),
              Text('🌾 $costCrop Crop   🪵 $costWood Wood', style: const TextStyle(fontSize: 13, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canAfford ? () => state.drillArmy() : null,
            icon: const Icon(Icons.fitness_center),
            label: Text('Conduct Army Drills (Raise to Tier ${state.drillLevel + 1})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreenAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    ));
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.tealAccent),
        ),
        const SizedBox(height: 6),
        const Text(
          'Casualties from world plot assaults are transferred here as wounded soldiers. Brew herbal remedies to restore them to active standing army.',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$clinicLvl → Lv.${(clinicLvl + 1).clamp(1, 20)}',
            'Heal -${GameData.levelStats('clinic', clinicLvl.clamp(1, 20))['healSpd']}% → -${GameData.levelStats('clinic', (clinicLvl + 1).clamp(1, 20))['healSpd']}% · return Severe 50% / Minor 30% (Lv.1: 40%/0%) · severe -1 lvl · queue 0/6'),
        _levelTable('clinic', ['healSpd', 'minorChance', 'severeChance', 'queue']),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _infoCard('Wounded Troops', '$wounded Soldiers', Icons.healing, wounded > 0 ? Colors.redAccent : Colors.greenAccent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Clinic Efficiency', 'Lv. $clinicLvl (${clinicLvl * 25}% Cost Discount)', Icons.medical_services, Colors.tealAccent),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2838),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Medical Brew Supply:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                wounded > 0
                    ? 'Requires 🌾 $costCrop Crop to treat all $wounded casualties.'
                    : 'All soldiers are healthy and fit for battlefield deployment.',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
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
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    ));
  }

  // 7. MARKET: Merchant Trading Post
  Widget _buildMarketView(GameState state) {
    final marketLvl = state.capitalBuildings['market'] ?? 1;
    final double rate = math.min(0.95, 0.70 + (marketLvl * 0.05));
    final received = math.max(1, (_marketAmount * rate).round());
    final canAfford = state.hasResources({_marketFromRes: _marketAmount});

    final resOptions = [
      {'id': 'crop', 'name': 'Crop', 'icon': '🌾'},
      {'id': 'wood', 'name': 'Wood', 'icon': '🪵'},
      {'id': 'stone', 'name': 'Stone', 'icon': '🪨'},
    ];

    return _facilityScroll(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Market - Caravan Exchange',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Exchange Efficiency: ${(rate * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: Colors.cyanAccent)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Trade surplus commodities (crop/wood/stone) with traveling merchants. Chest-only specials (iron, EXP scroll, scroll, nail) cannot be traded.',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        _levelRow('Market Lv.$marketLvl → Lv.${(marketLvl + 1).clamp(1, 20)}',
            'Merchants $marketLvl → ${(marketLvl + 1).clamp(1, 20)} (1 slot/lvl) · union trade channel'),
        _levelTable('market', ['merchants']),
        const SizedBox(height: 8),

        // Trade selection
        Row(
          children: [
            // Sell dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Give Commodity:', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2838),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButton<String>(
                      value: _marketFromRes,
                      dropdownColor: const Color(0xFF1E2838),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: resOptions.map((r) {
                        return DropdownMenuItem(
                          value: r['id'],
                          child: Text('${r["icon"]} ${r["name"]}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _marketFromRes = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.arrow_forward, color: Colors.cyanAccent),
            ),
            // Receive dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Receive Commodity:', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2838),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButton<String>(
                      value: _marketToRes,
                      dropdownColor: const Color(0xFF1E2838),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: resOptions.map((r) {
                        return DropdownMenuItem(
                          value: r['id'],
                          child: Text('${r["icon"]} ${r["name"]}'),
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

        // Trade amount buttons
        Row(
          children: [100, 300, 500, 1000].map((amt) {
            final isSel = (_marketAmount == amt);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('$amt'),
                selected: isSel,
                selectedColor: Colors.cyanAccent,
                labelStyle: TextStyle(
                  color: isSel ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                onSelected: (val) {
                  if (val) setState(() => _marketAmount = amt);
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2838),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Trade $_marketAmount ${_marketFromRes.toUpperCase()} to receive $received ${_marketToRes.toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_marketFromRes != _marketToRes && canAfford)
                ? () => state.marketTrade(_marketFromRes, _marketToRes, _marketAmount)
                : null,
            icon: const Icon(Icons.swap_horiz),
            label: Text('Execute Merchant Trade ($received ${_marketToRes.toUpperCase()})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amberAccent),
        ),
        const SizedBox(height: 6),
        const Text(
          'Stores harvested crops from your realm. OCR: 5700 → 7400 (+1700/lvl).',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$level → Lv.${(level + 1).clamp(1, 20)}',
            'Crop Cap ${GameData.levelStats('barn', level.clamp(1, 20))['cropCap']} → ${GameData.levelStats('barn', (level + 1).clamp(1, 20))['cropCap']} (+1700/lvl)'),
        _levelTable('barn', ['cropCap']),
        const SizedBox(height: 8),

        _infoCard('Crop Storage', '${state.crop} / ${state.cropCapacity} (Level $level)', Icons.warehouse, Colors.amberAccent),
        const SizedBox(height: 16),

        const Text('Storage Capacity:', style: TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          minHeight: 12,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 6),
        Text('${(pct * 100).toInt()}% Full', style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2638),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Upgrade to Level ${level + 1} to increase crop capacity to ${state.cropCapacity + 3000}.',
            style: const TextStyle(fontSize: 12, color: Colors.amber),
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
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        _levelRow('Lv.$level → Lv.${(level + 1).clamp(1, 20)}',
            'Wood ${GameData.levelStats('warehouse', level.clamp(1, 20))['woodCap']} → ${GameData.levelStats('warehouse', (level + 1).clamp(1, 20))['woodCap']} · Stone same (+1700/lvl)'),
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
              child: _infoCard('Iron (chest)', '${state.iron}', Icons.construction, Colors.blueGrey),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('EXP Scroll (chest)', '${state.expScroll}', Icons.auto_stories, Colors.purpleAccent),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _infoCard('Scroll (chest)', '${state.scroll}', Icons.receipt_long, Colors.tealAccent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Nail (chest)', '${state.nail}', Icons.push_pin, Colors.redAccent),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2638),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Upgrade to Level ${level + 1} to increase material capacity to ${state.materialCapacity + 2500}.',
            style: const TextStyle(fontSize: 12, color: Colors.amber),
          ),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final capitalBuildings = state.capitalBuildings;

    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      body: Column(
              children: [
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
                              color: const Color(0xFF141926),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 2),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
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

  void _showNotBuiltDialog(BuildContext context, GameState state, String id, String name, String icon) {
    final req = state.capitalBuildRequirement(id);
    String? reqText;
    if (req != null) {
      reqText = state.capitalRequirementText(id);
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$name (Not built)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
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
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            if (reqText != null && reqText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Requires: $reqText',
                style: const TextStyle(fontSize: 13, color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Open the Build menu (hammer button, bottom right) to construct it.',
              style: TextStyle(fontSize: 12, color: Colors.amber),
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
          color: const Color(0xFF1E2638),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('MAX LEVEL (Lv.20)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
      );
    }
    final cost = GameData.upgradeCost(id, level + 1);
    final canAfford = state.hasResources(cost);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Upgrade → Lv.${level + 1}:\n🪵 ${cost['wood']} + 🪨 ${cost['stone']}',
              style: const TextStyle(fontSize: 12, color: Colors.white),
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
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
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
        final icon = b['icon'] as String;
        final level = buildings[id] ?? 0;
        if (level <= 0) {
          _showNotBuiltDialog(context, state, id, name, icon);
          return;
        }
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            titlePadding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            title: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$name (Lv. $level)',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.amber),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: SizedBox(
              width: 460,
              height: 520,
              child: Column(
                children: [
                  Expanded(child: _buildFacilityPopupContent(state, id, level)),
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
          backgroundColor: const Color(0xFF1A1F30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            existingGarrison != null
                ? 'Garrison at ($r, $c)'
                : 'Place Garrison at ($r, $c)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
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
      final troop = GameData.TROOPS.firstWhere((t) => t['id'] == troopId, orElse: () => {'name': troopId, 'icon': '❓'});

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(troop['icon'] as String, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(troop['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Count: $count', style: const TextStyle(fontSize: 14, color: Colors.white70)),
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
            icon: const Icon(Icons.swap_horiz, color: Colors.black),
            label: const Text('Move Garrison', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              state.recallCapitalGarrison(r, c);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text('Recall to Army', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
        ],
      );
    }

    void _showMoveGarrisonDialog(BuildContext context, GameState state, int fromR, int fromC) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F30),
          title: Text('Move Garrison from ($fromR, $fromC)', style: const TextStyle(color: Colors.amber)),
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
            Text('No troops available in main army.', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text('Train troops at Barracks first.', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
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
              const Text('Select troop type:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedTroopId,
                dropdownColor: const Color(0xFF1A1F30),
                style: const TextStyle(color: Colors.white),
                items: availableTroops.map((t) => DropdownMenuItem(
                  value: t['id'] as String,
                  child: Text('${t['icon']} ${t['name']} (Army: ${state.troops[t['id']] ?? 0})'),
                )).toList(),
                onChanged: (val) => setPromptState(() => selectedTroopId = val!),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: quantity > 5 ? () => setPromptState(() => quantity -= 5) : null,
                  ),
                  Text('$quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () => setPromptState(() => quantity += 5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Available in army: ${state.troops[selectedTroopId] ?? 0}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Place', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
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