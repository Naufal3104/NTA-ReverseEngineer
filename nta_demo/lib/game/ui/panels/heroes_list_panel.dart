import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../../../data/game_data.dart';
import '../asset_manager.dart';
import '../design_tokens.dart';
import 'general_muster_panel.dart';

/// Heroes List modal — near-fullscreen grid of owned/known heroes.
/// Reference: `Tampilan Button Heroes List.jpg`.
///
/// Tabs: Hero Portrait / Skin / Socialization. Grid 3-col, colored frame by
/// portrait tier. Bottom row: Exchange (fragment) + Muster (opens #37).
class HeroesListPanel extends StatefulWidget {
  const HeroesListPanel({super.key, this.initialTab = 0});

  final int initialTab;

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: HeroesListPanel(initialTab: initialTab),
      ),
    );
  }

  @override
  State<HeroesListPanel> createState() => _HeroesListPanelState();
}

class _HeroesListPanelState extends State<HeroesListPanel> {
  late int _tab;
  int _sortMode = 0; // 0 = portrait tier, 1 = name

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 820),
        child: Container(
          decoration: ntaPanel(),
          child: Column(
            children: [
              _tabs(),
              Expanded(
                child: switch (_tab) {
                  0 => _portraitTab(state),
                  1 => _skinTab(),
                  _ => _socialTab(),
                },
              ),
              _footer(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          _tabBtn('Hero Portrait', 0),
          _tabBtn('Skin', 1),
          _tabBtn('Socialization', 2),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final selected = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? NtaColors.surfaceRaised : NtaColors.surfaceCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(NtaRadius.card)),
            border: Border(
              top: BorderSide(
                color: selected ? NtaColors.accentBorder : NtaColors.borderSoft,
                width: selected ? 2 : 1,
              ),
            ),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: selected
                  ? NtaText.bodyBold.copyWith(fontSize: 12.5)
                  : NtaText.body.copyWith(
                      fontSize: 12.5, color: NtaColors.textMuted)),
        ),
      ),
    );
  }

  Widget _portraitTab(GameState state) {
    final heroes = _sortedHeroes(state);
    final owned = state.portraits.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
          child: Row(
            children: [
              Expanded(
                child: _dropdown(
                  _sortMode == 0 ? 'Sort by Portrait Tier' : 'Sort by Name',
                  () => setState(() => _sortMode = (_sortMode + 1) % 2),
                ),
              ),
              const SizedBox(width: 6),
              _dropdown('ALL($owned/${GameData.HEROES.length})', () {}),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.62,
            ),
            itemCount: heroes.length,
            itemBuilder: (_, i) => _heroCard(state, heroes[i]),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _sortedHeroes(GameState state) {
    final list = [...GameData.HEROES];
    if (_sortMode == 1) {
      list.sort((a, b) => GameState.heroName(a['id'] as int)
          .compareTo(GameState.heroName(b['id'] as int)));
    } else {
      // Repaired portraits (higher grade) first.
      list.sort((a, b) {
        final ga = state.hasPortrait(a['id'] as int)
            ? state.portraitGrade(a['id'] as int)
            : -1;
        final gb = state.hasPortrait(b['id'] as int)
            ? state.portraitGrade(b['id'] as int)
            : -1;
        return gb.compareTo(ga);
      });
    }
    return list;
  }

  Widget _dropdown(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: NtaColors.surfaceRaised,
          borderRadius: BorderRadius.circular(NtaRadius.pill),
          border: Border.all(color: NtaColors.borderSoft, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NtaText.body.copyWith(
                      fontSize: 11.5, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(GameState state, Map<String, dynamic> hero) {
    final id = hero['id'] as int;
    final owned = state.hasPortrait(id);
    final grade = owned ? state.portraitGrade(id) : -1;
    final frags = state.fragmentsOf(id);
    final frameColor = _frameColor(owned, grade);

    return GestureDetector(
      onTap: () => _showHeroDetail(context, state, id),
      child: Container(
        decoration: BoxDecoration(
          color: NtaColors.surfaceRaised,
          borderRadius: BorderRadius.circular(NtaRadius.card),
          border: Border.all(color: frameColor, width: 2.5),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Text(
              GameState.heroName(id),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: NtaText.bodyBold.copyWith(fontSize: 11),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Opacity(
                        opacity: owned ? 1 : 0.55,
                        child: Image.asset(
                          NtaAssets.heroPortrait(id),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (_, _, _) => const Icon(Icons.person),
                        ),
                      ),
                    ),
                    if (frags > 0)
                      Positioned(
                        left: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xCC2C5A47),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('$frags',
                              style: NtaText.xs.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(
                color: NtaColors.border,
                borderRadius: BorderRadius.circular(NtaRadius.pill),
              ),
              child: Text(
                owned ? GameData.PORTRAIT_GRADE_RAW[grade] : 'Locked',
                style: NtaText.xs.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: NtaColors.textOnDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _frameColor(bool owned, int grade) {
    if (!owned) return NtaColors.borderSoft;
    if (grade >= 7) return const Color(0xFFF0C24A); // Chosen = gold
    if (grade >= 5) return const Color(0xFFB07BD6); // purple
    return const Color(0xFF5B9BD5); // blue
  }

  void _showHeroDetail(BuildContext context, GameState state, int id) {
    final hero = GameState.heroById(id);
    final owned = state.hasPortrait(id);
    final grade = state.portraitGrade(id);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NtaColors.surface,
        title: Text(GameState.heroName(id), style: NtaText.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hero != null)
              Text('Troop: ${hero['troop']}', style: NtaText.body),
            Text('Fragments: ${state.fragmentsOf(id)}',
                style: NtaText.body),
            Text(
              owned
                  ? 'Tier: ${GameData.PORTRAIT_GRADE_LABELS[grade]} '
                      '(redraws ${state.portraitRedraws(id)})'
                  : 'Not repaired yet.',
              style: NtaText.body,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          if (owned)
            NtaGoldButton('Redraw', onTap: () { state.redrawPortrait(id); Navigator.of(ctx).pop(); })
          else
            NtaGoldButton('Repair', onTap: () { state.repairPortrait(id); Navigator.of(ctx).pop(); }),
        ],
      ),
    );
  }

  Widget _skinTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checkroom, size: 52, color: NtaColors.textMuted),
            const SizedBox(height: 12),
            Text('Hero Skins', style: NtaText.title),
            const SizedBox(height: 8),
            Text(
              'Cosmetic skins are free in the offline rebuild. '
              'No skin data was captured from the original build yet.',
              textAlign: TextAlign.center,
              style: NtaText.sm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border,
                size: 52, color: NtaColors.textMuted),
            const SizedBox(height: 12),
            Text('Socialization', style: NtaText.title),
            const SizedBox(height: 8),
            Text(
              'Hero affinity interactions. TODO: original socialization '
              'data not documented yet.',
              textAlign: TextAlign.center,
              style: NtaText.sm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer(GameState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: _footerBtn('Exchange', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exchange: trade fragments for hero shards.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _footerBtn('Muster', primary: true, onTap: () {
              Navigator.of(context).pop();
              GeneralMusterPanel.show(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _footerBtn(String label,
      {required VoidCallback onTap, bool primary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [NtaColors.accentTop, NtaColors.accentBottom],
                )
              : null,
          color: primary ? null : NtaColors.surfaceRaised,
          borderRadius: BorderRadius.circular(NtaRadius.button),
          border: Border.all(
              color: primary ? NtaColors.accentBorder : NtaColors.border,
              width: 2.5),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: NtaText.bodyBold.copyWith(
                fontSize: 15,
                color: primary ? NtaColors.onAccent : NtaColors.text)),
      ),
    );
  }
}