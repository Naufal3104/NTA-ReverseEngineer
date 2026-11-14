import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/battle_engine.dart';
import '../models/game_state.dart';
import '../../data/game_data.dart';
import 'asset_manager.dart';
import 'design_tokens.dart';

class GameTabs extends StatelessWidget {
  const GameTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          Container(
            color: NtaColors.surfaceCard,
            child: TabBar(
              labelColor: NtaColors.text,
              unselectedLabelColor: NtaColors.textMuted,
              indicatorColor: NtaColors.accentBorder,
              indicatorWeight: 3,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: NtaText.bodyBold,
              unselectedLabelStyle: NtaText.body.copyWith(fontWeight: FontWeight.w500),
              tabs: const [
                Tab(icon: Icon(Icons.fort, size: 20), text: 'Citadel'),
                Tab(icon: Icon(Icons.military_tech, size: 20), text: 'Barracks'),
                Tab(icon: Icon(Icons.hardware, size: 20), text: 'Smithy'),
                Tab(icon: Icon(Icons.auto_awesome, size: 20), text: 'Heroes'),
                Tab(icon: Icon(Icons.sports_kabaddi, size: 20), text: 'Expedition'),
                Tab(icon: Icon(Icons.history, size: 20), text: 'Log'),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: NtaColors.surface,
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
          ),
        ],
      ),
    );
  }
}

/// Banner info di atas tiap tab.
class _TabBanner extends StatelessWidget {
  final String title;
  final String body;
  final Widget? action;

  const _TabBanner({required this.title, required this.body, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x5),
      decoration: BoxDecoration(
        color: NtaColors.surfaceCard,
        border: const Border(bottom: BorderSide(color: NtaColors.borderSoft, width: NtaBorder.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: NtaText.bodyBold),
                const SizedBox(height: NtaSpace.x1),
                Text(body, style: NtaText.caption),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: NtaSpace.itemGap),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Potret pasukan asli (64x64 dari bundle `role/<pawnId>`), fallback ikon.
class _TroopPortrait extends StatelessWidget {
  final String troopId;

  const _TroopPortrait(this.troopId);

  @override
  Widget build(BuildContext context) {
    final pawnId = BattleEngine.troopCombatIds[troopId];
    if (pawnId == null) {
      return const Icon(Icons.shield, color: NtaColors.textMuted, size: 28);
    }
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        NtaAssets.unitSprite(pawnId),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.shield, color: NtaColors.textMuted, size: 28),
      ),
    );
  }
}

/// Kartu daftar: raised cream + border hairline.
class _ListCard extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Color bg;

  const _ListCard({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bg = NtaColors.surfaceRaised,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: NtaSpace.itemGap),
      padding: const EdgeInsets.all(NtaSpace.x5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: NtaColors.borderSoft, width: NtaBorder.hairline),
        borderRadius: BorderRadius.circular(NtaRadius.card),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: NtaSpace.sectionGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: NtaSpace.x2),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: NtaSpace.itemGap),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Chip biaya resource: hijau bila cukup, merah bila kurang.
class _CostChip extends StatelessWidget {
  final int amount;
  final String resource;
  final bool affordable;

  const _CostChip({required this.amount, required this.resource, required this.affordable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NtaSpace.x3, vertical: NtaSpace.x1),
      decoration: BoxDecoration(
        color: affordable ? NtaColors.surfaceSunk : NtaColors.danger.withValues(alpha: 0.12),
        border: Border.all(
          color: affordable ? NtaColors.borderSoft : NtaColors.danger,
          width: NtaBorder.hairline,
        ),
        borderRadius: BorderRadius.circular(NtaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$amount',
            style: NtaText.xs.copyWith(
              fontWeight: FontWeight.w700,
              color: affordable ? NtaColors.text : NtaColors.danger,
            ),
          ),
          const SizedBox(width: NtaSpace.x1),
          NtaResIcon(
            resource,
            size: 11,
            color: affordable ? NtaColors.textMuted : NtaColors.danger,
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
        _TabBanner(
          title: 'Capital Citadel (2x2 Space)',
          body: 'Only 1 Capital exists. All core facilities built here.',
          action: NtaGoldButton(
            'Interior View',
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
            onTap: () => context.read<GameState>().switchView('capital'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(NtaSpace.itemGap),
            itemCount: GameData.BUILDINGS.length,
            itemBuilder: (context, index) {
              final building = GameData.BUILDINGS[index];
              final id = building['id'] as String;
              final level = capitalBuildings[id] ?? 0;
              final nextLvlCost = GameData.upgradeCost(id, level + 1);
              final canAfford = state.hasResources(nextLvlCost);

              return _ListCard(
                leading: ntaLevelBadge('Lv.$level'),
                title: Text(building['name'] as String, style: NtaText.bodyBold),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(building['desc'] as String? ?? '', style: NtaText.caption),
                    const SizedBox(height: NtaSpace.x3),
                    Wrap(
                      spacing: NtaSpace.x3,
                      runSpacing: NtaSpace.x2,
                      children: nextLvlCost.entries.map((e) {
                        return _CostChip(
                          amount: e.value,
                          resource: e.key,
                          affordable: state.hasResources({e.key: e.value}),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                trailing: NtaGoldButton(
                  'Upgrade',
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
                  onTap: canAfford ? () => state.upgradeCapitalBuilding(id) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- 2. BARRACKS TAB: RECRUIT TROOPS ---
class _BarracksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Column(
      children: [
        const _TabBanner(
          title: 'Barracks',
          body: 'Spearman > Cavalry > Shieldman > Bowman > Spearman (+40% DMG)',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(NtaSpace.itemGap),
            itemCount: GameData.TROOPS.length,
            itemBuilder: (context, index) {
              final troop = GameData.TROOPS[index];
              final id = troop['id'] as String;
              final owned = state.troops[id] ?? 0;

              return _ListCard(
                leading: _TroopPortrait(id),
                title: Text('${troop['name']}  x$owned', style: NtaText.bodyBold),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATK ${troop['atk']}  ·  DEF ${troop['def']}  ·  HP ${troop['hp']}',
                      style: NtaText.caption,
                    ),
                    const SizedBox(height: NtaSpace.x1),
                    Text(
                      'Advantage: ${troop['advantage']}',
                      style: NtaText.caption.copyWith(color: NtaColors.success, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                trailing: NtaGoldButton(
                  'Train',
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
                  onTap: () => _showRecruitDialog(context, troop),
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

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(NtaSpace.panelPad),
              decoration: ntaPanel(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Train ${troop['name']}', style: NtaText.title),
                  const SizedBox(height: NtaSpace.sectionGap),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        onTap: count > 5 ? () => setDialogState(() => count -= 5) : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: NtaSpace.x12),
                        child: Text('$count', style: NtaText.display),
                      ),
                      _StepperButton(
                        icon: Icons.add,
                        onTap: () => setDialogState(() => count += 5),
                      ),
                    ],
                  ),
                  const SizedBox(height: NtaSpace.sectionGap),
                  Wrap(
                    spacing: NtaSpace.x3,
                    runSpacing: NtaSpace.x2,
                    alignment: WrapAlignment.center,
                    children: totalCost.entries
                        .map((e) => _CostChip(amount: e.value, resource: e.key, affordable: canAfford))
                        .toList(),
                  ),
                  const SizedBox(height: NtaSpace.panelPad),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FlatTextButton(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
                      const SizedBox(width: NtaSpace.sectionGap),
                      NtaGoldButton(
                        'Confirm',
                        onTap: canAfford
                            ? () {
                                state.trainTroops(troop['id'] as String, count);
                                Navigator.pop(ctx);
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? NtaColors.surfaceCard : NtaColors.disabled,
          border: Border.all(color: NtaColors.borderInput, width: 2),
          borderRadius: BorderRadius.circular(NtaRadius.button),
        ),
        child: Icon(icon, size: 20, color: enabled ? NtaColors.text : NtaColors.textMuted),
      ),
    );
  }
}

class _FlatTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _FlatTextButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: NtaSpace.panelPad, vertical: NtaSpace.x5),
        decoration: BoxDecoration(
          color: NtaColors.surfaceSunk,
          border: Border.all(color: NtaColors.borderSoft, width: NtaBorder.card),
          borderRadius: BorderRadius.circular(NtaRadius.button),
        ),
        child: Text(label, style: NtaText.body.copyWith(color: NtaColors.textMuted)),
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
      padding: const EdgeInsets.all(NtaSpace.itemGap),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: NtaSpace.itemGap),
          padding: const EdgeInsets.all(NtaSpace.x5),
          decoration: BoxDecoration(
            color: NtaColors.surfaceSunk,
            border: Border.all(color: NtaColors.borderSoft, width: NtaBorder.hairline),
            borderRadius: BorderRadius.circular(NtaRadius.card),
          ),
          child: Text(
            'Smithy Lv.$smithyLvl — Common Lv.1/3/5/7/12/14 · Exclusive 10/18 (max 2) · Smelt into exclusive 14/18 (1 nail)',
            style: NtaText.caption,
          ),
        ),
        for (final eq in GameData.EQUIP_MASTER) _smithyCard(context, state, eq, smithyLvl, false),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: NtaSpace.itemGap),
          child: Text(
            'Exclusive gear (free pick among owned troops · max 2/session)',
            style: NtaText.bodyBold.copyWith(color: NtaColors.heroNamePill),
          ),
        ),
        for (final eq in GameData.EXCLUSIVE_EQUIPMENT) _smithyCard(context, state, eq, smithyLvl, true),
      ],
    );
  }

  Widget _smithyCard(BuildContext context, GameState state, Map<String, dynamic> eq, int smithyLvl, bool exclusive) {
    final id = '${eq['id']}';
    final cost = (eq['cost'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int));
    final costText = cost.entries.map((e) => '${e.value} ${e.key}').join(', ');
    if (exclusive) {
      final owned = state.exclusiveEquipment[id];
      if (owned != null) {
        final rolled = ((owned['effects'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map((e) => GameData.equipRolledEffectText(e['id'] as int))
            .join(' · ');
        return _ListCard(
          bg: NtaColors.accentSoft,
          leading: const Icon(Icons.stars, color: NtaColors.heroNamePill, size: 28),
          title: Text('${owned['name']} (${owned['subtype']})', style: NtaText.bodyBold),
          subtitle: Text(rolled, style: NtaText.caption),
        );
      }
      final blocker = state.exclusiveForgeBlocker(id);
      final needLv = (eq['needLv'] as List).cast<int>();
      return _ListCard(
        leading: const Icon(Icons.stars, color: NtaColors.heroNamePill, size: 28),
        title: Text('${eq['nameIdl']} — ${eq['subtype']}', style: NtaText.bodyBold),
        subtitle: Text(
          blocker ?? 'Smithy Lv.${needLv.first}/${needLv.last} · Cost: $costText',
          style: NtaText.caption,
        ),
        trailing: NtaGoldButton(
          'Forge',
          fontSize: 12,
          padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
          onTap: blocker == null ? () => state.craftEquipment(id) : null,
        ),
      );
    }
    final needLv = (eq['needLv'] as List).cast<int>();
    final tier = needLv.isEmpty ? 1 : needLv.first;
    final locked = smithyLvl < tier;
    final owned = state.equipment[id] ?? 0;
    final canAfford = !locked && state.hasResources(cost);

    return _ListCard(
      leading: Icon(Icons.hardware, color: NtaColors.textMuted, size: 28),
      title: Row(
        children: [
          Flexible(child: Text('${eq['nameIdl']}  x$owned', style: NtaText.bodyBold)),
          if (locked) ...[
            const SizedBox(width: NtaSpace.x3),
            ntaLevelBadge('Lv.$tier'),
          ],
        ],
      ),
      subtitle: Text(
        '${eq['hp'] != '' ? 'HP ${eq['hp']} ' : ''}${eq['atk'] != '' ? 'ATK ${eq['atk']} ' : ''}'
        '· $costText\n${GameData.equipEffectText(eq, idl: true)}',
        style: NtaText.caption,
      ),
      trailing: NtaGoldButton(
        'Forge',
        fontSize: 12,
        padding: const EdgeInsets.symmetric(horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
        onTap: canAfford ? () => state.craftEquipment(id) : null,
      ),
    );
  }
}

// --- 4. HEROES TAB: PORTRAITS, EXPERTISE, WORSHIP ---
class _HeroesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Column(
      children: [
        _TabBanner(
          title: 'Hall of Heroes',
          body: 'Worship ${state.worshippedHeroes.length}/${state.worshipSlots} slots'
              ' · Repair & redraw need ${GameState.portraitFragmentCost} fragments',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(NtaSpace.itemGap),
            itemCount: GameData.HEROES.length,
            itemBuilder: (context, index) =>
                _HeroCard(hero: GameData.HEROES[index], state: state),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Map<String, dynamic> hero;
  final GameState state;

  const _HeroCard({required this.hero, required this.state});

  @override
  Widget build(BuildContext context) {
    final id = hero['id'] as int;
    final repaired = state.hasPortrait(id);
    final isWorshipped = state.worshippedHeroes.contains(id);
    final grade = state.portraitGrade(id);
    final fragments = state.fragmentsOf(id);
    final gradeLabel = GameData.PORTRAIT_GRADE_LABELS[grade];
    final skill = GameData.HERO_SKILLS[hero['skill']];

    return _ListCard(
      bg: isWorshipped ? NtaColors.accentSoft : NtaColors.surfaceRaised,
      leading: SizedBox(
        width: 44,
        height: 44,
        child: Image.asset(
          NtaAssets.heroPortrait(id),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          errorBuilder: (_, _, _) => Icon(
            repaired ? Icons.person : Icons.help_outline,
            color: NtaColors.textMuted,
            size: 28,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(GameState.heroName(id), style: NtaText.bodyBold),
          ),
          if (repaired) ntaLevelBadge(gradeLabel),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            repaired
                ? 'HP ${hero['hp'][grade]}  ·  ATK ${hero['atk'][grade]}  ·  '
                    '${state.portraitExpertise(id).length} expertise'
                : 'Fragments $fragments/${GameState.portraitFragmentCost}',
            style: NtaText.caption,
          ),
          const SizedBox(height: NtaSpace.x1),
          Text(
            'Skill: ${skill?['name'] ?? '-'}'
            '${repaired ? ' (${state.heroSkillValue(id)}${skill?['suffix'] ?? ''})' : ''}',
            style: NtaText.caption.copyWith(
                color: NtaColors.heroNamePill, fontWeight: FontWeight.w700),
          ),
          if (repaired && grade < 7) ...[
            const SizedBox(height: NtaSpace.x1),
            Text(
              'Next grade guaranteed in '
              '${(GameData.PORTRAIT_UPGRADE_PITY - state.portraitPity(id)).clamp(0, GameData.PORTRAIT_UPGRADE_PITY)} redraws',
              style: NtaText.caption,
            ),
          ],
          if (repaired) ...[
            const SizedBox(height: NtaSpace.x2),
            for (var slot = 0; slot < state.portraitExpertise(id).length; slot++)
              Builder(builder: (context) {
                final row = state.portraitExpertise(id)[slot];
                final label =
                    '· ${GameData.STRATEGY_RARITY_NAMES[((row['lv'] as int) - 1).clamp(0, 2)]}: '
                    '${GameData.strategyDesc(row['id'] as int)}';
                if (grade != 7) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: NtaSpace.x1),
                    child: Text(label, style: NtaText.caption),
                  );
                }
                return InkWell(
                  onTap: () => _pickChosenExpertise(context, id, slot),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: NtaSpace.x1),
                    child: Text(
                      '$label  ✎',
                      style: NtaText.caption.copyWith(
                          color: NtaColors.heroNamePill),
                    ),
                  ),
                );
              }),
          ],
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!repaired)
            NtaGoldButton(
              'Repair',
              fontSize: 12,
              padding: const EdgeInsets.symmetric(
                  horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
              onTap: () => state.repairPortrait(id),
            )
          else ...[
            NtaGoldButton(
              'Redraw',
              fontSize: 12,
              padding: const EdgeInsets.symmetric(
                  horizontal: NtaSpace.sectionGap, vertical: NtaSpace.x3),
              onTap: () => state.redrawPortrait(id),
            ),
            const SizedBox(height: NtaSpace.x2),
            if (isWorshipped)
              ntaLevelBadge('WORSHIPPED')
            else
              TextButton(
                onPressed: () => state.worshipHero(id),
                child: Text('Worship', style: NtaText.caption.copyWith(
                    color: NtaColors.heroNamePill, fontWeight: FontWeight.w700)),
              ),
          ],
        ],
      ),
    );
  }

  /// Chosen-only manual expertise pick for one slot.
  void _pickChosenExpertise(BuildContext context, int heroId, int slot) {
    final hero = GameState.heroById(heroId);
    final pool = ((hero?['strategy'] as List?) ?? const []).cast<int>();
    final rarity = slot < 3 ? slot + 1 : 3;
    final options = [
      for (final sid in pool)
        if ((GameData.STRATEGIES[sid]?['lv'] as int?) == rarity) sid,
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: NtaColors.surface,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(NtaSpace.sectionGap),
          children: [
            Text(
              '${GameData.STRATEGY_RARITY_NAMES[rarity - 1]} — slot ${slot + 1}',
              style: NtaText.bodyBold,
            ),
            const SizedBox(height: NtaSpace.itemGap),
            for (final sid in options)
              ListTile(
                dense: true,
                title: Text(GameData.strategyDesc(sid), style: NtaText.caption),
                onTap: () {
                  state.pickExpertise(heroId, slot, sid);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(NtaSpace.sectionGap),
      children: [
        Container(
          padding: const EdgeInsets.all(NtaSpace.sectionGap),
          decoration: ntaRaisedCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.military_tech, color: NtaColors.text, size: 20),
                  const SizedBox(width: NtaSpace.itemGap),
                  Text('Expeditionary Force', style: NtaText.title),
                ],
              ),
              const SizedBox(height: NtaSpace.x3),
              Text('Active Standing Army: $totalTroops soldiers', style: NtaText.caption),
              const SizedBox(height: NtaSpace.x2),
              Wrap(
                spacing: NtaSpace.x5,
                runSpacing: NtaSpace.x1,
                children: state.troops.entries
                    .map((e) => Text('${e.key}: ${e.value}', style: NtaText.caption))
                    .toList(),
              ),
              const SizedBox(height: NtaSpace.x2),
              Text(
                'Active Worshipped Heroes: ${state.worshippedHeroes.length}',
                style: NtaText.caption.copyWith(color: NtaColors.success, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: NtaSpace.sectionGap),
        _RemainsStandings(state: state),
        const SizedBox(height: NtaSpace.sectionGap),
        if (selectedTile != null)
          Container(
            padding: const EdgeInsets.all(NtaSpace.sectionGap),
            decoration: ntaCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Target: (${selectedTile[0]}, ${selectedTile[1]})',
                  style: NtaText.bodyBold,
                ),
                const SizedBox(height: NtaSpace.x2),
                Text(
                  state.isTileConquered(selectedTile[0], selectedTile[1])
                      ? 'Status: Secured territory with Watchtower and Player Flag.'
                      : 'Status: Unconquered Hostile Plot. Can launch automated turn assault.',
                  style: NtaText.caption,
                ),
                const SizedBox(height: NtaSpace.itemGap),
                NtaGoldButton(
                  'Open 11x11 Plot Interior View',
                  fontSize: 13,
                  padding: const EdgeInsets.symmetric(horizontal: NtaSpace.panelPad, vertical: NtaSpace.x3),
                  onTap: () => context.read<GameState>().setPlotView(selectedTile[0], selectedTile[1]),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(NtaSpace.sectionGap),
            decoration: ntaRaisedCard(),
            child: Text(
              'Tap any tile on the world map to inspect its 11x11 inner grid and launch automated turn-based assaults.',
              style: NtaText.caption,
            ),
          ),
      ],
    );
  }
}

/// Victory objective tracker: Remains ownership/levels for Construct Remains,
/// rival leader status for Final Conquest, plus the active bot difficulty.
class _RemainsStandings extends StatelessWidget {
  final GameState state;

  const _RemainsStandings({required this.state});

  @override
  Widget build(BuildContext context) {
    final finalConquest = state.victoryCondition == 'Final Conquest';
    final diff = state.botDifficulty;

    return Container(
      padding: const EdgeInsets.all(NtaSpace.sectionGap),
      decoration: ntaRaisedCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: NtaColors.text, size: 20),
              const SizedBox(width: NtaSpace.itemGap),
              Expanded(
                child: Text('Victory Objective: ${state.victoryCondition}',
                    style: NtaText.title),
              ),
            ],
          ),
          const SizedBox(height: NtaSpace.x2),
          Text(
            '${diff['name']} bot · Remains level-up every '
            '${(diff['levelsEvery'] as int) * (diff['tick'] as int) ~/ 60} min',
            style: NtaText.caption,
          ),
          const SizedBox(height: NtaSpace.itemGap),
          for (final r in state.remains.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Icon(
                    r['owner'] == 'player' ? Icons.account_balance : Icons.castle,
                    size: 14,
                    color: r['owner'] == 'player'
                        ? NtaColors.success
                        : NtaColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${r['name']} — Lv.${r['level']} · '
                      '${r['owner'] == 'player' ? 'You' : r['owner']}',
                      style: NtaText.caption,
                    ),
                  ),
                ],
              ),
            ),
          if (finalConquest) ...[
            const SizedBox(height: NtaSpace.itemGap),
            for (final u in state.rivalUnions)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '${u['name']} (${u['leader']}) — '
                  '${u['defeated'] == true ? 'DEFEATED' : '${u['points']} pts'}',
                  style: NtaText.caption.copyWith(
                    color: u['defeated'] == true
                        ? NtaColors.success
                        : NtaColors.text,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// --- 6. LOG TAB ---
class _LogTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return ListView.builder(
      padding: const EdgeInsets.all(NtaSpace.itemGap),
      itemCount: state.log.length,
      reverse: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: NtaSpace.x3),
          child: Text(
            state.log[state.log.length - 1 - index],
            style: NtaText.caption,
          ),
        );
      },
    );
  }
}
