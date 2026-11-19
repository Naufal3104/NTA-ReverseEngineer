// ignore_for_file: constant_identifier_names
import 'dart:math' as math;
// Game Configuration Data - Ninety Thousand Acres (???)
// Reconstructed from official documentation, OCR of Battle Guide & Plot Recap

class GameData {
  static const int MAP_WIDTH = 80;
  static const int MAP_HEIGHT = 80;
  static const int TILE_SIZE = 64;

  // Real-time ticking configurations
  // 60 seconds of real-time = 1 game day (for demo/simulation speed)
  static const int SECONDS_PER_DAY = 60;
  static const int DAYS_PER_SEASON = 3;

  // Resource types
  // Basics (producible per hour): crop, wood, stone.
  static const String RES_CROP = 'crop';
  static const String RES_WOOD = 'wood';
  static const String RES_STONE = 'stone';
  // Specials (chest-only, no production): iron, exp_scroll, scroll, nail.
  static const String RES_IRON = 'iron';
  static const String RES_EXP_SCROLL = 'exp_scroll';
  static const String RES_SCROLL = 'scroll';
  static const String RES_NAIL = 'nail';

  // Capital internal building slots & constructs (9 authentic Citadel facilities)
  // NOTE: Capital is NOT buildable; Wall & Watchtower are NOT buildable.
  // Sawmill, Farm, and Quarry are Ground Buildings built ONLY on conquered world plots.
  // New 17x17 layout: Court at rows 5-11, cols 5-11; CITY WALL = court perimeter
  // (rows 5/11, cols 5/11, white-bordered brown). Court interior rows 6-10, cols 6-10.
  // Palace: 3x1 at row 6, cols 7-9 (top interior, yellow line in ref).
  // Barracks: 1x1 at (10, 8) south interior (red dot in ref, on south road).
  // Other facilities: 1x1 tiles inside 5x5 interior, off the cross roads.
  // Build time in seconds + construction prerequisite (mirrors original
  // "Construction Requirement" row, e.g. Iron Prison -> Hall of Heroes Lv.5).
  // 'requires': {'id': <building id>, 'level': <min level>} or null = no requirement.
  static const List<Map<String, dynamic>> CAPITAL_BUILDINGS = [
    {
      'id': 'palace',
      'name': 'Imperial Palace',
      'cost': {'wood': 300, 'stone': 300, 'crop': 150},
      'buildTime': 600,
      'requires': null,
      'hp': 3000,
      'desc': 'Core seat of the Capital (Lv 1-20). Governs army teams & realm tax.',
      'icon': '👑',
      'r': 6,
      'c': 7,
      'w': 3,
      'h': 1,
    },
    {
      'id': 'barracks',
      'name': 'Barracks',
      'cost': {'wood': 180, 'stone': 120, 'crop': 80},
      'buildTime': 360,
      'requires': null,
      'hp': 1200,
      'desc': 'Recruits Spearmen, Bowmen, Cavalry, and Shieldmen.',
      'icon': '⚔️',
      'r': 10,
      'c': 8,
      'w': 1,
      'h': 1,
    },
    {
      'id': 'smithy',
      'name': 'Smithy',
      'cost': {'stone': 200, 'wood': 140, 'iron': 60},
      'buildTime': 420,
      'requires': {'id': 'barracks', 'level': 1},
      'hp': 1000,
      'desc': 'Forges Iron/Rattan Shields, Weapons, and Armor.',
      'icon': '🔨',
      'r': 7,
      'c': 6,
      'w': 1,
      'h': 1,
    },
    {
      'id': 'hall_of_heroes',
      'name': 'Hall of Heroes',
      'cost': {'wood': 250, 'stone': 200, 'crop': 100},
      'buildTime': 480,
      'requires': {'id': 'palace', 'level': 1},
      'hp': 1500,
      'desc': 'Worship legendary commanders to permanently bind them.',
      'icon': '🏛️',
      'r': 7,
      'c': 7,
      'w': 1,
      'h': 1,
    },
    {
      'id': 'drill_ground',
      'name': 'Drill Ground',
      'cost': {'wood': 160, 'stone': 120, 'crop': 100},
      'buildTime': 300,
      'requires': {'id': 'barracks', 'level': 1},
      'hp': 1100,
      'desc': 'Drills troops to elevate soldier attributes and battle morale.',
      'icon': '🎯',
      'r': 7,
      'c': 9,
      'w': 1,
      'h': 1,
    },
    {
      'id': 'clinic',
      'name': 'Clinic',
      'cost': {'wood': 140, 'crop': 100, 'stone': 50},
      'buildTime': 300,
      'requires': {'id': 'barracks', 'level': 1},
      'hp': 900,
      'desc': 'Heals wounded soldiers returning from plot assaults.',
      'icon': '🏥',
      'r': 7,
      'c': 10,
      'w': 1,
      'h': 1,
    },
    {
      'id': 'market',
      'name': 'Market',
      'cost': {'wood': 150, 'stone': 150, 'crop': 80},
      'buildTime': 360,
      'requires': {'id': 'palace', 'level': 1},
      'hp': 950,
      'desc': 'Trade resources with merchants and exchange surplus goods.',
      'icon': '🏪',
      'r': 9,
      'c': 6,
      'w': 1,
      'h': 1,
    },
    {
      'id': 'barn',
      'name': 'Barn',
      'cost': {'wood': 120, 'stone': 80},
      'buildTime': 240,
      'requires': null,
      'hp': 850,
      'desc': 'A place to store crops. A higher level grants more capacity.',
      'icon': '🏠',
      'r': 9,
      'c': 7,
      'w': 1,
      'h': 1,
    },
    {
      'id': 'warehouse',
      'name': 'Warehouse',
      'cost': {'wood': 140, 'stone': 120},
      'buildTime': 240,
      'requires': {'id': 'palace', 'level': 1},
      'hp': 900,
      'desc': 'Storage for lumber, stone, and iron (+3,000 Cap/lvl).',
      'icon': '📦',
      'r': 9,
      'c': 9,
      'w': 1,
      'h': 1,
    },
    {
      'id': 'embassy',
      'name': 'Embassy',
      'cost': {'wood': 155, 'stone': 155},
      'buildTime': 180,
      'requires': {'id': 'palace', 'level': 3},
      'hp': 950,
      'desc': 'Join a union at Lv.1, create one as leader at Lv.3. Member slots scale with leader embassy level.',
      'icon': '🤝',
      'r': 10,
      'c': 6,
      'w': 1,
      'h': 1,
    },
    {
      'id': 'union_market',
      'name': 'Union Market',
      'cost': {'wood': 165, 'stone': 135},
      'buildTime': 350,
      'requires': [
        {'id': 'barn', 'level': 3},
        {'id': 'warehouse', 'level': 3},
      ],
      'hp': 950,
      'desc': 'Trade channel for union members. +1 merchant per level; 1000 basics or 10 specials per shipment.',
      'icon': '🏷️',
      'r': 10,
      'c': 10,
      'w': 1,
      'h': 1,
    },
  ];

  /// Embassy member slots at a given embassy level (buildAttr effect 6).
  static int embassyMemberSlots(int level) =>
      (buildingEffects('embassy', level)[6] ?? 2).toInt();

  /// Union Market merchants at a given market level (buildAttr effect 7).
  static int unionMarketMerchants(int level) =>
      (buildingEffects('union_market', level)[7] ?? 1).toInt();

  /// Per-merchant payload caps for the Union Market trade channel.
  static const int MERCHANT_BASIC_CAP = 1000;
  static const int MERCHANT_SPECIAL_CAP = 10;

  // Per-level stats (Lv.1-20). Effects are extrapolated from OCR deltas;
  // cost/time are overwritten with the real buildAttr ladder.
  static Map<String, dynamic> levelStats(String id, int level) {
    final stats = _levelStatsBase(id, level);
    stats['cost'] = upgradeCost(id, level);
    stats['time'] = upgradeTime(id, level);
    return stats;
  }

  static Map<String, dynamic> _levelStatsBase(String id, int level) {
    final l = level.clamp(1, 20);
    final eff = buildingEffects(id, l);
    switch (id) {
      case 'palace':
        return {
          'armyCap': eff[11] ?? 1,
          'armyCapacity': 9,
          'territory': 11 + l * 4,
          'note': l >= 15 ? 'Policy slot unlocked' : 'New policy at Lv.15',
        };
      case 'barracks':
        return {
          'recruitSpd': eff[5] ?? 0,
          'soldierCap': l >= 20 ? 6 : l >= 15 ? 5 : l >= 10 ? 4 : l >= 5 ? 3 : 2,
          'note': l >= 12 ? 'New soldier unlocked' : 'New soldier at Lv.12',
        };
      case 'smithy':
        return {
          'craftSpd': eff[10] ?? 0,
          'note': l >= 10 ? 'Exclusive + Smelt unlocked' : 'Exclusive at Lv.10',
        };
      case 'hall_of_heroes':
        return {'portraits': 1 + ((l - 1) ~/ 9)};
      case 'frontier_garrison':
        return {'durability': 35 + l * 5, 'atk': 10 + l * 2};
      case 'drill_ground':
        return {'marchSpd': eff[13] ?? 0};
      case 'clinic':
        return {
          'healSpd': eff[37] ?? 0,
          'minorChance': l == 1 ? 40 : 50,
          'severeChance': l == 1 ? 0 : 30,
          'queue': 6,
        };
      case 'market':
      case 'union_market':
        return {'merchants': eff[7] ?? l};
      case 'embassy':
        return {
          'memberSlots': eff[6] ?? 2,
          'note': l >= 3 ? 'Can create union' : 'Create union at Lv.3',
        };
      case 'barn':
        return {'cropCap': 1000 + (eff[3] ?? 0)};
      case 'warehouse':
        return {'woodCap': 1000 + (eff[4] ?? 0), 'stoneCap': 1000 + (eff[4] ?? 0)};
      case 'city_wall':
        return {'hpBonus': eff[9] ?? 0};
      default:
        return {};
    }
  }

  /// Real upgrade cost for reaching [nextLevel] from `nextLevel - 1`.
  /// buildAttr row `lv = N` holds the cost that produces level N+1, so row 0
  /// is the initial build cost (0 -> 1).
  static Map<String, int> upgradeCost(String id, int nextLevel) {
    final l = nextLevel.clamp(1, 20);
    final baseId = BUILD_BASE_IDS[id];
    final rows = baseId == null ? null : BUILD_LADDER[baseId];
    if (rows != null && l - 1 < rows.length) {
      final cost = rows[l - 1]['cost'] as Map<String, int>;
      if (cost.isNotEmpty) return Map<String, int>.from(cost);
    }
    const normalR = 1.3239;
    const palaceR = 1.2896;
    final isPalace = id == 'palace';
    final base = isPalace ? 144.0 : 64.0;
    final r = isPalace ? palaceR : normalR;
    final v = (base * math.pow(r, (l - 2).clamp(0, 18))).round();
    return {'wood': v, 'stone': v};
  }

  /// Real build time in seconds for reaching [nextLevel] from `nextLevel - 1`.
  static int upgradeTime(String id, int nextLevel) {
    final l = nextLevel.clamp(1, 20);
    final baseId = BUILD_BASE_IDS[id];
    final rows = baseId == null ? null : BUILD_LADDER[baseId];
    if (rows == null || l - 1 >= rows.length) return 0;
    return rows[l - 1]['time'] as int;
  }

  /// Real per-level effects from buildAttr (effect id -> value).
  /// buildAttr row `lv = N` lists the stats *at* level N, while its cost
  /// produces level N+1 — hence `rows[level]` here vs `rows[level-1]` above.
  /// Known ids: 3 barn crop cap, 4 warehouse cap, 5 barrack recruit-time
  /// reduction %, 6 embassy member slots, 7 market merchants, 9 city wall HP,
  /// 10 smithy craft-time reduction %, 11 palace army cap, 13 drill ground
  /// train-time reduction %, 35/36 ancient, 37 clinic heal %, 63 palace
  /// secondary, 64 prison.
  static Map<int, num> buildingEffects(String id, int level) {
    final l = level.clamp(1, 20);
    final baseId = BUILD_BASE_IDS[id];
    final rows = baseId == null ? null : BUILD_LADDER[baseId];
    if (rows == null || l >= rows.length) return const {};
    return (rows[l]['effects'] as Map<int, num>?) ?? const {};
  }

  /// Real recruit (train) cost per soldier from pawnBase.drill_cost.
  /// In-game this is crop only. Falls back to the doc-derived TROOPS cost.
  static Map<String, int> recruitCost(String troopId) {
    final pawnId = _troopPawnIds[troopId];
    final base = pawnId == null ? null : PAWN_BASE[pawnId];
    final cost = base?['drillCost'] as Map<String, int>?;
    if (cost != null && cost.isNotEmpty) return Map<String, int>.from(cost);
    final troop = TROOPS.firstWhere((t) => t['id'] == troopId, orElse: () => {});
    final costMap = troop['cost'] as Map<String, dynamic>? ?? const {};
    return {
      for (final e in costMap.entries) e.key: e.value as int,
    };
  }

  /// Real recruit duration in seconds from pawnBase.drill_time.
  static int recruitTime(String troopId) {
    final pawnId = _troopPawnIds[troopId];
    final base = pawnId == null ? null : PAWN_BASE[pawnId];
    return (base?['drillTime'] as int?) ?? 0;
  }

  /// Barracks troop id -> pawnBase id (mirrors BattleEngine.troopCombatIds).
  static const Map<String, String> _troopPawnIds = {
    'longspearman': '3101',
    'lancer': '3102',
    'dagger_axe': '3103',
    'modao': '3104',
    'long_swordsman': '3105',
    'twin_spearman': '3106',
    'saber_shield': '3201',
    'heavy_shield': '3202',
    'spear_shield': '3203',
    'hammer_shield': '3204',
    'sword_shield': '3205',
    'axe_shield': '3206',
    'longbowman': '3301',
    'crossbowman': '3302',
    'toxibowman': '3303',
    'hunter': '3304',
    'improved_crossbowman': '3305',
    'fire_bowman': '3306',
    'sword_cavalry': '3401',
    'spear_cavalry': '3402',
    'broadsword_cavalry': '3403',
    'heavy_cavalry': '3404',
    'bow_cavalry': '3405',
    'axe_cavalry': '3406',
    'catapult': '3501',
    'trebuchet': '3502',
  };

  // Backwards compatibility alias
  static const List<Map<String, dynamic>> BUILDINGS = CAPITAL_BUILDINGS;

  // ---- LAND (game_json/land.json) ----
  /// Hourly output per conquerable plot. Source: land.json `cereal`/`timber`/
  /// `stone`. Lv.1 is the shared Wasteland row (1 of every resource); Lv.2-5
  /// are the dedicated crop/wood/stone plots. `type` 3/4/5 = crop/wood/stone.
  static const List<Map<String, dynamic>> LAND_PLOTS = [
    {'type': 3, 'lv': 1, 'crop': 1, 'wood': 1, 'stone': 1},
    {'type': 3, 'lv': 2, 'crop': 4, 'wood': 0, 'stone': 0},
    {'type': 3, 'lv': 3, 'crop': 7, 'wood': 0, 'stone': 0},
    {'type': 3, 'lv': 4, 'crop': 10, 'wood': 0, 'stone': 0},
    {'type': 3, 'lv': 5, 'crop': 14, 'wood': 0, 'stone': 0},
    {'type': 4, 'lv': 1, 'crop': 1, 'wood': 1, 'stone': 1},
    {'type': 4, 'lv': 2, 'crop': 0, 'wood': 4, 'stone': 0},
    {'type': 4, 'lv': 3, 'crop': 0, 'wood': 7, 'stone': 0},
    {'type': 4, 'lv': 4, 'crop': 0, 'wood': 10, 'stone': 0},
    {'type': 4, 'lv': 5, 'crop': 0, 'wood': 14, 'stone': 0},
    {'type': 5, 'lv': 1, 'crop': 1, 'wood': 1, 'stone': 1},
    {'type': 5, 'lv': 2, 'crop': 0, 'wood': 0, 'stone': 4},
    {'type': 5, 'lv': 3, 'crop': 0, 'wood': 0, 'stone': 7},
    {'type': 5, 'lv': 4, 'crop': 0, 'wood': 0, 'stone': 10},
    {'type': 5, 'lv': 5, 'crop': 0, 'wood': 0, 'stone': 14},
  ];

  /// Hourly output of a plot. `lv` 1 ignores `type` (Wasteland yields all).
  static Map<String, double> landYield(int type, int lv) {
    final t = lv == 1 ? 3 : type;
    final row = LAND_PLOTS.firstWhere(
      (r) => r['type'] == t && r['lv'] == lv,
      orElse: () => LAND_PLOTS.first,
    );
    return {
      'crop': (row['crop'] as int).toDouble(),
      'wood': (row['wood'] as int).toDouble(),
      'stone': (row['stone'] as int).toDouble(),
    };
  }

  /// land.json ids used for conquerable plots (id -> type). Lv.1 Wasteland
  /// has one shared id per type; Lv.2-5 crop/wood/stone are 302-305 / 402-405
  /// / 502-505. Used to render the real `ui.land_<id>` display name.
  static int landIdFor(int type, int lv) {
    if (lv <= 1) return 301;
    return type * 100 + lv; // 3->302..305, 4->402..405, 5->502..505
  }

  // ---- LAND ATTR (game_json/landAttr.json) ----
  /// Difficulty band per uiLv (landAttr.uiLv 1001-6002). Returns (name, sub)
  /// matching ui.json `land_difficulty_<n>`: Easy/Entry/Common/Advanced/
  /// Hard/Hell, with the digit after the thousands/thousands-block as sub.
  /// 1001-1012 Easy 1-3 → Common 1-4 (sub cycles 1-4 within each band).
  static const List<List<String>> LAND_DIFFICULTY_BANDS = [
    ['Easy', '1001', '1012'],
    ['Entry', '2001', '2012'],
    ['Common', '3001', '3012'],
    ['Advanced', '4001', '4015'],
    ['Hard', '5001', '5015'],
    ['Hell', '6001', '6002'],
  ];

  /// [landAttr] id (1001-5016) -> garrison + loot metadata. `hp` is the flag
  /// HP; `uiLv` selects the difficulty row from `LAND_DIFFICULTY_BANDS`;
  /// `stamina` is the march cost; `tonden` the Grain Garrison time in minutes;
  /// `treasures` is "wood,silver,gold" chest weights; `count` is the chest
  /// count range "lo,hi"; `armys3/4/5` are garrison strings ("pawnId,row_col,
  /// level" joined by `|`) for land type 3/4/5 (crop/wood/stone). A land type
  /// with no dedicated string reuses `armys3`.
  static const Map<int, Map<String, dynamic>> LAND_ATTR = {
    1001: {'hp': 1, 'uiLv': 1001, 'stamina': 1, 'tonden': 30, 'treasures': '50,0,0', 'count': '1,1', 'armys3': '4101,5_4,1', 'armys4': '', 'armys5': ''},
    1002: {'hp': 2, 'uiLv': 1002, 'stamina': 1, 'tonden': 30, 'treasures': '50,0,0', 'count': '1,2', 'armys3': '4101,4_4,1|4101,6_6,1', 'armys4': '', 'armys5': ''},
    1003: {'hp': 3, 'uiLv': 1003, 'stamina': 1, 'tonden': 30, 'treasures': '50,0,0', 'count': '2,2', 'armys3': '4101,4_6,1|4102,5_4,1|4101,6_6,1', 'armys4': '', 'armys5': ''},
    1004: {'hp': 3, 'uiLv': 2001, 'stamina': 1, 'tonden': 90, 'treasures': '80,20,0', 'count': '2,3', 'armys3': '4108,4_4,2|4108,6_6,2', 'armys4': '', 'armys5': ''},
    1005: {'hp': 3, 'uiLv': 2002, 'stamina': 1, 'tonden': 90, 'treasures': '78,22,0', 'count': '2,3', 'armys3': '4108,4_6,2|4102,5_4,2|4108,6_6,2', 'armys4': '', 'armys5': ''},
    1006: {'hp': 3, 'uiLv': 2003, 'stamina': 1, 'tonden': 90, 'treasures': '75,25,0', 'count': '2,3', 'armys3': '4108,4_4,2|4108,6_4,2|4102,6_6,2|4102,4_6,2', 'armys4': '', 'armys5': ''},
    1007: {'hp': 3, 'uiLv': 3001, 'stamina': 1, 'tonden': 180, 'treasures': '70,30,0', 'count': '2,4', 'armys3': '4107,4_4,3|4107,6_4,3|4107,6_6,3|4107,4_6,3', 'armys4': '4105,4_4,3|4105,6_4,3|4105,6_6,3|4105,4_6,3', 'armys5': '4106,4_4,3|4106,6_4,3|4106,6_6,3|4106,4_6,3'},
    1008: {'hp': 3, 'uiLv': 3001, 'stamina': 1, 'tonden': 180, 'treasures': '70,30,0', 'count': '2,4', 'armys3': '4107,4_4,3|4107,6_4,3|4107,6_6,3|4107,4_6,3', 'armys4': '4105,4_4,3|4105,6_4,3|4105,6_6,3|4105,4_6,3', 'armys5': '4106,4_4,3|4106,6_4,3|4106,6_6,3|4106,4_6,3'},
    1009: {'hp': 3, 'uiLv': 3001, 'stamina': 1, 'tonden': 180, 'treasures': '70,30,0', 'count': '2,4', 'armys3': '4107,4_4,3|4107,6_4,3|4107,6_6,3|4107,4_6,3', 'armys4': '4105,4_4,3|4105,6_4,3|4105,6_6,3|4105,4_6,3', 'armys5': '4106,4_4,3|4106,6_4,3|4106,6_6,3|4106,4_6,3'},
    1010: {'hp': 3, 'uiLv': 3001, 'stamina': 1, 'tonden': 180, 'treasures': '70,30,0', 'count': '2,4', 'armys3': '4107,4_4,3|4107,6_4,3|4107,6_6,3|4107,4_6,3', 'armys4': '4105,4_4,3|4105,6_4,3|4105,6_6,3|4105,4_6,3', 'armys5': '4106,4_4,3|4106,6_4,3|4106,6_6,3|4106,4_6,3'},
    1011: {'hp': 3, 'uiLv': 3001, 'stamina': 1, 'tonden': 180, 'treasures': '70,30,0', 'count': '2,4', 'armys3': '4107,4_4,3|4107,6_4,3|4107,6_6,3|4107,4_6,3', 'armys4': '4105,4_4,3|4105,6_4,3|4105,6_6,3|4105,4_6,3', 'armys5': '4106,4_4,3|4106,6_4,3|4106,6_6,3|4106,4_6,3'},
    1012: {'hp': 3, 'uiLv': 3003, 'stamina': 1, 'tonden': 180, 'treasures': '65,35,0', 'count': '2,4', 'armys3': '4107,4_4,4|4107,6_4,4|4107,6_6,4|4107,4_6,4', 'armys4': '4105,4_4,4|4105,6_4,4|4105,6_6,4|4105,4_6,4', 'armys5': '4106,4_4,4|4106,6_4,4|4106,6_6,4|4106,4_6,4'},
    2001: {'hp': 3, 'uiLv': 1003, 'stamina': 1, 'tonden': 240, 'treasures': '70,30,0', 'count': '3,4', 'armys3': '4117,4_6,1|4117,5_4,1|4117,6_6,1', 'armys4': '4116,4_6,1|4116,5_4,1|4116,6_6,1', 'armys5': '4118,4_6,1|4118,5_4,1|4118,6_6,1'},
    2002: {'hp': 3, 'uiLv': 1003, 'stamina': 1, 'tonden': 240, 'treasures': '70,30,0', 'count': '3,4', 'armys3': '4117,4_6,1|4117,5_4,1|4117,6_6,1', 'armys4': '4116,4_6,1|4116,5_4,1|4116,6_6,1', 'armys5': '4118,4_6,1|4118,5_4,1|4118,6_6,1'},
    2003: {'hp': 4, 'uiLv': 2003, 'stamina': 1, 'tonden': 240, 'treasures': '65,35,0', 'count': '3,4', 'armys3': '4117,4_4,2|4117,6_4,2|4117,6_6,2|4117,4_6,2', 'armys4': '4116,4_4,2|4116,6_4,2|4116,6_6,2|4116,4_6,2', 'armys5': '4118,4_4,2|4118,6_4,2|4118,6_6,2|4118,4_6,2'},
    2004: {'hp': 4, 'uiLv': 2003, 'stamina': 1, 'tonden': 240, 'treasures': '65,35,0', 'count': '3,4', 'armys3': '4117,4_4,2|4117,6_4,2|4117,6_6,2|4117,4_6,2', 'armys4': '4116,4_4,2|4116,6_4,2|4116,6_6,2|4116,4_6,2', 'armys5': '4118,4_4,2|4118,6_4,2|4118,6_6,2|4118,4_6,2'},
    2005: {'hp': 4, 'uiLv': 3002, 'stamina': 1, 'tonden': 300, 'treasures': '60,40,0', 'count': '3,5', 'armys3': '4110,4_4,3|4110,6_4,3|4110,6_6,3|4110,4_6,3', 'armys4': '4103,4_4,3|4103,6_4,3|4103,6_6,3|4103,4_6,3', 'armys5': '4104,4_4,3|4104,6_4,3|4104,6_6,3|4104,4_6,3'},
    2006: {'hp': 4, 'uiLv': 3002, 'stamina': 1, 'tonden': 300, 'treasures': '60,40,0', 'count': '3,5', 'armys3': '4110,4_4,3|4110,6_4,3|4110,6_6,3|4110,4_6,3', 'armys4': '4103,4_4,3|4103,6_4,3|4103,6_6,3|4103,4_6,3', 'armys5': '4104,4_4,3|4104,6_4,3|4104,6_6,3|4104,4_6,3'},
    2007: {'hp': 4, 'uiLv': 3003, 'stamina': 1, 'tonden': 300, 'treasures': '55,45,0', 'count': '3,5', 'armys3': '4110,4_4,3|4110,4_6,3|4110,6_6,3|4110,6_4,3|4109,5_4,3|4109,5_6,3', 'armys4': '4103,4_4,3|4103,4_6,3|4103,6_6,3|4103,6_4,3|4109,5_4,3|4109,5_6,3', 'armys5': '4104,4_4,3|4104,4_6,3|4104,6_6,3|4104,6_4,3|4109,5_4,3|4109,5_6,3'},
    2008: {'hp': 4, 'uiLv': 3003, 'stamina': 1, 'tonden': 300, 'treasures': '55,45,0', 'count': '3,5', 'armys3': '4110,4_4,3|4110,4_6,3|4110,6_6,3|4110,6_4,3|4109,5_4,3|4109,5_6,3', 'armys4': '4103,4_4,3|4103,4_6,3|4103,6_6,3|4103,6_4,3|4109,5_4,3|4109,5_6,3', 'armys5': '4104,4_4,3|4104,4_6,3|4104,6_6,3|4104,6_4,3|4109,5_4,3|4109,5_6,3'},
    2009: {'hp': 4, 'uiLv': 3004, 'stamina': 1, 'tonden': 300, 'treasures': '50,50,0', 'count': '3,5', 'armys3': '4110,4_4,3|4110,4_6,3|4110,6_6,3|4110,6_4,3|4109,5_4,3|4109,5_6,3', 'armys4': '4103,4_4,4|4103,4_6,3|4103,6_6,4|4103,6_4,3|4109,5_4,3|4109,5_6,3', 'armys5': '4104,4_4,4|4104,4_6,3|4104,6_6,4|4104,6_4,3|4109,5_4,3|4109,5_6,3'},
    2010: {'hp': 4, 'uiLv': 3004, 'stamina': 1, 'tonden': 300, 'treasures': '50,50,0', 'count': '3,5', 'armys3': '4110,4_4,4|4110,4_6,4|4110,6_6,4|4110,6_4,4|4109,5_4,4|4109,5_6,4', 'armys4': '4103,4_4,4|4103,4_6,3|4103,6_6,4|4103,6_4,3|4109,5_4,3|4109,5_6,3', 'armys5': '4104,4_4,4|4104,4_6,3|4104,6_6,4|4104,6_4,3|4109,5_4,3|4109,5_6,3'},
    2011: {'hp': 4, 'uiLv': 3004, 'stamina': 1, 'tonden': 300, 'treasures': '50,50,0', 'count': '3,5', 'armys3': '4110,4_4,4|4110,4_6,4|4110,6_6,4|4110,6_4,4|4109,5_4,4|4109,5_6,4', 'armys4': '4103,4_4,4|4103,4_6,3|4103,6_6,4|4103,6_4,3|4109,5_4,3|4109,5_6,3', 'armys5': '4104,4_4,4|4104,4_6,3|4104,6_6,4|4104,6_4,3|4109,5_4,3|4109,5_6,3'},
    2012: {'hp': 4, 'uiLv': 3005, 'stamina': 1, 'tonden': 300, 'treasures': '45,55,0', 'count': '3,5', 'armys3': '4110,4_4,4|4110,4_6,4|4110,6_6,4|4110,6_4,4|4109,5_4,4|4109,5_6,4', 'armys4': '4103,4_4,4|4103,4_6,4|4103,6_6,4|4103,6_4,4|4109,5_4,4|4109,5_6,4', 'armys5': '4104,4_4,4|4104,4_6,4|4104,6_6,4|4104,6_4,4|4109,5_4,4|4109,5_6,4'},
    3001: {'hp': 6, 'uiLv': 4001, 'stamina': 1, 'tonden': 400, 'treasures': '20,80,0', 'count': '4,7', 'armys3': '4111,4_4,5|4111,6_4,5|4111,6_6,5|4111,4_6,5', 'armys4': '4112,4_4,5|4112,6_4,5|4112,6_6,5|4112,4_6,5', 'armys5': '4119,4_4,5|4119,6_4,5|4119,6_6,5|4119,4_6,5'},
    3002: {'hp': 6, 'uiLv': 4001, 'stamina': 1, 'tonden': 400, 'treasures': '20,80,0', 'count': '4,7', 'armys3': '4111,4_4,5|4111,6_4,5|4111,6_6,5|4111,4_6,5', 'armys4': '4112,4_4,5|4112,6_4,5|4112,6_6,5|4112,4_6,5', 'armys5': '4119,4_4,5|4119,6_4,5|4119,6_6,5|4119,4_6,5'},
    3003: {'hp': 6, 'uiLv': 4001, 'stamina': 1, 'tonden': 400, 'treasures': '20,80,0', 'count': '4,7', 'armys3': '4111,4_4,5|4111,6_4,5|4111,6_6,5|4111,4_6,5', 'armys4': '4112,4_4,5|4112,6_4,5|4112,6_6,5|4112,4_6,5', 'armys5': '4119,4_4,5|4119,6_4,5|4119,6_6,5|4119,4_6,5'},
    3004: {'hp': 6, 'uiLv': 4001, 'stamina': 1, 'tonden': 400, 'treasures': '20,80,0', 'count': '4,7', 'armys3': '4111,4_4,5|4111,6_4,5|4111,6_6,5|4111,4_6,5', 'armys4': '4112,4_4,5|4112,6_4,5|4112,6_6,5|4112,4_6,5', 'armys5': '4119,4_4,5|4119,6_4,5|4119,6_6,5|4119,4_6,5'},
    3005: {'hp': 6, 'uiLv': 4001, 'stamina': 1, 'tonden': 400, 'treasures': '20,80,0', 'count': '4,7', 'armys3': '4111,4_4,5|4111,6_4,5|4111,6_6,5|4111,4_6,5', 'armys4': '4112,4_4,5|4112,6_4,5|4112,6_6,5|4112,4_6,5', 'armys5': '4119,4_4,5|4119,6_4,5|4119,6_6,5|4119,4_6,5'},
    3006: {'hp': 6, 'uiLv': 4001, 'stamina': 1, 'tonden': 400, 'treasures': '20,80,0', 'count': '4,7', 'armys3': '4111,4_4,5|4111,6_4,5|4111,6_6,5|4111,4_6,5', 'armys4': '4112,4_4,5|4112,6_4,5|4112,6_6,5|4112,4_6,5', 'armys5': '4119,4_4,5|4119,6_4,5|4119,6_6,5|4119,4_6,5'},
    3007: {'hp': 6, 'uiLv': 4002, 'stamina': 1, 'tonden': 600, 'treasures': '0,100,0', 'count': '4,7', 'armys3': '4111,5_4,5|4111,6_5,5|4111,5_6,5|4111,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys4': '4112,5_4,5|4112,6_5,5|4112,5_6,5|4112,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys5': '4104,5_4,5|4104,6_5,5|4104,5_6,5|4104,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5'},
    3008: {'hp': 6, 'uiLv': 4002, 'stamina': 1, 'tonden': 600, 'treasures': '0,100,0', 'count': '4,7', 'armys3': '4111,5_4,5|4111,6_5,5|4111,5_6,5|4111,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys4': '4112,5_4,5|4112,6_5,5|4112,5_6,5|4112,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys5': '4104,5_4,5|4104,6_5,5|4104,5_6,5|4104,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5'},
    3009: {'hp': 6, 'uiLv': 4002, 'stamina': 1, 'tonden': 600, 'treasures': '0,100,0', 'count': '4,7', 'armys3': '4111,5_4,5|4111,6_5,5|4111,5_6,5|4111,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys4': '4112,5_4,5|4112,6_5,5|4112,5_6,5|4112,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys5': '4104,5_4,5|4104,6_5,5|4104,5_6,5|4104,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5'},
    3010: {'hp': 6, 'uiLv': 4002, 'stamina': 1, 'tonden': 600, 'treasures': '0,100,0', 'count': '4,7', 'armys3': '4111,5_4,5|4111,6_5,5|4111,5_6,5|4111,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys4': '4112,5_4,5|4112,6_5,5|4112,5_6,5|4112,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys5': '4104,5_4,5|4104,6_5,5|4104,5_6,5|4104,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5'},
    3011: {'hp': 6, 'uiLv': 4002, 'stamina': 1, 'tonden': 600, 'treasures': '0,100,0', 'count': '4,7', 'armys3': '4111,5_4,5|4111,6_5,5|4111,5_6,5|4111,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys4': '4112,5_4,5|4112,6_5,5|4112,5_6,5|4112,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5', 'armys5': '4104,5_4,5|4104,6_5,5|4104,5_6,5|4104,4_5,5|4109,4_4,5|4109,6_4,5|4109,6_6,5|4109,4_6,5'},
    3012: {'hp': -1, 'uiLv': 4003, 'stamina': 1, 'tonden': 900, 'treasures': '0,90,10', 'count': '4,7', 'armys3': '4113,5_5,8', 'armys4': '4114,5_5,8', 'armys5': '4115,5_5,8'},
    4001: {'hp': 8, 'uiLv': 5001, 'stamina': 2, 'tonden': 1200, 'treasures': '0,50,50', 'count': '5,8', 'armys3': '4201,4_4,6|4201,6_4,6|4201,4_6,6|4201,6_6,6|4203,5_4,6|4203,5_6,6|4203,4_5,6|4203,6_5,6', 'armys4': '', 'armys5': ''},
    4002: {'hp': 8, 'uiLv': 5001, 'stamina': 2, 'tonden': 1200, 'treasures': '0,50,50', 'count': '5,8', 'armys3': '4201,4_4,6|4201,6_4,6|4201,4_6,6|4201,6_6,6|4203,5_4,6|4203,5_6,6|4203,4_5,6|4203,6_5,6', 'armys4': '', 'armys5': ''},
    4003: {'hp': 8, 'uiLv': 5001, 'stamina': 2, 'tonden': 1200, 'treasures': '0,50,50', 'count': '5,8', 'armys3': '4201,4_4,6|4201,6_4,6|4201,4_6,6|4201,6_6,6|4203,5_4,6|4203,5_6,6|4203,4_5,6|4203,6_5,6', 'armys4': '', 'armys5': ''},
    4004: {'hp': 8, 'uiLv': 5001, 'stamina': 2, 'tonden': 1200, 'treasures': '0,50,50', 'count': '5,8', 'armys3': '4201,4_4,6|4201,6_4,6|4201,4_6,6|4201,6_6,6|4203,5_4,6|4203,5_6,6|4203,4_5,6|4203,6_5,6', 'armys4': '', 'armys5': ''},
    4005: {'hp': 8, 'uiLv': 5001, 'stamina': 2, 'tonden': 1200, 'treasures': '0,50,50', 'count': '5,8', 'armys3': '4201,4_4,6|4201,6_4,6|4201,4_6,6|4201,6_6,6|4203,5_4,6|4203,5_6,6|4203,4_5,6|4203,6_5,6', 'armys4': '', 'armys5': ''},
    4006: {'hp': 8, 'uiLv': 5001, 'stamina': 2, 'tonden': 1200, 'treasures': '0,50,50', 'count': '5,8', 'armys3': '4201,4_4,6|4201,6_4,6|4201,4_6,6|4201,6_6,6|4203,5_4,6|4203,5_6,6|4203,4_5,6|4203,6_5,6', 'armys4': '', 'armys5': ''},
    4007: {'hp': 8, 'uiLv': 5001, 'stamina': 2, 'tonden': 1200, 'treasures': '0,50,50', 'count': '5,8', 'armys3': '4201,4_4,6|4201,6_4,6|4201,4_6,6|4201,6_6,6|4203,5_4,6|4203,5_6,6|4203,4_5,6|4203,6_5,6', 'armys4': '', 'armys5': ''},
    4008: {'hp': 8, 'uiLv': 5001, 'stamina': 2, 'tonden': 1200, 'treasures': '0,50,50', 'count': '5,8', 'armys3': '4201,4_4,6|4201,6_4,6|4201,4_6,6|4201,6_6,6|4203,5_4,6|4203,5_6,6|4203,4_5,6|4203,6_5,6', 'armys4': '', 'armys5': ''},
    4009: {'hp': 8, 'uiLv': 5002, 'stamina': 2, 'tonden': 1800, 'treasures': '0,30,70', 'count': '5,8', 'armys3': '4205,5_3,6|4205,5_7,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6|4202,3_4,6|4202,7_4,6|4201,3_6,6|4201,7_6,6', 'armys4': '', 'armys5': ''},
    4010: {'hp': 8, 'uiLv': 5002, 'stamina': 2, 'tonden': 1800, 'treasures': '0,30,70', 'count': '5,8', 'armys3': '4205,5_3,6|4205,5_7,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6|4202,3_4,6|4202,7_4,6|4201,3_6,6|4201,7_6,6', 'armys4': '', 'armys5': ''},
    4011: {'hp': 8, 'uiLv': 5002, 'stamina': 2, 'tonden': 1800, 'treasures': '0,30,70', 'count': '5,8', 'armys3': '4205,5_3,6|4205,5_7,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6|4202,3_4,6|4202,7_4,6|4201,3_6,6|4201,7_6,6', 'armys4': '', 'armys5': ''},
    4012: {'hp': 8, 'uiLv': 5002, 'stamina': 2, 'tonden': 1800, 'treasures': '0,30,70', 'count': '5,8', 'armys3': '4205,5_3,6|4205,5_7,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6|4202,3_4,6|4202,7_4,6|4201,3_6,6|4201,7_6,6', 'armys4': '', 'armys5': ''},
    4013: {'hp': 8, 'uiLv': 5002, 'stamina': 2, 'tonden': 1800, 'treasures': '0,30,70', 'count': '5,8', 'armys3': '4205,5_3,6|4205,5_7,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6|4202,3_4,6|4202,7_4,6|4201,3_6,6|4201,7_6,6', 'armys4': '', 'armys5': ''},
    4014: {'hp': 8, 'uiLv': 5002, 'stamina': 2, 'tonden': 1800, 'treasures': '0,30,70', 'count': '5,8', 'armys3': '4205,5_3,6|4205,5_7,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6|4202,3_4,6|4202,7_4,6|4201,3_6,6|4201,7_6,6', 'armys4': '', 'armys5': ''},
    4015: {'hp': 8, 'uiLv': 5003, 'stamina': 2, 'tonden': 2400, 'treasures': '0,10,90', 'count': '5,8', 'armys3': '4205,5_3,7|4205,5_7,7|4204,5_4,7|4204,5_6,7|4204,4_5,7|4204,6_5,7|4203,3_4,7|4203,7_4,7|4202,3_6,7|4202,7_6,7', 'armys4': '', 'armys5': ''},
    5001: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5002: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5003: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5004: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5005: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5006: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5007: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5008: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5009: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5010: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5011: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5012: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5013: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5014: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5015: {'hp': 10, 'uiLv': 6001, 'stamina': 3, 'tonden': 3000, 'treasures': '0,0,100', 'count': '6,9', 'armys3': '4201,2_2,6|4201,8_2,6|4201,2_8,6|4201,8_8,6|4202,4_8,6|4202,6_8,6|4202,4_2,6|4202,6_2,6|4202,2_4,6|4202,8_4,6|4202,2_6,6|4202,8_6,6|4205,5_3,6|4205,5_7,6|4205,3_5,6|4205,7_5,6|4204,5_4,6|4204,5_6,6|4204,4_5,6|4204,6_5,6', 'armys4': '', 'armys5': ''},
    5016: {'hp': -1, 'uiLv': 6002, 'stamina': 3, 'tonden': 3600, 'treasures': '0,0,100', 'count': '7,10', 'armys3': '4206,5_5,10|4205,5_7,7|4205,7_5,7|4205,5_3,7|4205,3_5,7', 'armys4': '', 'armys5': ''},
  };

  // ---- DIFFICULTY (game_json/landAttr.json uiLv) ----
  /// landAttr ids grouped by plot level (1-5). Ids sort easy→hard inside a
  /// band via `uiLv`, so distance maps linearly onto the list. Band sizes:
  /// lvl1 12, lvl2 12, lvl3 12, lvl4 15, lvl5 16.
  static const Map<int, List<int>> LAND_ATTR_IDS_BY_LEVEL = {
    1: [1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012],
    2: [2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012],
    3: [3001, 3002, 3003, 3004, 3005, 3006, 3007, 3008, 3009, 3010, 3011, 3012],
    4: [4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015],
    5: [5001, 5002, 5003, 5004, 5005, 5006, 5007, 5008, 5009, 5010, 5011, 5012, 5013, 5014, 5015, 5016],
  };

  /// Max sub-level per difficulty tier, per CLAUDE.md (Easy 3, Entry 3,
  /// Common 4, Advanced 4, Hard 4, Hell 2).
  static const List<int> LAND_TIER_SUBS = [0, 3, 3, 4, 4, 4, 2];

  /// Difficulty tier 1-6 (Easy..Hell) for a landAttr `uiLv`. The thousands
  /// digit is the tier: 1001-1012 Easy, 2001-2012 Entry, 3001-3012 Common,
  /// 4001-4015 Advanced, 5001-5015 Hard, 6001-6002 Hell.
  static int landDifficultyTier(int uiLv) {
    final t = uiLv ~/ 1000;
    return t.clamp(1, 6);
  }

  /// Sub-level 1..max for a landAttr `uiLv`. landAttr carries no explicit
  /// sub field, so the row ordinal inside its band cycles through the tier's
  /// sub range (reconstruction; garrison data is exact, only the label is
  /// derived).
  static int landDifficultySub(int uiLv) {
    final tier = landDifficultyTier(uiLv);
    final maxSub = LAND_TIER_SUBS[tier];
    final n = uiLv % 100;
    return ((n - 1) % maxSub) + 1;
  }

  /// Difficulty display name for a landAttr `uiLv` — e.g. "Hard 2".
  static String landDifficultyName(int uiLv) {
    const names = ['', 'Easy', 'Entry', 'Common', 'Advanced', 'Hard', 'Hell'];
    return '${names[landDifficultyTier(uiLv)]} ${landDifficultySub(uiLv)}';
  }

  /// Picks the landAttr id for a plot: [plotLevel] 1-5, [distance] from the
  /// capital in tiles (0..12). Near plots get the easy end of the band, far
  /// plots the hard end, capped at 12 tiles like the original.
  static int landAttrFor(int plotLevel, double distance) {
    final ids = LAND_ATTR_IDS_BY_LEVEL[plotLevel.clamp(1, 5)]!;
    final t = (distance.clamp(0.0, 12.0) / 12.0) * (ids.length - 1);
    return ids[t.round().clamp(0, ids.length - 1)];
  }

  /// Garrison string for a land type (3 crop / 4 wood / 5 stone). Bands that
  /// only fill `armys3` fall back to it for every type.
  static String landGarrisonRaw(int attrId, int landType) {
    final attr = LAND_ATTR[attrId];
    if (attr == null) return '';
    final raw = (attr['armys$landType'] as String?) ?? '';
    if (raw.isNotEmpty) return raw;
    return (attr['armys3'] as String?) ?? '';
  }

  /// Readable garrison label from the real composition, e.g.
  /// "Boar x2, Wolf x1". Empty when the row has no garrison.
  static String landGarrisonName(int attrId, int landType) {
    final units = landGarrison(landGarrisonRaw(attrId, landType));
    if (units.isEmpty) return 'Unoccupied';
    final counts = <String, int>{};
    for (final u in units) {
      final name = enemyName(u.key);
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts.entries.map((e) => '${e.key} x${e.value}').join(', ');
  }

  /// Enemy display name for a combat id (4101-4206), or the id itself.
  static String enemyName(String combatId) {
    for (final e in ENEMY_COMBAT) {
      if (e['id'] == combatId) return e['name'] as String;
    }
    return combatId;
  }

  /// Parses a landAttr garrison string ("pawnId,rowR_colC,level" joined by
  /// `|`) into a (pawnId, level) list. Empty string -> empty list.
  static List<MapEntry<String, int>> landGarrison(String raw) {
    final out = <MapEntry<String, int>>[];
    if (raw.isEmpty) return out;
    for (final part in raw.split('|')) {
      final bits = part.split(',');
      if (bits.length < 3) continue;
      out.add(MapEntry(bits[0], int.tryParse(bits[2]) ?? 1));
    }
    return out;
  }

  // Ground Buildings constructed ONLY on conquered world plots (outside Capital)
  static const List<Map<String, dynamic>> GROUND_BUILDINGS = [
    {
      'id': 'farm',
      'name': 'Farm',
      'resource': 'crop',
      'cost': {'wood': 80, 'crop': 40},
      'production': {'crop': 60},
      'hp': 500,
      'desc': 'Cultivates crops (+60 Crop/hr per lvl). Built on Crop plots.',
      'icon': '🌾',
    },
    {
      'id': 'sawmill',
      'name': 'Sawmill',
      'resource': 'wood',
      'cost': {'wood': 100, 'stone': 40},
      'production': {'wood': 45},
      'hp': 600,
      'desc': 'Processes timber (+45 Wood/hr per lvl). Built on Wood plots.',
      'icon': '🪚',
    },
    {
      'id': 'quarry',
      'name': 'Quarry',
      'resource': 'stone',
      'cost': {'wood': 110, 'stone': 50},
      'production': {'stone': 35},
      'hp': 700,
      'desc': 'Excavates masonry stone (+35 Stone/hr per lvl). Built on Stone plots.',
      'icon': '⛏️',
    },
    {
      // Ground Building: replaces the plot's Watchtower. Any conquered plot.
      'id': 'fortress',
      'name': 'Fortress',
      'resource': 'any',
      'cost': {'wood': 1550, 'stone': 1550},
      'buildTime': 2000, // 33:20
      'maxLevel': 20,
      'hpPerLevel': 80,
      'atkPerLevel': 16,
      'desc': 'Replaces the Watchtower (HP 80 / ATK 16). 3x faster marches '
          'between capital and fortresses, and heals wounded troops that '
          'reach it.',
      'icon': '🏯',
    },
  ];

  // Full Barracks roster (from SoldierAttribute.md, level-1 values).
  // Counter wheel: spear > cavalry > shield > bowman > spear; weaponry > building.
  // Cost scaled from category base by Cost Coefficient in the doc.
  static const List<Map<String, dynamic>> TROOPS = [
    // --- SPEARMAN (counter: cavalry) ---
    {
      'id': 'longspearman',
      'name': 'Longspearman',
      'category': 'spear',
      'counter': 'cavalry',
      'cost': {'crop': 36, 'wood': 27},
      'hp': 135, 'atk': 10, 'def': 14, 'speed': 3,
      'rage': '4/6', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 45, 'hp6': 396, 'atk6': 30,
      'skill': 'Stabs',
      'skillDesc': 'Stabs 2 tiles ahead for 100-150% ATK to 4 targets, restores 30% lost HP.',
      'desc': 'Counters Cavalry (+40% ATK, ignores 20% DEF).',
    },
    {
      'id': 'lancer',
      'name': 'Lancer',
      'category': 'spear',
      'counter': 'cavalry',
      'cost': {'crop': 40, 'wood': 30},
      'hp': 104, 'atk': 12, 'def': 12, 'speed': 3,
      'rage': '4/8', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 50, 'hp6': 305, 'atk6': 37,
      'skill': 'Project',
      'skillDesc': 'Strikes farthest enemy within 5 tiles for 70-120% ATK.',
      'desc': 'Counters Cavalry (+40% ATK, ignores 20% DEF).',
    },
    {
      'id': 'dagger_axe',
      'name': 'Dagger Axe',
      'category': 'spear',
      'counter': 'cavalry',
      'cost': {'crop': 37, 'wood': 27},
      'hp': 88, 'atk': 8, 'def': 11, 'speed': 2,
      'rage': '5/8', 'range': 2, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 46, 'hp6': 257, 'atk6': 24,
      'skill': 'Disarm',
      'skillDesc': 'Deals 100-125% ATK, cuts target ATK 30-80% for 3 rounds.',
      'desc': 'Counters Cavalry (+40% ATK, ignores 20% DEF).',
    },
    {
      'id': 'modao',
      'name': 'Modao',
      'category': 'spear',
      'counter': 'cavalry',
      'cost': {'crop': 42, 'wood': 31},
      'hp': 94, 'atk': 12, 'def': 10, 'speed': 3,
      'rage': '0/0', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 52, 'hp6': 277, 'atk6': 34,
      'skill': 'Erratic Attack / Cavalry Suffer (Passive)',
      'skillDesc': 'Random DMG ignoring DMG Reduction; bonus random DMG vs cavalry.',
      'desc': 'Counters Cavalry (+40% ATK, ignores 20% DEF).',
    },
    {
      'id': 'long_swordsman',
      'name': 'Long Swordsman',
      'category': 'spear',
      'counter': 'cavalry',
      'cost': {'crop': 38, 'wood': 28},
      'hp': 208, 'atk': 9, 'def': 16, 'speed': 3,
      'rage': '6/10', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 47, 'hp6': 610, 'atk6': 26,
      'skill': 'Whirlwind',
      'skillDesc': '45-70% DMG to 12 targets within 2 tiles + bleed True DMG 3 rounds.',
      'desc': 'Counters Cavalry (+40% ATK, ignores 20% DEF).',
    },
    {
      'id': 'twin_spearman',
      'name': 'Twin Spearman',
      'category': 'spear',
      'counter': 'cavalry',
      'cost': {'crop': 40, 'wood': 30},
      'hp': 126, 'atk': 11, 'def': 13, 'speed': 3,
      'rage': '5/8', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 50, 'hp6': 366, 'atk6': 32,
      'skill': 'Unbridled Dance',
      'skillDesc': 'Dashes to densest enemy cluster, 2x35% DMG to 8 targets, may parry basics.',
      'desc': 'Counters Cavalry (+40% ATK, ignores 20% DEF).',
    },
    // --- SHIELDMAN (counter: bowman) ---
    {
      'id': 'saber_shield',
      'name': 'Saber and Shield',
      'category': 'shield',
      'counter': 'bowman',
      'cost': {'crop': 60, 'wood': 24, 'stone': 36},
      'hp': 265, 'atk': 6, 'def': 26, 'speed': 3,
      'rage': '12/15', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 60, 'hp6': 745, 'atk6': 17,
      'skill': 'Shield',
      'skillDesc': 'Shields self + lowest-HP ally within 5 tiles, absorbs 30-80 DMG 3 rounds.',
      'desc': 'Counters Bowman (+40% ATK).',
    },
    {
      'id': 'heavy_shield',
      'name': 'Heavy Shield',
      'category': 'shield',
      'counter': 'bowman',
      'cost': {'crop': 72, 'wood': 29, 'stone': 43},
      'hp': 318, 'atk': 4, 'def': 30, 'speed': 3,
      'rage': '10/16', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 72, 'hp6': 895, 'atk6': 11,
      'skill': 'Shield Stance',
      'skillDesc': 'DMG taken -30-80% for 3 rounds; cannot act or gain Rage in stance.',
      'desc': 'Counters Bowman (+40% ATK).',
    },
    {
      'id': 'spear_shield',
      'name': 'Spear and Shield',
      'category': 'shield',
      'counter': 'bowman',
      'cost': {'crop': 63, 'wood': 25, 'stone': 38},
      'hp': 278, 'atk': 8, 'def': 27, 'speed': 3,
      'rage': '5/10', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 63, 'hp6': 784, 'atk6': 15,
      'skill': 'Charge',
      'skillDesc': 'Charges farthest target within 5 tiles, 100-125% ATK + blocks next attack.',
      'desc': 'Counters Bowman (+40% ATK).',
    },
    {
      'id': 'hammer_shield',
      'name': 'Hammer and Shield',
      'category': 'shield',
      'counter': 'bowman',
      'cost': {'crop': 65, 'wood': 26, 'stone': 39},
      'hp': 239, 'atk': 5, 'def': 25, 'speed': 3,
      'rage': '10/15', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 65, 'hp6': 673, 'atk6': 14,
      'skill': 'Earthshaker',
      'skillDesc': '70-100% ATK to 12 targets within 2 tiles + silence 2 rounds.',
      'desc': 'Counters Bowman (+40% ATK).',
    },
    {
      'id': 'sword_shield',
      'name': 'Sword and Shield',
      'category': 'shield',
      'counter': 'bowman',
      'cost': {'crop': 124, 'wood': 50, 'stone': 74},
      'hp': 159, 'atk': 3, 'def': 22, 'speed': 3,
      'rage': '8/15', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 124, 'hp6': 431, 'atk6': 8,
      'skill': 'Guardian Shield (Trainee Warrior)',
      'skillDesc': '100-125% ATK + shield 80% of DMG 3 turns; stacks Leap per Boar Knight slain.',
      'desc': 'Counters Bowman (+40% ATK).',
    },
    {
      'id': 'axe_shield',
      'name': 'Axe and Shield',
      'category': 'shield',
      'counter': 'bowman',
      'cost': {'crop': 67, 'wood': 27, 'stone': 40},
      'hp': 212, 'atk': 10, 'def': 24, 'speed': 3,
      'rage': '4/6', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 67, 'hp6': 598, 'atk6': 30,
      'skill': 'Whirling Axe / Shield Bash (Passive)',
      'skillDesc': 'Throws axe at random target within 4 tiles, bounces; bashes adjacent foes.',
      'desc': 'Counters Bowman (+40% ATK).',
    },
    // --- BOWMAN (counter: spearman) ---
    {
      'id': 'longbowman',
      'name': 'Longbowman',
      'category': 'bow',
      'counter': 'spearman',
      'cost': {'crop': 57, 'wood': 74},
      'hp': 78, 'atk': 7, 'def': 8, 'speed': 2,
      'rage': '6/8', 'range': 4, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 82, 'hp6': 128, 'atk6': 17,
      'skill': 'Scatter',
      'skillDesc': 'Hits 2 extra targets within 6 tiles for 50-100% DMG.',
      'desc': 'Counters Spearman (+40% ATK).',
    },
    {
      'id': 'crossbowman',
      'name': 'Crossbowman',
      'category': 'bow',
      'counter': 'spearman',
      'cost': {'crop': 57, 'wood': 73},
      'hp': 117, 'atk': 6, 'def': 10, 'speed': 3,
      'rage': '2/4', 'range': 3, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 81, 'hp6': 268, 'atk6': 14,
      'skill': 'Rapid Fire',
      'skillDesc': 'Fires 3x: 100% then 45-70% DMG.',
      'desc': 'Counters Spearman (+40% ATK).',
    },
    {
      'id': 'toxibowman',
      'name': 'Toxibowman',
      'category': 'bow',
      'counter': 'spearman',
      'cost': {'crop': 57, 'wood': 74},
      'hp': 76, 'atk': 5, 'def': 7, 'speed': 2,
      'rage': '4/6', 'range': 4, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 82, 'hp6': 122, 'atk6': 10,
      'skill': 'Poison Arrow',
      'skillDesc': 'Poisons target: 1-3.5% max-HP True DMG/round, -55-80% healing 3 rounds.',
      'desc': 'Counters Spearman (+40% ATK).',
    },
    {
      'id': 'hunter',
      'name': 'Hunter',
      'category': 'bow',
      'counter': 'spearman',
      'cost': {'crop': 59, 'wood': 75},
      'hp': 94, 'atk': 7, 'def': 9, 'speed': 2,
      'rage': '12/12', 'range': 4, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 84, 'hp6': 150, 'atk6': 12,
      'skill': 'Inspire (Hunting)',
      'skillDesc': 'Allies in range +2-9 ATK 3 rounds; +30% ATK vs Beasts.',
      'desc': 'Counters Spearman (+40% ATK).',
    },
    {
      'id': 'improved_crossbowman',
      'name': 'Improved Crossbowman',
      'category': 'bow',
      'counter': 'spearman',
      'cost': {'crop': 60, 'wood': 78},
      'hp': 55, 'atk': 15, 'def': 6, 'speed': 2,
      'rage': '0/0', 'range': 5, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 86, 'hp6': 70, 'atk6': 38,
      'skill': 'Draw / Anchor (Passive)',
      'skillDesc': 'Reloads 1 round per shot; +15-20% DMG per tile of distance.',
      'desc': 'Counters Spearman (+40% ATK).',
    },
    {
      'id': 'fire_bowman',
      'name': 'Fire Bowman',
      'category': 'bow',
      'counter': 'spearman',
      'cost': {'crop': 61, 'wood': 78},
      'hp': 78, 'atk': 6, 'def': 7, 'speed': 2,
      'rage': '8/10', 'range': 4, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 87, 'hp6': 128, 'atk6': 11,
      'skill': 'Fire Arrow',
      'skillDesc': 'Sets enemy ground ablaze within 7 tiles; burn True DMG scales with intensity.',
      'desc': 'Counters Spearman (+40% ATK).',
    },
    // --- CAVALRY (counter: shieldman) ---
    {
      'id': 'sword_cavalry',
      'name': 'Sword Cavalry',
      'category': 'cavalry',
      'counter': 'shieldman',
      'cost': {'crop': 115, 'wood': 82, 'stone': 33},
      'hp': 155, 'atk': 14, 'def': 15, 'speed': 4,
      'rage': '4/10', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 82, 'hp6': 475, 'atk6': 43,
      'skill': 'Leap Slash',
      'skillDesc': 'Leaps to lowest-HP target within 5 tiles: 100-125% ATK +10% lost HP.',
      'desc': 'Counters Shieldman (+40% ATK).',
    },
    {
      'id': 'spear_cavalry',
      'name': 'Spear Cavalry',
      'category': 'cavalry',
      'counter': 'shieldman',
      'cost': {'crop': 118, 'wood': 84, 'stone': 33},
      'hp': 186, 'atk': 10, 'def': 17, 'speed': 4,
      'rage': '6/10', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 84, 'hp6': 569, 'atk6': 31,
      'skill': 'Sweep',
      'skillDesc': '45-70% DMG to 20 targets within 3 tiles; +30% vs adjacent.',
      'desc': 'Counters Shieldman (+40% ATK).',
    },
    {
      'id': 'broadsword_cavalry',
      'name': 'Broadsword Cavalry',
      'category': 'cavalry',
      'counter': 'shieldman',
      'cost': {'crop': 129, 'wood': 92, 'stone': 37},
      'hp': 126, 'atk': 18, 'def': 14, 'speed': 4,
      'rage': '2/4', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 92, 'hp6': 386, 'atk6': 53,
      'skill': 'Chop',
      'skillDesc': '20-30 bonus True DMG per chop, stacks on same target.',
      'desc': 'Counters Shieldman (+40% ATK).',
    },
    {
      'id': 'heavy_cavalry',
      'name': 'Heavy Cavalry',
      'category': 'cavalry',
      'counter': 'shieldman',
      'cost': {'crop': 150, 'wood': 107, 'stone': 43},
      'hp': 256, 'atk': 7, 'def': 20, 'speed': 4,
      'rage': '4/12', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 107, 'hp6': 781, 'atk6': 23,
      'skill': 'Collide',
      'skillDesc': 'Knocks up enemies 2 tiles ahead for 75-100% ATK; breaks shields.',
      'desc': 'Counters Shieldman (+40% ATK).',
    },
    {
      'id': 'bow_cavalry',
      'name': 'Bow Cavalry',
      'category': 'cavalry',
      'counter': 'shieldman',
      'cost': {'crop': 118, 'wood': 84, 'stone': 33},
      'hp': 93, 'atk': 8, 'def': 12, 'speed': 4,
      'rage': '2/6', 'range': 4, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 84, 'hp6': 232, 'atk6': 18,
      'skill': 'Equestrian Archery',
      'skillDesc': 'Moves 1 tile then fires; up to 4 shots, 100% then 30-80% DMG.',
      'desc': 'Counters Shieldman (+40% ATK).',
    },
    {
      'id': 'axe_cavalry',
      'name': 'Axe Cavalry',
      'category': 'cavalry',
      'counter': 'shieldman',
      'cost': {'crop': 123, 'wood': 88, 'stone': 35},
      'hp': 202, 'atk': 9, 'def': 16, 'speed': 4,
      'rage': '0/0', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 88, 'hp6': 618, 'atk6': 26,
      'skill': 'Shattered Armor / Cleave (Passive)',
      'skillDesc': '+50-100% DMG vs shielded; 50% cleave 45-70% DMG around target.',
      'desc': 'Counters Shieldman (+40% ATK).',
    },
    // --- WEAPONRY (counter: building, cannot upgrade) ---
    {
      'id': 'catapult',
      'name': 'Catapult',
      'category': 'weaponry',
      'counter': 'building',
      'cost': {'crop': 80, 'wood': 80, 'stone': 40},
      'hp': 50, 'atk': 15, 'def': 5, 'speed': 1,
      'rage': '0/0', 'range': 5, 'move': 1, 'upkeep': 5, 'march': 46, 'coef': 60, 'hp6': 50, 'atk6': 15,
      'skill': 'Counter Building (Passive)',
      'skillDesc': 'ATK +2 when attacking Buildings. Cannot be upgraded.',
      'desc': 'Siege engine. Bonus vs Buildings.',
    },
    {
      'id': 'trebuchet',
      'name': 'Trebuchet',
      'category': 'weaponry',
      'counter': 'building',
      'cost': {'crop': 90, 'wood': 90, 'stone': 40},
      'hp': 50, 'atk': 18, 'def': 5, 'speed': 1,
      'rage': '0/0', 'range': 5, 'move': 1, 'upkeep': 5, 'march': 46, 'coef': 60, 'hp6': 50, 'atk6': 18,
      'skill': 'Penetration (Passive)',
      'skillDesc': 'Bonus DMG = 1% target Max HP (3.5% at Smithy 14). Cannot be upgraded.',
      'desc': 'Siege engine. Bonus vs Buildings.',
    },
  ];

  // =====================================================================
  // EQUIPMENT — real in-game data (equipBase.json / equipEffect.json /
  // equipText.json). Replaces the hand-rolled demo table (2026-11-14).
  //
  // Common pieces 6001-6044. Per row:
  //   'id'          numeric equipBase id
  //   'name'        equipText name_<id>.en
  //   'nameIdl'     equipText name_<id>.idl (official Indonesian)
  //   'hp'/'atk'    roll brackets as the game stores them, "lo,hi"
  //   'effects'     ordered equipEffect ids assigned to this piece
  //   'random'      how many of 'effects' actually roll (0 = all fixed)
  //   'needLv'      Smithy levels at which this tier can be forged
  //   'cost'        forge_cost decoded to {wood, stone, iron} (resource 2/3/9)
  //   'forgeTime'   seconds
  //   'restore'     restore_cost
  //   'recastMax'   reforge_count (growth pieces only)
  static const int EQUIP_RES_WOOD = 2;
  static const int EQUIP_RES_STONE = 3;
  static const int EQUIP_RES_IRON = 9;

  static const List<Map<String, dynamic>> EQUIP_MASTER = [
    // --- Smithy Lv.1 tier (needLv starts 1) ---
    {'id': 6001, 'name': 'Iron Sword', 'nameIdl': 'Pedang Besi', 'hp': '', 'atk': '6,15', 'effects': <int>[], 'random': 0, 'needLv': <int>[], 'cost': {'wood': 266, 'stone': 266, 'iron': 1}, 'forgeTime': 120, 'restore': 2, 'recastMax': 0},
    {'id': 6002, 'name': 'Helmet', 'nameIdl': 'Helm', 'hp': '60,130', 'atk': '', 'effects': <int>[], 'random': 0, 'needLv': <int>[], 'cost': {'wood': 266, 'stone': 266, 'iron': 1}, 'forgeTime': 200, 'restore': 2, 'recastMax': 0},
    {'id': 6003, 'name': 'Cureblade', 'nameIdl': 'Pisau Cure', 'hp': '', 'atk': '1,5', 'effects': <int>[1], 'random': 1, 'needLv': <int>[1, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 349, 'restore': 4, 'recastMax': 0},
    {'id': 6005, 'name': 'Crit Blade', 'nameIdl': 'Pisau Crit', 'hp': '', 'atk': '2,10', 'effects': <int>[3], 'random': 1, 'needLv': <int>[1, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 349, 'restore': 4, 'recastMax': 0},
    {'id': 6013, 'name': 'Meteor Hammer', 'nameIdl': 'Palu Meteor', 'hp': '', 'atk': '2,10', 'effects': <int>[11], 'random': 1, 'needLv': <int>[1, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 349, 'restore': 4, 'recastMax': 0},
    {'id': 6015, 'name': 'Dual Axe', 'nameIdl': 'Kapak Ganda', 'hp': '', 'atk': '2,10', 'effects': <int>[15], 'random': 1, 'needLv': <int>[1, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 349, 'restore': 4, 'recastMax': 0},
    {'id': 6028, 'name': 'Crescent Blade', 'nameIdl': 'Pedang Bulan Sabit', 'hp': '', 'atk': '2,8', 'effects': <int>[36], 'random': 1, 'needLv': <int>[1, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 349, 'restore': 4, 'recastMax': 0},
    {'id': 6042, 'name': 'Longyuan Sword', 'nameIdl': 'Pedang Longyuan', 'hp': '', 'atk': '2,8', 'effects': <int>[49], 'random': 1, 'needLv': <int>[1, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 349, 'restore': 4, 'recastMax': 0},
    // --- Lv.3 tier ---
    {'id': 6004, 'name': 'Chainmail', 'nameIdl': 'Zirah Rantai', 'hp': '20,70', 'atk': '', 'effects': <int>[2], 'random': 1, 'needLv': <int>[3, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 589, 'restore': 4, 'recastMax': 0},
    {'id': 6006, 'name': 'Wine Gourd', 'nameIdl': 'Labu Anggur', 'hp': '20,50', 'atk': '', 'effects': <int>[4], 'random': 1, 'needLv': <int>[3, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 589, 'restore': 4, 'recastMax': 0},
    {'id': 6008, 'name': 'DMG Reflection Armor', 'nameIdl': 'Zirah Refleksi DMG', 'hp': '20,80', 'atk': '', 'effects': <int>[6], 'random': 1, 'needLv': <int>[3, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 589, 'restore': 4, 'recastMax': 0},
    {'id': 6016, 'name': 'Copper Shield', 'nameIdl': 'Perisai Tembaga', 'hp': '20,60', 'atk': '', 'effects': <int>[16], 'random': 1, 'needLv': <int>[3, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 589, 'restore': 4, 'recastMax': 0},
    {'id': 6019, 'name': 'Golden Axe', 'nameIdl': 'Kapak Emas', 'hp': '20,40', 'atk': '1,5', 'effects': <int>[19], 'random': 1, 'needLv': <int>[3, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 589, 'restore': 4, 'recastMax': 0},
    {'id': 6022, 'name': 'Iron Shield', 'nameIdl': 'Perisai Besi', 'hp': '20,70', 'atk': '', 'effects': <int>[26], 'random': 1, 'needLv': <int>[3, 5, 7, 12, 14, 16, 20], 'cost': {'wood': 357, 'stone': 357, 'iron': 2}, 'forgeTime': 589, 'restore': 4, 'recastMax': 0},
    // --- Lv.5 tier ---
    {'id': 6007, 'name': 'Leech Sword', 'nameIdl': 'Pedang Leech', 'hp': '20,40', 'atk': '2,10', 'effects': <int>[5], 'random': 1, 'needLv': <int>[5, 7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6020, 'name': 'Circle Blade', 'nameIdl': 'Pedang Cincin', 'hp': '20,40', 'atk': '2,10', 'effects': <int>[20], 'random': 1, 'needLv': <int>[5, 7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6038, 'name': 'Obsidian Armor', 'nameIdl': 'Zirah Obsidian', 'hp': '20,50', 'atk': '', 'effects': <int>[45], 'random': 1, 'needLv': <int>[5, 7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6043, 'name': 'Radiant Plate Armor', 'nameIdl': 'Zirah Mingguang', 'hp': '10,10', 'atk': '', 'effects': <int>[50], 'random': 0, 'needLv': <int>[5, 7, 12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 0, 'recastMax': 50},
    {'id': 6044, 'name': 'Thousand Tempered Blade', 'nameIdl': 'Pisau Baibi', 'hp': '', 'atk': '1,1', 'effects': <int>[51], 'random': 0, 'needLv': <int>[5, 7, 12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 0, 'recastMax': 50},
    // --- Lv.7 tier ---
    {'id': 6009, 'name': 'Darts', 'nameIdl': 'Anak Panah', 'hp': '', 'atk': '4,14', 'effects': <int>[7], 'random': 1, 'needLv': <int>[7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6014, 'name': 'Rattan Shield', 'nameIdl': 'Perisai Rotan', 'hp': '20,60', 'atk': '', 'effects': <int>[12], 'random': 1, 'needLv': <int>[7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6021, 'name': 'Mace', 'nameIdl': 'Gada', 'hp': '', 'atk': '2,8', 'effects': <int>[14], 'random': 1, 'needLv': <int>[7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6023, 'name': 'Army Flag', 'nameIdl': 'Bendera Tentara', 'hp': '20,50', 'atk': '', 'effects': <int>[27], 'random': 1, 'needLv': <int>[7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6024, 'name': 'Qiankun Saber', 'nameIdl': 'Pedang Qiankun', 'hp': '', 'atk': '2,8', 'effects': <int>[31], 'random': 1, 'needLv': <int>[7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6029, 'name': 'Sunfire Armor', 'nameIdl': 'Armor Api Matahari', 'hp': '20,60', 'atk': '', 'effects': <int>[37], 'random': 1, 'needLv': <int>[7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6032, 'name': 'Helmet of Calmness', 'nameIdl': 'Helm Calm', 'hp': '20,50', 'atk': '', 'effects': <int>[39], 'random': 1, 'needLv': <int>[7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6034, 'name': 'Pure Gold Shield', 'nameIdl': 'Perisai Red Gold', 'hp': '20,50', 'atk': '', 'effects': <int>[41], 'random': 1, 'needLv': <int>[7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    {'id': 6041, 'name': 'Silver Serpent Whip', 'nameIdl': 'Cambuk Ular Perak', 'hp': '', 'atk': '2,10', 'effects': <int>[48], 'random': 1, 'needLv': <int>[7, 12, 14, 16, 20], 'cost': {'wood': 431, 'stone': 431, 'iron': 4}, 'forgeTime': 710, 'restore': 8, 'recastMax': 0},
    // --- Lv.12 tier ---
    {'id': 6012, 'name': 'Lamellar Cuirass', 'nameIdl': 'Zirah Lamelar', 'hp': '20,80', 'atk': '', 'effects': <int>[10], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    {'id': 6017, 'name': 'Hook Swords', 'nameIdl': 'Pedang Kait', 'hp': '', 'atk': '2,8', 'effects': <int>[17], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    {'id': 6018, 'name': 'Mirror Armor', 'nameIdl': 'Mirror Armor', 'hp': '20,70', 'atk': '', 'effects': <int>[18], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    {'id': 6026, 'name': 'Battle Axe', 'nameIdl': 'Kapak Perang', 'hp': '', 'atk': '2,8', 'effects': <int>[34], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    {'id': 6027, 'name': 'Jade Pendant', 'nameIdl': 'Liontin Giok', 'hp': '20,50', 'atk': '', 'effects': <int>[35], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    {'id': 6031, 'name': 'Lethal Umbrella', 'nameIdl': 'Payung Mesin', 'hp': '20,40', 'atk': '2,6', 'effects': <int>[38], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    {'id': 6035, 'name': 'Ring of Burning Heart', 'nameIdl': 'Cincin Burning Heart', 'hp': '', 'atk': '2,6', 'effects': <int>[42], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    {'id': 6036, 'name': 'Billhook', 'nameIdl': 'Sabit Hook', 'hp': '', 'atk': '2,8', 'effects': <int>[43], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    {'id': 6037, 'name': 'Bloodrage Belt', 'nameIdl': 'Sabuk Amarah Darah', 'hp': '20,50', 'atk': '', 'effects': <int>[44], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    {'id': 6040, 'name': 'Spiked Mace', 'nameIdl': 'Bola Duri', 'hp': '', 'atk': '2,8', 'effects': <int>[47], 'random': 1, 'needLv': <int>[12, 14, 16, 20], 'cost': {'wood': 525, 'stone': 525, 'iron': 6}, 'forgeTime': 831, 'restore': 12, 'recastMax': 0},
    // --- Lv.14 tier ---
    {'id': 6010, 'name': 'Dodge Boots', 'nameIdl': 'Sepatu Dodge', 'hp': '20,50', 'atk': '', 'effects': <int>[8], 'random': 1, 'needLv': <int>[14, 16, 20], 'cost': {'wood': 629, 'stone': 629, 'iron': 8}, 'forgeTime': 1446, 'restore': 16, 'recastMax': 0},
    {'id': 6011, 'name': 'Flying Guillotine', 'nameIdl': 'Flying Guillotine', 'hp': '', 'atk': '2,8', 'effects': <int>[9], 'random': 1, 'needLv': <int>[14, 16, 20], 'cost': {'wood': 629, 'stone': 629, 'iron': 8}, 'forgeTime': 1446, 'restore': 16, 'recastMax': 0},
    {'id': 6025, 'name': 'Time Flag', 'nameIdl': 'Bendera Waktu', 'hp': '30,30', 'atk': '3,3', 'effects': <int>[32, 33], 'random': 0, 'needLv': <int>[14, 16, 20], 'cost': {'wood': 1112, 'stone': 1112, 'iron': 20}, 'forgeTime': 3430, 'restore': 40, 'recastMax': 0},
    {'id': 6030, 'name': 'Hourglass', 'nameIdl': 'Jam Pasir', 'hp': '', 'atk': '2,4', 'effects': <int>[13], 'random': 1, 'needLv': <int>[14, 16, 20], 'cost': {'wood': 629, 'stone': 629, 'iron': 8}, 'forgeTime': 1446, 'restore': 16, 'recastMax': 0},
    {'id': 6033, 'name': 'Blinding Pendant', 'nameIdl': 'Liontin Dazzling Fall', 'hp': '20,50', 'atk': '', 'effects': <int>[40], 'random': 1, 'needLv': <int>[14, 16, 20], 'cost': {'wood': 629, 'stone': 629, 'iron': 8}, 'forgeTime': 1446, 'restore': 16, 'recastMax': 0},
    {'id': 6039, 'name': 'Darksteel Staff', 'nameIdl': 'Tongkat Besi Hitam', 'hp': '20,40', 'atk': '2,6', 'effects': <int>[46], 'random': 1, 'needLv': <int>[14, 16, 20], 'cost': {'wood': 629, 'stone': 629, 'iron': 8}, 'forgeTime': 1446, 'restore': 16, 'recastMax': 0},
  ];

  /// equipEffect.json — 51 rows. The roll range lives in `value` for most
  /// effects; a subset carries it in `odds` instead (the Chinese/EN text
  /// uses {0} for value and {1} for odds independently), so both are kept.
  /// `desc`/`descIdl` come from equipText `effect_<id>`.
  static const Map<int, Map<String, dynamic>> EQUIP_EFFECTS = {
    1: {'value': '4,10', 'suffix': '', 'odds': '', 'desc': 'Restores {0} HP on effective DMG; 40% chance to heal the lowest-HP ally within 5 tiles. Cannot heal weaponry. Halved past Range 2.', 'descIdl': 'Saat menyerang, memulihkan {0} HP setelah memberikan DMG efektif, ada 40% peluang memulihkan HP yang sama ke 1 sekutu ber-HP terendah dalam 5 Kotak (tidak bisa heal senjata; halving bila jangkauan > 2).'},
    2: {'value': '', 'suffix': '', 'odds': '5,20', 'desc': 'DMG taken -5. Per effective hit taken, {1} chance to reduce DMG taken by 1; +1 chance per 50 Max HP.', 'descIdl': 'DMG yang diterima -5, per ATK efektif ada {1} peluang mengurangi DMG diterima 1; tiap 50 HP Maks +1 peluang.'},
    3: {'value': '150,180', 'suffix': '%', 'odds': '20,40', 'desc': '{1} chance to deal {0} Crit DMG.', 'descIdl': 'Ada {1} peluang memberikan {0} CRIT DMG.'},
    4: {'value': '1,4', 'suffix': '%', 'odds': '', 'desc': 'Restores {0} of Max HP at the start of each round.', 'descIdl': 'Memulihkan {0} HP Maks di awal setiap ronde.'},
    5: {'value': '10,50', 'suffix': '%', 'odds': '', 'desc': 'On attack, Leech {0}; excess HP becomes a Shield up to Level*6.', 'descIdl': 'Saat ATK menambahkan Leech {0}; HP berlebih jadi Perisai hingga 6x level.'},
    6: {'value': '', 'suffix': '', 'odds': '20,40', 'desc': 'On taking DMG, {1} chance to reflect 5 True DMG; +1 per 50 Max HP.', 'descIdl': 'Saat menerima ATK ada {1} peluang memantulkan 5 True DMG; tiap 50 HP Maks Reflect +1.'},
    7: {'value': '20,50', 'suffix': '%', 'odds': '', 'desc': 'Converts {0} DMG dealt into True DMG.', 'descIdl': 'Mengubah {0} DMG yang diberikan menjadi True DMG.'},
    8: {'value': '', 'suffix': '', 'odds': '10,35', 'desc': '{1} chance to dodge all DMG.', 'descIdl': 'Ada {1} peluang dodge semua DMG.'},
    9: {'value': '5,20', 'suffix': '%', 'odds': '', 'desc': 'Slays targets below {0} HP and gains ATK +1 until battle end.', 'descIdl': 'Slay target dengan HP di bawah {0} dan ATK +1 hingga battle berakhir.'},
    10: {'value': '15,30', 'suffix': '', 'odds': '', 'desc': 'DMG taken capped at {0}; excess HP loss deferred 50%/round (100% if below {0}).', 'descIdl': 'DMG diterima tidak lebih dari {0}; kelebihan HP hilang ditunda 50%/ronde (100% bila di bawah {0}).'},
    11: {'value': '30,70', 'suffix': '%', 'odds': '', 'desc': 'ATK Range +1. Ignores {0} Dodge on attack.', 'descIdl': 'Jangkauan ATK +1, ignore {0} Dodge saat ATK.'},
    12: {'value': '30,60', 'suffix': '%', 'odds': '', 'desc': 'Ranged DMG -{0}; halves below 50% HP.', 'descIdl': 'Range DMG -{0}; effect halved di bawah 50% HP.'},
    13: {'value': '', 'suffix': '', 'odds': '5,25', 'desc': '{1} chance of acting 2 rounds.', 'descIdl': 'Ada {1} peluang beraksi 2 ronde.'},
    14: {'value': '1,5', 'suffix': '%', 'odds': '', 'desc': "Deals ({0} * target's current HP) additional DMG.", 'descIdl': 'Memberikan ekstra ({0} * HP saat ini target) DMG.'},
    15: {'value': '', 'suffix': '', 'odds': '20,50', 'desc': 'Each attack +1 Rage. {1} chance for +50% Rage after casting skills.', 'descIdl': 'Setiap ATK +1 Rage; ada {1} peluang +50% Rage setelah skill.'},
    16: {'value': '5,15', 'suffix': '%', 'odds': '', 'desc': 'First time below 50% HP: Shield (Max HP*{0}) and restore 30% Max HP.', 'descIdl': 'Saat HP pertama turun ke 50%: Perisai ({0}*HP Maks) dan pulihkan 30% HP Maks.'},
    17: {'value': '', 'suffix': '', 'odds': '15,35', 'desc': "{1} chance for extra True DMG = (2+level)% target Max HP (ranged: 1+level%).", 'descIdl': 'Ada {1} peluang True DMG ekstra (2+level)% HP Maks target (jarak jauh 1+level%).'},
    18: {'value': '10,15', 'suffix': '', 'odds': '', 'desc': 'Per distinct attacker: +4% DMG Reduction, max {0} stacks; +10% Max HP at 8.', 'descIdl': 'Per penyerang berbeda: +4% DMG Reduction, maks {0} stack; +10% HP Maks di 8.'},
    19: {'value': '', 'suffix': '', 'odds': '50,80', 'desc': "On effective DMG, {1} chance for Shield = (4+level)% of target's Max HP. No stack.", 'descIdl': 'Saat DMG efektif ada {1} peluang Perisai = (4+level)% HP Maks target; tak bisa stack.'},
    20: {'value': '4,10', 'suffix': '%', 'odds': '', 'desc': 'Per hit taken, next attack Leech +{0} (max 60%); +30% next DMG at 30% Leech.', 'descIdl': 'Per ATK diterima, Leech ATK berikut +{0} (maks 60%); +30% DMG berikutnya saat 30% Leech.'},
    21: {'value': '20,40', 'suffix': '%', 'odds': '', 'desc': 'Basic ATK +{0}.', 'descIdl': 'ATK dasar +{0}.'},
    22: {'value': '20,40', 'suffix': '%', 'odds': '', 'desc': 'Basic HP +{0}.', 'descIdl': 'HP dasar +{0}.'},
    23: {'value': '10,30', 'suffix': '%', 'odds': '', 'desc': 'Shield Effect +{0}.', 'descIdl': 'Efek Perisai +{0}.'},
    24: {'value': '10,20', 'suffix': '%', 'odds': '', 'desc': 'Charge DMG +{0}.', 'descIdl': 'Charge DMG +{0}.'},
    25: {'value': '25,40', 'suffix': '%', 'odds': '', 'desc': 'Collision DMG +{0}.', 'descIdl': 'Collision DMG +{0}.'},
    26: {'value': '10,35', 'suffix': '%', 'odds': '', 'desc': 'Melee DMG -{0}; doubled below 50% HP.', 'descIdl': 'Melee DMG -{0}; efek digandakan di bawah 50% HP.'},
    27: {'value': '2,4', 'suffix': '', 'odds': '', 'desc': 'On death, drops Army Flag ({0} HP): allies +20% DMG, enemies -20% within 2 tiles.', 'descIdl': 'Saat mati, drop Bendera Tentara ({0} HP): sekutu +20% DMG, musuh -20% dalam 2 kotak.'},
    28: {'value': '', 'suffix': '', 'odds': '', 'desc': 'Move Range +1.', 'descIdl': 'Jangkauan Gerakan +1.'},
    29: {'value': '1,5', 'suffix': '', 'odds': '', 'desc': 'Reflects {0} True DMG on taking Ranged DMG.', 'descIdl': 'Reflect {0} True DMG saat menerima DMG jarak jauh.'},
    30: {'value': '1,5', 'suffix': '', 'odds': '', 'desc': 'Reflects {0} True DMG on taking Melee DMG.', 'descIdl': 'Reflect {0} True DMG saat menerima DMG melee.'},
    31: {'value': '30,60', 'suffix': '%', 'odds': '', 'desc': 'Basic attacks deal extra {0} ATK True DMG to 4 enemies within 1 tile of target.', 'descIdl': 'Normal ATK beri ekstra {0} ATK True DMG ke 4 musuh dalam 1 kotak dari target.'},
    32: {'value': '10,10', 'suffix': '', 'odds': '', 'desc': 'HP only: +((3+level)*10) HP each season.', 'descIdl': 'Hanya HP: +((3+level)*10) HP per musim.'},
    33: {'value': '1,1', 'suffix': '', 'odds': '', 'desc': 'ATK only: +(3+level) ATK each season.', 'descIdl': 'Hanya ATK: +(3+level) ATK per musim.'},
    34: {'value': '10,30', 'suffix': '%', 'odds': '', 'desc': 'First time at 50% HP: ATK +(3*level), Leech +{0}.', 'descIdl': 'Saat HP pertama ke 50%: ATK +(3*level), Leech +{0}.'},
    35: {'value': '5,10', 'suffix': '%', 'odds': '', 'desc': 'Round 1: 3 closest allies gain Shield = {0} self Max HP and block 1 active skill hit (10 rounds).', 'descIdl': 'Ronde 1: 3 sekutu terdekat dapat Perisai = {0} HP Maks diri dan menahan 1 hit skill aktif (10 ronde).'},
    36: {'value': '20,50', 'suffix': '%', 'odds': '', 'desc': 'DMG dealt +{0}, ignores 20% DMG Reduction; DMG taken +100%.', 'descIdl': 'DMG diberikan +{0}, ignore 20% DMG Reduction; DMG diterima +100%.'},
    37: {'value': '', 'suffix': '', 'odds': '20,50', 'desc': 'Each round start, {1} chance to deal 4% self Max HP True DMG to 4 enemies within 1 tile.', 'descIdl': 'Awal tiap ronde ada {1} peluang True DMG 4% HP Maks diri ke 4 musuh dalam 1 kotak.'},
    38: {'value': '5,15', 'suffix': '%', 'odds': '5,15', 'desc': 'Battle start: ATK +{0}, DMG taken -{1}, and doubles a random effect from above.', 'descIdl': 'Awal battle: ATK +{0}, DMG diterima -{1}, dan menggandakan acak salah satu efek sebelumnya.'},
    39: {'value': '10,20', 'suffix': '%', 'odds': '', 'desc': 'Max HP +{0}; every 5 rounds restores 20% lost HP to self and 4 allies.', 'descIdl': 'HP Maks +{0}; tiap 5 ronde regen 20% HP hilang ke diri dan 4 sekutu.'},
    40: {'value': '', 'suffix': '', 'odds': '10,35', 'desc': 'On taking True DMG, {1} chance to stun attacker 1 round.', 'descIdl': 'Saat menerima True DMG ada {1} peluang stun penyerang 1 ronde.'},
    41: {'value': '20,50', 'suffix': '%', 'odds': '', 'desc': 'Every 3 rounds gain 4% Max HP Shield; Shield effects on self +{0}.', 'descIdl': 'Tiap 3 ronde dapat Perisai 4% HP Maks; efek Perisai diri +{0}.'},
    42: {'value': '20,40', 'suffix': '%', 'odds': '50,50', 'desc': 'Skill hit: 50% Burning Heart ({0} ATK True DMG/round; splashes (level*10)% to 4 enemies for 3 rounds).', 'descIdl': 'Skill kena target: 50% Burning Heart ({0} ATK True DMG/ronde; splash (level*10)% ke 4 musuh 3 ronde).'},
    43: {'value': '4,8', 'suffix': '', 'odds': '', 'desc': 'Additional DMG = ({0} * own level)% of target ATK.', 'descIdl': 'Ekstra {0} x level sendiri % dari ATK target.'},
    44: {'value': '', 'suffix': '', 'odds': '30,50', 'desc': 'After skills, heal (4% Max HP + 40% ATK); on taking ATK DMG, {1} chance for +1 Rage.', 'descIdl': 'Setelah skill, pulihkan (4% HP Maks + 40% ATK); tiap kena DMG ATK ada {1} peluang +1 Rage.'},
    45: {'value': '40,80', 'suffix': '%', 'odds': '', 'desc': 'First 5 rounds: {0} DMG Reduction; then DMG taken +50% until battle end.', 'descIdl': '5 ronde pertama: {0} DMG Reduction; lalu DMG diterima +50% sampai akhir battle.'},
    46: {'value': '10,25', 'suffix': '%', 'odds': '', 'desc': "On new target: extra {0} target Max HP True DMG + Shield 40% of it (once per target).", 'descIdl': 'Saat target baru: ekstra {0} HP Maks target True DMG + Perisai 40% (sekali per target).'},
    47: {'value': '50,100', 'suffix': '%', 'odds': '', 'desc': 'On kill, {0} ATK True DMG to 8 enemies within 2 tiles.', 'descIdl': 'Saat membunuh, {0} ATK True DMG ke 8 musuh dalam 2 kotak.'},
    48: {'value': '20,50', 'suffix': '%', 'odds': '', 'desc': 'Basic attack picks nearest in range; new target takes +{0} DMG.', 'descIdl': 'Normal ATK pilih target terdekat; target baru kena +{0} DMG.'},
    49: {'value': '10,20', 'suffix': '%', 'odds': '', 'desc': 'ATK +{0}; 30% chance +1% ATK after first attack each round, unlimited stack.', 'descIdl': 'ATK +{0}; 30% peluang +1% ATK setelah ATK pertama tiap ronde, stack tanpa batas.'},
    50: {'value': '0,0', 'suffix': '%', 'odds': '0,0', 'desc': 'Max HP +{0}, DMG Reduction +{1}; one grows +1% per recast, up to 50 recasts.', 'descIdl': 'HP Maks +{0}, DMG Reduction +{1}; salah satu +1% tiap recast, maks 50x.'},
    51: {'value': '0,0', 'suffix': '%', 'odds': '0,0', 'desc': 'ATK +{0}, Leech +{1}; one grows +1% per recast, up to 50 recasts.', 'descIdl': 'ATK +{0}, Leech +{1}; salah satu +1% tiap recast, maks 50x.'},
  };

  /// Exclusive gear 6101-6124 — one per soldier sub-type, Smithy Lv.10 / 18.
  /// `effects` is the full re-roll pool from equipBase.effect; `random` is
  /// the "lo,hi" count actually rolled (0 indexed id in the pipe list is
  /// always the fixed part, the rest are candidates). `skillIntensify` is
  /// `"<skillId>,<level>"` — the fixed boost to the sub-type's active skill.
  static const List<Map<String, dynamic>> EXCLUSIVE_EQUIPMENT = [
    {'id': 6101, 'name': 'Spear', 'nameIdl': 'Tombak', 'pawn': 3101, 'subtype': 'longspearman', 'effects': <int>[21, 22, 15, 3, 5, 19, 20, 34, 11, 8], 'random': '1,4', 'skillIntensify': '201,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6102, 'name': 'Lance', 'nameIdl': 'Lance', 'pawn': 3102, 'subtype': 'lancer', 'effects': <int>[21, 22, 14, 36, 7, 5, 19, 11, 8], 'random': '1,6', 'skillIntensify': '202,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6103, 'name': 'Dagger-axe', 'nameIdl': 'Kapak Belati', 'pawn': 3103, 'subtype': 'dagger_axe', 'effects': <int>[21, 22, 14, 3, 17, 9, 36, 7, 15, 11], 'random': '1,6', 'skillIntensify': '203,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6104, 'name': 'Wood Shield', 'nameIdl': 'Perisai Kayu', 'pawn': 3201, 'subtype': 'saber_shield', 'effects': <int>[21, 22, 23, 4, 2, 26, 18, 29, 16], 'random': '2,6', 'skillIntensify': '204,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6105, 'name': 'Heavy Shield', 'nameIdl': 'Perisai Berat', 'pawn': 3202, 'subtype': 'heavy_shield', 'effects': <int>[21, 22, 4, 35, 37, 2, 12, 30, 16], 'random': '2,6', 'skillIntensify': '205,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6106, 'name': 'Longbow', 'nameIdl': 'Busur Panjang', 'pawn': 3301, 'subtype': 'longbowman', 'effects': <int>[21, 22, 15, 14, 3, 36, 7, 9, 11], 'random': '1,6', 'skillIntensify': '206,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6107, 'name': 'Crossbow', 'nameIdl': 'Busur Silang', 'pawn': 3302, 'subtype': 'crossbowman', 'effects': <int>[21, 22, 15, 14, 3, 17, 36, 9, 11], 'random': '1,6', 'skillIntensify': '207,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6108, 'name': 'Great Sword', 'nameIdl': 'Pedang Besar', 'pawn': 3401, 'subtype': 'sword_cavalry', 'effects': <int>[21, 22, 15, 3, 7, 5, 20, 34, 16, 11], 'random': '1,6', 'skillIntensify': '208,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6109, 'name': 'Halberd', 'nameIdl': 'Ji Panjang', 'pawn': 3402, 'subtype': 'spear_cavalry', 'effects': <int>[21, 22, 3, 5, 20, 19, 12, 34, 16], 'random': '1,4', 'skillIntensify': '209,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6110, 'name': 'Long Spear', 'nameIdl': 'Tombak Panjang', 'pawn': 3203, 'subtype': 'spear_shield', 'effects': <int>[21, 22, 24, 4, 15, 3, 9, 34, 16], 'random': '2,4', 'skillIntensify': '212,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6111, 'name': 'Toxibow', 'nameIdl': 'Busur Racun', 'pawn': 3303, 'subtype': 'toxibowman', 'effects': <int>[21, 22, 15, 14, 3, 17, 36, 9, 11], 'random': '1,6', 'skillIntensify': '210,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6112, 'name': "Hunter's Bow", 'nameIdl': 'Busur Pemburu', 'pawn': 3304, 'subtype': 'hunter', 'effects': <int>[21, 22, 35, 15, 14, 3, 17, 9, 11], 'random': '1,6', 'skillIntensify': '214,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6113, 'name': 'Guandao', 'nameIdl': 'Guan Dao', 'pawn': 3403, 'subtype': 'broadsword_cavalry', 'effects': <int>[21, 22, 15, 9, 5, 19, 34, 16, 11], 'random': '1,6', 'skillIntensify': '211,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6114, 'name': 'Sledge Hammer', 'nameIdl': 'Palu Godam', 'pawn': 3404, 'subtype': 'heavy_cavalry', 'effects': <int>[21, 22, 25, 4, 15, 12, 26, 34, 16], 'random': '2,6', 'skillIntensify': '213,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6115, 'name': 'Modao Saber', 'nameIdl': 'Pedang Modao', 'pawn': 3104, 'subtype': 'modao', 'effects': <int>[22, 3, 17, 9, 5, 19, 34, 11, 8], 'random': '1,6', 'skillIntensify': '108,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6116, 'name': 'Iron Hammer', 'nameIdl': 'Palu Besi', 'pawn': 3204, 'subtype': 'hammer_shield', 'effects': <int>[21, 22, 4, 3, 9, 2, 26, 8, 16], 'random': '2,6', 'skillIntensify': '215,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6117, 'name': 'Improved Crossbow', 'nameIdl': 'Busur Kuat', 'pawn': 3305, 'subtype': 'improved_crossbowman', 'effects': <int>[21, 22, 14, 3, 36, 7, 9, 11], 'random': '1,6', 'skillIntensify': '112,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6118, 'name': 'Two-handed Sword', 'nameIdl': 'Pedang Dua Tangan', 'pawn': 3105, 'subtype': 'long_swordsman', 'effects': <int>[21, 22, 3, 17, 9, 20, 19, 34, 8], 'random': '2,4', 'skillIntensify': '216,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6119, 'name': 'Recurve Bow', 'nameIdl': 'Busur Rekurve', 'pawn': 3405, 'subtype': 'bow_cavalry', 'effects': <int>[21, 22, 14, 3, 17, 36, 9, 11, 28], 'random': '1,6', 'skillIntensify': '217,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6120, 'name': 'Sword&Shield', 'nameIdl': 'Pedang Perisai', 'pawn': 3205, 'subtype': 'sword_shield', 'effects': <int>[21, 22, 14, 17, 9, 20, 12, 11], 'random': '2,4', 'skillIntensify': '218,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6121, 'name': 'Mountain Splitting Axe', 'nameIdl': 'Kapak Pembelah Gunung', 'pawn': 3406, 'subtype': 'axe_cavalry', 'effects': <int>[21, 22, 3, 5, 19, 12, 26, 34, 16], 'random': '2,4', 'skillIntensify': '117,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6122, 'name': 'Double Halberds', 'nameIdl': 'Tombak Ganda', 'pawn': 3106, 'subtype': 'twin_spearman', 'effects': <int>[21, 22, 15, 3, 17, 9, 7, 5, 34], 'random': '1,4', 'skillIntensify': '219,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6123, 'name': 'Bow of Fire', 'nameIdl': 'Busur Api', 'pawn': 3306, 'subtype': 'fire_bowman', 'effects': <int>[21, 22, 15, 14, 3, 17, 36, 9, 11], 'random': '1,6', 'skillIntensify': '220,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
    {'id': 6124, 'name': 'Axe&Shield', 'nameIdl': 'Kapak & Perisai', 'pawn': 3206, 'subtype': 'axe_shield', 'effects': <int>[21, 22, 4, 3, 9, 2, 26, 8, 16], 'random': '1,4', 'skillIntensify': '221,1', 'needLv': <int>[10, 18], 'cost': {'wood': 869, 'stone': 869, 'iron': 12}, 'forgeTime': 2287},
  ];

  /// Smithy level needed for the common tier a piece belongs to.
  static int equipmentSmithyLevel(Map<String, dynamic> item) {
    final need = (item['needLv'] as List?) ?? const [];
    return need.isEmpty ? 1 : (need.first as int);
  }

  /// Unlock tier ladder seen in needLv: 1, 3, 5, 7, 12, 14.
  static const List<int> EQUIP_TIERS = [1, 3, 5, 7, 12, 14];

  /// Rolls one value out of a "lo,hi" string. Reuses the same behaviour as
  /// the old bracket format so callers keep working.
  static String equiRollRange(String raw) {
    if (raw.isEmpty) return '0,0';
    return raw;
  }

  /// Common piece lookup by its numeric id as a string ("6003").
  static Map<String, dynamic>? equipById(String id) {
    for (final e in EQUIP_MASTER) {
      if ('${e['id']}' == id) return e;
    }
    return null;
  }

  /// Exclusive piece lookup by its numeric id as a string ("6101").
  static Map<String, dynamic>? exclusiveById(String id) {
    for (final e in EXCLUSIVE_EQUIPMENT) {
      if ('${e['id']}' == id) return e;
    }
    return null;
  }

  /// Human-readable effect summary for a common piece, resolving the
  /// equipEffect ids assigned to it into their rolled `[lo-hi]` ranges.
  static String equipEffectText(Map<String, dynamic> item, {bool idl = false}) {
    final ids = ((item['effects'] as List?) ?? const []).cast<int>();
    if (ids.isEmpty) return idl ? 'Hanya atribut dasar.' : 'Base attributes only.';
    final parts = <String>[];
    for (final eid in ids) {
      final eff = EQUIP_EFFECTS[eid];
      if (eff == null) continue;
      final raw = (idl ? eff['descIdl'] : eff['desc']) as String;
      parts.add(_fillEffect(
        raw,
        (eff['value'] as String?) ?? '',
        (eff['odds'] as String?) ?? '',
        (eff['suffix'] as String?) ?? '',
      ));
    }
    return parts.join(' ');
  }

  static String _fillEffect(String raw, String value, String odds, String suffix) {
    String fmt(String range) {
      if (range.isEmpty) return '—';
      final p = range.split(',');
      if (p.length != 2) return range;
      return p[0] == p[1] ? '${p[0]}$suffix' : '[${p[0]}-${p[1]}]$suffix';
    }
    return raw.replaceAll('{0}', fmt(value)).replaceAll('{1}', fmt(odds));
  }

  /// Effect text for a single equipEffect id.
  static String equipRolledEffectText(int effectId, {bool idl = false}) {
    final eff = EQUIP_EFFECTS[effectId];
    if (eff == null) return '';
    return _fillEffect(
      (idl ? eff['descIdl'] : eff['desc']) as String,
      (eff['value'] as String?) ?? '',
      (eff['odds'] as String?) ?? '',
      (eff['suffix'] as String?) ?? '',
    );
  }

  /// Rolls a single integer inside a "lo,hi" pair (inclusive).
  static int rollPair(String raw, math.Random rng) {
    final p = raw.split(',');
    if (p.length != 2) return 0;
    final lo = int.tryParse(p[0]) ?? 0;
    final hi = int.tryParse(p[1]) ?? lo;
    if (hi <= lo) return lo;
    return lo + rng.nextInt(hi - lo + 1);
  }

  /// Active-skill damage multipliers, straight from pawnSkill.json.
  /// Each sub-type's active skill has 6 levels (20101..20106); every family
  /// grows linearly, so one base + step pair reproduces all six rows exactly.
  /// Families whose pawnSkill row has no `value` are flat 0 (Shield,
  /// Shield Stance, Poison Arrow, Inspire) — their damage comes from elsewhere.
  static const Map<int, Map<String, num>> ACTIVE_SKILL_SCALE = {
    201: {'base': 1.00, 'step': 0.10}, // Stab
    202: {'base': 0.70, 'step': 0.10}, // Project
    203: {'base': 1.00, 'step': 0.05}, // Disarm
    204: {'base': 0.0, 'step': 0.0},   // Shield
    205: {'base': 0.0, 'step': 0.0},   // Shield Stance
    206: {'base': 0.50, 'step': 0.10}, // Scatter
    207: {'base': 0.45, 'step': 0.05}, // Rapid Fire
    208: {'base': 1.00, 'step': 0.05}, // Leap Slash
    209: {'base': 0.45, 'step': 0.05}, // Sweep
    210: {'base': 0.0, 'step': 0.0},   // Poison Arrow
    211: {'base': 0.20, 'step': 0.02}, // Chop
    212: {'base': 1.00, 'step': 0.05}, // Charge
    213: {'base': 0.75, 'step': 0.05}, // Collide
    214: {'base': 0.0, 'step': 0.0},   // Inspire
    215: {'base': 50.0, 'step': 10.0}, // Earthshaker (flat DMG, not a multiplier)
    216: {'base': 0.45, 'step': 0.05}, // Whirlwind
    217: {'base': 0.30, 'step': 0.10}, // Equestrian Archery
    218: {'base': 1.00, 'step': 0.05}, // Guardian Sword
    219: {'base': 25.0, 'step': 5.0},  // Unbridled Dance (flat DMG)
    220: {'base': 0.55, 'step': 0.05}, // Fire Arrow
    221: {'base': 0.75, 'step': 0.05}, // Whirling Axe
  };

  /// Active skill family (201..221) for a pawnBase id, read from its Lv.1
  /// skill list in SOLDIER_COMBAT (the only entry >= 20000).
  static int? activeSkillFamily(String pawnId) {
    for (final u in SOLDIER_COMBAT) {
      if (u['id'] != pawnId) continue;
      final levels = (u['levels'] as List).cast<Map<String, dynamic>>();
      for (final row in levels) {
        for (final s in (row['skills'] as List).cast<int>()) {
          if (s >= 20000) return s ~/ 100;
        }
      }
    }
    return null;
  }

  /// Damage multiplier of a pawn's active skill at a given soldier level
  /// (1..6). Flat-DMG families (Earthshaker, Unbridled Dance) return 1.0
  /// here because their value is an absolute number, not a multiplier.
  static double activeSkillMultiplier(String pawnId, {int level = 1}) {
    final family = activeSkillFamily(pawnId);
    if (family == null) return 1.0;
    final scale = ACTIVE_SKILL_SCALE[family];
    if (scale == null) return 1.0;
    final base = (scale['base'] as num).toDouble();
    if (base >= 20) return 1.0; // flat-damage family, not a multiplier
    final step = (scale['step'] as num).toDouble();
    return base + step * (level.clamp(1, 6) - 1);
  }

  /// Absolute DMG of a flat-damage active skill (Earthshaker / Unbridled
  /// Dance), or 0 when the family scales as a multiplier instead.
  static int activeSkillFlatDamage(String pawnId, {int level = 1}) {
    final family = activeSkillFamily(pawnId);
    if (family == null) return 0;
    final scale = ACTIVE_SKILL_SCALE[family];
    if (scale == null) return 0;
    final base = (scale['base'] as num).toDouble();
    if (base < 20) return 0;
    final step = (scale['step'] as num).toDouble();
    return (base + step * (level.clamp(1, 6) - 1)).round();
  }

  /// Extra DMG % on a pawn's active skill granted by an exclusive piece's
  /// `skill_intensify` (`"<family>,<levels>"`). The intensify raises the skill
  /// that many levels, so the bonus is the resulting relative gain.
  static double exclusiveSkillBonusPct(String pawnId, int levels) {
    if (levels <= 0) return 0;
    final family = activeSkillFamily(pawnId);
    if (family == null) return 0;
    final scale = ACTIVE_SKILL_SCALE[family];
    if (scale == null) return 0;
    final base = (scale['base'] as num).toDouble();
    if (base < 20) {
      // Multiplier family: relative gain from bumping the level.
      final at = activeSkillMultiplier(pawnId, level: 1);
      final up = activeSkillMultiplier(pawnId, level: 1 + levels);
      if (at <= 0) return 0;
      return (up / at) - 1;
    }
    // Flat-damage family: gain relative to the level-1 flat value.
    final at = activeSkillFlatDamage(pawnId, level: 1);
    final up = activeSkillFlatDamage(pawnId, level: 1 + levels);
    if (at <= 0) return 0;
    return (up / at) - 1;
  }

  // ---- COMBAT DATA — diekstrak dari pawnBase.json + pawnAttr.json
  // (data in-game, authoritative). Id = pawnBase id, levels = pawnAttr rows.
  // type: spear > cavalry > shield > bow > spear (counter wheel).
  static const List<Map<String, dynamic>> SOLDIER_COMBAT = [
    {
      'id': '3101',
      'name': "Longspearman",
      'type': 'spear',
      'levels': [
        {'lv': 1, 'hp': 135, 'atk': 10, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20101]},
        {'lv': 2, 'hp': 167, 'atk': 12, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20102]},
        {'lv': 3, 'hp': 207, 'atk': 15, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20103]},
        {'lv': 4, 'hp': 257, 'atk': 19, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20104]},
        {'lv': 5, 'hp': 319, 'atk': 24, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20105]},
        {'lv': 6, 'hp': 396, 'atk': 30, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20106]},
      ],
    },
    {
      'id': '3102',
      'name': "Lancer",
      'type': 'spear',
      'levels': [
        {'lv': 1, 'hp': 104, 'atk': 12, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20201]},
        {'lv': 2, 'hp': 129, 'atk': 15, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20202]},
        {'lv': 3, 'hp': 160, 'atk': 19, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20203]},
        {'lv': 4, 'hp': 198, 'atk': 24, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20204]},
        {'lv': 5, 'hp': 246, 'atk': 30, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20205]},
        {'lv': 6, 'hp': 305, 'atk': 37, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20206]},
      ],
    },
    {
      'id': '3103',
      'name': "Dagger-axe Soldier",
      'type': 'spear',
      'levels': [
        {'lv': 1, 'hp': 88, 'atk': 8, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20301]},
        {'lv': 2, 'hp': 109, 'atk': 10, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20302]},
        {'lv': 3, 'hp': 135, 'atk': 12, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20303]},
        {'lv': 4, 'hp': 167, 'atk': 15, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20304]},
        {'lv': 5, 'hp': 207, 'atk': 19, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20305]},
        {'lv': 6, 'hp': 257, 'atk': 24, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20306]},
      ],
    },
    {
      'id': '3104',
      'name': "Modao Soldier",
      'type': 'spear',
      'levels': [
        {'lv': 1, 'hp': 94, 'atk': 3, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10801, 11001]},
        {'lv': 2, 'hp': 117, 'atk': 4, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10802, 11001]},
        {'lv': 3, 'hp': 145, 'atk': 5, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10803, 11001]},
        {'lv': 4, 'hp': 180, 'atk': 6, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10804, 11001]},
        {'lv': 5, 'hp': 223, 'atk': 7, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10805, 11001]},
        {'lv': 6, 'hp': 277, 'atk': 9, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10806, 11001]},
      ],
    },
    {
      'id': '3105',
      'name': "Long Swordsman",
      'type': 'spear',
      'levels': [
        {'lv': 1, 'hp': 208, 'atk': 9, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21601]},
        {'lv': 2, 'hp': 258, 'atk': 11, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21602]},
        {'lv': 3, 'hp': 320, 'atk': 14, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21603]},
        {'lv': 4, 'hp': 397, 'atk': 17, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21604]},
        {'lv': 5, 'hp': 492, 'atk': 21, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21605]},
        {'lv': 6, 'hp': 610, 'atk': 26, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21606]},
      ],
    },
    {
      'id': '3106',
      'name': "Twin Spearman",
      'type': 'spear',
      'levels': [
        {'lv': 1, 'hp': 125, 'atk': 11, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21901]},
        {'lv': 2, 'hp': 155, 'atk': 14, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21902]},
        {'lv': 3, 'hp': 192, 'atk': 17, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21903]},
        {'lv': 4, 'hp': 238, 'atk': 21, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21904]},
        {'lv': 5, 'hp': 295, 'atk': 26, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21905]},
        {'lv': 6, 'hp': 366, 'atk': 32, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21906]},
      ],
    },
    {
      'id': '3201',
      'name': "Saber&Shield Soldier",
      'type': 'shield',
      'levels': [
        {'lv': 1, 'hp': 265, 'atk': 6, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20401]},
        {'lv': 2, 'hp': 326, 'atk': 7, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20402]},
        {'lv': 3, 'hp': 401, 'atk': 9, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20403]},
        {'lv': 4, 'hp': 493, 'atk': 11, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20404]},
        {'lv': 5, 'hp': 606, 'atk': 14, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20405]},
        {'lv': 6, 'hp': 745, 'atk': 17, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20406]},
      ],
    },
    {
      'id': '3202',
      'name': "Heavy Shield Soldier",
      'type': 'shield',
      'levels': [
        {'lv': 1, 'hp': 318, 'atk': 4, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20501]},
        {'lv': 2, 'hp': 391, 'atk': 5, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20502]},
        {'lv': 3, 'hp': 481, 'atk': 6, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20503]},
        {'lv': 4, 'hp': 592, 'atk': 7, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20504]},
        {'lv': 5, 'hp': 728, 'atk': 9, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20505]},
        {'lv': 6, 'hp': 895, 'atk': 11, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20506]},
      ],
    },
    {
      'id': '3203',
      'name': "Spear&Shield Soldier",
      'type': 'shield',
      'levels': [
        {'lv': 1, 'hp': 278, 'atk': 5, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21201]},
        {'lv': 2, 'hp': 342, 'atk': 7, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21202]},
        {'lv': 3, 'hp': 421, 'atk': 9, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21203]},
        {'lv': 4, 'hp': 518, 'atk': 11, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21204]},
        {'lv': 5, 'hp': 637, 'atk': 13, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21205]},
        {'lv': 6, 'hp': 784, 'atk': 15, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21206]},
      ],
    },
    {
      'id': '3204',
      'name': "Hammer&Shield Soldier",
      'type': 'shield',
      'levels': [
        {'lv': 1, 'hp': 239, 'atk': 5, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21501]},
        {'lv': 2, 'hp': 294, 'atk': 6, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21502]},
        {'lv': 3, 'hp': 362, 'atk': 7, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21503]},
        {'lv': 4, 'hp': 445, 'atk': 9, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21504]},
        {'lv': 5, 'hp': 547, 'atk': 11, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21505]},
        {'lv': 6, 'hp': 673, 'atk': 14, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21506]},
      ],
    },
    {
      'id': '3205',
      'name': "Sword&Shield Soldier",
      'type': 'shield',
      'levels': [
        {'lv': 1, 'hp': 159, 'atk': 3, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11401, 21801]},
        {'lv': 2, 'hp': 194, 'atk': 4, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11402, 21802]},
        {'lv': 3, 'hp': 237, 'atk': 5, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11403, 21803]},
        {'lv': 4, 'hp': 289, 'atk': 6, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11404, 21804]},
        {'lv': 5, 'hp': 353, 'atk': 7, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11405, 21805]},
        {'lv': 6, 'hp': 431, 'atk': 8, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11406, 21806]},
      ],
    },
    {
      'id': '3206',
      'name': "Axe&Shield Soldier",
      'type': 'shield',
      'levels': [
        {'lv': 1, 'hp': 212, 'atk': 10, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22101, 11901]},
        {'lv': 2, 'hp': 261, 'atk': 14, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22102, 11902]},
        {'lv': 3, 'hp': 321, 'atk': 18, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22103, 11903]},
        {'lv': 4, 'hp': 395, 'atk': 22, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22104, 11904]},
        {'lv': 5, 'hp': 486, 'atk': 26, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22105, 11905]},
        {'lv': 6, 'hp': 598, 'atk': 30, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22106, 11906]},
      ],
    },
    {
      'id': '3301',
      'name': "Longbowman",
      'type': 'bow',
      'levels': [
        {'lv': 1, 'hp': 78, 'atk': 7, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20601]},
        {'lv': 2, 'hp': 86, 'atk': 9, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20602]},
        {'lv': 3, 'hp': 95, 'atk': 11, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20603]},
        {'lv': 4, 'hp': 105, 'atk': 13, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20604]},
        {'lv': 5, 'hp': 116, 'atk': 15, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20605]},
        {'lv': 6, 'hp': 128, 'atk': 17, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20606]},
      ],
    },
    {
      'id': '3302',
      'name': "Crossbowman",
      'type': 'bow',
      'levels': [
        {'lv': 1, 'hp': 117, 'atk': 6, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20701]},
        {'lv': 2, 'hp': 138, 'atk': 7, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20702]},
        {'lv': 3, 'hp': 163, 'atk': 8, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20703]},
        {'lv': 4, 'hp': 192, 'atk': 10, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20704]},
        {'lv': 5, 'hp': 227, 'atk': 12, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20705]},
        {'lv': 6, 'hp': 268, 'atk': 14, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20706]},
      ],
    },
    {
      'id': '3303',
      'name': "Toxibowman",
      'type': 'bow',
      'levels': [
        {'lv': 1, 'hp': 76, 'atk': 5, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21001]},
        {'lv': 2, 'hp': 84, 'atk': 6, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21002]},
        {'lv': 3, 'hp': 92, 'atk': 7, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21003]},
        {'lv': 4, 'hp': 101, 'atk': 8, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21004]},
        {'lv': 5, 'hp': 111, 'atk': 9, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21005]},
        {'lv': 6, 'hp': 122, 'atk': 10, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21006]},
      ],
    },
    {
      'id': '3304',
      'name': "Hunter",
      'type': 'bow',
      'levels': [
        {'lv': 1, 'hp': 94, 'atk': 7, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21401]},
        {'lv': 2, 'hp': 103, 'atk': 8, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21402]},
        {'lv': 3, 'hp': 113, 'atk': 9, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21403]},
        {'lv': 4, 'hp': 124, 'atk': 10, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21404]},
        {'lv': 5, 'hp': 136, 'atk': 11, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21405]},
        {'lv': 6, 'hp': 150, 'atk': 12, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21406]},
      ],
    },
    {
      'id': '3305',
      'name': "Improved Crossbowman",
      'type': 'bow',
      'levels': [
        {'lv': 1, 'hp': 55, 'atk': 15, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11201]},
        {'lv': 2, 'hp': 58, 'atk': 19, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11202]},
        {'lv': 3, 'hp': 61, 'atk': 23, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11203]},
        {'lv': 4, 'hp': 64, 'atk': 27, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11204]},
        {'lv': 5, 'hp': 67, 'atk': 32, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11205]},
        {'lv': 6, 'hp': 70, 'atk': 38, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11206]},
      ],
    },
    {
      'id': '3306',
      'name': "Fire Bowman",
      'type': 'bow',
      'levels': [
        {'lv': 1, 'hp': 78, 'atk': 6, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22001, 11801]},
        {'lv': 2, 'hp': 86, 'atk': 7, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22002, 11801]},
        {'lv': 3, 'hp': 95, 'atk': 8, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22003, 11801]},
        {'lv': 4, 'hp': 105, 'atk': 9, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22004, 11801]},
        {'lv': 5, 'hp': 116, 'atk': 10, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22005, 11801]},
        {'lv': 6, 'hp': 128, 'atk': 11, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22006, 11801]},
      ],
    },
    {
      'id': '3401',
      'name': "Sword Cavalry",
      'type': 'cavalry',
      'levels': [
        {'lv': 1, 'hp': 155, 'atk': 14, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20801]},
        {'lv': 2, 'hp': 194, 'atk': 18, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20802]},
        {'lv': 3, 'hp': 243, 'atk': 23, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20803]},
        {'lv': 4, 'hp': 304, 'atk': 29, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20804]},
        {'lv': 5, 'hp': 380, 'atk': 36, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20805]},
        {'lv': 6, 'hp': 475, 'atk': 43, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20806]},
      ],
    },
    {
      'id': '3402',
      'name': "Spear Cavalry",
      'type': 'cavalry',
      'levels': [
        {'lv': 1, 'hp': 186, 'atk': 10, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20901]},
        {'lv': 2, 'hp': 233, 'atk': 13, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20902]},
        {'lv': 3, 'hp': 291, 'atk': 16, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20903]},
        {'lv': 4, 'hp': 364, 'atk': 20, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20904]},
        {'lv': 5, 'hp': 455, 'atk': 25, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20905]},
        {'lv': 6, 'hp': 569, 'atk': 31, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20906]},
      ],
    },
    {
      'id': '3403',
      'name': "Broadsword Cavalry",
      'type': 'cavalry',
      'levels': [
        {'lv': 1, 'hp': 126, 'atk': 18, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21101]},
        {'lv': 2, 'hp': 157, 'atk': 23, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21102]},
        {'lv': 3, 'hp': 197, 'atk': 29, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21103]},
        {'lv': 4, 'hp': 246, 'atk': 36, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21104]},
        {'lv': 5, 'hp': 308, 'atk': 44, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21105]},
        {'lv': 6, 'hp': 386, 'atk': 53, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21106]},
      ],
    },
    {
      'id': '3404',
      'name': "Heavy Cavalry",
      'type': 'cavalry',
      'levels': [
        {'lv': 1, 'hp': 256, 'atk': 7, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21301]},
        {'lv': 2, 'hp': 320, 'atk': 9, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21302]},
        {'lv': 3, 'hp': 400, 'atk': 11, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21303]},
        {'lv': 4, 'hp': 500, 'atk': 14, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21304]},
        {'lv': 5, 'hp': 625, 'atk': 18, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21305]},
        {'lv': 6, 'hp': 781, 'atk': 23, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21306]},
      ],
    },
    {
      'id': '3405',
      'name': "Bow Cavalry",
      'type': 'cavalry',
      'levels': [
        {'lv': 1, 'hp': 93, 'atk': 8, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21701]},
        {'lv': 2, 'hp': 112, 'atk': 10, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21702]},
        {'lv': 3, 'hp': 134, 'atk': 12, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21703]},
        {'lv': 4, 'hp': 161, 'atk': 14, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21704]},
        {'lv': 5, 'hp': 193, 'atk': 16, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21705]},
        {'lv': 6, 'hp': 232, 'atk': 18, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21706]},
      ],
    },
    {
      'id': '3406',
      'name': "Axe Cavalry",
      'type': 'cavalry',
      'levels': [
        {'lv': 1, 'hp': 202, 'atk': 9, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11601, 11701]},
        {'lv': 2, 'hp': 253, 'atk': 11, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11602, 11702]},
        {'lv': 3, 'hp': 316, 'atk': 14, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11603, 11703]},
        {'lv': 4, 'hp': 395, 'atk': 17, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11604, 11704]},
        {'lv': 5, 'hp': 494, 'atk': 21, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11605, 11705]},
        {'lv': 6, 'hp': 618, 'atk': 26, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11606, 11706]},
      ],
    },
    {
      'id': '3501',
      'name': "Catapult",
      'type': 'weaponry',
      'levels': [
        {'lv': 1, 'hp': 50, 'atk': 15, 'range': 5, 'move': 1, 'rage': 0, 'initRage': 0, 'skills': [10105]},
      ],
    },
    {
      'id': '3502',
      'name': "Trebuchet",
      'type': 'weaponry',
      'levels': [
        {'lv': 1, 'hp': 50, 'atk': 18, 'range': 5, 'move': 1, 'rage': 0, 'initRage': 0, 'skills': [12301, 12401]},
      ],
    },
  ];

  static const List<Map<String, dynamic>> ENEMY_COMBAT = [
    {
      'id': '4101',
      'name': "Boar",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 25, 'atk': 13, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101]},
        {'lv': 2, 'hp': 50, 'atk': 15, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101]},
        {'lv': 3, 'hp': 101, 'atk': 17, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101]},
        {'lv': 4, 'hp': 201, 'atk': 20, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101]},
        {'lv': 5, 'hp': 301, 'atk': 24, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101]},
        {'lv': 6, 'hp': 404, 'atk': 28, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101]},
      ],
    },
    {
      'id': '4102',
      'name': "Wolf",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 30, 'atk': 14, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201]},
        {'lv': 2, 'hp': 60, 'atk': 17, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201]},
        {'lv': 3, 'hp': 123, 'atk': 20, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201]},
        {'lv': 4, 'hp': 243, 'atk': 23, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201]},
        {'lv': 5, 'hp': 363, 'atk': 26, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201]},
        {'lv': 6, 'hp': 483, 'atk': 29, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201]},
      ],
    },
    {
      'id': '4103',
      'name': "Bear",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 227, 'atk': 21, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401]},
        {'lv': 2, 'hp': 303, 'atk': 23, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401]},
        {'lv': 3, 'hp': 368, 'atk': 25, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401]},
        {'lv': 4, 'hp': 708, 'atk': 32, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401]},
        {'lv': 5, 'hp': 748, 'atk': 34, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401]},
        {'lv': 6, 'hp': 788, 'atk': 36, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401]},
      ],
    },
    {
      'id': '4104',
      'name': "Lion",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 243, 'atk': 16, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501]},
        {'lv': 2, 'hp': 328, 'atk': 18, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501]},
        {'lv': 3, 'hp': 394, 'atk': 20, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501]},
        {'lv': 4, 'hp': 732, 'atk': 28, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501]},
        {'lv': 5, 'hp': 772, 'atk': 30, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501]},
        {'lv': 6, 'hp': 812, 'atk': 32, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501]},
      ],
    },
    {
      'id': '4105',
      'name': "Hedgehog",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 124, 'atk': 17, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501]},
        {'lv': 2, 'hp': 208, 'atk': 20, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501]},
        {'lv': 3, 'hp': 302, 'atk': 23, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501]},
        {'lv': 4, 'hp': 622, 'atk': 26, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501]},
        {'lv': 5, 'hp': 643, 'atk': 28, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501]},
        {'lv': 6, 'hp': 664, 'atk': 30, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501]},
      ],
    },
    {
      'id': '4106',
      'name': "Skunk",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 145, 'atk': 16, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101]},
        {'lv': 2, 'hp': 231, 'atk': 19, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101]},
        {'lv': 3, 'hp': 323, 'atk': 21, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101]},
        {'lv': 4, 'hp': 646, 'atk': 26, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101]},
        {'lv': 5, 'hp': 668, 'atk': 28, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101]},
        {'lv': 6, 'hp': 688, 'atk': 30, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101]},
      ],
    },
    {
      'id': '4107',
      'name': "Lizard",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 101, 'atk': 16, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601]},
        {'lv': 2, 'hp': 146, 'atk': 20, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601]},
        {'lv': 3, 'hp': 221, 'atk': 23, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601]},
        {'lv': 4, 'hp': 434, 'atk': 27, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601]},
        {'lv': 5, 'hp': 466, 'atk': 30, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601]},
        {'lv': 6, 'hp': 488, 'atk': 33, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601]},
      ],
    },
    {
      'id': '4108',
      'name': "Leopard",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 36, 'atk': 18, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701]},
        {'lv': 2, 'hp': 88, 'atk': 20, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701]},
        {'lv': 3, 'hp': 115, 'atk': 25, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701]},
        {'lv': 4, 'hp': 184, 'atk': 28, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701]},
        {'lv': 5, 'hp': 274, 'atk': 30, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701]},
        {'lv': 6, 'hp': 364, 'atk': 32, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701]},
      ],
    },
    {
      'id': '4109',
      'name': "Bumblebee",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 50, 'atk': 12, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11501]},
        {'lv': 2, 'hp': 85, 'atk': 14, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11501]},
        {'lv': 3, 'hp': 129, 'atk': 18, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11502]},
        {'lv': 4, 'hp': 215, 'atk': 24, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11502]},
        {'lv': 5, 'hp': 248, 'atk': 26, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11502]},
        {'lv': 6, 'hp': 301, 'atk': 28, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11503]},
      ],
    },
    {
      'id': '4110',
      'name': "Elephant",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 199, 'atk': 19, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201]},
        {'lv': 2, 'hp': 276, 'atk': 25, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201]},
        {'lv': 3, 'hp': 473, 'atk': 31, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201]},
        {'lv': 4, 'hp': 802, 'atk': 34, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201]},
        {'lv': 5, 'hp': 852, 'atk': 37, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201]},
        {'lv': 6, 'hp': 902, 'atk': 39, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201]},
      ],
    },
    {
      'id': '4111',
      'name': "Buffalo",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 188, 'atk': 20, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601]},
        {'lv': 2, 'hp': 352, 'atk': 24, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601]},
        {'lv': 3, 'hp': 402, 'atk': 27, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601]},
        {'lv': 4, 'hp': 562, 'atk': 30, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601]},
        {'lv': 5, 'hp': 725, 'atk': 33, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601]},
        {'lv': 6, 'hp': 811, 'atk': 37, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601]},
      ],
    },
    {
      'id': '4112',
      'name': "Tiger",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 170, 'atk': 22, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701]},
        {'lv': 2, 'hp': 286, 'atk': 25, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701]},
        {'lv': 3, 'hp': 359, 'atk': 28, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701]},
        {'lv': 4, 'hp': 511, 'atk': 30, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701]},
        {'lv': 5, 'hp': 648, 'atk': 35, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701]},
        {'lv': 6, 'hp': 718, 'atk': 40, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701]},
      ],
    },
    {
      'id': '4113',
      'name': "Rat",
      'type': 'beast',
      'levels': [
        {'lv': 7, 'hp': 887, 'atk': 45, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [12001, 12101]},
        {'lv': 8, 'hp': 1166, 'atk': 66, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [12001, 12101]},
      ],
    },
    {
      'id': '4114',
      'name': "Ape",
      'type': 'beast',
      'levels': [
        {'lv': 7, 'hp': 1004, 'atk': 115, 'range': 6, 'move': 0, 'rage': 6, 'initRage': 4, 'skills': [12001, 30801]},
        {'lv': 8, 'hp': 1002, 'atk': 88, 'range': 6, 'move': 0, 'rage': 6, 'initRage': 4, 'skills': [12001, 30801]},
      ],
    },
    {
      'id': '4115',
      'name': "Goat",
      'type': 'beast',
      'levels': [
        {'lv': 7, 'hp': 1166, 'atk': 69, 'range': 6, 'move': 0, 'rage': 8, 'initRage': 4, 'skills': [12001, 30901]},
        {'lv': 8, 'hp': 1213, 'atk': 76, 'range': 6, 'move': 0, 'rage': 8, 'initRage': 4, 'skills': [12001, 30901]},
      ],
    },
    {
      'id': '4116',
      'name': "Porcupine",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 51, 'atk': 12, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301]},
        {'lv': 2, 'hp': 91, 'atk': 16, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301]},
        {'lv': 3, 'hp': 182, 'atk': 20, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301]},
        {'lv': 4, 'hp': 271, 'atk': 23, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301]},
        {'lv': 5, 'hp': 342, 'atk': 26, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301]},
        {'lv': 6, 'hp': 503, 'atk': 29, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301]},
      ],
    },
    {
      'id': '4117',
      'name': "Viper",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 42, 'atk': 13, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401]},
        {'lv': 2, 'hp': 72, 'atk': 17, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401]},
        {'lv': 3, 'hp': 144, 'atk': 19, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401]},
        {'lv': 4, 'hp': 245, 'atk': 22, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401]},
        {'lv': 5, 'hp': 344, 'atk': 25, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401]},
        {'lv': 6, 'hp': 446, 'atk': 28, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401]},
      ],
    },
    {
      'id': '4118',
      'name': "Snapping Turtle",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 35, 'atk': 20, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501]},
        {'lv': 2, 'hp': 76, 'atk': 22, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501]},
        {'lv': 3, 'hp': 152, 'atk': 24, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501]},
        {'lv': 4, 'hp': 253, 'atk': 26, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501]},
        {'lv': 5, 'hp': 354, 'atk': 28, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501]},
        {'lv': 6, 'hp': 455, 'atk': 30, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501]},
      ],
    },
    {
      'id': '4119',
      'name': "Rhino",
      'type': 'beast',
      'levels': [
        {'lv': 1, 'hp': 207, 'atk': 20, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601]},
        {'lv': 2, 'hp': 348, 'atk': 22, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601]},
        {'lv': 3, 'hp': 489, 'atk': 24, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601]},
        {'lv': 4, 'hp': 580, 'atk': 26, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601]},
        {'lv': 5, 'hp': 671, 'atk': 28, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601]},
        {'lv': 6, 'hp': 712, 'atk': 30, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601]},
      ],
    },
    {
      'id': '4201',
      'name': "Minion",
      'type': 'bandit',
      'levels': [
        {'lv': 1, 'hp': 112, 'atk': 13, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 2, 'hp': 158, 'atk': 11, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 3, 'hp': 190, 'atk': 13, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 4, 'hp': 228, 'atk': 15, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 5, 'hp': 274, 'atk': 18, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 6, 'hp': 611, 'atk': 29, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 7, 'hp': 622, 'atk': 30, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 8, 'hp': 474, 'atk': 24, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 9, 'hp': 455, 'atk': 32, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 10, 'hp': 531, 'atk': 35, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
      ],
    },
    {
      'id': '4202',
      'name': "Bandit Saberman",
      'type': 'bandit',
      'levels': [
        {'lv': 1, 'hp': 125, 'atk': 16, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 2, 'hp': 175, 'atk': 11, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 3, 'hp': 210, 'atk': 13, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 4, 'hp': 252, 'atk': 16, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 5, 'hp': 302, 'atk': 19, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 6, 'hp': 625, 'atk': 31, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 7, 'hp': 663, 'atk': 37, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 8, 'hp': 521, 'atk': 28, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 9, 'hp': 521, 'atk': 37, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
        {'lv': 10, 'hp': 625, 'atk': 41, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': []},
      ],
    },
    {
      'id': '4203',
      'name': "Assassin",
      'type': 'bandit',
      'levels': [
        {'lv': 1, 'hp': 90, 'atk': 12, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
        {'lv': 2, 'hp': 108, 'atk': 14, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
        {'lv': 3, 'hp': 130, 'atk': 17, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
        {'lv': 4, 'hp': 156, 'atk': 20, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
        {'lv': 5, 'hp': 187, 'atk': 24, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
        {'lv': 6, 'hp': 533, 'atk': 37, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
        {'lv': 7, 'hp': 544, 'atk': 40, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
        {'lv': 8, 'hp': 323, 'atk': 32, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
        {'lv': 9, 'hp': 323, 'atk': 43, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
        {'lv': 10, 'hp': 388, 'atk': 48, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901]},
      ],
    },
    {
      'id': '4204',
      'name': "Bandit Bowman",
      'type': 'bandit',
      'levels': [
        {'lv': 1, 'hp': 80, 'atk': 7, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
        {'lv': 2, 'hp': 96, 'atk': 8, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
        {'lv': 3, 'hp': 115, 'atk': 10, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
        {'lv': 4, 'hp': 138, 'atk': 12, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
        {'lv': 5, 'hp': 166, 'atk': 14, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
        {'lv': 6, 'hp': 247, 'atk': 20, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
        {'lv': 7, 'hp': 344, 'atk': 26, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
        {'lv': 8, 'hp': 287, 'atk': 23, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
        {'lv': 9, 'hp': 344, 'atk': 26, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
        {'lv': 10, 'hp': 413, 'atk': 29, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301]},
      ],
    },
    {
      'id': '4205',
      'name': "Boar Knight",
      'type': 'bandit',
      'levels': [
        {'lv': 1, 'hp': 160, 'atk': 15, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
        {'lv': 2, 'hp': 194, 'atk': 18, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
        {'lv': 3, 'hp': 235, 'atk': 22, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
        {'lv': 4, 'hp': 284, 'atk': 27, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
        {'lv': 5, 'hp': 404, 'atk': 33, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
        {'lv': 6, 'hp': 737, 'atk': 70, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
        {'lv': 7, 'hp': 827, 'atk': 85, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
        {'lv': 8, 'hp': 609, 'atk': 58, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
        {'lv': 9, 'hp': 737, 'atk': 70, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
        {'lv': 10, 'hp': 892, 'atk': 85, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301]},
      ],
    },
    {
      'id': '4206',
      'name': "Soulreaper",
      'type': 'bandit',
      'levels': [
        {'lv': 9, 'hp': 827, 'atk': 88, 'range': 6, 'move': 0, 'rage': 6, 'initRage': 4, 'skills': [12001, 31001]},
        {'lv': 10, 'hp': 1034, 'atk': 110, 'range': 6, 'move': 0, 'rage': 6, 'initRage': 4, 'skills': [12001, 31001]},
      ],
    },
  ];

  // Skill id -> nama (pawnSkill.json -> pawnSkillText.json).
  static const Map<int, String> SKILL_NAMES = {
    10101: "Counter Cavalry",
    10102: "Counter Bowman",
    10103: "Counter Spearman",
    10104: "Counter Shield Soldier",
    10105: "Counter Building",
    10106: "Counter Shield Soldier",
    10201: "Counter Cavalry",
    10202: "Counter Bowman",
    10203: "Counter Spearman",
    10204: "Counter Shield Soldier",
    10206: "Counter Shield Soldier",
    10301: "Fortitude",
    10401: "Hunting",
    10501: "DMG Reflection",
    10601: "Scale Armor",
    10701: "Evade",
    10801: "Erratic Attack",
    10802: "Erratic Attack",
    10803: "Erratic Attack",
    10804: "Erratic Attack",
    10805: "Erratic Attack",
    10806: "Erratic Attack",
    10901: "Crit",
    11001: "Cavalry Suffer",
    11101: "Draw",
    11201: "Anchor",
    11202: "Anchor",
    11203: "Anchor",
    11204: "Anchor",
    11205: "Anchor",
    11206: "Anchor",
    11401: "Trainee Warrior",
    11402: "Trainee Warrior",
    11403: "Trainee Warrior",
    11404: "Trainee Warrior",
    11405: "Trainee Warrior",
    11406: "Trainee Warrior",
    11501: "Poison Thorn",
    11502: "Poison Thorn",
    11503: "Poison Thorn",
    11601: "Shattered Armor",
    11602: "Shattered Armor",
    11603: "Shattered Armor",
    11604: "Shattered Armor",
    11605: "Shattered Armor",
    11606: "Shattered Armor",
    11701: "Cleave",
    11702: "Cleave",
    11703: "Cleave",
    11704: "Cleave",
    11705: "Cleave",
    11706: "Cleave",
    11801: "Fire Intensity",
    11901: "Shield Bash",
    11902: "Shield Bash",
    11903: "Shield Bash",
    11904: "Shield Bash",
    11905: "Shield Bash",
    11906: "Shield Bash",
    12001: "Iron Mountain Stance",
    12101: "Pestilence Infection",
    12301: "Penetration",
    12401: "Recycle",
    20101: "Stab",
    20102: "Stab",
    20103: "Stab",
    20104: "Stab",
    20105: "Stab",
    20106: "Stab",
    20201: "Project",
    20202: "Project",
    20203: "Project",
    20204: "Project",
    20205: "Project",
    20206: "Project",
    20301: "Disarm",
    20302: "Disarm",
    20303: "Disarm",
    20304: "Disarm",
    20305: "Disarm",
    20306: "Disarm",
    20401: "Shield",
    20402: "Shield",
    20403: "Shield",
    20404: "Shield",
    20405: "Shield",
    20406: "Shield",
    20501: "Shield Stance",
    20502: "Shield Stance",
    20503: "Shield Stance",
    20504: "Shield Stance",
    20505: "Shield Stance",
    20506: "Shield Stance",
    20601: "Scatter",
    20602: "Scatter",
    20603: "Scatter",
    20604: "Scatter",
    20605: "Scatter",
    20606: "Scatter",
    20701: "Rapid Fire",
    20702: "Rapid Fire",
    20703: "Rapid Fire",
    20704: "Rapid Fire",
    20705: "Rapid Fire",
    20706: "Rapid Fire",
    20801: "Leap Slash",
    20802: "Leap Slash",
    20803: "Leap Slash",
    20804: "Leap Slash",
    20805: "Leap Slash",
    20806: "Leap Slash",
    20901: "Sweep",
    20902: "Sweep",
    20903: "Sweep",
    20904: "Sweep",
    20905: "Sweep",
    20906: "Sweep",
    21001: "Poison Arrow",
    21002: "Poison Arrow",
    21003: "Poison Arrow",
    21004: "Poison Arrow",
    21005: "Poison Arrow",
    21006: "Poison Arrow",
    21101: "Chop",
    21102: "Chop",
    21103: "Chop",
    21104: "Chop",
    21105: "Chop",
    21106: "Chop",
    21201: "Charge",
    21202: "Charge",
    21203: "Charge",
    21204: "Charge",
    21205: "Charge",
    21206: "Charge",
    21301: "Collide",
    21302: "Collide",
    21303: "Collide",
    21304: "Collide",
    21305: "Collide",
    21306: "Collide",
    21401: "Inspire",
    21402: "Inspire",
    21403: "Inspire",
    21404: "Inspire",
    21405: "Inspire",
    21406: "Inspire",
    21501: "Earthshaker",
    21502: "Earthshaker",
    21503: "Earthshaker",
    21504: "Earthshaker",
    21505: "Earthshaker",
    21506: "Earthshaker",
    21601: "Whirlwind",
    21602: "Whirlwind",
    21603: "Whirlwind",
    21604: "Whirlwind",
    21605: "Whirlwind",
    21606: "Whirlwind",
    21701: "Equestrian Archery",
    21702: "Equestrian Archery",
    21703: "Equestrian Archery",
    21704: "Equestrian Archery",
    21705: "Equestrian Archery",
    21706: "Equestrian Archery",
    21801: "Guardian Sword",
    21802: "Guardian Sword",
    21803: "Guardian Sword",
    21804: "Guardian Sword",
    21805: "Guardian Sword",
    21806: "Guardian Sword",
    21901: "Unbridled Dance",
    21902: "Unbridled Dance",
    21903: "Unbridled Dance",
    21904: "Unbridled Dance",
    21905: "Unbridled Dance",
    21906: "Unbridled Dance",
    22001: "Fire Arrow",
    22002: "Fire Arrow",
    22003: "Fire Arrow",
    22004: "Fire Arrow",
    22005: "Fire Arrow",
    22006: "Fire Arrow",
    22101: "Whirling Axe",
    22102: "Whirling Axe",
    22103: "Whirling Axe",
    22104: "Whirling Axe",
    22105: "Whirling Axe",
    22106: "Whirling Axe",
    30101: "Poisoning",
    30201: "Sling",
    30301: "Aim",
    30401: "Smash",
    30501: "Tear",
    30601: "Wild Collision",
    30701: "Gash",
    30801: "Fury",
    30901: "Rampant Charge",
    31001: "Frenzy Claw",
    31101: "Tusk Assault",
    31201: "Wolf Howl",
    31301: "Spine Burst",
    31401: "Venom Spit",
    31501: "Shell Defense",
    31601: "Trample",
  };

  // ===== HEROES (portrayalBase + portrayalText + portrayalSkill) =====
  // id = portrayalBase id; pawn = avatar_pawn (unit the hero possesses);
  // hp/atk = 8-entry ladder for Grade 7,6,5,4,3,2,1,Chosen;
  // skill value ladder uses the same 8 grades; strategy = expertise pool.
  static const List<Map<String, dynamic>> HEROES = [
    {'id': 310101, 'name': 'Chen Dao', 'nameId': 'Chen Dao', 'pawn': 3101, 'troop': 'longspearman',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 1, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30101, 30102, 30103, 40101, 40102, 40103, 40104, 40105, 40106, 50001]},
    {'id': 310102, 'name': 'Zhao Yun', 'nameId': 'Zhao Yun', 'pawn': 3101, 'troop': 'longspearman',
     'hp': [150, 150, 180, 180, 210, 210, 240, 250], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 2, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30101, 30102, 30103, 40101, 40102, 40103, 40104, 40105, 40106, 50002]},
    {'id': 310103, 'name': 'Yang Miaozhen', 'nameId': 'Yang Miaozhen', 'pawn': 3101, 'troop': 'longspearman',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 54, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30101, 30102, 30103, 40101, 40102, 40103, 40104, 40105, 40106, 50030]},
    {'id': 310201, 'name': 'Zhang He', 'nameId': 'Zhang He', 'pawn': 3102, 'troop': 'lancer',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 11, 11, 13, 13, 16, 17], 'skill': 3, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30201, 30202, 40101, 40102, 40103, 40104, 40105, 40106, 50007]},
    {'id': 310202, 'name': 'Qin Liangyu', 'nameId': 'Qin Liangyu', 'pawn': 3102, 'troop': 'lancer',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 4, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30201, 30202, 40101, 40102, 40103, 40104, 40105, 40106, 50022]},
    {'id': 310301, 'name': 'Bai Qi', 'nameId': 'Bai Qi', 'pawn': 3103, 'troop': 'dagger_axe',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 5, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30301, 30302, 40101, 40102, 40103, 40104, 40105, 40106, 50003]},
    {'id': 310302, 'name': 'Zhou Yu', 'nameId': 'Zhou Yu', 'pawn': 3103, 'troop': 'dagger_axe',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 6, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30301, 30302, 40101, 40102, 40103, 40104, 40105, 40106, 50039]},
    {'id': 310303, 'name': 'Li Mu', 'nameId': 'Li Mu', 'pawn': 3103, 'troop': 'dagger_axe',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 56, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30301, 30302, 40101, 40102, 40103, 40104, 40105, 40106, 50033]},
    {'id': 310401, 'name': 'Li Siye', 'nameId': 'Li Siye', 'pawn': 3104, 'troop': 'modao',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 12, 12, 15, 15, 19, 20], 'skill': 7, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30401, 30402, 40101, 40104, 40105, 40106, 50004]},
    {'id': 310402, 'name': 'Yu Jin', 'nameId': 'Yu Jin', 'pawn': 3104, 'troop': 'modao',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 11, 11, 14, 14, 17, 18], 'skill': 8, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30401, 30402, 40101, 40104, 40105, 40106, 50040]},
    {'id': 310501, 'name': 'Jiang Wei', 'nameId': 'Jiang Wei', 'pawn': 3105, 'troop': 'long_swordsman',
     'hp': [125, 125, 155, 155, 185, 185, 215, 225], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 10, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 33101, 33102, 33103, 40101, 40102, 40103, 40104, 40105, 40106, 50005]},
    {'id': 310502, 'name': 'Lü Meng', 'nameId': 'Lü Meng', 'pawn': 3105, 'troop': 'long_swordsman',
     'hp': [125, 125, 155, 155, 185, 185, 215, 225], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 47, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 33101, 33102, 33103, 40101, 40102, 40103, 40104, 40105, 40106, 50019]},
    {'id': 310503, 'name': 'Xin Qiji', 'nameId': 'Xin Qiji', 'pawn': 3105, 'troop': 'long_swordsman',
     'hp': [125, 125, 155, 155, 185, 185, 215, 225], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 57, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 33101, 33102, 33103, 40101, 40102, 40103, 40104, 40105, 40106, 50032]},
    {'id': 310601, 'name': 'Wen Yang', 'nameId': 'Wen Yang', 'pawn': 3106, 'troop': 'twin_spearman',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 11, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30501, 30502, 30503, 40101, 40102, 40103, 40104, 40105, 40106, 50008]},
    {'id': 310602, 'name': 'Dian Wei', 'nameId': 'Dian Wei', 'pawn': 3106, 'troop': 'twin_spearman',
     'hp': [125, 125, 155, 155, 185, 185, 215, 225], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 12, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30501, 30502, 30503, 40101, 40102, 40103, 40104, 40105, 40106, 50018]},
    {'id': 310603, 'name': 'Qin Qiong', 'nameId': 'Qin Qiong', 'pawn': 3106, 'troop': 'twin_spearman',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 48, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30501, 30502, 30503, 40101, 40102, 40103, 40104, 40105, 40106, 50021]},
    {'id': 320101, 'name': 'Xu Sheng', 'nameId': 'Xu Sheng', 'pawn': 3201, 'troop': 'saber_shield',
     'hp': [250, 250, 325, 325, 400, 400, 475, 500], 'atk': [2, 2, 3, 3, 4, 4, 5, 5], 'skill': 13, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30601, 30602, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50006]},
    {'id': 320102, 'name': 'Yue Jin', 'nameId': 'Yue Jin', 'pawn': 3201, 'troop': 'saber_shield',
     'hp': [250, 250, 325, 325, 400, 400, 475, 500], 'atk': [2, 2, 3, 3, 4, 4, 5, 5], 'skill': 14, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30601, 30602, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50023]},
    {'id': 320103, 'name': 'Xiahou Dun', 'nameId': 'Xiahou Dun', 'pawn': 3201, 'troop': 'saber_shield',
     'hp': [250, 250, 325, 325, 400, 400, 475, 500], 'atk': [2, 2, 3, 3, 4, 4, 5, 5], 'skill': 15, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30601, 30602, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50056]},
    {'id': 320201, 'name': 'Cao Ren', 'nameId': 'Cao Ren', 'pawn': 3202, 'troop': 'heavy_shield',
     'hp': [300, 300, 390, 390, 480, 480, 570, 600], 'atk': [1, 1, 2, 2, 3, 3, 4, 4], 'skill': 16, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 30701, 30702, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50041]},
    {'id': 320202, 'name': 'Zhou Tai', 'nameId': 'Zhou Tai', 'pawn': 3202, 'troop': 'heavy_shield',
     'hp': [300, 300, 390, 390, 480, 480, 570, 600], 'atk': [1, 1, 2, 2, 3, 3, 4, 4], 'skill': 17, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 30701, 30702, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50042]},
    {'id': 320203, 'name': 'Wei Xiaokuan', 'nameId': 'Wei Xiaokuan', 'pawn': 3202, 'troop': 'heavy_shield',
     'hp': [300, 300, 390, 390, 480, 480, 570, 600], 'atk': [1, 1, 2, 2, 3, 3, 4, 4], 'skill': 58, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 30701, 30702, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50043]},
    {'id': 320301, 'name': 'Zhang Fei', 'nameId': 'Zhang Fei', 'pawn': 3203, 'troop': 'spear_shield',
     'hp': [150, 150, 210, 210, 270, 270, 330, 350], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 18, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30801, 30802, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50020]},
    {'id': 320302, 'name': 'Gao Shun', 'nameId': 'Gao Shun', 'pawn': 3203, 'troop': 'spear_shield',
     'hp': [150, 150, 210, 210, 270, 270, 330, 350], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 19, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 30801, 30802, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50026]},
    {'id': 320401, 'name': 'Huang Gai', 'nameId': 'Huang Gai', 'pawn': 3204, 'troop': 'hammer_shield',
     'hp': [200, 200, 260, 260, 320, 320, 380, 400], 'atk': [4, 4, 5, 5, 6, 6, 7, 8], 'skill': 20, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 30901, 30902, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50009]},
    {'id': 320402, 'name': 'Lian Po', 'nameId': 'Lian Po', 'pawn': 3204, 'troop': 'hammer_shield',
     'hp': [200, 200, 260, 260, 320, 320, 380, 400], 'atk': [4, 4, 5, 5, 6, 6, 7, 8], 'skill': 21, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 30901, 30902, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50013]},
    {'id': 320501, 'name': 'Cao Cao', 'nameId': 'Cao Cao', 'pawn': 3205, 'troop': 'sword_shield',
     'hp': [150, 150, 210, 210, 270, 270, 330, 350], 'atk': [4, 4, 5, 5, 6, 6, 7, 8], 'skill': 22, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 32101, 32102, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50010]},
    {'id': 320502, 'name': 'Deng Ai', 'nameId': 'Deng Ai', 'pawn': 3205, 'troop': 'sword_shield',
     'hp': [150, 150, 210, 210, 270, 270, 330, 350], 'atk': [4, 4, 5, 5, 6, 6, 7, 8], 'skill': 51, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 32101, 32102, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50028]},
    {'id': 320601, 'name': 'Meng Huo', 'nameId': 'Meng Huo', 'pawn': 3206, 'troop': 'axe_shield',
     'hp': [150, 150, 210, 210, 270, 270, 330, 350], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 53, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 34001, 34002, 34003, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50029]},
    {'id': 320602, 'name': 'Fan Kuai', 'nameId': 'Fan Kuai', 'pawn': 3206, 'troop': 'axe_shield',
     'hp': [150, 150, 210, 210, 270, 270, 330, 350], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 60, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 34001, 34002, 34003, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 50057]},
    {'id': 330101, 'name': 'Huang Zhong', 'nameId': 'Huang Zhong', 'pawn': 3301, 'troop': 'longbowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 10, 12], 'skill': 23, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31001, 31002, 40301, 40302, 40303, 40304, 40305, 40306, 50011]},
    {'id': 330102, 'name': 'Han Dang', 'nameId': 'Han Dang', 'pawn': 3301, 'troop': 'longbowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 10, 12], 'skill': 24, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31001, 31002, 40301, 40302, 40303, 40304, 40305, 40306, 50046]},
    {'id': 330201, 'name': 'Liu Bei', 'nameId': 'Liu Bei', 'pawn': 3302, 'troop': 'crossbowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 25, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31101, 31102, 40301, 40302, 40303, 40304, 40305, 40306, 50012]},
    {'id': 330202, 'name': 'Liu Chong', 'nameId': 'Liu Chong', 'pawn': 3302, 'troop': 'crossbowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 26, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31101, 31102, 40301, 40302, 40303, 40304, 40305, 40306, 50027]},
    {'id': 330203, 'name': 'Diao Chan', 'nameId': 'Diaochan', 'pawn': 3302, 'troop': 'crossbowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 59, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31101, 31102, 40301, 40302, 40303, 40304, 40305, 40306, 50055]},
    {'id': 330301, 'name': 'Wang Yi', 'nameId': 'Wang Yi', 'pawn': 3303, 'troop': 'toxibowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 28, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31201, 31202, 40301, 40302, 40303, 40304, 40305, 40306, 50044]},
    {'id': 330302, 'name': 'Li Ru', 'nameId': 'Li Ru', 'pawn': 3303, 'troop': 'toxibowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 29, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31201, 31202, 40301, 40302, 40303, 40304, 40305, 40306, 50045]},
    {'id': 330401, 'name': 'Yang Youji', 'nameId': 'Yang Youji', 'pawn': 3304, 'troop': 'hunter',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 31, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31301, 31302, 40301, 40302, 40303, 40304, 40305, 40306, 50034]},
    {'id': 330402, 'name': 'Sun Quan', 'nameId': 'Sun Quan', 'pawn': 3304, 'troop': 'hunter',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 32, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31301, 31302, 40301, 40302, 40303, 40304, 40305, 40306, 50014]},
    {'id': 330403, 'name': 'Liang Hongyu', 'nameId': 'Liang Hongyu', 'pawn': 3304, 'troop': 'hunter',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 55, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31301, 31302, 40301, 40302, 40303, 40304, 40305, 40306, 50031]},
    {'id': 330404, 'name': 'Cai Yan', 'nameId': 'Cai Wenji', 'pawn': 3304, 'troop': 'hunter',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 61, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31301, 31302, 40301, 40302, 40303, 40304, 40305, 40306, 50058]},
    {'id': 330501, 'name': 'Cao Xiu', 'nameId': 'Cao Xiu', 'pawn': 3305, 'troop': 'improved_crossbowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 10, 12], 'skill': 33, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31401, 31402, 40301, 40302, 40305, 40306, 50015]},
    {'id': 330502, 'name': 'Sun Shangxiang', 'nameId': 'Sun Shangxiang', 'pawn': 3305, 'troop': 'improved_crossbowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 34, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31401, 31402, 40301, 40302, 40305, 40306, 50035]},
    {'id': 330601, 'name': 'Lu Xun', 'nameId': 'Lu Xun', 'pawn': 3306, 'troop': 'fire_bowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 49, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 33001, 33002, 40301, 40302, 40303, 40304, 40305, 40306, 50036]},
    {'id': 330602, 'name': 'Zhu Yuanzhang', 'nameId': 'Zhu Yuanzhang', 'pawn': 3306, 'troop': 'fire_bowman',
     'hp': [50, 50, 65, 65, 80, 80, 95, 100], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 62, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 33001, 33002, 40301, 40302, 40303, 40304, 40305, 40306, 50059]},
    {'id': 340101, 'name': 'Zhang Liao', 'nameId': 'Zhang Liao', 'pawn': 3401, 'troop': 'sword_cavalry',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 11, 11, 13, 13, 16, 17], 'skill': 35, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31501, 31502, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50016]},
    {'id': 340102, 'name': 'Huo Qubing', 'nameId': 'Huo Qubing', 'pawn': 3401, 'troop': 'sword_cavalry',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 11, 11, 13, 13, 16, 17], 'skill': 36, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31501, 31502, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50017]},
    {'id': 340201, 'name': 'Lü Bu', 'nameId': 'Lü Bu', 'pawn': 3402, 'troop': 'spear_cavalry',
     'hp': [150, 150, 195, 195, 240, 240, 285, 300], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 37, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31601, 31602, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50037]},
    {'id': 340202, 'name': 'Ma Chao', 'nameId': 'Ma Chao', 'pawn': 3402, 'troop': 'spear_cavalry',
     'hp': [150, 150, 195, 195, 240, 240, 285, 300], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 38, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31601, 31602, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50038]},
    {'id': 340203, 'name': 'Xiang Yu', 'nameId': 'Xiang Yu', 'pawn': 3402, 'troop': 'spear_cavalry',
     'hp': [150, 150, 195, 195, 240, 240, 285, 300], 'atk': [8, 8, 10, 10, 12, 12, 14, 16], 'skill': 39, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31601, 31602, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50024]},
    {'id': 340301, 'name': 'Guan Yu', 'nameId': 'Guan Yu', 'pawn': 3403, 'troop': 'broadsword_cavalry',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 12, 12, 15, 15, 19, 20], 'skill': 40, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31701, 31702, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50025]},
    {'id': 340302, 'name': 'Guan Yinping', 'nameId': 'Guan Yinping', 'pawn': 3403, 'troop': 'broadsword_cavalry',
     'hp': [100, 100, 130, 130, 160, 160, 190, 200], 'atk': [8, 8, 11, 11, 14, 14, 17, 18], 'skill': 41, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31701, 31702, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50054]},
    {'id': 340401, 'name': 'Xu Chu', 'nameId': 'Xu Chu', 'pawn': 3404, 'troop': 'heavy_cavalry',
     'hp': [250, 250, 325, 325, 400, 400, 475, 500], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 42, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31801, 31802, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50047]},
    {'id': 340402, 'name': 'Pei Xingyan', 'nameId': 'Pei Xingyan', 'pawn': 3404, 'troop': 'heavy_cavalry',
     'hp': [250, 250, 325, 325, 400, 400, 475, 500], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 43, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31801, 31802, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50048]},
    {'id': 340403, 'name': 'Dong Zhuo', 'nameId': 'Dong Zhuo', 'pawn': 3404, 'troop': 'heavy_cavalry',
     'hp': [250, 250, 325, 325, 400, 400, 475, 500], 'atk': [4, 4, 6, 6, 8, 8, 9, 10], 'skill': 52, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31801, 31802, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50049]},
    {'id': 340501, 'name': 'Xia Houyuan', 'nameId': 'Xiahou Yuan', 'pawn': 3405, 'troop': 'bow_cavalry',
     'hp': [75, 75, 90, 90, 105, 105, 120, 125], 'atk': [4, 4, 5, 5, 6, 6, 7, 8], 'skill': 44, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31901, 31902, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50050]},
    {'id': 340502, 'name': 'Taishi Ci', 'nameId': 'Taishi Ci', 'pawn': 3405, 'troop': 'bow_cavalry',
     'hp': [75, 75, 90, 90, 105, 105, 120, 125], 'atk': [4, 4, 5, 5, 6, 6, 7, 8], 'skill': 45, 'strategy': [10001, 10002, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 31901, 31902, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 50051]},
    {'id': 340601, 'name': 'Xu Huang', 'nameId': 'Xu Huang', 'pawn': 3406, 'troop': 'axe_cavalry',
     'hp': [175, 175, 220, 220, 265, 265, 310, 325], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 46, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 32001, 32002, 40403, 40404, 40405, 40406, 40407, 50052]},
    {'id': 340602, 'name': 'Cheng Yaojin', 'nameId': 'Cheng Yaojin', 'pawn': 3406, 'troop': 'axe_cavalry',
     'hp': [175, 175, 220, 220, 265, 265, 310, 325], 'atk': [8, 8, 10, 10, 12, 12, 13, 14], 'skill': 50, 'strategy': [10001, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 32001, 32002, 40403, 40404, 40405, 40406, 40407, 50053]},
  ];

  /// portrayalSkill rows: skill id -> value ladder + params.
  /// Hero skills whose `{0}` value directly scales active-skill damage
  /// (descriptions contain "*ATK"). Other skills use the value for utility
  /// (shields, leech, stack caps), so it must not be folded into DMG.
  static const Set<int> HERO_SKILL_DAMAGE_SCALE = {4, 24, 35, 38, 43, 48, 56};

  static const Map<int, Map<String, dynamic>> HERO_SKILLS = {
    1: {'name': 'Common Hope', 'nameId': 'Harapan Bersama', 'desc': 'When attacking, also deals (10%*All allied Soldiers\' ATK) additional DMG. Meanwhile, transfers <color=#000001>{0}</c> of ATK DMG taken by self to the Soldier with the highest HP percentage.', 'descId': 'Saat menyerang, juga memberikan DMG tambahan sebesar 10% dari total ATK seluruh prajurit lain dalam pasukan. Selain itu, <color=#000001>{0}</c> DMG yang diterima diri sendiri akan dialihkan ke prajurit dengan Rasio HP tertinggi dalam pasukan',
         'values': [40, 40, 52, 52, 64, 64, 76, 80], 'suffix': '%', 'params': '0.1'},
    2: {'name': 'Valor of Loong', 'nameId': 'Nyali Naga', 'desc': 'Any Dodge +10%, +5% when taking ATK DMG, stackable without limit each round. Increases next attack\'s DMG by <color=#000001>{0}</c> after dodging successfully each time.', 'descId': 'Dodge apa pun +10%, dan Dodge apa pun +5% saat menerima ATK DMG, setiap ronde dapat distack tanpa batas, DMG yang ditimbulkan oleh ATK berikutnya +<color=#000001>{0}</c> per Dodge yang berhasil',
         'values': [10, 10, 13, 13, 16, 16, 19, 20], 'suffix': '%', 'params': '5'},
    3: {'name': 'Intimidating Force', 'nameId': 'Kekuatan Mengintimidasi', 'desc': 'Increases Project DMG by <color=#000001>{0}</c>. If a target is killed by Project, horrifies up to 4 enemies within 2 tile around the target, making them unable to move or attack for 1 round, except those in Shield Stance or with weaponry.', 'descId': 'Meningkatkan Project DMG sebesar <color=#000001>{0}</c>, jika target terbunuh oleh Project, horrify hingga 4 musuh dalam jarak 2 kotak di sekitar target, membuat mereka tidak dapat pindah atau ATK, selama 1 ronde, tidak akan di horrify dalam posisi Perisai Berdiri atau dengan persenjataan',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '%', 'params': ''},
    4: {'name': 'Barb', 'nameId': 'Barb', 'desc': 'The Lance will stay at the target position when being projected. Will take the Lance back instead of attacking in the next round. When taking the Lance back, if no enemy is at the target position, increases Rage by 75%; otherwise, deals (<color=#000001>{0}</c> *ATK) DMG to the target.', 'descId': 'Saat menembak, tombak akan tertinggal di lokasi target, tidak akan menyerang lagi tetapi mencabut tombak di ronde berikutnya, jika tidak ada musuh di lokasi target saat mengambil tombak, Rage akan meningkat 75%, jika tidak maka akan menyebabkan (<color=#000001>{0}</c>*ATK) DMG kepada mereka',
         'values': [100, 100, 115, 115, 130, 130, 145, 150], 'suffix': '%', 'params': '1.12,0.28'},
    5: {'name': 'Merciless Siege', 'nameId': 'Pengepungan', 'desc': 'When disarming the target, transfers <color=#000001>{0}</c> of their ATK Reduction to up to 12 allies within 4 tiles around the target for 3 rounds, prioritizing disarming allies with the highest ATK.', 'descId': 'Saat Disarm target, mentransfer <color=#000001>{0}</c> ATK Reduction mereka ke hingga 12 sekutu dalam jarak 4 kotak di sekitar target selama 3 ronde, prioritas disarm target dengan ATK tertinggi',
         'values': [50, 50, 65, 65, 80, 80, 95, 100], 'suffix': '%', 'params': '4'},
    6: {'name': 'Chains', 'nameId': 'Chain Cable', 'desc': 'When disarming the target, connects the target with up to 8 enemies (except for Weaponry) within 2 tile for 3 rounds. When any target takes ATK DMG, other connected targets will take <color=#000001>{0}</c> DMG.', 'descId': 'Saat disarm, target akan terhubung ke hingga 8 musuh dalam 2 kotak selama 3 ronde, persenjataan tidak dapat terhubung, target mana pun dalam koneksi menerima DMG ATK, dan target lainnya juga menerima <color=#000001>{0}</c> DMG',
         'values': [30, 30, 36, 36, 42, 42, 48, 50], 'suffix': '%', 'params': '2'},
    7: {'name': 'Brave Spirit', 'nameId': 'Brave Spirit', 'desc': 'Deals ATK DMG equal to the random DMG dealt by Cavalry Suffer. Gains 2 ATK and 3% Dodge when any enemy dies within self ATK Range, stackable up to <color=#000001>{0}</c> time(s).', 'descId': 'Memberikan ATK DMG yang sama dengan DMG acak yang diberikan oleh Cavalry Suffer, mendapatkan 2 ATK dan 3% Dodge ketika ada musuh yang mati dalam Jangkauan ATK, stack hingga <color=#000001>{0}</c> kali',
         'values': [5, 5, 8, 8, 11, 11, 14, 15], 'suffix': '', 'params': '3'},
    8: {'name': 'Unwavering General', 'nameId': 'Yizhong', 'desc': 'When a battle starts, increases DMG dealt and taken by <color=#000001>{0}</c> for all non-weaponry ally soldiers of the current army and make them immune to debuffs. This effect ends when Yu Jin is killed.', 'descId': 'Saat battle dimulai, DMG yang diberikan dan diterima meningkat sebesar <color=#000001>{0}</c> untuk semua prajurit sekutu non-persenjataan dari pasukan saat ini dan membuat mereka kebal terhadap efek debuff. Efek ini berakhir saat Yu Jin terbunuh',
         'values': [50, 50, 65, 65, 80, 80, 95, 100], 'suffix': '%', 'params': '0.5'},
    10: {'name': 'Wisdom & Bravery', 'nameId': 'Kebijaksanaan & Keberanian', 'desc': 'Each time Whirlwind is released, gains 4 ATK and 6% DMG Reduction, stackable up to <color=#000001>{0}</c> time(s).', 'descId': 'Setiap kali melepaskan Whirlwind, mendapatkan 4 ATK dan 6% DMG Reduction, bisa di-stack <color=#000001>{0}</c> kali',
         'values': [5, 5, 6, 6, 7, 7, 9, 10], 'suffix': '', 'params': '6'},
    11: {'name': 'Brave Charge', 'nameId': 'Serangan Berani', 'desc': 'Unbridled Dance only deals 1 stage of DMG. After each Unbridled Dance, there is a chance of dashing again. The chance of the first dash is 100% and the subsequent chances are <color=#000001>{0}</c>. Can dash up to 7 times.', 'descId': 'Unbridled Dance hanya memberikan 1 tahap DMG, setelah setiap Unbridled Dance ada peluang untuk lonjakan lagi, dengan peluang 100% untuk lonjakan pertama, dan <color=#000001>{0}</c> setelahnya, hingga maksimum 7 lonjakan',
         'values': [40, 40, 49, 49, 58, 58, 67, 70], 'suffix': '%', 'params': ''},
    12: {'name': 'Courage', 'nameId': 'Courage', 'desc': 'When gaining 1 Rage, ATK +1, stackable up to <color=#000001>{0}</c> time(s). After the effect is stacked to 20 times, Unbridled Dance Stages+1.', 'descId': 'Setiap naik 1 Rage, ATK +1 stack hingga <color=#000001>{0}</c>x, setelah stack 20 kali, Unbridled Dance Stage +1',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '', 'params': '0.1,0.1'},
    13: {'name': 'Safe Shelter', 'nameId': 'Tempat Berlindung', 'desc': 'When releasing Shield, also grants Safe Shelter to up to 10 allies, making them immune to debuffs and gain <color=#000001>{0}</c> Leech for 5 rounds. When allies within 5 tiles are inflicted with debuffs, increases self Rage by 1.', 'descId': 'Saat menggunakan Perisai, hingga 10 sekutu akan mendapatkan Perlindungan, membuat mereka kebal terhadap efek debuff dan mendapatkan <color=#000001>{0}</c> Leech selama 5 ronde. Setiap kali sekutu dalam radius 5 kotak terkena efek debuff, Anda mendapatkan 1 Rage',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '%', 'params': ''},
    14: {'name': 'First to Arrive', 'nameId': 'Prestage', 'desc': 'When a battle starts, attracts the enemy buildings to attack self, with an 80% chance of dodging the building\'s attacks. Deals (<color=#000001>{0}</c>*dodged DMG) additional DMG when attacking non-building targets the next time.', 'descId': 'Saat memasuki battle, menarik bangunan musuh untuk ATK diri sendiri, ada 80% peluang untuk dodge ATK bangunan. ATK berikutnya kepada target non-bangunan menyebabkan ekstra <color=#000001>{0}</c>*Dodge DMG',
         'values': [20, 20, 26, 26, 32, 32, 38, 40], 'suffix': '%', 'params': ''},
    15: {'name': 'Fierce Resolve', 'nameId': 'Valor', 'desc': 'When DMG taken outside of a round exceeds 10% of Max HP, restores 3% Max HP at the start of the next round and reflects <color=#000001>{0}</c> of the DMG taken as additional True DMG to the target that dealt the most DMG.', 'descId': 'Saat DMG ATK yang diterima di luar ronde mengakumulasi lebih dari 10% HP Maks, ronde berikutnya memulihkan HP sebesar 3% HP Maks, serta Reflect <color=#000001>{0}</c> dari DMG yang diterima sebagai True DMG tambahan kepada target yang menyebabkan DMG tertinggi pada diri sendiri',
         'values': [10, 10, 13, 13, 16, 16, 19, 20], 'suffix': '%', 'params': '0.1'},
    16: {'name': 'Strong Will', 'nameId': 'Ketangguhan', 'desc': 'When taking DMG each time, Max HP +8, stackable up to <color=#000001>{0}</c> time(s). After the effect is stacked to 20 times, restores HP by 1% of Max HP each round.', 'descId': 'Setiap kali menerima ATK DMG, HP Maks +8, stack hingga <color=#000001>{0}</c>x, setelah stack 20 kali, memulihkan (1%*HP Maks) HP setiap ronde',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '', 'params': '0.01'},
    17: {'name': 'Support', 'nameId': 'Support', 'desc': 'Takes <color=#000001>{0}</c> ATK DMG for allies within 5 tiles and has a 100% chance to restore 20% of the Max HP when dying. The chance will be reduced by 10% after the effect is triggered each time, up to 50%.', 'descId': 'Menerima <color=#000001>{0}</c> ATK DMG untuk sekutu dalam 5 kotak dan ada 100% peluang untuk memulihkan HP sebesar 20% dari HP Maks saat sekarat. Peluang akan berkurang 10% setelah efek dipicu setiap kali, hingga 50%',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '%', 'params': ''},
    18: {'name': 'Furious Roar', 'nameId': 'Raungan Amarah', 'desc': 'Roars after a Charge. Deals additional True DMG equal to <color=#000001>{0}</c> of the effective DMG from this Charge to up to 8 enemies within 2 tiles and terrifies them, making them unable to move for 3 rounds.', 'descId': 'Mengaum setelah charge, memberikan ekstra (<color=#000001>{0}</c>*DMG efektif) True DMG yang dihasilkan oleh charge tersebut kepada maksimal 8 musuh dalam 2 kotak dan membuat mereka terrify, tidak dapat berpindah, selama 3 ronde',
         'values': [40, 40, 49, 49, 58, 58, 67, 70], 'suffix': '%', 'params': '0.2,0.3'},
    19: {'name': 'Onslaught', 'nameId': 'Onslaught', 'desc': 'When a battle starts, increases Max HP by 10% and ATK by <color=#000001>{0}</c> for all non-weaponry ally soldiers of the current army; meanwhile, for every 1% HP lost, increases DMG dealt by 1%. This effect ends when Gao Shun is killed.', 'descId': 'Saat memasuki battle, HP Maks semua prajurit non-persenjataan dalam pasukan sendiri +10%, ATK +<color=#000001>{0}</c>, dan setiap kehilangan 1% HP, DMG yang diberikan +1%, efek hilang setelah Gao Shun terbunuh',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '%', 'params': '0.6,0.1'},
    20: {'name': 'Deliberate Sacrifice', 'nameId': 'Pengorbanan yang Disengaja', 'desc': 'At the start of the first round, deducts self HP by 20% of Max HP, grants the 30 closest allies and self a shield equal to <color=#000001>{0}</c>, and increases their ATK by 10% till the end of the battle.', 'descId': 'Pada awal ronde pertama, mengurangi HP diri sendiri sebesar 20% dari HP Maks, memberikan 30 sekutu terdekat dan diri sendiri perisai yang setara dengan <color=#000001>{0}</c>, dan meningkatkan ATK mereka sebesar 10% hingga akhir battle',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '%', 'params': '0.2'},
    21: {'name': 'Utmost Protection', 'nameId': 'Utmost Protection', 'desc': 'If HP is above 50%, increases DMG dealt by 25% for self and up to 12 allies within 3 tiles; if HP is lower than 50%, reduces DMG taken by 25% for self and up to 12 allies within 3 tiles. Additionally increases self effect by <color=#000001>{0}</c>.', 'descId': 'Jika HP di atas 50%, tingkatkan DMG yang diterima sebesar 25% untuk diri sendiri dan hingga 12 sekutu dalam 3 kotak; Jika HP di bawah 50%, kurangi DMG yang diterima sebesar 25% untuk diri sendiri dan hingga 12 sekutu dalam 3 kotak, dan tingkatkan efek diri sendiri sebesar <color=#000001>{0}</c>',
         'values': [50, 50, 65, 65, 80, 80, 95, 100], 'suffix': '%', 'params': '25'},
    22: {'name': 'Ambitious Spirit', 'nameId': 'Semangat Ambisius', 'desc': 'Each attack grants 1 layer of Morale on up to 20 allies within 3 tiles. Each layer of Morale increases Max HP by 10 and ATK by 1, stackable up to <color=#000001>{0}</c> layers. All layers of Morale will be removed after Cao Cao\'s death.', 'descId': 'Setiap serangan memberikan 1 lapisan Moral pada hingga 20 sekutu dalam 3 kotak, setiap lapisan Moral meningkatkan HP Maksimal sebesar 10 dan ATK sebesar 1, stack hingga <color=#000001>{0}</c> lapis, semua lapisan Moral akan dihapus setelah kematian Cao Cao',
         'values': [10, 10, 13, 13, 16, 16, 19, 20], 'suffix': '', 'params': '10'},
    23: {'name': 'Excellent Shot', 'nameId': 'Tembakan Luar Biasa', 'desc': 'When the HP of the target is below 60%, there is a <color=#000001>{0}</c> chance of killing them directly. The chance will be doubled when the target\'s HP is below 30% and prioritizes attacking the target with the lowest HP ratio.', 'descId': 'Saat ATK target dengan HP di bawah 60%, ada <color=#000001>{0}</c> peluang untuk membunuh mereka secara langsung, saat HP target dibawah 30%, peluangnya menjadi dua kali lipat, dan target dengan rasio HP terendah akan di-ATK terlebih dahulu',
         'values': [15, 15, 20, 20, 25, 25, 28, 30], 'suffix': '%', 'params': '0.6'},
    24: {'name': 'Ape Arm', 'nameId': 'Ape Arm', 'desc': 'Basic attack deals [(current Rage*<color=#000001>{0}</c>)%*ATK] additional True DMG and 1 Rage is reserved after Scatter.', 'descId': 'Normal ATK memberikan ekstra (Rage saat ini*<color=#000001>{0}</c>)*%ATK) True DMG, dan mempertahankan 1 Rage setelah Scatter',
         'values': [30, 30, 36, 36, 42, 42, 48, 50], 'suffix': '', 'params': ''},
    25: {'name': 'Benevolent Gesture', 'nameId': 'Gerakan Baik Hati', 'desc': 'Rapid Fire deals no more DMG to enemies and restores HP by <color=#000001>{0}</c> of their Max HP for the ally with the lowest HP ratio instead. Increases the restoration effect by 30% when self reaches the max level. Exclusive Equipment Effect: Rapid Fire Time +1', 'descId': 'Rapid Fire tidak lagi memberikan DMG kepada musuh, melainkan regen (<color=#000001>{0}</c>*HP Maks) HP untuk sekutu dengan rasio HP terendah, efek regen meningkat 30% saat diri sendiri mencapai level maksimum (efek equipment eksklusif: Jumlah Rapid Fire +1)',
         'values': [10, 10, 13, 13, 16, 16, 19, 20], 'suffix': '%', 'params': '630'},
    26: {'name': 'Precision', 'nameId': 'Presisi', 'desc': 'When releasing Rapid Fire, for every 1 arrow shot, there is a <color=#000001>{0}</c> chance of shooting 1 more arrow, up to 10 arrows can be shot.', 'descId': 'Saat melepaskan Rapid Fire, untuk setiap 1 anak panah yang ditembakkan, ada <color=#000001>{0}</c> peluang untuk menembakkan 1 anak panah lagi, hingga 10 anak panah dapat ditembakkan',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '%', 'params': ''},
    28: {'name': 'Poison Mist', 'nameId': 'Kabut Racun', 'desc': 'When shooting Poison Arrows, reduces Hit for up to 12 enemies within 3 tiles, making them have a <color=#000001>{0}</c> chance to miss the target for 2 rounds when attacking; if the target is paralyzed, +1 round.', 'descId': 'Saat melepaskan Panah Racun, mengurangi hit hingga 12 musuh dalam radius 3 kotak dari target, memberi mereka <color=#000001>{0}</c> peluang gagal mengenai target selama 2 ronde, jika target Paralysis, durasi +1 ronde',
         'values': [40, 40, 52, 52, 64, 64, 76, 80], 'suffix': '%', 'params': '12'},
    29: {'name': 'Poisoned Wine', 'nameId': 'Poisoned Wine', 'desc': 'Poison Arrow also inflicts Poisoned Wine for 3 rounds. When the target dies or at the end of a round, deals additional True DMG equal to <color=#000001>{0}</c> of the total DMG taken by the target within the duration of Poisoned Wine to up to 8 enemies within 2 tiles.', 'descId': 'Panah Racun juga memberikan Poisoned Wine selama 3 ronde, saat target mati atau ronde berakhir, memberikan True DMG ekstra kepada maksimal 8 musuh dalam 2 kotak, DMG-nya adalah <color=#000001>{0}</c> dari total DMG yang diterima target selama periode Poisoned Wine',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '%', 'params': '8'},
    31: {'name': 'Call of Wild', 'nameId': 'Panggilan Wild', 'desc': 'Stops releasing Inspire and summons a beast. If the beast already exists, feeds it to restore its HP by <color=#000001>{0}</c> of its Max HP instead. (Exclusive Equipment: When the beast is fed each time, its Max HP +4%, ATK +6%, stackable up to 25 times.)', 'descId': 'Menghentikan pelepasan Inspire dan summon satu beast. Jika beast sudah ada, beri makan beast untuk memulihkan HP-nya sebesar <color=#000001>{0}</c> dari HP Maks. (Efek Equipment Eksklusif: Setiap kali beast diberi makan, HP Maks+4%, ATK+6%, dapat distack hingga 25 kali)',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '%', 'params': '0.9,0.7'},
    32: {'name': 'Wise Ruler', 'nameId': 'Penguasa Bijaksana', 'desc': 'When inspiring, additionally increases <color=#000001>{0}</c> ATK for 4 allies with the highest ATK. When self reaches the max level, inflicts the effect on 4 more targets. (Exclusive Equipment: Also increases 50% Rage for these allies with the highest ATK, excluding self.)', 'descId': 'Saat Inspire, ATK 4 sekutu dengan ATK tertinggi meningkat <color=#000001>{0}</c>, saat level penuh, jumlah target +4 (Efek Equipment Eksklusif: Juga akan meningkatkan Rage sekutu ini dengan ATK tertinggi sebesar 50%, kecuali diri sendiri)',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '%', 'params': '0.66'},
    33: {'name': 'Sniper Fire', 'nameId': 'Penembak Jitu', 'desc': 'Prioritizes the furthest target. If the target is at the maximum ATK Range, DMG dealt to it +<color=#000001>{0}</c>.', 'descId': 'Memprioritaskan menyerang target terjauh. Jika target berada pada jarak serangan terjauh, maka DMG yang diberikan kepadanya +<color=#000001>{0}</c>',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '%', 'params': '650,0.36,5016'},
    34: {'name': 'Ambitious Belle', 'nameId': 'Ambitious Belle', 'desc': 'For every 5 rounds, stuns 1 enemy with the highest ATK for 3 rounds and restores HP by <color=#000001>{0}</c> of Max HP for 1 ally with the lowest HP ratio. When self reaches the max level, affected target +1 respectively.', 'descId': 'Untuk setiap 5 ronde, stun 1 musuh dengan ATK tertinggi selama 3 ronde dan memulihkan HP sebesar <color=#000001>{0}</c> dari HP Maks untuk 1 sekutu dengan rasio HP terendah. Saat diri sendiri mencapai level maksimal, target yang terpengaruh masing-masing mendapatkan +1',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '%', 'params': '5'},
    35: {'name': 'Surprise Attack', 'nameId': 'Surprise Attack', 'desc': 'If the target of Leap Slash survives, deals (<color=#000001>{0}</c>*ATK) additional True DMG again to up to 8 enemies within 2 tiles and grants self 50% DMG Reduction for 1 round.', 'descId': 'Jika target yang terkena Leap Slash tidak mati, maka memberikan (<color=#000001>{0}</c>*ATK) ekstra True DMG kepada maksimal 8 musuh dalam 2 kotak dari target, dan membuat diri sendiri mendapatkan 50% DMG Reduction selama 1 ronde',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '%', 'params': '8'},
    36: {'name': 'Swift Leap', 'nameId': 'Swift', 'desc': 'When a battle starts, each time a Sword Cavalry in the current army releases Leap Slash, increases Rage by 1 for another Sword Cavalry in the army and increases their Leap Slash DMG by <color=#000001>{0}</c> next time. This effect can be stacked and will end when Huo Qubing is killed.', 'descId': 'Saat memasuki battle, setiap Leap Slash yang dilepaskan oleh semua Kavaleri Pedang di pasukanmu akan meningkatkan Rage dari Kavaleri Pedang lain di pasukanmu sebesar 1 dan meningkatkan DMG Leap Slash berikutnya sebesar <color=#000001>{0}</c>, dapat di-stack. Efek hilang setelah Huo Qubing mati',
         'values': [5, 5, 6, 6, 7, 7, 9, 10], 'suffix': '%', 'params': '0.33,0.1'},
    37: {'name': 'Peerless Strike', 'nameId': 'Peerless Strike', 'desc': 'Self Leech +<color=#000001>{0}</c>. If the targets hit are fewer than the threshold value of (4x Sweep Range) when sweeping, multiplies the DMG dealt by [Threshold value/The number of targets hit].', 'descId': 'Leech Diri +<color=#000001>{0}</c>. Saat sweep, jjika jumlah target yang terkena kurang dari threshold (4×jangkauan sweep), DMG meningkat, faktor multiplier adalah threshold/jumlah target terkena',
         'values': [10, 10, 13, 13, 16, 16, 19, 20], 'suffix': '%', 'params': '4'},
    38: {'name': 'Full Chase', 'nameId': 'Chase', 'desc': 'Sweep Range +1. After releasing Sweep, chases the target with the lowest HP within the Sweep Range once, dealing (<color=#000001>{0}</c>*ATK) True DMG.', 'descId': 'Jangkauan Sweep +1, setelah Sweep, luncurkan 1 kali Chase terhadap target dengan HP terendah dalam jangkauan sweep, memberikan (<color=#000001>{0}</c>*ATK) True DMG',
         'values': [100, 100, 115, 115, 130, 130, 145, 150], 'suffix': '%', 'params': ''},
    39: {'name': 'Overlord', 'nameId': 'Overlord', 'desc': 'Increases Sweep\'s DMG by (<color=#000001>{0}</c>*the number of targets hit)% and knocks targets back by 1 tile, making the targets unable to move for 1 round.', 'descId': 'DMG dari sweep meningkat sebesar (<color=#000001>{0}</c>x jumlah hit)%, membuat target mundur 1 kotak dan tidak dapat bergerak selama 1 ronde',
         'values': [5, 5, 6, 6, 7, 7, 9, 10], 'suffix': '', 'params': ''},
    40: {'name': 'Martial Saint', 'nameId': 'Martial Saint', 'desc': 'Each time when attacking a new target, increases Rage by 100%. Increases Chop DMG by <color=#000001>{0}</c> for the next 3 times.', 'descId': 'Setiap kali ATK target baru, Rage meningkat 100%, tambahan True DMG dari 3 chop berikutnya meningkat sebesar <color=#000001>{0}</c>',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '%', 'params': '1'},
    41: {'name': 'Tiger\'s Roar', 'nameId': 'Auman Harimau', 'desc': 'After 1 chop is released, the next chop will become Tiger\'s Roar instead. Meanwhile, deals additional True DMG by <color=#000001>{0}</c> of this chop to up to 4 enemies within 2 tiles around the target and stuns them for 1 round.', 'descId': 'Setiap kali 1x Chop yang dilancarkan, Chop berikutnya berubah menjadi Auman Harimau, memberikan (<color=#000001>{0}</c>*Chop) ekstra True DMG kepada maksimal 4 musuh dalam 2 kotak dari target, dan stun selama 1 ronde',
         'values': [50, 50, 65, 65, 80, 80, 95, 100], 'suffix': '%', 'params': ''},
    42: {'name': 'Blind Loyalty', 'nameId': 'Kesetiaan Buta', 'desc': 'After Collision, ATK +<color=#000001>{0}</c>, -20% each round. When self HP is lower than 50% for the first time, increases DMG dealt by 30%, lasting until the end of the battle.', 'descId': 'Setelah Collide, ATK <color=#000001>{0}</c>, -20% setiap ronde, saat HP diri lebih rendah dari 50% untuk pertama kalinya, meningkatkan DMG yang diberikan sebesar 30%, berlangsung hingga akhir battle',
         'values': [100, 100, 130, 130, 160, 160, 190, 200], 'suffix': '%', 'params': '0.33,0.44'},
    43: {'name': 'Superhuman Strength', 'nameId': 'Divine Power', 'desc': 'Self ATK +<color=#000001>{0}</c>. Basic attacks will knock targets back by 1 tile. When the target is knocked back or up, deals (35%*ATK) additional DMG to the target for every tile moved.', 'descId': 'ATK diri sendiri +<color=#000001>{0}</c>, Normal ATK akan mendorong target mundur sebesar 1 kotak. Saat target didorong mundur atau terlempar, memberikan ekstra (35%*ATK) DMG ke target per kotak jangkauan',
         'values': [15, 15, 20, 20, 25, 25, 28, 30], 'suffix': '%', 'params': '0.7,0.3'},
    44: {'name': 'Long-range Raid', 'nameId': 'Serangan Jarak Jauh', 'desc': 'For every tile moved, increases DMG by 5%, stackable up to <color=#000001>{0}</c> time(s) and will be restacked if no attack is launched within the round.', 'descId': 'Setiap pindah 1 kotak, meningkatkan DMG sebesar 5%, stack hingga <color=#000001>{0}</c> kali, dan stack kembali jika tidak ada ATK yang diluncurkan dalam ronde tersebut',
         'values': [10, 10, 13, 13, 16, 16, 19, 20], 'suffix': '', 'params': '5'},
    45: {'name': 'Marvelous Speed', 'nameId': 'Extreme Speed', 'desc': 'After the basic attack is launched, there is a <color=#000001>{0}</c> chance of fully charging Rage and acting 1 more round.', 'descId': 'Setelah ATK normal, ada <color=#000001>{0}</c> peluang untuk langsung mengisi Rage dan melakukan 1 ronde tindakan lagi',
         'values': [20, 20, 26, 26, 32, 32, 38, 40], 'suffix': '%', 'params': '0.5'},
    46: {'name': 'Fierce Assault', 'nameId': 'Serangan Kuat', 'desc': 'Breaks the target\'s armor when DMG is dealt to them, increasing their DMG taken by <color=#000001>{0}</c>, stackable up to 10 times and lasting for 3 rounds.', 'descId': 'Saat memberikan DMG pada target, memberikan Armor Break pada target dan meningkatkan DMG yang diterima sebesar <color=#000001>{0}</c>, stack hingga 10x selama 3 ronde',
         'values': [10, 10, 13, 13, 16, 16, 19, 20], 'suffix': '%', 'params': '10'},
    47: {'name': 'Self-denial', 'nameId': 'Pengendalian Diri', 'desc': 'Max Rage -50%. Stops releasing Whirlwind for the first 3 times and gains 40 Shield instead. Afterward, increases DMG dealt by <color=#000001>{0}</c>. Meanwhile, for every 1 target hit by Whirlwind, gains 40 Shield.', 'descId': 'Rage Maks -50%, dan tidak lagi melepaskan 3 Whirlwind pertama, tetapi mendapatkan 40 Shield, kemudian DMG meningkat <color=#000001>{0}</c>, dan setiap kali Whirlwind mengenai satu target akan mendapatkan 40 Shield',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '%', 'params': '1.32'},
    48: {'name': 'Surmount Difficulties', 'nameId': 'Beheaded General', 'desc': 'Unbridled Dance only dashes to the enemy hero or the target with the highest ATK, dealing 1 stage of (200%*ATK) DMG and Parry Rate +20%. Meanwhile, the following 2 basic attacks deal (<color=#000001>{0}</c>*target\'s Max HP) additional DMG.', 'descId': 'Unbridled Dance hanya bergerak ke arah hero musuh atau target dengan ATK Power tertinggi, memberikan 1 tahap (200%*ATK) DMG, dan Parry Rate +20%, serta 2 ATK normal berikutnya memberikan ekstra (<color=#000001>{0}</c>*HP Maks) DMG',
         'values': [15, 15, 20, 20, 25, 25, 28, 30], 'suffix': '%', 'params': '0.3,0.4'},
    49: {'name': 'Burning Tents', 'nameId': 'Tenda Burning', 'desc': 'After shooting a fire arrow, there is a <color=#000001>{0}</c> chance of spreading the fire on the allies\' ground by 1 tile towards the enemies.', 'descId': 'Setelah menembakkan panah api, ada <color=#000001>{0}</c> peluang untuk menyebarkan api di tanah milik sekutu sebanyak 1 kotak ke arah musuh',
         'values': [15, 15, 20, 20, 25, 25, 28, 30], 'suffix': '%', 'params': ''},
    50: {'name': 'Three Axe Strokes', 'nameId': 'Kapak Tiga', 'desc': 'When switching to a new target each time, gains 3 special attacks: 1st - Attacks a single target, increasing DMG by 50%; 2nd - Cleave, restores HP by 5% of Max HP for every target hit; 3rd - Attacks a single target and deals (<color=#000001>{0}</c>*lost HP) additional True DMG to the target.', 'descId': 'Setiap kali berganti target, mendapatkan 3 serangan spesial, ATK pertama single-target, DMG +50%, serangan kedua Cleave, setiap mengenai satu target regen (5%*HP Maks) HP, ATK ketiga single-target, memberikan ekstra (<color=#000001>{0}</c>*HP Lost) True DMG kepada target',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '%', 'params': ''},
    51: {'name': 'Garrison Field', 'nameId': 'Farming Field', 'desc': 'At the start of the first round, sends Garrison Order to 30 closest allies: reducing their DMG dealt by 20% for 5 rounds, then increasing their DMG dealt by 10% and restoring <color=#000001>{0}</c> HP each round.', 'descId': 'Pada awal ronde pertama, kirimkan Perintah Farming Field ke 30 sekutu terdekat: kurangi DMG yang diberikan sebesar 20% selama 5 ronde, lalu tingkatkan DMG yang diberikan sebesar 10% dan pulihkan <color=#000001>{0}</c> HP setiap ronde',
         'values': [10, 10, 16, 16, 22, 22, 28, 30], 'suffix': '', 'params': ''},
    52: {'name': 'Cruelty', 'nameId': 'Cruelty', 'desc': 'When Collide is released, the knocked-up target takes (8%*Max HP) additional True DMG and their Max HP is reduced by 8%, stackable up to <color=#000001>{0}</c> times and lasting until Dong Zhuo dies.', 'descId': 'Saat Collide, target yang terlempar menerima ekstra (8%*HP Maks) True DMG, dan membuat HP Maks target -8%, dapat distack <color=#000001>{0}</c> kali, berlangsung hingga Dong Zhuo mati',
         'values': [5, 5, 6, 6, 7, 7, 9, 10], 'suffix': '', 'params': '0.33,0.44'},
    53: {'name': 'Resurgence', 'nameId': 'Bangkit Kembali', 'desc': 'After being attacked each time, DMG dealt +<color=#000001>{0}</c>. Restores 10% of the lost HP after the effect is stacked to 7 layers and then restacks from the beginning.', 'descId': 'Setiap menerima ATK, DMG yang diberikan +<color=#000001>{0}</c>, setelah stack 7 kali, regen (10%*HP Lost) HP, dan mulai stack kembali',
         'values': [10, 10, 13, 13, 16, 16, 19, 20], 'suffix': '%', 'params': '0.44'},
    54: {'name': 'True Sight', 'nameId': 'See Through', 'desc': 'The first target will be marked for 2 rounds when being stabbed. When self attacks the marked target, deals additional True DMG equal to 15% of their Max HP and restores HP equal to <color=#000001>{0}</c> of the DMG.', 'descId': 'Stab akan menandai target utama, selama 2 ronde; Saat diri sendiri ATK target yang ditandai, memberikan ekstra (15%*HP Maks) True DMG, dan regen (<color=#000001>{0}</c>*DMG) HP',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '%', 'params': '0.15'},
    55: {'name': 'War Drum', 'nameId': 'Drum Beat', 'desc': 'When inspiring, also grants allies <color=#000001>{0}</c> DMG Reduction. Doubles the effect if self reaches the max level. Exclusive Equipment Effect: In the duration of inspiring, restores 2% of Max HP for self each round.', 'descId': 'Saat Inspire, juga memberikan <color=#000001>{0}</c> DMG Reduction kepada sekutu, efek berlipat ganda saat diri sendiri mencapai level maksimum (efek equipment eksklusif: Regen (2%*HP Maks) HP setiap ronde selama durasi Inspire)',
         'values': [10, 10, 11, 11, 12, 12, 14, 15], 'suffix': '%', 'params': ''},
    56: {'name': 'Strength Gathering', 'nameId': 'Charge Up', 'desc': 'When releasing Disarm, up to 8 allies with the highest ATK within self ATK Range gain 30% DMG Reduction for 1 round. Afterward, deals (<color=#000001>{0}</c>*ATK) additional True DMG when attacking for 3 rounds.', 'descId': 'Saat melepaskan Disarm, hingga 8 sekutu dengan ATK tertinggi dalam jangkauan ATK Anda akan mendapatkan 30% DMG Reduction selama 1 ronde; selanjutnya, saat ATK membawa (<color=#000001>{0}</c>*ATK) True DMG selama 3 ronde',
         'values': [30, 30, 36, 36, 42, 42, 48, 50], 'suffix': '%', 'params': ''},
    57: {'name': 'Looking Back', 'nameId': 'Look Back', 'desc': 'Gains Iron Weapon in the first 23 rounds upon entering a battle, ATK +<color=#000001>{0}</c>, and reduces DMG taken by 30%. Gains Sorrowful Dream after the 23 rounds and gains Iron Weapon for 1 round for every 3 attacks released.', 'descId': '23 ronde pertama setelah memasuki battle, mendapatkan efek Golden Spear, ATK +<color=#000001>{0}</c>, serta DMG yang diterima -30%; setelah 23 ronde, mendapatkan efek Sorrowful Dream. Setiap 3 kali serangan, mendapatkan efek Golden Spear selama 1 ronde',
         'values': [30, 30, 36, 36, 42, 42, 48, 50], 'suffix': '%', 'params': '23'},
    58: {'name': 'Fear Factor', 'nameId': 'Menakuti Musuh', 'desc': 'When posing Shield Stance, forces up to 12 enemies within 4 tiles to attack him and reduces their DMG dealt by <color=#000001>{0}</c> for 2 rounds.', 'descId': 'Saat Perisai Berdiri, memaksa hingga 12 musuh dalam radius 4 kotak untuk menyerang diri sendiri, mengurangi DMG yang mereka berikan sebesar <color=#000001>{0}</c> selama 2 ronde',
         'values': [20, 20, 29, 29, 38, 38, 47, 50], 'suffix': '%', 'params': '12'},
    59: {'name': 'Moonveil', 'nameId': 'Moon-Hiding', 'desc': 'Every 4 rounds, makes 1 hero or the enemy with the highest ATK within ATK Range obsessed for 2 rounds. Obsessed targets will attack their allies; if no attack is performed, they take additional True DMG equal to <color=#000001>{0}</c> of ATK. At self max level, affects +1 target.', 'descId': 'Setiap 4 ronde, membuat 1 Hero atau musuh dengan ATK tertinggi dalam Jangkauan ATK mengalami Infatuation selama 2 ronde. Dalam status Infatuation akan menyerang sekutu. Jika tidak menyerang, maka akan membuat diri sendiri menerima tambahan (<color=#000001>{0}</c>*ATK) True DMG. Saat level diri sendiri mencapai maksimal, target +1',
         'values': [100, 100, 115, 115, 130, 130, 145, 150], 'suffix': '%', 'params': '4'},
    60: {'name': 'Berserk', 'nameId': 'Rampage', 'desc': 'When HP is above 25%, loses 5% Max HP each round to gain Berserk, increasing the DMG of the next attack by <color=#000001>{0}</c>.', 'descId': 'Saat HP lebih dari 25%, setiap ronde mengurangi 5% HP Maks untuk mendapatkan efek Rampage, membuat DMG dari ATK berikutnya meningkat <color=#000001>{0}</c>',
         'values': [50, 50, 65, 65, 80, 80, 95, 100], 'suffix': '%', 'params': '0.33'},
    61: {'name': 'Elegy', 'nameId': 'Dirge', 'desc': 'When inspiring, additionally restores 5% Max HP to the 3 allies with the lowest HP ratio. Has a <color=#000001>{0}</c> chance to make them deal additional True DMG equal to 30% ATK when attacking for 3 rounds. If self is max-leveled, targets +3.', 'descId': 'Saat Inspire, juga memulihkan HP sebesar 5% HP Maks untuk 3 sekutu dengan rasio HP terendah, serta memiliki <color=#000001>{0}</c> peluang membuat serangannya menyertakan True DMG sebesar 30% ATK selama 3 ronde. Saat level diri sendiri mencapai maksimal, target +3',
         'values': [50, 50, 65, 65, 80, 80, 95, 100], 'suffix': '%', 'params': '5'},
    62: {'name': 'Hongwu', 'nameId': 'Mighty Force', 'desc': 'When an enemy dies on our flames, there is a <color=#000001>{0}</c> chance to create Imperial Legacy. Allies within Imperial Legacy deal 50% more DMG and restore 5% Max HP each turn. Imperial Legacy disappears when Zhu Yuanzhang dies.', 'descId': 'Saat musuh gugur di atas api sendiri, memiliki <color=#000001>{0}</c> peluang membentuk Dominion, DMG sekutu yang berada dalam Dominion meningkat 50%, serta setiap ronde memulihkan HP sebesar 5% HP Maks, Dominion menghilang setelah Zhu Yuanzhang gugur',
         'values': [50, 50, 65, 65, 80, 80, 95, 100], 'suffix': '%', 'params': ''},
  };

  /// strategy rows = hero expertise pool. lv 1/2/3 = Basic/Mid/Advanced
  /// (unlocked at Grade 6/4/2); overlay = max stack (Basic 3, Mid 2, Adv 1).
  static const Map<int, Map<String, dynamic>> STRATEGIES = {
    10001: {'value': '30', 'vSuffix': '%', 'params': '30', 'pSuffix': '%',
         'target': '4,0', 'lv': 3, 'overlay': 1, 'desc': 'Hero\'s DMG dealt +{0}, DMG taken -{1}', 'descId': 'DMG yang diberikan Hero +{0}, DMG yang diterima -{1}'},
    10002: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 1, 'overlay': 1, 'desc': '{0} has a 40% chance to retain {1} Rage after using a skill', 'descId': '{0} memiliki peluang 40% untuk mempertahankan {1} Amarah setelah menggunakan skill'},
    20001: {'value': '2', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 1, 'overlay': 3, 'desc': '{0}\'s ATK +{1}', 'descId': '{0} ATK +{1}'},
    20002: {'value': '20', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 1, 'overlay': 3, 'desc': '{0}\'s HP +{1}', 'descId': '{0} HP +{1}'},
    20003: {'value': '5', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 1, 'overlay': 3, 'desc': '{0}\'s ATK +{1}', 'descId': '{0} ATK +{1}'},
    20004: {'value': '5', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 1, 'overlay': 3, 'desc': '{0}\'s HP +{1}', 'descId': '{0} HP +{1}'},
    20005: {'value': '5', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 1, 'overlay': 3, 'desc': 'DMG dealt by {0} +{1}', 'descId': '{0} DMG yang diberikan +{1}'},
    20006: {'value': '5', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 1, 'overlay': 3, 'desc': 'DMG taken by {0} -{1}', 'descId': '{0} DMG yang diterima -{1}'},
    20007: {'value': '2', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 1, 'overlay': 3, 'desc': '{0} restores {1} HP each round.', 'descId': '{0} memulihkan {1} HP per ronde'},
    20008: {'value': '8', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 2, 'overlay': 2, 'desc': '{0} gains {1} Leech.', 'descId': '{0} mendapatkan {1} Leech'},
    20009: {'value': '8', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 2, 'overlay': 2, 'desc': '{0} gains {1} Dodge.', 'descId': '{0} mendapatkan {1} Dodge'},
    20010: {'value': '8', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 2, 'overlay': 2, 'desc': '{0} ignores {1} Dodge.', 'descId': '{0} mengabaikan {1} Dodge'},
    20011: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '10,0', 'lv': 3, 'overlay': 1, 'desc': 'When {0} attacks, there is a 30% chance to deal ({1}*ATK) additional True DMG.', 'descId': '{0} saat menyerang memiliki 30% peluang menghasilkan True DMG tambahan sebesar {1} ATK'},
    30101: {'value': '50', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3101', 'lv': 3, 'overlay': 1, 'desc': 'Changes HP restored by Longspearman\'s stabs to {0} of the HP lost.', 'descId': 'HP yang dipulihkan dari stab Prajurit Tombak berubah menjadi {0} HP yang hilang'},
    30102: {'value': '5', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 3, 'overlay': 1, 'desc': 'Spearman restores ({0}*own level) HP when attacking.', 'descId': 'Saat Prajurit Tombak melakukan ATK, regen ({0} × level sendiri) HP'},
    30103: {'value': '2', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3101', 'lv': 3, 'overlay': 1, 'desc': 'Longspearman restores HP equal to {0} of Max HP after a successful dodge.', 'descId': 'Setelah Prajurit Tombak Panjang berhasil dodge, memulihkan ({0}*HP Maks) HP'},
    30201: {'value': '40', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3102', 'lv': 3, 'overlay': 1, 'desc': 'The effect of Lancer\'s Exclusive Equipment is always calculated based on {0} soldier(s).', 'descId': 'Efek equipment eksklusif Prajurit Lancer selalu dihitung berdasarkan {0} prajurit'},
    30202: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3102', 'lv': 3, 'overlay': 1, 'desc': 'Lancer\'s Project Range +{0}', 'descId': 'Jangkauan Project Prajurit Lancer +{0}'},
    30301: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' DMG dealt to the disarmed target +{0}', 'descId': 'DMG semua sekutu yang diberikan ke target Disarm +{0}'},
    30302: {'value': '', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3103', 'lv': 3, 'overlay': 1, 'desc': 'Dagger-axe Soldier has full initial Rage.', 'descId': 'Initial Rage Prajurit Kapak Belati adalah Rage Penuh'},
    30401: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 3, 'overlay': 1, 'desc': 'When Spearman takes DMG, if the attacker has higher ATK, DMG -{0}', 'descId': 'Saat Prajurit Tombak menerima DMG, jika penyerang memiliki ATK yang lebih tinggi, DMG -{0}'},
    30402: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3104', 'lv': 3, 'overlay': 1, 'desc': 'Modao Soldier ignores {0} DMG Reduction.', 'descId': 'Prajurit Pedang Modao ignore {0} DMG Reduction'},
    30501: {'value': '10', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3106', 'lv': 3, 'overlay': 1, 'desc': 'Twin Spearman\'s Parry Rate +{0} after Unbridled Dance.', 'descId': 'Setelah Unbridled Dance Prajurit Tombak Ganda, Parry Rate +{0}'},
    30502: {'value': '10', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3106', 'lv': 3, 'overlay': 1, 'desc': 'Twin Spearman\'s Unbridled Dance DMG +{0}.', 'descId': 'DMG Unbridled Dance Prajurit Tombak Ganda + {0}'},
    30503: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3106', 'lv': 3, 'overlay': 1, 'desc': 'Twin Spearman\'s Unbridled Dance dash range +{0}', 'descId': 'Jangkauan serangan Unbridled Dance Prajurit Tombak Ganda +{0}'},
    30601: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'Shield Effect on all allies +{0}', 'descId': 'Efek Perisai pada semua sekutu +{0}'},
    30602: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3201', 'lv': 3, 'overlay': 1, 'desc': 'When Shield Soldier has a Shield, their DMG taken -{0}.', 'descId': 'Saat Prajurit Saber & Perisai memiliki Perisai, DMG yang diterima -{0}'},
    30701: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3202', 'lv': 3, 'overlay': 1, 'desc': 'Rounds of Heavy Shield Soldier\'s Shield Stance Duration +{0}', 'descId': 'Ronde durasi Perisai Berdiri Prajurit Perisai Berat +{0}'},
    30702: {'value': '20', 'vSuffix': '%', 'params': '50', 'pSuffix': '%',
         'target': '1,3202', 'lv': 3, 'overlay': 1, 'desc': 'When Heavy Shield Soldier\'s HP drops to 50% for the first time, restores HP by {0} of Max HP.', 'descId': 'Saat HP Prajurit Perisai Berat turun hingga 50% untuk pertama kalinya, memulihkan HP sebesar {0} dari HP Maks'},
    30801: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3203', 'lv': 3, 'overlay': 1, 'desc': 'Charge DMG dealt by Spear & Shield Soldier +{0}', 'descId': 'Charge DMG Prajurit Tombak & Perisai +{0}'},
    30802: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3203', 'lv': 3, 'overlay': 2, 'desc': 'Block Times of Spear & Shield Soldier +{0}', 'descId': 'Kuota Block Prajurit Tombak & Perisai +{0}'},
    30901: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3204', 'lv': 3, 'overlay': 1, 'desc': 'Rounds of Silence inflicted by Hammer & Shield Soldier +{0}', 'descId': 'Ronde durasi Silence Prajurit Palu & Perisai +{0}'},
    30902: {'value': '50', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3204', 'lv': 3, 'overlay': 1, 'desc': 'Hammer & Shield Soldier\'s Earthshaker also reduces the target\'s current Rage by {0} when silencing them.', 'descId': 'Earthshaker dari Prajurit Palu & Perisai juga akan mengurangi nilai Rage target saat efek Silence aktif{0}'},
    31001: {'value': '50', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3301', 'lv': 3, 'overlay': 2, 'desc': 'Longbowman\'s Scatter has a {0} chance of attacking 1 more target', 'descId': 'Scatter Prajurit Busur Panjang memiliki {0} peluang untuk ATK 1 target lagi'},
    31002: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3301', 'lv': 3, 'overlay': 1, 'desc': 'Longbowman\'s ATK +{0}', 'descId': 'ATK Prajurit Busur Panjang +{0}'},
    31101: {'value': '50', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3302', 'lv': 3, 'overlay': 2, 'desc': 'Crossbowman\'s Rapid Fire has a {0} chance of firing 1 more time', 'descId': 'Rapid Fire Prajurit Busur Silang memiliki {0} peluang untuk menembak 1 kali lagi'},
    31102: {'value': '3', 'vSuffix': '%', 'params': '5', 'pSuffix': '',
         'target': '1,3302', 'lv': 3, 'overlay': 1, 'desc': 'Every 5th shooting of Crossbowman deals extra ({0}*target\'s Max HP) DMG to the target.', 'descId': 'Setiap tembakan ke-5 Prajurit Busur Silang menyebabkan ({0}*HP Maks) DMG'},
    31201: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' DMG dealt to the poisoned target +{0}', 'descId': 'DMG yang diberikan kepada target yang terkena poison +{0}'},
    31202: {'value': '40', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3303', 'lv': 3, 'overlay': 1, 'desc': 'Toxibowman\'s Poison DMG +{0}', 'descId': 'DMG Poison Prajurit Busur Racun +{0}'},
    31301: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3304', 'lv': 3, 'overlay': 1, 'desc': 'Hunter\'s ATK +{0} when attacking Monsters.', 'descId': 'Saat pemburu menyerang beast, ATK +{0}'},
    31302: {'value': '5', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3304', 'lv': 3, 'overlay': 1, 'desc': 'Allies\' HP Restored by Hunter\'s Exclusive Equipment +{0}', 'descId': 'HP Sekutu Dipulihkan oleh Equipment Eksklusif Pemburu +{0}'},
    31401: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3305', 'lv': 3, 'overlay': 1, 'desc': 'When Improved Crossbowman knocks the target back, also makes them unable to move for 1 round', 'descId': 'Saat Prajurit Busur Kuat menjatuhkan target, itu juga mencegah target berpindah selama 1 ronde.'},
    31402: {'value': '2', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3305', 'lv': 3, 'overlay': 1, 'desc': 'After Improved Crossbowman draws, they can shoot for {0} round(s)', 'descId': 'Prajurit Busur Kuat dapat menembak selama {0} ronde setelah menarik tali'},
    31501: {'value': '20', 'vSuffix': '%', 'params': '50', 'pSuffix': '%',
         'target': '1,3401', 'lv': 3, 'overlay': 1, 'desc': 'When Sword Cavalry\'s HP drops to 50% for the first time, ATK +{0}.', 'descId': 'Saat HP Kavaleri Pedang turun hingga 50% untuk pertama kalinya, ATK +{0}'},
    31502: {'value': '15', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3401', 'lv': 3, 'overlay': 1, 'desc': 'Sword Cavalry\'s Exclusive\'s chance of releasing Leap Slash continuously +{0}', 'descId': 'Peluang Leap Slash beruntun Equipment Eksklusif Kavaleri Pedang +{0}'},
    31601: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3402', 'lv': 3, 'overlay': 1, 'desc': 'When Spear Cavalry takes True DMG from attacks, restores ({0}*this DMG) HP.', 'descId': 'Ketika Kavaleri Tombak menerima True DMG dari ATK, memulihkan ({0}*DMG ini) HP'},
    31602: {'value': '2', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3402', 'lv': 3, 'overlay': 1, 'desc': 'Spear Cavalry keeps {0} Rage after casting skills.', 'descId': 'Kavaleri Tombak mempertahankan {0} Rage setelah melepaskan skill'},
    31701: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3403', 'lv': 3, 'overlay': 1, 'desc': 'Chop DMG dealt by Broadsword Cavalry +{0}', 'descId': 'DMG chop Kavaleri Pedang Lebar meningkat {0}'},
    31702: {'value': '10', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3403', 'lv': 3, 'overlay': 1, 'desc': 'When Broadsword Cavalry\'s exclusive equipment switches the target, reserved DMG +{0}.', 'descId': 'Saat equipment eksklusif Kavaleri Pedang Lebar mengganti target, DMG yang dipertahankan +{0}'},
    31801: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' DMG dealt to the stunned target +{0}', 'descId': 'DMG semua unit yang diberikan kepada target yang terkena stun +{0}'},
    31802: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3404', 'lv': 3, 'overlay': 1, 'desc': 'Rounds of Stun inflicted by Heavy Cavalry +{0} when they collide.', 'descId': 'Ronde durasi Stun yang disebabkan oleh Collide Kavaleri Berat +{0}'},
    31901: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,4', 'lv': 3, 'overlay': 1, 'desc': 'Cavalry\'s Move Range +{0}', 'descId': 'Jangkauan Gerakan Kavaleri +{0}'},
    31902: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3405', 'lv': 3, 'overlay': 1, 'desc': 'Bow Cavalry\'s ATK +{0}', 'descId': 'ATK Kavaleri Panah +{0}'},
    32001: {'value': '100', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3406', 'lv': 3, 'overlay': 1, 'desc': 'When Axe Cavalry deals DMG to the target\'s shield, converts the DMG into a shield owned by self.', 'descId': 'Saat Kavaleri Kapak merusak perisai musuh, DMG tersebut dikonversi menjadi perisai sendiri'},
    32002: {'value': '100', 'vSuffix': '%', 'params': '4', 'pSuffix': '',
         'target': '1,3406', 'lv': 3, 'overlay': 1, 'desc': 'When Axe Cavalry breaks the Shield, deals ({0}*the Shield value) additional True DMG to up to 4 enemies within 1 tile around the target.', 'descId': 'Saat Kavaleri Kapak menghancurkan perisai, memberikan ekstra ({0}*Shield) True DMG hingga ke 4 musuh dalam 1 kotak dari target'},
    32101: {'value': '15', 'vSuffix': '%', 'params': '15', 'pSuffix': '%',
         'target': '1,3205', 'lv': 3, 'overlay': 1, 'desc': 'After Sword&Shield Soldier\'s Leap is stacked to the max limit, HP +{0}, ATK +{1}.', 'descId': 'Setelah Prajurit Pedang & Perisai mencapai level maksimal, HP +{0}, ATK +{1}'},
    32102: {'value': '5', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3205', 'lv': 3, 'overlay': 1, 'desc': 'Changes DMG Increase effect of Sword&Shield Soldier\'s exclusive equipment to {0}.', 'descId': 'DMG efek equipment eksklusif Prajurit Pedang & Perisai diubah menjadi {0}'},
    33001: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3306', 'lv': 3, 'overlay': 1, 'desc': 'Fire Bowman\'s Max Fire Intensity Level +{0}', 'descId': 'Level Intensitas Api Maksimum Pemanah +{0}'},
    33002: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3306', 'lv': 3, 'overlay': 1, 'desc': 'Fire Bowman\'s DMG +{0} when triggering fire.', 'descId': 'DMG efek api Prajurit Busur Api +{0}'},
    33101: {'value': '60', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3105', 'lv': 3, 'overlay': 1, 'desc': 'Changes Long Swordsman\'s exclusive equipment effect to: Restores ({0}*DMG taken) HP.', 'descId': 'Efek equipment eksklusif Prajurit Pedang Panjang diubah menjadi pemulihan {0} dari DMG sebagai HP'},
    33102: {'value': '50', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3105', 'lv': 3, 'overlay': 1, 'desc': 'Long Swordsman\'s Bleeding effect also reduces the target\'s HP Restoration by {0}.', 'descId': 'Efek Bleed Prajurit Pedang Panjang juga mengurangi pemulihan HP target sebesar {0}'},
    33103: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' DMG dealt to the Bleed target +{0}', 'descId': 'DMG yang diberikan semua unit terhadap target bleed +{0}'},
    34001: {'value': '1', 'vSuffix': '', 'params': '10', 'pSuffix': '%',
         'target': '1,3206', 'lv': 3, 'overlay': 1, 'desc': 'Axe&Shield Soldier\'s Bounce Time of Whirling Axe +{0}. Shield Bash\'s Chance of Stunning the Target +{1}.', 'descId': 'Jumlah pantulan Whirling Axe Prajurit Kapak & Perisai +{0}, peluang Shield Bash membuat target stun +{1}'},
    34002: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3206', 'lv': 3, 'overlay': 1, 'desc': 'Axe&Shield Soldier\'s ATK Range +{0}', 'descId': 'Jangkauan ATK Prajurit Kapak & Perisai +{0}'},
    34003: {'value': '1', 'vSuffix': '', 'params': '15', 'pSuffix': '%',
         'target': '1,3206', 'lv': 3, 'overlay': 1, 'desc': 'Axe & Shield Soldier\'s Whirling Axe selection range +{0}, and Whirling Axe DMG +{1}.', 'descId': 'Jangkauan target Whirling Axe Prajurit Kapak & Perisai +{0}, DMG Whirling Axe +{1}'},
    40101: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 3, 'overlay': 1, 'desc': 'Spearman\'s ATK Range +{0}', 'descId': 'Jangkauan ATK Prajurit Tombak +{0}'},
    40102: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 2, 'overlay': 1, 'desc': 'Spearman\'s Max Rage -{0}', 'descId': 'Rage Maks Prajurit Tombak -{0}'},
    40103: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 3, 'overlay': 1, 'desc': 'When Spearman attacks, grants {0} extra Rage', 'descId': 'Saat Prajurit Tombak ATK, memberikan {0} Rage ekstra'},
    40104: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 2, 'overlay': 1, 'desc': 'After Spearman kills a target, ATK +{0}', 'descId': 'Setelah Prajurit Tombak membunuh target, ATK +{0}'},
    40105: {'value': '10', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 2, 'overlay': 2, 'desc': 'For every 10% HP lost by Spearman, DMG dealt +{0}', 'descId': 'Saat prajurit tombak melakukan ATK, untuk setiap 10% HP yang hilang dari Prajurit Tombak, DMG yang diberikan +{0}'},
    40106: {'value': '15', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 2, 'overlay': 2, 'desc': 'Spearman\'s HP Restoration +{0}', 'descId': 'Pemulihan HP Prajurit Tombak +{0}'},
    40201: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,2', 'lv': 2, 'overlay': 1, 'desc': 'Shield Soldier\'s Max Rage -{0}', 'descId': 'Rage Maks Prajurit Perisai -{0}'},
    40202: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,2', 'lv': 3, 'overlay': 1, 'desc': 'When Shield Soldier attacks, grants {0} extra Rage', 'descId': 'Saat Prajurit Perisai ATK, memberikan {0} Rage ekstra'},
    40203: {'value': '10', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,2', 'lv': 2, 'overlay': 2, 'desc': 'When being inflicted with debuffs, Shield Soldier has a {0} chance of gaining immunity', 'descId': 'Saat terkena efek debuff, Prajurit Perisai memiliki {0} peluang untuk mendapatkan Immune'},
    40204: {'value': '2', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,2', 'lv': 3, 'overlay': 2, 'desc': 'Shield Soldier restores ({0}*current HP) HP each round', 'descId': 'Prajurit Perisai memulihkan ({0}*HP saat ini) HP setiap ronde'},
    40205: {'value': '15', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,2', 'lv': 2, 'overlay': 2, 'desc': 'Shield Soldier\'s HP Restoration +{0}', 'descId': 'Pemulihan HP Prajurit Perisai +{0}'},
    40206: {'value': '3', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,2', 'lv': 2, 'overlay': 2, 'desc': 'Shield Soldier\'s DMG taken -{0}', 'descId': 'DMG yang diterima Prajurit Perisai -{0} poin'},
    40207: {'value': '2', 'vSuffix': '%', 'params': '30', 'pSuffix': '%',
         'target': '2,2', 'lv': 3, 'overlay': 1, 'desc': 'Shield Soldier has a 30% chance to deal additional True DMG by {0} of self Max HP to up to 4 enemies within 1 tile each round.', 'descId': 'Setiap ronde, Prajurit Perisai memiliki 30% peluang untuk memberikan True DMG ekstra sebesar ({0}*HP Maks sendiri) kepada maksimal 4 musuh dalam 1 kotak'},
    40301: {'value': '4', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,3', 'lv': 2, 'overlay': 2, 'desc': 'Bowman\'s ATK +{0}', 'descId': 'ATK Pemanah +{0}'},
    40302: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,3', 'lv': 3, 'overlay': 1, 'desc': 'Bowman\'s ATK Range +{0}', 'descId': 'Jangkauan ATK Pemanah +{0}'},
    40303: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,3', 'lv': 2, 'overlay': 1, 'desc': 'Bowman\'s Max Rage -{0}', 'descId': 'Rage Maks Pemanah -{0}'},
    40304: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,3', 'lv': 3, 'overlay': 1, 'desc': 'When Bowman attacks, grants {0} extra Rage', 'descId': 'Saat Pemanah melakukan ATK, memberikan {0} Rage ekstra'},
    40305: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,3', 'lv': 2, 'overlay': 1, 'desc': 'After Bowman kills a target, ATK +{0}', 'descId': 'Setelah Pemanah membunuh target, ATK +{0}'},
    40306: {'value': '2', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,3', 'lv': 2, 'overlay': 2, 'desc': 'For every 1 tile between Bowman and the target, DMG Dealt +{0}.', 'descId': 'Setiap 1 kotak jarak antara Pemanah dan target, DMG yang diberikan +{0}'},
    40401: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,4', 'lv': 2, 'overlay': 1, 'desc': 'Cavalry\'s Max Rage -{0}', 'descId': 'Rage Maks Kavaleri -{0}'},
    40402: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,4', 'lv': 3, 'overlay': 1, 'desc': 'When Cavalry attacks, grants {0} extra Rage', 'descId': 'Saat Kavaleri ATK, memberikan {0} Rage ekstra'},
    40403: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '2,4', 'lv': 2, 'overlay': 1, 'desc': 'After Cavalry kills a target, ATK +{0}', 'descId': 'Setelah Kavaleri membunuh target, ATK +{0}'},
    40404: {'value': '15', 'vSuffix': '%', 'params': '30', 'pSuffix': '%',
         'target': '2,4', 'lv': 2, 'overlay': 2, 'desc': 'When Cavalry\'s HP drops to 30% for the first time, restores HP by {0} of Max HP.', 'descId': 'Saat HP Kavaleri pertama kali turun ke 30%, memulihkan {0} HP Maks'},
    40405: {'value': '15', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,4', 'lv': 2, 'overlay': 2, 'desc': 'Cavalry\'s HP Restoration +{0}', 'descId': 'Pemulihan HP Kavaleri +{0}'},
    40406: {'value': '2', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,4', 'lv': 3, 'overlay': 2, 'desc': 'When Cavalry attacks, deals ({0}*target\'s current HP) additional DMG.', 'descId': 'Saat Kavaleri ATK, memberikan ekstra ({0}*HP saat ini) DMG'},
    40407: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,4', 'lv': 3, 'overlay': 1, 'desc': 'Converts {0} of Cavalry\'s DMG dealt into True DMG.', 'descId': '{0} dari DMG yang diberikan Kavaleri diubah menjadi True DMG'},
    50001: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3101', 'lv': 3, 'overlay': 1, 'desc': 'Longspearman\'s Stab restores HP for the ally with the lowest HP ratio by {0} of their lost HP.', 'descId': 'Stab Prajurit Tombak memulihkan HP untuk sekutu dalam pasukan dengan rasio HP terendah sebesar {0} dari HP mereka yang hilang'},
    50002: {'value': '5', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 3, 'overlay': 1, 'desc': 'Spearman\'s Any Dodge +{0}. After dodging, Rage +1.', 'descId': 'Dodge Prajurit Tombak mana pun +{0}, setelah dodge, Rage +1'},
    50003: {'value': '1', 'vSuffix': '', 'params': '20', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'When an enemy dies, ATK +{0} for up to 4 allies within 1 tile', 'descId': 'Saat musuh mati, ATK +{0}untuk hingga 4 sekutu dalam 1 kotak, stack hingga 20 kali'},
    50004: {'value': '60', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3104', 'lv': 3, 'overlay': 1, 'desc': 'Modifies Modao Soldier\'s counter effect on Cavalry to {0}', 'descId': 'Memodifikasi efek pengekangan Prajurit Pedang Modao pada Kavaleri menjadi {0}'},
    50005: {'value': '8', 'vSuffix': '', 'params': '15', 'pSuffix': '%',
         'target': '1,3105', 'lv': 3, 'overlay': 1, 'desc': 'Long Swordsman\'s ATK +{0} and they gain {1} DMG Reduction.', 'descId': 'ATK Prajurit Pedang Panjang +{0}, dan mendapatkan {1} DMG Reduction'},
    50006: {'value': '2', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3201', 'lv': 3, 'overlay': 1, 'desc': 'Saber & Shield Soldier grants shield on {0} more allies', 'descId': 'Prajurit Saber & Perisai memberikan tambahan perisai pada {0} sekutu'},
    50007: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3102', 'lv': 3, 'overlay': 1, 'desc': 'Lancer\'s Project DMG +{0}', 'descId': 'DMG Project Prajurit Lancer +{0}'},
    50008: {'value': '5', 'vSuffix': '%', 'params': '1', 'pSuffix': '',
         'target': '1,3106', 'lv': 3, 'overlay': 1, 'desc': 'Twin Spearman\'s Parry Rate +{0} after Unbridled Dance, Rage +1 after Parry.', 'descId': 'Setelah Unbridled Dance Prajurit Tombak Ganda, Parry Rate +{0}, dan setelah Parry, Rage bertambah 1'},
    50009: {'value': '10', 'vSuffix': '', 'params': '20', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'When an ally dies, Max HP +{0} for up to 4 allies within 1 tile, stackable up to 20 times.', 'descId': 'Saat sekutu mati, HP Maks +{0} untuk maksimal 4 sekutu dalam 1 kotak, stack hingga 20 kali'},
    50010: {'value': '4', 'vSuffix': '', 'params': '40', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' Max HP +{1}, ATK +{0}', 'descId': 'HP Maks semua sekutu +{1}, ATK +{0}'},
    50011: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,3', 'lv': 3, 'overlay': 1, 'desc': 'Bowman\'s DMG dealt to the target with HP over 50% +{0}', 'descId': 'DMG Pemanah terhadap target dengan HP lebih dari 50% +{0}'},
    50012: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' HP Restoration +{0}', 'descId': 'Pemulihan HP semua sekutu +{0}'},
    50013: {'value': '10', 'vSuffix': '%', 'params': '10', 'pSuffix': '%',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' DMG dealt +{0}, DMG taken -{1}', 'descId': 'DMG yang diberikan semua sekutu +{0}, DMG yang diterima -{1}'},
    50014: {'value': '', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' Max Rage can be exceeded', 'descId': 'Batas Rage yang dapat dilampaui semua unit'},
    50015: {'value': '', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3305', 'lv': 3, 'overlay': 1, 'desc': 'Improved Crossbowman\'s Anchor is always calculated based on the farthest distance', 'descId': 'Anchor Prajurit Busur Kuat selalu dihitung berdasarkan jarak terjauh'},
    50016: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,4', 'lv': 3, 'overlay': 1, 'desc': 'Cavalry\'s DMG dealt to the target with no allies around +{0}', 'descId': 'DMG Kavaleri yang diberikan ke target tanpa sekutu di sekitar +{0}'},
    50017: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3401', 'lv': 3, 'overlay': 1, 'desc': 'Sword Cavalry\'s Leap Slash Range +{0}', 'descId': 'Jangkauan Leap Slash Kavaleri Pedang +{0}'},
    50018: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3106', 'lv': 3, 'overlay': 1, 'desc': 'Twin Spearman\'s Stage of Unbridled Dance +{0}', 'descId': 'Tahap Unbridled Dance Prajurit Tombak Ganda +{0}'},
    50019: {'value': '20', 'vSuffix': '%', 'params': '30', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'If the battle lasts for more than 30 minutes, all allies\' DMG dealt +{0}.', 'descId': 'Jika pertempuran berlangsung selama lebih dari 30 menit, DMG yang diberikan semua prajurit sekutu +{0}'},
    50020: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,2', 'lv': 3, 'overlay': 1, 'desc': 'Shield Soldier\'s DMG taken -{0} when there are no allies around.', 'descId': 'Ketika tidak ada sekutu di sekitar Prajurit Perisai, DMG yang diterima -{0}'},
    50021: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,1', 'lv': 3, 'overlay': 1, 'desc': 'DMG dealt by Spearman to Heroes +{0}', 'descId': 'DMG Prajurit Tombak pada Hero +{0}'},
    50022: {'value': '2', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3102', 'lv': 3, 'overlay': 1, 'desc': 'After Lancers kill the target by projecting, increases Rage by {0}.', 'descId': 'Rage Prajurit Lancer meningkat {0} setelah menembak dan membunuh target'},
    50023: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies have a {0} chance of dodging building\'s attacks.', 'descId': 'Semua sekutu memiliki {0} peluang untuk dodge serangan bangunan'},
    50024: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'When enemy soldiers outnumber ally soldiers, all ally soldiers\' DMG dealt +{0}.', 'descId': 'Ketika jumlah prajurit musuh lebih banyak dari kita, DMG yang ditimbulkan oleh seluruh prajurit kita meningkat {0}'},
    50025: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '2,4', 'lv': 3, 'overlay': 1, 'desc': 'Cavalry\'s DMG dealt to the target with lower ATK +{0}', 'descId': 'DMG yang disebabkan oleh Kavaleri terhadap target dengan ATK lebih rendah meningkat {0}'},
    50026: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3203', 'lv': 3, 'overlay': 1, 'desc': 'When Spear & Shield Soldier has no allies around, DMG dealt +{0}.', 'descId': 'Saat Prajurit Tombak & Perisai tidak memiliki sekutu di sekitar, DMG yang diberikan +{0}'},
    50027: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3302', 'lv': 3, 'overlay': 1, 'desc': 'Crossbowman\'s Rapid Fire Attempt +{0}', 'descId': 'Jumlah Rapid Fire Prajurit Busur Silang +{0}'},
    50028: {'value': '10', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'Restores {0} HP for all allies at the start of each round.', 'descId': 'Semua unit memulihkan HP sebesar {0} di awal setiap ronde'},
    50029: {'value': '15', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'If all allies are on the attacking side, ATK +{0}.', 'descId': 'Saat seluruh unit berada di sisi penyerang, ATK +{0}'},
    50030: {'value': '2', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3101', 'lv': 3, 'overlay': 1, 'desc': 'When Longspearman attacks, deals ({0}*target\'s max HP) additional True DMG.', 'descId': 'Saat Prajurit Tombak ATK, memberikan ({0} HP Maks target) ekstra True DMG'},
    50031: {'value': '1', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3304', 'lv': 3, 'overlay': 1, 'desc': 'Duration of Inspire released by Hunter +{0}', 'descId': 'Durasi ronde Inspire Pemburu +{0}'},
    50032: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'The DMG dealt by all allies\' first 20 attacks +{0}', 'descId': 'DMG yang diberikan 20 ATK pertama meningkat {0}'},
    50033: {'value': '15', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' DMG Reduction +{0}', 'descId': 'Seluruh unit mendapatkan {0} DMG Reduction'},
    50034: {'value': '50', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3304', 'lv': 3, 'overlay': 1, 'desc': 'Hunter\'s Max Rage -{0}', 'descId': 'Rage Maks Pemburu -{0}'},
    50035: {'value': '50', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3305', 'lv': 3, 'overlay': 1, 'desc': 'When Improved Crossbowman is dying for the first time, restores HP by {0} of Max HP.', 'descId': 'Saat Prajurit Busur Kuat pertama kali sekarat, memulihkan {0} HP Maks'},
    50036: {'value': '50', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3306', 'lv': 3, 'overlay': 1, 'desc': 'When Fire Bowman shoots a fire arrow, there is a {0} chance of spreading the fire by 1 tile towards the enemies.', 'descId': 'Saat Prajurit Busur Api menembakkan roket, ada {0} peluang merambat 1 kotak ke arah musuh'},
    50037: {'value': '10', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3402', 'lv': 3, 'overlay': 1, 'desc': 'Spear Cavalry\'s Sweep +{0} Leech', 'descId': 'Sweep Kavaleri Tombak +{0} Leech'},
    50038: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3402', 'lv': 3, 'overlay': 1, 'desc': 'Spear Cavalry\'s DMG Dealt to the farthest target within the Sweep Range +{0}', 'descId': 'Saat Kavaleri Tombak melakukan sweep, DMG terhadap target terjauh dalam jangkauan sweep +{0}'},
    50039: {'value': '20', 'vSuffix': '%', 'params': '4', 'pSuffix': '',
         'target': '1,3103', 'lv': 3, 'overlay': 1, 'desc': 'When Dagger-axe Soldier attacks, deals ({0}*ATK) additional True DMG to up to 4 enemies within 1 tile around the target.', 'descId': 'Saat Prajurit Kapak Belati menyerang, hingga 4 musuh dalam 1 kotak dari target menerima True DMG ekstra ({0}*ATK)'},
    50040: {'value': '15', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3104', 'lv': 3, 'overlay': 1, 'desc': 'When Modao Soldier has full HP, DMG Dealt +{0}.', 'descId': 'Saat Prajurit Pedang Modao memiliki HP penuh, DMG yang diberikan +{0}'},
    50041: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3202', 'lv': 3, 'overlay': 1, 'desc': 'Heavy Shield Soldier\'s Max HP +{0}', 'descId': 'HP Maks Prajurit Perisai Berat +{0}'},
    50042: {'value': '1', 'vSuffix': '%', 'params': '50', 'pSuffix': '%',
         'target': '1,3202', 'lv': 3, 'overlay': 1, 'desc': 'When Heavy Shield Soldier\'s HP is below 50%, restores {0} of the Max HP each round.', 'descId': 'Saat HP Prajurit Perisai Berat di bawah 50%, memulihkan {0} HP Maks setiap ronde'},
    50043: {'value': '10', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3202', 'lv': 3, 'overlay': 1, 'desc': 'Heavy Shield Soldier restores HP by {0} of lost HP after Shield Stance ends.', 'descId': 'Setelah Prajurit Perisai Berat selesai mendirikan perisai, memulihkan {0} HP yang hilang'},
    50044: {'value': '10', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3303', 'lv': 3, 'overlay': 1, 'desc': 'Toxibowman\'s Exclusive Equipment has {0} more chance to paralyze the target.', 'descId': 'Peluang efek equipment eksklusif Prajurit Busur Racun membuat target Paralysis +{0}'},
    50045: {'value': '15', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3303', 'lv': 3, 'overlay': 1, 'desc': 'Target\'s HP Restoration Reduction caused by Toxibowman\'s Poison +{0}', 'descId': 'Poison Prajurit Busur Racun mengurangi pemulihan HP target sebesar +{0}'},
    50046: {'value': '20', 'vSuffix': '%', 'params': '1', 'pSuffix': '',
         'target': '1,3301', 'lv': 3, 'overlay': 1, 'desc': 'Longbowman\'s Max Rage +1, DMG Dealt +{0}', 'descId': 'Rage Maks Prajurit Busur Panjang +1, DMG yang diberikan +{0}'},
    50047: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3404', 'lv': 3, 'overlay': 1, 'desc': 'Heavy Cavalry\'s Collision DMG +{0}', 'descId': 'DMG Collide Kavaleri Berat +{0}'},
    50048: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3404', 'lv': 3, 'overlay': 1, 'desc': 'Upon entering the battle, Heavy Cavalry\'s DMG taken in the first 5 rounds -{0}.', 'descId': 'DMG yang diterima Kavaleri Berat berkurang {0} di 5 ronde pertama sebelum battle'},
    50049: {'value': '5', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'When an enemy dies, restores HP by {0} of Max HP for the ally with the lowest HP ratio within 3 tiles.', 'descId': 'Saat musuh mati, sekutu dengan rasio HP terendah dalam radius 3 kotak memulihkan {0} HP Maks'},
    50050: {'value': '50', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3405', 'lv': 3, 'overlay': 1, 'desc': 'Bow Cavalry\'s ATK +1% for every tile they move, stackable up to {0} times.', 'descId': 'Setiap Kavaleri Panah bergerak 1 kotak, ATK +1%, stack hingga {0} kali'},
    50051: {'value': '30', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3405', 'lv': 3, 'overlay': 1, 'desc': 'After Bow Cavalry\'s Rage is full, increases their next attack\'s DMG dealt by {0}.', 'descId': 'Setelah Kavaleri Panah mencapai Rage penuh, DMG serangan berikutnya +{0}'},
    50052: {'value': '50', 'vSuffix': '%', 'params': '3', 'pSuffix': '',
         'target': '1,3406', 'lv': 3, 'overlay': 1, 'desc': 'Increases the Axe Cavalry\'s DMG dealt by every 3rd attack by {0}.', 'descId': 'Setiap serangan ke-3 Kavaleri Kapak, DMG yang diberikan +{0}'},
    50053: {'value': '10', 'vSuffix': '%', 'params': '10', 'pSuffix': '%',
         'target': '1,3406', 'lv': 3, 'overlay': 1, 'desc': 'Axe Cavalry\'s ATK +{0}, DMG Dealt +{1}', 'descId': 'ATK Kavaleri Kapak +{0}, DMG yang diberikan +{1}'},
    50054: {'value': '2', 'vSuffix': '', 'params': '', 'pSuffix': '',
         'target': '1,3403', 'lv': 3, 'overlay': 1, 'desc': 'Broadsword Cavalry keeps {0} Rage after casting skills.', 'descId': 'Kavaleri Pedang Lebar mempertahankan {0} Rage setelah menggunakan skill'},
    50055: {'value': '10', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3302', 'lv': 3, 'overlay': 1, 'desc': 'Crossbowman Exclusive Equipment\'s initial Dodge Rate +{0}.', 'descId': 'Initial Dodge Rate Equipment Eksklusif Prajurit Busur Silang +{0}'},
    50056: {'value': '1', 'vSuffix': '%', 'params': '20', 'pSuffix': '%',
         'target': '2,2', 'lv': 3, 'overlay': 1, 'desc': 'When Shield Soldiers are attacked, they have a 20% chance to reflect additional True DMG equal to {0} of Max HP to the attacker.', 'descId': 'Saat Prajurit Perisai menerima ATK, memiliki 20% peluang Reflect True DMG tambahan sebesar {0} HP Maks kepada penyerang'},
    50057: {'value': '1', 'vSuffix': '%', 'params': '2', 'pSuffix': '%',
         'target': '1,3206', 'lv': 3, 'overlay': 1, 'desc': 'For every 2% HP lost by Axe & Shield Soldiers, they gain {0} Leech.', 'descId': 'Setiap Prajurit Kapak & Perisai kehilangan 2% HP, mendapatkan {0} Leech'},
    50058: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '1,3304', 'lv': 3, 'overlay': 1, 'desc': 'When Hunters inspiring, they have a {0} chance to remove 1 debuff from allies.', 'descId': 'Saat Pemburu melepaskan Inspire, memiliki {0} peluang menghapus 1 efek Debuff sekutu'},
    50059: {'value': '20', 'vSuffix': '%', 'params': '', 'pSuffix': '',
         'target': '0,0', 'lv': 3, 'overlay': 1, 'desc': 'All allies\' DMG dealt to the target standing on our flames +{0}', 'descId': 'DMG yang disebabkan semua sekutu kepada target di atas api sendiri meningkat {0}'},
  };

  /// portrayalText rows: hero id -> display name (en/idl) + courtesy name.
  static const Map<int, Map<String, String>> HERO_TEXT = {
    310101: {'name': 'Chen Dao', 'nameId': 'Chen Dao', 'vice': 'Shuzhi', 'viceId': 'Shuzhi'},
    310102: {'name': 'Zhao Yun', 'nameId': 'Zhao Yun', 'vice': 'Zilong', 'viceId': 'Zilong'},
    310103: {'name': 'Yang Miaozhen', 'nameId': 'Yang Miaozhen'},
    310201: {'name': 'Zhang He', 'nameId': 'Zhang He', 'vice': 'Junyi', 'viceId': 'Junyi'},
    310202: {'name': 'Qin Liangyu', 'nameId': 'Qin Liangyu', 'vice': 'Zhensu', 'viceId': 'Zhensu'},
    310301: {'name': 'Bai Qi', 'nameId': 'Bai Qi'},
    310302: {'name': 'Zhou Yu', 'nameId': 'Zhou Yu', 'vice': 'Gongjin', 'viceId': 'Gongjin'},
    310303: {'name': 'Li Mu', 'nameId': 'Li Mu'},
    310401: {'name': 'Li Siye', 'nameId': 'Li Siye'},
    310402: {'name': 'Yu Jin', 'nameId': 'Yu Jin', 'vice': 'Wenze', 'viceId': 'Wenze'},
    310501: {'name': 'Jiang Wei', 'nameId': 'Jiang Wei', 'vice': 'Boyue', 'viceId': 'Boyue'},
    310502: {'name': 'Lü Meng', 'nameId': 'Lü Meng', 'vice': 'Ziming', 'viceId': 'Ziming'},
    310503: {'name': 'Xin Qiji', 'nameId': 'Xin Qiji', 'vice': 'Youan', 'viceId': 'You\'an'},
    310601: {'name': 'Wen Yang', 'nameId': 'Wen Yang', 'vice': 'Ciqian', 'viceId': 'Ciqian'},
    310602: {'name': 'Dian Wei', 'nameId': 'Dian Wei'},
    310603: {'name': 'Qin Qiong', 'nameId': 'Qin Qiong', 'vice': 'Shubao', 'viceId': 'Shubao'},
    320101: {'name': 'Xu Sheng', 'nameId': 'Xu Sheng', 'vice': 'Wenxiang', 'viceId': 'Wenxiang'},
    320102: {'name': 'Yue Jin', 'nameId': 'Yue Jin', 'vice': 'Wenqian', 'viceId': 'Wenqian'},
    320103: {'name': 'Xiahou Dun', 'nameId': 'Xiahou Dun', 'vice': 'Yuanrang', 'viceId': 'Yuanrang'},
    320201: {'name': 'Cao Ren', 'nameId': 'Cao Ren', 'vice': 'Zixiao', 'viceId': 'Zixiao'},
    320202: {'name': 'Zhou Tai', 'nameId': 'Zhou Tai', 'vice': 'Youping', 'viceId': 'Youping'},
    320203: {'name': 'Wei Xiaokuan', 'nameId': 'Wei Xiaokuan'},
    320301: {'name': 'Zhang Fei', 'nameId': 'Zhang Fei', 'vice': 'Yide', 'viceId': 'Yide'},
    320302: {'name': 'Gao Shun', 'nameId': 'Gao Shun'},
    320401: {'name': 'Huang Gai', 'nameId': 'Huang Gai', 'vice': 'Gongfu', 'viceId': 'Gongfu'},
    320402: {'name': 'Lian Po', 'nameId': 'Lian Po'},
    320501: {'name': 'Cao Cao', 'nameId': 'Cao Cao', 'vice': 'Mengde', 'viceId': 'Mengde'},
    320502: {'name': 'Deng Ai', 'nameId': 'Deng Ai', 'vice': 'Shizai', 'viceId': 'Shi Zai'},
    320601: {'name': 'Meng Huo', 'nameId': 'Meng Huo'},
    320602: {'name': 'Fan Kuai', 'nameId': 'Fan Kuai'},
    330101: {'name': 'Huang Zhong', 'nameId': 'Huang Zhong', 'vice': 'Hansheng', 'viceId': 'Hansheng'},
    330102: {'name': 'Han Dang', 'nameId': 'Han Dang', 'vice': 'Yigong', 'viceId': 'Yi Gong'},
    330201: {'name': 'Liu Bei', 'nameId': 'Liu Bei', 'vice': 'Xuande', 'viceId': 'Xuande'},
    330202: {'name': 'Liu Chong', 'nameId': 'Liu Chong'},
    330203: {'name': 'Diao Chan', 'nameId': 'Diaochan'},
    330301: {'name': 'Wang Yi', 'nameId': 'Wang Yi'},
    330302: {'name': 'Li Ru', 'nameId': 'Li Ru', 'vice': 'Wenyou', 'viceId': 'Wen You'},
    330401: {'name': 'Yang Youji', 'nameId': 'Yang Youji', 'vice': 'Shu', 'viceId': 'Shu'},
    330402: {'name': 'Sun Quan', 'nameId': 'Sun Quan', 'vice': 'Zhongmou', 'viceId': 'Zhongmou'},
    330403: {'name': 'Liang Hongyu', 'nameId': 'Liang Hongyu'},
    330404: {'name': 'Cai Yan', 'nameId': 'Cai Wenji'},
    330501: {'name': 'Cao Xiu', 'nameId': 'Cao Xiu', 'vice': 'Wenlie', 'viceId': 'Wenlie'},
    330502: {'name': 'Sun Shangxiang', 'nameId': 'Sun Shangxiang'},
    330601: {'name': 'Lu Xun', 'nameId': 'Lu Xun', 'vice': 'Boyan', 'viceId': 'Boyan'},
    330602: {'name': 'Zhu Yuanzhang', 'nameId': 'Zhu Yuanzhang'},
    340101: {'name': 'Zhang Liao', 'nameId': 'Zhang Liao', 'vice': 'Wenyuan', 'viceId': 'Wenyuan'},
    340102: {'name': 'Huo Qubing', 'nameId': 'Huo Qubing'},
    340201: {'name': 'Lü Bu', 'nameId': 'Lü Bu', 'vice': 'Fengxian', 'viceId': 'Fengxian'},
    340202: {'name': 'Ma Chao', 'nameId': 'Ma Chao', 'vice': 'Mengqi', 'viceId': 'Mengqi'},
    340203: {'name': 'Xiang Yu', 'nameId': 'Xiang Yu'},
    340301: {'name': 'Guan Yu', 'nameId': 'Guan Yu', 'vice': 'Yunchang', 'viceId': 'Yunchang'},
    340302: {'name': 'Guan Yinping', 'nameId': 'Guan Yinping'},
    340401: {'name': 'Xu Chu', 'nameId': 'Xu Chu', 'vice': 'Zhongkang', 'viceId': 'Zhongkang'},
    340402: {'name': 'Pei Xingyan', 'nameId': 'Pei Xingyan', 'vice': 'Shoujing', 'viceId': 'Shou Jing'},
    340403: {'name': 'Dong Zhuo', 'nameId': 'Dong Zhuo', 'vice': 'Zhongying', 'viceId': 'Zhongying'},
    340501: {'name': 'Xia Houyuan', 'nameId': 'Xiahou Yuan', 'vice': 'Miaocai', 'viceId': 'Miaocai'},
    340502: {'name': 'Taishi Ci', 'nameId': 'Taishi Ci', 'vice': 'Ziyi', 'viceId': 'Ziyi'},
    340601: {'name': 'Xu Huang', 'nameId': 'Xu Huang', 'vice': 'Gongming', 'viceId': 'Gongming'},
    340602: {'name': 'Cheng Yaojin', 'nameId': 'Cheng Yaojin', 'vice': 'Yizhen', 'viceId': 'Yi Zhen'},
  };


  // ===== PORTRAIT GRADES (ui.json portrayal_desc_*, portrayal_quality_*) =====
  // Index = gradeIdx 0..7. Ladder follows portrayalBase hp/atk column order.
  static const List<String> PORTRAIT_GRADE_LABELS = [
    'Grade 7', 'Grade 6', 'Grade 5', 'Grade 4',
    'Grade 3', 'Grade 2', 'Grade 1', 'Chosen',
  ];
  static const List<String> PORTRAIT_GRADE_RAW = [
    'Tier 7', 'Tier 6', 'Tier 5', 'Tier 4',
    'Tier 3', 'Tier 2', 'Tier 1', 'Chosen',
  ];
  /// Expertise slot count by grade: Grade 6/4/2 unlock Common/Uncommon/Rare,
  /// Chosen adds one extra Rare slot; Grade 7/5/3 keep the lower tier count.
  static const List<int> PORTRAIT_SLOTS = [0, 1, 1, 2, 2, 3, 3, 4];
  /// Max stack per rarity row (strategy.overlay): Common 3, Uncommon 2, Rare 1.
  static const List<int> EXPERTISE_STACK_CAP = [3, 2, 1];
  /// ui.json strategy_level_1/2/3 (rarity names, lv 1/2/3).
  static const List<String> STRATEGY_RARITY_NAMES = [
    'Keahlian Dasar',
    'Keahlian Menengah',
    'Keahlian Lanjutan',
  ];

  static bool portraitGradeBoosts(int gradeIdx) =>
      const {2, 4, 6, 7}.contains(gradeIdx);

  static int portraitExpertiseSlots(int gradeIdx) =>
      PORTRAIT_SLOTS[gradeIdx.clamp(0, 7)];

  /// Base chance of rolling a portrait of a higher grade on one redraw.
  static const double PORTRAIT_UPGRADE_CHANCE = 0.10;

  /// Pity: a grade-up is guaranteed within this many redraws.
  static const int PORTRAIT_UPGRADE_PITY = 10;

  // ---- REMAINS (neutral capitals) ----
  // Real entities from city.json ids 3001-3004 (2x2 cell, 17x17 area,
  // 7x7 build_size, max_army 10, hp 180 — same footprint as the Capital).
  // Names from cityText.json `name_3001..3004` (en + official idl).
  static const List<Map<String, dynamic>> REMAINS = [
    {'id': 3001, 'name': "Chang'an", 'idl': "Chang'an", 'row': 10, 'col': 10},
    {'id': 3002, 'name': 'Jinling', 'idl': 'Jinling', 'row': 10, 'col': 68},
    {'id': 3003, 'name': 'Yanjing', 'idl': 'Yanjing', 'row': 68, 'col': 10},
    {'id': 3004, 'name': 'Luoyang', 'idl': 'Luoyang', 'row': 68, 'col': 68},
  ];

  /// Neutral Remains garrison: "many Lv.6 soldiers" (CLAUDE.md). landAttr has
  /// no Remains row (server-side), so the Hell-band bandit/beast composition is
  /// reused at Lv.6.
  static const String REMAINS_GARRISON =
      '4201,4_4,6|4201,6_4,6|4201,4_6,6|4201,6_6,6'
      '|4202,2_2,6|4202,8_8,6|4202,2_8,6|4202,8_2,6'
      '|4205,5_4,6|4205,5_6,6|4205,4_5,6|4205,6_5,6';

  static const int REMAINS_MAX_LEVEL = 20;
  /// A recaptured Remains drops this many levels (Construct Remains rule 5).
  static const int REMAINS_RECAPTURE_PENALTY = 3;
  /// Build one Remains to Lv.20 first -> win.
  static const int REMAINS_WIN_LEVEL = 20;
  /// Hold 3 Remains at Lv.12+ -> win.
  static const int REMAINS_WIN_COUNT = 3;
  static const int REMAINS_WIN_COUNT_LEVEL = 12;

  // ---- BOT AI (rival unions) ----
  // Rebuild rule: opponents are bots at 3 difficulty levels. Bots never take
  // the player's Remains (offline, no defence mechanic); difficulty only sets
  // how fast they level their own Remains and pile up union points.
  //   tick        = seconds of active playtime between bot moves
  //   levelsEvery = bot ticks per Remains level-up
  static const List<Map<String, dynamic>> BOT_DIFFICULTIES = [
    {
      'id': 'easy',
      'name': 'Easy',
      'tagline': 'Bot lambat: Remains naik tiap ~40 menit',
      'tick': 300,
      'levelsEvery': 8,
      'points': 2,
      'territory': 1,
    },
    {
      'id': 'normal',
      'name': 'Normal',
      'tagline': 'Bot sedang: Remains naik tiap ~24 menit',
      'tick': 240,
      'levelsEvery': 6,
      'points': 4,
      'territory': 2,
    },
    {
      'id': 'hard',
      'name': 'Hard',
      'tagline': 'Bot cepat: Remains naik tiap ~12 menit',
      'tick': 180,
      'levelsEvery': 4,
      'points': 7,
      'territory': 3,
    },
  ];

  // Seasons
  static const List<String> SEASONS = ['Spring', 'Summer', 'Autumn', 'Winter'];

  // One season = 3 real days. Clock only advances while the app is open
  // (rebuild rule: timer pauses when the game is closed).
  static const int REAL_SECONDS_PER_DAY = 86400;
  static const int REAL_SECONDS_PER_SEASON = REAL_SECONDS_PER_DAY * DAYS_PER_SEASON;

  // Divisions — rebuild has no waitlist: pick one and play immediately.
  // Rules text mirrors the original Rules screen (CLAUDE.md "Divisi & Victory").
  static const List<Map<String, dynamic>> DIVISIONS = [
    {
      'id': 'newbie',
      'name': 'Newbie Division',
      'tagline': 'Langsung gabung, tanpa daftar',
      'victory': 'Construct Remains',
      'unionMarket': 'union',
      'autoUnion': false,
      'tierWinPoints': false,
      'rewardPointsUnlimited': false,
      'tallies': [1, 100],
      'rules': [
        'Bebas membuat union kapan saja.',
        'Union Market: hanya anggota union yang bisa trade.',
        'Reward akhir sesi: [1-100] Bronze Tallies sesuai ranking.',
        'Tidak dapat Tier Win Points.',
        'Victory: Construct Remains.',
      ],
    },
    {
      'id': 'free',
      'name': 'Free Division',
      'tagline': 'Tanpa daftar, tanpa batas poin',
      'victory': 'Construct Remains',
      'unionMarket': 'free',
      'autoUnion': false,
      'tierWinPoints': false,
      'rewardPointsUnlimited': true,
      'tallies': [1, 100],
      'rules': [
        'Sama seperti Newbie Division.',
        'No Reward Points Limit.',
        'Union Market: Free Market — barter dengan pemain mana pun.',
        'Reward akhir sesi: [1-100] Bronze Tallies sesuai ranking.',
        'Victory: Construct Remains.',
      ],
    },
    {
      'id': 'ranked',
      'name': 'Ranked Division',
      'tagline': 'Union otomatis, naik tier',
      'victory': 'Final Conquest',
      'unionMarket': 'union',
      'autoUnion': true,
      'tierWinPoints': true,
      'rewardPointsUnlimited': true,
      'tallies': [1, 100],
      'rules': [
        'Daftar dulu; union di-assign otomatis.',
        'Top 3 alliance dapat bonus Scroll Fragments.',
        'Dapat Tier Win Points sesuai ranking akhir.',
        'Reward akhir sesi: [1-100] Bronze Tallies + hero fragment per tier.',
        'Victory: Final Conquest.',
      ],
    },
  ];

  /// Ranked ladder — 24 tiers, thresholds from `seasonReward.json`
  /// (`rank_score`). `rank_name_5` = "Bronze Ⅰ" confirms the naming shape.
  static const List<Map<String, dynamic>> RANK_TIERS = [
    {'name': 'Iron II', 'points': 20},
    {'name': 'Iron I', 'points': 40},
    {'name': 'Bronze III', 'points': 60},
    {'name': 'Bronze II', 'points': 90},
    {'name': 'Bronze I', 'points': 120},
    {'name': 'Silver III', 'points': 150},
    {'name': 'Silver II', 'points': 195},
    {'name': 'Silver I', 'points': 240},
    {'name': 'Gold III', 'points': 285},
    {'name': 'Gold II', 'points': 345},
    {'name': 'Gold I', 'points': 405},
    {'name': 'Platinum IV', 'points': 465},
    {'name': 'Platinum III', 'points': 545},
    {'name': 'Platinum II', 'points': 625},
    {'name': 'Platinum I', 'points': 705},
    {'name': 'Diamond V', 'points': 785},
    {'name': 'Diamond IV', 'points': 885},
    {'name': 'Diamond III', 'points': 985},
    {'name': 'Diamond II', 'points': 1085},
    {'name': 'Diamond I', 'points': 1185},
    {'name': 'Master III', 'points': 1285},
    {'name': 'Master II', 'points': 1485},
    {'name': 'Master I', 'points': 1685},
    {'name': 'Ace', 'points': 1885},
  ];

  /// Tier Win Points granted per plot level on a ranked-division conquest.
  /// User-confirmed curve: plot Lv.1→2, Lv.2→4, Lv.3→6, Lv.4→8, Lv.5→10, i.e.
  /// 2 points per plot level (0..10 for the 1..5 plot levels).
  static const int TIER_POINTS_PER_PLOT_LEVEL = 2;

  /// Tier reached at `points` (Tier Win Points). Below the first threshold
  /// the player is still unranked.
  static String rankTierName(int points) {
    var name = 'Unranked';
    for (final t in RANK_TIERS) {
      if (points >= (t['points'] as int)) name = t['name'] as String;
    }
    return name;
  }

  /// Points needed for the next tier, or null at Ace.
  static int? nextRankThreshold(int points) {
    for (final t in RANK_TIERS) {
      if (points < (t['points'] as int)) return t['points'] as int;
    }
    return null;
  }

  // Terrain types
  static const int TILE_GRASS = 0;
  static const int TILE_FOREST = 1;
  static const int TILE_MOUNTAIN = 2;
  static const int TILE_WATER = 3;
  static const int TILE_SAND = 4;

  // ---- REAL DATA (generated from game_json/pawnAttr, pawnBase, buildAttr) ----
  /// Idle/build id -> BUILD_LADDER key (buildBase id).
  static const Map<String, int> BUILD_BASE_IDS = {
    'palace': 2001,
    'barracks': 2004,
    'smithy': 2008,
    'hall_of_heroes': 2015,
    'drill_ground': 2011,
    'clinic': 2016,
    'market': 2006,
    'barn': 2002,
    'warehouse': 2003,
    'embassy': 2005,
    'city_wall': 2000,
    'factory': 2010,
    'guard_tower_n': 2012,
    'guard_tower_s': 2013,
    'union_market': 2014,
    'prison': 2017,
  };

  static const Map<String, Map<String, dynamic>> PAWN_BASE = {
    '3101': {'attackSpeed': 6, 'velocity': 90, 'marchSpeed': 62, 'bagCap': 2, 'cerealCost': 2, 'needUnlock': 1, 'unlockAt': [1,5,8,12], 'drillCost': {'crop': 113}, 'drillTime': 120, 'canEquip': 1},
    '3102': {'attackSpeed': 6, 'velocity': 90, 'marchSpeed': 62, 'bagCap': 2, 'cerealCost': 2, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 124}, 'drillTime': 237, 'canEquip': 1},
    '3103': {'attackSpeed': 6, 'velocity': 85, 'marchSpeed': 62, 'bagCap': 2, 'cerealCost': 2, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 115}, 'drillTime': 216, 'canEquip': 1},
    '3104': {'attackSpeed': 6, 'velocity': 90, 'marchSpeed': 62, 'bagCap': 2, 'cerealCost': 2, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 130}, 'drillTime': 216, 'canEquip': 1},
    '3105': {'attackSpeed': 6, 'velocity': 85, 'marchSpeed': 62, 'bagCap': 2, 'cerealCost': 2, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 118}, 'drillTime': 226, 'canEquip': 1},
    '3106': {'attackSpeed': 6, 'velocity': 95, 'marchSpeed': 62, 'bagCap': 2, 'cerealCost': 2, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 125}, 'drillTime': 235, 'canEquip': 1},
    '3201': {'attackSpeed': 8, 'velocity': 80, 'marchSpeed': 62, 'bagCap': 3, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [1,5,8,12], 'drillCost': {'crop': 151}, 'drillTime': 210, 'canEquip': 1},
    '3202': {'attackSpeed': 9, 'velocity': 75, 'marchSpeed': 62, 'bagCap': 3, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [1,5,8,12], 'drillCost': {'crop': 180}, 'drillTime': 310, 'canEquip': 1},
    '3203': {'attackSpeed': 8, 'velocity': 80, 'marchSpeed': 62, 'bagCap': 3, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [1,5,8,12], 'drillCost': {'crop': 158}, 'drillTime': 252, 'canEquip': 1},
    '3204': {'attackSpeed': 8, 'velocity': 80, 'marchSpeed': 62, 'bagCap': 3, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [1,5,8,12], 'drillCost': {'crop': 162}, 'drillTime': 255, 'canEquip': 1},
    '3205': {'attackSpeed': 7, 'velocity': 80, 'marchSpeed': 62, 'bagCap': 3, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 310}, 'drillTime': 480, 'canEquip': 1},
    '3206': {'attackSpeed': 7, 'velocity': 80, 'marchSpeed': 62, 'bagCap': 3, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [1,5,8,12], 'drillCost': {'crop': 168}, 'drillTime': 265, 'canEquip': 1},
    '3301': {'attackSpeed': 5, 'velocity': 110, 'marchSpeed': 62, 'bagCap': 1, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [2,5,8,12], 'drillCost': {'crop': 206}, 'drillTime': 300, 'canEquip': 1},
    '3302': {'attackSpeed': 5, 'velocity': 110, 'marchSpeed': 62, 'bagCap': 1, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [2,5,8,12], 'drillCost': {'crop': 202}, 'drillTime': 300, 'canEquip': 1},
    '3303': {'attackSpeed': 5, 'velocity': 110, 'marchSpeed': 62, 'bagCap': 1, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [2,5,8,12], 'drillCost': {'crop': 204}, 'drillTime': 330, 'canEquip': 1},
    '3304': {'attackSpeed': 5, 'velocity': 115, 'marchSpeed': 62, 'bagCap': 1, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [2,5,8,12], 'drillCost': {'crop': 209}, 'drillTime': 315, 'canEquip': 1},
    '3305': {'attackSpeed': 5, 'velocity': 90, 'marchSpeed': 62, 'bagCap': 1, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [2,5,8,12], 'drillCost': {'crop': 216}, 'drillTime': 325, 'canEquip': 1},
    '3306': {'attackSpeed': 5, 'velocity': 110, 'marchSpeed': 62, 'bagCap': 1, 'cerealCost': 3, 'needUnlock': 1, 'unlockAt': [2,5,8,12], 'drillCost': {'crop': 218}, 'drillTime': 335, 'canEquip': 1},
    '3401': {'attackSpeed': 6, 'velocity': 150, 'marchSpeed': 74, 'bagCap': 3, 'cerealCost': 4, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 204}, 'drillTime': 315, 'canEquip': 1},
    '3402': {'attackSpeed': 7, 'velocity': 150, 'marchSpeed': 74, 'bagCap': 3, 'cerealCost': 4, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 210}, 'drillTime': 320, 'canEquip': 1},
    '3403': {'attackSpeed': 6, 'velocity': 150, 'marchSpeed': 74, 'bagCap': 3, 'cerealCost': 4, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 230}, 'drillTime': 346, 'canEquip': 1},
    '3404': {'attackSpeed': 8, 'velocity': 145, 'marchSpeed': 74, 'bagCap': 3, 'cerealCost': 5, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 268}, 'drillTime': 350, 'canEquip': 1},
    '3405': {'attackSpeed': 6, 'velocity': 155, 'marchSpeed': 74, 'bagCap': 3, 'cerealCost': 4, 'needUnlock': 1, 'unlockAt': [2,5,8,12], 'drillCost': {'crop': 210}, 'drillTime': 331, 'canEquip': 1},
    '3406': {'attackSpeed': 7, 'velocity': 150, 'marchSpeed': 74, 'bagCap': 3, 'cerealCost': 4, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 220}, 'drillTime': 336, 'canEquip': 1},
    '3501': {'attackSpeed': 4, 'velocity': 60, 'marchSpeed': 46, 'bagCap': 0, 'cerealCost': 5, 'needUnlock': 1, 'unlockAt': [5,8,12], 'drillCost': {'crop': 150}, 'drillTime': 150, 'canEquip': 0},
    '3502': {'attackSpeed': 4, 'velocity': 60, 'marchSpeed': 46, 'bagCap': 1, 'cerealCost': 5, 'needUnlock': 1, 'unlockAt': [2,5,8,12], 'drillCost': {'crop': 200}, 'drillTime': 350, 'canEquip': 0},
    '3601': {'attackSpeed': 9, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '3701': {'attackSpeed': 0, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '3702': {'attackSpeed': 0, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '3703': {'attackSpeed': 0, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4101': {'attackSpeed': 6, 'velocity': 100, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 1, 'canEquip': 0},
    '4102': {'attackSpeed': 8, 'velocity': 135, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 2, 'canEquip': 0},
    '4103': {'attackSpeed': 9, 'velocity': 70, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 8, 'canEquip': 0},
    '4104': {'attackSpeed': 7, 'velocity': 135, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 12, 'canEquip': 0},
    '4105': {'attackSpeed': 9, 'velocity': 90, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 4, 'canEquip': 0},
    '4106': {'attackSpeed': 7, 'velocity': 100, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 6, 'canEquip': 0},
    '4107': {'attackSpeed': 9, 'velocity': 100, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 9, 'canEquip': 0},
    '4108': {'attackSpeed': 7, 'velocity': 140, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 5, 'canEquip': 0},
    '4109': {'attackSpeed': 6, 'velocity': 110, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 3, 'canEquip': 0},
    '4110': {'attackSpeed': 9, 'velocity': 60, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 7, 'canEquip': 0},
    '4111': {'attackSpeed': 9, 'velocity': 80, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 10, 'canEquip': 0},
    '4112': {'attackSpeed': 7, 'velocity': 135, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 11, 'canEquip': 0},
    '4113': {'attackSpeed': 9, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 1},
    '4114': {'attackSpeed': 9, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 1},
    '4115': {'attackSpeed': 9, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 1},
    '4116': {'attackSpeed': 7, 'velocity': 100, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4117': {'attackSpeed': 6, 'velocity': 110, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4118': {'attackSpeed': 5, 'velocity': 70, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4119': {'attackSpeed': 9, 'velocity': 110, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4201': {'attackSpeed': 8, 'velocity': 90, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4202': {'attackSpeed': 9, 'velocity': 90, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4203': {'attackSpeed': 6, 'velocity': 120, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4204': {'attackSpeed': 6, 'velocity': 110, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4205': {'attackSpeed': 7, 'velocity': 150, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '4206': {'attackSpeed': 6, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 2},
    '7001': {'attackSpeed': 9, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '7002': {'attackSpeed': 9, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
    '7003': {'attackSpeed': 9, 'velocity': 0, 'marchSpeed': 0, 'bagCap': 0, 'cerealCost': 0, 'needUnlock': 0, 'unlockAt': <int>[], 'drillCost': <String, int>{}, 'drillTime': 0, 'canEquip': 0},
  };

  static const Map<String, List<Map<String, dynamic>>> PAWN_LADDER = {
    '3101': [
      {'lv': 1, 'hp': 135, 'atk': 10, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20101], 'gate': [4, 2004, 1], 'cost': {'crop': 181, 'expScroll': 1}, 'time': 240},
      {'lv': 2, 'hp': 167, 'atk': 12, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20102], 'gate': [4, 2004, 5], 'cost': {'crop': 290, 'expScroll': 1}, 'time': 486},
      {'lv': 3, 'hp': 207, 'atk': 15, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20103], 'gate': [4, 2004, 10], 'cost': {'crop': 464, 'expScroll': 2}, 'time': 729},
      {'lv': 4, 'hp': 257, 'atk': 19, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20104], 'gate': [4, 2004, 15], 'cost': {'crop': 742, 'expScroll': 2}, 'time': 1094},
      {'lv': 5, 'hp': 319, 'atk': 24, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20105], 'gate': [4, 2004, 20], 'cost': {'crop': 1187, 'expScroll': 3}, 'time': 1641},
      {'lv': 6, 'hp': 396, 'atk': 30, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10101, 10201, 20106], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3102': [
      {'lv': 1, 'hp': 104, 'atk': 12, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20201], 'gate': [4, 2004, 1], 'cost': {'crop': 198, 'expScroll': 1}, 'time': 356},
      {'lv': 2, 'hp': 129, 'atk': 15, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20202], 'gate': [4, 2004, 5], 'cost': {'crop': 317, 'expScroll': 1}, 'time': 534},
      {'lv': 3, 'hp': 160, 'atk': 19, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20203], 'gate': [4, 2004, 10], 'cost': {'crop': 507, 'expScroll': 2}, 'time': 801},
      {'lv': 4, 'hp': 198, 'atk': 24, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20204], 'gate': [4, 2004, 15], 'cost': {'crop': 811, 'expScroll': 2}, 'time': 1202},
      {'lv': 5, 'hp': 246, 'atk': 30, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20205], 'gate': [4, 2004, 20], 'cost': {'crop': 1298, 'expScroll': 3}, 'time': 1803},
      {'lv': 6, 'hp': 305, 'atk': 37, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [10101, 10201, 20206], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3103': [
      {'lv': 1, 'hp': 88, 'atk': 8, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20301], 'gate': [4, 2004, 1], 'cost': {'crop': 184, 'expScroll': 1}, 'time': 324},
      {'lv': 2, 'hp': 109, 'atk': 10, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20302], 'gate': [4, 2004, 5], 'cost': {'crop': 294, 'expScroll': 1}, 'time': 486},
      {'lv': 3, 'hp': 135, 'atk': 12, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20303], 'gate': [4, 2004, 10], 'cost': {'crop': 470, 'expScroll': 2}, 'time': 729},
      {'lv': 4, 'hp': 167, 'atk': 15, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20304], 'gate': [4, 2004, 15], 'cost': {'crop': 752, 'expScroll': 2}, 'time': 1094},
      {'lv': 5, 'hp': 207, 'atk': 19, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20305], 'gate': [4, 2004, 20], 'cost': {'crop': 1203, 'expScroll': 3}, 'time': 1641},
      {'lv': 6, 'hp': 257, 'atk': 24, 'range': 2, 'move': 2, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 20306], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3104': [
      {'lv': 1, 'hp': 94, 'atk': 3, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10801, 11001], 'gate': [4, 2004, 1], 'cost': {'crop': 208, 'expScroll': 1}, 'time': 324},
      {'lv': 2, 'hp': 117, 'atk': 4, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10802, 11001], 'gate': [4, 2004, 5], 'cost': {'crop': 333, 'expScroll': 1}, 'time': 486},
      {'lv': 3, 'hp': 145, 'atk': 5, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10803, 11001], 'gate': [4, 2004, 10], 'cost': {'crop': 533, 'expScroll': 2}, 'time': 729},
      {'lv': 4, 'hp': 180, 'atk': 6, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10804, 11001], 'gate': [4, 2004, 15], 'cost': {'crop': 853, 'expScroll': 2}, 'time': 1094},
      {'lv': 5, 'hp': 223, 'atk': 7, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10805, 11001], 'gate': [4, 2004, 20], 'cost': {'crop': 1365, 'expScroll': 3}, 'time': 1641},
      {'lv': 6, 'hp': 277, 'atk': 9, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10101, 10201, 10806, 11001], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3105': [
      {'lv': 1, 'hp': 208, 'atk': 9, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21601], 'gate': [4, 2004, 1], 'cost': {'crop': 189, 'expScroll': 1}, 'time': 339},
      {'lv': 2, 'hp': 258, 'atk': 11, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21602], 'gate': [4, 2004, 5], 'cost': {'crop': 302, 'expScroll': 1}, 'time': 509},
      {'lv': 3, 'hp': 320, 'atk': 14, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21603], 'gate': [4, 2004, 10], 'cost': {'crop': 483, 'expScroll': 2}, 'time': 764},
      {'lv': 4, 'hp': 397, 'atk': 17, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21604], 'gate': [4, 2004, 15], 'cost': {'crop': 773, 'expScroll': 2}, 'time': 1146},
      {'lv': 5, 'hp': 492, 'atk': 21, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21605], 'gate': [4, 2004, 20], 'cost': {'crop': 1237, 'expScroll': 3}, 'time': 1719},
      {'lv': 6, 'hp': 610, 'atk': 26, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 6, 'skills': [10101, 10201, 21606], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3106': [
      {'lv': 1, 'hp': 125, 'atk': 11, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21901], 'gate': [4, 2004, 1], 'cost': {'crop': 200, 'expScroll': 1}, 'time': 353},
      {'lv': 2, 'hp': 155, 'atk': 14, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21902], 'gate': [4, 2004, 5], 'cost': {'crop': 320, 'expScroll': 1}, 'time': 530},
      {'lv': 3, 'hp': 192, 'atk': 17, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21903], 'gate': [4, 2004, 10], 'cost': {'crop': 512, 'expScroll': 2}, 'time': 795},
      {'lv': 4, 'hp': 238, 'atk': 21, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21904], 'gate': [4, 2004, 15], 'cost': {'crop': 819, 'expScroll': 2}, 'time': 1193},
      {'lv': 5, 'hp': 295, 'atk': 26, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21905], 'gate': [4, 2004, 20], 'cost': {'crop': 1310, 'expScroll': 3}, 'time': 1790},
      {'lv': 6, 'hp': 366, 'atk': 32, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [10101, 10201, 21906], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3201': [
      {'lv': 1, 'hp': 265, 'atk': 6, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20401], 'gate': [4, 2004, 1], 'cost': {'crop': 242, 'expScroll': 1}, 'time': 360},
      {'lv': 2, 'hp': 326, 'atk': 7, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20402], 'gate': [4, 2004, 5], 'cost': {'crop': 387, 'expScroll': 2}, 'time': 540},
      {'lv': 3, 'hp': 401, 'atk': 9, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20403], 'gate': [4, 2004, 10], 'cost': {'crop': 619, 'expScroll': 3}, 'time': 810},
      {'lv': 4, 'hp': 493, 'atk': 11, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20404], 'gate': [4, 2004, 15], 'cost': {'crop': 990, 'expScroll': 4}, 'time': 1215},
      {'lv': 5, 'hp': 606, 'atk': 14, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20405], 'gate': [4, 2004, 20], 'cost': {'crop': 1584, 'expScroll': 5}, 'time': 1823},
      {'lv': 6, 'hp': 745, 'atk': 17, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 12, 'skills': [10102, 10202, 20406], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3202': [
      {'lv': 1, 'hp': 318, 'atk': 4, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20501], 'gate': [4, 2004, 1], 'cost': {'crop': 288, 'expScroll': 1}, 'time': 465},
      {'lv': 2, 'hp': 391, 'atk': 5, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20502], 'gate': [4, 2004, 5], 'cost': {'crop': 461, 'expScroll': 2}, 'time': 698},
      {'lv': 3, 'hp': 481, 'atk': 6, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20503], 'gate': [4, 2004, 10], 'cost': {'crop': 738, 'expScroll': 3}, 'time': 1047},
      {'lv': 4, 'hp': 592, 'atk': 7, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20504], 'gate': [4, 2004, 15], 'cost': {'crop': 1181, 'expScroll': 4}, 'time': 1571},
      {'lv': 5, 'hp': 728, 'atk': 9, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20505], 'gate': [4, 2004, 20], 'cost': {'crop': 1890, 'expScroll': 5}, 'time': 2357},
      {'lv': 6, 'hp': 895, 'atk': 11, 'range': 1, 'move': 3, 'rage': 16, 'initRage': 10, 'skills': [10102, 10202, 20506], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3203': [
      {'lv': 1, 'hp': 278, 'atk': 5, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21201], 'gate': [4, 2004, 1], 'cost': {'crop': 253, 'expScroll': 1}, 'time': 378},
      {'lv': 2, 'hp': 342, 'atk': 7, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21202], 'gate': [4, 2004, 5], 'cost': {'crop': 405, 'expScroll': 2}, 'time': 567},
      {'lv': 3, 'hp': 421, 'atk': 9, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21203], 'gate': [4, 2004, 10], 'cost': {'crop': 648, 'expScroll': 3}, 'time': 851},
      {'lv': 4, 'hp': 518, 'atk': 11, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21204], 'gate': [4, 2004, 15], 'cost': {'crop': 1037, 'expScroll': 4}, 'time': 1277},
      {'lv': 5, 'hp': 637, 'atk': 13, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21205], 'gate': [4, 2004, 20], 'cost': {'crop': 1659, 'expScroll': 5}, 'time': 1916},
      {'lv': 6, 'hp': 784, 'atk': 15, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [10102, 10202, 21206], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3204': [
      {'lv': 1, 'hp': 239, 'atk': 5, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21501], 'gate': [4, 2004, 1], 'cost': {'crop': 259, 'expScroll': 1}, 'time': 383},
      {'lv': 2, 'hp': 294, 'atk': 6, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21502], 'gate': [4, 2004, 5], 'cost': {'crop': 414, 'expScroll': 2}, 'time': 575},
      {'lv': 3, 'hp': 362, 'atk': 7, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21503], 'gate': [4, 2004, 10], 'cost': {'crop': 662, 'expScroll': 3}, 'time': 863},
      {'lv': 4, 'hp': 445, 'atk': 9, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21504], 'gate': [4, 2004, 15], 'cost': {'crop': 1059, 'expScroll': 4}, 'time': 1295},
      {'lv': 5, 'hp': 547, 'atk': 11, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21505], 'gate': [4, 2004, 20], 'cost': {'crop': 1694, 'expScroll': 5}, 'time': 1943},
      {'lv': 6, 'hp': 673, 'atk': 14, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 10, 'skills': [10102, 10202, 21506], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3205': [
      {'lv': 1, 'hp': 159, 'atk': 3, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11401, 21801], 'gate': [4, 2004, 1], 'cost': {'crop': 496, 'expScroll': 1}, 'time': 720},
      {'lv': 2, 'hp': 194, 'atk': 4, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11402, 21802], 'gate': [4, 2004, 5], 'cost': {'crop': 794, 'expScroll': 2}, 'time': 1080},
      {'lv': 3, 'hp': 237, 'atk': 5, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11403, 21803], 'gate': [4, 2004, 10], 'cost': {'crop': 1270, 'expScroll': 3}, 'time': 1620},
      {'lv': 4, 'hp': 289, 'atk': 6, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11404, 21804], 'gate': [4, 2004, 15], 'cost': {'crop': 2032, 'expScroll': 4}, 'time': 2430},
      {'lv': 5, 'hp': 353, 'atk': 7, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11405, 21805], 'gate': [4, 2004, 20], 'cost': {'crop': 3251, 'expScroll': 5}, 'time': 3645},
      {'lv': 6, 'hp': 431, 'atk': 8, 'range': 1, 'move': 3, 'rage': 15, 'initRage': 8, 'skills': [10102, 10202, 11406, 21806], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3206': [
      {'lv': 1, 'hp': 212, 'atk': 10, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22101, 11901], 'gate': [4, 2004, 1], 'cost': {'crop': 269, 'expScroll': 1}, 'time': 398},
      {'lv': 2, 'hp': 261, 'atk': 14, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22102, 11902], 'gate': [4, 2004, 5], 'cost': {'crop': 430, 'expScroll': 2}, 'time': 597},
      {'lv': 3, 'hp': 321, 'atk': 18, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22103, 11903], 'gate': [4, 2004, 10], 'cost': {'crop': 688, 'expScroll': 3}, 'time': 896},
      {'lv': 4, 'hp': 395, 'atk': 22, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22104, 11904], 'gate': [4, 2004, 15], 'cost': {'crop': 1101, 'expScroll': 4}, 'time': 1344},
      {'lv': 5, 'hp': 486, 'atk': 26, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22105, 11905], 'gate': [4, 2004, 20], 'cost': {'crop': 1762, 'expScroll': 5}, 'time': 2016},
      {'lv': 6, 'hp': 598, 'atk': 30, 'range': 1, 'move': 3, 'rage': 6, 'initRage': 4, 'skills': [10102, 10202, 22106, 11906], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3301': [
      {'lv': 1, 'hp': 78, 'atk': 7, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20601], 'gate': [4, 2004, 1], 'cost': {'crop': 330, 'expScroll': 1}, 'time': 450},
      {'lv': 2, 'hp': 86, 'atk': 9, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20602], 'gate': [4, 2004, 5], 'cost': {'crop': 528, 'expScroll': 1}, 'time': 675},
      {'lv': 3, 'hp': 95, 'atk': 11, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20603], 'gate': [4, 2004, 10], 'cost': {'crop': 845, 'expScroll': 2}, 'time': 1013},
      {'lv': 4, 'hp': 105, 'atk': 13, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20604], 'gate': [4, 2004, 15], 'cost': {'crop': 1352, 'expScroll': 2}, 'time': 1520},
      {'lv': 5, 'hp': 116, 'atk': 15, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20605], 'gate': [4, 2004, 20], 'cost': {'crop': 2163, 'expScroll': 3}, 'time': 2280},
      {'lv': 6, 'hp': 128, 'atk': 17, 'range': 4, 'move': 2, 'rage': 8, 'initRage': 6, 'skills': [10103, 10203, 20606], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3302': [
      {'lv': 1, 'hp': 117, 'atk': 6, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20701], 'gate': [4, 2004, 1], 'cost': {'crop': 323, 'expScroll': 1}, 'time': 450},
      {'lv': 2, 'hp': 138, 'atk': 7, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20702], 'gate': [4, 2004, 5], 'cost': {'crop': 517, 'expScroll': 1}, 'time': 675},
      {'lv': 3, 'hp': 163, 'atk': 8, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20703], 'gate': [4, 2004, 10], 'cost': {'crop': 827, 'expScroll': 2}, 'time': 1013},
      {'lv': 4, 'hp': 192, 'atk': 10, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20704], 'gate': [4, 2004, 15], 'cost': {'crop': 1323, 'expScroll': 2}, 'time': 1520},
      {'lv': 5, 'hp': 227, 'atk': 12, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20705], 'gate': [4, 2004, 20], 'cost': {'crop': 2117, 'expScroll': 3}, 'time': 2280},
      {'lv': 6, 'hp': 268, 'atk': 14, 'range': 3, 'move': 3, 'rage': 4, 'initRage': 2, 'skills': [10103, 10203, 20706], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3303': [
      {'lv': 1, 'hp': 76, 'atk': 5, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21001], 'gate': [4, 2004, 1], 'cost': {'crop': 326, 'expScroll': 1}, 'time': 495},
      {'lv': 2, 'hp': 84, 'atk': 6, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21002], 'gate': [4, 2004, 5], 'cost': {'crop': 522, 'expScroll': 1}, 'time': 743},
      {'lv': 3, 'hp': 92, 'atk': 7, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21003], 'gate': [4, 2004, 10], 'cost': {'crop': 835, 'expScroll': 2}, 'time': 1115},
      {'lv': 4, 'hp': 101, 'atk': 8, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21004], 'gate': [4, 2004, 15], 'cost': {'crop': 1336, 'expScroll': 2}, 'time': 1673},
      {'lv': 5, 'hp': 111, 'atk': 9, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21005], 'gate': [4, 2004, 20], 'cost': {'crop': 2138, 'expScroll': 3}, 'time': 2510},
      {'lv': 6, 'hp': 122, 'atk': 10, 'range': 4, 'move': 2, 'rage': 6, 'initRage': 4, 'skills': [10103, 10203, 21006], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3304': [
      {'lv': 1, 'hp': 94, 'atk': 7, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21401], 'gate': [4, 2004, 1], 'cost': {'crop': 334, 'expScroll': 1}, 'time': 473},
      {'lv': 2, 'hp': 103, 'atk': 8, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21402], 'gate': [4, 2004, 5], 'cost': {'crop': 534, 'expScroll': 1}, 'time': 710},
      {'lv': 3, 'hp': 113, 'atk': 9, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21403], 'gate': [4, 2004, 10], 'cost': {'crop': 854, 'expScroll': 2}, 'time': 1065},
      {'lv': 4, 'hp': 124, 'atk': 10, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21404], 'gate': [4, 2004, 15], 'cost': {'crop': 1366, 'expScroll': 2}, 'time': 1598},
      {'lv': 5, 'hp': 136, 'atk': 11, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21405], 'gate': [4, 2004, 20], 'cost': {'crop': 2186, 'expScroll': 3}, 'time': 2397},
      {'lv': 6, 'hp': 150, 'atk': 12, 'range': 4, 'move': 2, 'rage': 12, 'initRage': 12, 'skills': [10103, 10203, 10401, 21406], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3305': [
      {'lv': 1, 'hp': 55, 'atk': 15, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11201], 'gate': [4, 2004, 1], 'cost': {'crop': 346, 'expScroll': 1}, 'time': 488},
      {'lv': 2, 'hp': 58, 'atk': 19, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11202], 'gate': [4, 2004, 5], 'cost': {'crop': 554, 'expScroll': 1}, 'time': 732},
      {'lv': 3, 'hp': 61, 'atk': 23, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11203], 'gate': [4, 2004, 10], 'cost': {'crop': 886, 'expScroll': 2}, 'time': 1098},
      {'lv': 4, 'hp': 64, 'atk': 27, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11204], 'gate': [4, 2004, 15], 'cost': {'crop': 1418, 'expScroll': 2}, 'time': 1647},
      {'lv': 5, 'hp': 67, 'atk': 32, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11205], 'gate': [4, 2004, 20], 'cost': {'crop': 2269, 'expScroll': 3}, 'time': 2471},
      {'lv': 6, 'hp': 70, 'atk': 38, 'range': 5, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [10103, 10203, 11101, 11206], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3306': [
      {'lv': 1, 'hp': 78, 'atk': 6, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22001, 11801], 'gate': [4, 2004, 1], 'cost': {'crop': 349, 'expScroll': 1}, 'time': 503},
      {'lv': 2, 'hp': 86, 'atk': 7, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22002, 11801], 'gate': [4, 2004, 5], 'cost': {'crop': 558, 'expScroll': 1}, 'time': 755},
      {'lv': 3, 'hp': 95, 'atk': 8, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22003, 11801], 'gate': [4, 2004, 10], 'cost': {'crop': 893, 'expScroll': 2}, 'time': 1133},
      {'lv': 4, 'hp': 105, 'atk': 9, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22004, 11801], 'gate': [4, 2004, 15], 'cost': {'crop': 1429, 'expScroll': 2}, 'time': 1700},
      {'lv': 5, 'hp': 116, 'atk': 10, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22005, 11801], 'gate': [4, 2004, 20], 'cost': {'crop': 2286, 'expScroll': 3}, 'time': 2550},
      {'lv': 6, 'hp': 128, 'atk': 11, 'range': 4, 'move': 2, 'rage': 10, 'initRage': 8, 'skills': [10103, 10203, 22006, 11801], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3401': [
      {'lv': 1, 'hp': 155, 'atk': 14, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20801], 'gate': [4, 2004, 1], 'cost': {'crop': 326, 'expScroll': 1}, 'time': 473},
      {'lv': 2, 'hp': 194, 'atk': 18, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20802], 'gate': [4, 2004, 5], 'cost': {'crop': 522, 'expScroll': 2}, 'time': 710},
      {'lv': 3, 'hp': 243, 'atk': 23, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20803], 'gate': [4, 2004, 10], 'cost': {'crop': 835, 'expScroll': 3}, 'time': 1065},
      {'lv': 4, 'hp': 304, 'atk': 29, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20804], 'gate': [4, 2004, 15], 'cost': {'crop': 1336, 'expScroll': 4}, 'time': 1598},
      {'lv': 5, 'hp': 380, 'atk': 36, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20805], 'gate': [4, 2004, 20], 'cost': {'crop': 2138, 'expScroll': 5}, 'time': 2397},
      {'lv': 6, 'hp': 475, 'atk': 43, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 4, 'skills': [10104, 10204, 20806], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3402': [
      {'lv': 1, 'hp': 186, 'atk': 10, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20901], 'gate': [4, 2004, 1], 'cost': {'crop': 336, 'expScroll': 1}, 'time': 480},
      {'lv': 2, 'hp': 233, 'atk': 13, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20902], 'gate': [4, 2004, 5], 'cost': {'crop': 538, 'expScroll': 2}, 'time': 720},
      {'lv': 3, 'hp': 291, 'atk': 16, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20903], 'gate': [4, 2004, 10], 'cost': {'crop': 861, 'expScroll': 3}, 'time': 1080},
      {'lv': 4, 'hp': 364, 'atk': 20, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20904], 'gate': [4, 2004, 15], 'cost': {'crop': 1378, 'expScroll': 4}, 'time': 1620},
      {'lv': 5, 'hp': 455, 'atk': 25, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20905], 'gate': [4, 2004, 20], 'cost': {'crop': 2205, 'expScroll': 5}, 'time': 2430},
      {'lv': 6, 'hp': 569, 'atk': 31, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 6, 'skills': [10104, 10204, 20906], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3403': [
      {'lv': 1, 'hp': 126, 'atk': 18, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21101], 'gate': [4, 2004, 1], 'cost': {'crop': 368, 'expScroll': 1}, 'time': 519},
      {'lv': 2, 'hp': 157, 'atk': 23, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21102], 'gate': [4, 2004, 5], 'cost': {'crop': 589, 'expScroll': 2}, 'time': 779},
      {'lv': 3, 'hp': 197, 'atk': 29, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21103], 'gate': [4, 2004, 10], 'cost': {'crop': 942, 'expScroll': 3}, 'time': 1169},
      {'lv': 4, 'hp': 246, 'atk': 36, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21104], 'gate': [4, 2004, 15], 'cost': {'crop': 1507, 'expScroll': 4}, 'time': 1754},
      {'lv': 5, 'hp': 308, 'atk': 44, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21105], 'gate': [4, 2004, 20], 'cost': {'crop': 2411, 'expScroll': 5}, 'time': 2631},
      {'lv': 6, 'hp': 386, 'atk': 53, 'range': 1, 'move': 4, 'rage': 4, 'initRage': 2, 'skills': [10104, 10204, 21106], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3404': [
      {'lv': 1, 'hp': 256, 'atk': 7, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21301], 'gate': [4, 2004, 1], 'cost': {'crop': 429, 'expScroll': 1}, 'time': 525},
      {'lv': 2, 'hp': 320, 'atk': 9, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21302], 'gate': [4, 2004, 5], 'cost': {'crop': 686, 'expScroll': 2}, 'time': 788},
      {'lv': 3, 'hp': 400, 'atk': 11, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21303], 'gate': [4, 2004, 10], 'cost': {'crop': 1098, 'expScroll': 3}, 'time': 1182},
      {'lv': 4, 'hp': 500, 'atk': 14, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21304], 'gate': [4, 2004, 15], 'cost': {'crop': 1757, 'expScroll': 4}, 'time': 1773},
      {'lv': 5, 'hp': 625, 'atk': 18, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21305], 'gate': [4, 2004, 20], 'cost': {'crop': 2811, 'expScroll': 5}, 'time': 2660},
      {'lv': 6, 'hp': 781, 'atk': 23, 'range': 1, 'move': 4, 'rage': 12, 'initRage': 4, 'skills': [10104, 10204, 21306], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3405': [
      {'lv': 1, 'hp': 93, 'atk': 8, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21701], 'gate': [4, 2004, 1], 'cost': {'crop': 336, 'expScroll': 1}, 'time': 497},
      {'lv': 2, 'hp': 112, 'atk': 10, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21702], 'gate': [4, 2004, 5], 'cost': {'crop': 538, 'expScroll': 2}, 'time': 746},
      {'lv': 3, 'hp': 134, 'atk': 12, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21703], 'gate': [4, 2004, 10], 'cost': {'crop': 861, 'expScroll': 3}, 'time': 1119},
      {'lv': 4, 'hp': 161, 'atk': 14, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21704], 'gate': [4, 2004, 15], 'cost': {'crop': 1378, 'expScroll': 4}, 'time': 1679},
      {'lv': 5, 'hp': 193, 'atk': 16, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21705], 'gate': [4, 2004, 20], 'cost': {'crop': 2205, 'expScroll': 5}, 'time': 2519},
      {'lv': 6, 'hp': 232, 'atk': 18, 'range': 4, 'move': 4, 'rage': 6, 'initRage': 2, 'skills': [10106, 10206, 21706], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3406': [
      {'lv': 1, 'hp': 202, 'atk': 9, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11601, 11701], 'gate': [4, 2004, 1], 'cost': {'crop': 352, 'expScroll': 1}, 'time': 504},
      {'lv': 2, 'hp': 253, 'atk': 11, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11602, 11702], 'gate': [4, 2004, 5], 'cost': {'crop': 563, 'expScroll': 2}, 'time': 756},
      {'lv': 3, 'hp': 316, 'atk': 14, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11603, 11703], 'gate': [4, 2004, 10], 'cost': {'crop': 901, 'expScroll': 3}, 'time': 1134},
      {'lv': 4, 'hp': 395, 'atk': 17, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11604, 11704], 'gate': [4, 2004, 15], 'cost': {'crop': 1442, 'expScroll': 4}, 'time': 1701},
      {'lv': 5, 'hp': 494, 'atk': 21, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11605, 11705], 'gate': [4, 2004, 20], 'cost': {'crop': 2307, 'expScroll': 5}, 'time': 2552},
      {'lv': 6, 'hp': 618, 'atk': 26, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 11606, 11706], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3501': [
      {'lv': 1, 'hp': 50, 'atk': 15, 'range': 5, 'move': 1, 'rage': 0, 'initRage': 0, 'skills': [10105], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3502': [
      {'lv': 1, 'hp': 50, 'atk': 18, 'range': 5, 'move': 1, 'rage': 0, 'initRage': 0, 'skills': [12301, 12401], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3601': [
      {'lv': 1, 'hp': 0, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3701': [
      {'lv': 1, 'hp': 0, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3702': [
      {'lv': 1, 'hp': 0, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 0, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 0, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 0, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 0, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '3703': [
      {'lv': 1, 'hp': 0, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4101': [
      {'lv': 1, 'hp': 25, 'atk': 13, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 50, 'atk': 15, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 101, 'atk': 17, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 201, 'atk': 20, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 301, 'atk': 24, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 404, 'atk': 28, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 5, 'skills': [31101], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4102': [
      {'lv': 1, 'hp': 30, 'atk': 14, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 60, 'atk': 17, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 123, 'atk': 20, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 243, 'atk': 23, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 363, 'atk': 26, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 483, 'atk': 29, 'range': 1, 'move': 4, 'rage': 6, 'initRage': 6, 'skills': [31201], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4103': [
      {'lv': 1, 'hp': 227, 'atk': 21, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 303, 'atk': 23, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 368, 'atk': 25, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 708, 'atk': 32, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 748, 'atk': 34, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 788, 'atk': 36, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30401], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4104': [
      {'lv': 1, 'hp': 243, 'atk': 16, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 328, 'atk': 18, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 394, 'atk': 20, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 732, 'atk': 28, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 772, 'atk': 30, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 812, 'atk': 32, 'range': 1, 'move': 4, 'rage': 10, 'initRage': 5, 'skills': [30501], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4105': [
      {'lv': 1, 'hp': 124, 'atk': 17, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 208, 'atk': 20, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 302, 'atk': 23, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 622, 'atk': 26, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 643, 'atk': 28, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 664, 'atk': 30, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10501], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4106': [
      {'lv': 1, 'hp': 145, 'atk': 16, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 231, 'atk': 19, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 323, 'atk': 21, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 646, 'atk': 26, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 668, 'atk': 28, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 688, 'atk': 30, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30101], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4107': [
      {'lv': 1, 'hp': 101, 'atk': 16, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 146, 'atk': 20, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 221, 'atk': 23, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 434, 'atk': 27, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 466, 'atk': 30, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 488, 'atk': 33, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10601], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4108': [
      {'lv': 1, 'hp': 36, 'atk': 18, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 88, 'atk': 20, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 115, 'atk': 25, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 184, 'atk': 28, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 274, 'atk': 30, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 364, 'atk': 32, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10701], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4109': [
      {'lv': 1, 'hp': 50, 'atk': 12, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 85, 'atk': 14, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 129, 'atk': 18, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11502], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 215, 'atk': 24, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11502], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 248, 'atk': 26, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11502], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 301, 'atk': 28, 'range': 4, 'move': 2, 'rage': 0, 'initRage': 0, 'skills': [11503], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4110': [
      {'lv': 1, 'hp': 199, 'atk': 19, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 276, 'atk': 25, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 473, 'atk': 31, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 802, 'atk': 34, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 852, 'atk': 37, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 902, 'atk': 39, 'range': 1, 'move': 3, 'rage': 10, 'initRage': 5, 'skills': [30201], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4111': [
      {'lv': 1, 'hp': 188, 'atk': 20, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 352, 'atk': 24, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 402, 'atk': 27, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 562, 'atk': 30, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 725, 'atk': 33, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 811, 'atk': 37, 'range': 1, 'move': 3, 'rage': 12, 'initRage': 6, 'skills': [30601], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4112': [
      {'lv': 1, 'hp': 170, 'atk': 22, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 286, 'atk': 25, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 359, 'atk': 28, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 511, 'atk': 30, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 648, 'atk': 35, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 718, 'atk': 40, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [30701], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4113': [
      {'lv': 7, 'hp': 887, 'atk': 45, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [12001, 12101], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 1166, 'atk': 66, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [12001, 12101], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4114': [
      {'lv': 7, 'hp': 1004, 'atk': 115, 'range': 6, 'move': 0, 'rage': 6, 'initRage': 4, 'skills': [12001, 30801], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 1002, 'atk': 88, 'range': 6, 'move': 0, 'rage': 6, 'initRage': 4, 'skills': [12001, 30801], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4115': [
      {'lv': 7, 'hp': 1166, 'atk': 69, 'range': 6, 'move': 0, 'rage': 8, 'initRage': 4, 'skills': [12001, 30901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 1213, 'atk': 76, 'range': 6, 'move': 0, 'rage': 8, 'initRage': 4, 'skills': [12001, 30901], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4116': [
      {'lv': 1, 'hp': 51, 'atk': 12, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 91, 'atk': 16, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 182, 'atk': 20, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 271, 'atk': 23, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 342, 'atk': 26, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 503, 'atk': 29, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31301], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4117': [
      {'lv': 1, 'hp': 42, 'atk': 13, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 72, 'atk': 17, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 144, 'atk': 19, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 245, 'atk': 22, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 344, 'atk': 25, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 446, 'atk': 28, 'range': 2, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31401], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4118': [
      {'lv': 1, 'hp': 35, 'atk': 20, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 76, 'atk': 22, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 152, 'atk': 24, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 253, 'atk': 26, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 354, 'atk': 28, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 455, 'atk': 30, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31501], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4119': [
      {'lv': 1, 'hp': 207, 'atk': 20, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 348, 'atk': 22, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 489, 'atk': 24, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 580, 'atk': 26, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 671, 'atk': 28, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 712, 'atk': 30, 'range': 1, 'move': 3, 'rage': 8, 'initRage': 4, 'skills': [31601], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4201': [
      {'lv': 1, 'hp': 112, 'atk': 13, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 158, 'atk': 11, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 190, 'atk': 13, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 228, 'atk': 15, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 274, 'atk': 18, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 611, 'atk': 29, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 7, 'hp': 622, 'atk': 30, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 474, 'atk': 24, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 9, 'hp': 455, 'atk': 32, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 531, 'atk': 35, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4202': [
      {'lv': 1, 'hp': 125, 'atk': 16, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 175, 'atk': 11, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 210, 'atk': 13, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 252, 'atk': 16, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 302, 'atk': 19, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 625, 'atk': 31, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 7, 'hp': 663, 'atk': 37, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 521, 'atk': 28, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 9, 'hp': 521, 'atk': 37, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 625, 'atk': 41, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4203': [
      {'lv': 1, 'hp': 90, 'atk': 12, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 108, 'atk': 14, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 130, 'atk': 17, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 156, 'atk': 20, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 187, 'atk': 24, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 533, 'atk': 37, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 7, 'hp': 544, 'atk': 40, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 323, 'atk': 32, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 9, 'hp': 323, 'atk': 43, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 388, 'atk': 48, 'range': 1, 'move': 3, 'rage': 0, 'initRage': 0, 'skills': [10901], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4204': [
      {'lv': 1, 'hp': 80, 'atk': 7, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 96, 'atk': 8, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 115, 'atk': 10, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 138, 'atk': 12, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 166, 'atk': 14, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 247, 'atk': 20, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 7, 'hp': 344, 'atk': 26, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 287, 'atk': 23, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 9, 'hp': 344, 'atk': 26, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 413, 'atk': 29, 'range': 4, 'move': 2, 'rage': 4, 'initRage': 0, 'skills': [10103, 10203, 30301], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4205': [
      {'lv': 1, 'hp': 160, 'atk': 15, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 194, 'atk': 18, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 235, 'atk': 22, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 284, 'atk': 27, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 404, 'atk': 33, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 737, 'atk': 70, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 7, 'hp': 827, 'atk': 85, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 609, 'atk': 58, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 9, 'hp': 737, 'atk': 70, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 892, 'atk': 85, 'range': 1, 'move': 4, 'rage': 0, 'initRage': 0, 'skills': [10104, 10204, 10301], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '4206': [
      {'lv': 9, 'hp': 827, 'atk': 88, 'range': 6, 'move': 0, 'rage': 6, 'initRage': 4, 'skills': [12001, 31001], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 1034, 'atk': 110, 'range': 6, 'move': 0, 'rage': 6, 'initRage': 4, 'skills': [12001, 31001], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '7001': [
      {'lv': 1, 'hp': 40, 'atk': 12, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 45, 'atk': 14, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 50, 'atk': 16, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 55, 'atk': 18, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 60, 'atk': 20, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 65, 'atk': 22, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 7, 'hp': 70, 'atk': 24, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 75, 'atk': 26, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 9, 'hp': 80, 'atk': 28, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 85, 'atk': 30, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 11, 'hp': 90, 'atk': 32, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 12, 'hp': 95, 'atk': 34, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 13, 'hp': 100, 'atk': 36, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 14, 'hp': 105, 'atk': 38, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 15, 'hp': 110, 'atk': 40, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 16, 'hp': 115, 'atk': 42, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 17, 'hp': 120, 'atk': 44, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 18, 'hp': 125, 'atk': 46, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 19, 'hp': 130, 'atk': 48, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 20, 'hp': 135, 'atk': 50, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 21, 'hp': 140, 'atk': 52, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 22, 'hp': 145, 'atk': 54, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 23, 'hp': 150, 'atk': 56, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 24, 'hp': 155, 'atk': 58, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 25, 'hp': 160, 'atk': 60, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 26, 'hp': 165, 'atk': 62, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 27, 'hp': 170, 'atk': 64, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 28, 'hp': 175, 'atk': 66, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 29, 'hp': 180, 'atk': 68, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '7002': [
      {'lv': 1, 'hp': 80, 'atk': 16, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 90, 'atk': 18, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 100, 'atk': 20, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 110, 'atk': 22, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 120, 'atk': 24, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 130, 'atk': 26, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 7, 'hp': 140, 'atk': 28, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 150, 'atk': 30, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 9, 'hp': 160, 'atk': 32, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 170, 'atk': 34, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 11, 'hp': 180, 'atk': 36, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 12, 'hp': 190, 'atk': 38, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 13, 'hp': 200, 'atk': 40, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 14, 'hp': 210, 'atk': 42, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 15, 'hp': 220, 'atk': 44, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 16, 'hp': 230, 'atk': 46, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 17, 'hp': 240, 'atk': 48, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 18, 'hp': 250, 'atk': 50, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 19, 'hp': 260, 'atk': 52, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 20, 'hp': 270, 'atk': 54, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '7003': [
      {'lv': 1, 'hp': 200, 'atk': 22, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 220, 'atk': 25, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 240, 'atk': 28, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 260, 'atk': 31, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 280, 'atk': 34, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 300, 'atk': 37, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 7, 'hp': 320, 'atk': 40, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 340, 'atk': 43, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 9, 'hp': 360, 'atk': 46, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 380, 'atk': 49, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 11, 'hp': 400, 'atk': 52, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 12, 'hp': 420, 'atk': 55, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 13, 'hp': 440, 'atk': 58, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 14, 'hp': 460, 'atk': 61, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 15, 'hp': 480, 'atk': 64, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 16, 'hp': 500, 'atk': 67, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 17, 'hp': 520, 'atk': 70, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 18, 'hp': 540, 'atk': 73, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 19, 'hp': 560, 'atk': 76, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 20, 'hp': 580, 'atk': 79, 'range': 6, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
    '8001': [
      {'lv': 1, 'hp': 300, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 2, 'hp': 320, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 3, 'hp': 340, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 4, 'hp': 360, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 5, 'hp': 380, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 6, 'hp': 400, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 7, 'hp': 420, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 8, 'hp': 440, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 9, 'hp': 460, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 10, 'hp': 480, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 11, 'hp': 500, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 12, 'hp': 520, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 13, 'hp': 540, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 14, 'hp': 560, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 15, 'hp': 580, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 16, 'hp': 600, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 17, 'hp': 620, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 18, 'hp': 640, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 19, 'hp': 660, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
      {'lv': 20, 'hp': 680, 'atk': 0, 'range': 0, 'move': 0, 'rage': 0, 'initRage': 0, 'skills': [], 'gate': null, 'cost': {}, 'time': 0},
    ],
  };

  static const Map<int, List<Map<String, dynamic>>> BUILD_LADDER = {
    2000: [
      {'lv': 0, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 180, 'stone': 220}, 'time': 550, 'gate': '4,2001,5', 'effects': <int, num>{9: 0}},
      {'lv': 2, 'cost': <String, int>{'wood': 216, 'stone': 264}, 'time': 660, 'gate': null, 'effects': <int, num>{9: 20}},
      {'lv': 3, 'cost': <String, int>{'wood': 259, 'stone': 317}, 'time': 790, 'gate': null, 'effects': <int, num>{9: 40}},
      {'lv': 4, 'cost': <String, int>{'wood': 311, 'stone': 381}, 'time': 950, 'gate': null, 'effects': <int, num>{9: 60}},
      {'lv': 5, 'cost': <String, int>{'wood': 375, 'stone': 459}, 'time': 1150, 'gate': null, 'effects': <int, num>{9: 80}},
      {'lv': 6, 'cost': <String, int>{'wood': 454, 'stone': 555}, 'time': 1390, 'gate': null, 'effects': <int, num>{9: 100}},
      {'lv': 7, 'cost': <String, int>{'wood': 552, 'stone': 674}, 'time': 1690, 'gate': null, 'effects': <int, num>{9: 120}},
      {'lv': 8, 'cost': <String, int>{'wood': 674, 'stone': 823}, 'time': 2060, 'gate': null, 'effects': <int, num>{9: 140}},
      {'lv': 9, 'cost': <String, int>{'wood': 827, 'stone': 1011}, 'time': 2530, 'gate': null, 'effects': <int, num>{9: 160}},
      {'lv': 10, 'cost': <String, int>{'wood': 1022, 'stone': 1249}, 'time': 3130, 'gate': null, 'effects': <int, num>{9: 180}},
      {'lv': 11, 'cost': <String, int>{'wood': 1271, 'stone': 1554}, 'time': 3890, 'gate': null, 'effects': <int, num>{9: 200}},
      {'lv': 12, 'cost': <String, int>{'wood': 1593, 'stone': 1947}, 'time': 4880, 'gate': null, 'effects': <int, num>{9: 220}},
      {'lv': 13, 'cost': <String, int>{'wood': 2012, 'stone': 2459}, 'time': 6160, 'gate': null, 'effects': <int, num>{9: 240}},
      {'lv': 14, 'cost': <String, int>{'wood': 2560, 'stone': 3128}, 'time': 7840, 'gate': null, 'effects': <int, num>{9: 260}},
      {'lv': 15, 'cost': <String, int>{'wood': 3283, 'stone': 4013}, 'time': 10060, 'gate': null, 'effects': <int, num>{9: 280}},
      {'lv': 16, 'cost': <String, int>{'wood': 4246, 'stone': 5189}, 'time': 13010, 'gate': null, 'effects': <int, num>{9: 300}},
      {'lv': 17, 'cost': <String, int>{'wood': 5535, 'stone': 6766}, 'time': 16960, 'gate': null, 'effects': <int, num>{9: 320}},
      {'lv': 18, 'cost': <String, int>{'wood': 7277, 'stone': 8894}, 'time': 22290, 'gate': null, 'effects': <int, num>{9: 340}},
      {'lv': 19, 'cost': <String, int>{'wood': 9644, 'stone': 11788}, 'time': 29540, 'gate': null, 'effects': <int, num>{9: 360}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{9: 380}},
    ],
    2001: [
      {'lv': 0, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 178, 'stone': 178}, 'time': 20, 'gate': null, 'effects': <int, num>{11: 2, 63: 3}},
      {'lv': 2, 'cost': <String, int>{'wood': 221, 'stone': 221}, 'time': 180, 'gate': null, 'effects': <int, num>{11: 3, 63: 5}},
      {'lv': 3, 'cost': <String, int>{'wood': 272, 'stone': 272}, 'time': 360, 'gate': null, 'effects': <int, num>{11: 3, 63: 5}},
      {'lv': 4, 'cost': <String, int>{'wood': 335, 'stone': 335}, 'time': 580, 'gate': null, 'effects': <int, num>{11: 4, 63: 5}},
      {'lv': 5, 'cost': <String, int>{'wood': 411, 'stone': 411}, 'time': 820, 'gate': null, 'effects': <int, num>{11: 4, 63: 7}},
      {'lv': 6, 'cost': <String, int>{'wood': 505, 'stone': 505}, 'time': 1080, 'gate': '12,0,10', 'effects': <int, num>{11: 5, 63: 9}},
      {'lv': 7, 'cost': <String, int>{'wood': 622, 'stone': 622}, 'time': 1370, 'gate': '12,0,20', 'effects': <int, num>{11: 5, 63: 9}},
      {'lv': 8, 'cost': <String, int>{'wood': 767, 'stone': 767}, 'time': 1690, 'gate': '12,0,30', 'effects': <int, num>{11: 6, 63: 9}},
      {'lv': 9, 'cost': <String, int>{'wood': 951, 'stone': 951}, 'time': 2100, 'gate': '12,0,40', 'effects': <int, num>{11: 6, 63: 9}},
      {'lv': 10, 'cost': <String, int>{'wood': 1184, 'stone': 1184}, 'time': 2620, 'gate': '12,0,50', 'effects': <int, num>{11: 7, 63: 9}},
      {'lv': 11, 'cost': <String, int>{'wood': 1482, 'stone': 1482}, 'time': 3280, 'gate': '12,0,60', 'effects': <int, num>{11: 7, 63: 9}},
      {'lv': 12, 'cost': <String, int>{'wood': 1866, 'stone': 1866}, 'time': 4140, 'gate': '12,0,70', 'effects': <int, num>{11: 8, 63: 9}},
      {'lv': 13, 'cost': <String, int>{'wood': 2366, 'stone': 2366}, 'time': 5260, 'gate': '12,0,80', 'effects': <int, num>{11: 8, 63: 9}},
      {'lv': 14, 'cost': <String, int>{'wood': 3021, 'stone': 3021}, 'time': 6730, 'gate': '12,0,90', 'effects': <int, num>{11: 9, 63: 9}},
      {'lv': 15, 'cost': <String, int>{'wood': 3886, 'stone': 3886}, 'time': 8660, 'gate': '12,0,100', 'effects': <int, num>{11: 9, 63: 9}},
      {'lv': 16, 'cost': <String, int>{'wood': 5036, 'stone': 5036}, 'time': 11230, 'gate': '12,0,110', 'effects': <int, num>{11: 10, 63: 9}},
      {'lv': 17, 'cost': <String, int>{'wood': 6577, 'stone': 6577}, 'time': 14680, 'gate': '12,0,120', 'effects': <int, num>{11: 10, 63: 9}},
      {'lv': 18, 'cost': <String, int>{'wood': 8657, 'stone': 8657}, 'time': 19330, 'gate': '12,0,130', 'effects': <int, num>{11: 11, 63: 9}},
      {'lv': 19, 'cost': <String, int>{'wood': 11487, 'stone': 11487}, 'time': 25660, 'gate': '12,0,140', 'effects': <int, num>{11: 11, 63: 9}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{11: 12, 63: 9}},
    ],
    2002: [
      {'lv': 0, 'cost': <String, int>{'wood': 85, 'stone': 66}, 'time': 40, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 144, 'stone': 118}, 'time': 80, 'gate': null, 'effects': <int, num>{3: 1500}},
      {'lv': 2, 'cost': <String, int>{'wood': 178, 'stone': 146}, 'time': 180, 'gate': null, 'effects': <int, num>{3: 3100}},
      {'lv': 3, 'cost': <String, int>{'wood': 219, 'stone': 180}, 'time': 300, 'gate': null, 'effects': <int, num>{3: 4700}},
      {'lv': 4, 'cost': <String, int>{'wood': 270, 'stone': 221}, 'time': 440, 'gate': null, 'effects': <int, num>{3: 6400}},
      {'lv': 5, 'cost': <String, int>{'wood': 332, 'stone': 272}, 'time': 600, 'gate': null, 'effects': <int, num>{3: 8200}},
      {'lv': 6, 'cost': <String, int>{'wood': 409, 'stone': 335}, 'time': 720, 'gate': null, 'effects': <int, num>{3: 10000}},
      {'lv': 7, 'cost': <String, int>{'wood': 505, 'stone': 414}, 'time': 870, 'gate': null, 'effects': <int, num>{3: 11900}},
      {'lv': 8, 'cost': <String, int>{'wood': 627, 'stone': 513}, 'time': 1060, 'gate': null, 'effects': <int, num>{3: 13900}},
      {'lv': 9, 'cost': <String, int>{'wood': 782, 'stone': 639}, 'time': 1300, 'gate': null, 'effects': <int, num>{3: 16000}},
      {'lv': 10, 'cost': <String, int>{'wood': 980, 'stone': 801}, 'time': 1610, 'gate': null, 'effects': <int, num>{3: 18100}},
      {'lv': 11, 'cost': <String, int>{'wood': 1235, 'stone': 1010}, 'time': 2010, 'gate': null, 'effects': <int, num>{3: 20300}},
      {'lv': 12, 'cost': <String, int>{'wood': 1566, 'stone': 1282}, 'time': 2530, 'gate': null, 'effects': <int, num>{3: 22600}},
      {'lv': 13, 'cost': <String, int>{'wood': 2001, 'stone': 1637}, 'time': 3210, 'gate': null, 'effects': <int, num>{3: 25000}},
      {'lv': 14, 'cost': <String, int>{'wood': 2575, 'stone': 2106}, 'time': 4100, 'gate': null, 'effects': <int, num>{3: 27500}},
      {'lv': 15, 'cost': <String, int>{'wood': 3337, 'stone': 2731}, 'time': 5290, 'gate': null, 'effects': <int, num>{3: 30100}},
      {'lv': 16, 'cost': <String, int>{'wood': 4360, 'stone': 3567}, 'time': 6880, 'gate': null, 'effects': <int, num>{3: 32800}},
      {'lv': 17, 'cost': <String, int>{'wood': 5740, 'stone': 4697}, 'time': 9020, 'gate': null, 'effects': <int, num>{3: 35600}},
      {'lv': 18, 'cost': <String, int>{'wood': 7618, 'stone': 6233}, 'time': 11940, 'gate': null, 'effects': <int, num>{3: 38500}},
      {'lv': 19, 'cost': <String, int>{'wood': 10190, 'stone': 8338}, 'time': 15940, 'gate': null, 'effects': <int, num>{3: 41500}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{3: 44700}},
    ],
    2003: [
      {'lv': 0, 'cost': <String, int>{'wood': 95, 'stone': 116}, 'time': 60, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 118, 'stone': 144}, 'time': 110, 'gate': null, 'effects': <int, num>{4: 1500}},
      {'lv': 2, 'cost': <String, int>{'wood': 146, 'stone': 178}, 'time': 215, 'gate': null, 'effects': <int, num>{4: 3100}},
      {'lv': 3, 'cost': <String, int>{'wood': 180, 'stone': 219}, 'time': 340, 'gate': null, 'effects': <int, num>{4: 4700}},
      {'lv': 4, 'cost': <String, int>{'wood': 221, 'stone': 270}, 'time': 490, 'gate': null, 'effects': <int, num>{4: 6400}},
      {'lv': 5, 'cost': <String, int>{'wood': 272, 'stone': 332}, 'time': 660, 'gate': null, 'effects': <int, num>{4: 8200}},
      {'lv': 6, 'cost': <String, int>{'wood': 335, 'stone': 409}, 'time': 790, 'gate': null, 'effects': <int, num>{4: 10000}},
      {'lv': 7, 'cost': <String, int>{'wood': 414, 'stone': 505}, 'time': 950, 'gate': null, 'effects': <int, num>{4: 11900}},
      {'lv': 8, 'cost': <String, int>{'wood': 513, 'stone': 627}, 'time': 1160, 'gate': null, 'effects': <int, num>{4: 13900}},
      {'lv': 9, 'cost': <String, int>{'wood': 639, 'stone': 782}, 'time': 1420, 'gate': null, 'effects': <int, num>{4: 16000}},
      {'lv': 10, 'cost': <String, int>{'wood': 801, 'stone': 980}, 'time': 1750, 'gate': null, 'effects': <int, num>{4: 18100}},
      {'lv': 11, 'cost': <String, int>{'wood': 1010, 'stone': 1235}, 'time': 2180, 'gate': null, 'effects': <int, num>{4: 20300}},
      {'lv': 12, 'cost': <String, int>{'wood': 1282, 'stone': 1566}, 'time': 2740, 'gate': null, 'effects': <int, num>{4: 22600}},
      {'lv': 13, 'cost': <String, int>{'wood': 1637, 'stone': 2001}, 'time': 3470, 'gate': null, 'effects': <int, num>{4: 25000}},
      {'lv': 14, 'cost': <String, int>{'wood': 2106, 'stone': 2575}, 'time': 4440, 'gate': null, 'effects': <int, num>{4: 27500}},
      {'lv': 15, 'cost': <String, int>{'wood': 2731, 'stone': 3337}, 'time': 5730, 'gate': null, 'effects': <int, num>{4: 30100}},
      {'lv': 16, 'cost': <String, int>{'wood': 3567, 'stone': 4360}, 'time': 7450, 'gate': null, 'effects': <int, num>{4: 32800}},
      {'lv': 17, 'cost': <String, int>{'wood': 4697, 'stone': 5740}, 'time': 9780, 'gate': null, 'effects': <int, num>{4: 35600}},
      {'lv': 18, 'cost': <String, int>{'wood': 6233, 'stone': 7618}, 'time': 12940, 'gate': null, 'effects': <int, num>{4: 38500}},
      {'lv': 19, 'cost': <String, int>{'wood': 8338, 'stone': 10190}, 'time': 17270, 'gate': null, 'effects': <int, num>{4: 41500}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{4: 44700}},
    ],
    2004: [
      {'lv': 0, 'cost': <String, int>{'wood': 157, 'stone': 128}, 'time': 2, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 193, 'stone': 158}, 'time': 30, 'gate': null, 'effects': <int, num>{5: 0}},
      {'lv': 2, 'cost': <String, int>{'wood': 235, 'stone': 193}, 'time': 220, 'gate': null, 'effects': <int, num>{5: 5}},
      {'lv': 3, 'cost': <String, int>{'wood': 287, 'stone': 235}, 'time': 420, 'gate': null, 'effects': <int, num>{5: 7}},
      {'lv': 4, 'cost': <String, int>{'wood': 350, 'stone': 287}, 'time': 660, 'gate': null, 'effects': <int, num>{5: 10}},
      {'lv': 5, 'cost': <String, int>{'wood': 428, 'stone': 350}, 'time': 800, 'gate': null, 'effects': <int, num>{5: 12}},
      {'lv': 6, 'cost': <String, int>{'wood': 524, 'stone': 429}, 'time': 970, 'gate': null, 'effects': <int, num>{5: 15}},
      {'lv': 7, 'cost': <String, int>{'wood': 645, 'stone': 527}, 'time': 1190, 'gate': null, 'effects': <int, num>{5: 17}},
      {'lv': 8, 'cost': <String, int>{'wood': 796, 'stone': 652}, 'time': 1460, 'gate': null, 'effects': <int, num>{5: 20}},
      {'lv': 9, 'cost': <String, int>{'wood': 989, 'stone': 810}, 'time': 1800, 'gate': null, 'effects': <int, num>{5: 22}},
      {'lv': 10, 'cost': <String, int>{'wood': 1236, 'stone': 1012}, 'time': 2240, 'gate': null, 'effects': <int, num>{5: 25}},
      {'lv': 11, 'cost': <String, int>{'wood': 1555, 'stone': 1272}, 'time': 2810, 'gate': null, 'effects': <int, num>{5: 27}},
      {'lv': 12, 'cost': <String, int>{'wood': 1969, 'stone': 1611}, 'time': 3550, 'gate': null, 'effects': <int, num>{5: 30}},
      {'lv': 13, 'cost': <String, int>{'wood': 2511, 'stone': 2055}, 'time': 4520, 'gate': null, 'effects': <int, num>{5: 32}},
      {'lv': 14, 'cost': <String, int>{'wood': 3227, 'stone': 2641}, 'time': 5800, 'gate': null, 'effects': <int, num>{5: 35}},
      {'lv': 15, 'cost': <String, int>{'wood': 4180, 'stone': 3420}, 'time': 7500, 'gate': null, 'effects': <int, num>{5: 37}},
      {'lv': 16, 'cost': <String, int>{'wood': 5457, 'stone': 4464}, 'time': 9770, 'gate': null, 'effects': <int, num>{5: 40}},
      {'lv': 17, 'cost': <String, int>{'wood': 7180, 'stone': 5874}, 'time': 12840, 'gate': null, 'effects': <int, num>{5: 42}},
      {'lv': 18, 'cost': <String, int>{'wood': 9523, 'stone': 7792}, 'time': 17020, 'gate': null, 'effects': <int, num>{5: 45}},
      {'lv': 19, 'cost': <String, int>{'wood': 12734, 'stone': 10419}, 'time': 22740, 'gate': null, 'effects': <int, num>{5: 47}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{5: 50}},
    ],
    2005: [
      {'lv': 0, 'cost': <String, int>{'wood': 155, 'stone': 155}, 'time': 180, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 185, 'stone': 185}, 'time': 300, 'gate': null, 'effects': <int, num>{}},
      {'lv': 2, 'cost': <String, int>{'wood': 221, 'stone': 221}, 'time': 480, 'gate': null, 'effects': <int, num>{}},
      {'lv': 3, 'cost': <String, int>{'wood': 265, 'stone': 265}, 'time': 580, 'gate': null, 'effects': <int, num>{6: 6}},
      {'lv': 4, 'cost': <String, int>{'wood': 318, 'stone': 318}, 'time': 700, 'gate': null, 'effects': <int, num>{6: 8}},
      {'lv': 5, 'cost': <String, int>{'wood': 383, 'stone': 383}, 'time': 840, 'gate': null, 'effects': <int, num>{6: 10}},
      {'lv': 6, 'cost': <String, int>{'wood': 463, 'stone': 463}, 'time': 1020, 'gate': null, 'effects': <int, num>{6: 12}},
      {'lv': 7, 'cost': <String, int>{'wood': 564, 'stone': 564}, 'time': 1240, 'gate': null, 'effects': <int, num>{6: 14}},
      {'lv': 8, 'cost': <String, int>{'wood': 690, 'stone': 690}, 'time': 1520, 'gate': null, 'effects': <int, num>{6: 16}},
      {'lv': 9, 'cost': <String, int>{'wood': 851, 'stone': 851}, 'time': 1880, 'gate': null, 'effects': <int, num>{6: 18}},
      {'lv': 10, 'cost': <String, int>{'wood': 1056, 'stone': 1056}, 'time': 2340, 'gate': null, 'effects': <int, num>{6: 20}},
      {'lv': 11, 'cost': <String, int>{'wood': 1321, 'stone': 1321}, 'time': 2930, 'gate': null, 'effects': <int, num>{6: 22}},
      {'lv': 12, 'cost': <String, int>{'wood': 1666, 'stone': 1666}, 'time': 3700, 'gate': null, 'effects': <int, num>{6: 24}},
      {'lv': 13, 'cost': <String, int>{'wood': 2117, 'stone': 2117}, 'time': 4710, 'gate': null, 'effects': <int, num>{6: 26}},
      {'lv': 14, 'cost': <String, int>{'wood': 2713, 'stone': 2713}, 'time': 6040, 'gate': null, 'effects': <int, num>{6: 28}},
      {'lv': 15, 'cost': <String, int>{'wood': 3506, 'stone': 3506}, 'time': 7810, 'gate': null, 'effects': <int, num>{6: 30}},
      {'lv': 16, 'cost': <String, int>{'wood': 4568, 'stone': 4568}, 'time': 10180, 'gate': null, 'effects': <int, num>{6: 32}},
      {'lv': 17, 'cost': <String, int>{'wood': 6001, 'stone': 6001}, 'time': 13370, 'gate': null, 'effects': <int, num>{6: 34}},
      {'lv': 18, 'cost': <String, int>{'wood': 7951, 'stone': 7951}, 'time': 17710, 'gate': null, 'effects': <int, num>{6: 36}},
      {'lv': 19, 'cost': <String, int>{'wood': 10622, 'stone': 10622}, 'time': 23660, 'gate': null, 'effects': <int, num>{6: 38}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{6: 40}},
    ],
    2006: [
      {'lv': 0, 'cost': <String, int>{'wood': 165, 'stone': 135}, 'time': 340, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 205, 'stone': 167}, 'time': 410, 'gate': null, 'effects': <int, num>{7: 1}},
      {'lv': 2, 'cost': <String, int>{'wood': 252, 'stone': 206}, 'time': 490, 'gate': null, 'effects': <int, num>{7: 2}},
      {'lv': 3, 'cost': <String, int>{'wood': 309, 'stone': 253}, 'time': 590, 'gate': null, 'effects': <int, num>{7: 3}},
      {'lv': 4, 'cost': <String, int>{'wood': 379, 'stone': 310}, 'time': 710, 'gate': null, 'effects': <int, num>{7: 4}},
      {'lv': 5, 'cost': <String, int>{'wood': 465, 'stone': 380}, 'time': 860, 'gate': null, 'effects': <int, num>{7: 5}},
      {'lv': 6, 'cost': <String, int>{'wood': 571, 'stone': 467}, 'time': 1050, 'gate': null, 'effects': <int, num>{7: 6}},
      {'lv': 7, 'cost': <String, int>{'wood': 703, 'stone': 576}, 'time': 1290, 'gate': null, 'effects': <int, num>{7: 7}},
      {'lv': 8, 'cost': <String, int>{'wood': 871, 'stone': 712}, 'time': 1590, 'gate': null, 'effects': <int, num>{7: 8}},
      {'lv': 9, 'cost': <String, int>{'wood': 1083, 'stone': 886}, 'time': 1970, 'gate': null, 'effects': <int, num>{7: 9}},
      {'lv': 10, 'cost': <String, int>{'wood': 1355, 'stone': 1108}, 'time': 2460, 'gate': null, 'effects': <int, num>{7: 10}},
      {'lv': 11, 'cost': <String, int>{'wood': 1705, 'stone': 1395}, 'time': 3090, 'gate': null, 'effects': <int, num>{7: 11}},
      {'lv': 12, 'cost': <String, int>{'wood': 2160, 'stone': 1768}, 'time': 3910, 'gate': null, 'effects': <int, num>{7: 12}},
      {'lv': 13, 'cost': <String, int>{'wood': 2757, 'stone': 2256}, 'time': 4980, 'gate': null, 'effects': <int, num>{7: 13}},
      {'lv': 14, 'cost': <String, int>{'wood': 3545, 'stone': 2900}, 'time': 6400, 'gate': null, 'effects': <int, num>{7: 14}},
      {'lv': 15, 'cost': <String, int>{'wood': 4593, 'stone': 3758}, 'time': 8280, 'gate': null, 'effects': <int, num>{7: 15}},
      {'lv': 16, 'cost': <String, int>{'wood': 5997, 'stone': 4906}, 'time': 10800, 'gate': null, 'effects': <int, num>{7: 16}},
      {'lv': 17, 'cost': <String, int>{'wood': 7893, 'stone': 6458}, 'time': 14210, 'gate': null, 'effects': <int, num>{7: 17}},
      {'lv': 18, 'cost': <String, int>{'wood': 10471, 'stone': 8567}, 'time': 18840, 'gate': null, 'effects': <int, num>{7: 18}},
      {'lv': 19, 'cost': <String, int>{'wood': 14004, 'stone': 11457}, 'time': 25190, 'gate': null, 'effects': <int, num>{7: 19}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{7: 20}},
    ],
    2008: [
      {'lv': 0, 'cost': <String, int>{'wood': 128, 'stone': 157}, 'time': 120, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 158, 'stone': 193}, 'time': 320, 'gate': null, 'effects': <int, num>{10: 0}},
      {'lv': 2, 'cost': <String, int>{'wood': 193, 'stone': 235}, 'time': 520, 'gate': null, 'effects': <int, num>{10: 6}},
      {'lv': 3, 'cost': <String, int>{'wood': 235, 'stone': 287}, 'time': 630, 'gate': null, 'effects': <int, num>{10: 9}},
      {'lv': 4, 'cost': <String, int>{'wood': 287, 'stone': 350}, 'time': 760, 'gate': '4,2004,2', 'effects': <int, num>{10: 12}},
      {'lv': 5, 'cost': <String, int>{'wood': 350, 'stone': 428}, 'time': 920, 'gate': null, 'effects': <int, num>{10: 15}},
      {'lv': 6, 'cost': <String, int>{'wood': 429, 'stone': 524}, 'time': 1120, 'gate': '4,2004,4', 'effects': <int, num>{10: 18}},
      {'lv': 7, 'cost': <String, int>{'wood': 527, 'stone': 645}, 'time': 1370, 'gate': null, 'effects': <int, num>{10: 21}},
      {'lv': 8, 'cost': <String, int>{'wood': 652, 'stone': 796}, 'time': 1690, 'gate': null, 'effects': <int, num>{10: 24}},
      {'lv': 9, 'cost': <String, int>{'wood': 810, 'stone': 989}, 'time': 2100, 'gate': '4,2004,7', 'effects': <int, num>{10: 27}},
      {'lv': 10, 'cost': <String, int>{'wood': 1012, 'stone': 1236}, 'time': 2620, 'gate': null, 'effects': <int, num>{10: 30}},
      {'lv': 11, 'cost': <String, int>{'wood': 1272, 'stone': 1555}, 'time': 3290, 'gate': null, 'effects': <int, num>{10: 33}},
      {'lv': 12, 'cost': <String, int>{'wood': 1611, 'stone': 1969}, 'time': 4160, 'gate': null, 'effects': <int, num>{10: 36}},
      {'lv': 13, 'cost': <String, int>{'wood': 2055, 'stone': 2511}, 'time': 5300, 'gate': null, 'effects': <int, num>{10: 39}},
      {'lv': 14, 'cost': <String, int>{'wood': 2641, 'stone': 3227}, 'time': 6810, 'gate': null, 'effects': <int, num>{10: 42}},
      {'lv': 15, 'cost': <String, int>{'wood': 3420, 'stone': 4180}, 'time': 8810, 'gate': null, 'effects': <int, num>{10: 45}},
      {'lv': 16, 'cost': <String, int>{'wood': 4464, 'stone': 5457}, 'time': 11500, 'gate': null, 'effects': <int, num>{10: 48}},
      {'lv': 17, 'cost': <String, int>{'wood': 5874, 'stone': 7180}, 'time': 15130, 'gate': null, 'effects': <int, num>{10: 51}},
      {'lv': 18, 'cost': <String, int>{'wood': 7792, 'stone': 9523}, 'time': 20060, 'gate': null, 'effects': <int, num>{10: 54}},
      {'lv': 19, 'cost': <String, int>{'wood': 10419, 'stone': 12734}, 'time': 26810, 'gate': null, 'effects': <int, num>{10: 57}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{10: 60}},
    ],
    2010: [
      {'lv': 0, 'cost': <String, int>{'wood': 154, 'stone': 126}, 'time': 355, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 195, 'stone': 160}, 'time': 440, 'gate': null, 'effects': <int, num>{5: 0}},
      {'lv': 2, 'cost': <String, int>{'wood': 245, 'stone': 200}, 'time': 540, 'gate': null, 'effects': <int, num>{5: 5}},
      {'lv': 3, 'cost': <String, int>{'wood': 305, 'stone': 249}, 'time': 660, 'gate': null, 'effects': <int, num>{5: 7}},
      {'lv': 4, 'cost': <String, int>{'wood': 378, 'stone': 309}, 'time': 810, 'gate': null, 'effects': <int, num>{5: 10}},
      {'lv': 5, 'cost': <String, int>{'wood': 468, 'stone': 383}, 'time': 990, 'gate': null, 'effects': <int, num>{5: 12}},
      {'lv': 6, 'cost': <String, int>{'wood': 580, 'stone': 474}, 'time': 1210, 'gate': null, 'effects': <int, num>{5: 15}},
      {'lv': 7, 'cost': <String, int>{'wood': 719, 'stone': 589}, 'time': 1490, 'gate': null, 'effects': <int, num>{5: 17}},
      {'lv': 8, 'cost': <String, int>{'wood': 895, 'stone': 733}, 'time': 1840, 'gate': null, 'effects': <int, num>{5: 20}},
      {'lv': 9, 'cost': <String, int>{'wood': 1119, 'stone': 915}, 'time': 2280, 'gate': null, 'effects': <int, num>{5: 22}},
      {'lv': 10, 'cost': <String, int>{'wood': 1405, 'stone': 1149}, 'time': 2850, 'gate': null, 'effects': <int, num>{5: 25}},
      {'lv': 11, 'cost': <String, int>{'wood': 1774, 'stone': 1451}, 'time': 3580, 'gate': null, 'effects': <int, num>{5: 27}},
      {'lv': 12, 'cost': <String, int>{'wood': 2253, 'stone': 1844}, 'time': 4530, 'gate': null, 'effects': <int, num>{5: 30}},
      {'lv': 13, 'cost': <String, int>{'wood': 2881, 'stone': 2358}, 'time': 5770, 'gate': null, 'effects': <int, num>{5: 32}},
      {'lv': 14, 'cost': <String, int>{'wood': 3710, 'stone': 3036}, 'time': 7410, 'gate': null, 'effects': <int, num>{5: 35}},
      {'lv': 15, 'cost': <String, int>{'wood': 4813, 'stone': 3938}, 'time': 9590, 'gate': null, 'effects': <int, num>{5: 37}},
      {'lv': 16, 'cost': <String, int>{'wood': 6289, 'stone': 5146}, 'time': 12520, 'gate': null, 'effects': <int, num>{5: 40}},
      {'lv': 17, 'cost': <String, int>{'wood': 8283, 'stone': 6777}, 'time': 16470, 'gate': null, 'effects': <int, num>{5: 42}},
      {'lv': 18, 'cost': <String, int>{'wood': 10995, 'stone': 8996}, 'time': 21840, 'gate': null, 'effects': <int, num>{5: 45}},
      {'lv': 19, 'cost': <String, int>{'wood': 14709, 'stone': 12035}, 'time': 29200, 'gate': null, 'effects': <int, num>{5: 47}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{5: 50}},
    ],
    2011: [
      {'lv': 0, 'cost': <String, int>{'wood': 154, 'stone': 126}, 'time': 330, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 198, 'stone': 162}, 'time': 420, 'gate': null, 'effects': <int, num>{13: 0}},
      {'lv': 2, 'cost': <String, int>{'wood': 251, 'stone': 205}, 'time': 510, 'gate': null, 'effects': <int, num>{13: 3}},
      {'lv': 3, 'cost': <String, int>{'wood': 315, 'stone': 257}, 'time': 610, 'gate': null, 'effects': <int, num>{13: 4}},
      {'lv': 4, 'cost': <String, int>{'wood': 393, 'stone': 321}, 'time': 740, 'gate': null, 'effects': <int, num>{13: 6}},
      {'lv': 5, 'cost': <String, int>{'wood': 489, 'stone': 400}, 'time': 900, 'gate': null, 'effects': <int, num>{13: 7}},
      {'lv': 6, 'cost': <String, int>{'wood': 608, 'stone': 498}, 'time': 1090, 'gate': null, 'effects': <int, num>{13: 9}},
      {'lv': 7, 'cost': <String, int>{'wood': 757, 'stone': 620}, 'time': 1330, 'gate': null, 'effects': <int, num>{13: 10}},
      {'lv': 8, 'cost': <String, int>{'wood': 945, 'stone': 773}, 'time': 1630, 'gate': null, 'effects': <int, num>{13: 12}},
      {'lv': 9, 'cost': <String, int>{'wood': 1183, 'stone': 968}, 'time': 2020, 'gate': null, 'effects': <int, num>{13: 13}},
      {'lv': 10, 'cost': <String, int>{'wood': 1488, 'stone': 1217}, 'time': 2510, 'gate': null, 'effects': <int, num>{13: 15}},
      {'lv': 11, 'cost': <String, int>{'wood': 1881, 'stone': 1539}, 'time': 3150, 'gate': null, 'effects': <int, num>{13: 16}},
      {'lv': 12, 'cost': <String, int>{'wood': 2393, 'stone': 1958}, 'time': 3980, 'gate': null, 'effects': <int, num>{13: 18}},
      {'lv': 13, 'cost': <String, int>{'wood': 3062, 'stone': 2506}, 'time': 5070, 'gate': null, 'effects': <int, num>{13: 19}},
      {'lv': 14, 'cost': <String, int>{'wood': 3947, 'stone': 3229}, 'time': 6500, 'gate': null, 'effects': <int, num>{13: 21}},
      {'lv': 15, 'cost': <String, int>{'wood': 5123, 'stone': 4192}, 'time': 8410, 'gate': null, 'effects': <int, num>{13: 22}},
      {'lv': 16, 'cost': <String, int>{'wood': 6700, 'stone': 5481}, 'time': 10960, 'gate': null, 'effects': <int, num>{13: 24}},
      {'lv': 17, 'cost': <String, int>{'wood': 8828, 'stone': 7223}, 'time': 14410, 'gate': null, 'effects': <int, num>{13: 25}},
      {'lv': 18, 'cost': <String, int>{'wood': 11722, 'stone': 9590}, 'time': 19100, 'gate': null, 'effects': <int, num>{13: 27}},
      {'lv': 19, 'cost': <String, int>{'wood': 15687, 'stone': 12834}, 'time': 25520, 'gate': null, 'effects': <int, num>{13: 28}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{13: 30}},
    ],
    2012: [
      {'lv': 0, 'cost': <String, int>{'wood': 187, 'stone': 153}, 'time': 355, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 226, 'stone': 185}, 'time': 430, 'gate': null, 'effects': <int, num>{}},
      {'lv': 2, 'cost': <String, int>{'wood': 272, 'stone': 222}, 'time': 520, 'gate': null, 'effects': <int, num>{}},
      {'lv': 3, 'cost': <String, int>{'wood': 328, 'stone': 268}, 'time': 630, 'gate': null, 'effects': <int, num>{}},
      {'lv': 4, 'cost': <String, int>{'wood': 396, 'stone': 324}, 'time': 760, 'gate': null, 'effects': <int, num>{}},
      {'lv': 5, 'cost': <String, int>{'wood': 480, 'stone': 393}, 'time': 920, 'gate': null, 'effects': <int, num>{}},
      {'lv': 6, 'cost': <String, int>{'wood': 585, 'stone': 478}, 'time': 1120, 'gate': null, 'effects': <int, num>{}},
      {'lv': 7, 'cost': <String, int>{'wood': 716, 'stone': 585}, 'time': 1370, 'gate': null, 'effects': <int, num>{}},
      {'lv': 8, 'cost': <String, int>{'wood': 881, 'stone': 720}, 'time': 1690, 'gate': null, 'effects': <int, num>{}},
      {'lv': 9, 'cost': <String, int>{'wood': 1090, 'stone': 892}, 'time': 2100, 'gate': null, 'effects': <int, num>{}},
      {'lv': 10, 'cost': <String, int>{'wood': 1359, 'stone': 1112}, 'time': 2620, 'gate': null, 'effects': <int, num>{}},
      {'lv': 11, 'cost': <String, int>{'wood': 1705, 'stone': 1395}, 'time': 3290, 'gate': null, 'effects': <int, num>{}},
      {'lv': 12, 'cost': <String, int>{'wood': 2155, 'stone': 1764}, 'time': 4160, 'gate': null, 'effects': <int, num>{}},
      {'lv': 13, 'cost': <String, int>{'wood': 2746, 'stone': 2246}, 'time': 5300, 'gate': null, 'effects': <int, num>{}},
      {'lv': 14, 'cost': <String, int>{'wood': 3524, 'stone': 2884}, 'time': 6810, 'gate': null, 'effects': <int, num>{}},
      {'lv': 15, 'cost': <String, int>{'wood': 4560, 'stone': 3731}, 'time': 8810, 'gate': null, 'effects': <int, num>{}},
      {'lv': 16, 'cost': <String, int>{'wood': 5948, 'stone': 4866}, 'time': 11500, 'gate': null, 'effects': <int, num>{}},
      {'lv': 17, 'cost': <String, int>{'wood': 7821, 'stone': 6399}, 'time': 15130, 'gate': null, 'effects': <int, num>{}},
      {'lv': 18, 'cost': <String, int>{'wood': 10369, 'stone': 8483}, 'time': 20060, 'gate': null, 'effects': <int, num>{}},
      {'lv': 19, 'cost': <String, int>{'wood': 13859, 'stone': 11339}, 'time': 26810, 'gate': null, 'effects': <int, num>{}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{}},
    ],
    2013: [
      {'lv': 0, 'cost': <String, int>{'wood': 180, 'stone': 220}, 'time': 360, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 214, 'stone': 261}, 'time': 450, 'gate': null, 'effects': <int, num>{}},
      {'lv': 2, 'cost': <String, int>{'wood': 254, 'stone': 311}, 'time': 550, 'gate': null, 'effects': <int, num>{}},
      {'lv': 3, 'cost': <String, int>{'wood': 303, 'stone': 371}, 'time': 670, 'gate': null, 'effects': <int, num>{}},
      {'lv': 4, 'cost': <String, int>{'wood': 363, 'stone': 444}, 'time': 820, 'gate': null, 'effects': <int, num>{}},
      {'lv': 5, 'cost': <String, int>{'wood': 437, 'stone': 534}, 'time': 1010, 'gate': null, 'effects': <int, num>{}},
      {'lv': 6, 'cost': <String, int>{'wood': 528, 'stone': 646}, 'time': 1240, 'gate': null, 'effects': <int, num>{}},
      {'lv': 7, 'cost': <String, int>{'wood': 643, 'stone': 785}, 'time': 1530, 'gate': null, 'effects': <int, num>{}},
      {'lv': 8, 'cost': <String, int>{'wood': 787, 'stone': 961}, 'time': 1890, 'gate': null, 'effects': <int, num>{}},
      {'lv': 9, 'cost': <String, int>{'wood': 969, 'stone': 1185}, 'time': 2350, 'gate': null, 'effects': <int, num>{}},
      {'lv': 10, 'cost': <String, int>{'wood': 1203, 'stone': 1471}, 'time': 2940, 'gate': null, 'effects': <int, num>{}},
      {'lv': 11, 'cost': <String, int>{'wood': 1505, 'stone': 1840}, 'time': 3700, 'gate': null, 'effects': <int, num>{}},
      {'lv': 12, 'cost': <String, int>{'wood': 1898, 'stone': 2319}, 'time': 4680, 'gate': null, 'effects': <int, num>{}},
      {'lv': 13, 'cost': <String, int>{'wood': 2412, 'stone': 2947}, 'time': 5970, 'gate': null, 'effects': <int, num>{}},
      {'lv': 14, 'cost': <String, int>{'wood': 3090, 'stone': 3776}, 'time': 7670, 'gate': null, 'effects': <int, num>{}},
      {'lv': 15, 'cost': <String, int>{'wood': 3992, 'stone': 4879}, 'time': 9930, 'gate': null, 'effects': <int, num>{}},
      {'lv': 16, 'cost': <String, int>{'wood': 5200, 'stone': 6355}, 'time': 12960, 'gate': null, 'effects': <int, num>{}},
      {'lv': 17, 'cost': <String, int>{'wood': 6831, 'stone': 8349}, 'time': 17050, 'gate': null, 'effects': <int, num>{}},
      {'lv': 18, 'cost': <String, int>{'wood': 9050, 'stone': 11061}, 'time': 22610, 'gate': null, 'effects': <int, num>{}},
      {'lv': 19, 'cost': <String, int>{'wood': 12089, 'stone': 14775}, 'time': 30220, 'gate': null, 'effects': <int, num>{}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{}},
    ],
    2014: [
      {'lv': 0, 'cost': <String, int>{'wood': 165, 'stone': 135}, 'time': 350, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 205, 'stone': 167}, 'time': 430, 'gate': null, 'effects': <int, num>{7: 1}},
      {'lv': 2, 'cost': <String, int>{'wood': 252, 'stone': 206}, 'time': 530, 'gate': null, 'effects': <int, num>{7: 2}},
      {'lv': 3, 'cost': <String, int>{'wood': 309, 'stone': 253}, 'time': 650, 'gate': null, 'effects': <int, num>{7: 3}},
      {'lv': 4, 'cost': <String, int>{'wood': 379, 'stone': 310}, 'time': 790, 'gate': null, 'effects': <int, num>{7: 4}},
      {'lv': 5, 'cost': <String, int>{'wood': 465, 'stone': 380}, 'time': 970, 'gate': null, 'effects': <int, num>{7: 5}},
      {'lv': 6, 'cost': <String, int>{'wood': 571, 'stone': 467}, 'time': 1190, 'gate': null, 'effects': <int, num>{7: 6}},
      {'lv': 7, 'cost': <String, int>{'wood': 703, 'stone': 576}, 'time': 1460, 'gate': null, 'effects': <int, num>{7: 7}},
      {'lv': 8, 'cost': <String, int>{'wood': 871, 'stone': 712}, 'time': 1800, 'gate': null, 'effects': <int, num>{7: 8}},
      {'lv': 9, 'cost': <String, int>{'wood': 1083, 'stone': 886}, 'time': 2230, 'gate': null, 'effects': <int, num>{7: 9}},
      {'lv': 10, 'cost': <String, int>{'wood': 1355, 'stone': 1108}, 'time': 2780, 'gate': null, 'effects': <int, num>{7: 10}},
      {'lv': 11, 'cost': <String, int>{'wood': 1705, 'stone': 1395}, 'time': 3500, 'gate': null, 'effects': <int, num>{7: 11}},
      {'lv': 12, 'cost': <String, int>{'wood': 2160, 'stone': 1768}, 'time': 4430, 'gate': null, 'effects': <int, num>{7: 12}},
      {'lv': 13, 'cost': <String, int>{'wood': 2757, 'stone': 2256}, 'time': 5650, 'gate': null, 'effects': <int, num>{7: 13}},
      {'lv': 14, 'cost': <String, int>{'wood': 3545, 'stone': 2900}, 'time': 7260, 'gate': null, 'effects': <int, num>{7: 14}},
      {'lv': 15, 'cost': <String, int>{'wood': 4593, 'stone': 3758}, 'time': 9400, 'gate': null, 'effects': <int, num>{7: 15}},
      {'lv': 16, 'cost': <String, int>{'wood': 5997, 'stone': 4906}, 'time': 12270, 'gate': null, 'effects': <int, num>{7: 16}},
      {'lv': 17, 'cost': <String, int>{'wood': 7893, 'stone': 6458}, 'time': 16140, 'gate': null, 'effects': <int, num>{7: 17}},
      {'lv': 18, 'cost': <String, int>{'wood': 10471, 'stone': 8567}, 'time': 21400, 'gate': null, 'effects': <int, num>{7: 18}},
      {'lv': 19, 'cost': <String, int>{'wood': 14004, 'stone': 11457}, 'time': 28610, 'gate': null, 'effects': <int, num>{7: 19}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{7: 20}},
    ],
    2015: [
      {'lv': 0, 'cost': <String, int>{'wood': 153, 'stone': 187}, 'time': 360, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 185, 'stone': 226}, 'time': 450, 'gate': null, 'effects': <int, num>{}},
      {'lv': 2, 'cost': <String, int>{'wood': 222, 'stone': 272}, 'time': 560, 'gate': null, 'effects': <int, num>{}},
      {'lv': 3, 'cost': <String, int>{'wood': 268, 'stone': 328}, 'time': 690, 'gate': null, 'effects': <int, num>{}},
      {'lv': 4, 'cost': <String, int>{'wood': 324, 'stone': 396}, 'time': 850, 'gate': null, 'effects': <int, num>{}},
      {'lv': 5, 'cost': <String, int>{'wood': 393, 'stone': 480}, 'time': 1040, 'gate': null, 'effects': <int, num>{}},
      {'lv': 6, 'cost': <String, int>{'wood': 478, 'stone': 585}, 'time': 1280, 'gate': null, 'effects': <int, num>{}},
      {'lv': 7, 'cost': <String, int>{'wood': 585, 'stone': 716}, 'time': 1580, 'gate': null, 'effects': <int, num>{}},
      {'lv': 8, 'cost': <String, int>{'wood': 720, 'stone': 881}, 'time': 1960, 'gate': null, 'effects': <int, num>{}},
      {'lv': 9, 'cost': <String, int>{'wood': 892, 'stone': 1090}, 'time': 2440, 'gate': null, 'effects': <int, num>{}},
      {'lv': 10, 'cost': <String, int>{'wood': 1112, 'stone': 1359}, 'time': 3050, 'gate': null, 'effects': <int, num>{}},
      {'lv': 11, 'cost': <String, int>{'wood': 1395, 'stone': 1705}, 'time': 3840, 'gate': null, 'effects': <int, num>{}},
      {'lv': 12, 'cost': <String, int>{'wood': 1764, 'stone': 2155}, 'time': 4860, 'gate': null, 'effects': <int, num>{}},
      {'lv': 13, 'cost': <String, int>{'wood': 2246, 'stone': 2746}, 'time': 6200, 'gate': null, 'effects': <int, num>{}},
      {'lv': 14, 'cost': <String, int>{'wood': 2884, 'stone': 3524}, 'time': 7970, 'gate': null, 'effects': <int, num>{}},
      {'lv': 15, 'cost': <String, int>{'wood': 3731, 'stone': 4560}, 'time': 10320, 'gate': null, 'effects': <int, num>{}},
      {'lv': 16, 'cost': <String, int>{'wood': 4866, 'stone': 5948}, 'time': 13470, 'gate': null, 'effects': <int, num>{}},
      {'lv': 17, 'cost': <String, int>{'wood': 6399, 'stone': 7821}, 'time': 17720, 'gate': null, 'effects': <int, num>{}},
      {'lv': 18, 'cost': <String, int>{'wood': 8483, 'stone': 10369}, 'time': 23500, 'gate': null, 'effects': <int, num>{}},
      {'lv': 19, 'cost': <String, int>{'wood': 11339, 'stone': 13859}, 'time': 31420, 'gate': null, 'effects': <int, num>{}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{}},
    ],
    2016: [
      {'lv': 0, 'cost': <String, int>{'wood': 154, 'stone': 126}, 'time': 9, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 189, 'stone': 155}, 'time': 85, 'gate': null, 'effects': <int, num>{37: 0}},
      {'lv': 2, 'cost': <String, int>{'wood': 232, 'stone': 189}, 'time': 220, 'gate': null, 'effects': <int, num>{37: 4}},
      {'lv': 3, 'cost': <String, int>{'wood': 283, 'stone': 231}, 'time': 400, 'gate': null, 'effects': <int, num>{37: 6}},
      {'lv': 4, 'cost': <String, int>{'wood': 345, 'stone': 282}, 'time': 630, 'gate': null, 'effects': <int, num>{37: 8}},
      {'lv': 5, 'cost': <String, int>{'wood': 421, 'stone': 345}, 'time': 810, 'gate': null, 'effects': <int, num>{37: 10}},
      {'lv': 6, 'cost': <String, int>{'wood': 516, 'stone': 422}, 'time': 1000, 'gate': null, 'effects': <int, num>{37: 12}},
      {'lv': 7, 'cost': <String, int>{'wood': 634, 'stone': 519}, 'time': 1240, 'gate': null, 'effects': <int, num>{37: 14}},
      {'lv': 8, 'cost': <String, int>{'wood': 783, 'stone': 641}, 'time': 1540, 'gate': null, 'effects': <int, num>{37: 16}},
      {'lv': 9, 'cost': <String, int>{'wood': 972, 'stone': 796}, 'time': 1920, 'gate': null, 'effects': <int, num>{37: 18}},
      {'lv': 10, 'cost': <String, int>{'wood': 1214, 'stone': 994}, 'time': 2410, 'gate': null, 'effects': <int, num>{37: 20}},
      {'lv': 11, 'cost': <String, int>{'wood': 1527, 'stone': 1249}, 'time': 3040, 'gate': null, 'effects': <int, num>{37: 22}},
      {'lv': 12, 'cost': <String, int>{'wood': 1933, 'stone': 1581}, 'time': 3860, 'gate': null, 'effects': <int, num>{37: 24}},
      {'lv': 13, 'cost': <String, int>{'wood': 2465, 'stone': 2016}, 'time': 4930, 'gate': null, 'effects': <int, num>{37: 26}},
      {'lv': 14, 'cost': <String, int>{'wood': 3166, 'stone': 2591}, 'time': 6350, 'gate': null, 'effects': <int, num>{37: 28}},
      {'lv': 15, 'cost': <String, int>{'wood': 4100, 'stone': 3354}, 'time': 8230, 'gate': null, 'effects': <int, num>{37: 30}},
      {'lv': 16, 'cost': <String, int>{'wood': 5350, 'stone': 4378}, 'time': 10750, 'gate': null, 'effects': <int, num>{37: 32}},
      {'lv': 17, 'cost': <String, int>{'wood': 7039, 'stone': 5759}, 'time': 14160, 'gate': null, 'effects': <int, num>{37: 34}},
      {'lv': 18, 'cost': <String, int>{'wood': 9335, 'stone': 7638}, 'time': 18790, 'gate': null, 'effects': <int, num>{37: 36}},
      {'lv': 19, 'cost': <String, int>{'wood': 12481, 'stone': 10212}, 'time': 25140, 'gate': null, 'effects': <int, num>{37: 38}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{37: 40}},
    ],
    2017: [
      {'lv': 0, 'cost': <String, int>{'wood': 248, 'stone': 303}, 'time': 350, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'wood': 288, 'stone': 352}, 'time': 470, 'gate': null, 'effects': <int, num>{64: 5}},
      {'lv': 2, 'cost': <String, int>{'wood': 337, 'stone': 411}, 'time': 610, 'gate': null, 'effects': <int, num>{64: 5.5}},
      {'lv': 3, 'cost': <String, int>{'wood': 396, 'stone': 483}, 'time': 780, 'gate': null, 'effects': <int, num>{64: 6}},
      {'lv': 4, 'cost': <String, int>{'wood': 468, 'stone': 571}, 'time': 990, 'gate': null, 'effects': <int, num>{64: 6.5}},
      {'lv': 5, 'cost': <String, int>{'wood': 556, 'stone': 680}, 'time': 1250, 'gate': null, 'effects': <int, num>{64: 7}},
      {'lv': 6, 'cost': <String, int>{'wood': 666, 'stone': 814}, 'time': 1570, 'gate': null, 'effects': <int, num>{64: 7.5}},
      {'lv': 7, 'cost': <String, int>{'wood': 803, 'stone': 982}, 'time': 1980, 'gate': null, 'effects': <int, num>{64: 8}},
      {'lv': 8, 'cost': <String, int>{'wood': 976, 'stone': 1193}, 'time': 2490, 'gate': null, 'effects': <int, num>{64: 8.5}},
      {'lv': 9, 'cost': <String, int>{'wood': 1196, 'stone': 1461}, 'time': 3140, 'gate': null, 'effects': <int, num>{64: 9}},
      {'lv': 10, 'cost': <String, int>{'wood': 1477, 'stone': 1805}, 'time': 3970, 'gate': null, 'effects': <int, num>{64: 10}},
      {'lv': 11, 'cost': <String, int>{'wood': 1840, 'stone': 2248}, 'time': 5040, 'gate': null, 'effects': <int, num>{64: 11}},
      {'lv': 12, 'cost': <String, int>{'wood': 2311, 'stone': 2825}, 'time': 6430, 'gate': null, 'effects': <int, num>{64: 12}},
      {'lv': 13, 'cost': <String, int>{'wood': 2929, 'stone': 3580}, 'time': 8250, 'gate': null, 'effects': <int, num>{64: 13}},
      {'lv': 14, 'cost': <String, int>{'wood': 3744, 'stone': 4577}, 'time': 10650, 'gate': null, 'effects': <int, num>{64: 14}},
      {'lv': 15, 'cost': <String, int>{'wood': 4829, 'stone': 5902}, 'time': 13850, 'gate': null, 'effects': <int, num>{64: 15}},
      {'lv': 16, 'cost': <String, int>{'wood': 6282, 'stone': 7678}, 'time': 18130, 'gate': null, 'effects': <int, num>{64: 16}},
      {'lv': 17, 'cost': <String, int>{'wood': 8244, 'stone': 10075}, 'time': 23910, 'gate': null, 'effects': <int, num>{64: 18}},
      {'lv': 18, 'cost': <String, int>{'wood': 10911, 'stone': 13336}, 'time': 31780, 'gate': null, 'effects': <int, num>{64: 20}},
      {'lv': 19, 'cost': <String, int>{'wood': 14566, 'stone': 17802}, 'time': 42560, 'gate': null, 'effects': <int, num>{64: 22}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{64: 24}},
    ],
    3001: [
      {'lv': 0, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'crop': 5280, 'wood': 6160, 'stone': 6160}, 'time': 10000, 'gate': null, 'effects': <int, num>{35: 2}},
      {'lv': 2, 'cost': <String, int>{'crop': 6060, 'wood': 7070, 'stone': 7070}, 'time': 10710, 'gate': null, 'effects': <int, num>{35: 3}},
      {'lv': 3, 'cost': <String, int>{'crop': 6996, 'wood': 8162, 'stone': 8162}, 'time': 11490, 'gate': null, 'effects': <int, num>{35: 4}},
      {'lv': 4, 'cost': <String, int>{'crop': 8129, 'wood': 9483, 'stone': 9483}, 'time': 12350, 'gate': null, 'effects': <int, num>{35: 5}},
      {'lv': 5, 'cost': <String, int>{'crop': 9510, 'wood': 11095, 'stone': 11095}, 'time': 13310, 'gate': null, 'effects': <int, num>{35: 6}},
      {'lv': 6, 'cost': <String, int>{'crop': 11210, 'wood': 13078, 'stone': 13078}, 'time': 14400, 'gate': null, 'effects': <int, num>{35: 7}},
      {'lv': 7, 'cost': <String, int>{'crop': 13317, 'wood': 15537, 'stone': 15537}, 'time': 15640, 'gate': null, 'effects': <int, num>{35: 8}},
      {'lv': 8, 'cost': <String, int>{'crop': 15952, 'wood': 18610, 'stone': 18610}, 'time': 17070, 'gate': null, 'effects': <int, num>{35: 9}},
      {'lv': 9, 'cost': <String, int>{'crop': 19271, 'wood': 22483, 'stone': 22483}, 'time': 18730, 'gate': null, 'effects': <int, num>{35: 10}},
      {'lv': 10, 'cost': <String, int>{'crop': 23486, 'wood': 27400, 'stone': 27400}, 'time': 20670, 'gate': null, 'effects': <int, num>{35: 11}},
      {'lv': 11, 'cost': <String, int>{'crop': 28882, 'wood': 33695, 'stone': 33695}, 'time': 22950, 'gate': null, 'effects': <int, num>{35: 12}},
      {'lv': 12, 'cost': <String, int>{'crop': 35842, 'wood': 41816, 'stone': 41816}, 'time': 25670, 'gate': null, 'effects': <int, num>{35: 13}},
      {'lv': 13, 'cost': <String, int>{'crop': 44890, 'wood': 52372, 'stone': 52372}, 'time': 28930, 'gate': null, 'effects': <int, num>{35: 14}},
      {'lv': 14, 'cost': <String, int>{'crop': 56744, 'wood': 66201, 'stone': 66201}, 'time': 32880, 'gate': null, 'effects': <int, num>{35: 15}},
      {'lv': 15, 'cost': <String, int>{'crop': 72390, 'wood': 84455, 'stone': 84455}, 'time': 37700, 'gate': null, 'effects': <int, num>{35: 16}},
      {'lv': 16, 'cost': <String, int>{'crop': 93200, 'wood': 108733, 'stone': 108733}, 'time': 43620, 'gate': null, 'effects': <int, num>{35: 17}},
      {'lv': 17, 'cost': <String, int>{'crop': 121085, 'wood': 141266, 'stone': 141266}, 'time': 50960, 'gate': null, 'effects': <int, num>{35: 18}},
      {'lv': 18, 'cost': <String, int>{'crop': 158730, 'wood': 185185, 'stone': 185185}, 'time': 60140, 'gate': null, 'effects': <int, num>{35: 19}},
      {'lv': 19, 'cost': <String, int>{'crop': 209927, 'wood': 244915, 'stone': 244915}, 'time': 71710, 'gate': null, 'effects': <int, num>{35: 20}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{35: 20}},
    ],
    3002: [
      {'lv': 0, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'crop': 5280, 'wood': 6160, 'stone': 6160}, 'time': 10000, 'gate': null, 'effects': <int, num>{13: 1}},
      {'lv': 2, 'cost': <String, int>{'crop': 6060, 'wood': 7070, 'stone': 7070}, 'time': 10710, 'gate': null, 'effects': <int, num>{13: 1}},
      {'lv': 3, 'cost': <String, int>{'crop': 6996, 'wood': 8162, 'stone': 8162}, 'time': 11490, 'gate': null, 'effects': <int, num>{13: 2}},
      {'lv': 4, 'cost': <String, int>{'crop': 8129, 'wood': 9483, 'stone': 9483}, 'time': 12350, 'gate': null, 'effects': <int, num>{13: 2}},
      {'lv': 5, 'cost': <String, int>{'crop': 9510, 'wood': 11095, 'stone': 11095}, 'time': 13310, 'gate': null, 'effects': <int, num>{13: 3}},
      {'lv': 6, 'cost': <String, int>{'crop': 11210, 'wood': 13078, 'stone': 13078}, 'time': 14400, 'gate': null, 'effects': <int, num>{13: 3}},
      {'lv': 7, 'cost': <String, int>{'crop': 13317, 'wood': 15537, 'stone': 15537}, 'time': 15640, 'gate': null, 'effects': <int, num>{13: 4}},
      {'lv': 8, 'cost': <String, int>{'crop': 15952, 'wood': 18610, 'stone': 18610}, 'time': 17070, 'gate': null, 'effects': <int, num>{13: 4}},
      {'lv': 9, 'cost': <String, int>{'crop': 19271, 'wood': 22483, 'stone': 22483}, 'time': 18730, 'gate': null, 'effects': <int, num>{13: 5}},
      {'lv': 10, 'cost': <String, int>{'crop': 23486, 'wood': 27400, 'stone': 27400}, 'time': 20670, 'gate': null, 'effects': <int, num>{13: 5}},
      {'lv': 11, 'cost': <String, int>{'crop': 28882, 'wood': 33695, 'stone': 33695}, 'time': 22950, 'gate': null, 'effects': <int, num>{13: 6}},
      {'lv': 12, 'cost': <String, int>{'crop': 35842, 'wood': 41816, 'stone': 41816}, 'time': 25670, 'gate': null, 'effects': <int, num>{13: 6}},
      {'lv': 13, 'cost': <String, int>{'crop': 44890, 'wood': 52372, 'stone': 52372}, 'time': 28930, 'gate': null, 'effects': <int, num>{13: 7}},
      {'lv': 14, 'cost': <String, int>{'crop': 56744, 'wood': 66201, 'stone': 66201}, 'time': 32880, 'gate': null, 'effects': <int, num>{13: 7}},
      {'lv': 15, 'cost': <String, int>{'crop': 72390, 'wood': 84455, 'stone': 84455}, 'time': 37700, 'gate': null, 'effects': <int, num>{13: 8}},
      {'lv': 16, 'cost': <String, int>{'crop': 93200, 'wood': 108733, 'stone': 108733}, 'time': 43620, 'gate': null, 'effects': <int, num>{13: 8}},
      {'lv': 17, 'cost': <String, int>{'crop': 121085, 'wood': 141266, 'stone': 141266}, 'time': 50960, 'gate': null, 'effects': <int, num>{13: 9}},
      {'lv': 18, 'cost': <String, int>{'crop': 158730, 'wood': 185185, 'stone': 185185}, 'time': 60140, 'gate': null, 'effects': <int, num>{13: 9}},
      {'lv': 19, 'cost': <String, int>{'crop': 209927, 'wood': 244915, 'stone': 244915}, 'time': 71710, 'gate': null, 'effects': <int, num>{13: 10}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{13: 10}},
    ],
    3003: [
      {'lv': 0, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'crop': 5280, 'wood': 6160, 'stone': 6160}, 'time': 10000, 'gate': null, 'effects': <int, num>{14: 1}},
      {'lv': 2, 'cost': <String, int>{'crop': 6060, 'wood': 7070, 'stone': 7070}, 'time': 10710, 'gate': null, 'effects': <int, num>{14: 1}},
      {'lv': 3, 'cost': <String, int>{'crop': 6996, 'wood': 8162, 'stone': 8162}, 'time': 11490, 'gate': null, 'effects': <int, num>{14: 2}},
      {'lv': 4, 'cost': <String, int>{'crop': 8129, 'wood': 9483, 'stone': 9483}, 'time': 12350, 'gate': null, 'effects': <int, num>{14: 2}},
      {'lv': 5, 'cost': <String, int>{'crop': 9510, 'wood': 11095, 'stone': 11095}, 'time': 13310, 'gate': null, 'effects': <int, num>{14: 3}},
      {'lv': 6, 'cost': <String, int>{'crop': 11210, 'wood': 13078, 'stone': 13078}, 'time': 14400, 'gate': null, 'effects': <int, num>{14: 3}},
      {'lv': 7, 'cost': <String, int>{'crop': 13317, 'wood': 15537, 'stone': 15537}, 'time': 15640, 'gate': null, 'effects': <int, num>{14: 4}},
      {'lv': 8, 'cost': <String, int>{'crop': 15952, 'wood': 18610, 'stone': 18610}, 'time': 17070, 'gate': null, 'effects': <int, num>{14: 4}},
      {'lv': 9, 'cost': <String, int>{'crop': 19271, 'wood': 22483, 'stone': 22483}, 'time': 18730, 'gate': null, 'effects': <int, num>{14: 5}},
      {'lv': 10, 'cost': <String, int>{'crop': 23486, 'wood': 27400, 'stone': 27400}, 'time': 20670, 'gate': null, 'effects': <int, num>{14: 5}},
      {'lv': 11, 'cost': <String, int>{'crop': 28882, 'wood': 33695, 'stone': 33695}, 'time': 22950, 'gate': null, 'effects': <int, num>{14: 6}},
      {'lv': 12, 'cost': <String, int>{'crop': 35842, 'wood': 41816, 'stone': 41816}, 'time': 25670, 'gate': null, 'effects': <int, num>{14: 6}},
      {'lv': 13, 'cost': <String, int>{'crop': 44890, 'wood': 52372, 'stone': 52372}, 'time': 28930, 'gate': null, 'effects': <int, num>{14: 7}},
      {'lv': 14, 'cost': <String, int>{'crop': 56744, 'wood': 66201, 'stone': 66201}, 'time': 32880, 'gate': null, 'effects': <int, num>{14: 7}},
      {'lv': 15, 'cost': <String, int>{'crop': 72390, 'wood': 84455, 'stone': 84455}, 'time': 37700, 'gate': null, 'effects': <int, num>{14: 8}},
      {'lv': 16, 'cost': <String, int>{'crop': 93200, 'wood': 108733, 'stone': 108733}, 'time': 43620, 'gate': null, 'effects': <int, num>{14: 8}},
      {'lv': 17, 'cost': <String, int>{'crop': 121085, 'wood': 141266, 'stone': 141266}, 'time': 50960, 'gate': null, 'effects': <int, num>{14: 9}},
      {'lv': 18, 'cost': <String, int>{'crop': 158730, 'wood': 185185, 'stone': 185185}, 'time': 60140, 'gate': null, 'effects': <int, num>{14: 9}},
      {'lv': 19, 'cost': <String, int>{'crop': 209927, 'wood': 244915, 'stone': 244915}, 'time': 71710, 'gate': null, 'effects': <int, num>{14: 10}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{14: 10}},
    ],
    3004: [
      {'lv': 0, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{}},
      {'lv': 1, 'cost': <String, int>{'crop': 5280, 'wood': 6160, 'stone': 6160}, 'time': 10000, 'gate': null, 'effects': <int, num>{36: 1}},
      {'lv': 2, 'cost': <String, int>{'crop': 6060, 'wood': 7070, 'stone': 7070}, 'time': 10710, 'gate': null, 'effects': <int, num>{36: 1}},
      {'lv': 3, 'cost': <String, int>{'crop': 6996, 'wood': 8162, 'stone': 8162}, 'time': 11490, 'gate': null, 'effects': <int, num>{36: 2}},
      {'lv': 4, 'cost': <String, int>{'crop': 8129, 'wood': 9483, 'stone': 9483}, 'time': 12350, 'gate': null, 'effects': <int, num>{36: 2}},
      {'lv': 5, 'cost': <String, int>{'crop': 9510, 'wood': 11095, 'stone': 11095}, 'time': 13310, 'gate': null, 'effects': <int, num>{36: 3}},
      {'lv': 6, 'cost': <String, int>{'crop': 11210, 'wood': 13078, 'stone': 13078}, 'time': 14400, 'gate': null, 'effects': <int, num>{36: 3}},
      {'lv': 7, 'cost': <String, int>{'crop': 13317, 'wood': 15537, 'stone': 15537}, 'time': 15640, 'gate': null, 'effects': <int, num>{36: 4}},
      {'lv': 8, 'cost': <String, int>{'crop': 15952, 'wood': 18610, 'stone': 18610}, 'time': 17070, 'gate': null, 'effects': <int, num>{36: 4}},
      {'lv': 9, 'cost': <String, int>{'crop': 19271, 'wood': 22483, 'stone': 22483}, 'time': 18730, 'gate': null, 'effects': <int, num>{36: 5}},
      {'lv': 10, 'cost': <String, int>{'crop': 23486, 'wood': 27400, 'stone': 27400}, 'time': 20670, 'gate': null, 'effects': <int, num>{36: 5}},
      {'lv': 11, 'cost': <String, int>{'crop': 28882, 'wood': 33695, 'stone': 33695}, 'time': 22950, 'gate': null, 'effects': <int, num>{36: 6}},
      {'lv': 12, 'cost': <String, int>{'crop': 35842, 'wood': 41816, 'stone': 41816}, 'time': 25670, 'gate': null, 'effects': <int, num>{36: 6}},
      {'lv': 13, 'cost': <String, int>{'crop': 44890, 'wood': 52372, 'stone': 52372}, 'time': 28930, 'gate': null, 'effects': <int, num>{36: 7}},
      {'lv': 14, 'cost': <String, int>{'crop': 56744, 'wood': 66201, 'stone': 66201}, 'time': 32880, 'gate': null, 'effects': <int, num>{36: 7}},
      {'lv': 15, 'cost': <String, int>{'crop': 72390, 'wood': 84455, 'stone': 84455}, 'time': 37700, 'gate': null, 'effects': <int, num>{36: 8}},
      {'lv': 16, 'cost': <String, int>{'crop': 93200, 'wood': 108733, 'stone': 108733}, 'time': 43620, 'gate': null, 'effects': <int, num>{36: 8}},
      {'lv': 17, 'cost': <String, int>{'crop': 121085, 'wood': 141266, 'stone': 141266}, 'time': 50960, 'gate': null, 'effects': <int, num>{36: 9}},
      {'lv': 18, 'cost': <String, int>{'crop': 158730, 'wood': 185185, 'stone': 185185}, 'time': 60140, 'gate': null, 'effects': <int, num>{36: 9}},
      {'lv': 19, 'cost': <String, int>{'crop': 209927, 'wood': 244915, 'stone': 244915}, 'time': 71710, 'gate': null, 'effects': <int, num>{36: 10}},
      {'lv': 20, 'cost': <String, int>{}, 'time': 0, 'gate': null, 'effects': <int, num>{36: 10}},
    ],
  };


  // ===== POLICIES (policy.json + policyText.json) =====
  // id, type, values = 3 tiers from `value`, weight = draw weight,
  // useCond = building gate tokens `4,<buildBaseId>,<lv>` joined by `|`.
  static const List<Map<String, dynamic>> POLICIES = [
    {'id': 1001, 'type': 12, 'values': [100, 150, 200], 'weight': 100, 'useCond': '',
     'name': 'Panen Melimpah', 'desc': 'Produksi dasar +{0} per jam'},
    {'id': 1002, 'type': 2, 'values': [20, 40, 60], 'weight': 100, 'useCond': '',
     'name': 'Revolusi Industri', 'desc': 'Waktu perbaikan bangunan -{0}%'},
    {'id': 1003, 'type': 5, 'values': [10, 20, 30], 'weight': 100, 'useCond': '',
     'name': 'Pola Pikir Prajurit', 'desc': 'Waktu rekrut prajurit -{0}%'},
    {'id': 1004, 'type': 1, 'values': [1, 2, 3], 'weight': 0, 'useCond': '',
     'name': 'Berbaris Bersama', 'desc': 'Antrian perbaikan bangunan +{0}'},
    {'id': 1005, 'type': 13, 'values': [10, 20, 30], 'weight': 100, 'useCond': '',
     'name': 'Berbaris Cepat', 'desc': 'Waktu berbaris pasukan -{0}%'},
    {'id': 1006, 'type': 14, 'values': [30, 45, 60], 'weight': 100, 'useCond': '4,2011,1',
     'name': 'Kegigihan', 'desc': 'Waktu latihan prajurit -{0}%'},
    {'id': 1007, 'type': 15, 'values': [500, 1000, 1500], 'weight': 100, 'useCond': '4,2002,1|4,2003,1',
     'name': 'Kehebatan Tersembunyi', 'desc': 'Kapasitas Lumbung dan Gudang +{0} per level'},
    {'id': 1008, 'type': 16, 'values': [20, 30, 40], 'weight': 80, 'useCond': '',
     'name': 'Akuisisi Talenta', 'desc': '{0}% peluang untuk merekrut prajurit Lv.2'},
    {'id': 1009, 'type': 8, 'values': [3, 6, 9], 'weight': 100, 'useCond': '',
     'name': 'Rekrut Tanpa Hambatan', 'desc': 'Antrian Rekrut Barak +{0}'},
    {'id': 1010, 'type': 17, 'values': [20, 40, 60], 'weight': 100, 'useCond': '',
     'name': 'Perdagangan & Industri', 'desc': 'Kapasitas pengiriman setiap Pedagang +1000, waktu pengiriman -{0}%'},
    {'id': 1011, 'type': 11, 'values': [1, 2, 3], 'weight': 50, 'useCond': '',
     'name': 'Protokol Ekspansi', 'desc': 'Kapasitas pasukan +{0}'},
    {'id': 1012, 'type': 18, 'values': [4, 5, 6], 'weight': 80, 'useCond': '',
     'name': 'Bantuan Darurat', 'desc': 'SPD berbaris *{0} antara Kota Utama dan Benteng'},
    {'id': 1013, 'type': 19, 'values': [40, 60, 80], 'weight': 100, 'useCond': '',
     'name': 'Kemenangan Mendekat', 'desc': 'Waktu konstruksi dan pembongkaran semua bangunan darat -{0}%'},
    {'id': 1014, 'type': 20, 'values': [20, 40, 60], 'weight': 60, 'useCond': '',
     'name': 'Hadiah Super', 'desc': 'Hadiah Sumber Daya Dasar diperoleh melalui Peti +{0}%'},
    {'id': 1015, 'type': 21, 'values': [20, 30, 40], 'weight': 60, 'useCond': '4,2008,1',
     'name': 'Dihidupkan Kembali', 'desc': 'Ada {0}% peluang untuk recast gratis 1 kali saat recast equipment'},
    {'id': 1016, 'type': 22, 'values': [2, 4, 8], 'weight': 100, 'useCond': '',
     'name': 'Makan Bunga', 'desc': 'Buku EXP dan Besi meningkat {0}% per hari'},
    {'id': 1017, 'type': 23, 'values': [5, 10, 15], 'weight': 100, 'useCond': '',
     'name': 'Banyak Buku dan Besi', 'desc': 'Jika Buku EXP atau Besi saat ini melebihi 100, maka meningkat {0}% per hari'},
    {'id': 1018, 'type': 24, 'values': [3, 6, 9], 'weight': 100, 'useCond': '4,2011,1',
     'name': 'Banyak Talenta', 'desc': 'Antrian latihan Lapangan Latihan +{0}'},
    {'id': 1019, 'type': 25, 'values': [3, 6, 9], 'weight': 60, 'useCond': '',
     'name': 'Jantung Perlindungan', 'desc': 'Level menara penjaga +{0}'},
    {'id': 1020, 'type': 26, 'values': [10, 20, 30], 'weight': 80, 'useCond': '',
     'name': 'Mogul Pertanian', 'desc': 'Pertanian memiliki {0}% peluang untuk menghasilkan Buku EXP atau besi setiap jam'},
    {'id': 1021, 'type': 27, 'values': [10, 20, 30], 'weight': 80, 'useCond': '',
     'name': 'Mogul Tambang', 'desc': 'Tambang memiliki {0}% peluang untuk menghasilkan Besi setiap jam'},
    {'id': 1022, 'type': 28, 'values': [10, 20, 30], 'weight': 80, 'useCond': '',
     'name': 'Mogul Penggergajian', 'desc': 'Penggergajian memiliki {0}% peluang untuk menghasilkan Buku EXP setiap jam'},
    {'id': 1023, 'type': 29, 'values': [3, 6, 9], 'weight': 100, 'useCond': '4,2016,1',
     'name': 'Lalu Lintas Ramai', 'desc': 'Antrian Heal Pusat Medis +{0}'},
    {'id': 1024, 'type': 31, 'values': [2, 3, 4], 'weight': 100, 'useCond': '',
     'name': 'Arsitektur Indah', 'desc': 'Batas atas semua bangunan darat +{0}'},
    {'id': 1025, 'type': 30, 'values': [30, 45, 60], 'weight': 100, 'useCond': '',
     'name': 'Tawaran Fantastis', 'desc': 'Jumlah Pertukaran Alam per hari +1, dan biaya penanganan -{0}%'},
    {'id': 1026, 'type': 38, 'values': [15, 20, 30], 'weight': 60, 'useCond': '',
     'name': 'Aura Penjaga', 'desc': 'Saat battle di teritori sendiri, HP Maks prajurit +{0}%'},
    {'id': 1027, 'type': 39, 'values': [10, 15, 20], 'weight': 60, 'useCond': '',
     'name': 'Tanduk Attack', 'desc': 'Saat battle di teritori musuh, ATK prajurit +{0}%'},
    {'id': 1028, 'type': 40, 'values': [10, 20, 30], 'weight': 60, 'useCond': '',
     'name': 'Spesialisasi Armor', 'desc': 'HP Maks semua prajurit +{0} per level'},
    {'id': 1029, 'type': 41, 'values': [1, 2, 3], 'weight': 60, 'useCond': '',
     'name': 'Spesialisasi Senjata', 'desc': 'ATK semua prajurit +{0} per level'},
    {'id': 1030, 'type': 42, 'values': [10, 15, 20], 'weight': 50, 'useCond': '',
     'name': 'Kekuatan Tingkat 1', 'desc': 'HP Maks dan ATK semua prajurit Lv.1 +{0}%'},
    {'id': 1031, 'type': 43, 'values': [10, 20, 30], 'weight': 80, 'useCond': '',
     'name': 'Untung Tanpa Usaha', 'desc': 'Saat 10 pemain kalah dalam pertempuran, bisa mendapatkan {0} Gulungan atau Fiksator'},
    {'id': 1032, 'type': 44, 'values': [60, 80, 100], 'weight': 100, 'useCond': '',
     'name': 'Rampas Paksa', 'desc': 'Dapatkan {0}% sumber daya yang tersisa saat menaklukkan satu pemain'},
    {'id': 1033, 'type': 45, 'values': [20, 40, 60], 'weight': 100, 'useCond': '',
     'name': 'Cuaca Baik', 'desc': 'Waktu Farming -{0}%'},
    {'id': 1034, 'type': 46, 'values': [1, 2, 3], 'weight': 80, 'useCond': '',
     'name': 'Berkah Hujan', 'desc': 'Peti yang diperoleh dari Farming +{0}'},
    {'id': 1035, 'type': 37, 'values': [10, 20, 30], 'weight': 100, 'useCond': '4,2016,1',
     'name': 'Tangan Ahli', 'desc': 'Waktu heal pasukan terluka -{0}%'},
    {'id': 1036, 'type': 47, 'values': [3, 6, 9], 'weight': 50, 'useCond': '4,2016,1',
     'name': 'Obati Dunia', 'desc': 'Mendapatkan {0} kali heal prajurit gratis'},
    {'id': 1037, 'type': 48, 'values': [3, 6, 9], 'weight': 80, 'useCond': '4,2008,1',
     'name': 'Tempa Berkali-kali', 'desc': 'Mendapatkan {0} kali membuat atau recast equipment gratis'},
    {'id': 1038, 'type': 49, 'values': [10, 20, 30], 'weight': 80, 'useCond': '',
     'name': 'Rekrut Pasukan', 'desc': 'Mendapatkan {0} kali perekrutan prajurit gratis'},
    {'id': 1039, 'type': 50, 'values': [10, 20, 30], 'weight': 80, 'useCond': '',
     'name': 'Para Bijak Berkumpul', 'desc': 'Mendapatkan {0} kali pelatihan prajurit gratis'},
    {'id': 1040, 'type': 51, 'values': [3, 6, 9], 'weight': 100, 'useCond': '',
     'name': 'Keuntungan Besar', 'desc': 'Langsung mendapatkan 3 gulungan, dan mendapatkan {0} gulungan di awal setiap musim'},
    {'id': 1041, 'type': 52, 'values': [3, 6, 9], 'weight': 100, 'useCond': '',
     'name': 'Landasan Kokoh', 'desc': 'Langsung mendapatkan 3 Fiksator, dan mendapatkan {0} Fiksator di awal setiap musim'},
    {'id': 1042, 'type': 53, 'values': [20, 30, 50], 'weight': 60, 'useCond': '',
     'name': 'Pembasmi Beast', 'desc': 'DMG semua prajurit terhadap monster liar meningkat {0}%'},
    {'id': 1043, 'type': 54, 'values': [30, 40, 50], 'weight': 50, 'useCond': '',
     'name': 'Ahli Penakluk Tantangan', 'desc': 'Semua prajurit memiliki {0}% peluang untuk membuat DMG terhadap bangunan +1'},
    {'id': 1044, 'type': 55, 'values': [1, 2, 3], 'weight': 80, 'useCond': '',
     'name': 'Hidup Abadi', 'desc': 'Semua prajurit memulihkan ({0}*level sendiri) HP di setiap ronde'},
    {'id': 1045, 'type': 56, 'values': [10, 15, 20], 'weight': 50, 'useCond': '',
     'name': 'Yang Kuat Menjadi Raja', 'desc': 'DMG yang diberikan Prajurit Level Maksimal +{0}%, DMG yang diterima -{0}%'},
    {'id': 1046, 'type': 32, 'values': [10, 15, 20], 'weight': 50, 'useCond': '',
     'name': 'Spectral Decay', 'desc': 'Saat semua prajurit menyerang musuh dengan level lebih rendah, DMG meningkat ({0} × selisih level)%'},
    {'id': 1047, 'type': 57, 'values': [1, 2, 3], 'weight': 80, 'useCond': '',
     'name': 'Serbu Kota, Rebut Tanah', 'desc': 'Langsung buka Katapel Tempur, DMG yang diberikan Katapel Tempur pada bangunan +{0}'},
    {'id': 1048, 'type': 58, 'values': [4, 8, 12], 'weight': 50, 'useCond': '',
     'name': 'Formasi Benteng Tajam', 'desc': 'Saat tembok kota, benteng, dan menara penjaga terus menyerang target yang sama, setiap DMG +{0}%, dapat distack hingga 20x'},
    {'id': 1049, 'type': 59, 'values': [10, 20, 30], 'weight': 50, 'useCond': '',
     'name': 'Spesialisasi Prajurit Tombak', 'desc': 'Semua Prajurit Tombak Leech+{0}%'},
    {'id': 1050, 'type': 60, 'values': [15, 25, 35], 'weight': 60, 'useCond': '',
     'name': 'Spesialisasi Prajurit Perisai', 'desc': 'DMG yang diterima semua Prajurit Perisai -{0}%'},
    {'id': 1051, 'type': 61, 'values': [10, 15, 20], 'weight': 50, 'useCond': '',
     'name': 'Spesialisasi Pemanah', 'desc': 'DMG yang ditimbulkan semua Pemanah +{0}%'},
    {'id': 1052, 'type': 62, 'values': [8, 12, 16], 'weight': 50, 'useCond': '',
     'name': 'Spesialisasi Kavaleri', 'desc': 'HP Maks dan ATK semua Kavaleri +{0}%'},
  ];

  /// Capital levels that open a new policy slot (5 total, per CLAUDE.md:
  /// 3 active at Capital Lv.10, "New Policy unlocks at Lv.15").
  static const List<int> POLICY_SLOT_LEVELS = [1, 5, 10, 15, 20];

  /// Union policy slots open at total union embassy level 1 / 200 / 400.
  static const List<int> UNION_POLICY_LEVELS = [1, 200, 400];

  /// Number of policy slots available at [capitalLevel].
  static int policySlotsAt(int capitalLevel) =>
      POLICY_SLOT_LEVELS.where((l) => l <= capitalLevel).length;

  static Map<String, dynamic>? policyById(int id) {
    for (final p in POLICIES) {
      if (p['id'] == id) return p;
    }
    return null;
  }

  /// Policy description with the tier's value substituted for `{0}`.
  static String policyDesc(Map<String, dynamic> policy, int tier) {
    final values = (policy['values'] as List).cast<int>();
    final v = values[tier.clamp(0, values.length - 1)];
    return (policy['desc'] as String).replaceAll('{0}', '$v');
  }

  /// Expertise text with `{0}`/`{1}` filled from `value`/`params` + suffixes.
  static String strategyDesc(int id, {bool idl = false, String? pawnId}) {
    final row = STRATEGIES[id];
    if (row == null) return 'Unknown expertise';
    final text = ((idl ? row['descId'] : row['desc']) as String?) ?? '';
    final v = '${row['value']}${row['vSuffix']}';
    final rawParams = (row['params'] as String?) ?? '';
    final p = '$rawParams${row['pSuffix']}';
    // Placeholder shapes in strategyText.json:
    //  - params present:      {0} = value, {1} = params
    //  - params empty, {0}{1}: {0} = target label, {1} = value
    //  - params empty, {0}   : {0} = value (target is named inline)
    if (rawParams.isEmpty && text.contains('{0}') && text.contains('{1}')) {
      return text
          .replaceAll('{0}', _strategyTargetLabel(row, pawnId: pawnId))
          .replaceAll('{1}', v);
    }
    return text.replaceAll('{0}', v).replaceAll('{1}', p);
  }

  /// `target_id` = `"<kind>,<sub>"`: 10 possessed troop, 1 pawn id, 2 troop
  /// type, 4 hero, 0 all allies. Rendered as the wording the original uses.
  static String _strategyTargetLabel(Map<String, dynamic> row, {String? pawnId}) {
    final target = (row['target'] as String?) ?? '0,0';
    final parts = target.split(',');
    final kind = parts.isNotEmpty ? parts[0] : '0';
    final sub = parts.length > 1 ? parts[1] : '0';
    switch (kind) {
      case '1':
        return _pawnName(sub);
      case '2':
        const byType = {
          '1': 'Spearman',
          '2': 'Shieldman',
          '3': 'Bowman',
          '4': 'Cavalry',
        };
        return byType[sub] ?? 'troops';
      case '4':
        return 'Hero';
      case '10':
        return pawnId == null ? 'Possessed troop' : _pawnName(pawnId);
      default:
        return 'All allies';
    }
  }

  static String _pawnName(String pawnId) {
    final pawn = SOLDIER_COMBAT.firstWhere(
      (p) => p['id'] == pawnId,
      orElse: () => const {},
    );
    return (pawn['name'] as String?) ?? 'soldier';
  }

  static int policyValue(Map<String, dynamic> policy, int tier) {
    final values = (policy['values'] as List).cast<int>();
    return values[tier.clamp(0, values.length - 1)];
  }

  /// `use_cond` tokens are `4,<buildBaseId>,<lv>` joined by `|` — every token
  /// must be met. Empty cond = always available.
  static bool policyGateMet(
      Map<String, dynamic> policy, Map<String, int> capitalBuildings) {
    final cond = policy['useCond'] as String? ?? '';
    if (cond.isEmpty) return true;
    final baseToId = {
      for (final e in BUILD_BASE_IDS.entries) e.value: e.key,
    };
    for (final token in cond.split('|')) {
      final bits = token.split(',');
      if (bits.length < 3) continue;
      final buildingId = baseToId[int.tryParse(bits[1])];
      if (buildingId == null) continue;
      final needLv = int.tryParse(bits[2]) ?? 1;
      if ((capitalBuildings[buildingId] ?? 0) < needLv) return false;
    }
    return true;
  }

  /// Research Institute (ceri.json) rows that unlock a policy (type 1).
  /// Map policyId -> {needLv, weight, cost, time}.
  static const Map<int, Map<String, dynamic>> POLICY_RESEARCH = {
    1004: {'needLv': 2, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1005: {'needLv': 2, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1006: {'needLv': 2, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1007: {'needLv': 2, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1008: {'needLv': 11, 'weight': 80, 'cost': {'crop': 70, 'wood': 50, 'stone': 50}, 'time': 400},
    1009: {'needLv': 5, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1010: {'needLv': 5, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1011: {'needLv': 18, 'weight': 70, 'cost': {'crop': 80, 'wood': 60, 'stone': 60}, 'time': 450},
    1012: {'needLv': 11, 'weight': 90, 'cost': {'crop': 60, 'wood': 40, 'stone': 40}, 'time': 350},
    1013: {'needLv': 2, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1014: {'needLv': 2, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1015: {'needLv': 8, 'weight': 60, 'cost': {'crop': 90, 'wood': 70, 'stone': 70}, 'time': 500},
    1016: {'needLv': 14, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1017: {'needLv': 14, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1018: {'needLv': 14, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1019: {'needLv': 5, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1020: {'needLv': 11, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1021: {'needLv': 11, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1022: {'needLv': 11, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1024: {'needLv': 5, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
    1025: {'needLv': 5, 'weight': 100, 'cost': {'crop': 50, 'wood': 30, 'stone': 30}, 'time': 300},
  };
}
