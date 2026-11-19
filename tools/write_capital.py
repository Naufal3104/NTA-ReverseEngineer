content = '''import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../../data/game_data.dart';

class CapitalInteriorDialog extends StatefulWidget {
  const CapitalInteriorDialog({super.key});

  @override
  State<CapitalInteriorDialog> createState() => _CapitalInteriorDialogState();
}

class _CapitalInteriorDialogState extends State<CapitalInteriorDialog> {
  // Currently selected capital facility (default to Imperial Palace)
  String _selectedBuildingId = 'palace';

  // Market trade state
  String _marketFromRes = 'crop';
  String _marketToRes = 'stone';
  int _marketAmount = 100;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final capitalBuildings = state.capitalBuildings;

    return Dialog(
      backgroundColor: const Color(0xFF0F131D),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.amber, width: 2),
      ),
      child: Container(
        width: 1040,
        height: 720,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Header: Title, 2x2 Spatial Description & Quick Status Bar
            _buildHeader(state),
            const Divider(color: Colors.white24, height: 16),

            // Main Interior Body: Left 22x22 Spatial Grid vs Right Facility Console
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT: 22x22 Spatial Grid (4x plot area, 5-petak avenues, 9 citadel buildings)
                  _buildSpatialGridPanel(state, capitalBuildings),

                  const SizedBox(width: 16),
                  const VerticalDivider(color: Colors.white12, width: 1),
                  const SizedBox(width: 16),

                  // RIGHT: Active Facility Interactive Control Console
                  Expanded(
                    child: _buildFacilityConsole(state, capitalBuildings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeader(GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber),
              ),
              child: const Icon(Icons.fort, color: Colors.amber, size: 26),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Imperial Capital Citadel (2x2 Territory)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                Text(
                  'Interior 22x22 Grid (4x Plot Area) · 5 Petak Entrance Avenues · 9 Citadel Facilities',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),

        // Quick resource & army overview chips
        Row(
          children: [
            _headerChip('🌾', '${state.crop}/${state.cropCapacity}'),
            const SizedBox(width: 6),
            _headerChip('🪵', '${state.wood}/${state.materialCapacity}'),
            const SizedBox(width: 6),
            _headerChip('🪨', '${state.stone}/${state.materialCapacity}'),
            const SizedBox(width: 6),
            _headerChip('⚔️', '${state.iron}/${state.materialCapacity}'),
            const SizedBox(width: 6),
            _headerChip('🪙', '${state.gold}'),
            const SizedBox(width: 6),
            _headerChip('🛡️', '${state.troops.values.fold(0, (a, b) => a + b)}'),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Return to World Map',
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerChip(String icon, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2132),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        '$icon $val',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // --- LEFT PANEL: 22x22 SPATIAL INTERIOR GRID ---
  Widget _buildSpatialGridPanel(GameState state, Map<String, int> capitalBuildings) {
    return SizedBox(
      width: 480,
      child: Column(
        children: [
          // North Gate Banner (Distance 5 petak to central citadel court)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF182236),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.meeting_room, size: 14, color: Colors.greenAccent),
                SizedBox(width: 6),
                Text(
                  'North Gate (5 Petak Avenue to Citadel Center)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Middle row: West Gate indicator, 22x22 Grid, East Gate indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // West Gate Flag
              RotatedBox(
                quarterTurns: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF182236),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Text('West Gate (5 Petak)', style: TextStyle(fontSize: 9, color: Colors.greenAccent)),
                ),
              ),
              const SizedBox(width: 6),

              // 22x22 Interactive Grid (440x440 px, 20px per cell)
              Container(
                width: 440,
                height: 440,
                decoration: BoxDecoration(
                  color: const Color(0xFF141926),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 2),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(22, (r) {
                    return SizedBox(
                      height: 20,
                      child: Row(
                        children: List.generate(22, (c) {
                          return SizedBox(
                            width: 20,
                            height: 20,
                            child: _buildCell(r, c, capitalBuildings),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 6),

              // East Gate Flag
              RotatedBox(
                quarterTurns: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF182236),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Text('East Gate (5 Petak)', style: TextStyle(fontSize: 9, color: Colors.greenAccent)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // South Gate Banner (Distance 5 petak to central citadel court)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF182236),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.meeting_room, size: 14, color: Colors.greenAccent),
                SizedBox(width: 6),
                Text(
                  'South Gate (5 Petak Avenue to Citadel Center)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quick Selector Chips for 9 Facilities
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: GameData.CAPITAL_BUILDINGS.map((b) {
                final id = b['id'] as String;
                final isSelected = (_selectedBuildingId == id);
                final lvl = capitalBuildings[id] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('${b["icon"]} ${b["name"]} (Lv.$lvl)'),
                    selected: isSelected,
                    selectedColor: Colors.amber,
                    backgroundColor: const Color(0xFF1A2133),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedBuildingId = id);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildCell(int r, int c, Map<String, int> capitalBuildings) {
    // 1. Gates
    final bool isNorthGate = (r == 0 && (c == 10 || c == 11));
    final bool isSouthGate = (r == 21 && (c == 10 || c == 11));
    final bool isWestGate = ((r == 10 || r == 11) && c == 0);
    final bool isEastGate = ((r == 10 || r == 11) && c == 21);
    final bool isGate = isNorthGate || isSouthGate || isWestGate || isEastGate;

    // 2. 5-Petak Entrance Avenues (exact length: 5 cells to central court)
    final bool isNorthAvenue = (r >= 0 && r <= 4 && (c == 10 || c == 11));
    final bool isSouthAvenue = (r >= 17 && r <= 21 && (c == 10 || c == 11));
    final bool isWestAvenue = ((r == 10 || r == 11) && c >= 0 && c <= 4);
    final bool isEastAvenue = ((r == 10 || r == 11) && c >= 17 && c <= 21);
    final bool isAvenue = isNorthAvenue || isSouthAvenue || isWestAvenue || isEastAvenue;

    // 3. Central Citadel Court boundaries: rows 5..16, cols 5..16 (12x12 area)
    final bool inCourt = (r >= 5 && r <= 16 && c >= 5 && c <= 16);

    // 4. Fortified Citadel Wall / Bastion (outside court and not on entrance avenues)
    final bool isWall = !inCourt && !isAvenue && !isGate;

    // 5. Facility occupation
    final facility = _getFacilityAt(r, c);

    if (isGate) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF183D24),
          border: Border.all(color: Colors.greenAccent, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text('🚪', style: TextStyle(fontSize: 10)),
      );
    }

    if (isWall) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF171B26),
          border: Border.all(color: const Color(0xFF222838), width: 0.3),
        ),
        alignment: Alignment.center,
        child: const Text('🧱', style: TextStyle(fontSize: 9, color: Colors.white24)),
      );
    }

    if (facility != null) {
      final id = facility['id'] as String;
      final isSelected = (_selectedBuildingId == id);
      final br = facility['r'] as int;
      final bc = facility['c'] as int;
      final bw = facility['w'] as int;
      final bh = facility['h'] as int;

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
        onTap: () => setState(() => _selectedBuildingId = id),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? baseColor.withValues(alpha: 0.95) : baseColor.withValues(alpha: 0.7),
            border: Border.all(
              color: isSelected ? Colors.amberAccent : Colors.white24,
              width: isSelected ? 1.5 : 0.4,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: isCenterCell
              ? Text(
                  facility['icon'] as String,
                  style: TextStyle(
                    fontSize: (bw >= 3) ? 12 : 10,
                  ),
                )
              : null,
        ),
      );
    }

    // Paved Stone Road / Court Walkway
    return Container(
      decoration: BoxDecoration(
        color: inCourt ? const Color(0xFF252B3B) : const Color(0xFF333D52),
        border: Border.all(color: const Color(0xFF3A445C), width: 0.3),
      ),
      alignment: Alignment.center,
      child: isAvenue
          ? const Text('·', style: TextStyle(color: Colors.white38, fontSize: 14))
          : null,
    );
  }

  // --- RIGHT PANEL: ACTIVE FACILITY INTERACTIVE CONSOLE ---
  Widget _buildFacilityConsole(GameState state, Map<String, int> capitalBuildings) {
    final facility = GameData.CAPITAL_BUILDINGS.firstWhere(
      (b) => b['id'] == _selectedBuildingId,
      orElse: () => GameData.CAPITAL_BUILDINGS[0],
    );

    final id = facility['id'] as String;
    final name = facility['name'] as String;
    final level = capitalBuildings[id] ?? 0;
    final costMap = facility['cost'] as Map<String, dynamic>;
    final nextLvlCost = <String, int>{};
    for (var e in costMap.entries) {
      nextLvlCost[e.key] = (e.value as int) * (level + 1);
    }
    final canAfford = state.hasResources(nextLvlCost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Facility Header Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF192033),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252E47),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(facility['icon'] as String, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name (Lv. $level)',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                      Text(
                        'Citadel Facility · HP: ${facility["hp"]} · Footprint: ${facility["w"]}x${facility["h"]}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),

              // Upgrade Button
              ElevatedButton.icon(
                onPressed: canAfford ? () => state.upgradeCapitalBuilding(id) : null,
                icon: const Icon(Icons.arrow_upward, size: 16),
                label: Text('Upgrade Lv.${level + 1}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Upgrade Cost Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF151928),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Level Cost: ${nextLvlCost.entries.map((e) => "${e.value} ${e.key}").join(", ")}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: canAfford ? Colors.lightGreenAccent : Colors.redAccent,
                ),
              ),
              Text(
                canAfford ? '✓ Ready to Upgrade' : '✗ Insufficient Resources',
                style: TextStyle(
                  fontSize: 11,
                  color: canAfford ? Colors.lightGreenAccent : Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Dedicated Facility Functionality Views
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141926),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: _buildFacilityContent(state, id, level),
          ),
        ),
      ],
    );
  }

  // Route to the dedicated building interactive views
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

  // 1. PALACE: Seat of Power, Realm Command, Tribute & Tax
  Widget _buildPalaceView(GameState state, int level) {
    final maxTeams = (1 + (level * 0.5)).floor().clamp(1, 12);
    final rates = state.getHourlyProduction();

    return Column(
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
              child: _infoCard('Command Capacity', '$maxTeams / 12 Teams', Icons.groups, Colors.blueAccent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Conquered Plots', '${state.conqueredPlots.length} Plots', Icons.flag, Colors.greenAccent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoCard('Capital Citadel HP', '3000 / 3000', Icons.shield, Colors.amberAccent),
            ),
          ],
        ),
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
                  Text('⚔️ +${rates["iron"]!.toInt()}/h', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  Text('🪙 +${rates["gold"]!.toInt()}/h', style: const TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),

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
    );
  }

  // 2. BARRACKS: Soldier Training & Strict Advantage Wheel
  Widget _buildBarracksView(GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Barracks - Train Standing Army',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Counter: Spear > Cav > Shield > Bow > Spear', style: TextStyle(fontSize: 10, color: Colors.redAccent)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            itemCount: GameData.TROOPS.length,
            itemBuilder: (context, index) {
              final troop = GameData.TROOPS[index];
              final id = troop['id'] as String;
              final count = state.troops[id] ?? 0;
              final costMap = troop['cost'] as Map<String, dynamic>;

              return Card(
                color: const Color(0xFF1B2133),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                  title: Text('${troop["name"]} (x$count in Army)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    'ATK: ${troop["atk"]} | DEF: ${troop["def"]} | HP: ${troop["hp"]} | Advantage: ${troop["counter"]}\nCost: ${costMap.entries.map((e) => "${e.value} ${e.key}").join(", ")}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _recruitTroopPrompt(state, troop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Train', style: TextStyle(fontSize: 12)),
                  ),
                ),
              );
            },
          ),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: quantity > 5 ? () => setPromptState(() => quantity -= 5) : null,
                    ),
                    Text('$quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () => setPromptState(() => quantity += 5),
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

  // 3. SMITHY: Forging Equipment
  Widget _buildSmithyView(GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smithy - Forge Battlefield Gear',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: GameData.EQUIPMENT.length,
            itemBuilder: (context, index) {
              final eq = GameData.EQUIPMENT[index];
              final id = eq['id'] as String;
              final owned = state.equipment[id] ?? 0;
              final cost = eq['cost'] as Map<String, dynamic>;
              final costParsed = cost.map((k, v) => MapEntry(k, v as int));
              final canAfford = state.hasResources(costParsed);

              return Card(
                color: const Color(0xFF1B2133),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.shield, color: Colors.orangeAccent, size: 28),
                  title: Text('${eq["name"]} (Owned: $owned)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    'Effect: ${eq["effect"]}\nCost: ${costParsed.entries.map((e) => "${e.value} ${e.key}").join(", ")}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  trailing: ElevatedButton(
                    onPressed: canAfford ? () => state.craftEquipment(id) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Forge', style: TextStyle(fontSize: 12)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. HALL OF HEROES: Worship & Permanently Bind Generals
  Widget _buildHeroesView(GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hall of Heroes - Worship & Bind Legendary Generals',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
        ),
        const SizedBox(height: 4),
        const Text(
          'Notice: Once a hero is Worshipped, they are permanently bound to your campaign command.',
          style: TextStyle(fontSize: 11, color: Colors.amberAccent),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: GameData.HEROES.length,
            itemBuilder: (context, index) {
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
                    'ATK: ${hero["atk"]} | DEF: ${hero["def"]} | HP: ${hero["hp"]}\nSkill: ${hero["skill"]}',
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
            },
          ),
        ),
      ],
    );
  }

  // 5. DRILL GROUND: Elevate Troop Morale & Combat Potency
  Widget _buildDrillGroundView(GameState state) {
    final costCrop = 80 * state.drillLevel;
    final costWood = 50 * state.drillLevel;
    final canAfford = state.hasResources({'crop': costCrop, 'wood': costWood});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drill Ground - Elevate Army Potency',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent),
        ),
        const SizedBox(height: 6),
        const Text(
          'Conduct rigorous formation drills to permanently amplify your soldiers\' battle prowess and morale.',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 14),

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
        const Spacer(),

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
    );
  }

  // 6. CLINIC: Treat and Restore Wounded Soldiers
  Widget _buildClinicView(GameState state) {
    final wounded = state.woundedTroops;
    final clinicLvl = state.capitalBuildings['clinic'] ?? 1;
    final costCrop = math.max(10, (wounded * 4) ~/ clinicLvl);
    final canAfford = (state.crop >= costCrop && wounded > 0);

    return Column(
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
        const SizedBox(height: 14),

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
        const Spacer(),

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
    );
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
      {'id': 'iron', 'name': 'Iron', 'icon': '⚔️'},
      {'id': 'gold', 'name': 'Gold', 'icon': '🪙'},
    ];

    return Column(
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
          'Trade surplus commodities with traveling merchants to acquire vital materials.',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 12),

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
        const Spacer(),

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
    );
  }

  // 8. BARN: Granary Storage Facility
  Widget _buildBarnView(GameState state, int level) {
    final double pct = (state.crop / state.cropCapacity).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Barn - Imperial Granary',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amberAccent),
        ),
        const SizedBox(height: 6),
        const Text(
          'Stores harvested crops from your realm. Upgrading expands crop storage capacity by +3,000 per level.',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 16),

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
        const Spacer(),

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
    );
  }

  // 9. WAREHOUSE: Sturdy Materials Depot
  Widget _buildWarehouseView(GameState state, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Warehouse - Material Depot',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
        ),
        const SizedBox(height: 6),
        const Text(
          'Protects lumber, masonry stone, and iron reserves. Upgrading expands capacity by +3,000 per level.',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 16),

        _infoCard('Material Capacity', '${state.materialCapacity} per Resource (Level $level)', Icons.inventory_2, Colors.lightBlueAccent),
        const SizedBox(height: 14),

        _storageBar('Wood', state.wood, state.materialCapacity, Colors.brown),
        const SizedBox(height: 8),
        _storageBar('Stone', state.stone, state.materialCapacity, Colors.grey),
        const SizedBox(height: 8),
        _storageBar('Iron', state.iron, state.materialCapacity, Colors.blueGrey),
        const Spacer(),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2638),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Upgrade to Level ${level + 1} to increase storage cap to ${state.materialCapacity + 3000}.',
            style: const TextStyle(fontSize: 12, color: Colors.lightBlueAccent),
          ),
        ),
      ],
    );
  }

  Widget _storageBar(String label, int current, int max, Color col) {
    final double pct = (current / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
            Text('$current / $max', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: pct,
          minHeight: 8,
          backgroundColor: Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(col),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _infoCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2336),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
'''

with open('nta_demo/lib/game/components/capital_interior_view.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
