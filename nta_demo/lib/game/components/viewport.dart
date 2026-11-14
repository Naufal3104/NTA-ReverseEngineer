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
    final state = context.watch<GameState>();
    final view = state.currentView;

    return Stack(
      children: [
        // Main content area
        if (view == 'lobby')
          const LobbyView()
        else if (view == 'map')
          GameMap()
        else if (view == 'capital')
          CapitalInteriorView()
        else if (view == 'plot')
          PlotInteriorView(row: state.plotViewRow, col: state.plotViewCol),
      ],
    );
  }
}
