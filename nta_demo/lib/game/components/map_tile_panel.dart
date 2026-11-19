import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/game_data.dart';
import '../models/game_state.dart';
import '../ui/design_tokens.dart';

/// Panel aksi tile map, mengikuti layout game asli (folder `Main UI/`):
/// plate judul + koordinat di atas, kartu info di kiri, tumpukan tombol di
/// kanan. Tiga varian: capital, plot dikuasai, plot liar.
class MapTilePanel extends StatelessWidget {
  final int row;
  final int col;

  const MapTilePanel({super.key, required this.row, required this.col});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final bool isCapital = state.isCapitalTile(row, col);
    final remains = state.remainsAt(row, col);
    final bool conquered = state.isTileConquered(row, col);
    final plot = state.getPlotData(row, col);

    final String title;
    if (isCapital) {
      title = 'Imperial Capital';
    } else if (remains != null) {
      title = '${remains['name']} Remains';
    } else if (conquered) {
      title = _plotTitle(plot, conquered: true);
    } else {
      title = _plotTitle(plot, conquered: false);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _titlePlate(context, title, state, isCapital),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _infoCard(context, state, isCapital, remains, conquered, plot),
            const SizedBox(width: 8),
            _buttonStack(context, state, isCapital, remains, conquered),
          ],
        ),
      ],
    );
  }

  // --- judul tile --------------------------------------------------------
  String _plotTitle(Map<String, dynamic>? plot, {required bool conquered}) {
    if (plot == null) return 'Wasteland';
    final lv = plot['level'] as int? ?? 1;
    if (lv <= 1) return 'Wasteland';
    final res = (plot['resource'] as String? ?? 'crop');
    final resName = res == 'crop' ? 'Crop' : (res == 'wood' ? 'Wood' : 'Stone');
    return 'Lv.$lv $resName Plot';
  }

  Widget _titlePlate(
    BuildContext context,
    String title,
    GameState state,
    bool isCapital,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: NtaColors.surfaceRaised,
        borderRadius: BorderRadius.circular(NtaRadius.pill),
        border: Border.all(color: NtaColors.hudBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: NtaText.bodyBold),
          const SizedBox(width: 8),
          Text('($row,$col)', style: NtaText.sm),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _toast(context, 'Flag placed at ($row,$col).'),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: NtaColors.buttonPlus,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NtaColors.buttonPlusEdge, width: 2),
              ),
              child: const Icon(Icons.flag, size: 18, color: NtaColors.success),
            ),
          ),
        ],
      ),
    );
  }

  // --- kartu info --------------------------------------------------------
  Widget _infoCard(
    BuildContext context,
    GameState state,
    bool isCapital,
    Map<String, dynamic>? remains,
    bool conquered,
    Map<String, dynamic>? plot,
  ) {
    final rows = <Widget>[];

    if (isCapital) {
      final palaceLvl = state.capitalBuildings['palace'] ?? 1;
      final hp = 200 + (palaceLvl - 1) * 20;
      rows.add(_infoRow(Icons.favorite, '$hp', color: NtaColors.danger));
      rows.add(_infoRow(Icons.arrow_upward, 'Lv.$palaceLvl'));
      rows.add(_infoRow(Icons.shield, 'Team ${state.armyCap}'));
    } else if (remains != null) {
      final lvl = remains['level'] as int? ?? 1;
      final owner = remains['owner'] as String? ?? 'neutral';
      rows.add(_infoRow(Icons.favorite, '${40 + lvl * 20}', color: NtaColors.danger));
      rows.add(_infoRow(Icons.arrow_upward, 'Lv.$lvl'));
      rows.add(_infoRow(Icons.workspace_premium,
          owner == 'player' ? 'You' : (owner == 'neutral' ? 'Neutral' : owner)));
    } else if (conquered) {
      // Referensi `Tampilan Jika Plot Biasa dikuasai di Klik.jpg`:
      // 笛叶 (heart HP) / ⭑ Lv.1 / 🏅 FallStar7 / ikon +4/h — 4 baris.
      final stats = state.plotTowerStats(row, col);
      final lvl = plot?['level'] as int? ?? 1;
      final prod = _plotYield(plot);
      final who = state.playerName.isNotEmpty ? state.playerName : 'Commander';
      rows.add(_infoRow(Icons.favorite, '${stats['hp']}', color: NtaColors.danger));
      rows.add(_infoRow(Icons.star, 'Lv.$lvl', color: NtaColors.accentTop));
      rows.add(_infoRow(Icons.military_tech, who, color: NtaColors.success));
      if (prod != null) {
        rows.add(_infoRow(_resIcon(prod.$1), '+${prod.$2}/h', color: NtaColors.success));
      }
    } else {
      final lvl = plot?['level'] as int? ?? 1;
      final diff = plot?['difficulty'] as String? ?? 'Easy';
      final prod = _plotYield(plot);
      rows.add(_infoRow(Icons.favorite, lvl <= 1 ? '3' : '${lvl * 8}', color: NtaColors.danger));
      rows.add(_infoRow(Icons.local_fire_department, diff));
      if (prod != null) {
        rows.add(_infoRow(_resIcon(prod.$1), '+${prod.$2}/h', color: NtaColors.success));
      }
      rows.add(_infoRow(Icons.monetization_on, '0 Points'));
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: NtaColors.surface,
        borderRadius: BorderRadius.circular(NtaRadius.card),
        border: Border.all(color: NtaColors.border, width: NtaBorder.card),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color color = NtaColors.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(text, style: NtaText.sm.copyWith(color: NtaColors.text)),
        ],
      ),
    );
  }

  /// (resource, perHour) untuk satu plot; null = wasteland (semua resource).
  (String, int)? _plotYield(Map<String, dynamic>? plot) {
    if (plot == null) return null;
    final lv = plot['level'] as int? ?? 1;
    final landType = plot['landType'] as int? ?? 3;
    final res = plot['resource'] as String? ?? 'crop';
    final y = GameData.landYield(landType, lv);
    final v = y[res] ?? 0;
    if (v <= 0) return null;
    return (res, v.round());
  }

  IconData _resIcon(String res) => ntaResIconData(res);

  // --- tombol aksi -------------------------------------------------------
  Widget _buttonStack(
    BuildContext context,
    GameState state,
    bool isCapital,
    Map<String, dynamic>? remains,
    bool conquered,
  ) {
    final enter = _ActionBtn(
      label: 'Enter',
      icon: Icons.login,
      style: _BtnStyle.green,
      fullWidth: conquered && !isCapital && remains == null,
      onTap: () => _enter(context, state, isCapital, remains),
    );

    if (isCapital || remains != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          enter,
          const SizedBox(width: 6),
          _ActionBtn(
            label: 'March',
            icon: Icons.directions_walk,
            style: _BtnStyle.gold,
            onTap: () => _toast(context, 'March — pick an army (TODO).'),
          ),
        ],
      );
    }

    if (conquered) {
      // Referensi `Tampilan Jika Plot Biasa dikuasai di Klik.jpg`:
      // tumpukan vertikal 4 baris penuh-lebar, bukan grid 2x2.
      return SizedBox(
        width: 104,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            enter,
            const SizedBox(height: 5),
            _ActionBtn(
              label: 'Grain Garrison',
              icon: Icons.agriculture,
              style: _BtnStyle.cream,
              fullWidth: true,
              onTap: () => _toast(context, 'Grain Garrison — requires an army (TODO).'),
            ),
            const SizedBox(height: 5),
            _ActionBtn(
              label: 'Build',
              icon: Icons.handyman,
              style: _BtnStyle.cream,
              fullWidth: true,
              onTap: () => _buildGround(context, state),
            ),
            const SizedBox(height: 5),
            _ActionBtn(
              label: 'March',
              icon: Icons.directions_walk,
              style: _BtnStyle.gold,
              fullWidth: true,
              onTap: () => _toast(context, 'March — pick an army (TODO).'),
            ),
          ],
        ),
      );
    }

    // Plot liar: Enter + Conquer.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        enter,
        const SizedBox(width: 6),
        _ActionBtn(
          label: 'Conquer',
          icon: Icons.close,
          style: _BtnStyle.gold,
          onTap: () => _conquer(context, state),
        ),
      ],
    );
  }

  // --- aksi --------------------------------------------------------------
  void _enter(
    BuildContext context,
    GameState state,
    bool isCapital,
    Map<String, dynamic>? remains,
  ) {
    if (isCapital) {
      state.switchView('capital');
    } else {
      state.setPlotView(row, col);
    }
  }

  void _conquer(BuildContext context, GameState state) {
    final result = state.attackPlot(row, col);
    final bool victory = result['victory'] == true;
    _toast(
      context,
      victory ? 'Victory! Plot conquered.' : 'Defeat: ${result['reason'] ?? 'repelled'}',
    );
  }

  void _buildGround(BuildContext context, GameState state) {
    final ok = state.constructGroundBuilding(row, col);
    _toast(context, ok ? 'Ground facility constructed.' : 'Cannot build here.');
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}

enum _BtnStyle { green, gold, cream }

/// Tombol aksi kecil ala game asli: ikon + label, gradient hijau/emas/cream.
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final _BtnStyle style;
  final VoidCallback? onTap;

  /// `true` → tombol mengisi lebar induk (dipakai tumpukan vertikal plot
  /// dikuasai); `false` → lebar tetap 66px (grid 2 tombol).
  final bool fullWidth;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.style,
    this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Color top, bottom, border, fg;
    switch (style) {
      case _BtnStyle.green:
        top = NtaColors.buttonPlus;
        bottom = const Color(0xFFB7E85A);
        border = NtaColors.buttonPlusEdge;
        fg = NtaColors.success;
        break;
      case _BtnStyle.gold:
        top = NtaColors.accentTop;
        bottom = NtaColors.accentBottom;
        border = NtaColors.accentBorder;
        fg = NtaColors.onAccent;
        break;
      case _BtnStyle.cream:
        top = NtaColors.surfaceRaised;
        bottom = NtaColors.surfaceCard;
        border = NtaColors.hudBorder;
        fg = NtaColors.text;
        break;
    }

    return Semantics(
      button: true,
      label: label.replaceAll('\n', ' '),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: fullWidth ? null : 66,
          padding: EdgeInsets.symmetric(vertical: fullWidth ? 7 : 6, horizontal: fullWidth ? 8 : 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, bottom],
            ),
            borderRadius: BorderRadius.circular(NtaRadius.button),
            border: Border.all(color: border, width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 2)),
            ],
          ),
          child: fullWidth
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 15, color: fg),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: 9.5,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}