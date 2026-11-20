import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

/// Helper akses asset ekstrak dari APK asli.
///
/// Sprite plot diambil dari bundle `resources` asli lewat
/// `extract_demo_pack.py` (atlas Cocos → PNG per frame):
/// - `plots/`      ikon per level plot (grain/tree/stone 101-104 = lv 2-5,
///                 dipetakan langsung dari `common/json/land.json`)
/// - `terrain/`    tile terrain (grass/hill/lake/river/sea/mountain/beach/bridge)
/// - `flags/`      angka bendera plot (map_flag_0-9, x)
/// - `capital/`    skin capital per level (city_1001..city_1001122) + fortress/farm
/// - `buildings/`  sprite bangunan capital (build_2001 = palace, 2004 barrack, ...)
/// - `ui/`         ikon season/treasure/reward point
/// - `ui_chrome/`  panel, tombol, ikon UI 9-slice dari atlas asli (51 frame)
class NtaAssets {
  NtaAssets._();

  // --- Chrome UI (9-slice & ikon) ----------------------------------------
  /// Semua key chrome tersedia beserta metadata 9-slice (capInsets).
  /// Data sumber: `_chrome_manifest.json` (dihasilkan `_extract_chrome.py`).
  static const Map<String, _ChromeMeta> _chromeMeta = {
    // Tombol gold
    'btn_gold_round': _ChromeMeta('btn_gold_round.png', Rect.fromLTRB(16, 16, 16, 16)),
    'btn_gold_round_diamond': _ChromeMeta('btn_gold_round_diamond.png', Rect.fromLTRB(20, 30, 20, 30)),
    'btn_gold_wide': _ChromeMeta('btn_gold_wide.png', Rect.fromLTRB(54, 26, 0, 16)),
    'btn_gold_wide2': _ChromeMeta('btn_gold_wide2.png', Rect.zero),
    // Tombol putih
    'btn_white_wide': _ChromeMeta('btn_white_wide.png', Rect.fromLTRB(50, 0, 50, 0)),
    'btn_white_round': _ChromeMeta('btn_white_round.png', Rect.fromLTRB(25, 25, 25, 25)),
    // Panah / plus
    'btn_arrow': _ChromeMeta('btn_arrow.png', Rect.zero),
    'frame_plus': _ChromeMeta('frame_plus.png', Rect.zero),
    // Panel
    'panel_wide': _ChromeMeta('panel_wide.png', Rect.fromLTRB(48, 0, 48, 0)),
    'panel_ring': _ChromeMeta('panel_ring.png', Rect.fromLTRB(48, 0, 48, 0)),
    'panel_cream': _ChromeMeta('panel_cream.png', Rect.fromLTRB(32, 32, 32, 32)),
    'panel_square': _ChromeMeta('panel_square.png', Rect.fromLTRB(16, 16, 16, 16)),
    'panel_dark': _ChromeMeta('panel_dark.png', Rect.fromLTRB(12, 12, 12, 12)),
    'panel_inset': _ChromeMeta('panel_inset.png', Rect.fromLTRB(8, 8, 8, 8)),
    // Frame
    'frame_selected': _ChromeMeta('frame_selected.png', Rect.fromLTRB(16, 16, 16, 16)),
    'box_frame_1': _ChromeMeta('box_frame_1.png', Rect.fromLTRB(11, 11, 11, 11)),
    'box_frame_2': _ChromeMeta('box_frame_2.png', Rect.zero),
    // Title quality
    'title_q1': _ChromeMeta('title_q1.png', Rect.zero),
    'title_q2': _ChromeMeta('title_q2.png', Rect.zero),
    'title_q3': _ChromeMeta('title_q3.png', Rect.zero),
    'title_q4': _ChromeMeta('title_q4.png', Rect.zero),
    'title_q5': _ChromeMeta('title_q5.png', Rect.zero),
    'title_q6': _ChromeMeta('title_q6.png', Rect.zero),
    'title_q7': _ChromeMeta('title_q7.png', Rect.zero),
    'title_empty': _ChromeMeta('title_empty.png', Rect.zero),
    // Ikon UI
    'ic_confirm': _ChromeMeta('ic_confirm.png', Rect.zero),
    'ic_cancel': _ChromeMeta('ic_cancel.png', Rect.zero),
    'ic_chat_send': _ChromeMeta('ic_chat_send.png', Rect.zero),
    'ic_back': _ChromeMeta('ic_back.png', Rect.zero),
    'ic_chat': _ChromeMeta('ic_chat.png', Rect.zero),
    'ic_add_friend': _ChromeMeta('ic_add_friend.png', Rect.zero),
    'ic_user': _ChromeMeta('ic_user.png', Rect.zero),
    'ic_max': _ChromeMeta('ic_max.png', Rect.zero),
    'ic_min': _ChromeMeta('ic_min.png', Rect.zero),
    'ic_eye_on': _ChromeMeta('ic_eye_on.png', Rect.zero),
    'ic_eye_off': _ChromeMeta('ic_eye_off.png', Rect.zero),
    'ic_bgm_on': _ChromeMeta('ic_bgm_on.png', Rect.zero),
    'ic_bgm_off': _ChromeMeta('ic_bgm_off.png', Rect.zero),
    'ic_sfx_on': _ChromeMeta('ic_sfx_on.png', Rect.zero),
    'ic_sfx_off': _ChromeMeta('ic_sfx_off.png', Rect.zero),
    // Bar / flag / map
    'bar_hp': _ChromeMeta('bar_hp.png', Rect.zero),
    'flag_bg': _ChromeMeta('flag_bg.png', Rect.zero),
    'map_mask': _ChromeMeta('map_mask.png', Rect.zero),
    // Lainnya
    'ic_popularity': _ChromeMeta('ic_popularity.png', Rect.zero),
    'ic_record': _ChromeMeta('ic_record.png', Rect.zero),
    'buff_bg_0': _ChromeMeta('buff_bg_0.png', Rect.fromLTRB(10, 10, 10, 10)),
    'buff_bg_1': _ChromeMeta('buff_bg_1.png', Rect.fromLTRB(10, 10, 10, 10)),
    // Season background
    'season_bg_0': _ChromeMeta('season_bg_0.png', Rect.zero),
    'season_bg_1': _ChromeMeta('season_bg_1.png', Rect.zero),
    'season_bg_2': _ChromeMeta('season_bg_2.png', Rect.zero),
    'season_bg_3': _ChromeMeta('season_bg_3.png', Rect.zero),
  };

  /// Path file PNG chrome (`assets/images/ui_chrome/<key>.png`).
  static String chrome(String key) => 'assets/images/ui_chrome/$key.png';

  /// Metadata 9-slice (capInsets) untuk key chrome. Null kalau bukan 9-slice.
  static Rect? chromeSlice(String key) => _chromeMeta[key]?.capInsets;

  /// Widget Image chrome. Flutter web (`CanvasKit`/`HTML`) tidak mendukung
  /// `centerSlice` (9-slice) secara konsisten — citra sering tampil sebagai
  /// kotak kecil di tengah container, bukan meregang. Karena itu kita drop
  /// `centerSlice` sepenuhnya dan pakai `BoxFit.fill` biasa agar citra memenuhi
  /// seluruh container.
  static Widget chromeImage(String key,
      {double? width, double? height, BoxFit fit = BoxFit.fill}) {
    return Image.asset(chrome(key), width: width, height: height, fit: fit,
        filterQuality: FilterQuality.none);
  }

  /// Container dengan background chrome. Tanpa `centerSlice`, citra di-stretch
  /// memenuhi seluruh container melalui `BoxFit.fill`.
  static BoxDecoration chromeDecoration(String key, {Color? color}) {
    return BoxDecoration(
      color: color,
      image: DecorationImage(
        image: AssetImage(chrome(key)),
        fit: BoxFit.fill,
      ),
    );
  }

  // --- Original asset getters ----------------------------------------------

  /// Ikon plot per (tipe resource, level). Level 1 = wasteland (ikon kosong).
  /// Sumber: game_json/land.json — grain_101 = crop lv2, grain_104 = crop lv5.
  static String? plotIcon(String resource, int level) {
    if (level <= 1) return null;
    final idx = level - 1; // lv2 -> 101
    switch (resource) {
      case 'crop':
        return 'assets/images/plots/grain_10$idx.png';
      case 'wood':
        return 'assets/images/plots/tree_10$idx.png';
      case 'stone':
        return 'assets/images/plots/stone_10$idx.png';
      default:
        return null;
    }
  }

  /// Tile grass untuk lantai plot interior (11x11 / 17x17).
  static String get grassTile => 'assets/images/terrain/grass_101.png';

  /// Tile air solid (`sea_2_101` = laut dalam tanpa busa).
  static String get waterTile => 'assets/images/terrain/sea_2_101.png';

  /// Tile hutan/gunung solid — potongan sel interior dari autotile sheet asli
  /// (`decorate/hill_101`, `mountain/mountain_N/...`), diekstrak oleh
  /// `extract_demo_pack.py` (FILL_CELLS).
  static String get forestTile => 'assets/images/terrain/fill_forest.png';
  static String mountainTile(int variant) =>
      'assets/images/terrain/fill_mountain_${(variant % 5) + 1}.png';

  /// Rumpun rumput transparan (grass_101-104) untuk tekstur padang.
  static String grassTuft(int variant) =>
      'assets/images/terrain/grass_10${(variant % 4) + 1}.png';

  /// Dekorasi plot liar (jerami / pohon kecil / batu) — atlas `decorate/`
  /// asli. Dipakai sebagai taburan kecil di tile map (lihat
  /// `Tampilan Utama.jpg`).
  static String plotDecoration(int variant) {
    const List<String> paths = [
      'assets/images/terrain/grain_101.png',
      'assets/images/terrain/grain_103.png',
      'assets/images/terrain/tree_101.png',
      'assets/images/terrain/tree_103.png',
      'assets/images/terrain/stone_101.png',
      'assets/images/terrain/stone_103.png',
    ];
    return paths[variant % paths.length];
  }

  /// Hiasan rumput liar di area capital (batu / semak) — beda atlas path.
  static String capitalGardenDecoration(int variant) {
    const List<String> paths = [
      'assets/images/terrain/stone_102.png',
      'assets/images/terrain/stone_104.png',
      'assets/images/terrain/tree_102.png',
      'assets/images/terrain/tree_104.png',
    ];
    return paths[variant % paths.length];
  }

  /// Sprite bendera angka (0-9, x) untuk garrison count.
  static String flagNum(String c) => 'assets/images/flags/map_flag_$c.png';

  /// Skin capital per level: city_1001 = lv1, city_10010 = lv10, city_10011NN = skin.
  static String capitalSkin(int level) {
    if (level >= 10) {
      final n = (level - 9).clamp(1, 22);
      return 'assets/images/capital/city_10011${n.toString().padLeft(2, '0')}.png';
    }
    return 'assets/images/capital/city_100$level.png';
  }

  /// Sprite bangunan capital, key = buildBase id (2001 palace, 2004 barrack, ...).
  static String building(String buildId) =>
      'assets/images/buildings/build_$buildId.png';

  // --- Sprite tampilan DUNIA (map 80x80) -------------------------------
  // Diambil langsung dari atlas Cocos `tmp/image/city/` — sprite yang
  // dipakai game asli saat capital/plot tampil dari luar (bukan interior).

  /// Capital pemain di map — pagoda biru bertingkat (152x180).
  /// Sumber `city_1001` (skin lv.1). Level 10 memakai `city_10010`,
  /// lv.>10 memakai `city_10011NN` — lihat [capitalSkin].
  static String get mapCapital => 'assets/images/capital/city_1001.png';

  /// Watchtower plot dikuasai — menara kayu A-frame (72x76, `city_2202`).
  static String get mapWatchtower => 'assets/images/capital/city_2202.png';

  /// Fortress di plot — gerbang kayu biru (72x76, `city_2203`).
  static String get mapFortress => 'assets/images/capital/city_2203.png';

  /// Farm / sawmill / quarry di plot — gubuk beratap jerami (72x76, `city_2201`).
  static String get mapFarm => 'assets/images/capital/city_2201.png';

  /// Remains (capital netral) — aula hijau beratap (152x180, `city_10010`).
  static String get mapRemains => 'assets/images/capital/city_10010.png';

  /// Facility id → buildBase id (dari `common/json/buildBase.json`).
  static const Map<String, String> facilityBuildId = {
    'palace': '2001',       // BuildMainInfo
    'barn': '2002',         // BuildGranary
    'warehouse': '2003',    // BuildGranary (kedua)
    'barracks': '2004',     // BuildBarracks
    'embassy': '2005',      // BuildEmbassy
    'market': '2006',       // BuildBazaar
    'union_market': '2014', // BuildUnionMarket
    'smithy': '2008',       // BuildSmithy
    'drill_ground': '2011', // BuildDrillground
    'clinic': '2016',       // BuildHospital
    'hall_of_heroes': '2015', // BuildHerohall
  };

  /// Sprite fasilitas capital; null kalau tidak ada sprite asli.
  static String? facilitySprite(String facilityId) {
    final b = facilityBuildId[facilityId];
    return b == null ? null : building(b);
  }

  /// Ikon season 0-3 (spring/summer/autumn/winter).
  static String season(int i) => 'assets/images/ui/season_$i.png';

  /// Ikon resource dasar dari atlas asli `common/image/` (40x40 px):
  /// cereal=crop, timber=wood, stone, iron, exp_book=exp_scroll,
  /// up_scroll=scroll, fixator=nail.
  static String? resIcon(String resource) {
    const map = {
      'crop': 'assets/images/res/crop.png',
      'wood': 'assets/images/res/wood.png',
      'stone': 'assets/images/res/stone.png',
      'iron': 'assets/images/res/iron.png',
      'exp_scroll': 'assets/images/res/exp_scroll.png',
      'scroll': 'assets/images/res/scroll.png',
      'nail': 'assets/images/res/nail.png',
    };
    return map[resource];
  }

  /// Ikon mata uang / item khusus (`ui/`): ingot, gold, rank_coin, war_token,
  /// voucher, stamina, win_point, shop_ingot_1..6.
  static String currencyIcon(String key) => 'assets/images/ui/$key.png';

  /// Ikon hadiah/roda putar (Lucky Wheel) — `giftbox_101.png`.
  static String get luckyWheelIcon => 'assets/images/ui/giftbox_101.png';

  /// Ikon toko (Shop) — `shop_ingot_1.png`.
  static String get shopIcon => 'assets/images/ui/shop_ingot_1.png';

  /// Ikon peta (Map Overview) — capital skin level 1 sebagai minimap.
  static String get mapIcon => 'assets/images/capital/city_1001.png';

  /// Ikon pasukan/army (All Armies) — ikon pasukan minimal.
  static String get armiesIcon => 'assets/images/plots/land__army_min_icon.png';

  /// Ikon rekrut/gerak (March List) — ikon rekrut naik.
  static String get marchIcon => 'assets/images/ui/up_recruit.png';

  /// Ikon muster/General Muster Terrace — giftbox.
  static String get musterIcon => 'assets/images/ui/giftbox_101.png';

  /// Ikon ranking/peringkat — rank coin.
  static String get rankingIcon => 'assets/images/ui/rank_coin.png';

  /// Ikon reward points (bronze tally) — win point.
  static String get rewardPointsIcon => 'assets/images/ui/win_point.png';

  /// Ikon capital (masuk capital) — city_1001.
  static String get capitalIcon => 'assets/images/capital/city_1001.png';

  /// Ikon hero/portrait untuk rail heroes list.
  static String heroPortraitIcon(int portrayalId) =>
      'assets/images/heroes/portrayal_$portrayalId.png';

  /// Ikon equipment dari atlas asli `tmp/image/equip/equip_<id>`.
  /// Common: 6001–6044. Exclusive: 6101–6124.
  /// Null kalau id di luar jangkauan ekstraksi.
  static String? equipIcon(String equipId) {
    final n = int.tryParse(equipId);
    if (n == null) return null;
    if ((n >= 6001 && n <= 6044) || (n >= 6101 && n <= 6124)) {
      return 'assets/images/equip/equip_$equipId.png';
    }
    return null;
  }

  /// Potret pasukan/monster 64x64 dari bundle `role/<id>` (pawnBase id).
  /// Dipakai untuk token unit di grid tempur dan roster barrack.
  static String unitSprite(String pawnId) =>
      'assets/images/units/unit_$pawnId.png';

  /// Hero portrait (`portrayal_<portrayalId>.png`) — frame statis dari atlas
  /// Cocos, dipakai di kartu hero dan panel Aula Hero.
  static String heroPortrait(int portrayalId) =>
      'assets/images/heroes/portrayal_$portrayalId.png';

  /// Hero avatar bulat — pakai `portrayal_<portrayalId>.png` (ilustrasi penuh
  /// valid) di-crop `BoxFit.cover`. `avatar_pawn_*` hasil ekstrak korup
  /// (bar kuning), jadi tidak dipakai lagi.
  static String heroAvatar(int portrayalId) =>
      'assets/images/heroes/portrayal_$portrayalId.png';

  /// Frame animasi `role_<pawnId>_walk` / `_drill` (Cocos AnimationClip).
  static String unitAnimFrame(String pawnId, String clip, int i) =>
      'assets/images/units/anim/${pawnId}_${clip}_$i.png';

  /// `[frameCount, fps]` untuk (pawnId, clip); null kalau klip tidak ada.
  static List<num>? unitClip(String pawnId, String clip) =>
      unitClips[pawnId]?[clip];

  /// Clip frame counts + fps, extracted from Cocos AnimationClip assets
  /// (`role_<pawnId>_walk` / `_drill`) by `extract_unit_anims.py`.
  static const Map<String, Map<String, List<num>>> unitClips = {
    '3101': {'walk': [4, 8.3, 72, 74], 'drill': [4, 7.7, 100, 74]},
    '3102': {'walk': [4, 8.3, 56, 70], 'drill': [4, 7.7, 100, 66]},
    '3103': {'walk': [4, 8.3, 72, 86], 'drill': [4, 7.7, 104, 86]},
    '3104': {'walk': [4, 8.3, 56, 74], 'drill': [5, 7.2, 96, 74]},
    '3105': {'walk': [4, 8.3, 76, 70], 'drill': [6, 7.4, 150, 130]},
    '3106': {'walk': [4, 8.8, 84, 74], 'drill': [4, 8.8, 88, 74]},
    '3201': {'walk': [4, 7.7, 70, 74], 'drill': [4, 7.7, 86, 74]},
    '3202': {'walk': [4, 7.5, 76, 74], 'drill': [4, 7.7, 76, 74]},
    '3203': {'walk': [4, 7.7, 72, 74], 'drill': [4, 7.7, 88, 74]},
    '3204': {'walk': [4, 7.7, 72, 74], 'drill': [5, 7.2, 84, 76]},
    '3205': {'walk': [4, 7.7, 68, 72], 'drill': [6, 7.0, 96, 74]},
    '3206': {'walk': [4, 7.7, 80, 74], 'drill': [4, 7.7, 92, 78]},
    '3301': {'walk': [4, 8.8, 72, 80], 'drill': [4, 7.7, 78, 80]},
    '3302': {'walk': [4, 8.8, 78, 70], 'drill': [2, 11.6, 78, 70]},
    '3303': {'walk': [4, 8.8, 64, 74], 'drill': [4, 7.7, 76, 72]},
    '3304': {'walk': [4, 8.8, 60, 70], 'drill': [4, 7.7, 72, 68]},
    '3305': {'walk': [4, 8.8, 64, 74], 'drill': [7, 6.8, 90, 78]},
    '3306': {'walk': [4, 8.8, 64, 78], 'drill': [5, 7.2, 76, 76]},
    '3401': {'walk': [4, 10.7, 64, 96], 'drill': [4, 7.7, 84, 94]},
    '3402': {'walk': [4, 10.7, 56, 96], 'drill': [4, 7.7, 100, 94]},
    '3403': {'walk': [4, 10.7, 64, 96], 'drill': [4, 7.7, 100, 94]},
    '3404': {'walk': [4, 9.9, 64, 96], 'drill': [4, 7.7, 108, 96]},
    '3405': {'walk': [4, 10.7, 56, 96], 'drill': [5, 7.2, 74, 92]},
    '3406': {'walk': [4, 10.7, 60, 96], 'drill': [6, 7.0, 110, 92]},
    '3501': {'walk': [2, 7.2, 80, 76], 'drill': [8, 6.6, 84, 76]},
    '3502': {'walk': [2, 7.2, 64, 68], 'drill': [8, 6.6, 74, 68]},
    '4201': {'walk': [4, 6.2, 68, 70]},
    '4202': {'walk': [4, 6.2, 78, 68]},
  };

  static Future<void> preloadUiSounds() async {
    await FlameAudio.audioCache.loadAll([
      'sounds/ui/sound_ui_001.mp3',
      'sounds/ui/sound_ui_002.mp3',
      'sounds/ui/sound_ui_004.mp3',
      'sounds/ui/sound_ui_005.mp3',
      'sounds/ui/sound_ui_009.mp3',
      'sounds/ui/sound_ui_010.mp3',
      'sounds/ui/sound_ui_013.mp3',
      'sounds/ui/sound_ui_014.mp3',
      'sounds/ui/sound_ui_015.mp3',
      'sounds/ui/sound_ui_016.mp3',
      'sounds/ui/sound_ui_020.mp3',
      'sounds/ui/sound_ui_021.mp3',
      'sounds/ui/sound_ui_023.mp3',
    ]);
  }

  static Future<void> preloadBgm() async {
    await FlameAudio.audioCache.loadAll([
      'sounds/bgm/sound_bgm_001.mp3',
      'sounds/bgm/sound_bgm_002.mp3',
    ]);
  }

  /// Click button / panel open.
  static void playClick() => FlameAudio.play('sounds/ui/sound_ui_001.mp3', volume: 0.6);

  /// Modal open (building info, hero detail).
  static void playModalOpen() => FlameAudio.play('sounds/ui/sound_ui_002.mp3', volume: 0.5);

  /// Success notif (upgrade complete, conquest win).
  static void playSuccess() => FlameAudio.play('sounds/ui/sound_ui_009.mp3', volume: 0.7);

  /// Error / invalid action.
  static void playError() => FlameAudio.play('sounds/ui/sound_ui_013.mp3', volume: 0.5);

  /// BGM loop (main game).
  static void playBgm({double volume = 0.3}) {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('sounds/bgm/sound_bgm_001.mp3', volume: volume);
  }

  static void stopBgm() => FlameAudio.bgm.stop();

  /// Unit sound per soldier type (001-152, acak pilih).
  /// Contoh: Longspearman attack → sound_001.mp3 - sound_010.mp3.
  /// TODO: map exact troop → sound range dari OCR + testing.
  static void playUnitSound(int idx) {
    final n = (idx % 152) + 1;
    FlameAudio.play('sounds/unit/sound_${n.toString().padLeft(3, '0')}.mp3', volume: 0.4);
  }
}

class _ChromeMeta {
  final String fileName;
  final Rect capInsets;
  const _ChromeMeta(this.fileName, this.capInsets);
}