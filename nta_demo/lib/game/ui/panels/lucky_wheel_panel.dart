import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../design_tokens.dart';

/// Lucky Wheel modal — reference `Tampilan Button Spin Wheel.jpg`.
///
/// Rebuild rule: unlimited free spins (anti-cooldown). A spin picks a random
/// prize segment and grants its resource bundle into [GameState].
class LuckyWheelPanel extends StatefulWidget {
  const LuckyWheelPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: const LuckyWheelPanel(),
      ),
    );
  }

  @override
  State<LuckyWheelPanel> createState() => _LuckyWheelPanelState();
}

class _WheelSegment {
  const _WheelSegment({
    required this.label,
    required this.icon,
    required this.reward,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Map<String, int> reward;
  final Color color;
}

class _LuckyWheelPanelState extends State<LuckyWheelPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late Animation<double> _anim;
  double _angle = 0;
  String? _prizeLabel;

  final math.Random _rng = math.Random();

  static const List<_WheelSegment> _segments = [
    _WheelSegment(label: '1200', icon: Icons.grass, reward: {'crop': 1200}, color: Color(0xFFF6E3A8)),
    _WheelSegment(label: '1200', icon: Icons.park, reward: {'wood': 1200}, color: Color(0xFFF0D896)),
    _WheelSegment(label: '1200', icon: Icons.landscape, reward: {'stone': 1200}, color: Color(0xFFF6E3A8)),
    _WheelSegment(label: '2', icon: Icons.receipt_long, reward: {'scroll': 2}, color: Color(0xFFA9D8A0)),
    _WheelSegment(label: '2', icon: Icons.receipt_long, reward: {'scroll': 2}, color: Color(0xFFC0E2B4)),
    _WheelSegment(label: '350', icon: Icons.grass, reward: {'crop': 350}, color: Color(0xFFF0D896)),
    _WheelSegment(label: '350', icon: Icons.park, reward: {'wood': 350}, color: Color(0xFFF6E3A8)),
    _WheelSegment(label: '350', icon: Icons.landscape, reward: {'stone': 350}, color: Color(0xFFF0D896)),
    _WheelSegment(label: '10', icon: Icons.settings, reward: {'iron': 10}, color: Color(0xFFE6CC7E)),
    _WheelSegment(label: '5', icon: Icons.settings, reward: {'iron': 5}, color: Color(0xFFA9D8A0)),
    _WheelSegment(label: '5', icon: Icons.menu_book, reward: {'exp_scroll': 5}, color: Color(0xFFC0E2B4)),
    _WheelSegment(label: '5', icon: Icons.menu_book, reward: {'exp_scroll': 5}, color: Color(0xFFA9D8A0)),
  ];

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600));
    _anim = const AlwaysStoppedAnimation(0);
    _ctl.addListener(() => setState(() => _angle = _anim.value));
    _ctl.addStatusListener((status) {
      if (status == AnimationStatus.completed) _settle();
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _spin() {
    if (_ctl.isAnimating) return;
    setState(() => _prizeLabel = null);
    const baseTurns = 5;
    final seg = _segments.length;
    final targetSeg = _rng.nextInt(seg);
    // pointer sits at the top (-pi/2). Land the chosen segment there.
    final segAngle = (2 * math.pi) / seg;
    final landing = baseTurns * 2 * math.pi +
        (2 * math.pi - targetSeg * segAngle) -
        (math.pi / 2);
    _anim = Tween<double>(begin: _angle, end: landing).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic),
    );
    _pendingSeg = targetSeg;
    _ctl.forward(from: 0);
  }

  int _pendingSeg = 0;

  void _settle() {
    final seg = _segments[_pendingSeg];
    final state = context.read<GameState>();
    state.grantWheelReward(seg.reward);
    setState(() => _prizeLabel = seg.label);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 760),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFC98A4B), Color(0xFFA96E36)],
            ),
            borderRadius: BorderRadius.circular(NtaRadius.panel),
            border: Border.all(color: const Color(0xFF6E4520), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _titleBar(),
              const SizedBox(height: 8),
              Flexible(child: SingleChildScrollView(child: _wheelBody())),
              const SizedBox(height: 8),
              Text("Today's chance(s) left: Unlimited",
                  style: NtaText.body.copyWith(
                      fontSize: 13,
                      color: const Color(0xFFFFF3DA),
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E4C0),
                        borderRadius: BorderRadius.circular(NtaRadius.pill),
                        border:
                            Border.all(color: const Color(0xFF6E4520), width: 2),
                      ),
                      child: Text(
                        _prizeLabel == null
                            ? 'Free to spin any time'
                            : 'Won: $_prizeLabel',
                        textAlign: TextAlign.center,
                        style: NtaText.bodyBold.copyWith(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _spin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFEAF6A6), Color(0xFFC7E56E)],
                        ),
                        borderRadius: BorderRadius.circular(NtaRadius.pill),
                        border:
                            Border.all(color: const Color(0xFF73AA4A), width: 2),
                      ),
                      child: Text('Skip',
                          style: NtaText.bodyBold.copyWith(
                              fontSize: 14, color: NtaColors.onAccent)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleBar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF7A4A24),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF5A3418), width: 2),
          ),
          child: Text('Lucky Wheel',
              textAlign: TextAlign.center,
              style: NtaText.heading.copyWith(
                  fontSize: 20, color: const Color(0xFFFFE9C0))),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E4C0),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6E4520), width: 2),
              ),
              child: const Icon(Icons.question_mark,
                  size: 16, color: NtaColors.text),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E4C0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6E4520), width: 2),
                ),
                child: const Icon(Icons.close, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _wheelBody() {
    return Center(
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _spin,
              child: Transform.rotate(
                angle: _angle,
                child: CustomPaint(
                  size: const Size(320, 320),
                  painter: _WheelPainter(_segments),
                ),
              ),
            ),
            // hub + pointer
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0C24A),
                border: Border.all(color: const Color(0xFF8A6A1F), width: 3),
              ),
            ),
            Positioned(
              top: -4,
              child: Container(
                width: 0,
                height: 0,
                decoration: const BoxDecoration(),
                child: const Icon(Icons.arrow_drop_down,
                    size: 40, color: Color(0xFF7A4A24)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.segments);

  final List<_WheelSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segAngle = (2 * math.pi) / segments.length;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (var i = 0; i < segments.length; i++) {
      final start = i * segAngle - math.pi / 2;
      final paint = Paint()..color = segments[i].color;
      canvas.drawArc(rect, start, segAngle, true, paint);

      // segment divider
      final edge = Paint()
        ..color = const Color(0xFFB98B4A)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, start, segAngle, true, edge);

      // label
      final mid = start + segAngle / 2;
      final lx = center.dx + math.cos(mid) * radius * 0.68;
      final ly = center.dy + math.sin(mid) * radius * 0.68;
      final tp = TextPainter(
        text: TextSpan(
          text: segments[i].label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: NtaColors.text,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }

    // outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF6E4520)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}