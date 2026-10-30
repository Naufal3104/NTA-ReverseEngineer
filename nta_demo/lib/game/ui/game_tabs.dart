import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../../data/game_data.dart';

class GameTabs extends StatelessWidget {
  const GameTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(Icons.fort), text: 'Citadel'),
              Tab(icon: Icon(Icons.military_tech), text: 'Barracks'),
              Tab(icon: Icon(Icons.hardware), text: 'Smithy'),
              Tab(icon: Icon(Icons.auto_awesome), text: 'Heroes'),
              Tab(icon: Icon(Icons.sports_kabaddi), text: 'Expedition'),
              Tab(icon: Icon(Icons.history), text: 'Log'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _CitadelTab(),
                _BarracksTab(),
                _SmithyTab(),
                _HeroesTab(),
                _ExpeditionTab(),
                _LogTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 1. CITADEL TAB: CAPITAL BUILDINGS MANAGEMENT ---
class _CitadelTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final capitalBuildings = state.capitalBuildings;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: const Color(0xFF20263A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Capital Citadel (2x2 Space)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber)),
                  Text('Only 1 Capital exists. All core facilities built here.', style: TextStyle(fontSize: 11, color: Colors.white60)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => context.read<GameState>().switchView('capital'),
                icon: const Icon(Icons.meeting_room, size: 16),
                label: const Text('Interior View'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: GameData.BUILDINGS.length,
            itemBuilder: (context, index) {
              final building = GameData.BUILDINGS[index];
              final id = building['id'] as String;
              final level = capitalBuildings[id] ?? 0;
              final nextLvlCost = GameData.upgradeCost(id, level + 1);
              final canAfford = state.hasResources(nextLvlCost);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: const Color(0xFF1F2436),
                child: ListTile(
                  leading: const Icon(Icons.castle, color: Colors.amber),
                  title: Text('${building['name']} (Level $level)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(building['desc'] as String? ?? '', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: nextLvlCost.entries.map((e) {
                          return Chip(
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                            label: Text('${e.value} ${_resIcon(e.key)}', style: const TextStyle(fontSize: 10)),
                            backgroundColor: state.hasResources({e.key: e.value})
                                ? Colors.black45
                                : Colors.red.withValues(alpha: 0.25),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: canAfford ? () => state.upgradeCapitalBuilding(id) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Upgrade'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _resIcon(String resource) {
    switch (resource) {
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

// --- 2. BARRACKS TAB: RECRUIT TROOPS ---
class _BarracksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFF2C1E20),
          child: const Text(
            'Barracks Training: Spearman > Cavalry > Shieldman > Bowman > Spearman (+40% DMG)',
            style: TextStyle(fontSize: 11, color: Colors.amberAccent),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: GameData.TROOPS.length,
            itemBuilder: (context, index) {
              final troop = GameData.TROOPS[index];
              final id = troop['id'] as String;
              final owned = state.troops[id] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: const Color(0xFF1E2335),
                child: ListTile(
                  leading: const Icon(Icons.shield, color: Colors.redAccent),
                  title: Text('${troop['name']} (x$owned Standing)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ATK: ${troop['atk']}  |  DEF: ${troop['def']}  |  HP: ${troop['hp']}',
                          style: const TextStyle(fontSize: 11, color: Colors.white60)),
                      Text('Advantage: ${troop['advantage']}',
                          style: const TextStyle(fontSize: 10, color: Colors.lightGreenAccent)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _showRecruitDialog(context, troop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Train'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRecruitDialog(BuildContext context, Map<String, dynamic> troop) {
    final state = context.read<GameState>();
    int count = 10;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final costMap = troop['cost'] as Map<String, dynamic>;
          final totalCost = <String, int>{};
          for (var entry in costMap.entries) {
            totalCost[entry.key] = (entry.value as int) * count;
          }
          final canAfford = state.hasResources(totalCost);

          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F30),
            title: Text('Train ${troop['name']} in Barracks'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: count > 5 ? () => setDialogState(() => count -= 5) : null,
                    ),
                    Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () => setDialogState(() => count += 5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Cost: ${totalCost.entries.map((e) => "${e.value} ${_CitadelTab._resIcon(e.key)}").join(' ')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canAfford ? Colors.lightGreenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: canAfford
                    ? () {
                        state.trainTroops(troop['id'] as String, count);
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
}

// --- 3. SMITHY TAB: FORGE EQUIPMENT (tier-gated) ---
class _SmithyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final smithyLvl = state.capitalBuildings['smithy'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Smithy Lv.$smithyLvl — Common Lv.1/3/5/7/12/14 · Exclusive Lv.10 · Smelt Lv.10',
            style: const TextStyle(fontSize: 11, color: Colors.amberAccent),
          ),
        ),
        for (final eq in GameData.EQUIPMENT)
          _smithyCard(context, state, eq, smithyLvl, false),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Exclusive gear (Smithy Lv.10)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
        ),
        for (final eq in GameData.EXCLUSIVE_EQUIPMENT)
          _smithyCard(context, state, eq, smithyLvl, true),
      ],
    );
  }

  Widget _smithyCard(BuildContext context, GameState state, Map<String, dynamic> eq, int smithyLvl, bool exclusive) {
    final id = eq['id'] as String;
    final tier = (eq['tier'] as int?) ?? 1;
    final locked = smithyLvl < tier;
    final owned = exclusive ? (state.exclusiveEquipment[id] != null ? 1 : 0) : (state.equipment[id] ?? 0);
    final cost = eq['cost'] as Map<String, dynamic>;
    final costParsed = cost.map((k, v) => MapEntry(k, v as int));
    final canAfford = !locked && state.hasResources(costParsed) && (!exclusive || owned == 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF1E2335),
      child: ListTile(
        leading: Icon(exclusive ? Icons.stars : Icons.hardware, color: exclusive ? Colors.purpleAccent : Colors.orangeAccent),
        title: Text('${eq['name']} (x$owned)${locked ? " 🔒Lv.$tier" : ""}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(
          exclusive
              ? 'Exclusive +${eq['hp']} HP / +${eq['atk']} ATK | Skill: ${eq['skillMod']}'
              : 'Roll ${eq['roll']} | Effect: ${eq['effect']}',
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
        trailing: ElevatedButton(
          onPressed: canAfford ? () => state.craftEquipment(id) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: exclusive ? Colors.purpleAccent : Colors.orangeAccent,
            foregroundColor: Colors.black,
          ),
          child: const Text('Forge'),
        ),
      ),
    );
  }
}

// --- 4. HEROES TAB: WORSHIP HEROES (PERMANENT BINDING) ---
class _HeroesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: GameData.HEROES.length,
      itemBuilder: (context, index) {
        final hero = GameData.HEROES[index];
        final id = hero['id'] as String;
        final isWorshipped = state.worshippedHeroes.contains(id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: const Color(0xFF1E2335),
          child: ListTile(
            leading: Icon(
              isWorshipped ? Icons.stars : Icons.person_outline,
              color: isWorshipped ? Colors.amber : Colors.grey,
              size: 32,
            ),
            title: Text(
              hero['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWorshipped ? Colors.amber : Colors.white70,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ATK: ${hero['atk']} | DEF: ${hero['def']} | HP: ${hero['hp']}',
                    style: const TextStyle(fontSize: 11, color: Colors.white60)),
                Text('Skill: ${hero['skill']}',
                    style: const TextStyle(fontSize: 11, color: Colors.lightBlueAccent)),
              ],
            ),
            trailing: isWorshipped
                ? const Chip(
                    label: Text('WORSHIPPED', style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.black38,
                  )
                : ElevatedButton(
                    onPressed: () => state.worshipHero(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Worship'),
                  ),
          ),
        );
      },
    );
  }
}

// --- 5. EXPEDITION TAB: BATTLE STATUS & SURROUNDING PLOTS ---
class _ExpeditionTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final selectedTile = state.selectedTile;

    int totalTroops = 0;
    for (var count in state.troops.values) {
      totalTroops += count;
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Army overview
        Card(
          color: const Color(0xFF1B2238),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.military_tech, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Expeditionary Force', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Active Standing Army: $totalTroops soldiers', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  children: state.troops.entries.map((e) => Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 11, color: Colors.white60))).toList(),
                ),
                const SizedBox(height: 4),
                Text('Active Worshipped Heroes: ${state.worshippedHeroes.length}', style: const TextStyle(fontSize: 11, color: Colors.amberAccent)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Selected plot action
        if (selectedTile != null) ...[
          Card(
            color: const Color(0xFF242238),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Target: (${selectedTile[0]}, ${selectedTile[1]})',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.isTileConquered(selectedTile[0], selectedTile[1])
                        ? 'Status: Secured territory with Watchtower and Player Flag.'
                        : 'Status: Unconquered Hostile Plot. Can launch automated turn assault.',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.read<GameState>().setPlotView(selectedTile[0], selectedTile[1]),
                    icon: const Icon(Icons.grid_view),
                    label: const Text('Open 11x11 Plot Interior View'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          const Card(
            color: Color(0xFF1E2130),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Tap any tile on the world map to inspect its 11x11 inner grid and launch automated turn-based assaults.',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// --- 6. LOG TAB ---
class _LogTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.log.length,
      reverse: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            state.log[state.log.length - 1 - index],
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        );
      },
    );
  }
}
