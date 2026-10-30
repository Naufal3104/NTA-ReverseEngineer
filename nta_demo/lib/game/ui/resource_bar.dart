import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';

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
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        border: Border(bottom: BorderSide(color: Colors.amber.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          _buildResourceWidget('🌾', '${state.crop}', '+${rates['crop']!.round()}/h', Colors.orange),
          const SizedBox(width: 14),
          _buildResourceWidget('🪵', '${state.wood}', '+${rates['wood']!.round()}/h', Colors.brown[300]!),
          const SizedBox(width: 14),
          _buildResourceWidget('🪨', '${state.stone}', '+${rates['stone']!.round()}/h', Colors.grey[300]!),
          const SizedBox(width: 14),
          _buildResourceWidget('⚙️', '${state.iron}', '+${rates['iron']!.round()}/h', Colors.blueGrey[200]!),
          const SizedBox(width: 14),
          _buildResourceWidget('💰', '${state.gold}', '+${rates['gold']!.round()}/h', Colors.yellow),
          const Spacer(),
          // Real-time ticking indicators
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.amberAccent),
                const SizedBox(width: 6),
                Text(
                  '$hours:$minutes:$seconds',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${state.season} · Day ${state.dayInSeason}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResourceWidget(String icon, String value, String rate, Color color) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              rate,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

class SeasonIndicator extends StatelessWidget {
  const SeasonIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    
    final seasonColors = {
      'Spring': Colors.green,
      'Summer': Colors.orange,
      'Autumn': Colors.brown,
      'Winter': Colors.blue,
    };
    final seasonIcons = {
      'Spring': '🌱',
      'Summer': '☀️',
      'Autumn': '🍂',
      'Winter': '❄️',
    };
    
    final color = seasonColors[state.season] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(seasonIcons[state.season] ?? '🌱', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.season,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Day ${state.dayInSeason}/3 (Real-time)',
                style: const TextStyle(fontSize: 10, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
