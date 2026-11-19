import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../design_tokens.dart';

/// Modal info special resource (iron / exp scroll / scroll / nail) —
/// referensi: `Tampilan untuk Special Resource.jpg`.
class SpecialResourcePanel extends StatelessWidget {
  const SpecialResourcePanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: const SpecialResourcePanel(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 80),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 660),
        child: Container(
          decoration: ntaPanel(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 6, 6),
                child: Row(
                  children: [
                    Text('Special Resources',
                        style: NtaText.title.copyWith(fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: 'Close',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  children: [
                    _row(
                      'exp_scroll',
                      'EXP Scroll',
                      'Necessary resources to train soldiers at the Drill Ground. '
                          'A chance to obtain it from Wood Plot.',
                      state.expScroll,
                    ),
                    _row(
                      'iron',
                      'Iron',
                      'Necessary resources to craft equipment at the Smithy. '
                          'A chance to obtain it from Stone Plot.',
                      state.iron,
                    ),
                    _row(
                      'scroll',
                      'Scroll',
                      'Can level up soldiers directly. A higher chance to obtain '
                          'it from Adv. Wood Plot.',
                      state.scroll,
                    ),
                    _row(
                      'nail',
                      'Nail',
                      'Can lock an effect when recasting exclusive equipment. '
                          'A higher chance to obtain it from Adv. Stone Plot.',
                      state.nail,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String id, String name, String desc, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: NtaResIcon(id, size: 20),
              ),
              const SizedBox(width: 6),
              Text(name, style: NtaText.bodyBold.copyWith(fontSize: 13)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NtaColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(NtaRadius.pill),
                  border: Border.all(color: NtaColors.borderSoft),
                ),
                child: Text('$count',
                    style: NtaText.bodyBold.copyWith(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc,
              style: NtaText.sm.copyWith(fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}
