import 'package:flutter/material.dart';

/// Design tokens — diukur piksel-per-piksel dari screenshot game asli
/// (Building Info, Hero detail, Rules, HUD world map).
///
/// Sumber tunggal: `replica/design/tokens.json` + `tokens.css`.
/// Nilai = warna asli hasil sampling. Kontras WCAG: `replica/design/contrast_report.txt`
/// (0 gagal AA). Kalau ganti nilai, jalankan ulang:
///   python contrast_check.py replica/design/tokens.json
class NtaColors {
  NtaColors._();

  // Latar
  static const bg = Color(0xFFD6DF84); // rumput map
  static const bgAlt = Color(0xFFC5D77B);
  static const surface = Color(0xFFF6EFDF); // body panel
  static const surfaceRaised = Color(0xFFFFFBEF); // kartu terang di panel
  static const surfaceCard = Color(0xFFE8DDC7); // kartu di dalam panel
  static const surfaceSunk = Color(0xFFEDE6CE);

  // Border
  static const border = Color(0xFF4E4037); // border panel ~3dp
  static const borderSoft = Color(0xFFDDD3BA);
  static const borderInput = Color(0xFF947D6B);

  // Teks
  static const text = Color(0xFF3A3026);
  static const textMuted = Color(0xFF5B544C);
  static const textOnDark = Color(0xFFFFF7EF);

  // Aksi utama (tombol gold)
  static const accent = Color(0xFFFFDA6B);
  static const accentTop = Color(0xFFFFE288);
  static const accentBottom = Color(0xFFFDD866);
  static const accentBorder = Color(0xFF6D5249);
  static const accentSoft = Color(0xFFFEEBB0);
  static const onAccent = Color(0xFF282723);

  // Status
  static const success = Color(0xFF356F24);
  static const danger = Color(0xFFAD4D3A);
  static const warning = Color(0xFFE6DF8C);
  static const disabled = Color(0xFFDED7CD);

  // HUD world map
  static const hudSurface = Color(0xFFFFF7EF);
  static const hudBorder = Color(0xFF947D6B);
  static const hudText = Color(0xFF5F4E3E);
  static const hudRate = Color(0xFF3A7325);
  static const hudProgress = Color(0xFF63B6FF);
  static const hudTrack = Color(0xFFFFF3E6);
  static const buttonPlus = Color(0xFFDEFB7B);
  static const buttonPlusEdge = Color(0xFF73AA4A);

  // Rail + hero
  static const rail = Color(0xFF7B814A);
  static const railIcon = Color(0xFFF7F7E6);
  static const heroTeal = Color(0xFF59AA97);
  static const heroNamePill = Color(0xFF39716E);

  // Peta
  static const mapGreenA = Color(0xFFD6DF84);
  static const mapGreenB = Color(0xFFC5D77B);
  static const mapRoad = Color(0xFFE6DF8C);

  // Toast / scrim
  static const toastBg = Color(0xB8000000);
  static const toastText = Color(0xFFFFF7EF);
  static const scrim = Color(0x99000000);

  // Alias lama (nama dipertahankan supaya file lain tidak pecah)
  static const panelBg = surface;
  static const panelCard = surfaceCard;
  static const panelHeader = surfaceCard;
  static const panelBorder = border;
  static const textPrimary = text;
  static const textSecondary = textMuted;
  static const goldTop = accentTop;
  static const goldBottom = accentBottom;
  static const goldBorder = accentBorder;
  static const valueGreen = success;
  static const starGold = accentBottom;
  static const starEmpty = Color(0xFFC4BBAA);
  static const hudPill = hudSurface;
  static const hudText_ = hudText;
}

/// Ikon resource dari Material (emoji tidak tersedia di semua platform/font).
IconData ntaResIconData(String resource) {
  switch (resource) {
    case 'crop':
      return Icons.grass;
    case 'wood':
      return Icons.park;
    case 'stone':
      return Icons.landscape;
    case 'iron':
      return Icons.settings;
    case 'exp_scroll':
      return Icons.menu_book;
    case 'scroll':
      return Icons.receipt_long;
    case 'nail':
      return Icons.hardware;
    default:
      return Icons.inventory_2;
  }
}

/// Ikon bangunan capital dari Material.
IconData ntaBuildingIcon(String id) {
  switch (id) {
    case 'palace':
      return Icons.account_balance;
    case 'barracks':
      return Icons.shield;
    case 'smithy':
      return Icons.handyman;
    case 'hall_of_heroes':
      return Icons.auto_awesome;
    case 'drill_ground':
      return Icons.flag;
    case 'clinic':
      return Icons.local_hospital;
    case 'market':
      return Icons.store;
    case 'union_market':
      return Icons.storefront;
    case 'embassy':
      return Icons.handshake;
    case 'barn':
      return Icons.home;
    case 'warehouse':
      return Icons.inventory_2;
    default:
      return Icons.help_outline;
  }
}

/// Ikon resource siap pakai.
class NtaResIcon extends StatelessWidget {
  final String resource;
  final double size;
  final Color? color;

  const NtaResIcon(this.resource, {super.key, this.size = 18, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      ntaResIconData(resource),
      size: size,
      color: color ?? NtaColors.text,
    );
  }
}

class NtaRadius {
  NtaRadius._();
  static const pill = 8.0;
  static const button = 12.0;
  static const card = 12.0;
  static const panel = 16.0;
  static const round = 999.0;
}

class NtaBorder {
  NtaBorder._();
  static const panel = 3.0;
  static const button = 2.5;
  static const card = 1.5;
  static const hairline = 1.0;
}

class NtaSpace {
  NtaSpace._();
  static const x1 = 2.0;
  static const x2 = 4.0;
  static const x3 = 6.0;
  static const itemGap = 8.0;
  static const x5 = 10.0;
  static const sectionGap = 12.0;
  static const panelPad = 16.0;
  static const x12 = 24.0;
}

class NtaText {
  NtaText._();
  static const xs = TextStyle(fontSize: 10, height: 1.4, fontWeight: FontWeight.w500, color: NtaColors.text);
  static const sm = TextStyle(fontSize: 12, height: 1.33, fontWeight: FontWeight.w500, color: NtaColors.textMuted);
  static const body = TextStyle(fontSize: 14, height: 1.43, color: NtaColors.text);
  static const bodyBold = TextStyle(fontSize: 14, height: 1.43, fontWeight: FontWeight.w700, color: NtaColors.text);
  static const title = TextStyle(fontSize: 16, height: 1.38, fontWeight: FontWeight.w700, color: NtaColors.text);
  static const heading = TextStyle(fontSize: 20, height: 1.3, fontWeight: FontWeight.w700, color: NtaColors.text);
  static const display = TextStyle(fontSize: 28, height: 1.21, fontWeight: FontWeight.w700, color: NtaColors.text);
  static const stat = TextStyle(fontSize: 16, height: 1.38, fontWeight: FontWeight.w700, color: NtaColors.text);
  static const caption = sm;
  static const hudValue = TextStyle(fontSize: 16, height: 1.3, fontWeight: FontWeight.w700, color: NtaColors.hudText);
  static const hudRate = TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w700, color: NtaColors.hudRate);
}

// ---------------------------------------------------------------------------
// Primitives — dibangun sekali di sini, dipakai semua screen.
// Spec: replica/design/components.md
// ---------------------------------------------------------------------------

/// Panel modal: cream + border coklat 3dp + radius 16 + shadow.
BoxDecoration ntaPanel({Color bg = NtaColors.surface, double radius = NtaRadius.panel}) {
  return BoxDecoration(
    color: bg,
    border: Border.all(color: NtaColors.border, width: NtaBorder.panel),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );
}

/// Kartu di dalam panel.
BoxDecoration ntaCard({Color bg = NtaColors.surfaceCard, bool selected = false}) {
  return BoxDecoration(
    color: selected ? NtaColors.accentSoft : bg,
    border: Border.all(color: NtaColors.border, width: NtaBorder.card),
    borderRadius: BorderRadius.circular(NtaRadius.card),
  );
}

/// Kartu terang (raised) untuk konten di atas panel.
BoxDecoration ntaRaisedCard() {
  return BoxDecoration(
    color: NtaColors.surfaceRaised,
    border: Border.all(color: NtaColors.borderSoft, width: NtaBorder.hairline),
    borderRadius: BorderRadius.circular(NtaRadius.card),
  );
}

/// Tombol utama gold: gradient accent-top -> accent-bottom, border 2.5dp.
/// states: default, pressed (geser 1dp, shadow mati), disabled (bg disabled).
class NtaGoldButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final double fontSize;
  final EdgeInsets padding;

  const NtaGoldButton(
    this.label, {
    super.key,
    this.onTap,
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
  });

  @override
  State<NtaGoldButton> createState() => _NtaGoldButtonState();
}

class _NtaGoldButtonState extends State<NtaGoldButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          transform: Matrix4.translationValues(0, _pressed ? 1 : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [NtaColors.accentTop, NtaColors.accentBottom],
                  )
                : null,
            color: enabled ? null : NtaColors.disabled,
            border: Border.all(
              color: enabled ? NtaColors.accentBorder : NtaColors.borderSoft,
              width: NtaBorder.button,
            ),
            borderRadius: BorderRadius.circular(NtaRadius.button),
            boxShadow: enabled && !_pressed
                ? const [BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 3))]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w700,
              color: enabled ? NtaColors.onAccent : NtaColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper lama (kompatibilitas) — delegasi ke NtaGoldButton.
Widget ntaGoldButton(String label, {VoidCallback? onTap, double fontSize = 16}) =>
    NtaGoldButton(label, onTap: onTap, fontSize: fontSize);

/// Pill resource HUD: cream, border coklat 2dp, progress biru di bawah nilai.
class NtaResourcePill extends StatelessWidget {
  final Widget icon;
  final String value;
  final String? rate;
  final double? progress; // 0..1, null = tanpa bar

  const NtaResourcePill({
    super.key,
    required this.icon,
    required this.value,
    this.rate,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: rate == null ? value : '$value, $rate',
      child: Container(
        height: 34,
        padding: const EdgeInsets.fromLTRB(8, 3, 10, 3),
        decoration: BoxDecoration(
          color: NtaColors.hudSurface,
          border: Border.all(color: NtaColors.hudBorder, width: 2),
          borderRadius: BorderRadius.circular(NtaRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 20, height: 20, child: icon),
            const SizedBox(width: 6),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value, style: NtaText.hudValue.copyWith(height: 1.05)),
                    if (rate != null) ...[
                      const SizedBox(width: 2),
                      Text(rate!, style: NtaText.hudRate.copyWith(height: 1.05)),
                    ],
                  ],
                ),
                if (progress != null)
                  Container(
                    width: 76,
                    height: 3,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: NtaColors.hudTrack,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress!.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: NtaColors.hudProgress,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill counter HUD (coin / reward points), opsional tombol plus hijau.
class NtaCounterPill extends StatelessWidget {
  final Widget icon;
  final String value;
  final VoidCallback? onPlus;

  const NtaCounterPill({super.key, required this.icon, required this.value, this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: NtaColors.hudSurface,
        border: Border.all(color: NtaColors.hudBorder, width: 2),
        borderRadius: BorderRadius.circular(NtaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 6),
          SizedBox(width: 20, height: 20, child: icon),
          const SizedBox(width: 6),
          Text(value, style: NtaText.hudValue),
          const SizedBox(width: 8),
          if (onPlus != null)
            GestureDetector(
              onTap: onPlus,
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  color: NtaColors.buttonPlus,
                  border: Border.all(color: NtaColors.buttonPlusEdge, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, size: 16, color: NtaColors.onAccent),
              ),
            )
          else
            const SizedBox(width: 6),
        ],
      ),
    );
  }
}

/// Badge level gelap ("Level 1").
Widget ntaLevelBadge(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: NtaColors.border,
      borderRadius: BorderRadius.circular(NtaRadius.pill),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 10, height: 1.4, fontWeight: FontWeight.w700, color: NtaColors.textOnDark),
    ),
  );
}

/// Baris perbandingan stat: label kiri, nilai sekarang, nilai berikut (hijau).
class NtaStatRow extends StatelessWidget {
  final String label;
  final String current;
  final String next;

  const NtaStatRow({super.key, required this.label, required this.current, required this.next});

  @override
  Widget build(BuildContext context) {
    final changed = current != next;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text('$label: $current', style: NtaText.body)),
          Text(
            next,
            style: changed
                ? NtaText.bodyBold.copyWith(color: NtaColors.success)
                : NtaText.body.copyWith(color: NtaColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Tombol ikon di HUD: kartu cream + border coklat.
class NtaIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;

  const NtaIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: NtaColors.surfaceRaised,
            border: Border.all(color: NtaColors.hudBorder, width: 2),
            borderRadius: BorderRadius.circular(NtaRadius.button),
            boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Icon(icon, size: size * 0.5, color: NtaColors.text),
        ),
      ),
    );
  }
}

/// Toast / banner quest di bawah tengah.
class NtaToast extends StatelessWidget {
  final String text;
  const NtaToast({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: NtaColors.toastBg,
        borderRadius: BorderRadius.circular(NtaRadius.pill),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: NtaColors.toastText)),
    );
  }
}

/// Tab segment ala panel asli: aktif = cream, non-aktif = tint coklat.
class NtaSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const NtaSegmentedTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: i == selected ? NtaColors.surface : NtaColors.surfaceCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(NtaRadius.card)),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: i == selected
                      ? NtaText.bodyBold
                      : NtaText.body.copyWith(color: NtaColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
