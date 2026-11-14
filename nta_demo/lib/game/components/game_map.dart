import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../../data/game_data.dart';
import '../ui/asset_manager.dart';
import '../ui/design_tokens.dart';

class GameMap extends StatefulWidget {
  const GameMap({super.key});

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  final TransformationController _transController = TransformationController();
  bool _hasCentered = false;

  /// Sprite ikon plot asli (level 2-5 x crop/wood/stone) dimuat sekali.
  final Map<String, ui.Image> _plotSprites = {};

  /// Tile terrain asli dari atlas game (tanah/air/hutan/gunung/pasir).
  final Map<String, ui.Image> _terrainSprites = {};

  @override
  void initState() {
    super.initState();
    _loadSprites();
  }

  Future<ui.Image?> _loadImage(String path) async {
    try {
      final data = await rootBundle.load(path);
      // Honour the view window: on web small assets are slices of a shared
      // buffer, and `buffer.asUint8List()` would include neighbouring bytes.
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      debugPrint('sprite load failed: $path ($e)');
      return null;
    }
  }

  Future<void> _loadSprites() async {
    final jobs = <Future<void>>[];
    Future<void> put(Map<String, ui.Image> into, String key, String path) async {
      final img = await _loadImage(path);
      if (img != null) into[key] = img;
    }

    const resources = ['crop', 'wood', 'stone'];
    for (final res in resources) {
      for (int lv = 2; lv <= 5; lv++) {
        final path = NtaAssets.plotIcon(res, lv);
        if (path == null) continue;
        jobs.add(put(_plotSprites, '$res:$lv', path));
      }
    }
    jobs.add(put(_terrainSprites, 'water', NtaAssets.waterTile));
    jobs.add(put(_terrainSprites, 'forest', NtaAssets.forestTile));
    for (int v = 0; v < 5; v++) {
      jobs.add(put(_terrainSprites, 'mountain$v', NtaAssets.mountainTile(v)));
    }
    for (int v = 0; v < 4; v++) {
      jobs.add(put(_terrainSprites, 'grass$v', NtaAssets.grassTuft(v)));
    }
    for (int d = 0; d <= 9; d++) {
      jobs.add(put(_terrainSprites, 'digit$d', NtaAssets.flagNum('$d')));
    }
    await Future.wait(jobs);
    if (mounted) setState(() {});
  }

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
    final remainsSel = selectedTile == null
        ? null
        : state.remainsAt(selectedTile[0], selectedTile[1]);
    final bool isRemainsSelected = remainsSel != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _centerOnPlayer(Size(constraints.maxWidth, constraints.maxHeight));
        });

        return Stack(
          children: [
            Container(
              color: NtaColors.bg,
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
                      plotSprites: _plotSprites,
                      terrainSprites: _terrainSprites,
                      plotLevelAt: (r, c) => state.getPlotData(r, c)?['level'] as int? ?? 1,
                      plotResourceAt: (r, c) => state.getPlotData(r, c)?['resource'] as String? ?? 'crop',
                      remains: state.remains.values.toList(),
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
                bottom: 96,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: NtaSpace.panelPad,
                      vertical: NtaSpace.x5,
                    ),
                    decoration: BoxDecoration(
                      color: NtaColors.surface,
                      borderRadius: BorderRadius.circular(NtaRadius.panel),
                      border: Border.all(color: NtaColors.border, width: NtaBorder.panel),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCapitalSelected ? Icons.fort : Icons.location_on,
                          color: isCapitalSelected ? NtaColors.heroNamePill : NtaColors.textMuted,
                        ),
                        const SizedBox(width: NtaSpace.itemGap),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isCapitalSelected
                                    ? 'Imperial Capital Citadel (2x2 Space)'
                                    : isRemainsSelected
                                        ? '${remainsSel['name']} Remains (2x2 Space)'
                                        : 'Tile (${selectedTile[0]}, ${selectedTile[1]}) - ${state.getTileTerrainName(selectedTile[0], selectedTile[1])}',
                                style: NtaText.bodyBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isCapitalSelected
                                    ? 'Contains Barracks, Smithy, Hall of Heroes & Workshops'
                                    : isRemainsSelected
                                        ? 'Neutral capital · Lv.${remainsSel['level']} · held by '
                                            '${remainsSel['owner'] == 'player' ? 'you' : remainsSel['owner']}'
                                        : (state.isTileConquered(selectedTile[0], selectedTile[1])
                                            ? 'Controlled Domain (Secured with Watchtower & Player Flag)'
                                            : 'Wild Territory (11x11 Grid with 4 Gates)'),
                                style: NtaText.caption,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: NtaSpace.itemGap),
                        NtaGoldButton(
                          isCapitalSelected
                              ? 'Enter Capital'
                              : isRemainsSelected
                                  ? 'Enter Remains'
                                  : 'Inspect Plot',
                          fontSize: 13,
                          padding: const EdgeInsets.symmetric(
                            horizontal: NtaSpace.x5,
                            vertical: NtaSpace.x3,
                          ),
                          onTap: isCapitalSelected
                              ? () => _openCapitalInterior(context)
                              : () => _openPlotInterior(context, selectedTile[0], selectedTile[1]),
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
  final Map<String, ui.Image> plotSprites;
  final Map<String, ui.Image> terrainSprites;
  final int Function(int row, int col) plotLevelAt;
  final String Function(int row, int col) plotResourceAt;
  final List<Map<String, dynamic>> remains;
  final List<int>? selectedTile;
  final int capitalMinRow;
  final int capitalMaxRow;
  final int capitalMinCol;
  final int capitalMaxCol;

  MapPainter({
    required this.map,
    required this.conqueredPlots,
    required this.plotSprites,
    required this.terrainSprites,
    required this.plotLevelAt,
    required this.plotResourceAt,
    required this.remains,
    this.selectedTile,
    required this.capitalMinRow,
    required this.capitalMaxRow,
    required this.capitalMinCol,
    required this.capitalMaxCol,
  });

  Map<String, dynamic>? _remainsAt(int row, int col) {
    for (final r in remains) {
      final rr = r['row'] as int;
      final cc = r['col'] as int;
      if (row >= rr && row <= rr + 1 && col >= cc && col <= cc + 1) return r;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (map.isEmpty) return;

    final double tileSize = GameData.TILE_SIZE.toDouble();
    final Paint bgPaint = Paint()..style = PaintingStyle.fill;
    final Paint gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0x2A4E4037);

    // Terrain Colors
    const Color cGrass = NtaColors.mapGreenA;
    const Color cForest = Color(0xFFA8BE63);
    const Color cMountain = Color(0xFFC2AE86);
    const Color cWater = Color(0xFF8FC7E0);
    const Color cSand = NtaColors.mapRoad;

    // 1. Draw base terrain grid
    for (int row = 0; row < map.length; row++) {
      for (int col = 0; col < map[row].length; col++) {
        final int terrain = map[row][col];
        final Rect rect = Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize);

        // Base: grassland colour; the original atlas has no seamless grass fill
        // (grass_101-104 are sparse tufts), so tufts are drawn as an overlay.
        bgPaint.color = cGrass;
        canvas.drawRect(rect, bgPaint);

        switch (terrain) {
          case 1:
            if (terrainSprites['forest'] != null) {
              _drawTile(canvas, rect, terrainSprites['forest']!);
            } else {
              bgPaint.color = cForest;
              canvas.drawRect(rect, bgPaint);
              _drawForestDetails(canvas, rect);
            }
            break;
          case 2:
            final mountain = terrainSprites['mountain${(row + col) % 5}'];
            if (mountain != null) {
              _drawTile(canvas, rect, mountain);
            } else {
              bgPaint.color = cMountain;
              canvas.drawRect(rect, bgPaint);
              _drawMountainDetails(canvas, rect);
            }
            break;
          case 3:
            if (terrainSprites['water'] != null) {
              _drawTile(canvas, rect, terrainSprites['water']!);
            } else {
              bgPaint.color = cWater;
              canvas.drawRect(rect, bgPaint);
              _drawWaterDetails(canvas, rect);
            }
            break;
          case 4:
            if (terrainSprites['sand'] != null) {
              _drawTile(canvas, rect, terrainSprites['sand']!);
            } else {
              bgPaint.color = cSand;
              canvas.drawRect(rect, bgPaint);
            }
            break;
          case 0:
          default:
            final tuft = terrainSprites['grass${(row * 7 + col * 3) % 4}'];
            if (tuft != null) {
              _drawTileOverlay(canvas, rect, tuft);
            } else {
              _drawGrassDetails(canvas, rect);
            }
            break;
        }

        canvas.drawRect(rect, gridPaint);

        final bool isCap = row >= capitalMinRow && row <= capitalMaxRow &&
                           col >= capitalMinCol && col <= capitalMaxCol;

        // 2a. Original plot-resource sprite (levels 2-5) — anchors the tile to the
        // real game's land.json icon per (resource, level).
        final bool isRemains = _remainsAt(row, col) != null;
        if (!isCap && !isRemains) {
          final lv = plotLevelAt(row, col);
          final sprite = plotSprites['${plotResourceAt(row, col)}:$lv'];
          if (sprite != null) {
            _drawSprite(canvas, rect, sprite);
          }
          // Level badge — digit glyphs from the original map_flag_num atlas.
          final digit = terrainSprites['digit$lv'];
          if (lv > 1) {
            _drawDigitBadge(canvas, rect, digit);
          }
        }

        // 2b. Conquered plots (outside capital): draw automatic Watchtower & Player Flag
        if (!isCap && conqueredPlots.contains('$row,$col')) {
          _drawConqueredWatchtowerAndFlag(canvas, rect);
        }
      }
    }

    // 3. Draw Grand 2x2 Capital Citadel
    _drawGrandCapitalCitadel(canvas, tileSize);

    // 3b. Remains (neutral capitals) — 2x2 footprint each.
    for (final r in remains) {
      _drawRemains(canvas, tileSize, r);
    }

    // 4. Selection Highlight
    if (selectedTile != null) {
      final int sRow = selectedTile![0];
      final int sCol = selectedTile![1];

      final bool isCap = sRow >= capitalMinRow && sRow <= capitalMaxRow &&
                         sCol >= capitalMinCol && sCol <= capitalMaxCol;
      final selRemains = _remainsAt(sRow, sCol);

      Rect selRect;
      if (isCap) {
        // Highlight entire 2x2 Capital
        selRect = Rect.fromLTWH(
          capitalMinCol * tileSize,
          capitalMinRow * tileSize,
          (capitalMaxCol - capitalMinCol + 1) * tileSize,
          (capitalMaxRow - capitalMinRow + 1) * tileSize,
        );
      } else if (selRemains != null) {
        selRect = Rect.fromLTWH(
          (selRemains['col'] as int) * tileSize,
          (selRemains['row'] as int) * tileSize,
          tileSize * 2,
          tileSize * 2,
        );
      } else {
        selRect = Rect.fromLTWH(sCol * tileSize, sRow * tileSize, tileSize, tileSize);
      }

      // Highlight fill
      final Paint selFill = Paint()
        ..style = PaintingStyle.fill
        ..color = isCap ? const Color(0x55FFDA6B) : const Color(0x553A7325);
      canvas.drawRect(selRect, selFill);

      // Border
      final Paint borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = isCap ? NtaColors.accentBorder : NtaColors.success;
      canvas.drawRect(selRect, borderPaint);
    }
  }

  /// Remains: 2x2 neutral capital. Colour = owner (neutral stone grey,
  /// player imperial red, rival union slate blue), with a level badge.
  void _drawRemains(Canvas canvas, double tileSize, Map<String, dynamic> r) {
    final double left = (r['col'] as int) * tileSize;
    final double top = (r['row'] as int) * tileSize;
    final Rect rect = Rect.fromLTWH(left, top, tileSize * 2, tileSize * 2);
    final String owner = r['owner'] as String? ?? 'neutral';

    final Color wallColor;
    final Color roofColor;
    switch (owner) {
      case 'player':
        wallColor = const Color(0xFF8B2B2B);
        roofColor = const Color(0xFFFFB703);
        break;
      case 'neutral':
        wallColor = const Color(0xFF5A5F6A);
        roofColor = const Color(0xFF9AA3AE);
        break;
      default:
        wallColor = const Color(0xFF33415C);
        roofColor = const Color(0xFF6C8EBF);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(8)),
      Paint()..color = const Color(0xFF3B3A38),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(6), const Radius.circular(6)),
      Paint()
        ..color = wallColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0,
    );

    final double cx = rect.center.dx;
    final double cy = rect.center.dy;

    // Keep/tower block + roof, smaller than the Capital citadel.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 8), width: 48, height: 38),
        const Radius.circular(5),
      ),
      Paint()..color = wallColor,
    );
    final Path roof = Path()
      ..moveTo(cx - 32, cy + 10)
      ..lineTo(cx, cy - 20)
      ..lineTo(cx + 32, cy + 10)
      ..close();
    canvas.drawPath(roof, Paint()..color = roofColor);

    // Corner turrets.
    final Paint turret = Paint()..color = const Color(0xFF2B2D42);
    canvas.drawCircle(Offset(left + 16, top + 16), 9, turret);
    canvas.drawCircle(Offset(rect.right - 16, top + 16), 9, turret);
    canvas.drawCircle(Offset(left + 16, rect.bottom - 16), 9, turret);
    canvas.drawCircle(Offset(rect.right - 16, rect.bottom - 16), 9, turret);

    // Level badge in the bottom-right corner.
    final level = (r['level'] as int?) ?? 1;
    final Rect badge = Rect.fromLTWH(
      rect.right - 26,
      rect.bottom - 20,
      22,
      16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badge, const Radius.circular(3)),
      Paint()..color = const Color(0xD92B2118),
    );
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: '$level',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(badge.center.dx - tp.width / 2, badge.center.dy - tp.height / 2));
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

  /// Draw an extracted sprite stretched to fill a tile exactly.
  void _drawTile(Canvas canvas, Rect tile, ui.Image sprite) {
    final Paint p = Paint()..filterQuality = FilterQuality.none;
    canvas.drawImageRect(
      sprite,
      Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
      tile,
      p,
    );
  }

  /// Draw an original terrain overlay centred in a tile (transparent edges).
  void _drawTileOverlay(Canvas canvas, Rect tile, ui.Image? sprite) {
    if (sprite == null) return;
    final double side = tile.shortestSide;
    final Rect dst = Rect.fromCenter(
      center: tile.center,
      width: side,
      height: side,
    );
    final Paint p = Paint()..filterQuality = FilterQuality.none;
    canvas.drawImageRect(
      sprite,
      Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
      dst,
      p,
    );
  }

  /// Draw a plot-level digit in the tile's bottom-right corner.
  ///
  /// The atlas glyphs are near-white, so a dark rounded backing keeps them
  /// legible over the pale grassland.
  void _drawDigitBadge(Canvas canvas, Rect tile, ui.Image? digit) {
    const double h = 15.0;
    final double w = digit == null ? 10.0 : h * digit.width / digit.height;
    final Rect dst = Rect.fromLTWH(tile.right - w - 5, tile.bottom - h - 5, w, h);

    canvas.drawRRect(
      RRect.fromRectAndRadius(dst.inflate(1.5), const Radius.circular(3)),
      Paint()..color = const Color(0xD92B2118),
    );
    if (digit == null) return;
    canvas.drawImageRect(
      digit,
      Rect.fromLTWH(0, 0, digit.width.toDouble(), digit.height.toDouble()),
      dst,
      Paint()..filterQuality = FilterQuality.none,
    );
  }

  /// Draw an extracted original sprite centred in a map tile.
  void _drawSprite(Canvas canvas, Rect tile, ui.Image sprite) {
    final double side = tile.shortestSide * 0.86;
    final Rect dst = Rect.fromCenter(
      center: Offset(tile.center.dx, tile.center.dy - side * 0.06),
      width: side,
      height: side,
    );
    final Paint p = Paint()..filterQuality = FilterQuality.none;
    canvas.drawImageRect(
      sprite,
      Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
      dst,
      p,
    );
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
      ..color = const Color(0x334E4037)
      ..strokeWidth = 1.0;
    canvas.drawLine(r.center + const Offset(-10, 8), r.center + const Offset(-8, -4), p);
    canvas.drawLine(r.center + const Offset(8, 6), r.center + const Offset(10, -6), p);
  }

  void _drawForestDetails(Canvas canvas, Rect r) {
    final Paint treePaint = Paint()
      ..color = const Color(0xFF6F8A3E)
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
      ..color = const Color(0xFF8C7A5C)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, mountainPaint);
  }

  void _drawWaterDetails(Canvas canvas, Rect r) {
    final Paint wave = Paint()
      ..color = const Color(0x88FFF7EF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(r.center + const Offset(-14, -6), r.center + const Offset(6, -6), wave);
    canvas.drawLine(r.center + const Offset(-4, 6), r.center + const Offset(14, 6), wave);
  }

  static String _remainsSignature(List<Map<String, dynamic>> list) =>
      list.map((r) => '${r['id']}:${r['level']}:${r['owner']}').join('|');

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.map != map ||
        oldDelegate.conqueredPlots != conqueredPlots ||
        oldDelegate.plotSprites.length != plotSprites.length ||
        oldDelegate.terrainSprites.length != terrainSprites.length ||
        _remainsSignature(oldDelegate.remains) != _remainsSignature(remains) ||
        oldDelegate.selectedTile != selectedTile;
  }
}
