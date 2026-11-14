import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/game_data.dart';
import '../models/game_state.dart';
import '../ui/asset_manager.dart';
import '../ui/design_tokens.dart';

/// Entry screen: title + division selection. No waitlist — pick a division
/// and the season starts immediately (rebuild rule).
class LobbyView extends StatelessWidget {
  const LobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [NtaColors.bg, NtaColors.bgAlt],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LobbyHeader(),
                  const SizedBox(height: 18),
                  for (var i = 0; i < GameData.DIVISIONS.length; i++) ...[
                    _DivisionCard(
                      division: GameData.DIVISIONS[i],
                      selected: state.divisionChosen && state.divisionIndex == i,
                      onEnter: () {
                        final wasActive =
                            state.divisionChosen && state.divisionIndex == i;
                        state.chooseDivision(i);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(wasActive
                                ? '${GameData.DIVISIONS[i]['name']}: '
                                    'sesi dilanjutkan'
                                : '${GameData.DIVISIONS[i]['name']}: '
                                    '${GameData.DIVISIONS[i]['victory']}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    if (i != GameData.DIVISIONS.length - 1)
                      const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 14),
                  _BotDifficultyRow(
                    selected: state.botDifficultyIndex,
                    onPick: state.setBotDifficulty,
                  ),
                  const SizedBox(height: 14),
                  if (state.divisionChosen)
                    _ResumeBar(
                      divisionName: state.divisionName,
                      onResume: () => state.switchView('map'),
                    ),
                  const SizedBox(height: 10),
                  const Text(
                    'Season = 3 hari real-time. Timer berhenti saat game ditutup.',
                    textAlign: TextAlign.center,
                    style: NtaText.sm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LobbyHeader extends StatelessWidget {
  const _LobbyHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          NtaAssets.season(0),
          width: 56,
          height: 56,
          filterQuality: FilterQuality.none,
        ),
        const SizedBox(height: 8),
        const Text(
          'Ninety Thousand Acres',
          textAlign: TextAlign.center,
          style: NtaText.display,
        ),
        const SizedBox(height: 4),
        const Text(
          '九萬畝 · Offline Rebuild',
          textAlign: TextAlign.center,
          style: NtaText.sm,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: NtaColors.surfaceRaised,
            border: Border.all(color: NtaColors.hudBorder, width: 2),
            borderRadius: BorderRadius.circular(NtaRadius.pill),
          ),
          child: const Text(
            'Pilih divisi — langsung main, tanpa daftar',
            style: NtaText.body,
          ),
        ),
      ],
    );
  }
}

class _DivisionCard extends StatelessWidget {
  final Map<String, dynamic> division;
  final bool selected;
  final VoidCallback onEnter;

  const _DivisionCard({
    required this.division,
    required this.selected,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final rules = (division['rules'] as List).cast<String>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ntaPanel().copyWith(
        border: Border.all(
          color: selected ? NtaColors.heroNamePill : NtaColors.border,
          width: selected ? 3 : NtaBorder.panel,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(division['name'] as String, style: NtaText.heading),
                    const SizedBox(height: 2),
                    Text(division['tagline'] as String, style: NtaText.sm),
                  ],
                ),
              ),
              if (selected) ...[
                const Chip(
                  label: Text('AKTIF',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  backgroundColor: NtaColors.accentSoft,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 6),
              ],
              NtaGoldButton(
                selected ? 'Masuk' : 'Pilih',
                onTap: onEnter,
                fontSize: 14,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.emoji_events, size: 15, color: NtaColors.textMuted),
              const SizedBox(width: 5),
              Text(
                'Victory: ${division['victory']}',
                style: NtaText.bodyBold.copyWith(color: NtaColors.success),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: ntaRaisedCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < rules.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == rules.length - 1 ? 0 : 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${i + 1}. ', style: NtaText.body),
                        Expanded(child: Text(rules[i], style: NtaText.body)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (division['tierWinPoints'] == true)
                _tag('Tier Win Points', NtaColors.heroNamePill),
              if (division['unionMarket'] == 'free')
                _tag('Free Market', NtaColors.success),
              if (division['unionMarket'] == 'union')
                _tag('Union Market', NtaColors.textMuted),
              if (division['autoUnion'] == true)
                _tag('Union otomatis', NtaColors.textMuted),
              if (division['rewardPointsUnlimited'] == true)
                _tag('Reward Points tanpa batas', NtaColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: NtaColors.surfaceSunk,
        border: Border.all(color: NtaColors.borderSoft, width: NtaBorder.hairline),
        borderRadius: BorderRadius.circular(NtaRadius.pill),
      ),
      child: Text(
        text,
        style: NtaText.xs.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Bot difficulty picker: 3 levels, applies to the rival unions in every
/// division (rebuild rule: offline opponents are bots).
class _BotDifficultyRow extends StatelessWidget {
  final int selected;
  final void Function(int) onPick;

  const _BotDifficultyRow({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ntaPanel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_outlined, size: 18, color: NtaColors.text),
              const SizedBox(width: 6),
              Text('Bot Difficulty', style: NtaText.bodyBold),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < GameData.BOT_DIFFICULTIES.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onPick(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: i == selected
                            ? NtaColors.accentSoft
                            : NtaColors.surfaceSunk,
                        borderRadius: BorderRadius.circular(NtaRadius.card),
                        border: Border.all(
                          color: i == selected ? NtaColors.heroNamePill : NtaColors.borderSoft,
                          width: i == selected ? 2 : NtaBorder.hairline,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            GameData.BOT_DIFFICULTIES[i]['name'] as String,
                            style: NtaText.bodyBold.copyWith(
                              color: i == selected ? NtaColors.success : NtaColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            GameData.BOT_DIFFICULTIES[i]['tagline'] as String,
                            textAlign: TextAlign.center,
                            style: NtaText.xs,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ResumeBar extends StatelessWidget {
  final String divisionName;
  final VoidCallback onResume;

  const _ResumeBar({required this.divisionName, required this.onResume});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ntaCard(selected: true),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline, size: 20, color: NtaColors.text),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Sesi aktif: $divisionName', style: NtaText.bodyBold),
          ),
          NtaGoldButton(
            'Lanjut',
            onTap: onResume,
            fontSize: 14,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }
}
