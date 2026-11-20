import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../ui/design_tokens.dart';
import '../ui/asset_manager.dart';

/// HUD overlay tampilan dunia — meniru layout `Tampilan Utama.jpg`:
///
///   - rail kanan vertikal: 5 tombol (setting, profil, hero, muster, ranking)
///   - dua chip timer (construction queue, march list)
///   - satu petak unit prajurit di pojok kanan-bawah.
///
/// Semua tombol membuka modal masing-masing (lihat [MapHudCallbacks]).
class MapHudRail extends StatelessWidget {
  const MapHudRail({super.key, required this.callbacks});

  final MapHudCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    // Stack needs bounded constraints — wrap in SizedBox with known rail height.
    // Rail: 5 btns × 44 + 4 gaps × 4 + padding 12 = ~248px.
    // Timer chips positioned BELOW rail (not to the right).
    return SizedBox(
      width: 60, // rail width (44 + padding 6 + 6)
      height: 400, // rail (~248) + gap + 2 timer chips + margin
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Rail at top
          Positioned(top: 0, right: 0, child: _buildRail(context)),
          // Timer chips BELOW rail (diturunkan lebih)
          Positioned(
            top: 300,
            right: 0,
            child: _timerChip(context, 'ic_record', '13:05', callbacks.onConstructionQueue),
          ),
          Positioned(
            top: 345,
            right: 0,
            child: _timerChip(context, 'ic_popularity', '120:35', callbacks.onMarchList),
          ),
        ],
      ),
    );
  }

  Widget _buildRail(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: NtaColors.rail,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(NtaRadius.panel),
          bottomLeft: Radius.circular(NtaRadius.panel),
        ),
        boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Setting (4 kubus)
          _RailBtn(icon: NtaAssets.chromeImage('ic_max', width: 26, height: 26, fit: BoxFit.contain), onTap: null),
          const SizedBox(height: 4),
          // 2. Profil
          _RailBtn(icon: NtaAssets.chromeImage('ic_user', width: 26, height: 26, fit: BoxFit.contain), onTap: callbacks.onProfile),
          const SizedBox(height: 4),
          // 3. List hero
          _RailBtn(icon: NtaAssets.chromeImage('ic_popularity', width: 26, height: 26, fit: BoxFit.contain), onTap: callbacks.onHeroes),
          const SizedBox(height: 4),
          // 4. General Muster Terrace
          _RailBtn(icon: NtaAssets.chromeImage('ic_confirm', width: 26, height: 26, fit: BoxFit.contain), onTap: callbacks.onGeneralMuster),
          const SizedBox(height: 4),
          // 5. Ranking pemain
          _RailBtn(icon: NtaAssets.chromeImage('ic_popularity', width: 26, height: 26, fit: BoxFit.contain), onTap: callbacks.onBattleRankings),
        ],
      ),
    );
  }
}

/// Stateless rail button - avoids rebuild when parent rebuilds.
class _RailBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;

  const _RailBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: const BoxDecoration(
          color: NtaColors.rail,
          borderRadius: BorderRadius.all(Radius.circular(NtaRadius.button)),
        ),
        child: Center(
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(NtaColors.railIcon, BlendMode.srcIn),
            child: icon,
          ),
        ),
      ),
    );
  }
}

Widget _timerChip(
  BuildContext context,
  String chromeKey,
  String label,
  VoidCallback? onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NtaColors.surfaceRaised,
        border: Border.all(color: NtaColors.hudBorder, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(NtaRadius.pill)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NtaAssets.chromeImage(chromeKey, width: 16, height: 16, fit: BoxFit.contain),
          const SizedBox(width: 4),
          Text(label, style: NtaText.xs.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

/// Kumpulan callback yang dipakai [MapHudRail] + tombol bawah.
class MapHudCallbacks {
  const MapHudCallbacks({
    this.onMapOverview,
    this.onHeroes,
    this.onBattleRankings,
    this.onProfile,
    this.onGeneralMuster,
    this.onConstructionQueue,
    this.onMarchList,
    this.onArmies,
    this.onChat,
  });

  final VoidCallback? onMapOverview;
  final VoidCallback? onHeroes;
  final VoidCallback? onBattleRankings;
  final VoidCallback? onProfile;
  final VoidCallback? onGeneralMuster;
  final VoidCallback? onConstructionQueue;
  final VoidCallback? onMarchList;
  final VoidCallback? onArmies;
  final VoidCallback? onChat;
}

/// Petak prajurit di pojok kanan-bawah (mirip `Tampilan Utama.jpg`) —
/// menampilkan jumlah prajurit aktif + ikon runcing.
class MapUnitThumb extends StatelessWidget {
  const MapUnitThumb({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final n = state.troops.values.fold<int>(0, (a, b) => a + b);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: NtaColors.surfaceRaised,
          border: Border.all(color: NtaColors.hudBorder, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(NtaRadius.button)),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Stack(
          children: [
            Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(NtaColors.text, BlendMode.srcIn),
                child: NtaAssets.chromeImage('ic_user', width: 26, height: 26, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: const BoxDecoration(
                  color: NtaColors.accentTop,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Text('$n', style: NtaText.xs.copyWith(fontWeight: FontWeight.w700, color: NtaColors.onAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder modal kecil untuk fitur yang belum diimplementasi.
void showStubPanel(BuildContext context, String title) {
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: NtaColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NtaRadius.panel),
        side: const BorderSide(color: NtaColors.border, width: NtaBorder.panel),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: NtaText.title),
            const SizedBox(height: 10),
            Text('Panel belum diimplementasikan.', style: NtaText.sm.copyWith(color: NtaColors.textMuted)),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          ],
        ),
      ),
    ),
  );
}