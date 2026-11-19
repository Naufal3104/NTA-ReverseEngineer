import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../design_tokens.dart';

/// Shop modal Daily/Weekly — reference `Tampilan Button Shop.jpg`.
///
/// Rebuild rule: anti-coin. There is no top-up; every purchase button reads
/// "Free"/"Claim" and grants its bundle. Top-up category is shown as
/// "Not available in offline build". Daily Gift can be claimed once per day.
class ShopPanel extends StatefulWidget {
  const ShopPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameState>(),
        child: const ShopPanel(),
      ),
    );
  }

  @override
  State<ShopPanel> createState() => _ShopPanelState();
}

class _ShopOffer {
  const _ShopOffer({
    required this.name,
    required this.discount,
    required this.icon,
    required this.amount,
    required this.bundle,
  });

  final String name;
  final String discount;
  final IconData icon;
  final int amount;
  final Map<String, int> bundle;
}

class _ShopPanelState extends State<ShopPanel> {
  int _category = 0;
  int _tab = 0; // 0 = Daily, 1 = Weekly

  static const List<String> _categories = [
    'Limited-Time Offer',
    'Value Supply',
    'Top-up',
    'Skin Mall',
    'Exclusive Pack',
  ];

  static const List<String> _categoryIcons = [
    '🎁', '🏷', '💰', '👗', '📦',
  ];

  static const List<_ShopOffer> _dailyOffers = [
    _ShopOffer(
      name: 'Coin Offer',
      discount: '10% OFF',
      icon: Icons.grass,
      amount: 100,
      bundle: {'crop': 200, 'wood': 200},
    ),
    _ShopOffer(
      name: 'Bronze Tally Offer I',
      discount: '40% OFF',
      icon: Icons.military_tech,
      amount: 10,
      bundle: {'exp_scroll': 3},
    ),
    _ShopOffer(
      name: 'Bronze Tally Offer II',
      discount: '50% OFF',
      icon: Icons.military_tech,
      amount: 80,
      bundle: {'scroll': 2, 'nail': 1},
    ),
  ];

  static const List<_ShopOffer> _weeklyOffers = [
    _ShopOffer(
      name: 'Value Wood Crate',
      discount: '20% OFF',
      icon: Icons.park,
      amount: 1500,
      bundle: {'wood': 1500},
    ),
    _ShopOffer(
      name: 'Stone Quarry Pack',
      discount: '30% OFF',
      icon: Icons.landscape,
      amount: 1200,
      bundle: {'stone': 1200},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 820),
        child: Container(
          decoration: ntaPanel(),
          clipBehavior: Clip.antiAlias,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _categoryRail(),
              Expanded(child: _content(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryRail() {
    return Container(
      width: 96,
      color: const Color(0xFFE3D6BC),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: NtaColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: NtaColors.border, width: 2),
                    ),
                    child: const Icon(Icons.chevron_left,
                        size: 20, color: NtaColors.success),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final selected = _category == i;
                return GestureDetector(
                  onTap: () => setState(() => _category = i),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? NtaColors.surfaceCard
                          : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: selected
                              ? NtaColors.accentBorder
                              : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(_categoryIcons[i],
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 2),
                        Text(_categories[i],
                            textAlign: TextAlign.center,
                            style: NtaText.xs.copyWith(
                              fontSize: 9.5,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(GameState state) {
    if (_category == 2) return _topUpNotice();
    return Column(
      children: [
        _headerBanner(),
        _offerTabs(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            children: [
              for (final offer in (_tab == 0 ? _dailyOffers : _weeklyOffers))
                _offerCard(state, offer),
              if (_tab == 0) _dailyGift(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerBanner() {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D4C6E), Color(0xFF6A7FA8)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tab == 0 ? 'Daily Offer' : 'Weekly Offer',
                  style: NtaText.heading.copyWith(
                      fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x55000000),
                    borderRadius: BorderRadius.circular(NtaRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 3),
                      Text('09:48:42',
                          style: NtaText.xs.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 14,
            bottom: 0,
            child: Icon(Icons.storefront,
                size: 62, color: Color(0x55FFFFFF)),
          ),
        ],
      ),
    );
  }

  Widget _offerTabs() {
    return Row(
      children: [
        _offerTabsBtn('Daily Offer', 0),
        _offerTabsBtn('Weekly Offer', 1),
      ],
    );
  }

  Widget _offerTabsBtn(String label, int idx) {
    final selected = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? NtaColors.accentTop : NtaColors.surfaceCard,
            border: Border(
              bottom: BorderSide(
                color: selected ? NtaColors.accentBorder : NtaColors.borderSoft,
                width: selected ? 3 : 1,
              ),
            ),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: selected
                  ? NtaText.bodyBold.copyWith(fontSize: 14)
                  : NtaText.body.copyWith(
                      fontSize: 14, color: NtaColors.textMuted)),
        ),
      ),
    );
  }

  Widget _offerCard(GameState state, _ShopOffer offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF2D4), Color(0xFFFBEBB8)],
        ),
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(color: const Color(0xFFE7C964), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(offer.name,
                    style: NtaText.bodyBold.copyWith(fontSize: 14)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF5A623), Color(0xFFF57C00)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFB35E00), width: 1.5),
                ),
                child: Text(offer.discount,
                    style: NtaText.xs.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF7E4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE7C964), width: 1.5),
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(offer.icon, size: 24)),
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Text('${offer.amount}',
                          style: NtaText.xs.copyWith(
                              fontSize: 8, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Daily Purchase Limit: 1',
                  style: NtaText.sm.copyWith(fontSize: 10.5),
                ),
              ),
              _freeButton(state, offer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _freeButton(GameState state, _ShopOffer offer) {
    return GestureDetector(
      onTap: () {
        state.grantWheelReward(offer.bundle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Claimed: ${offer.name} (free).'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDEFB7B), Color(0xFFB9E85A)],
          ),
          borderRadius: BorderRadius.circular(NtaRadius.button),
          border: Border.all(color: const Color(0xFF73AA4A), width: 2),
        ),
        child: Text('Free',
            style: NtaText.bodyBold.copyWith(
                fontSize: 13, color: NtaColors.onAccent)),
      ),
    );
  }

  Widget _dailyGift(GameState state) {
    final claimed = state.dailyGiftClaimed;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NtaColors.surfaceCard,
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(color: NtaColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Gift', style: NtaText.bodyBold.copyWith(fontSize: 14)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAFBAA), Color(0xFFC7E86E)],
              ),
              borderRadius: BorderRadius.circular(NtaRadius.card),
              border: Border.all(color: const Color(0xFF88B84A), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('3 Free Coin',
                          style: NtaText.bodyBold.copyWith(fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(
                        claimed ? 'Claimed today' : 'Tap to claim your gift',
                        style: NtaText.sm.copyWith(
                            fontSize: 11,
                            color: claimed
                                ? NtaColors.textMuted
                                : NtaColors.success,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: claimed ? null : () => state.claimDailyGift(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF7E4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF88B84A), width: 1.5),
                    ),
                    child: Icon(
                      claimed ? Icons.check_circle : Icons.card_giftcard,
                      color: claimed
                          ? NtaColors.success
                          : const Color(0xFFE7A11C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topUpNotice() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 52, color: NtaColors.textMuted),
            const SizedBox(height: 12),
            Text('Top-up', style: NtaText.title),
            const SizedBox(height: 8),
            Text(
              'Not available in offline build.\n'
              'This game is fully playable without purchases.',
              textAlign: TextAlign.center,
              style: NtaText.sm,
            ),
          ],
        ),
      ),
    );
  }
}