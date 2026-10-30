import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/game_data.dart';

class GameState extends ChangeNotifier {
  // Player resources (stored with double precision for real-time delta)
  // Basics (producible per hour): crop, wood, stone.
  double _crop = 1000.0;
  double _wood = 800.0;
  double _stone = 600.0;
  // Specials (chest-only, no production): iron, exp_scroll, scroll, nail.
  int _iron = 20;
  int _expScroll = 0;
  int _scroll = 0;
  int _nail = 0;

  // Real-time clock
  int _elapsedSeconds = 0;
  int _seasonIndex = 0;
  int _dayInSeason = 1;
  Timer? _ticker;

  // Capital 2x2 footprint on world map (unchanged)
  static const int capitalMinRow = 39;
  static const int capitalMaxRow = 40;
  static const int capitalMinCol = 39;
  static const int capitalMaxCol = 40;

  // Buildings inside Capital (9 authentic Citadel facilities)
  // Only Palace and Barracks start built (level 1). Others start unconstructed (level 0).
  // Sawnmill, Farm, and Quarry are Ground Buildings built ONLY on conquered world plots.
  final Map<String, int> _capitalBuildings = {
    'palace': 1,
    'barracks': 1,
    'smithy': 0,
    'hall_of_heroes': 0,
    'drill_ground': 0,
    'clinic': 0,
    'barn': 0,
    'warehouse': 0,
    'market': 0,
  };

  // Ground buildings on conquered plots: key 'row,col' -> {'type': 'farm'|'sawmill'|'quarry', 'level': int}
  final Map<String, Map<String, dynamic>> _plotBuildings = {};

  // Wounded soldiers awaiting treatment at Capital Clinic
  int _woundedTroops = 0;

  // Drill Ground troop training tier
  int _drillLevel = 1;

  // Conquered plots on map (format: 'row,col')
  // Conquered plots automatically possess a Watchtower & Player Flag
  final Set<String> _conqueredPlots = {};

  // World Map terrain (80x80)
  final List<List<int>> _map = [];

  // Plot specifications: key 'row,col' -> metadata
  // { 'level': 1..5, 'resource': 'crop'|'wood'|'stone', 'garrisonName': String, 'garrisonPower': int, 'difficulty': String }
  // Legacy saves may hold 'iron' plot resource — treated as stone output.
  final Map<String, Map<String, dynamic>> _plots = {};

  // Troops inventory (trained exclusively at Barracks)
  // Starter army mirrors the old composition with doc-authentic units.
  final Map<String, int> _troops = {
    'longspearman': 30,
    'longbowman': 25,
    'saber_shield': 20,
    'sword_cavalry': 15,
  };

  // Garrison troops positioned in capital interior (17x17 grid)
  // Key format: 'r,c' -> {'troopId': 'spearman', 'count': 10}
  final Map<String, Map<String, dynamic>> _capitalGarrison = {};

  // Equipment inventory (crafted exclusively at Smithy)
  final Map<String, int> _equipment = {
    'iron_shield': 1,
    'rattan_shield': 1,
    'cureblade': 1,
  };

  // Exclusive gear: equipment id -> rolled bonus text (e.g. '+32 HP / +7 ATK').
  final Map<String, String> _exclusiveEquipment = {};

  // Recast counts for growth gear (radiant_plate, thousand_tempered).
  final Map<String, int> _recastCounts = {};

  Map<String, int> get recastCounts => Map.unmodifiable(_recastCounts);

  // Worshipped heroes (permanently bound at Hall of Heroes)
  final Set<String> _worshippedHeroes = {'chen_dao'};

  // Selected tile [row, col]
  List<int>? _selectedTile;

  // View navigation: 'map', 'capital', 'plot'
  String _currentView = 'map';
  int _plotViewRow = 0;
  int _plotViewCol = 0;

  // Combat log & event stream
  final List<String> _log = [];

  GameState() {
    _startRealtimeTicker();
  }

  // Getters
  // Basics (producible): crop, wood, stone.
  int get crop => _crop.floor();
  int get wood => _wood.floor();
  int get stone => _stone.floor();
  // Specials (chest-only, no production): iron, exp scroll, scroll, nail.
  int get iron => _iron;
  int get expScroll => _expScroll;
  int get scroll => _scroll;
  int get nail => _nail;
  // Backwards compat: gold removed -> always 0.
  int get gold => 0;

  int get elapsedSeconds => _elapsedSeconds;
  int get seasonIndex => _seasonIndex;
  String get season => GameData.SEASONS[_seasonIndex];
  int get dayInSeason => _dayInSeason;

  int get woundedTroops => _woundedTroops;
  int get drillLevel => _drillLevel;
  Map<String, Map<String, dynamic>> get plotBuildings => Map.unmodifiable(_plotBuildings);

  int get cropCapacity => 5000 + ((_capitalBuildings['barn'] ?? 1) * 3000);
  int get materialCapacity => 5000 + ((_capitalBuildings['warehouse'] ?? 1) * 3000);

  Map<String, int> get capitalBuildings => Map.unmodifiable(_capitalBuildings);
  Set<String> get conqueredPlots => Set.unmodifiable(_conqueredPlots);
  Map<String, int> get troops => Map.unmodifiable(_troops);
  Map<String, int> get equipment => Map.unmodifiable(_equipment);
  Map<String, String> get exclusiveEquipment => Map.unmodifiable(_exclusiveEquipment);
  Map<String, Map<String, dynamic>> get capitalGarrison => Map.unmodifiable(_capitalGarrison);
  Set<String> get worshippedHeroes => Set.unmodifiable(_worshippedHeroes);
  String get currentView => _currentView;
  int get plotViewRow => _plotViewRow;
  int get plotViewCol => _plotViewCol;
  List<String> get log => List.unmodifiable(_log);
  List<int>? get selectedTile => _selectedTile;
  List<List<int>> get map => _map;

  void switchView(String view) {
    _currentView = view;
    notifyListeners();
  }

  void setPlotView(int row, int col) {
    _currentView = 'plot';
    _plotViewRow = row;
    _plotViewCol = col;
    notifyListeners();
  }

  void goToMap() {
    _currentView = 'map';
    notifyListeners();
  }

  // Backwards compatibility getters for existing UI
  Map<String, int> get buildings => Map.unmodifiable(_capitalBuildings);
  List<String> get heroes => _worshippedHeroes.toList();
  Map<String, String> get tiles {
    final res = <String, String>{};
    // Mark capital 2x2
    for (int r = capitalMinRow; r <= capitalMaxRow; r++) {
      for (int c = capitalMinCol; c <= capitalMaxCol; c++) {
        res['$r,$c'] = 'capital';
      }
    }
    // Mark conquered tiles
    for (var key in _conqueredPlots) {
      if (!isCapitalTileKey(key)) {
        res[key] = 'watchtower';
      }
    }
    // Mark unconquered plots with hostiles
    for (var entry in _plots.entries) {
      if (!_conqueredPlots.contains(entry.key)) {
        final lvl = entry.value['level'] as int;
        res[entry.key] = 'plot_$lvl';
      }
    }
    return res;
  }

  Map<String, int> get enemyCamps {
    final camps = <String, int>{};
    for (var entry in _plots.entries) {
      if (!_conqueredPlots.contains(entry.key)) {
        camps[entry.key] = entry.value['level'] as int;
      }
    }
    return camps;
  }

  bool isCapitalTile(int row, int col) {
    return row >= capitalMinRow && row <= capitalMaxRow &&
           col >= capitalMinCol && col <= capitalMaxCol;
  }

  bool isCapitalTileKey(String key) {
    final parts = key.split(',');
    if (parts.length != 2) return false;
    final r = int.tryParse(parts[0]) ?? -1;
    final c = int.tryParse(parts[1]) ?? -1;
    return isCapitalTile(r, c);
  }

  bool isTileConquered(int row, int col) {
    if (isCapitalTile(row, col)) return true;
    return _conqueredPlots.contains('$row,$col');
  }

  Map<String, dynamic>? getPlotData(int row, int col) {
    return _plots['$row,$col'];
  }

  void selectTile(int row, int col) {
    _selectedTile = [row, col];
    notifyListeners();
  }

  void addLog(String message) {
    _log.add(message);
    if (_log.length > 100) {
      _log.removeAt(0);
    }
    notifyListeners();
  }

  // Real-time production engine
  void _startRealtimeTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;

      // Day advances every SECONDS_PER_DAY seconds (default 60s)
      if (_elapsedSeconds % GameData.SECONDS_PER_DAY == 0) {
        _dayInSeason++;
        if (_dayInSeason > GameData.DAYS_PER_SEASON) {
          _dayInSeason = 1;
          _seasonIndex = (_seasonIndex + 1) % 4;
          addLog('Season changed to ${GameData.SEASONS[_seasonIndex]}!');
        }
      }

      // Calculate real-time rates per second
      _applyRealtimeProduction();
      notifyListeners();
    });
  }

  // Hourly production rates calculated and applied per second
  Map<String, double> getHourlyProduction() {
    // Base capital tax & production
    final palaceLvl = _capitalBuildings['palace'] ?? 1;
    double cropHr = 100.0 + (palaceLvl * 15.0);
    double woodHr = 80.0 + (palaceLvl * 10.0);
    double stoneHr = 50.0 + (palaceLvl * 8.0);
    // iron, specials: no production — only from chests

    // Production from Ground Buildings constructed on conquered world plots
    for (var entry in _plotBuildings.entries) {
      final type = entry.value['type'] as String;
      final lvl = entry.value['level'] as int? ?? 1;
      if (type == 'farm') cropHr += lvl * 60.0;
      if (type == 'sawmill') woodHr += lvl * 45.0;
      if (type == 'quarry') stoneHr += lvl * 35.0;
    }

    // Production from conquered resource plots (base territory output)
    for (var key in _conqueredPlots) {
      final plot = _plots[key];
      if (plot != null) {
        final lvl = plot['level'] as int? ?? 1;
        final resType = plot['resource'] as String? ?? 'crop';
        final yieldVal = lvl * 25.0;

        switch (resType) {
          case 'crop': cropHr += yieldVal; break;
          case 'wood': woodHr += yieldVal; break;
          case 'stone': stoneHr += yieldVal; break;
          default: break; // specials (iron/scroll/exp/nail): not produced
        }
      }
    }

    // Seasonal production modifiers
    if (_seasonIndex == 0) cropHr *= 1.25; // Spring
    if (_seasonIndex == 1) cropHr *= 1.35; // Summer
    if (_seasonIndex == 2) woodHr *= 1.20; // Autumn
    if (_seasonIndex == 3) cropHr *= 0.70; // Winter

    // Basics: FIXED production only from basics (crop/wood/stone).
    // Specials (iron/exp_scroll/scroll/nail): no production, chest-only.
    return {'crop': cropHr, 'wood': woodHr, 'stone': stoneHr};
  }

  void _applyRealtimeProduction() {
    final rates = getHourlyProduction();
    _crop += (rates['crop']! / 3600.0);
    _wood += (rates['wood']! / 3600.0);
    _stone += (rates['stone']! / 3600.0);
    // iron/exp_scroll/scroll/nail: chest-only, no passive gain.
  }

  bool hasResources(Map<String, int> cost) {
    for (var entry in cost.entries) {
      switch (entry.key) {
        case 'crop': if (_crop < entry.value) return false;
        case 'wood': if (_wood < entry.value) return false;
        case 'stone': if (_stone < entry.value) return false;
        case 'iron': if (_iron < entry.value) return false;
        case 'exp_scroll': if (_expScroll < entry.value) return false;
        case 'scroll': if (_scroll < entry.value) return false;
        case 'nail': if (_nail < entry.value) return false;
      }
    }
    return true;
  }

  void spendResources(Map<String, int> cost) {
    for (var entry in cost.entries) {
      switch (entry.key) {
        case 'crop': _crop -= entry.value; break;
        case 'wood': _wood -= entry.value; break;
        case 'stone': _stone -= entry.value; break;
        case 'iron': _iron -= entry.value; break;
        case 'exp_scroll': _expScroll -= entry.value; break;
        case 'scroll': _scroll -= entry.value; break;
        case 'nail': _nail -= entry.value; break;
      }
    }
    notifyListeners();
  }

  void _addResource(String key, int amount) {
    switch (key) {
      case 'crop': _crop += amount; break;
      case 'wood': _wood += amount; break;
      case 'stone': _stone += amount; break;
      case 'iron': _iron += amount; break;
      case 'exp_scroll': _expScroll += amount; break;
      case 'scroll': _scroll += amount; break;
      case 'nail': _nail += amount; break;
    }
  }

  int getResource(String key) {
    switch (key) {
      case 'crop': return crop;
      case 'wood': return wood;
      case 'stone': return stone;
      case 'iron': return iron;
      case 'exp_scroll': return expScroll;
      case 'scroll': return scroll;
      case 'nail': return nail;
      default: return 0;
    }
  }

  // Random Award Chest: drops after every victorious conquest.
  // Basics scale with plot level; specials (iron/scrolls/nails) roll by chance.
  Map<String, int> openAwardChest(int plotLvl) {
    final rand = math.Random();
    final reward = <String, int>{
      'crop': plotLvl * 120,
      'wood': plotLvl * 90,
      'stone': plotLvl * 60,
    };
    // Guaranteed small iron, bonus specials by luck
    reward['iron'] = plotLvl * 5 + rand.nextInt(plotLvl * 3 + 1);
    if (rand.nextDouble() < 0.30 + plotLvl * 0.05) {
      reward['exp_scroll'] = 1 + rand.nextInt(plotLvl ~/ 2 + 1);
    }
    if (rand.nextDouble() < 0.20 + plotLvl * 0.04) {
      reward['scroll'] = 1;
    }
    if (rand.nextDouble() < 0.15 + plotLvl * 0.03) {
      reward['nail'] = 1 + (plotLvl >= 4 ? rand.nextInt(2) : 0);
    }
    for (var e in reward.entries) {
      _addResource(e.key, e.value);
    }
    return reward;
  }

  static String _resLabel(String key) {
    switch (key) {
      case 'crop': return 'Crop';
      case 'wood': return 'Wood';
      case 'stone': return 'Stone';
      case 'iron': return 'Iron';
      case 'exp_scroll': return 'EXP Scroll';
      case 'scroll': return 'Scroll';
      case 'nail': return 'Nail';
      default: return key.toUpperCase();
    }
  }

  // --- CAPITAL FUNCTIONALITY ---
  // Level 0 -> build (checks construction requirement); level >=1 -> upgrade.
  Map<String, dynamic>? capitalBuildRequirement(String buildingId) {
    final building = GameData.BUILDINGS.firstWhere(
      (b) => b['id'] == buildingId,
      orElse: () => {},
    );
    if (building.isEmpty) return null;
    final req = building['requires'];
    if (req == null) return null;
    return Map<String, dynamic>.from(req as Map);
  }

  bool capitalRequirementMet(String buildingId) {
    final req = capitalBuildRequirement(buildingId);
    if (req == null) return true;
    final reqId = req['id'] as String;
    final reqLvl = req['level'] as int? ?? 1;
    return (_capitalBuildings[reqId] ?? 0) >= reqLvl;
  }

  String capitalRequirementText(String buildingId) {
    final req = capitalBuildRequirement(buildingId);
    if (req == null) return '';
    final reqId = req['id'] as String;
    final reqLvl = req['level'] as int? ?? 1;
    final reqName = GameData.BUILDINGS.firstWhere(
      (b) => b['id'] == reqId,
      orElse: () => {'name': reqId},
    )['name'];
    final cur = _capitalBuildings[reqId] ?? 0;
    return '$reqName Lv.$reqLvl (now Lv.$cur)';
  }

  bool canConstructCapitalBuilding(String buildingId) {
    if ((_capitalBuildings[buildingId] ?? 0) > 0) return false;
    if (!capitalRequirementMet(buildingId)) return false;
    final building = GameData.BUILDINGS.firstWhere(
      (b) => b['id'] == buildingId,
      orElse: () => {},
    );
    if (building.isEmpty) return false;
    return hasResources(GameData.upgradeCost(buildingId, 1));
  }

  bool constructCapitalBuilding(String buildingId) {
    if ((_capitalBuildings[buildingId] ?? 0) > 0) return false;
    if (!capitalRequirementMet(buildingId)) {
      addLog('Cannot build: requires ${capitalRequirementText(buildingId)}.');
      return false;
    }
    return upgradeCapitalBuilding(buildingId);
  }

  bool upgradeCapitalBuilding(String buildingId) {
    final building = GameData.BUILDINGS.firstWhere(
      (b) => b['id'] == buildingId,
      orElse: () => {},
    );
    if (building.isEmpty) return false;

    final currentLevel = _capitalBuildings[buildingId] ?? 0;
    final nextLevel = currentLevel + 1;

    final totalCost = GameData.upgradeCost(buildingId, nextLevel);

    if (!hasResources(totalCost)) {
      addLog('Cannot upgrade ${building['name']}: Insufficient resources.');
      return false;
    }

    spendResources(totalCost);
    _capitalBuildings[buildingId] = nextLevel;
    addLog('Capital: ${building['name']} upgraded to Level $nextLevel!');
    notifyListeners();
    return true;
  }

  // --- PALACE: COLLECT IMPERIAL TRIBUTE ---
  bool collectPalaceTribute() {
    final palaceLvl = _capitalBuildings['palace'] ?? 1;
    final bonusCrop = palaceLvl * 100;
    final bonusWood = palaceLvl * 80;
    final bonusStone = palaceLvl * 60;
    // Specials (iron/scrolls/nails): chest-only, no tribute.

    _crop += bonusCrop;
    _wood += bonusWood;
    _stone += bonusStone;
    // _iron/_expScroll/_scroll/_nail: chest-only.

    addLog('Palace: Collected Imperial Tribute! +$bonusCrop Crop, +$bonusWood Wood, +$bonusStone Stone. (Special resources come only from Award Chests)');
    notifyListeners();
    return true;
  }

  // --- BARRACKS: TRAIN TROOPS ---
  bool trainTroops(String troopId, int count) {
    final troop = GameData.TROOPS.firstWhere(
      (t) => t['id'] == troopId,
      orElse: () => {},
    );
    if (troop.isEmpty) return false;

    final costMap = troop['cost'] as Map<String, dynamic>;
    final totalCost = <String, int>{};
    for (var e in costMap.entries) {
      totalCost[e.key] = (e.value as int) * count;
    }

    if (!hasResources(totalCost)) {
      addLog('Cannot recruit ${troop['name']}: Insufficient resources.');
      return false;
    }

    spendResources(totalCost);
    _troops[troopId] = (_troops[troopId] ?? 0) + count;
    addLog('Barracks: Recruited $count ${troop['name']}.');
    notifyListeners();
    return true;
  }

  // Backwards compatibility method for game_tabs
  void recruitTroop(String troopId, int count) {
    trainTroops(troopId, count);
  }

  // --- SMITHY: CRAFT EQUIPMENT (tier-gated) ---
  bool craftEquipment(String equipmentId) {
    // Common tiers unlock by Smithy level; exclusive pieces need Lv.10.
    Map<String, dynamic> item = GameData.EQUIPMENT.firstWhere(
      (e) => e['id'] == equipmentId,
      orElse: () => {},
    );
    bool isExclusive = false;
    if (item.isEmpty) {
      item = GameData.EXCLUSIVE_EQUIPMENT.firstWhere(
        (e) => e['id'] == equipmentId,
        orElse: () => {},
      );
      isExclusive = true;
    }
    if (item.isEmpty) return false;

    final smithyLvl = _capitalBuildings['smithy'] ?? 0;
    final tier = (item['tier'] as int?) ?? 1;
    if (smithyLvl < tier) {
      addLog('${item['name']} needs Smithy Lv.$tier (now Lv.$smithyLvl).');
      return false;
    }

    final costMap = item['cost'] as Map<String, dynamic>;
    final totalCost = <String, int>{};
    for (var e in costMap.entries) {
      totalCost[e.key] = e.value as int;
    }

    if (!hasResources(totalCost)) {
      addLog('Cannot forge ${item['name']}: Insufficient resources.');
      return false;
    }

    spendResources(totalCost);
    if (isExclusive) {
      _exclusiveEquipment[equipmentId] =
          '${item['hp']} HP / ${item['atk']} ATK — ${item['skillMod']} + 2 random common passives';
      addLog('Smithy: Forged exclusive ${item['name']} (${item['hp']} HP / ${item['atk']} ATK)!');
    } else {
      _equipment[equipmentId] = (_equipment[equipmentId] ?? 0) + 1;
      addLog('Smithy: Forged 1x ${item['name']} (${item['roll']})!');
    }
    notifyListeners();
    return true;
  }

  // --- SMITHY: SMELT (Lv.10) — dismantle a common piece for 50% refund ---
  bool smeltEquipment(String equipmentId) {
    final smithyLvl = _capitalBuildings['smithy'] ?? 0;
    if (smithyLvl < 10) {
      addLog('Smelt needs Smithy Lv.10 (now Lv.$smithyLvl).');
      return false;
    }
    if ((_equipment[equipmentId] ?? 0) <= 0) {
      addLog('Nothing to smelt.');
      return false;
    }
    final item = GameData.EQUIPMENT.firstWhere(
      (e) => e['id'] == equipmentId,
      orElse: () => {},
    );
    if (item.isEmpty) return false;
    final costMap = item['cost'] as Map<String, dynamic>;
    _equipment[equipmentId] = _equipment[equipmentId]! - 1;
    for (var e in costMap.entries) {
      _addResource(e.key, (e.value as int) ~/ 2);
    }
    addLog('Smithy: Smelted 1x ${item['name']} for 50% refund.');
    notifyListeners();
    return true;
  }

  // --- SMITHY: RECAST growth gear (Radiant Plate / Thousand Tempered, max 50) ---
  bool recastEquipment(String equipmentId) {
    if (equipmentId != 'radiant_plate' && equipmentId != 'thousand_tempered') {
      addLog('Only Radiant Plate / Thousand Tempered can be recast.');
      return false;
    }
    final times = _recastCounts[equipmentId] ?? 0;
    if (times >= 50) {
      addLog('Recast cap reached (50).');
      return false;
    }
    final cost = {'iron': 20, 'stone': 20};
    if (!hasResources(cost)) {
      addLog('Recast needs 20 Iron + 20 Stone.');
      return false;
    }
    if ((_equipment[equipmentId] ?? 0) <= 0) {
      addLog('Forge the piece first before recasting.');
      return false;
    }
    spendResources(cost);
    _recastCounts[equipmentId] = times + 1;
    addLog('Smithy: Recast $equipmentId (${times + 1}/50).');
    notifyListeners();
    return true;
  }

  // --- HALL OF HEROES: WORSHIP HERO ---
  // A hero once worshipped is permanently bound for this campaign
  bool worshipHero(String heroId) {
    if (_worshippedHeroes.contains(heroId)) {
      addLog('Hero already worshipped.');
      return false;
    }

    final hero = GameData.HEROES.firstWhere(
      (h) => h['id'] == heroId,
      orElse: () => {},
    );
    if (hero.isEmpty) return false;

    final cost = {'stone': 100, 'wood': 50};
    if (!hasResources(cost)) {
      addLog('Need 100 Stone & 50 Wood to worship ${hero['name']}.');
      return false;
    }

    spendResources(cost);
    _worshippedHeroes.add(heroId);
    addLog('Hall of Heroes: ${hero['name']} has been Worshipped into active command!');
    notifyListeners();
    return true;
  }

  // --- CLINIC: HEAL WOUNDED SOLDIERS ---
  bool healWoundedTroops() {
    if (_woundedTroops <= 0) {
      addLog('Clinic: No wounded soldiers awaiting treatment.');
      return false;
    }
    final clinicLvl = _capitalBuildings['clinic'] ?? 1;
    final costCrop = math.max(10, (_woundedTroops * 4) ~/ clinicLvl);
    if (_crop < costCrop) {
      addLog('Clinic: Need $costCrop Crop to brew medicine.');
      return false;
    }
    _crop -= costCrop;
    final healed = _woundedTroops;
    _woundedTroops = 0;
    // Distribute healed back to active army
    _troops['longspearman'] = (_troops['longspearman'] ?? 0) + (healed * 0.4).round();
    _troops['longbowman'] = (_troops['longbowman'] ?? 0) + (healed * 0.3).round();
    _troops['saber_shield'] = (_troops['saber_shield'] ?? 0) + (healed * 0.2).round();
    _troops['sword_cavalry'] = (_troops['sword_cavalry'] ?? 0) + (healed * 0.1).round();
    addLog('Clinic: Treated and restored $healed wounded troops to active army!');
    notifyListeners();
    return true;
  }

  // --- DRILL GROUND: CONDUCT ARMY DRILLS ---
  bool drillArmy() {
    final cost = {'crop': 80 * _drillLevel, 'wood': 50 * _drillLevel};
    if (!hasResources(cost)) {
      addLog('Drill Ground: Need ${cost['crop']} Crop & ${cost['wood']} Wood to conduct drills.');
      return false;
    }
    spendResources(cost);
    _drillLevel++;
    addLog('Drill Ground: Completed rigorous drills! Army Potency raised to Tier $_drillLevel (+${_drillLevel * 10}% battle prowess).');
    notifyListeners();
    return true;
  }

  // --- MARKET: MERCHANT RESOURCE EXCHANGE (basics only) ---
  bool marketTrade(String fromRes, String toRes, int amount) {
    // Basics only — chest specials cannot be traded.
    const basics = {'crop', 'wood', 'stone'};
    if (!basics.contains(fromRes) || !basics.contains(toRes)) return false;
    if (amount <= 0 || fromRes == toRes) return false;
    final cost = {fromRes: amount};
    if (!hasResources(cost)) {
      addLog('Market: Insufficient $fromRes to exchange.');
      return false;
    }
    spendResources(cost);
    final marketLvl = _capitalBuildings['market'] ?? 1;
    // Base 75% rate + 5% per market level (up to 95%)
    final double rate = math.min(0.95, 0.70 + (marketLvl * 0.05));
    final received = math.max(1, (amount * rate).round());

    switch (toRes) {
      case 'crop': _crop += received; break;
      case 'wood': _wood += received; break;
      case 'stone': _stone += received; break;
      default: break; // specials (iron/scrolls/nails): chest-only, not tradable
    }
    addLog('Market: Exchanged $amount ${fromRes.toUpperCase()} for $received ${toRes.toUpperCase()} (Rate: ${(rate * 100).toInt()}%).');
    notifyListeners();
    return true;
  }

  // --- GROUND BUILDINGS: CONSTRUCT & UPGRADE ON CONQUERED PLOTS ONLY ---
  Map<String, dynamic>? getGroundBuilding(int row, int col) {
    return _plotBuildings['$row,$col'];
  }

  bool constructGroundBuilding(int row, int col) {
    final key = '$row,$col';
    if (!isTileConquered(row, col) || isCapitalTile(row, col)) {
      addLog('Ground facilities can only be constructed on conquered territory.');
      return false;
    }
    if (_plotBuildings.containsKey(key)) {
      addLog('A ground facility already exists on this plot.');
      return false;
    }

    final plot = _plots[key];
    final resType = plot?['resource'] as String? ?? 'crop';
    String buildingType = 'farm';
    if (resType == 'wood') buildingType = 'sawmill';
    if (resType == 'stone' || resType == 'iron') buildingType = 'quarry';

    final bDef = GameData.GROUND_BUILDINGS.firstWhere(
      (b) => b['id'] == buildingType,
      orElse: () => GameData.GROUND_BUILDINGS[0],
    );

    final costMap = bDef['cost'] as Map<String, dynamic>;
    final cost = <String, int>{};
    for (var e in costMap.entries) {
      cost[e.key] = e.value as int;
    }

    if (!hasResources(cost)) {
      addLog('Insufficient resources to construct ${bDef['name']}.');
      return false;
    }

    spendResources(cost);
    _plotBuildings[key] = {
      'type': buildingType,
      'level': 1,
    };
    addLog('Ground Facility: Constructed ${bDef['name']} Lv. 1 at ($row, $col)!');
    notifyListeners();
    return true;
  }

  bool upgradeGroundBuilding(int row, int col) {
    final key = '$row,$col';
    final existing = _plotBuildings[key];
    if (existing == null) return false;

    final buildingType = existing['type'] as String;
    final curLevel = existing['level'] as int? ?? 1;
    final nextLevel = curLevel + 1;

    final bDef = GameData.GROUND_BUILDINGS.firstWhere(
      (b) => b['id'] == buildingType,
      orElse: () => GameData.GROUND_BUILDINGS[0],
    );

    final costMap = bDef['cost'] as Map<String, dynamic>;
    final cost = <String, int>{};
    for (var e in costMap.entries) {
      cost[e.key] = (e.value as int) * nextLevel;
    }

    if (!hasResources(cost)) {
      addLog('Insufficient resources to upgrade ${bDef['name']}.');
      return false;
    }

    spendResources(cost);
    existing['level'] = nextLevel;
    addLog('Ground Facility: ${bDef['name']} at ($row, $col) upgraded to Level $nextLevel!');
    notifyListeners();
    return true;
  }

  // --- AUTOMATED TURN-BASED COMBAT SIMULATION ---
  // Conquers plots and removes hostile garrisons
  Map<String, dynamic> attackPlot(int row, int col) {
    final key = '$row,$col';
    if (isTileConquered(row, col)) {
      return {'victory': false, 'reason': 'Tile already controlled.'};
    }

    final plot = _plots[key];
    final int plotLvl = plot?['level'] as int? ?? 1;
    final String enemyName = plot?['garrisonName'] as String? ?? 'Wild Beasts';
    final int enemyBaseHP = (plotLvl * 500) + 200;
    final int enemyBaseATK = (plotLvl * 45) + 30;

    // Calculate player army statistics
    int playerHP = 0;
    int playerATK = 0;
    int totalTroops = 0;

    for (var entry in _troops.entries) {
      final troop = GameData.TROOPS.firstWhere((t) => t['id'] == entry.key, orElse: () => {});
      if (troop.isNotEmpty) {
        final count = entry.value;
        totalTroops += count;
        playerHP += (troop['hp'] as int) * count;
        playerATK += (troop['atk'] as int) * count;
      }
    }

    if (totalTroops <= 0) {
      addLog('Battle failed: You have no active soldiers in your army!');
      return {'victory': false, 'reason': 'No troops available.'};
    }

    // Hero stat bonuses
    for (var heroId in _worshippedHeroes) {
      final hero = GameData.HEROES.firstWhere((h) => h['id'] == heroId, orElse: () => {});
      if (hero.isNotEmpty) {
        playerATK += (hero['atk'] as int) * 2;
        playerHP += hero['hp'] as int;
      }
    }

    // Drill Ground army potency bonus
    playerATK = (playerATK * (1.0 + (_drillLevel - 1) * 0.10)).round();

    // Equipment damage reduction
    double playerDefMult = 1.0;
    if ((_equipment['iron_shield'] ?? 0) > 0) playerDefMult *= 0.80;
    if ((_equipment['rattan_shield'] ?? 0) > 0) playerDefMult *= 0.85;

    // Automated Turn Simulation (up to 5 rounds)
    final rounds = <Map<String, dynamic>>[];
    int curPlayerHP = playerHP;
    int curEnemyHP = enemyBaseHP;
    int round = 1;

    while (curPlayerHP > 0 && curEnemyHP > 0 && round <= 5) {
      // Turn 1: Vanguard strikes, then enemy
      final dmgToEnemy = (playerATK * (0.85 + (math.Random().nextDouble() * 0.3))).round();
      curEnemyHP -= dmgToEnemy;

      int dmgToPlayer = 0;
      if (curEnemyHP > 0) {
        dmgToPlayer = (enemyBaseATK * playerDefMult * (0.85 + (math.Random().nextDouble() * 0.3))).round();
        curPlayerHP -= dmgToPlayer;
      }

      rounds.add({
        'round': round,
        'dmgDealt': dmgToEnemy,
        'dmgTaken': dmgToPlayer,
        'playerHP': math.max(0, curPlayerHP),
        'enemyHP': math.max(0, curEnemyHP),
      });

      round++;
    }

    final victory = curEnemyHP <= 0;

    if (victory) {
      // Capture territory! Watchtower and player flag automatically appear
      _conqueredPlots.add(key);

      // Casualties: 50% are wounded and sent to Capital Clinic for treatment
      final lossRate = 0.08 + (plotLvl * 0.03);
      int totalLost = 0;
      for (var tKey in _troops.keys.toList()) {
        final cur = _troops[tKey] ?? 0;
        final lost = (cur * lossRate).ceil();
        totalLost += lost;
        _troops[tKey] = math.max(0, cur - lost);
      }
      final newlyWounded = (totalLost * 0.55).round();
      _woundedTroops += newlyWounded;

      // Award Chest drop: basics scale with plot level, specials by luck
      final reward = openAwardChest(plotLvl);
      final rewardText = reward.entries.map((e) => '+${e.value} ${_resLabel(e.key)}').join(', ');

      addLog('Victory at ($row, $col)! Flag claimed. Conquered $enemyName (Level $plotLvl). $newlyWounded soldiers wounded (sent to Clinic). Award Chest: $rewardText.');
    } else {
      // Defeat: lose 25% troops, 50% become wounded
      int totalLost = 0;
      for (var tKey in _troops.keys.toList()) {
        final cur = _troops[tKey] ?? 0;
        final lost = (cur * 0.25).ceil();
        totalLost += lost;
        _troops[tKey] = math.max(0, cur - lost);
      }
      final newlyWounded = (totalLost * 0.50).round();
      _woundedTroops += newlyWounded;
      addLog('Defeat at ($row, $col)! Army repelled. $newlyWounded soldiers wounded (sent to Clinic).');
    }

    notifyListeners();

    return {
      'victory': victory,
      'enemyName': enemyName,
      'plotLevel': plotLvl,
      'rounds': rounds,
      'remainingPlayerHP': math.max(0, curPlayerHP),
      'initialEnemyHP': enemyBaseHP,
    };
  }

  // Backwards compatibility method
  Map<String, dynamic> attackEnemyCamp(String campKey) {
    final parts = campKey.split(',');
    if (parts.length != 2) return {'winner': 'defender'};
    final r = int.parse(parts[0]);
    final c = int.parse(parts[1]);
    final res = attackPlot(r, c);
    return {
      'winner': res['victory'] == true ? 'attacker' : 'defender',
      'playerScore': res['remainingPlayerHP'] ?? 0,
      'enemyScore': res['initialEnemyHP'] ?? 0,
      'victory': res['victory'] ?? false,
    };
  }

  Map<String, dynamic> simulateBattle(List<String> attackerTroops, List<String> defenderTroops) {
    return {
      'winner': 'attacker',
      'attackRoll': 450,
      'defenseRoll': 320,
      'attackerHP': 850,
      'defenderHP': 0,
    };
  }

  // --- MAP & PLOT INITIALIZATION ---
  void generateMap() {
    _map.clear();
    _plots.clear();
    _conqueredPlots.clear();

    final rand = math.Random(1337);

    // Generate 80x80 terrain
    for (int r = 0; r < GameData.MAP_HEIGHT; r++) {
      final rowList = <int>[];
      for (int c = 0; c < GameData.MAP_WIDTH; c++) {
        final distFromCenter = math.sqrt(math.pow(r - 40, 2) + math.pow(c - 40, 2));
        int terrain = GameData.TILE_GRASS;

        if (distFromCenter > 25 && rand.nextDouble() < 0.25) {
          terrain = GameData.TILE_FOREST;
        } else if (distFromCenter > 32 && rand.nextDouble() < 0.18) {
          terrain = GameData.TILE_MOUNTAIN;
        } else if (rand.nextDouble() < 0.08) {
          terrain = GameData.TILE_WATER;
        } else if (rand.nextDouble() < 0.05) {
          terrain = GameData.TILE_SAND;
        }
        rowList.add(terrain);
      }
      _map.add(rowList);
    }

    // Clear Capital 2x2 area to Grassland: (39,39), (39,40), (40,39), (40,40)
    for (int r = capitalMinRow; r <= capitalMaxRow; r++) {
      for (int c = capitalMinCol; c <= capitalMaxCol; c++) {
        _map[r][c] = GameData.TILE_GRASS;
        _conqueredPlots.add('$r,$c');
      }
    }

    // Also claim immediate 1-tile boundary as player's starting domain
    for (int r = capitalMinRow - 1; r <= capitalMaxRow + 1; r++) {
      for (int c = capitalMinCol - 1; c <= capitalMaxCol + 1; c++) {
        if (r >= 0 && r < GameData.MAP_HEIGHT && c >= 0 && c < GameData.MAP_WIDTH) {
          if (_map[r][c] == GameData.TILE_MOUNTAIN || _map[r][c] == GameData.TILE_WATER) {
            _map[r][c] = GameData.TILE_GRASS;
          }
          _conqueredPlots.add('$r,$c');
        }
      }
    }

    // Populate remaining plots with Levels (1-5), resources, and garrisons
    for (int r = 0; r < GameData.MAP_HEIGHT; r++) {
      for (int c = 0; c < GameData.MAP_WIDTH; c++) {
        if (_conqueredPlots.contains('$r,$c')) continue;

        // Distance scaling capped at 12 tiles
        final dist = math.sqrt(math.pow(r - 39.5, 2) + math.pow(c - 39.5, 2));
        final cappedDist = math.min(12.0, dist);

        // Plot Level 1 to 5
        int plotLvl = 1;
        if (cappedDist >= 10.0) {
          plotLvl = 5;
        } else if (cappedDist >= 7.5) {
          plotLvl = 4;
        } else if (cappedDist >= 5.0) {
          plotLvl = 3;
        } else if (cappedDist >= 2.5) {
          plotLvl = 2;
        }

        // Plot Resource type based on terrain
        final terrain = _map[r][c];
        String resType = 'crop';
        if (terrain == GameData.TILE_FOREST) resType = 'wood';
        // Sand dunes yield stone (quarry output); iron is chest-only special.
        if (terrain == GameData.TILE_MOUNTAIN || terrain == GameData.TILE_SAND) resType = 'stone';

        // Garrison enemy based on plot level (from NTA bestiary)
        String enemyName = 'Wild Wolf Pack';
        String diff = 'Easy 1';
        if (plotLvl == 2) {
          enemyName = 'Desert Leopard & Vipers';
          diff = 'Common 2';
        } else if (plotLvl == 3) {
          enemyName = 'Rampaging Elephant & Bear';
          diff = 'Advanced 3';
        } else if (plotLvl == 4) {
          enemyName = 'Bandit Brigade (Bowmen & Assassins)';
          diff = 'Hard 2';
        } else if (plotLvl == 5) {
          enemyName = 'Boar Knight Vanguard';
          diff = 'Hell 1';
        }

        _plots['$r,$c'] = {
          'level': plotLvl,
          'resource': resType,
          'garrisonName': enemyName,
          'difficulty': diff,
        };
      }
    }

    addLog('World Map generated: 80x80 tiles.');
    addLog('Capital Fortress established at (39-40, 39-40) [2x2 Space].');
    notifyListeners();
  }

  String getTileTerrainName(int row, int col) {
    if (row < 0 || row >= _map.length || col < 0 || col >= _map[row].length) return 'Out of bounds';
    final t = _map[row][col];
    switch (t) {
      case GameData.TILE_FOREST: return 'Dense Forest';
      case GameData.TILE_MOUNTAIN: return 'High Mountain';
      case GameData.TILE_WATER: return 'River / Lake';
      case GameData.TILE_SAND: return 'Sand Dunes';
      default: return 'Plains / Grassland';
    }
  }

  bool canBuildOnTile(int row, int col) {
    return isCapitalTile(row, col);
  }

  bool buildStructure(String buildingId, int count, int row, int col) {
    return upgradeCapitalBuilding(buildingId);
  }

  // Next turn compatibility: advances real-time clock by 60s
  void nextTurn() {
    _elapsedSeconds += GameData.SECONDS_PER_DAY;
    _dayInSeason++;
    if (_dayInSeason > GameData.DAYS_PER_SEASON) {
      _dayInSeason = 1;
      _seasonIndex = (_seasonIndex + 1) % 4;
      addLog('Season changed to ${GameData.SEASONS[_seasonIndex]}!');
    }
    notifyListeners();
  }

  // --- PERSISTENCE ---
  Future<void> saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'crop': _crop,
        'wood': _wood,
        'stone': _stone,
        'iron': _iron,
        'exp_scroll': _expScroll,
        'scroll': _scroll,
        'nail': _nail,
        'elapsedSeconds': _elapsedSeconds,
        'seasonIndex': _seasonIndex,
        'dayInSeason': _dayInSeason,
        'capitalBuildings': _capitalBuildings,
        'conqueredPlots': _conqueredPlots.toList(),
        'troops': _troops,
        'equipment': _equipment,
        'exclusiveEquipment': _exclusiveEquipment,
        'recastCounts': _recastCounts,
        'worshippedHeroes': _worshippedHeroes.toList(),
        'capitalGarrison': _capitalGarrison,
        'log': _log,
      };
      await prefs.setString('nta_save_state_v2', jsonEncode(data));
      addLog('Game state saved locally.');
    } catch (e) {
      addLog('Save failed: $e');
    }
  }

  Future<bool> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('nta_save_state_v2');
      if (str == null) return false;

      final data = jsonDecode(str) as Map<String, dynamic>;
      _crop = (data['crop'] as num?)?.toDouble() ?? 1000.0;
      _wood = (data['wood'] as num?)?.toDouble() ?? 800.0;
      _stone = (data['stone'] as num?)?.toDouble() ?? 600.0;
      _iron = (data['iron'] as num?)?.toInt() ?? 20;
      _expScroll = (data['exp_scroll'] as num?)?.toInt() ?? 0;
      _scroll = (data['scroll'] as num?)?.toInt() ?? 0;
      _nail = (data['nail'] as num?)?.toInt() ?? 0;
      _elapsedSeconds = data['elapsedSeconds'] ?? 0;
      _seasonIndex = data['seasonIndex'] ?? 0;
      _dayInSeason = data['dayInSeason'] ?? 1;

      _capitalBuildings.clear();
      if (data['capitalBuildings'] != null) {
        (data['capitalBuildings'] as Map<String, dynamic>).forEach((k, v) => _capitalBuildings[k] = v as int);
      }

      _conqueredPlots.clear();
      if (data['conqueredPlots'] != null) {
        for (var p in data['conqueredPlots']) {
          _conqueredPlots.add(p.toString());
        }
      }

      // Legacy saves held old unit/gear ids — drop ids no longer in the roster.
      _troops.clear();
      if (data['troops'] != null) {
        final validIds = GameData.TROOPS.map((t) => t['id'] as String).toSet();
        (data['troops'] as Map<String, dynamic>).forEach((k, v) {
          if (validIds.contains(k)) _troops[k] = v as int;
        });
      }

      _equipment.clear();
      if (data['equipment'] != null) {
        final validGear = {
          ...GameData.EQUIPMENT.map((e) => e['id'] as String),
          ...GameData.EXCLUSIVE_EQUIPMENT.map((e) => e['id'] as String),
        };
        (data['equipment'] as Map<String, dynamic>).forEach((k, v) {
          if (validGear.contains(k)) _equipment[k] = v as int;
        });
      }

      _exclusiveEquipment.clear();
      if (data['exclusiveEquipment'] != null) {
        (data['exclusiveEquipment'] as Map<String, dynamic>)
            .forEach((k, v) => _exclusiveEquipment[k] = v.toString());
      }

      _recastCounts.clear();
      if (data['recastCounts'] != null) {
        (data['recastCounts'] as Map<String, dynamic>)
            .forEach((k, v) => _recastCounts[k] = (v as num).toInt());
      }

      _worshippedHeroes.clear();
      if (data['worshippedHeroes'] != null) {
        for (var h in data['worshippedHeroes']) {
          _worshippedHeroes.add(h.toString());
        }
      }

      _capitalGarrison.clear();
      if (data['capitalGarrison'] != null) {
        (data['capitalGarrison'] as Map<String, dynamic>).forEach((k, v) {
          if (v is Map) {
            _capitalGarrison[k] = Map<String, dynamic>.from(v);
          }
        });
      }

      addLog('Game loaded successfully.');
      notifyListeners();
      return true;
    } catch (e) {
      addLog('Load failed: $e');
      return false;
    }
  }

  // --- GARRISON MANAGEMENT ---
  // Check if a capital interior cell is blocked for troop placement (gate areas)
  bool isCapitalGarrisonBlocked(int r, int c) {
    // Blocked: 4 gate areas (5x2 each)
    // North gate: row 0, col 8 -> rows 0-4, cols 7-8
    if (r >= 0 && r <= 4 && c >= 7 && c <= 8) return true;
    // South gate: row 16, col 8 -> rows 12-16, cols 7-8
    if (r >= 12 && r <= 16 && c >= 7 && c <= 8) return true;
    // West gate: row 8, col 0 -> rows 7-8, cols 0-4
    if (r >= 7 && r <= 8 && c >= 0 && c <= 4) return true;
    // East gate: row 8, col 16 -> rows 7-8, cols 12-16
    if (r >= 7 && r <= 8 && c >= 12 && c <= 16) return true;
    return false;
  }

  // Place troops from main army to capital garrison at specific cell
  bool placeCapitalGarrison(String troopId, int count, int r, int c) {
    // Check if cell is blocked (gate areas)
    if (isCapitalGarrisonBlocked(r, c)) {
      addLog('Cannot place garrison: Gate areas are blocked!');
      return false;
    }

    // Check if we have enough troops in main army
    final available = _troops[troopId] ?? 0;
    if (available < count) {
      addLog('Not enough ${GameData.TROOPS.firstWhere((t) => t['id'] == troopId, orElse: () => {'name': troopId})['name']} in army.');
      return false;
    }

    // Check if cell already has garrison
    final key = '$r,$c';
    if (_capitalGarrison.containsKey(key)) {
      addLog('Garrison already exists at ($r, $c). Move it first.');
      return false;
    }

    // Deduct from main army
    _troops[troopId] = available - count;
    // Add to garrison
    _capitalGarrison[key] = {
      'troopId': troopId,
      'count': count,
    };
    addLog('Placed $count ${GameData.TROOPS.firstWhere((t) => t['id'] == troopId, orElse: () => {'name': troopId})['name']} at capital interior ($r, $c).');
    notifyListeners();
    return true;
  }

  // Move garrison from one cell to another
  bool moveCapitalGarrison(int fromR, int fromC, int toR, int toC) {
    final fromKey = '$fromR,$fromC';
    final toKey = '$toR,$toC';

    final garrison = _capitalGarrison[fromKey];
    if (garrison == null) {
      addLog('No garrison at source ($fromR, $fromC).');
      return false;
    }

    // Check if target is blocked
    if (isCapitalGarrisonBlocked(toR, toC)) {
      addLog('Cannot move to gate area!');
      return false;
    }

    // Check if target already occupied
    if (_capitalGarrison.containsKey(toKey)) {
      addLog('Target cell ($toR, $toC) already occupied.');
      return false;
    }

    _capitalGarrison[toKey] = garrison;
    _capitalGarrison.remove(fromKey);
    addLog('Moved garrison from ($fromR, $fromC) to ($toR, $toC).');
    notifyListeners();
    return true;
  }

  // Recall garrison back to main army
  bool recallCapitalGarrison(int r, int c) {
    final key = '$r,$c';
    final garrison = _capitalGarrison[key];
    if (garrison == null) {
      addLog('No garrison at ($r, $c).');
      return false;
    }

    final troopId = garrison['troopId'] as String;
    final count = garrison['count'] as int;
    _troops[troopId] = (_troops[troopId] ?? 0) + count;
    _capitalGarrison.remove(key);
    addLog('Recalled $count ${GameData.TROOPS.firstWhere((t) => t['id'] == troopId, orElse: () => {'name': troopId})['name']} from capital interior.');
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
