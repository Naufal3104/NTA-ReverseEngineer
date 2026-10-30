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
      'icon': '??',
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
      'icon': '???',
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
      'icon': '??',
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
      'icon': '???',
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
      'icon': '??',
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
      'icon': '??',
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
      'icon': '??',
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
      'icon': '??',
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
      'icon': '??',
      'r': 9,
      'c': 9,
      'w': 1,
      'h': 1,
    },
  ];

  // Per-level extrapolation (Lv.1-20) from OCR deltas. One transition per
  // building observed; linear extrapolation with caps. 'cost' = base upgrade
  // cost at Lv.1 (x next level on upgrade); 'time' = upgrade seconds at Lv.1.
  static Map<String, dynamic> levelStats(String id, int level) {
    final l = level.clamp(1, 20);
    switch (id) {
      case 'palace':
        return {
          'armyCap': 1 + ((l - 1) ~/ 2).clamp(0, 9) + (l >= 10 ? 5 : 0),
          'armyCapacity': 9,
          'territory': 11 + l * 4,
          'cost': {'wood': 118, 'stone': 118},
          'time': 2620,
          'note': l >= 15 ? 'Policy slot unlocked' : 'New policy at Lv.15',
        };
      case 'barracks':
        return {
          'recruitSpd': 6 + (l - 1) * 2,
          'soldierCap': l >= 12 ? 4 : 3,
          'cost': {'wood': 99, 'stone': 81},
          'time': 1460,
          'note': l >= 12 ? 'New soldier unlocked' : 'New soldier at Lv.12',
        };
      case 'smithy':
        return {
          'craftSpd': (l - 1) * 3,
          'cost': {'wood': 75, 'stone': 92},
          'time': 1370,
          'note': l >= 10 ? 'Exclusive + Smelt unlocked' : 'Exclusive at Lv.10',
        };
      case 'hall_of_heroes':
        return {
          'portraits': 1 + ((l - 1) ~/ 9),
          'cost': {'wood': 92, 'crop': 113},
          'time': 450,
        };
      case 'frontier_garrison':
        return {
          'durability': 35 + l * 5,
          'atk': 10 + l * 2,
          'cost': {'wood': 113, 'crop': 92},
          'time': 430,
        };
      case 'drill_ground':
        return {
          'marchSpd': (l - 1) * 3,
          'cost': {'wood': 99, 'stone': 81},
          'time': 420,
        };
      case 'clinic':
        return {
          'healSpd': (l - 1) * 4,
          'minorChance': l == 1 ? 0 : 30,
          'severeChance': l == 1 ? 40 : 50,
          'queue': 6,
          'cost': {'wood': 94, 'crop': 77},
          'time': 85,
        };
      case 'market':
      case 'union_market':
        return {
          'merchants': l,
          'cost': {'wood': 102, 'stone': 83},
          'time': 430,
        };
      case 'embassy':
        return {
          'cost': {'wood': 92, 'stone': 92},
          'time': 300,
          'note': l >= 3 ? 'Can create union' : 'Create union at Lv.3',
        };
      case 'barn':
        return {
          'cropCap': 4000 + l * 1700,
          'cost': {'wood': 109, 'stone': 90},
          'time': 300,
        };
      case 'warehouse':
        return {
          'woodCap': 4000 + l * 1700,
          'stoneCap': 4000 + l * 1700,
          'cost': {'wood': 90, 'stone': 109},
          'time': 340,
        };
      default:
        return {};
    }
  }

  // Upgrade cost curve (wood + stone only). Anchors: normal 64 -> 10.000
  // (Lv.1->2 ... Lv.19->20), palace 144 -> 14.000. Exponential.
  static Map<String, int> upgradeCost(String id, int nextLevel) {
    final l = nextLevel.clamp(1, 20);
    final isPalace = id == 'palace';
    const normalR = 1.3239;
    const palaceR = 1.2896;
    final base = isPalace ? 144.0 : 64.0;
    final r = isPalace ? palaceR : normalR;
    final v = (base * math.pow(r, (l - 2).clamp(0, 18))).round();
    return {'wood': v, 'stone': v};
  }

  // Backwards compatibility alias
  static const List<Map<String, dynamic>> BUILDINGS = CAPITAL_BUILDINGS;

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
      'icon': '??',
    },
    {
      'id': 'sawmill',
      'name': 'Sawmill',
      'resource': 'wood',
      'cost': {'wood': 100, 'stone': 40},
      'production': {'wood': 45},
      'hp': 600,
      'desc': 'Processes timber (+45 Wood/hr per lvl). Built on Wood plots.',
      'icon': '??',
    },
    {
      'id': 'quarry',
      'name': 'Quarry',
      'resource': 'stone',
      'cost': {'wood': 110, 'stone': 50},
      'production': {'stone': 35},
      'hp': 700,
      'desc': 'Excavates masonry stone (+35 Stone/hr per lvl). Built on Stone plots.',
      'icon': '??',
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
      'rage': '4/6', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 45,
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
      'rage': '4/8', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 50,
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
      'rage': '5/8', 'range': 2, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 46,
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
      'rage': '0/0', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 52,
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
      'rage': '6/10', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 47,
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
      'rage': '5/8', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 50,
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
      'rage': '12/15', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 60,
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
      'rage': '10/16', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 72,
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
      'rage': '5/10', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 63,
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
      'rage': '10/15', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 65,
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
      'rage': '8/15', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 124,
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
      'rage': '4/6', 'range': 1, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 67,
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
      'rage': '6/8', 'range': 4, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 82,
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
      'rage': '2/4', 'range': 3, 'move': 3, 'upkeep': 3, 'march': 62, 'coef': 81,
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
      'rage': '4/6', 'range': 4, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 82,
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
      'rage': '12/12', 'range': 4, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 84,
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
      'hp': 55, 'atk': 26, 'def': 6, 'speed': 2,
      'rage': '0/0', 'range': 5, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 86,
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
      'rage': '8/10', 'range': 4, 'move': 2, 'upkeep': 3, 'march': 62, 'coef': 87,
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
      'rage': '4/10', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 82,
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
      'rage': '6/10', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 84,
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
      'rage': '2/4', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 92,
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
      'rage': '4/12', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 107,
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
      'rage': '2/6', 'range': 4, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 84,
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
      'rage': '0/0', 'range': 1, 'move': 4, 'upkeep': 4, 'march': 74, 'coef': 88,
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
      'rage': '0/0', 'range': 5, 'move': 1, 'upkeep': 5, 'march': 46, 'coef': 60,
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
      'rage': '0/0', 'range': 5, 'move': 1, 'upkeep': 5, 'march': 46, 'coef': 60,
      'skill': 'Penetration (Passive)',
      'skillDesc': 'Bonus DMG = 1% target Max HP (3.5% at Smithy 14). Cannot be upgraded.',
      'desc': 'Siege engine. Bonus vs Buildings.',
    },
  ];

  // Equipment forged in Smithy. Tiers mirror the original unlock ladder:
  // Lv.1 / Lv.3 / Lv.5 / Lv.7 / Lv.12 / Lv.14 (common), Lv.10 (exclusive).
  // 'tier' = minimum Smithy level. 'roll' = rolled stat range on the card.
  // Costs are demo-tiered (doc lists effects/rolls, not forge prices).
  static const List<Map<String, dynamic>> EQUIPMENT = [
    // --- Lv.1 (6) ---
    {'id': 'cureblade', 'name': 'Cureblade', 'tier': 1, 'roll': '[1-5]', 'cost': {'crop': 30, 'wood': 40}, 'effect': 'Restores [4-10] HP on effective DMG, 40% chance to heal lowest-HP ally within 5 tiles. Halved beyond Range 2. Cannot heal weaponry.'},
    {'id': 'crit_blade', 'name': 'Crit Blade', 'tier': 1, 'roll': '[2-10]', 'cost': {'crop': 30, 'wood': 40}, 'effect': '[20-40]% chance to deal [150-180]% Crit DMG.'},
    {'id': 'meteor_hammer', 'name': 'Meteor Hammer', 'tier': 1, 'roll': '[2-10]', 'cost': {'crop': 30, 'wood': 40}, 'effect': 'ATK Range +1. Ignores [30-70]% Dodge.'},
    {'id': 'dual_axe', 'name': 'Dual Axe', 'tier': 1, 'roll': '[2-10]', 'cost': {'crop': 30, 'wood': 40}, 'effect': 'Each attack +1 Rage. [20-50]% chance +50% Rage after skills.'},
    {'id': 'crescent_blade', 'name': 'Crescent Blade', 'tier': 1, 'roll': '[2-8]', 'cost': {'crop': 30, 'wood': 40}, 'effect': 'DMG dealt +[20-50]%, DMG taken +100%, ignores 20% DMG Reduction.'},
    {'id': 'longyuan_sword', 'name': 'Longyuan Sword', 'tier': 1, 'roll': '[2-8]', 'cost': {'crop': 30, 'wood': 40}, 'effect': 'ATK +[10-20]%. 30% chance +1% ATK after first attack each round, stackable.'},
    // --- Lv.3 (6) ---
    {'id': 'chainmail', 'name': 'Chainmail', 'tier': 3, 'roll': '[20-70]', 'cost': {'crop': 20, 'wood': 60, 'stone': 40}, 'effect': 'DMG taken -5. Per effective hit taken, [5-20]% chance -1 DMG. +1 chance per 50 Max HP.'},
    {'id': 'wine_gourd', 'name': 'Wine Gourd', 'tier': 3, 'roll': '[20-50]', 'cost': {'crop': 20, 'wood': 60, 'stone': 40}, 'effect': 'Restores [1-4]% Max HP at start of each round.'},
    {'id': 'dmg_reflection_armor', 'name': 'DMG Reflection Armor', 'tier': 3, 'roll': '[20-80]', 'cost': {'crop': 20, 'wood': 60, 'stone': 40}, 'effect': '[20-40]% chance to reflect 5 True DMG. +1 per 50 Max HP.'},
    {'id': 'copper_shield', 'name': 'Copper Shield', 'tier': 3, 'roll': '[20-60]', 'cost': {'crop': 20, 'wood': 60, 'stone': 40}, 'effect': 'First time below 50% HP: Shield (Max HP*[5-15]%) + restore 30% Max HP.'},
    {'id': 'golden_axe', 'name': 'Golden Axe', 'tier': 3, 'roll': '[20-40]', 'cost': {'crop': 20, 'wood': 60, 'stone': 40}, 'effect': 'On effective DMG, [50-80]% chance Shield = (4+level)% of target Max HP. No stack.'},
    {'id': 'iron_shield', 'name': 'Iron Shield', 'tier': 3, 'roll': '[20-70]', 'cost': {'crop': 20, 'wood': 60, 'stone': 40}, 'effect': 'Melee DMG -[10-35]%. Doubled below 50% HP.', 'icon': '???'},
    // --- Lv.5 (5) ---
    {'id': 'leech_sword', 'name': 'Leech Sword', 'tier': 5, 'roll': '[20-40]', 'cost': {'wood': 60, 'stone': 30, 'iron': 20}, 'effect': 'Heals [10-50]% of DMG dealt; excess becomes Shield up to Level*6.'},
    {'id': 'circle_blade', 'name': 'Circle Blade', 'tier': 5, 'roll': '[20-40]', 'cost': {'wood': 60, 'stone': 30, 'iron': 20}, 'effect': 'Per DMG taken, next attack Leech +[4-10]% (max 60%); +30% DMG at 30% Leech.'},
    {'id': 'obsidian_armor', 'name': 'Obsidian Armor', 'tier': 5, 'roll': '[20-50]', 'cost': {'wood': 60, 'stone': 30, 'iron': 20}, 'effect': 'First 5 rounds: [40-80]% DMG Reduction; then +50% DMG taken.'},
    {'id': 'radiant_plate', 'name': 'Radiant Plate Armor', 'tier': 5, 'roll': '[20-50]', 'cost': {'wood': 60, 'stone': 30, 'iron': 20}, 'effect': 'Max HP +0% / DMG Reduction +0%; one +1% per recast, up to 50 recasts.'},
    {'id': 'thousand_tempered', 'name': 'Thousand Tempered Blade', 'tier': 5, 'roll': '[20-40]', 'cost': {'wood': 60, 'stone': 30, 'iron': 20}, 'effect': 'ATK +0% / Leech +0%; one +1% per recast, up to 50 recasts.'},
    // --- Lv.7 (9) ---
    {'id': 'darts', 'name': 'Darts', 'tier': 7, 'roll': '[4-14]', 'cost': {'wood': 70, 'stone': 45, 'iron': 35}, 'effect': 'Converts [20-50]% DMG dealt into True DMG.'},
    {'id': 'rattan_shield', 'name': 'Rattan Shield', 'tier': 7, 'roll': '[20-60]', 'cost': {'wood': 70, 'stone': 45, 'iron': 35}, 'effect': 'Ranged DMG -[30-60]%. Halved below 50% HP.', 'icon': '??'},
    {'id': 'mace', 'name': 'Mace', 'tier': 7, 'roll': '[2-8]', 'cost': {'wood': 70, 'stone': 45, 'iron': 35}, 'effect': 'Extra DMG = [1-5]% of target current HP.'},
    {'id': 'army_flag', 'name': 'Army Flag', 'tier': 7, 'roll': '[20-50]', 'cost': {'wood': 70, 'stone': 45, 'iron': 35}, 'effect': 'On death drops Flag ([2-4] HP): allies +20% DMG, enemies -20% DMG within 2 tiles.'},
    {'id': 'qiankun_saber', 'name': 'Qiankun Saber', 'tier': 7, 'roll': '[2-8]', 'cost': {'wood': 70, 'stone': 45, 'iron': 35}, 'effect': 'Basics deal extra [30-60]% ATK True DMG to 4 enemies within 1 tile of target.'},
    {'id': 'sunfire_armor', 'name': 'Sunfire Armor', 'tier': 7, 'roll': '[20-60]', 'cost': {'wood': 70, 'stone': 45, 'iron': 35}, 'effect': 'Each round start, [20-50]% chance: 4% Max-HP True DMG to 4 enemies within 1 tile.'},
    {'id': 'helmet_calmness', 'name': 'Helmet of Calmness', 'tier': 7, 'roll': '[20-50]', 'cost': {'wood': 70, 'stone': 45, 'iron': 35}, 'effect': 'Max HP +[10-20]%; restores 20% lost HP (self + 4 allies) every 5 rounds.'},
    {'id': 'pure_gold_shield', 'name': 'Pure Gold Shield', 'tier': 7, 'roll': '[20-50]', 'cost': {'wood': 70, 'stone': 45, 'iron': 35}, 'effect': 'Shield = 4% Max HP every 3 rounds; Shield effects +[20-50]% on self.'},
    {'id': 'silver_serpent', 'name': 'Silver Serpent Whip', 'tier': 7, 'roll': '[2-10]', 'cost': {'wood': 70, 'stone': 45, 'iron': 35}, 'effect': 'Basics pick nearest target in range; new target takes +[20-50]% DMG.'},
    // --- Lv.12 (10) ---
    {'id': 'lamellar_cuirass', 'name': 'Lamellar Cuirass', 'tier': 12, 'roll': '[20-80]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': 'DMG taken capped at [15-30]; excess HP loss deferred over turns.'},
    {'id': 'hook_swords', 'name': 'Hook Swords', 'tier': 12, 'roll': '[2-8]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': '[15-35]% chance bonus True DMG = (2+level)% target Max HP (ranged: 1+level%).'},
    {'id': 'mirror_armor', 'name': 'Mirror Armor', 'tier': 12, 'roll': '[20-70]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': 'Per distinct attacker: +4% DMG Reduction, max [10-15] stacks; +10% Max HP at 8.'},
    {'id': 'battle_axe', 'name': 'Battle Axe', 'tier': 12, 'roll': '[2-8]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': 'First time at 50% HP: ATK +(3*level), Leech +[10-30]% .'},
    {'id': 'jade_pendant', 'name': 'Jade Pendant', 'tier': 12, 'roll': '[20-50]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': 'Round 1: 3 closest allies gain Shield [5-10]% Max HP + block 1 active-skill hit (10 rounds).'},
    {'id': 'lethal_umbrella', 'name': 'Lethal Umbrella', 'tier': 12, 'roll': '[20-40]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': 'Battle start: ATK +[5-15]%, DMG taken -[5-15]%, doubles one of them.'},
    {'id': 'burning_heart_ring', 'name': 'Ring of Burning Heart', 'tier': 12, 'roll': '[2-6]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': 'Skill hits: 50% Burning Heart ([20-40]% ATK True DMG/round, splashes on True DMG).'},
    {'id': 'billhook', 'name': 'Billhook', 'tier': 12, 'roll': '[2-8]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': 'Bonus DMG = ([4-8]*level)% of target ATK.'},
    {'id': 'bloodrage_belt', 'name': 'Bloodrage Belt', 'tier': 12, 'roll': '[20-50]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': 'After skills: heal 4% Max HP + 40% ATK. [30-50]% chance +1 Rage when hit.'},
    {'id': 'spiked_mace', 'name': 'Spiked Mace', 'tier': 12, 'roll': '[2-8]', 'cost': {'wood': 90, 'stone': 70, 'iron': 90}, 'effect': 'On kill: [50-100]% ATK True DMG to 8 enemies within 2 tiles.'},
    // --- Lv.14 (6) ---
    {'id': 'dodge_boots', 'name': 'Dodge Boots', 'tier': 14, 'roll': '[20-50]', 'cost': {'wood': 110, 'stone': 90, 'iron': 150}, 'effect': '[10-35]% chance to dodge all DMG.'},
    {'id': 'flying_guillotine', 'name': 'Flying Guillotine', 'tier': 14, 'roll': '[2-8]', 'cost': {'wood': 110, 'stone': 90, 'iron': 150}, 'effect': 'Slays targets below [5-20]% HP; +1 ATK per kill.'},
    {'id': 'time_flag', 'name': 'Time Flag', 'tier': 14, 'roll': '[30-43]', 'cost': {'wood': 110, 'stone': 90, 'iron': 150}, 'effect': 'Season-scaling: +(3+level)*10 HP or +(3+level) ATK each season (rolled).'},
    {'id': 'hourglass', 'name': 'Hourglass', 'tier': 14, 'roll': '[2-4]', 'cost': {'wood': 110, 'stone': 90, 'iron': 150}, 'effect': '[5-25]% chance to act 2 rounds.'},
    {'id': 'blinding_pendant', 'name': 'Blinding Pendant', 'tier': 14, 'roll': '[20-50]', 'cost': {'wood': 110, 'stone': 90, 'iron': 150}, 'effect': 'When taking True DMG, [10-35]% chance to stun attacker 1 round.'},
    {'id': 'darksteel_staff', 'name': 'Darksteel Staff', 'tier': 14, 'roll': '[20-40]', 'cost': {'wood': 110, 'stone': 90, 'iron': 150}, 'effect': 'Per new target: extra [10-25]% Max-HP True DMG + Shield 40% of it (once each).'},
  ];

  // Exclusive gear: one per soldier sub-type, Smithy Lv.10.
  // 'hp'/'atk' = additional stat roll brackets; 'skillMod' = fixed skill upgrade;
  // each piece also rolls 2 random effects from the common pool.
  static const List<Map<String, dynamic>> EXCLUSIVE_EQUIPMENT = [
    {'id': 'exc_spear', 'name': 'Spear', 'subtype': 'longspearman', 'tier': 10, 'hp': '[20-40]', 'atk': '[4-12]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Stab: +1 tile reach; +15% Dodge per target hit (3 rounds).'},
    {'id': 'exc_lance', 'name': 'Lance', 'subtype': 'lancer', 'tier': 10, 'hp': '[20-40]', 'atk': '[4-13]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Project: +(allied soldiers * level) DMG, cap 40.'},
    {'id': 'exc_dagger_axe', 'name': 'Dagger-axe', 'subtype': 'dagger_axe', 'tier': 10, 'hp': '[20-40]', 'atk': '[4-10]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Disarm: disarms up to 4 enemies within 1 tile of target.'},
    {'id': 'exc_modao_saber', 'name': 'Modao Saber', 'subtype': 'modao', 'tier': 10, 'hp': '[20-40]', 'atk': '[4-15]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Steady Attack: first 3 attacks deal max roll; post-kill attack also max.'},
    {'id': 'exc_two_handed', 'name': 'Two-handed Sword', 'subtype': 'long_swordsman', 'tier': 10, 'hp': '[25-45]', 'atk': '[4-10]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Whirlwind: restores 40% of Bleed DMG triggered within 2 tiles.'},
    {'id': 'exc_double_halberd', 'name': 'Double Halberds', 'subtype': 'twin_spearman', 'tier': 10, 'hp': '[20-40]', 'atk': '[4-12]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Unbridled Dance: parry duration +1 round.'},
    {'id': 'exc_wood_shield', 'name': 'Wood Shield', 'subtype': 'saber_shield', 'tier': 10, 'hp': '[50-100]', 'atk': '[1-2]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Shield: +5% self Max HP to Shield value.'},
    {'id': 'exc_heavy_shield', 'name': 'Heavy Shield', 'subtype': 'heavy_shield', 'tier': 10, 'hp': '[60-120]', 'atk': '[1-2]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Shield Stance: -5% DMG taken per adjacent enemy.'},
    {'id': 'exc_long_spear', 'name': 'Long Spear', 'subtype': 'spear_shield', 'tier': 10, 'hp': '[45-90]', 'atk': '[1-4]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Charge: +(5% own Max HP) bonus DMG.'},
    {'id': 'exc_iron_hammer', 'name': 'Iron Hammer', 'subtype': 'hammer_shield', 'tier': 10, 'hp': '[40-80]', 'atk': '[1-2]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Earthshaker: +1 Rage to in-range allies below half Rage.'},
    {'id': 'exc_sword_shield', 'name': 'Sword&Shield', 'subtype': 'sword_shield', 'tier': 10, 'hp': '[30-70]', 'atk': '[2-6]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Guardian Sword: +3% next attack DMG per out-of-turn hit taken.'},
    {'id': 'exc_axe_shield', 'name': 'Axe&Shield', 'subtype': 'axe_shield', 'tier': 10, 'hp': '[30-70]', 'atk': '[2-8]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Whirling Axe bounce +2; Shield Bash stun +20%.'},
    {'id': 'exc_longbow', 'name': 'Longbow', 'subtype': 'longbowman', 'tier': 10, 'hp': '[10-20]', 'atk': '[2-10]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Scatter: extra attack hits 4 targets.'},
    {'id': 'exc_crossbow', 'name': 'Crossbow', 'subtype': 'crossbowman', 'tier': 10, 'hp': '[10-20]', 'atk': '[2-8]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Dexterity: 30% dodge vs ATK DMG, -10% per tile distance.'},
    {'id': 'exc_toxibow', 'name': 'Toxibow', 'subtype': 'toxibowman', 'tier': 10, 'hp': '[10-20]', 'atk': '[2-8]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Poison Arrow: (10*level)% paralyze 1 round; repeat paralysis -> Fragile (+30% taken).'},
    {'id': 'exc_hunter_bow', 'name': "Hunter's Bow", 'subtype': 'hunter', 'tier': 10, 'hp': '[10-20]', 'atk': '[2-8]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Inspire: also restores (1+level) HP to all allies.'},
    {'id': 'exc_improved_xbow', 'name': 'Improved Crossbow', 'subtype': 'improved_crossbowman', 'tier': 10, 'hp': '[10-20]', 'atk': '[2-10]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Anchor: knocks back 1 tile at max range (not vs stance/weaponry).'},
    {'id': 'exc_fire_bow', 'name': 'Bow of Fire', 'subtype': 'fire_bowman', 'tier': 10, 'hp': '[10-20]', 'atk': '[2-8]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Wildfire: flames trigger nearby allies flames.'},
    {'id': 'exc_great_sword', 'name': 'Great Sword', 'subtype': 'sword_cavalry', 'tier': 10, 'hp': '[20-40]', 'atk': '[4-13]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Leap Slash: 85% chance of bonus slash on kill.'},
    {'id': 'exc_halberd', 'name': 'Halberd', 'subtype': 'spear_cavalry', 'tier': 10, 'hp': '[30-60]', 'atk': '[4-10]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Sweep: 20% Leech on sweep.'},
    {'id': 'exc_guandao', 'name': 'Guandao', 'subtype': 'broadsword_cavalry', 'tier': 10, 'hp': '[20-40]', 'atk': '[4-15]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Chop: reserves 50% stacked DMG on target switch.'},
    {'id': 'exc_sledge', 'name': 'Sledge Hammer', 'subtype': 'heavy_cavalry', 'tier': 10, 'hp': '[50-100]', 'atk': '[2-8]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Charge: up to 4 airborne targets stunned 1 turn.'},
    {'id': 'exc_recurve', 'name': 'Recurve Bow', 'subtype': 'bow_cavalry', 'tier': 10, 'hp': '[15-25]', 'atk': '[2-8]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Guerrilla: +20% ATK vs melee targets.'},
    {'id': 'exc_mountain_axe', 'name': 'Mountain Splitting Axe', 'subtype': 'axe_cavalry', 'tier': 10, 'hp': '[35-65]', 'atk': '[4-10]', 'cost': {'wood': 100, 'stone': 80, 'iron': 130}, 'skillMod': 'Cleave: +6 Shield per target hit; else DMG +30%.'},
  ];

  // Heroes worshipped at Hall of Heroes
  static const List<Map<String, dynamic>> HEROES = [
    {
      'id': 'chen_dao',
      'name': 'Chen Dao',
      'title': 'White Feather Commander',
      'atk': 55,
      'def': 42,
      'hp': 680,
      'skill': 'White Feather Guard: +20% Spearman DMG Reduction',
    },
    {
      'id': 'zhao_yun',
      'name': 'Zhao Yun',
      'title': 'Dragon of Changban',
      'atk': 78,
      'def': 36,
      'hp': 720,
      'skill': 'Seven In, Seven Out: Initial attack deals +50% True DMG',
    },
    {
      'id': 'guan_yu',
      'name': 'Guan Yu',
      'title': 'God of War',
      'atk': 88,
      'def': 32,
      'hp': 650,
      'skill': 'Green Dragon Crescent: Breaks Shields & ignores 20% DEF',
    },
    {
      'id': 'cao_cao',
      'name': 'Cao Cao',
      'title': 'Hero of Chaos',
      'atk': 52,
      'def': 54,
      'hp': 760,
      'skill': 'Supreme Ambition: +1 Rage per turn for all allied teams',
    },
    {
      'id': 'sun_ce',
      'name': 'Sun Ce',
      'title': 'Little Conqueror',
      'atk': 82,
      'def': 30,
      'hp': 640,
      'skill': 'Fierce Charge: Cavalry ATK +30% on first round',
    },
  ];

  // Seasons
  static const List<String> SEASONS = ['Spring', 'Summer', 'Autumn', 'Winter'];

  // Terrain types
  static const int TILE_GRASS = 0;
  static const int TILE_FOREST = 1;
  static const int TILE_MOUNTAIN = 2;
  static const int TILE_WATER = 3;
  static const int TILE_SAND = 4;
}
