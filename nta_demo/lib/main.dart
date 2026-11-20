import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game/models/game_state.dart';
import 'game/components/viewport.dart' show GameViewport;
import 'game/components/map_hud_overlay.dart';
import 'game/ui/panels/armies_panel.dart';
import 'game/ui/panels/heroes_list_panel.dart';
import 'game/ui/panels/shop_panel.dart';
import 'game/ui/panels/lucky_wheel_panel.dart';
import 'game/ui/panels/battle_rankings_panel.dart';
import 'game/ui/panels/chat_panel.dart';
import 'game/ui/panels/construction_queue_panel.dart';
import 'game/ui/panels/map_overview_panel.dart';
import 'game/ui/panels/march_list_panel.dart';
import 'game/ui/panels/output_overview_panel.dart';
import 'game/ui/panels/profile_panel.dart';
import 'game/ui/panels/season_detail_panel.dart';
import 'game/ui/panels/special_resource_panel.dart';
import 'game/ui/panels/general_muster_panel.dart';
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
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = context.read<GameState>();
    if (!_precached) {
      _precacheAssets(context);
      _precached = true;
    }
  }

  /// Precache frequently used images to avoid jank on first render.
  void _precacheAssets(BuildContext context) {
    precacheImage(AssetImage(NtaAssets.chrome('panel_cream')), context);
    precacheImage(AssetImage(NtaAssets.chrome('panel_square')), context);
    precacheImage(AssetImage(NtaAssets.chrome('btn_gold_round')), context);
    precacheImage(AssetImage(NtaAssets.chrome('btn_gold_wide')), context);
    for (var i = 0; i < 4; i++) {
      precacheImage(AssetImage(NtaAssets.season(i)), context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
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

          if (!inPlot && !inLobby) ...[
            // Top-left resource panel - wrapped in RepaintBoundary to isolate repaints
            Positioned(
              top: 8,
              left: 8,
              child: RepaintBoundary(child: _ResourcePanel()),
            ),

            // Top-right coins & time panel
            Positioned(
              top: 8,
              right: 8,
              child: RepaintBoundary(child: _TopRightPanel()),
            ),

            // Rail kanan vertikal + timer chips (construction, march).
            if (!inPlot)
              Positioned(
                top: 100,
                right: 8,
                child: RepaintBoundary(
                  child: MapHudRail(
                    callbacks: MapHudCallbacks(
                      onMapOverview: () => MapOverviewPanel.show(context),
                      onHeroes: () => HeroesListPanel.show(context),
                      onBattleRankings: () => BattleRankingsPanel.show(context),
                      onProfile: () => ProfilePanel.show(context),
                      onGeneralMuster: () => GeneralMusterPanel.show(context),
                      onConstructionQueue: () => ConstructionQueuePanel.show(context),
                      onMarchList: () => MarchListPanel.show(context),
                      onArmies: () => ArmiesPanel.show(context),
                    ),
                  ),
                ),
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
// bar progress biru tipis di bawah nilai. Pill basic dan special lebarnya sama (size to content).
class _ResourcePanel extends StatelessWidget {
  const _ResourcePanel();

  @override
  Widget build(BuildContext context) {
    // Use context.select to only rebuild when specific resources change
    final crop = context.select((GameState s) => s.crop);
    final wood = context.select((GameState s) => s.wood);
    final stone = context.select((GameState s) => s.stone);
    final cropCap = context.select((GameState s) => s.cropCapacity);
    final matCap = context.select((GameState s) => s.materialCapacity);
    final iron = context.select((GameState s) => s.iron);
    final expScroll = context.select((GameState s) => s.expScroll);
    final scroll = context.select((GameState s) => s.scroll);
    final nail = context.select((GameState s) => s.nail);
    final rates = context.select((GameState s) => s.getHourlyProduction());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Basic resource pills: constrain width so Expanded inside NtaResourcePill works
        SizedBox(width: 180, child: _pill(context, 'crop', crop, rates['crop'] ?? 0, cropCap)),
        const SizedBox(height: 4),
        SizedBox(width: 180, child: _pill(context, 'wood', wood, rates['wood'] ?? 0, matCap)),
        const SizedBox(height: 4),
        SizedBox(width: 180, child: _pill(context, 'stone', stone, rates['stone'] ?? 0, matCap)),
        const SizedBox(height: 6),
        // Resource khusus (chest-only) — ikon + angka, tanpa produksi.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _special(context, 'iron', iron),
            const SizedBox(width: 6),
            _special(context, 'exp_scroll', expScroll),
            const SizedBox(width: 6),
            _special(context, 'scroll', scroll),
            const SizedBox(width: 6),
            _special(context, 'nail', nail),
          ],
        ),
      ],
    );
  }

  Widget _pill(BuildContext context, String resource, int value, double rate,
      int cap) {
    final progress = cap <= 0 ? 0.0 : value / cap;
    return GestureDetector(
      onTap: () => OutputOverviewPanel.show(context, initialRes: resource),
      child: NtaResourcePill(
        icon: NtaResIcon(resource, size: 18),
        value: '$value',
        rate: '+${rate.round()}',
        progress: progress,
      ),
    );
  }

  Widget _special(BuildContext context, String resource, int value) {
    return GestureDetector(
      onTap: () => SpecialResourcePanel.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: NtaColors.surfaceCard,
          border:
              Border.all(color: NtaColors.border, width: NtaBorder.hairline),
          borderRadius: BorderRadius.circular(NtaRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NtaResIcon(resource, size: 13),
            const SizedBox(width: 4),
            Text('$value',
                style: NtaText.xs.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// Top-right panel: reward points, tier win points (ranked), season/time
class _TopRightPanel extends StatelessWidget {
  const _TopRightPanel();

  @override
  Widget build(BuildContext context) {
    // Use context.select to only rebuild when specific values change
    final rewardPoints = context.select((GameState s) => s.rewardPoints);
    final earnsTierWinPoints = context.select((GameState s) => s.earnsTierWinPoints);
    final tierWinPoints = context.select((GameState s) => s.tierWinPoints);
    final rankTier = context.select((GameState s) => s.rankTier);
    final season = context.select((GameState s) => s.season);
    final dayInSeason = context.select((GameState s) => s.dayInSeason);
    final seasonTimeLeftLabel = context.select((GameState s) => s.seasonTimeLeftLabel);

    final seasonIndex = switch (season) {
      'Spring' => 0,
      'Summer' => 1,
      'Autumn' => 2,
      _ => 3,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reward Points — ikon win_point (bronze tally/coin)
        NtaCounterPill(
          icon: Image.asset(NtaAssets.rewardPointsIcon, width: 18, height: 18, fit: BoxFit.contain),
          value: '$rewardPoints',
        ),
        // Ranked: Tier Win Points + current tier.
        if (earnsTierWinPoints) ...[
          const SizedBox(height: 4),
          NtaCounterPill(
            icon: const Icon(Icons.military_tech, size: 18, color: NtaColors.text),
            value: '$tierWinPoints $rankTier',
          ),
        ],
        const SizedBox(height: 6),
        // Musim + sisa waktu season — tap → SeasonDetailPanel.
        GestureDetector(
          onTap: () => SeasonDetailPanel.show(context),
          child: Container(
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
                  '$season D$dayInSeason',
                  style: NtaText.xs.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Text(
                  seasonTimeLeftLabel,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: NtaColors.hudText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
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

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 72),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message button (always top) — ic_chat ✓
          _ChromeActionButton(
            chromeKey: 'ic_chat',
            label: 'Chat',
            onPressed: () => ChatPanel.show(context),
          ),
          const SizedBox(height: 8),
          // Context-aware bottom button
          _ChromeActionButton(
            chromeKey: isInCapitalOrPlot ? 'ic_back' : 'ic_user',
            label: isInCapitalOrPlot ? 'Back' : 'Capital',
            onPressed: isInCapitalOrPlot
                ? () => state.goToMap()
                : () => state.switchView('capital'),
          ),
        ],
      ),
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
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quest/Reward Info button
            _ChromeActionButton(
              chromeKey: 'ic_chat',
              label: 'Quest',
              onPressed: () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quest info coming soon!'), duration: Duration(seconds: 2)),
                  );
                }
              },
            ),
            const SizedBox(width: 6),
            // Building selection button
            _ChromeActionButton(
              chromeKey: 'ic_back',
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
            const SizedBox(width: 6),
            // Facility Access button (replaces the old facility quick access navbar)
            _ChromeActionButton(
              chromeKey: 'ic_user',
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
            const SizedBox(width: 6),
            // Troops in this capital/plot only
            _ChromeActionButton(
              chromeKey: 'ic_user',
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
        ),
      );
    }

    // Map view — referensi `Tampilan Utama.jpg`:
    // Left to right: Lucky Wheel · Shop · Map Overview · Armies (All Armies/Territories/Battle Report tabs)
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Lucky Wheel — giftbox icon
          _ChromeActionButton(
            chromeKey: 'custom',
            customIcon: Image.asset(NtaAssets.luckyWheelIcon, width: 28, height: 28, fit: BoxFit.contain),
            label: 'Lucky Wheel',
            onPressed: () => LuckyWheelPanel.show(context),
          ),
          const SizedBox(width: 6),
          // Shop — shop_ingot icon
          _ChromeActionButton(
            chromeKey: 'custom',
            customIcon: Image.asset(NtaAssets.shopIcon, width: 28, height: 28, fit: BoxFit.contain),
            label: 'Shop',
            onPressed: () => ShopPanel.show(context),
          ),
          const SizedBox(width: 6),
          // Map Overview — capital/minimap icon
          _ChromeActionButton(
            chromeKey: 'custom',
            customIcon: Image.asset(NtaAssets.mapIcon, width: 28, height: 28, fit: BoxFit.contain),
            label: 'Map',
            onPressed: () => MapOverviewPanel.show(context),
          ),
          const SizedBox(width: 6),
          // Armies — army icon (2 helmets)
          _ChromeActionButton(
            chromeKey: 'custom',
            customIcon: Image.asset(NtaAssets.armiesIcon, width: 28, height: 28, fit: BoxFit.contain),
            label: 'Armies',
            badge: state.troops.values.fold<int>(0, (a, b) => a + b),
            onPressed: () => ArmiesPanel.show(context),
          ),
        ],
      ),
    );
  }

  int _getGarrisonCount(GameState state) {
    // For now return total troops - will be replaced with garrison-specific count
    return state.troops.values.fold<int>(0, (a, b) => a + b);
  }
}

class _ChromeActionButton extends StatelessWidget {
  final String chromeKey;
  final String label;
  final VoidCallback? onPressed;
  final int badge;
  final Widget? customIcon;

  const _ChromeActionButton({
    required this.chromeKey,
    required this.label,
    this.onPressed,
    this.badge = 0,
    this.customIcon,
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NtaColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(NtaRadius.button),
                  border: Border.all(color: NtaColors.hudBorder, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Center(
                  child: customIcon ??
                      NtaAssets.chromeImage(chromeKey, width: 28, height: 28, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ),
        if (badge > 0)
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
