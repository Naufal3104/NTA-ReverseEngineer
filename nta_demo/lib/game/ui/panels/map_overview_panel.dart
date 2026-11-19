import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../design_tokens.dart';

/// Modal Map (overview) — peta kecil 80x80 di mana titik pemain, allied
/// territory, dan territory milik pemain lain digambar sebagai titik-titik.
/// Referensi: `Tampilan Button Map.jpg`.
class MapOverviewPanel extends StatefulWidget {
  const MapOverviewPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: const MapOverviewPanel(),
      ),
    );
  }

  @override
  State<MapOverviewPanel> createState() => _MapOverviewPanelState();
}

class _MapOverviewPanelState extends State<MapOverviewPanel> {
  final _panController = TransformationController();

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 660),
        child: Container(
          decoration: ntaPanel(),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _legendDot(NtaColors.success),
                  const SizedBox(width: 3),
                  Text('Our Territory',
                      style: NtaText.sm.copyWith(fontSize: 11)),
                  const SizedBox(width: 10),
                  _legendDot(const Color(0xFF4E7CD8)),
                  const SizedBox(width: 3),
                  Text('Allied Territory',
                      style: NtaText.sm.copyWith(fontSize: 11)),
                  const SizedBox(width: 10),
                  _legendDot(NtaColors.danger),
                  const SizedBox(width: 3),
                  Text('Other Players',
                      style: NtaText.sm.copyWith(fontSize: 11)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: NtaColors.surfaceCard,
                    border: Border.all(color: NtaColors.borderSoft),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: InteractiveViewer(
                    transformationController: _panController,
                    minScale: 0.6,
                    maxScale: 3,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomPaint(
                        painter: _MiniMapPainter(
                          map: state.map,
                          conquered: state.conqueredPlots,
                          capitalRow: GameState.capitalMinRow,
                          capitalCol: GameState.capitalMinCol,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _letterBtn('A'),
                  const SizedBox(width: 6),
                  _letterBtn('B'),
                  const SizedBox(width: 6),
                  _letterBtn('C'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NtaColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(NtaRadius.pill),
                      border: Border.all(color: NtaColors.borderSoft),
                    ),
                    child: Text('X:110  Y:408', style: NtaText.sm),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: NtaColors.accentTop,
                      borderRadius: BorderRadius.circular(NtaRadius.button),
                      border:
                          Border.all(color: NtaColors.accentBorder),
                    ),
                    child: Text('View',
                        style: NtaText.bodyBold.copyWith(
                            fontSize: 12, color: NtaColors.onAccent)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _letterBtn(String label) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: NtaColors.surfaceRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: NtaColors.border, width: 1),
      ),
      child: Text(label,
          style: NtaText.bodyBold.copyWith(fontSize: 12)),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  _MiniMapPainter({
    required this.map,
    required this.conquered,
    required this.capitalRow,
    required this.capitalCol,
  });

  final List<List<int>> map;
  final Set<String> conquered;
  final int capitalRow;
  final int capitalCol;

  @override
  void paint(Canvas canvas, Size size) {
    if (map.isEmpty) return;
    final double sw = size.width / map[0].length;
    final double sh = size.height / map.length;

    // Backdrop parchment.
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF1E2CB));

    // Plot dots per owner bucket. Since demo only has "player own" vs "wild"
    // vs "water/mountain", we render:
    //   - conquered tiles: green
    //   - other plot tiles: red (rival bot occupations, kept static)
    //   - water/mountain: light grey-blue
    final green = Paint()..color = NtaColors.success;
    final red = Paint()..color = NtaColors.danger;
    final water = Paint()..color = const Color(0x338FC7E0);
    final mountain = Paint()..color = const Color(0x33C2AE86);

    for (int r = 0; r < map.length; r++) {
      for (int c = 0; c < map[r].length; c++) {
        final t = map[r][c];
        final Rect dot =
            Rect.fromLTWH(c * sw, r * sh, sw + 0.6, sh + 0.6);
        if (conquered.contains('$r,$c')) {
          canvas.drawRect(dot, green);
        } else if (t == 3) {
          canvas.drawRect(dot, water);
        } else if (t == 2) {
          canvas.drawRect(dot, mountain);
        } else if (t == 1) {
          canvas.drawRect(
              dot, Paint()..color = const Color(0x33C2AE86));
        } else if ((r * 13 + c * 7) % 19 == 0) {
          canvas.drawRect(dot, red);
        }
      }
    }

    // Capital pin.
    final px = (capitalCol + 1) * sw;
    final py = (capitalRow + 1) * sh;
    canvas.drawCircle(Offset(px, py), 6, Paint()..color = Colors.yellow);
    canvas.drawCircle(
      Offset(px, py),
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = NtaColors.border,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter old) =>
      old.map != map || old.conquered != conquered;
}
