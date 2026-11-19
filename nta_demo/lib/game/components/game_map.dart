import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../../data/game_data.dart';
import '../ui/asset_manager.dart';
import '../ui/design_tokens.dart';
import 'map_tile_panel.dart';

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

  /// Sprite bangunan tampilan-dunia (capital/watchtower/fortress/barn/remains)
  /// diambil dari atlas `tmp/image/city/` asli.
  final Map<String, ui.Image> _mapSprites = {};

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
    // Taburan dekorasi plot liar (jerami / pohon / batu) — atlas decorate.
    for (int v = 0; v < 6; v++) {
      jobs.add(put(_terrainSprites, 'deco$v', NtaAssets.plotDecoration(v)));
    }
    for (int v = 0; v < 4; v++) {
      jobs.add(put(_terrainSprites, 'garden$v', NtaAssets.capitalGardenDecoration(v)));
    }
    jobs.add(put(_mapSprites, 'capital', NtaAssets.mapCapital));
    jobs.add(put(_mapSprites, 'watchtower', NtaAssets.mapWatchtower));
    jobs.add(put(_mapSprites, 'fortress', NtaAssets.mapFortress));
    jobs.add(put(_mapSprites, 'farm', NtaAssets.mapFarm));
    jobs.add(put(_mapSprites, 'remains', NtaAssets.mapRemains));
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
                  // ListenableBuilder rebuilds on pan/zoom so visibleRect updates for culling.
                  child: ListenableBuilder(
                    listenable: _transController,
                    builder: (context, _) {
                      // Compute visible viewport rect in map pixel coordinates for culling.
                      Rect? visibleRect;
                      final m = _transController.value;
                      if (!m.isIdentity()) {
                        final viewportWidth = constraints.maxWidth;
                        final viewportHeight = constraints.maxHeight;
                        final inv = Matrix4.inverted(m);
                        final tl = inv.transform3(Vector3(0, 0, 0));
                        final br = inv.transform3(Vector3(viewportWidth, viewportHeight, 0));
                        visibleRect = Rect.fromLTRB(
                          tl.x.clamp(0.0, mapPixelWidth),
                          tl.y.clamp(0.0, mapPixelHeight),
                          br.x.clamp(0.0, mapPixelWidth),
                          br.y.clamp(0.0, mapPixelHeight),
                        );
                      }
                      return RepaintBoundary(
                        child: CustomPaint(
                          size: Size(mapPixelWidth, mapPixelHeight),
                          painter: MapPainter(
                            map: state.map,
                            conqueredPlots: state.conqueredPlots,
                            plotSprites: _plotSprites,
                            terrainSprites: _terrainSprites,
                            mapSprites: _mapSprites,
                            plotLevelAt: (r, c) => state.getPlotData(r, c)?['level'] as int? ?? 1,
                            plotResourceAt: (r, c) => state.getPlotData(r, c)?['resource'] as String? ?? 'crop',
                            plotBuildingAt: (r, c) => (state.plotBuildings['$r,$c']?['type'] as String?) ?? '',
                            remains: state.remains.values.toList(),
                            playerName: state.playerName,
                            selectedTile: selectedTile,
                            capitalMinRow: GameState.capitalMinRow,
                            capitalMaxRow: GameState.capitalMaxRow,
                            capitalMinCol: GameState.capitalMinCol,
                            capitalMaxCol: GameState.capitalMaxCol,
                            visibleRect: visibleRect,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Tile action panel — plate + info card + button stack (gaya asli).
            if (selectedTile != null)
              Positioned(
                bottom: 96,
                left: 12,
                right: 12,
                child: Center(
                  child: MapTilePanel(row: selectedTile[0], col: selectedTile[1]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class MapPainter extends CustomPainter {
  final List<List<int>> map;
  final Set<String> conqueredPlots;
  final Map<String, ui.Image> plotSprites;
  final Map<String, ui.Image> terrainSprites;
  final Map<String, ui.Image> mapSprites;
  final int Function(int row, int col) plotLevelAt;
  final String Function(int row, int col) plotResourceAt;
  final String Function(int row, int col) plotBuildingAt;
  final List<Map<String, dynamic>> remains;
  final String playerName;
  final List<int>? selectedTile;
  final int capitalMinRow;
  final int capitalMaxRow;
  final int capitalMinCol;
  final int capitalMaxCol;
  /// Visible viewport in map pixel coordinates (for culling). If null, draw all.
  final Rect? visibleRect;

  MapPainter({
    required this.map,
    required this.conqueredPlots,
    required this.plotSprites,
    required this.terrainSprites,
    required this.mapSprites,
    required this.plotLevelAt,
    required this.plotResourceAt,
    required this.plotBuildingAt,
    required this.remains,
    required this.playerName,
    this.selectedTile,
    required this.capitalMinRow,
    required this.capitalMaxRow,
    required this.capitalMinCol,
    required this.capitalMaxCol,
    this.visibleRect,
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

    // Terrain Colors — warna dasar rumput diambil langsung dari screenshot
    // `Tampilan Utama.jpg` (checkerboard hijau: wild `#7BAF81`/`#80B486`,
    // territory dikuasai `#8FC17A`/`#91C078`).
    const Color cGrass = Color(0xFF7BAF81);
    const Color cGrassAlt = Color(0xFF80B486);
    const Color cOwnedA = Color(0xFF8FC17A);
    const Color cOwnedB = Color(0xFF91C078);
    const Color cForest = Color(0xFFA8BE63);
    const Color cMountain = Color(0xFFC2AE86);
    const Color cWater = Color(0xFF8FC7E0);
    const Color cSand = NtaColors.mapRoad;

    // Viewport culling: only draw tiles intersecting visibleRect (+1 tile margin)
    final int mapH = map.length;
    final int mapW = map[0].length;
    int startRow = 0, endRow = mapH - 1;
    int startCol = 0, endCol = mapW - 1;
    if (visibleRect != null) {
      startRow = (visibleRect!.top / tileSize).floor() - 1;
      endRow = (visibleRect!.bottom / tileSize).ceil() + 1;
      startCol = (visibleRect!.left / tileSize).floor() - 1;
      endCol = (visibleRect!.right / tileSize).ceil() + 1;
      startRow = startRow.clamp(0, mapH - 1);
      endRow = endRow.clamp(0, mapH - 1);
      startCol = startCol.clamp(0, mapW - 1);
      endCol = endCol.clamp(0, mapW - 1);
    }

    // 1. Draw base terrain grid
    for (int row = startRow; row <= endRow; row++) {
      for (int col = startCol; col <= endCol; col++) {
        final int terrain = map[row][col];
        final Rect rect = Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize);

        // Base: checkerboard grassland (2x2 pattern), matching the original
        // map. `grass_*` sprites from the atlas are sparse single tufts, so
        // they are drawn on top as decoration.
        final bool checker = ((row + col) & 1) == 0;
        final bool inDomain = conqueredPlots.contains('$row,$col');
        bgPaint.color = inDomain
            ? (checker ? cOwnedA : cOwnedB)
            : (checker ? cGrass : cGrassAlt);
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

        // 2a. Plot sprite di atas tile.
        // Wild plot -> ikon resource asli (land.json) + badge level.
        // Plot dikuasai -> sprite watchtower/fortress asli dari atlas city.
        final bool isRemains = _remainsAt(row, col) != null;
        final bool isConquered = conqueredPlots.contains('$row,$col');

        // Batas domain — garis hijau gelap tebal hanya di tepi teritori
        // (lihat `Tampilan Utama.jpg`: `#3C854D`/`#368045` mengelilingi
        // seluruh wilayah milik sendiri). Warna interior tile sudah
        // dibedakan di base fill, jadi tidak perlu overlay lagi.
        if (isConquered && !isCap) {
          final Paint edge = Paint()
            ..color = const Color(0xFF3C854D)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke;
          bool owned(int r, int c) =>
              r >= 0 && r < map.length && c >= 0 && c < map[r].length &&
              conqueredPlots.contains('$r,$c');
          if (!owned(row - 1, col)) canvas.drawLine(rect.topLeft, rect.topRight, edge);
          if (!owned(row + 1, col)) canvas.drawLine(rect.bottomLeft, rect.bottomRight, edge);
          if (!owned(row, col - 1)) canvas.drawLine(rect.topLeft, rect.bottomLeft, edge);
          if (!owned(row, col + 1)) canvas.drawLine(rect.topRight, rect.bottomRight, edge);
        }

        if (!isCap && !isRemains) {
          final lv = plotLevelAt(row, col);
          if (isConquered) {
            // Domain: bangunan asli (fortress / farm / watchtower). Tile
            // rumput kosong (kebun istana di sekitar capital) sengaja dibiarkan
            // tanpa bangunan supaya sama dengan tampilan asli.
            final btype = plotBuildingAt(row, col);
            final bool garden = lv <= 1 &&
                btype.isEmpty &&
                row > 34 && row < 45 &&
                col > 34 && col < 45;
            if (garden) {
              // Halaman istana: taburan batu / semak (referensi
              // `Tampilan Utama.jpg` — ring di sekitar pagoda).
              final rough = (row * 73 + col * 41) % 7;
              if (rough < 3) {
                final g = terrainSprites['garden${(row * 5 + col * 3) % 4}'];
                if (g != null) _drawDecoration(canvas, rect, g, scale: 0.8);
              }
            } else {
              final sprite = btype == 'fortress'
                  ? mapSprites['fortress']
                  : (btype == 'farm' || btype == 'sawmill' || btype == 'quarry')
                      ? mapSprites['farm']
                      : mapSprites['watchtower'];
              if (sprite != null) _drawSprite(canvas, rect, sprite);
            }
            if (lv > 1) _drawDigitBadge(canvas, rect, terrainSprites['digit$lv']);
          } else {
            final sprite = plotSprites['${plotResourceAt(row, col)}:$lv'];
            if (sprite != null) {
              _drawSprite(canvas, rect, sprite);
            }
            // Taburan dekorasi kecil (jerami / rumput / batu) di tile liar
            // — referensi menunjukkan plot liar tidak seluruhnya kosong.
            final rough = (row * 31 + col * 17) % 11;
            if (rough < 2 && lv <= 1) {
              final d = terrainSprites['deco${(row + col * 3) % 6}'];
              if (d != null) {
                _drawDecoration(canvas, rect, d, scale: 0.85);
              }
            }
            // Level badge — digit glyphs from the original map_flag_num atlas.
            final digit = terrainSprites['digit$lv'];
            if (lv > 1) {
              _drawDigitBadge(canvas, rect, digit);
            }
          }
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

  /// Remains (capital netral) — sprite dinding asli city_10010, plus badge
  /// level di pojok kanan bawah.
  void _drawRemains(Canvas canvas, double tileSize, Map<String, dynamic> r) {
    final double left = (r['col'] as int) * tileSize;
    final double top = (r['row'] as int) * tileSize;
    final Rect rect = Rect.fromLTWH(left, top, tileSize * 2, tileSize * 2);
    final sprite = mapSprites['remains'];
    if (sprite != null) {
      _drawFootprint(canvas, rect, sprite);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(8)),
        Paint()..color = const Color(0xFF6B5B47),
      );
    }

    final level = (r['level'] as int?) ?? 1;
    final Rect badge = Rect.fromLTWH(rect.right - 26, rect.bottom - 20, 22, 16);
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

  /// Capital pemain (2x2) — sprite pagoda asli city_1001 + label nama gelap
  /// di atasnya. Halaman kekuningan & garis batas sudah bagian dari skin
  /// capital, jadi tidak digambar ulang (lihat `Tampilan Utama.jpg`).
  void _drawGrandCapitalCitadel(Canvas canvas, double tileSize) {
    final double left = capitalMinCol * tileSize;
    final double top = capitalMinRow * tileSize;
    final double width = (capitalMaxCol - capitalMinCol + 1) * tileSize;
    final double height = (capitalMaxRow - capitalMinRow + 1) * tileSize;
    final Rect rect = Rect.fromLTWH(left, top, width, height);

    final sprite = mapSprites['capital'];
    if (sprite != null) {
      // Sprite pagoda menempati seluruh 2x2; gambar anchor ke bawah-tengah.
      final Rect dst = Rect.fromLTWH(
        rect.left + (rect.width - rect.height * sprite.width / sprite.height) / 2,
        rect.top,
        rect.height * sprite.width / sprite.height,
        rect.height,
      );
      canvas.drawImageRect(
        sprite,
        Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
        dst,
        Paint()..filterQuality = FilterQuality.none,
      );
    }

    // Label nama pemain (pill gelap) menggantung di atas puncak pagoda.
    _drawNamePill(canvas, rect, playerName, tileSize);
  }

  /// Gambar sprite mempertahankan rasio, di tengah footprint.
  void _drawFootprint(Canvas canvas, Rect rect, ui.Image sprite) {
    final double sw = sprite.width.toDouble();
    final double sh = sprite.height.toDouble();
    final double scale = (rect.width / sw) < (rect.height / sh)
        ? rect.width / sw
        : rect.height / sh;
    final double w = sw * scale;
    final double h = sh * scale;
    final Rect dst = Rect.fromCenter(center: rect.center, width: w, height: h);
    canvas.drawImageRect(
      sprite,
      Rect.fromLTWH(0, 0, sw, sh),
      dst,
      Paint()..filterQuality = FilterQuality.none,
    );
  }

  /// Label nama pemain gaya referensi: pill gelap besar dengan avatar
  /// kepala ksatria di sisi kiri (`Tampilan Utama.jpg`, "FallStar7").
  /// Ukuran font diskalakan mengikuti tileSize agar tetap proporsional
  /// saat zoom.
  void _drawNamePill(Canvas canvas, Rect rect, String name, double tileSize) {
    final double fontPx = (tileSize * 0.22).clamp(11.0, 26.0);
    final double avatar = fontPx * 1.55;
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontPx,
          fontWeight: FontWeight.w700,
          shadows: const [
            Shadow(color: Color(0x99000000), offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final double pillH = avatar + 4;
    final double pillW = tp.width + avatar + 16;
    final Rect pill = Rect.fromLTWH(
      rect.center.dx - pillW / 2,
      rect.top - pillH * 0.55,
      pillW,
      pillH,
    );
    final RRect rr = RRect.fromRectAndRadius(pill, Radius.circular(pillH * 0.32));
    canvas.drawRRect(rr, Paint()..color = const Color(0xE0302822));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF6B5B47),
    );

    // Avatar kotak kiri — bingkai + ikon helm.
    final Rect av = Rect.fromLTWH(pill.left + 2, pill.top + 2, avatar - 2, avatar - 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(av, const Radius.circular(3)),
      Paint()..color = const Color(0xFFB0866A),
    );
    TextPainter helmet = TextPainter(
      text: TextSpan(
        text: '⚔',
        style: TextStyle(fontSize: avatar * 0.62, color: const Color(0xFFF2E9D8)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    helmet.paint(
      canvas,
      Offset(av.center.dx - helmet.width / 2, av.center.dy - helmet.height / 2),
    );

    tp.paint(canvas, Offset(av.right + 7, pill.center.dy - tp.height / 2));
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

  /// Tempel dekorasi kecil (batu/semak/jerami) di tengah tile, tanpa
  /// menutupi seluruh petak — atlas `decorate/*` punya konten kecil di
  /// sudut kiri-bawah slice 80x80.
  void _drawDecoration(Canvas canvas, Rect tile, ui.Image sprite, {double scale = 1.0}) {
    final double side = tile.shortestSide * scale;
    final Rect dst = Rect.fromCenter(center: tile.center, width: side, height: side);
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

  /// Gambar sprite plot (8x8 tile slice, isi di sudut kiri-bawah) di dalam
  /// satu tile map. Isi dianchor ke tepi bawah tile seperti tile asli.
  void _drawSprite(Canvas canvas, Rect tile, ui.Image sprite) {
    final Paint p = Paint()..filterQuality = FilterQuality.none;
    canvas.drawImageRect(
      sprite,
      Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
      tile,
      p,
    );
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
        oldDelegate.mapSprites.length != mapSprites.length ||
        _remainsSignature(oldDelegate.remains) != _remainsSignature(remains) ||
        oldDelegate.playerName != playerName ||
        oldDelegate.selectedTile != selectedTile;
  }
}
