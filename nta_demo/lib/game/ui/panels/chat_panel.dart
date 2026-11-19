import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../asset_manager.dart';
import '../design_tokens.dart';

/// Modal Chat — Union / Team tab, dan scope World / Alles / Private Chat.
/// Referensi: `Tampilan Button Chat.jpg`. Offline mode: pesan disimulasikan
/// dari daftar fiktif (tidak ada socket server).
class ChatPanel extends StatefulWidget {
  const ChatPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: const ChatPanel(),
      ),
    );
  }

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  int _tab = 0; // 0 = Union, 1 = Team
  final List<_ChatMessage> _messages = _seedMessages();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final memberCount = state.unionMembers.isEmpty
        ? 39
        : state.unionMembers.length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 720),
        child: Container(
          decoration: ntaPanel(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _scopeTabs(),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Row(
                  children: [
                    _tabBtn('Union', 0),
                    const SizedBox(width: 6),
                    _tabBtn('Team', 1),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.group, size: 16),
                        const SizedBox(width: 4),
                        Text('$memberCount/40',
                            style: NtaText.sm.copyWith(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 6),
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
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: NtaColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(NtaRadius.card),
                    border:
                        Border.all(color: NtaColors.borderSoft, width: 1),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      if (m.isTimestamp) return _timestamp(m.sender);
                      return _message(m);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _inputBar(context),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scopeTabs() {
    return Container(
      decoration: const BoxDecoration(color: NtaColors.surfaceSunk),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          for (final t in const ['World', 'Alles', 'Private Chat'])
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(t,
                      textAlign: TextAlign.center,
                      style: NtaText.sm.copyWith(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final selected = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? NtaColors.accentTop : NtaColors.surfaceRaised,
          borderRadius: BorderRadius.circular(NtaRadius.button),
          border: Border.all(color: NtaColors.border, width: NtaBorder.card),
        ),
        child: Text(label,
            style: NtaText.bodyBold.copyWith(fontSize: 12)),
      ),
    );
  }

  Widget _timestamp(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(t, style: NtaText.sm.copyWith(fontSize: 11)),
      ),
    );
  }

  Widget _message(_ChatMessage m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              NtaAssets.heroAvatar(m.avatarId),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.person, size: 20),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(m.sender,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NtaText.bodyBold.copyWith(fontSize: 12)),
                    ),
                    if (m.tag != null) ...[
                      const SizedBox(width: 3),
                      Text(m.tag!,
                          style: NtaText.xs.copyWith(
                              color: NtaColors.textMuted, fontSize: 10)),
                    ],
                  ],
                ),
                if (m.body != null)
                  Text(m.body!,
                      style: NtaText.sm.copyWith(
                          fontSize: 12, color: NtaColors.text)),
                if (m.link != null)
                  Text(m.link!,
                      style: NtaText.sm.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF2E6DA4),
                          fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: NtaColors.surfaceRaised,
                borderRadius: BorderRadius.circular(NtaRadius.button),
                border: Border.all(color: NtaColors.border, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerLeft,
              child: Text('Type a message…',
                  style: NtaText.sm.copyWith(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [NtaColors.accentTop, NtaColors.accentBottom],
                ),
                borderRadius: BorderRadius.circular(NtaRadius.button),
                border: Border.all(
                    color: NtaColors.accentBorder, width: 1.5),
              ),
              child: Text('Send',
                  style: NtaText.bodyBold.copyWith(
                      fontSize: 13, color: NtaColors.onAccent)),
            ),
          ),
        ],
      ),
    );
  }

  static List<_ChatMessage> _seedMessages() => const [
        _ChatMessage(sender: 'biar aku saja', avatarId: 310101, body: null),
        _ChatMessage(sender: '17:54', avatarId: 0, isTimestamp: true),
        _ChatMessage(
            sender: 'khankoon',
            avatarId: 310102,
            tag: '(Agility Wizard)',
            body: null,
            link: '[570,229]전투 지원 요청합니다'),
        _ChatMessage(sender: '17:55', avatarId: 0, isTimestamp: true),
        _ChatMessage(
            sender: 'kẻ hủy diệt',
            avatarId: 310103,
            tag: '<Union Leader>',
            link: '[Long Spear++]'),
        _ChatMessage(
            sender: 'kẻ hủy diệt',
            avatarId: 310103,
            tag: '<Union Leader>',
            link: '[Long Spear++]'),
        _ChatMessage(
            sender: 'kẻ hủy diệt',
            avatarId: 310103,
            tag: '<Union Leader>',
            body: 'bỏ khiêu động'),
        _ChatMessage(sender: '18:37', avatarId: 0, isTimestamp: true),
        _ChatMessage(
            sender: '半兵衛',
            avatarId: 310201,
            tag: '(Agility Wizard)',
            link: '[563,220]攻撃されています'),
        _ChatMessage(sender: '18:54', avatarId: 0, isTimestamp: true),
        _ChatMessage(
            sender: 'khankoon',
            avatarId: 310102,
            tag: '(Agility Wizard)',
            link: '[563,220]지원 필요해요'),
      ];
}

class _ChatMessage {
  const _ChatMessage({
    required this.sender,
    required this.avatarId,
    this.tag,
    this.body,
    this.link,
    this.isTimestamp = false,
  });

  final String sender;
  final int avatarId;
  final String? tag;
  final String? body;
  final String? link;
  final bool isTimestamp;
}
