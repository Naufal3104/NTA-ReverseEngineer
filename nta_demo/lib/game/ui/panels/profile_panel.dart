import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../asset_manager.dart';
import '../design_tokens.dart';

/// Modal Profil — Personal Info / Add / Battle Info. Referensi:
/// `Tampilan Button Profil.jpg`.
class ProfilePanel extends StatefulWidget {
  const ProfilePanel({super.key, this.initialTab = 0});

  final int initialTab;

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: ProfilePanel(initialTab: initialTab),
      ),
    );
  }

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 740),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tabBar(context),
            Flexible(
              child: Container(
                decoration: ntaPanel(radius: 0),
                child: _tab == 0
                    ? _personalInfo(state)
                    : _tab == 1
                        ? _addTab(state)
                        : _battleInfo(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBar(BuildContext context) {
    const titles = ['Personal Info', 'Add', 'Battle Info'];
    return Container(
      decoration: const BoxDecoration(color: NtaColors.surfaceSunk),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _tab == i
                        ? NtaColors.surface
                        : NtaColors.surfaceCard,
                    border: Border(
                      bottom: BorderSide(
                        color: _tab == i
                            ? NtaColors.border
                            : Colors.transparent,
                        width: NtaBorder.button,
                      ),
                    ),
                  ),
                  child: Text(titles[i],
                      textAlign: TextAlign.center,
                      style: NtaText.bodyBold.copyWith(
                          fontSize: 13,
                          color: _tab == i
                              ? NtaColors.text
                              : NtaColors.textMuted)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _personalInfo(GameState state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      children: [
        Row(
          children: [
            _portrait(310101),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(state.playerName, style: NtaText.title),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 16),
                      const Spacer(),
                      Text('UID: 62196070',
                          style: NtaText.sm.copyWith(fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Title: ',
                          style: NtaText.sm.copyWith(fontSize: 12)),
                      const Icon(Icons.emoji_events,
                          size: 14, color: NtaColors.accentBorder),
                      const SizedBox(width: 2),
                      Text('Agility Wizard',
                          style: NtaText.bodyBold.copyWith(
                              fontSize: 13, color: NtaColors.accentBorder)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: NtaColors.surfaceRaised,
            borderRadius: BorderRadius.circular(NtaRadius.card),
            border: Border.all(color: NtaColors.borderSoft),
          ),
          child: Text('Enter your self introduction...',
              style: NtaText.sm.copyWith(fontSize: 12)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: ntaCard(),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech, size: 28),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.rankTier.isNotEmpty ? state.rankTier : 'Iron III',
                            style: NtaText.bodyBold.copyWith(fontSize: 13)),
                        Text('Win Pts: ${state.tierWinPoints}',
                            style: NtaText.sm.copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: ntaCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ranked Battles',
                        style: NtaText.sm.copyWith(fontSize: 11)),
                    Text('${state.battleReports.length}',
                        style: NtaText.title.copyWith(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            _ReactionChip(icon: Icons.thumb_up, color: Color(0xFF73AA4A), value: 8),
            SizedBox(width: 12),
            _ReactionChip(icon: Icons.favorite, color: NtaColors.danger, value: 6),
            SizedBox(width: 12),
            _ReactionChip(icon: Icons.local_florist, color: Color(0xFFE08AB4), value: 1),
          ],
        ),
        const SizedBox(height: 12),
        Text('Friends (11/100)',
            style: NtaText.bodyBold.copyWith(fontSize: 13)),
        const SizedBox(height: 6),
        for (final f in _friends) _friendRow(f),
      ],
    );
  }

  Widget _portrait(int heroId) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: NtaColors.surfaceCard,
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(color: NtaColors.border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        NtaAssets.heroAvatar(heroId),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) => const Icon(Icons.person, size: 32),
      ),
    );
  }

  Widget _friendRow(_Friend f) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: NtaColors.surfaceCard,
              border: Border.all(color: NtaColors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              NtaAssets.heroAvatar(f.avatarId),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.person, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.name, style: NtaText.bodyBold.copyWith(fontSize: 12)),
                Text('Online ${f.lastSeen}',
                    style: NtaText.sm.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: NtaColors.surfaceRaised,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: NtaColors.borderSoft),
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _addTab(GameState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Add Friend', style: NtaText.title),
        const SizedBox(height: 10),
        Text(
          'Cari pemain lewat nama atau UID lalu kirim permintaan pertemanan. '
          '(Mode offline: fitur ini tidak mengirim ke server.)',
          style: NtaText.sm.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: NtaColors.surfaceRaised,
            borderRadius: BorderRadius.circular(NtaRadius.button),
            border: Border.all(color: NtaColors.borderSoft),
          ),
          child: Text('Enter player UID…', style: NtaText.sm),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _tabBtn('Cancel', false)),
            const SizedBox(width: 8),
            Expanded(child: _tabBtn('Send Request', true)),
          ],
        ),
      ],
    );
  }

  Widget _battleInfo(GameState state) {
    final totalKills = state.battleReports
        .fold<int>(0, (a, r) => a + (r['kills'] as int? ?? 0));
    final wins = state.battleReports.where((r) => r['victory'] == true).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Battle Info', style: NtaText.title),
        const SizedBox(height: 12),
        _stat('Battles fought', '${state.battleReports.length}'),
        _stat('Victories', '$wins'),
        _stat('Total kills', '$totalKills'),
        _stat('Territories', '${state.conqueredPlots.length}'),
        _stat('Tier Win Points', '${state.tierWinPoints}'),
        _stat('Reward Points', '${state.rewardPoints}'),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: NtaText.body.copyWith(fontSize: 13))),
          Text(value, style: NtaText.bodyBold),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, bool primary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: primary ? NtaColors.accentTop : NtaColors.surfaceRaised,
        borderRadius: BorderRadius.circular(NtaRadius.button),
        border: Border.all(color: NtaColors.border, width: NtaBorder.card),
      ),
      alignment: Alignment.center,
      child: Text(label, style: NtaText.bodyBold.copyWith(fontSize: 13)),
    );
  }

  static const List<_Friend> _friends = [
    _Friend(name: 'CADET 1C', avatarId: 310401, lastSeen: '9Min ago'),
    _Friend(name: '飛鳥月二', avatarId: 310502, lastSeen: '12H ago'),
    _Friend(name: 'xCreedx', avatarId: 310603, lastSeen: '15D ago'),
    _Friend(name: 'Deniqqa', avatarId: 320301, lastSeen: '16D ago'),
  ];
}

class _Friend {
  const _Friend({
    required this.name,
    required this.avatarId,
    required this.lastSeen,
  });

  final String name;
  final int avatarId;
  final String lastSeen;
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.icon,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NtaColors.surfaceRaised,
        borderRadius: BorderRadius.circular(NtaRadius.pill),
        border: Border.all(color: NtaColors.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text('$value',
              style: NtaText.xs.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
