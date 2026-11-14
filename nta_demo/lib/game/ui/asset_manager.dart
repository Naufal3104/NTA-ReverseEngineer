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
class NtaAssets {
  NtaAssets._();

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

  /// Potret pasukan/monster 64x64 dari bundle `role/<id>` (pawnBase id).
  /// Dipakai untuk token unit di grid tempur dan roster barrack.
  static String unitSprite(String pawnId) =>
      'assets/images/units/unit_$pawnId.png';

  /// Hero portrait (`portrayal_<portrayalId>.png`) — frame statis dari atlas
  /// Cocos, dipakai di kartu hero dan panel Aula Hero.
  static String heroPortrait(int portrayalId) =>
      'assets/images/heroes/portrayal_$portrayalId.png';

  /// Hero avatar di atas prajurit (`avatar_pawn_<portrayalId>_01.png`).
  static String heroAvatar(int portrayalId) =>
      'assets/images/heroes/avatar_pawn_${portrayalId}_01.png';

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
