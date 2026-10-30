import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game/models/game_state.dart';
import 'game/components/viewport.dart' show GameViewport;
import 'data/game_data.dart';

void main() {
  runApp(const NTAdemo());
}

class NTAdemo extends StatelessWidget {
  const NTAdemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()..generateMap(),
      child: MaterialApp(
        title: 'Ninety Thousand Acres - Reconstructed Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.amber,
          scaffoldBackgroundColor: const Color(0xFF0F141C),
          colorScheme: const ColorScheme.dark(
            primary: Colors.amber,
            secondary: Colors.blueAccent,
            surface: Color(0xFF1B2132),
          ),
        ),
        home: const GameScreen(),
      ),
    );
  }
}

// Building List popup (mirrors original game: costs, build time, requirement, Build button)
class BuildingListModal extends StatelessWidget {
  final GameState state;
  final VoidCallback onClose;

  const BuildingListModal({
    super.key,
    required this.state,
    required this.onClose,
  });

  String _formatBuildTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00';
  }

  String _resIcon(String res) {
    switch (res) {
      case 'crop':
        return '🌾';
      case 'wood':
        return '🪵';
      case 'stone':
        return '🪨';
      case 'iron':
        return '⚙️';
      case 'exp_scroll':
        return '📜';
      case 'scroll':
        return '🧾';
      case 'nail':
        return '🔩';
      default:
        return '📦'; // specials keep own icons in resIconExt
    }
  }

  // Chest-only special icons (unused alias, kept for dialog lookups).
  // ignore: unused_element
  String _resIconExt(String res) {
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

  @override
  Widget build(BuildContext context) {
    final buildings = GameData.CAPITAL_BUILDINGS;
    final levels = state.capitalBuildings;

    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Color(0xFFF5E9D2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.brown.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Building List',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF4A2F1D)),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: buildings.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (ctx, i) {
                  final b = buildings[i];
                  final id = b['id'] as String;
                  final level = levels[id] ?? 0;
                  final built = level > 0;
                  final cost = GameData.upgradeCost(id, 1);
                  final time = b['buildTime'] as int? ?? 0;
                  final req = state.capitalBuildRequirement(id);
                  String? reqName;
                  int reqLvl = 1;
                  if (req != null) {
                    reqLvl = req['level'] as int? ?? 1;
                    final reqId = req['id'] as String;
                    reqName = (GameData.CAPITAL_BUILDINGS.firstWhere(
                      (e) => e['id'] == reqId,
                      orElse: () => {'name': reqId},
                    )['name']) as String;
                  }
                  final reqMet = state.capitalRequirementMet(id);
                  final afford = state.hasResources(cost);
                  final canBuild = !built && reqMet && afford;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8EC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.brown.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(b['icon'] as String, style: const TextStyle(fontSize: 30)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b['name'] as String,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A2F1D)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                b['desc'] as String? ?? '',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF6B4A2F)),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Construction Costs:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A2F1D)),
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 10,
                                runSpacing: 2,
                                children: [
                                  for (var e in cost.entries)
                                    Text(
                                      '${_resIcon(e.key)} ${e.value}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF4A2F1D)),
                                    ),
                                  Text('⏱ ${_formatBuildTime(time)}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF4A2F1D))),
                                ],
                              ),
                              if (reqName != null) ...[
                                const SizedBox(height: 4),
                                const Text(
                                  'Construction Requirement:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A2F1D)),
                                ),
                                Text(
                                  '$reqName Lv.$reqLvl',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: reqMet ? const Color(0xFF4A2F1D) : Colors.red,
                                    fontWeight: reqMet ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                              ],
                              if (built)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('Already built', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                                )
                              else if (!reqMet)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Requires $reqName Lv.$reqLvl',
                                      style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                                )
                              else if (!afford)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('Insufficient resources', style: TextStyle(fontSize: 12, color: Colors.red)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: canBuild
                              ? () {
                                  final ok = state.constructCapitalBuilding(id);
                                  if (ok && context.mounted) Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1E4C8),
                            foregroundColor: Colors.black87,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: Text(built ? 'Built' : 'Build', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simplified tab-like structure for facility access - now just a modal/popup from the grid
class FacilityAccessModal extends StatelessWidget {
  final GameState state;
  final VoidCallback onClose;
  final Map<String, int> capitalBuildings;

  const FacilityAccessModal({
    super.key,
    required this.state,
    required this.onClose,
    required this.capitalBuildings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Citadel Facilities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...GameData.BUILDINGS.map((building) {
            final id = building['id'] as String;
            final level = capitalBuildings[id] ?? 0;
            return ListTile(
              dense: true,
              leading: Text(building['icon'] as String, style: const TextStyle(fontSize: 24)),
              title: Text('${building['name']} (Lv. $level)', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(building['desc'] as String? ?? '', style: const TextStyle(fontSize: 11, color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to the facility popup in capital interior view
                state.switchView('capital');
                // The capital interior view will show the facility popup
              },
            );
          }),
        ],
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final isMap = state.currentView == 'map';

    return Scaffold(
      body: Stack(
        children: [
          // Main game map viewport
          const GameViewport(),

          // Top-left resource panel
          Positioned(
            top: 8,
            left: 8,
            child: _ResourcePanel(),
          ),

          // Top-right coins & time panel
          Positioned(
            top: 8,
            right: 8,
            child: _TopRightPanel(),
          ),

          // Bottom-left action buttons
          Positioned(
            bottom: 16,
            left: 16,
            child: _BottomLeftPanel(),
          ),

          // Bottom-right action buttons
          Positioned(
            bottom: 16,
            right: 16,
            child: _BottomRightPanel(),
          ),
        ],
      ),
    );
  }
}

// Top-left vertical resource panel
class _ResourcePanel extends StatelessWidget {
  const _ResourcePanel();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final rates = state.getHourlyProduction();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xCC0A0E14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x44FFFFFF), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _resourceRow('🌾 Crop', state.crop, rates['crop'] ?? 0, Colors.orange),
          const SizedBox(height: 4),
          _resourceRow('🪵 Wood', state.wood, rates['wood'] ?? 0, const Color(0xFF8B6914)),
          const SizedBox(height: 4),
          _resourceRow('🪨 Stone', state.stone, rates['stone'] ?? 0, Colors.grey),
          const Divider(height: 10, color: Color(0x33FFFFFF)),
          // Specials (chest-only, no hourly production)
          _resourceRow('⚙️ Iron', state.iron, 0, Colors.blueGrey, showRate: false),
          const SizedBox(height: 4),
          _resourceRow('📜 EXP Scroll', state.expScroll, 0, Colors.purpleAccent, showRate: false),
          const SizedBox(height: 4),
          _resourceRow('🧾 Scroll', state.scroll, 0, Colors.tealAccent, showRate: false),
          const SizedBox(height: 4),
          _resourceRow('🔩 Nail', state.nail, 0, Colors.redAccent, showRate: false),
        ],
      ),
    );
  }

  Widget _resourceRow(String label, int value, double rate, Color color, {bool showRate = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (value / 5000).clamp(0.0, 1.0),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              const SizedBox(height: 2),
              Text(
                showRate ? '$value (+${rate.round()}/h)' : '$value (chest)',
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Top-right panel: coins, reward points, season/time
class _TopRightPanel extends StatelessWidget {
  const _TopRightPanel();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    final seasonIcons = {
      'Spring': '🌱',
      'Summer': '☀️',
      'Autumn': '🍂',
      'Winter': '❄️',
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xCC0A0E14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x44FFFFFF), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coin & reward points
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _currencyItem('🪙 Coin', 180, Colors.amber),
              const SizedBox(width: 12),
              _currencyItem('🎁 Reward Pts', 250, Colors.purple),
            ],
          ),
          const SizedBox(height: 8),
          // Season & time
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(seasonIcons[state.season] ?? '🌱', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '${state.season} Day ${state.dayInSeason}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              _TimeDisplay(seconds: state.elapsedSeconds),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currencyItem(String label, int value, Color color) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        const SizedBox(width: 4),
        Text('$value', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Real-time clock display
class _TimeDisplay extends StatefulWidget {
  final int seconds;
  const _TimeDisplay({required this.seconds});

  @override
  State<_TimeDisplay> createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<_TimeDisplay> {
  int _displaySeconds = 0;

  @override
  void didUpdateWidget(covariant _TimeDisplay oldWidget) {
    if (widget.seconds != _displaySeconds) {
      setState(() => _displaySeconds = widget.seconds);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final hours = (_displaySeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_displaySeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (_displaySeconds % 60).toString().padLeft(2, '0');
    return Text(
      '$hours:$minutes:$secs',
      style: const TextStyle(fontFamily: 'monospace', color: Colors.white70, fontSize: 11),
    );
  }
}

// Bottom-left: Context-aware buttons
// Map view: Message (top), Capital shortcut (bottom/corner)
// Capital/Plot view: Message (top), Back to Map (bottom/corner)
class _BottomLeftPanel extends StatelessWidget {
  const _BottomLeftPanel();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final isInCapitalOrPlot = state.currentView == 'capital' || state.currentView == 'plot';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Message button (always top)
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: 'Message',
          color: Colors.blue,
          onPressed: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messages coming soon!'), duration: Duration(seconds: 2)),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        // Context-aware bottom button
        _ActionButton(
          icon: isInCapitalOrPlot ? Icons.map : Icons.fort,
          label: isInCapitalOrPlot ? 'Back' : 'Capital',
          color: isInCapitalOrPlot ? Colors.blue : Colors.amber,
          onPressed: isInCapitalOrPlot
              ? () => state.goToMap()
              : () => state.switchView('capital'),
        ),
      ],
    );
  }
}

// Bottom-right: Context-aware buttons
// Map view: Lucky Spin, Shop, Map, Troops (horizontal, Troops at far right)
// Capital/Plot view: Quest Info, Build, Facility Access, Troops (this plot only), (no eye icon)
class _BottomRightPanel extends StatelessWidget {
  const _BottomRightPanel();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final isInCapitalOrPlot = state.currentView == 'capital' || state.currentView == 'plot';

    if (isInCapitalOrPlot) {
      // Inside capital/plot: Quest, Build, Facility Access, Troops (horizontal)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quest/Reward Info button
          _ActionButton(
            icon: Icons.assignment,
            label: 'Quest',
            color: Colors.cyan,
            onPressed: () {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quest info coming soon!'), duration: Duration(seconds: 2)),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          // Building selection button
          _ActionButton(
            icon: Icons.construction,
            label: 'Build',
            color: Colors.orange,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (ctx) => BuildingListModal(
                  state: state,
                  onClose: () => Navigator.pop(ctx),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Facility Access button (replaces the old facility quick access navbar)
          _ActionButton(
            icon: Icons.fort,
            label: 'Facility',
            color: Colors.amber,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1A1F30),
                isScrollControlled: true,
                builder: (ctx) => FacilityAccessModal(
                  state: state,
                  onClose: () => Navigator.pop(ctx),
                  capitalBuildings: state.capitalBuildings,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Troops in this capital/plot only
          _ActionButton(
            icon: Icons.person_outline,
            label: 'Troops',
            color: Colors.red,
            badge: _getGarrisonCount(state),
            onPressed: () {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Garrison management coming soon!'), duration: Duration(seconds: 2)),
                );
              }
            },
          ),
        ],
      );
    }

    // Map view: Lucky Spin, Shop, Map, Troops
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lucky Spin (far left)
        _ActionButton(
          icon: Icons.casino,
          label: 'Spin',
          color: Colors.orange,
          onPressed: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lucky Spin coming soon!'), duration: Duration(seconds: 2)),
              );
            }
          },
        ),
        const SizedBox(width: 8),
        // Shop
        _ActionButton(
          icon: Icons.store,
          label: 'Shop',
          color: Colors.purple,
          onPressed: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shop coming soon!'), duration: Duration(seconds: 2)),
              );
            }
          },
        ),
        const SizedBox(width: 8),
        // Map zoom button
        _ActionButton(
          icon: Icons.map,
          label: 'Map',
          color: Colors.green,
          onPressed: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('World map coming soon!'), duration: Duration(seconds: 2)),
              );
            }
          },
        ),
        const SizedBox(width: 8),
        // Troop list button (far right - corner)
        _ActionButton(
          icon: Icons.person_outline,
          label: 'Troops',
          color: Colors.red,
          badge: state.troops.values.fold<int>(0, (a, b) => a + b),
          onPressed: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Troop management coming soon!'), duration: Duration(seconds: 2)),
              );
            }
          },
        ),
      ],
    );
  }

  int _getGarrisonCount(GameState state) {
    // For now return total troops - will be replaced with garrison-specific count
    return state.troops.values.fold<int>(0, (a, b) => a + b);
  }
}

// Generic action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final int? badge;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xDD1A1F2B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 28),
            onPressed: onPressed,
            tooltip: label,
          ),
        ),
        if (badge != null && badge! > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$badge',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
