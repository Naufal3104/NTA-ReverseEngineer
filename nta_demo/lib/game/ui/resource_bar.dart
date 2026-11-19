import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import 'asset_manager.dart';
import 'design_tokens.dart';

class ResourceBar extends StatelessWidget {
  const ResourceBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final rates = state.getHourlyProduction();

    final hours = (state.elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((state.elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.elapsedSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: NtaColors.bgAlt,
      child: Row(
        children: [
          NtaResourcePill(
            icon: NtaResIcon('crop', size: 16),
            value: '${state.crop}',
            rate: '+${rates['crop']!.round()}/h',
          ),
          const SizedBox(width: NtaSpace.itemGap),
          NtaResourcePill(
            icon: NtaResIcon('wood', size: 16),
            value: '${state.wood}',
            rate: '+${rates['wood']!.round()}/h',
          ),
          const SizedBox(width: NtaSpace.itemGap),
          NtaResourcePill(
            icon: NtaResIcon('stone', size: 16),
            value: '${state.stone}',
            rate: '+${rates['stone']!.round()}/h',
          ),
          const SizedBox(width: NtaSpace.itemGap),
          NtaResourcePill(
            icon: NtaResIcon('iron', size: 16),
            value: '${state.iron}',
            rate: 'chest',
          ),
          const SizedBox(width: NtaSpace.itemGap),
          NtaResourcePill(
            icon: NtaResIcon('exp_scroll', size: 16),
            value: '${state.expScroll}',
            rate: 'chest',
          ),
          const Spacer(),
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: NtaAssets.chromeDecoration('panel_cream', color: NtaColors.hudSurface),
            child: Row(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(NtaColors.hudText, BlendMode.srcIn),
                  child: NtaAssets.chromeImage('ic_chat', width: 16, height: 16, fit: BoxFit.contain),
                ),
                const SizedBox(width: 6),
                Text(
                  '$hours:$minutes:$seconds',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: NtaColors.hudText,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${state.season} · D${state.dayInSeason}',
                  style: NtaText.xs.copyWith(color: NtaColors.hudText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SeasonIndicator extends StatelessWidget {
  const SeasonIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    final seasonColors = {
      'Spring': NtaColors.success,
      'Summer': const Color(0xFFC98B1E),
      'Autumn': const Color(0xFF9A6A3A),
      'Winter': const Color(0xFF2F6E77),
    };
    final seasonIndex = {
      'Spring': 0,
      'Summer': 1,
      'Autumn': 2,
      'Winter': 3,
    };

    final color = seasonColors[state.season] ?? NtaColors.textMuted;
    final idx = seasonIndex[state.season] ?? 0;
    final baseDecor = NtaAssets.chromeDecoration('season_bg_$idx', color: NtaColors.surfaceCard);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: NtaSpace.x5, vertical: NtaSpace.x3),
        decoration: BoxDecoration(
          color: baseDecor.color,
          image: baseDecor.image,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(NtaRadius.card),
          boxShadow: baseDecor.boxShadow,
          gradient: baseDecor.gradient,
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            NtaAssets.season(idx),
            width: 22,
            height: 22,
            filterQuality: FilterQuality.none,
          ),
          const SizedBox(width: NtaSpace.itemGap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.season, style: NtaText.bodyBold),
              Text('Day ${state.dayInSeason}/3', style: NtaText.caption),
            ],
          ),
        ],
      ),
    );
  }
}
