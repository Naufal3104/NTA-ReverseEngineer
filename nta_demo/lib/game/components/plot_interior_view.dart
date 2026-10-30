import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';

class PlotInteriorView extends StatefulWidget {
  final int row;
  final int col;

  const PlotInteriorView({
    super.key,
    required this.row,
    required this.col,
  });

  @override
  State<PlotInteriorView> createState() => _PlotInteriorViewState();
}

class _PlotInteriorViewState extends State<PlotInteriorView> {
  bool _isBattling = false;
  Map<String, dynamic>? _battleResult;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final isConquered = state.isTileConquered(widget.row, widget.col);
    final plotData = state.getPlotData(widget.row, widget.col);
    final plotLvl = plotData?['level'] as int? ?? 1;
    final resType = plotData?['resource'] as String? ?? 'crop';
    final garrisonName = plotData?['garrisonName'] as String? ?? 'Wild Wolf Pack';
    final difficulty = plotData?['difficulty'] as String? ?? 'Easy 1';

    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      body: SafeArea(
        child: Column(
          children: [
            // Title Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141824),
                border: Border(bottom: BorderSide(
                  color: isConquered ? Colors.amber : Colors.redAccent.withValues(alpha: 0.6),
                  width: 2,
                )),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isConquered ? Icons.flag : Icons.crisis_alert,
                        color: isConquered ? Colors.amber : Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Plot Interior (${widget.row}, ${widget.col})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isConquered
                          ? Colors.green.withValues(alpha: 0.25)
                          : Colors.red.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isConquered ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    child: Text(
                      isConquered ? 'Controlled Territory' : 'Hostile Plot (Lv. $plotLvl)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isConquered ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Metadata banner
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2438),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoBadge('Resource', '${_resIcon(resType)} ${resType.toUpperCase()} (+${plotLvl * 25}/h basics)'),
                  _infoBadge('Terrain', state.getTileTerrainName(widget.row, widget.col)),
                  _infoBadge('Status', isConquered ? 'Secured (Watchtower & Flag)' : '$garrisonName [$difficulty]'),
                ],
              ),
            ),

            // Ground Building Development Card (Only on conquered world plots)
            if (isConquered) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildGroundBuildingCard(state, resType),
              ),
            ],

            // 11x11 Grid View - Center is (5,5), Gates at (0,5), (10,5), (5,0), (5,10) - 5 tiles from center
            Expanded(
              child: Center(
                child: Container(
                  width: 330,
                  height: 330,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF263820),
                    border: Border.all(color: Colors.white24, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
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
                ),
              ),
            ),

            // Battle simulation result or action prompt
            if (_battleResult != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildBattleSummary(_battleResult!),
              ),
            ],

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isConquered)
                    ElevatedButton.icon(
                      onPressed: _isBattling ? null : () => _executeAssault(context),
                      icon: const Icon(Icons.sports_kabaddi),
                      label: Text(_isBattling ? 'Engaging Enemy...' : 'Assault Plot (Automated Turns)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Secured with Watchtower'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
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

  Widget _buildGroundBuildingCard(GameState state, String resType) {
    final building = state.getGroundBuilding(widget.row, widget.col);
    final String targetType = (resType == 'wood')
        ? 'sawmill'
        : (resType == 'stone' || resType == 'iron')
            ? 'quarry'
            : 'farm';

    final bDef = (targetType == 'sawmill')
        ? {'name': 'Sawmill', 'icon': '🪵', 'yield': '+45 Wood/h', 'cost': {'wood': 100, 'stone': 40}}
        : (targetType == 'quarry')
            ? {'name': 'Quarry', 'icon': '🪨', 'yield': '+35 Stone/h', 'cost': {'wood': 110, 'stone': 50}}
            : {'name': 'Farm', 'icon': '🌾', 'yield': '+60 Crop/h', 'cost': {'wood': 80, 'crop': 40}};

    if (building != null) {
      final lvl = building['level'] as int? ?? 1;
      final costMap = bDef['cost'] as Map<String, int>;
      final nextCost = <String, int>{};
      for (var e in costMap.entries) {
        nextCost[e.key] = e.value * (lvl + 1);
      }
      final canAfford = state.hasResources(nextCost);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(bDef['icon'] as String, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ground Facility: ${bDef['name']} (Level $lvl)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.greenAccent),
                    ),
                    Text(
                      'Resource Output: ${bDef['yield']} · Level $lvl',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: canAfford ? () => state.upgradeGroundBuilding(widget.row, widget.col) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text('Upgrade to Lv.${lvl + 1}'),
            ),
          ],
        ),
      );
    }

    final costMap = bDef['cost'] as Map<String, int>;
    final canAfford = state.hasResources(costMap);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF24221A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(bDef['icon'] as String, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Facility: ${bDef['name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                  ),
                  Text(
                    'Construct on this conquered plot to produce ${bDef['yield']}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: canAfford ? () => state.constructGroundBuilding(widget.row, widget.col) : null,
            icon: const Icon(Icons.build, size: 14),
            label: Text('Construct ${bDef['name']}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

    // Ground building slot on conquered plot (rendered at r: 3, c: 3)
    final groundB = isConquered ? state.getGroundBuilding(widget.row, widget.col) : null;
    final bool isGroundBuildingCell = (r == 3 && c == 3 && groundB != null);

    if (isGroundBuildingCell) {
      final bType = groundB['type'] as String? ?? 'farm';
      final bIcon = (bType == 'sawmill') ? '🪵' : (bType == 'quarry') ? '🪨' : '🌾';
      final bLvl = groundB['level'] as int? ?? 1;

      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A1A),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.greenAccent, width: 1.5),
        ),
        child: Center(
          child: Text(
            '$bIcon$bLvl',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Center contains Watchtower / Flag (if conquered) or Hostile Garrison
    if (isCenter) {
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isConquered ? const Color(0xFF8B6B10) : const Color(0xFF6B1818),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isConquered ? Colors.amber : Colors.red, width: 1.5),
        ),
        child: Center(
          child: Icon(
            isConquered ? Icons.tour : Icons.pest_control_rodent,
            size: 16,
            color: isConquered ? Colors.amberAccent : Colors.redAccent,
          ),
        ),
      );
    }

    // Four gates: exactly 5 petak from center
    if (isNorthGate || isSouthGate || isWestGate || isEastGate) {
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3828),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.amberAccent, width: 1),
        ),
        child: const Center(
          child: Icon(Icons.meeting_room, size: 12, color: Colors.amberAccent),
        ),
      );
    }

    // Road pathway connecting gates to center (5 tiles each way)
    if (isRoad) {
      return Container(
        margin: const EdgeInsets.all(0.5),
        color: const Color(0xFF483D2D),
        child: Center(
          child: Text(
            '·',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10),
          ),
        ),
      );
    }

    // Normal field tiles inside 11x11 square
    return Container(
      margin: const EdgeInsets.all(0.5),
      color: ((r + c) % 2 == 0) ? const Color(0xFF2E4823) : const Color(0xFF263C1E),
    );
  }

  Widget _infoBadge(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildBattleSummary(Map<String, dynamic> res) {
    final bool victory = res['victory'] == true;
    final rounds = (res['rounds'] as List<dynamic>?) ?? [];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: victory ? const Color(0xFF132F1A) : const Color(0xFF381414),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: victory ? Colors.greenAccent : Colors.redAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(victory ? Icons.military_tech : Icons.dangerous, color: victory ? Colors.greenAccent : Colors.redAccent),
              const SizedBox(width: 8),
              Text(
                victory ? 'Automated Battle Won!' : 'Defeat in Battle!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: victory ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Target: ${res['enemyName']} (Level ${res['plotLevel']}) - Completed in ${rounds.length} Turn Rounds.',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          ...rounds.map((rd) {
            return Text(
              'Turn ${rd['round']}: Army strikes for ${rd['dmgDealt']} DMG. Enemy counter: ${rd['dmgTaken']} DMG.',
              style: const TextStyle(fontSize: 11, color: Colors.white60),
            );
          }),
        ],
      ),
    );
  }

  void _executeAssault(BuildContext context) {
    setState(() => _isBattling = true);

    final state = context.read<GameState>();
    final result = state.attackPlot(widget.row, widget.col);

    setState(() {
      _isBattling = false;
      _battleResult = result;
    });
  }

  static String _resIcon(String res) {
    switch (res) {
      case 'crop': return '🌾';
      case 'wood': return '🪵';
      case 'stone': return '🪨';
      case 'iron': return '⚙️';
      case 'exp_scroll': return '📜';
      case 'scroll': return '🧾';
      case 'nail': return '🔩';
      default: return '📦';
    }
  }
}