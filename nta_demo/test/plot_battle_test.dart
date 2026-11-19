import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nta_demo/game/components/plot_interior_view.dart';
import 'package:nta_demo/game/models/game_state.dart';

void main() {
  testWidgets('assault plot renders battle tokens and replay', (tester) async {
    final state = GameState();
    state.generateMap();

    // Find a hostile plot near the capital.
    int? row;
    int? col;
    for (var r = 0; r < 80 && row == null; r++) {
      for (var c = 0; c < 80; c++) {
        final p = state.getPlotData(r, c);
        if (p != null && !state.isTileConquered(r, c) && (p['level'] as int) == 1) {
          row = r;
          col = c;
          break;
        }
      }
    }
    expect(row, isNotNull);

    state.setPlotView(row!, col!);
    await tester.pumpWidget(
      ChangeNotifierProvider<GameState>.value(
        value: state,
        child: const MaterialApp(home: PlotInteriorView()),
      ),
    );
    await tester.pumpAndSettle();

    final button = find.textContaining('Assault Plot');
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    tester.takeException();

    expect(find.textContaining('Battle Won!'), findsWidgets);
    expect(find.textContaining('actions.'), findsOneWidget);
    expect(find.textContaining('Losses:'), findsOneWidget);
    // Replay slider present.
    expect(find.byType(Slider), findsOneWidget);

    state.dispose();
    await tester.pumpWidget(const SizedBox());
  });
}
