import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game/models/game_state.dart';
import 'game/components/viewport.dart' show GameViewport;
import 'game/ui/asset_manager.dart';
import 'game/ui/design_tokens.dart';
import 'data/game_data.dart';

void main() {
  runApp(const NTAdemo());
}

class NTAdemo extends StatelessWidget {
  const NTAdemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Ninety Thousand Acres - Reconstructed Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: NtaColors.accent,
          scaffoldBackgroundColor: NtaColors.surface,
          dialogTheme: const DialogThemeData(backgroundColor: NtaColors.surface),
          colorScheme: const ColorScheme.light(
            primary: NtaColors.accent,
            onPrimary: NtaColors.onAccent,
            secondary: NtaColors.heroTeal,
            onSecondary: NtaColors.textOnDark,
            surface: NtaColors.surface,
            onSurface: NtaColors.text,
            error: NtaColors.danger,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: NtaColors.text),
            bodySmall: TextStyle(color: NtaColors.textMuted),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: NtaColors.toastBg,
            contentTextStyle: TextStyle(color: NtaColors.toastText),
            behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    final buildings = GameData.CAPITAL_BUILDINGS;
    final levels = state.capitalBuildings;

    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: ntaPanel().copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: NtaColors.panelBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            Text('Building List', style: NtaText.title),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: buildings.length,
                separatorBuilder: (_, separatorIndex) => const Divider(height: 12),
                itemBuilder: (ctx, i) {
                  final b = buildings[i];
                  final id = b['id'] as String;
                  final level = levels[id] ?? 0;
                  final built = level > 0;
                  final cost = GameData.upgradeCost(id, 1);
                  final time = GameData.upgradeTime(id, 1);
                  final reqText = state.capitalRequirementText(id);
                  final hasReq = reqText.isNotEmpty;
                  final reqMet = state.capitalRequirementMet(id);
                  final afford = state.hasResources(cost);
                  final canBuild = !built && reqMet && afford;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: ntaCard(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: NtaColors.surfaceSunk,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            ntaBuildingIcon(b['id'] as String),
                            size: 26,
                            color: NtaColors.text,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b['name'] as String,
                                style: NtaText.body.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                b['desc'] as String? ?? '',
                                style: NtaText.caption,
                              ),
                              const SizedBox(height: 6),
                              Text('Construction Costs:', style: NtaText.body.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 10,
                                runSpacing: 2,
                                children: [
                                  for (var e in cost.entries)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        NtaResIcon(e.key, size: 13),
                                        const SizedBox(width: 3),
                                        Text('${e.value}', style: NtaText.body),
                                      ],
                                    ),
                                  Text('⏱ ${_formatBuildTime(time)}', style: NtaText.body),
                                ],
                              ),
                              if (hasReq) ...[
                                const SizedBox(height: 4),
                                Text('Construction Requirement:', style: NtaText.body.copyWith(fontWeight: FontWeight.bold)),
                                Text(
                                  reqText,
                                  style: NtaText.body.copyWith(
                                    color: reqMet ? NtaColors.text : NtaColors.danger,
                                    fontWeight: reqMet ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                              ],
                              if (built)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Already built', style: NtaText.body.copyWith(color: NtaColors.success, fontWeight: FontWeight.bold)),
                                )
                              else if (!reqMet)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Requires $reqText', style: NtaText.body.copyWith(color: NtaColors.danger, fontWeight: FontWeight.bold)),
                                )
                              else if (!afford)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Insufficient resources', style: NtaText.body.copyWith(color: NtaColors.danger)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (canBuild)
                          ntaGoldButton(
                            'Build',
                            onTap: () {
                              final ok = state.constructCapitalBuilding(id);
                              if (ok && context.mounted) Navigator.pop(context);
                            },
                            fontSize: 14,
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: NtaColors.disabled,
                              borderRadius: BorderRadius.circular(NtaRadius.button),
                            ),
                            child: Text(
                              built ? 'Built' : 'Build',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: NtaColors.textMuted, fontSize: 14),
                            ),
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
      decoration: ntaPanel(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Citadel Facilities', style: NtaText.title),
              IconButton(
                icon: Icon(Icons.close, color: NtaColors.textMuted),
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
              leading: Icon(ntaBuildingIcon(building['id'] as String), size: 22, color: NtaColors.text),
              title: Text('${building['name']} (Lv. $level)', style: NtaText.body.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(building['desc'] as String? ?? '', style: NtaText.caption),
              onTap: () {
                Navigator.pop(context);
                state.switchView('capital');
              },
            );
          }),
        ],
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  GameState? _state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = context.read<GameState>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    // Season clock counts active playtime only: freeze it when the app is
    // backgrounded/closed and pick up exactly where it stopped.
    final state = _state;
    if (state == null) return;
    switch (lifecycleState) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        state.pauseClock();
      case AppLifecycleState.resumed:
        state.resumeClock();
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final view = state.currentView;
    final inPlot = view == 'plot';
    final inLobby = view == 'lobby';

    return Scaffold(
      body: Stack(
        children: [
          const GameViewport(),

          // Plot interior is a full-screen scene with its own header + actions.
          if (!inPlot && !inLobby) ...[
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

          if (state.gameOver) _VictoryOverlay(state: state),
        ],
      ),
    );
  }
}

/// Settlement overlay: shown when a victory condition fires (Construct
/// Remains or Final Conquest) or the season settles as a defeat.
class _VictoryOverlay extends StatelessWidget {
  const _VictoryOverlay({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final won = state.gameWon;
    final accent = won ? NtaColors.success : NtaColors.danger;

    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xCC0E0B09),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NtaColors.surface,
              borderRadius: BorderRadius.circular(NtaRadius.panel),
              border: Border.all(color: accent, width: NtaBorder.panel),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  won ? Icons.military_tech : Icons.dangerous,
                  size: 48,
                  color: accent,
                ),
                const SizedBox(height: 12),
                Text(
                  state.victoryTitle,
                  textAlign: TextAlign.center,
                  style: NtaText.title.copyWith(color: accent),
                ),
                const SizedBox(height: 12),
                for (final line in state.victoryLines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(line, style: NtaText.body),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Division: ${state.divisionName}',
                  style: NtaText.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                NtaGoldButton(
                  'Start New Session',
                  onTap: () {
                    state.startNewSession();
                    state.switchView('map');
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: state.closeVictory,
                  child: Text(
                    'Keep Viewing World',
                    style: NtaText.body.copyWith(color: NtaColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Top-left: tiga pill resource dasar (crop/wood/stone) + baris resource khusus.
// Layout mengikuti HUD game asli (S4): ikon menonjol di kiri pill, nilai + rate hijau,
// bar progress biru tipis di bawah nilai.
class _ResourcePanel extends StatelessWidget {
  const _ResourcePanel();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final rates = state.getHourlyProduction();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _pill('crop', state.crop, rates['crop'] ?? 0, state.cropCapacity),
        const SizedBox(height: 4),
        _pill('wood', state.wood, rates['wood'] ?? 0, state.materialCapacity),
        const SizedBox(height: 4),
        _pill('stone', state.stone, rates['stone'] ?? 0, state.materialCapacity),
        const SizedBox(height: 6),
        // Resource khusus (chest-only) — ikon + angka, tanpa produksi.
        Row(
          children: [
            _special('iron', state.iron),
            const SizedBox(width: 6),
            _special('exp_scroll', state.expScroll),
            const SizedBox(width: 6),
            _special('scroll', state.scroll),
            const SizedBox(width: 6),
            _special('nail', state.nail),
          ],
        ),
      ],
    );
  }

  Widget _pill(String resource, int value, double rate, int cap) {
    final progress = cap <= 0 ? 0.0 : value / cap;
    return NtaResourcePill(
      icon: NtaResIcon(resource, size: 18),
      value: '$value',
      rate: '+${rate.round()}',
      progress: progress,
    );
  }

  Widget _special(String resource, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: NtaColors.surfaceCard,
        border: Border.all(color: NtaColors.border, width: NtaBorder.hairline),
        borderRadius: BorderRadius.circular(NtaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NtaResIcon(resource, size: 13),
          const SizedBox(width: 4),
          Text('$value', style: NtaText.xs.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// Top-right panel: coins, reward points, season/time
class _TopRightPanel extends StatelessWidget {
  const _TopRightPanel();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    final seasonIndex = switch (state.season) {
      'Spring' => 0,
      'Summer' => 1,
      'Autumn' => 2,
      _ => 3,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reward Points (di game asli: coin dihapus, diganti tally/reward points).
        NtaCounterPill(
          icon: const Icon(Icons.redeem, size: 18, color: NtaColors.text),
          value: '${state.rewardPoints}',
        ),
        // Ranked: Tier Win Points + current tier.
        if (state.earnsTierWinPoints) ...[
          const SizedBox(height: 4),
          NtaCounterPill(
            icon: const Icon(Icons.military_tech, size: 18, color: NtaColors.text),
            value: '${state.tierWinPoints} ${state.rankTier}',
          ),
        ],
        const SizedBox(height: 4),
        // Victory-objective progress (Remains level or defeated rivals).
        NtaCounterPill(
          icon: Icon(
            state.victoryCondition == 'Final Conquest'
                ? Icons.gavel
                : Icons.account_balance,
            size: 18,
            color: NtaColors.text,
          ),
          value: state.victoryProgressLabel,
        ),
        const SizedBox(height: 6),
        // Musim + sisa waktu season (pause saat game ditutup).
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: NtaColors.surfaceRaised,
            border: Border.all(color: NtaColors.hudBorder, width: 2),
            borderRadius: BorderRadius.circular(NtaRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                NtaAssets.season(seasonIndex),
                width: 16,
                height: 16,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 4),
              Text(
                '${state.season} D${state.dayInSeason}',
                style: NtaText.xs.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Text(
                state.seasonTimeLeftLabel,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: NtaColors.hudText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
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
              onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
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
        // General Muster Terrace (free spin → hero fragments).
        _ActionButton(
          icon: Icons.casino,
          label: 'Muster',
          onPressed: () {
            final state = context.read<GameState>();
            final id = state.musterFragments();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${GameState.heroName(id!)}: '
                      '${state.fragmentsOf(id)} fragments'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        const SizedBox(width: 8),
        // Shop
        _ActionButton(
          icon: Icons.store,
          label: 'Shop',
          onPressed: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shop coming soon!'), duration: Duration(seconds: 2)),
              );
            }
          },
        ),
        const SizedBox(width: 8),
        // Back to the lobby (division picker / session info).
        _ActionButton(
          icon: Icons.meeting_room,
          label: 'Lobby',
          onPressed: () => state.returnToLobby(),
        ),
        const SizedBox(width: 8),
        // Troop list button (far right - corner)
        _ActionButton(
          icon: Icons.person_outline,
          label: 'Troops',
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
  final VoidCallback? onPressed;
  final int? badge;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: NtaColors.surfaceRaised,
                borderRadius: BorderRadius.circular(NtaRadius.button),
                border: Border.all(color: NtaColors.hudBorder, width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Icon(icon, color: NtaColors.text, size: 28),
            ),
          ),
        ),
        if (badge != null && badge! > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: NtaColors.danger,
                borderRadius: BorderRadius.circular(NtaRadius.round),
                border: Border.all(color: NtaColors.surfaceRaised, width: 1),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$badge',
                style: const TextStyle(color: NtaColors.textOnDark, fontSize: 9, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
