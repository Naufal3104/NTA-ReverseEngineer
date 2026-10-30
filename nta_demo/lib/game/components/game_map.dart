import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../../data/game_data.dart';

class GameMap extends StatefulWidget {
  const GameMap({super.key});

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  final TransformationController _transController = TransformationController();
  bool _hasCentered = false;

  void _centerOnPlayer(Size viewportSize) {
    if (_hasCentered || viewportSize.width == 0 || viewportSize.height == 0) return;
    _hasCentered = true;

    const double initialScale = 0.85;
    const double tileSize = GameData.TILE_SIZE * initialScale;
    const double centerRow = 39.5;
    const double centerCol = 39.5;

    final double targetX = (viewportSize.width / 2.0) - (centerCol * tileSize);
    final double targetY = (viewportSize.height / 2.0) - (centerRow * tileSize);

    _transController.value = Matrix4.identity()
      ..translateByDouble(targetX, targetY, 0.0, 1.0)
      ..scaleByDouble(initialScale, initialScale, 1.0, 1.0);
  }

  @override
  void dispose() {
    _transController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final selectedTile = state.selectedTile;
    final double mapPixelWidth = GameData.MAP_WIDTH * GameData.TILE_SIZE.toDouble();
    final double mapPixelHeight = GameData.MAP_HEIGHT * GameData.TILE_SIZE.toDouble();

    final bool isCapitalSelected = selectedTile != null &&
        state.isCapitalTile(selectedTile[0], selectedTile[1]);

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _centerOnPlayer(Size(constraints.maxWidth, constraints.maxHeight));
        });

        return Stack(
          children: [
            Container(
              color: const Color(0xFF0F141C),
              child: InteractiveViewer(
                transformationController: _transController,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(1200),
                minScale: 0.15,
                maxScale: 2.5,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    final double x = details.localPosition.dx;
                    final double y = details.localPosition.dy;
                    final int col = (x / GameData.TILE_SIZE).floor();
                    final int row = (y / GameData.TILE_SIZE).floor();

                    if (row >= 0 && row < GameData.MAP_HEIGHT && col >= 0 && col < GameData.MAP_WIDTH) {
                      state.selectTile(row, col);
                    }
                  },
                  child: CustomPaint(
                    size: Size(mapPixelWidth, mapPixelHeight),
                    painter: MapPainter(
                      map: state.map,
                      conqueredPlots: state.conqueredPlots,
                      selectedTile: selectedTile,
                      capitalMinRow: GameState.capitalMinRow,
                      capitalMaxRow: GameState.capitalMaxRow,
                      capitalMinCol: GameState.capitalMinCol,
                      capitalMaxCol: GameState.capitalMaxCol,
                    ),
                  ),
                ),
              ),
            ),

            // Floating Tile Action Bar
            if (selectedTile != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xF0181F30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCapitalSelected ? Colors.amber : Colors.blueAccent,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCapitalSelected ? Icons.fort : Icons.location_on,
                          color: isCapitalSelected ? Colors.amber : Colors.blueAccent,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isCapitalSelected
                                  ? 'Imperial Capital Citadel (2x2 Space)'
                                  : 'Tile (${selectedTile[0]}, ${selectedTile[1]}) - ${state.getTileTerrainName(selectedTile[0], selectedTile[1])}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                            ),
                            Text(
                              isCapitalSelected
                                  ? 'Contains Barracks, Smithy, Hall of Heroes & Workshops'
                                  : (state.isTileConquered(selectedTile[0], selectedTile[1])
                                      ? 'Controlled Domain (Secured with Watchtower & Player Flag)'
                                      : 'Wild Territory (11x11 Grid with 4 Gates)'),
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        if (isCapitalSelected)
                          ElevatedButton.icon(
                            onPressed: () => _openCapitalInterior(context),
                            icon: const Icon(Icons.meeting_room, size: 16),
                            label: const Text('Enter Capital'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () => _openPlotInterior(context, selectedTile[0], selectedTile[1]),
                            icon: const Icon(Icons.grid_view, size: 16),
                            label: const Text('Inspect Plot (11x11)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openCapitalInterior(BuildContext context) {
    context.read<GameState>().switchView('capital');
  }

  void _openPlotInterior(BuildContext context, int row, int col) {
    context.read<GameState>().setPlotView(row, col);
  }
}

class MapPainter extends CustomPainter {
  final List<List<int>> map;
  final Set<String> conqueredPlots;
  final List<int>? selectedTile;
  final int capitalMinRow;
  final int capitalMaxRow;
  final int capitalMinCol;
  final int capitalMaxCol;

  MapPainter({
    required this.map,
    required this.conqueredPlots,
    this.selectedTile,
    required this.capitalMinRow,
    required this.capitalMaxRow,
    required this.capitalMinCol,
    required this.capitalMaxCol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (map.isEmpty) return;

    final double tileSize = GameData.TILE_SIZE.toDouble();
    final Paint bgPaint = Paint()..style = PaintingStyle.fill;
    final Paint gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0x18FFFFFF);

    // Terrain Colors
    const Color cGrass = Color(0xFF386629);
    const Color cForest = Color(0xFF224419);
    const Color cMountain = Color(0xFF6B5844);
    const Color cWater = Color(0xFF1E5F8A);
    const Color cSand = Color(0xFFB5A165);

    // 1. Draw base terrain grid
    for (int row = 0; row < map.length; row++) {
      for (int col = 0; col < map[row].length; col++) {
        final int terrain = map[row][col];
        final Rect rect = Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize);

        switch (terrain) {
          case 1:
            bgPaint.color = cForest;
            canvas.drawRect(rect, bgPaint);
            _drawForestDetails(canvas, rect);
            break;
          case 2:
            bgPaint.color = cMountain;
            canvas.drawRect(rect, bgPaint);
            _drawMountainDetails(canvas, rect);
            break;
          case 3:
            bgPaint.color = cWater;
            canvas.drawRect(rect, bgPaint);
            _drawWaterDetails(canvas, rect);
            break;
          case 4:
            bgPaint.color = cSand;
            canvas.drawRect(rect, bgPaint);
            break;
          case 0:
          default:
            bgPaint.color = cGrass;
            canvas.drawRect(rect, bgPaint);
            _drawGrassDetails(canvas, rect);
            break;
        }

        canvas.drawRect(rect, gridPaint);

        // 2. Conquered plots (outside capital): draw automatic Watchtower & Player Flag
        final bool isCap = row >= capitalMinRow && row <= capitalMaxRow &&
                           col >= capitalMinCol && col <= capitalMaxCol;
        if (!isCap && conqueredPlots.contains('$row,$col')) {
          _drawConqueredWatchtowerAndFlag(canvas, rect);
        }
      }
    }

    // 3. Draw Grand 2x2 Capital Citadel
    _drawGrandCapitalCitadel(canvas, tileSize);

    // 4. Selection Highlight
    if (selectedTile != null) {
      final int sRow = selectedTile![0];
      final int sCol = selectedTile![1];

      final bool isCap = sRow >= capitalMinRow && sRow <= capitalMaxRow &&
                         sCol >= capitalMinCol && sCol <= capitalMaxCol;

      Rect selRect;
      if (isCap) {
        // Highlight entire 2x2 Capital
        selRect = Rect.fromLTWH(
          capitalMinCol * tileSize,
          capitalMinRow * tileSize,
          (capitalMaxCol - capitalMinCol + 1) * tileSize,
          (capitalMaxRow - capitalMinRow + 1) * tileSize,
        );
      } else {
        selRect = Rect.fromLTWH(sCol * tileSize, sRow * tileSize, tileSize, tileSize);
      }

      // Highlight fill
      final Paint selFill = Paint()
        ..style = PaintingStyle.fill
        ..color = isCap ? const Color(0x44FFD700) : const Color(0x4400B4D8);
      canvas.drawRect(selRect, selFill);

      // Border
      final Paint borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = isCap ? const Color(0xFFFFD700) : const Color(0xFF00B4D8);
      canvas.drawRect(selRect, borderPaint);
    }
  }

  // Draw Grand 2x2 Capital Citadel (spans rows 39-40, cols 39-40)
  void _drawGrandCapitalCitadel(Canvas canvas, double tileSize) {
    final double left = capitalMinCol * tileSize;
    final double top = capitalMinRow * tileSize;
    final double width = (capitalMaxCol - capitalMinCol + 1) * tileSize; // 2 tiles = 128px
    final double height = (capitalMaxRow - capitalMinRow + 1) * tileSize;

    final Rect citadelRect = Rect.fromLTWH(left, top, width, height);

    // Stone fortress courtyard
    final Paint courtPaint = Paint()..color = const Color(0xFF423B36);
    canvas.drawRRect(RRect.fromRectAndRadius(citadelRect.deflate(4), const Radius.circular(8)), courtPaint);

    // Citadel walls
    final Paint wallPaint = Paint()
      ..color = const Color(0xFF8B2B2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawRRect(RRect.fromRectAndRadius(citadelRect.deflate(6), const Radius.circular(6)), wallPaint);

    // Central Palace Pavilions
    final double cx = citadelRect.center.dx;
    final double cy = citadelRect.center.dy;

    final Paint palaceBase = Paint()..color = const Color(0xFF9E2A2B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 6), width: 68, height: 50), const Radius.circular(6)),
      palaceBase,
    );

    // Golden Imperial Pagoda Roof
    final Path roof = Path()
      ..moveTo(cx - 44, cy + 6)
      ..lineTo(cx, cy - 32)
      ..lineTo(cx + 44, cy + 6)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFFFB703));

    // Secondary upper roof
    final Path upperRoof = Path()
      ..moveTo(cx - 26, cy - 14)
      ..lineTo(cx, cy - 38)
      ..lineTo(cx + 26, cy - 14)
      ..close();
    canvas.drawPath(upperRoof, Paint()..color = const Color(0xFFFB8500));

    // Corner Watchtowers on Citadel (4 corners of 2x2 space)
    final Paint towerPaint = Paint()..color = const Color(0xFF2B2D42);
    final double r12 = 12.0;
    canvas.drawCircle(Offset(left + r12 + 6, top + r12 + 6), r12, towerPaint);
    canvas.drawCircle(Offset(left + width - r12 - 6, top + r12 + 6), r12, towerPaint);
    canvas.drawCircle(Offset(left + r12 + 6, top + height - r12 - 6), r12, towerPaint);
    canvas.drawCircle(Offset(left + width - r12 - 6, top + height - r12 - 6), r12, towerPaint);

    // Imperial Player Flag in Center
    final Path flag = Path()
      ..moveTo(cx, cy - 38)
      ..lineTo(cx + 22, cy - 46)
      ..lineTo(cx, cy - 54)
      ..close();
    canvas.drawPath(flag, Paint()..color = Colors.redAccent);
    canvas.drawLine(Offset(cx, cy - 36), Offset(cx, cy - 56), Paint()..color = Colors.white..strokeWidth = 2.5);
  }

  // Automatic Watchtower and Player Flag on conquered plots
  void _drawConqueredWatchtowerAndFlag(Canvas canvas, Rect r) {
    final double cx = r.center.dx;
    final double cy = r.center.dy;

    // Territory control border
    final Paint borderPaint = Paint()
      ..color = const Color(0x66FFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(r.deflate(2), borderPaint);

    // Automatic Watchtower base
    final Paint towerBase = Paint()..color = const Color(0xFF4A4E69);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 6), width: 18, height: 26), const Radius.circular(2)),
      towerBase,
    );

    // Observation deck
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - 8), width: 24, height: 8),
      Paint()..color = const Color(0xFF22223B),
    );

    // Player Ownership Flag
    final Paint flagPaint = Paint()..color = const Color(0xFFE63946);
    final Path flagPath = Path()
      ..moveTo(cx + 2, cy - 12)
      ..lineTo(cx + 14, cy - 17)
      ..lineTo(cx + 2, cy - 22)
      ..close();
    canvas.drawPath(flagPath, flagPaint);
    canvas.drawLine(Offset(cx + 2, cy - 8), Offset(cx + 2, cy - 24), Paint()..color = Colors.white..strokeWidth = 1.5);
  }

  void _drawGrassDetails(Canvas canvas, Rect r) {
    final Paint p = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 1.0;
    canvas.drawLine(r.center + const Offset(-10, 8), r.center + const Offset(-8, -4), p);
    canvas.drawLine(r.center + const Offset(8, 6), r.center + const Offset(10, -6), p);
  }

  void _drawForestDetails(Canvas canvas, Rect r) {
    final Paint treePaint = Paint()
      ..color = const Color(0xFF142E0E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(r.center + const Offset(-12, 6), 9, treePaint);
    canvas.drawCircle(r.center + const Offset(12, 4), 10, treePaint);
    canvas.drawCircle(r.center + const Offset(0, -8), 12, treePaint);
  }

  void _drawMountainDetails(Canvas canvas, Rect r) {
    final Path path = Path();
    path.moveTo(r.left + 8, r.bottom - 8);
    path.lineTo(r.left + r.width * 0.45, r.top + 10);
    path.lineTo(r.right - 10, r.bottom - 8);
    path.close();

    final Paint mountainPaint = Paint()
      ..color = const Color(0xFF4A3C2D)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, mountainPaint);
  }

  void _drawWaterDetails(Canvas canvas, Rect r) {
    final Paint wave = Paint()
      ..color = const Color(0x44FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(r.center + const Offset(-14, -6), r.center + const Offset(6, -6), wave);
    canvas.drawLine(r.center + const Offset(-4, 6), r.center + const Offset(14, 6), wave);
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.map != map ||
        oldDelegate.conqueredPlots != conqueredPlots ||
        oldDelegate.selectedTile != selectedTile;
  }
}
