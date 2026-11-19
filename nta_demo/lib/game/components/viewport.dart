import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import 'game_map.dart';
import 'capital_interior_view.dart';
import 'lobby_view.dart';
import 'plot_interior_view.dart';

class GameViewport extends StatelessWidget {
  const GameViewport({super.key});

  @override
  Widget build(BuildContext context) {
    // Use context.select to only rebuild when view changes
    final view = context.select((GameState s) => s.currentView);

    // Use IndexedStack to keep all views alive (preserves state, avoids rebuild cost)
    // Order: 0=lobby, 1=map, 2=capital, 3=plot
    int index;
    switch (view) {
      case 'lobby':
        index = 0;
        break;
      case 'map':
        index = 1;
        break;
      case 'capital':
        index = 2;
        break;
      case 'plot':
        index = 3;
        break;
      default:
        index = 1;
    }

    return IndexedStack(
      index: index,
      children: [
        const LobbyView(),
        const GameMap(),
        const CapitalInteriorView(),
        const PlotInteriorView(),
      ],
    );
  }
}
