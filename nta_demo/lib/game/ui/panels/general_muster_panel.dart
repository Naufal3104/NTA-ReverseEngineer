import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../../../data/game_data.dart';
import '../asset_manager.dart';
import '../design_tokens.dart';

/// Fullscreen "General Muster Terrace" — mural drum that rolls hero fragments.
/// Reference: `Tampilan Button General Muster Terrace.jpg`.
///
/// Rebuild rule: every muster is FREE (anti-coin). Original charges coin per
/// draw. The cooldown label is shown but never blocks. The `n/50` counter
/// tracks draws toward the guaranteed high-multiplier fragment.
class GeneralMusterPanel extends StatefulWidget {
  const GeneralMusterPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0xE6000000),
      useSafeArea: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: const GeneralMusterPanel(),
      ),
    );
  }

  @override
  State<GeneralMusterPanel> createState() => _GeneralMusterPanelState();
}

class _GeneralMusterPanelState extends State<GeneralMusterPanel> {
  final math.Random _rng = math.Random();
  bool _skipCutscene = false;
  bool _drumming = false;
  List<int> _lastResults = const [];

  Future<void> _muster(GameState state, int times) async {
    if (_drumming) return;
    setState(() {
      _drumming = true;
      _lastResults = const [];
    });
    final results = <int>[];
    if (!_skipCutscene) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
    }
    for (var i = 0; i < times; i++) {
      final id = state.musterFragments(rng: _rng);
      if (id != null) results.add(id);
    }
    if (!mounted) return;
    setState(() {
      _drumming = false;
      _lastResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5FA98A), Color(0xFF4E9377)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _titleBanner(),
              const SizedBox(height: 6),
              _infoRow(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _drum(state),
                        const SizedBox(height: 8),
                        _guaranteeBanner(),
                        const SizedBox(height: 6),
                        Text(
                          'Free muster on cooldown. 09:49:19',
                          style: NtaText.sm.copyWith(
                            color: const Color(0xFFEAF6E0),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_lastResults.isNotEmpty) _resultsGrid(),
                        const SizedBox(height: 10),
                        _musterRow(state),
                        const SizedBox(height: 6),
                        _skipRow(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: _backButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3E7D63),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF2C5A47), width: 3),
        ),
      ),
      child: Text(
        'General Muster Terrace',
        textAlign: TextAlign.center,
        style: NtaText.display.copyWith(
          color: const Color(0xFFF3F7E4),
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _infoRow() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF0C24A),
            borderRadius: BorderRadius.circular(NtaRadius.pill),
            border: Border.all(color: const Color(0xFF8A6A1F), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.priority_high,
                  size: 16, color: Color(0xFF5A4310)),
              const SizedBox(width: 4),
              Text('Probability Overview',
                  style: NtaText.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A4310),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _drum(GameState state) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedRotation(
          turns: _drumming ? 0.5 : 0,
          duration: const Duration(milliseconds: 650),
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFF6EFD8), Color(0xFFE6D9B4)],
              ),
              border: Border.all(color: const Color(0xFFB23A2E), width: 16),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 16,
                    offset: Offset(0, 8)),
              ],
            ),
            child: const Center(
              child: Icon(Icons.music_note,
                  size: 96, color: Color(0xFFCDBB92)),
            ),
          ),
        ),
        // draw counter, top-right of the drum
        Positioned(
          top: 2,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2C5A47),
              borderRadius: BorderRadius.circular(NtaRadius.pill),
              border: Border.all(color: const Color(0xFFF0C24A), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_florist,
                    size: 14, color: Color(0xFF7FD8A6)),
                const SizedBox(width: 3),
                Text('${state.musterDraws}/${GameState.musterGuarantee}',
                    style: NtaText.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF3F7E4),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _guaranteeBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5D45A),
        borderRadius: BorderRadius.circular(NtaRadius.pill),
        border: Border.all(color: const Color(0xFF8A6A1F), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 16, color: Color(0xFF5A4310)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'More Draws for Guaranteed High-Multiplier Fragments',
              style: NtaText.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5A4310),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultsGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xF2FFF7EF),
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(color: const Color(0xFF2C5A47), width: 2),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final id in _lastResults)
            GestureDetector(
              onTap: () => _showRepairDialog(context, id),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DDC7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF8A6A1F), width: 2),
                    ),
                    child: Image.asset(
                      NtaAssets.heroPortrait(id),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, _, _) => const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(GameState.heroName(id),
                      style: NtaText.xs.copyWith(fontSize: 9)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showRepairDialog(BuildContext context, int id) {
    final state = context.read<GameState>();
    final frags = state.fragmentsOf(id);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NtaColors.surface,
        title: Text(GameState.heroName(id), style: NtaText.title),
        content: Text(
          'Fragments: $frags / ${GameState.portraitFragmentCost}\n'
          '${state.hasPortrait(id) ? 'Portrait repaired: ${GameData.PORTRAIT_GRADE_LABELS[state.portraitGrade(id)]}' : 'Repair to unlock this hero.'}',
          style: NtaText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          if (!state.hasPortrait(id))
            NtaGoldButton(
              'Repair',
              onTap: () {
                state.repairPortrait(id);
                Navigator.of(ctx).pop();
              },
            ),
        ],
      ),
    );
  }

  Widget _musterRow(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(child: _musterBtn('Muster*1', () => _muster(state, 1))),
          const SizedBox(width: 8),
          Expanded(child: _musterBtn('Muster*5', () => _muster(state, 5))),
          const SizedBox(width: 8),
          Expanded(child: _musterBtn('Muster*5', () => _muster(state, 5),
              highlight: true)),
        ],
      ),
    );
  }

  Widget _musterBtn(String label, VoidCallback onTap,
      {bool highlight = false}) {
    return GestureDetector(
      onTap: _drumming ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: highlight
                ? const [Color(0xFFEAF6A6), Color(0xFFC7E56E)]
                : const [Color(0xFFFFE288), Color(0xFFFDD866)],
          ),
          borderRadius: BorderRadius.circular(NtaRadius.button),
          border: Border.all(color: NtaColors.accentBorder, width: 2.5),
          boxShadow: const [
            BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Text(label,
                style: NtaText.bodyBold.copyWith(
                    fontSize: 15, color: NtaColors.onAccent)),
            const SizedBox(height: 2),
            Text('Free',
                style: NtaText.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NtaColors.success)),
          ],
        ),
      ),
    );
  }

  Widget _skipRow() {
    return GestureDetector(
      onTap: () => setState(() => _skipCutscene = !_skipCutscene),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: NtaColors.border, width: 2),
            ),
            child: _skipCutscene
                ? const Icon(Icons.check, size: 14, color: NtaColors.text)
                : null,
          ),
          const SizedBox(width: 6),
          Text('Skip the mustering cutscene.',
              style: NtaText.body.copyWith(
                  fontSize: 13, color: const Color(0xFFF3F7E4))),
        ],
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: NtaColors.surfaceRaised,
          borderRadius: BorderRadius.circular(NtaRadius.button),
          border: Border.all(color: NtaColors.border, width: 2.5),
        ),
        child: const Icon(Icons.chevron_left, size: 30, color: NtaColors.success),
      ),
    );
  }
}