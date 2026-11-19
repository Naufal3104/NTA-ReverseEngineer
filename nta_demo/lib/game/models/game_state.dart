import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/game_data.dart';
import 'battle_engine.dart';

// Persistence (save/load) lives in a part file so it can reach the private
// state fields without widening the model's public surface.
part 'game_save.dart';

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

  // Real-time clock. `_elapsedSeconds` counts ACTIVE playtime only: one
  // season = 3 real days, and the timer pauses while the game is closed.
  int _elapsedSeconds = 0;
  int _seasonIndex = 0;
  int _dayInSeason = 1;
  Timer? _ticker;
  DateTime _lastTickAt = DateTime.now();
  int _secondsSinceSave = 0;
  bool _clockPaused = false;

  // Division picked at the lobby. No waitlist: choice applies immediately.
  int _divisionIndex = 0;
  bool _divisionChosen = false;
  int _tierWinPoints = 0;

  // Commander name — shown on the map capital pill and tile-info card
  // (reference: `FallStar7`). Editable later from the profile modal.
  String _playerName = 'Commander';
  String get playerName => _playerName;
  set playerName(String v) {
    if (v.trim().isEmpty) return;
    _playerName = v.trim();
    notifyListeners();
    saveGame(silent: true);
  }

  // Bot AI difficulty for rival unions (rebuild rule: 3 levels).
  int _botDifficultyIndex = 1;
  int _botSeconds = 0;

  // Reward Points: cap 100, income +50/day (Battle Guide §5.1). Spent on
  // conquest chests (lvl 1-3 = 1, lvl 4 = 2, lvl 5 = 3) and Grain Garrison (3x).
  int _rewardPoints = 100;
  static const int rewardPointsCap = 100;

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
    'embassy': 0,
    'union_market': 0,
  };

  // Ground buildings on conquered plots: key 'row,col' -> {'type': 'farm'|'sawmill'|'quarry', 'level': int}
  final Map<String, Map<String, dynamic>> _plotBuildings = {};

  // Wounded soldiers awaiting treatment at Capital Clinic
  int _woundedTroops = 0;

  // Per-troop training levels 1-6 (SoldierAttribute.md ranges).
  // Weaponry (catapult/trebuchet) cannot train — fixed at level 1.
  final Map<String, int> _troopLevels = {};

  // Leap stacks (Trainee Warrior passive, Sword&Shield 3205): +0.5 ATK and
  // +5 HP per stack, one stack per Boar Knight (enemy 4205) slain. Cap scales
  // with the troop's training level: 10 at Lv.1 through 100 at Lv.6.
  int _leapStacks = 0;
  int get leapStacks => _leapStacks;

  /// Stack cap at the current Sword&Shield training level ("[10-100]").
  int get leapStackCap {
    final lv = troopLevel('sword_shield').clamp(1, 6);
    return (10 + (lv - 1) * 18).clamp(10, 100);
  }

  /// Grant one Leap stack per Boar Knight killed in a battle.
  /// Only applies if the army contains Sword&Shield soldiers.
  void _gainLeapStacks(int boarKills) {
    if (boarKills <= 0) return;
    if ((_troops['sword_shield'] ?? 0) <= 0) return;
    final cap = leapStackCap;
    final before = _leapStacks;
    _leapStacks = math.min(cap, _leapStacks + boarKills);
    final gained = _leapStacks - before;
    if (gained > 0) {
      addLog('Trainee Warrior: +$gained Leap stack${gained == 1 ? '' : 's'} '
          '($_leapStacks/$cap) — Sword&Shield +'
          '${(_leapStacks * 0.5).toStringAsFixed(1)} ATK, '
          '+${_leapStacks * 5} HP.');
    }
  }

  /// Boar Knight (4205) kills from a battle's defender loss map.
  int _boarKnightKills(BattleResult result, List<BattleUnit> defenders) {
    final uidToId = {for (final u in defenders) u.uid: u.id};
    var kills = 0;
    result.defenderLosses.forEach((uid, n) {
      if (uidToId[uid] == '4205') kills += n;
    });
    return kills;
  }

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

  // Equipment inventory, keyed by the real equipBase id as a string
  // ("6003" = Cureblade). Seeded with the two shields the original game
  // hands out during the opening tutorial.
  final Map<String, int> _equipment = {
    '6022': 1, // Iron Shield
    '6014': 1, // Rattan Shield
    '6003': 1, // Cureblade
  };

  // Exclusive gear per forged piece (max 2/session), keyed by equipBase id
  // ("6101" = Spear). {
  //   'effects': [{'id': <equipEffect id>, 'roll': int} x2 drawn from pool],
  //   'locked': int (-1 none, else index into effects preserved on recast),
  //   'smelt': [{'id','roll'}] infused bonuses,
  //   'skillIntensify': '201,1', 'subtype', 'name': denormalized display }.
  final Map<String, Map<String, dynamic>> _exclusiveEquipment = {};

  /// Session forge order (insertion order = 1st/2nd piece).
  List<String> get exclusiveOrder => List.unmodifiable(_exclusiveEquipment.keys);

  /// Rolls a "lo,hi" pair, e.g. '6,15' -> 6..15 inclusive.
  int _rollPair(String raw) => GameData.rollPair(raw, math.Random());

  /// Shared gate: 1st piece needs Smithy 10, 2nd needs Smithy 18, max 2,
  /// and the subtype must be owned at the Barracks (free choice).
  String? exclusiveForgeBlocker(String equipmentId) {
    final item = GameData.exclusiveById(equipmentId);
    if (item == null) return 'Unknown exclusive piece.';
    if (_exclusiveEquipment.containsKey(equipmentId)) return 'Already forged.';
    if (_exclusiveEquipment.length >= 2) return 'Max 2 exclusives per session.';
    final smithyLvl = _capitalBuildings['smithy'] ?? 0;
    final need = _exclusiveEquipment.isEmpty ? 10 : 18;
    if (smithyLvl < need) {
      return '${item['name']} needs Smithy Lv.$need (now Lv.$smithyLvl).';
    }
    final subtype = item['subtype'] as String;
    if ((_troops[subtype] ?? 0) <= 0) {
      final troop = GameData.TROOPS.firstWhere(
        (t) => t['id'] == subtype,
        orElse: () => {'name': subtype},
      );
      return 'Own ${troop['name']} troops at the Barracks first.';
    }
    return null;
  }

  /// Smelt gate: infusing into the 1st piece needs Smithy 14, 2nd needs 18.
  String? exclusiveSmeltBlocker(String excId) {
    if (!_exclusiveEquipment.containsKey(excId)) return 'Forge it first.';
    final idx = _exclusiveEquipment.keys.toList().indexOf(excId);
    final need = idx == 0 ? 14 : 18;
    final smithyLvl = _capitalBuildings['smithy'] ?? 0;
    if (smithyLvl < need) {
      return 'Smelt on this piece needs Smithy Lv.$need (now Lv.$smithyLvl).';
    }
    if (_nail < 1) return 'Smelt needs 1 Nail.';
    return null;
  }

  // Recast counts for growth gear (radiant_plate, thousand_tempered).
  final Map<String, int> _recastCounts = {};

  Map<String, int> get recastCounts => Map.unmodifiable(_recastCounts);

  // --- PORTRAITS & EXPERTISE ---
  // Portrait fragment inventory: portrayal id -> fragment count (repair = 3).
  final Map<int, int> _heroFragments = {310101: 3};
  // Repaired portraits: id -> {'grade': 0..7, 'redraws': int, 'pity': int}.
  final Map<int, Map<String, int>> _portraits = {
    310101: {'grade': 0, 'redraws': 0, 'pity': 0},
  };
  // Rolled expertise per portrait: id -> [strategyId, ...] indexed by slot.
  final Map<int, List<int?>> _portraitStrategies = {310101: []};
  // Worshipped hero ids (permanently bound at Hall of Heroes).
  final Set<int> _worshippedHeroes = {310101};
  // General Muster Terrace: draws toward the 50-draw guaranteed counter.
  int _musterDraws = 20;
  // Shop daily gift claimed today (reset on new day).
  bool _dailyGiftClaimed = false;

  // --- POLICIES ---
  // slot index (0-based) -> {'policyId': int, 'tier': 0..2}
  final Map<int, Map<String, int>> _activePolicies = {};
  // Policies unlocked via Research Institute (ceri.json type 1).
  final Set<int> _researchedPolicies = {};

  Map<int, Map<String, int>> get activePolicies => Map.unmodifiable(_activePolicies);
  Set<int> get researchedPolicies => Set.unmodifiable(_researchedPolicies);

  // --- UNION (offline: bots stand in for the other 39 players) ---
  bool _unionJoined = false;
  String _unionName = '';
  bool _unionIsLeader = false;
  // Member roster: {'name': String, 'embassy': int, 'leader': bool}.
  // Slot count is capped by the leader's embassy level (buildAttr effect 6).
  final List<Map<String, dynamic>> _unionMembers = [];

  bool get unionJoined => _unionJoined;
  String get unionName => _unionName;
  bool get unionIsLeader => _unionIsLeader;
  List<Map<String, dynamic>> get unionMembers => List.unmodifiable(_unionMembers);

  /// Leader's embassy level — governs how many members fit in the union.
  /// When the player leads, their own embassy is authoritative.
  int get unionLeaderEmbassy {
    if (_unionIsLeader) return _capitalBuildings['embassy'] ?? 1;
    for (final m in _unionMembers) {
      if (m['leader'] == true) return (m['embassy'] as int?) ?? 1;
    }
    return _capitalBuildings['embassy'] ?? 1;
  }

  int get unionMemberSlots => GameData.embassyMemberSlots(unionLeaderEmbassy);
  int get unionMemberCount => _unionMembers.length;

  /// Total union embassy level across all members — gates the 3 union policy
  /// slots at 1 / 200 / 400.
  int get totalUnionEmbassyLevel =>
      _unionMembers.fold<int>(0, (a, m) => a + ((m['embassy'] as int?) ?? 0));

  /// Union policy slots open at the current total union embassy level.
  int get unionPolicySlots {
    final total = totalUnionEmbassyLevel;
    return GameData.UNION_POLICY_LEVELS.where((l) => l <= total).length;
  }

  /// Can the player create a union (leader)? Embassy Lv.3.
  bool get canCreateUnion => (_capitalBuildings['embassy'] ?? 0) >= 3;
  /// Can the player join an existing union? Embassy Lv.1.
  bool get canJoinUnion => (_capitalBuildings['embassy'] ?? 0) >= 1;

  /// Three candidate unions to join (free, unlimited re-roll). Leader embassy
  /// levels are simulated for the bot-run unions.
  List<Map<String, dynamic>> drawUnionChoices({int count = 3}) {
    const names = [
      'Tiger Banner', 'Iron Lotus', 'Golden Harvest', 'Crimson Spear',
      'Azure Wind', 'Stone Pact', 'Silk Road Guild', 'Northern Watch',
    ];
    final rng = math.Random();
    final picks = <Map<String, dynamic>>[];
    final pool = List<String>.from(names)..shuffle(rng);
    for (int i = 0; i < count && i < pool.length; i++) {
      final leaderEmbassy = 3 + rng.nextInt(18); // Lv.3-20
      final slots = GameData.embassyMemberSlots(leaderEmbassy);
      picks.add({
        'name': pool[i],
        'leaderEmbassy': leaderEmbassy,
        'slots': slots,
        'members': math.max(1, slots - rng.nextInt(3)),
        'totalEmbassy': leaderEmbassy * math.max(1, slots ~/ 2),
      });
    }
    return picks;
  }

  /// Join an existing (bot-run) union. Free and unlimited.
  bool joinUnion(Map<String, dynamic> candidate) {
    if (!canJoinUnion) {
      addLog('Union: Build the Embassy first (Lv.1).');
      return false;
    }
    final name = candidate['name'] as String? ?? 'Union';
    final leaderEmbassy = (candidate['leaderEmbassy'] as int?) ?? 3;
    final slots = GameData.embassyMemberSlots(leaderEmbassy);
    final memberCount = math.max(1, (candidate['members'] as int?) ?? 1);

    _unionJoined = true;
    _unionName = name;
    _unionIsLeader = false;
    _unionMembers
      ..clear()
      ..add({'name': 'Warlord (Leader)', 'embassy': leaderEmbassy, 'leader': true});
    final botEmbassy = math.max(1, leaderEmbassy - 4);
    for (int i = 1; i < math.min(memberCount, slots); i++) {
      _unionMembers.add({'name': 'Member ${i + 1}', 'embassy': botEmbassy, 'leader': false});
    }
    _unionMembers.add({
      'name': 'You',
      'embassy': _capitalBuildings['embassy'] ?? 1,
      'leader': false,
    });
    addLog('Union: Joined "$name" (leader embassy Lv.$leaderEmbassy, $slots slots).');
    notifyListeners();
    return true;
  }

  /// Create a union and become its leader (Embassy Lv.3).
  bool createUnion(String name) {
    if (!canCreateUnion) {
      addLog('Union: Creating a union needs Embassy Lv.3.');
      return false;
    }
    final clean = name.trim().isEmpty ? 'My Union' : name.trim();
    _unionJoined = true;
    _unionName = clean;
    _unionIsLeader = true;
    _unionMembers
      ..clear()
      ..add({
        'name': 'You (Leader)',
        'embassy': _capitalBuildings['embassy'] ?? 3,
        'leader': true,
      });
    _syncUnionBots();
    addLog('Union: Created "$clean". You are the leader (slots: $unionMemberSlots).');
    notifyListeners();
    return true;
  }

  /// Leave the current union. Free and unlimited.
  bool leaveUnion() {
    if (!_unionJoined) return false;
    addLog('Union: Left "$_unionName".');
    _unionJoined = false;
    _unionName = '';
    _unionIsLeader = false;
    _unionMembers.clear();
    _unionPolicies.clear();
    notifyListeners();
    return true;
  }

  /// Fill empty slots in a player-led union with bot members as the embassy
  /// grows. Bot embassy levels are simulated so the union embassy total can
  /// reach the 200/400 policy gates.
  void _syncUnionBots() {
    if (!_unionIsLeader) {
      for (final m in _unionMembers) {
        if (m['name'] == 'You') m['embassy'] = _capitalBuildings['embassy'] ?? 1;
      }
      return;
    }
    for (final m in _unionMembers) {
      if (m['leader'] == true) m['embassy'] = _capitalBuildings['embassy'] ?? 3;
    }
    final slots = unionMemberSlots;
    final rng = math.Random();
    while (_unionMembers.length < slots) {
      final botEmbassy = 3 + rng.nextInt(18);
      _unionMembers.add({
        'name': 'Ally ${_unionMembers.length}',
        'embassy': botEmbassy,
        'leader': false,
      });
    }
  }

  /// Ranked division auto-assigns a union (division `autoUnion`).
  void _autoAssignUnion() {
    if (!autoUnion || _unionJoined) return;
    final choices = drawUnionChoices(count: 1);
    if (choices.isEmpty) return;
    final c = choices.first;
    final leaderEmbassy = (c['leaderEmbassy'] as int?) ?? 3;
    _unionJoined = true;
    _unionName = c['name'] as String? ?? 'Assigned Union';
    _unionIsLeader = false;
    _unionMembers
      ..clear()
      ..add({'name': 'Warlord (Leader)', 'embassy': leaderEmbassy, 'leader': true})
      ..add({
        'name': 'You',
        'embassy': _capitalBuildings['embassy'] ?? 1,
        'leader': false,
      });
    addLog('Union: Assigned to "$_unionName" (Ranked division).');
  }

  // --- UNION POLICIES (3 slots at total union embassy 1 / 200 / 400) ---
  // slot index (0-based) -> {'policyId': int, 'tier': 0..2}
  final Map<int, Map<String, int>> _unionPolicies = {};
  Map<int, Map<String, int>> get unionPolicies => Map.unmodifiable(_unionPolicies);

  bool canEnactIntoUnion(int slot) {
    if (slot < 0 || slot >= unionPolicySlots) return false;
    for (int i = 0; i < slot; i++) {
      if (!_unionPolicies.containsKey(i)) return false;
    }
    return true;
  }

  /// Leader-only (as in the original: the union leader sets union policy).
  bool enactUnionPolicy(int slot, int policyId, int tier) {
    if (!_unionIsLeader) {
      addLog('Union Policy: only the union leader can enact.');
      return false;
    }
    if (!canEnactIntoUnion(slot)) {
      addLog('Union Policy: fill the previous slot first.');
      return false;
    }
    final policy = GameData.policyById(policyId);
    if (policy == null) return false;
    if (GameData.POLICY_RESEARCH.containsKey(policyId) &&
        !_researchedPolicies.contains(policyId)) {
      addLog('Union Policy: ${policy['name']} has not been researched.');
      return false;
    }
    if (!GameData.policyGateMet(policy, _capitalBuildings)) {
      addLog('Union Policy: ${policy['name']} needs a higher building level.');
      return false;
    }
    final t = tier.clamp(0, ((policy['values'] as List).length - 1));
    _unionPolicies[slot] = {'policyId': policyId, 'tier': t};
    addLog('Union Policy enacted: ${policy['name']} (Tier ${t + 1}) — '
        '${GameData.policyDesc(policy, t)}');
    notifyListeners();
    return true;
  }

  bool resetUnionPolicySlot(int slot) {
    if (!_unionIsLeader) return false;
    final removed = _unionPolicies.remove(slot);
    if (removed == null) return false;
    addLog('Union Policy slot ${slot + 1} reset.');
    notifyListeners();
    return true;
  }

  // --- REMAINS (neutral capitals) ---
  // Real city.json ids 3001-3004. Each row: {'id','name','row','col',
  // 'level' 1-20, 'owner'} where owner is 'neutral' | 'player' | <union name>.
  final Map<int, Map<String, dynamic>> _remains = {};
  Map<int, Map<String, dynamic>> get remains => Map.unmodifiable(_remains);

  // Rival union leaders for Ranked Final Conquest. Bot AI fills holds/territory.
  final List<Map<String, dynamic>> _rivalUnions = [];
  List<Map<String, dynamic>> get rivalUnions => List.unmodifiable(_rivalUnions);

  bool _gameOver = false;
  bool _gameWon = false;
  String _victoryTitle = '';
  final List<String> _victoryLines = [];
  bool get gameOver => _gameOver;
  bool get gameWon => _gameWon;
  String get victoryTitle => _victoryTitle;
  List<String> get victoryLines => List.unmodifiable(_victoryLines);

  /// Short HUD label for the active victory objective.
  String get victoryProgressLabel {
    if (victoryCondition == 'Final Conquest') {
      final total = _rivalUnions.length;
      final down = _rivalUnions.where((u) => u['defeated'] == true).length;
      return 'Leaders $down/$total';
    }
    final lv12 = playerRemains
        .where((r) => (r['level'] as int) >= GameData.REMAINS_WIN_COUNT_LEVEL)
        .length;
    return 'Remains Lv.$playerRemainsMaxLevel/${GameData.REMAINS_WIN_LEVEL}'
        ' · $lv12/${GameData.REMAINS_WIN_COUNT}@Lv.${GameData.REMAINS_WIN_COUNT_LEVEL}';
  }

  void _initRemains() {
    _remains.clear();
    for (final r in GameData.REMAINS) {
      _remains[r['id'] as int] = {
        'id': r['id'],
        'name': r['name'],
        'row': r['row'],
        'col': r['col'],
        'level': 1,
        'owner': 'neutral',
      };
    }
  }

  /// Remains whose 2x2 footprint covers (row, col), if any.
  Map<String, dynamic>? remainsAt(int row, int col) {
    for (final r in _remains.values) {
      final rr = r['row'] as int;
      final cc = r['col'] as int;
      if (row >= rr && row <= rr + 1 && col >= cc && col <= cc + 1) return r;
    }
    return null;
  }

  bool isRemainsTile(int row, int col) => remainsAt(row, col) != null;

  List<Map<String, dynamic>> get playerRemains => [
        for (final r in _remains.values)
          if (r['owner'] == 'player') r,
      ];

  int get playerRemainsMaxLevel => playerRemains.fold<int>(
      0, (a, r) => math.max(a, r['level'] as int));

  int get playerRemainsLevelSum =>
      playerRemains.fold<int>(0, (a, r) => a + (r['level'] as int));

  /// Remains upgrade cost uses the Capital (palace) ladder — city.json gives
  /// Remains the same hp 180 / 7x7 build_size footprint as the Capital.
  Map<String, int> remainsUpgradeCost(int id) {
    final r = _remains[id];
    final lvl = (r?['level'] as int?) ?? 1;
    if (lvl >= GameData.REMAINS_MAX_LEVEL) return const {};
    return GameData.upgradeCost('palace', lvl + 1);
  }

  /// Assault a Remains. Neutral garrison is the same for bot-held Remains in
  /// the offline demo (the original garrisons it with the owner's army).
  Map<String, dynamic> attackRemains(int id) {
    final r = _remains[id];
    if (r == null) return {'victory': false, 'reason': 'No such Remains.'};
    if (_gameOver) return {'victory': false, 'reason': 'Session already settled.'};
    if (r['owner'] == 'player') {
      return {'victory': false, 'reason': 'Remains already under your control.'};
    }
    final totalTroops =
        _troops.values.fold<int>(0, (a, b) => a + (b > 0 ? b : 0));
    if (totalTroops <= 0) {
      addLog('Battle failed: You have no active soldiers in your army!');
      return {'victory': false, 'reason': 'No troops available.'};
    }

    final rng = math.Random();
    final gateIndex = _approachGate(r['row'] as int, r['col'] as int);
    final attackers = _playerAttackers(gateIndex);
    final defenders =
        BattleEngine.buildUnitsFromRaw(GameData.REMAINS_GARRISON);
    final result = BattleEngine.simulate(
      attackers: attackers,
      defenders: defenders,
      rng: rng,
    );
    final newlyWounded = _applyCasualties(result);
    _gainLeapStacks(_boarKnightKills(result, defenders));
    if (getGroundBuilding(r['row'] as int, r['col'] as int)?['type'] == 'fortress') {
      fieldHealAtFortress(r['row'] as int, r['col'] as int);
    }

    final prevOwner = r['owner'] as String;
    if (result.victory) {
      final penalty = prevOwner == 'neutral'
          ? 0
          : GameData.REMAINS_RECAPTURE_PENALTY;
      r['level'] = math.max(1, (r['level'] as int) - penalty);
      r['owner'] = 'player';
      addLog('Remains captured: ${r['name']} (now Lv.${r['level']}) after '
          '${result.rounds} rounds.$penaltyTag(penalty)$newlyWoundedTag(newlyWounded)');
      if (prevOwner != 'neutral') _defeatRivalLeader(prevOwner);
      _evaluateVictory();
    } else {
      addLog('Assault on ${r['name']} repelled after ${result.rounds} rounds! '
          '$newlyWounded wounded (Clinic).');
    }
    notifyListeners();
    return {
      'victory': result.victory,
      'enemyName': '${r['name']} Garrison',
      'plotLevel': r['level'],
      'rounds': result.rounds,
      'events': result.events,
      'frames': result.frames,
      'attackerStart': result.attackerStart,
      'attackerLosses': result.attackerLosses,
      'defenderLosses': result.defenderLosses,
      'wounded': newlyWounded,
      'remains': true,
      'remainsId': id,
    };
  }

  String penaltyTag(int penalty) =>
      penalty > 0 ? ' Recaptured Remains lost $penalty levels.' : '';

  String newlyWoundedTag(int wounded) =>
      wounded > 0 ? ' $wounded wounded (Clinic).' : '';

  bool upgradeRemains(int id) {
    final r = _remains[id];
    if (r == null) return false;
    if (r['owner'] != 'player') {
      addLog('Remains: capture ${r['name']} before upgrading it.');
      return false;
    }
    final lvl = r['level'] as int;
    if (lvl >= GameData.REMAINS_MAX_LEVEL) {
      addLog('Remains: ${r['name']} is already at max level.');
      return false;
    }
    final cost = remainsUpgradeCost(id);
    if (!hasResources(cost)) {
      addLog('Insufficient resources to upgrade ${r['name']}.');
      return false;
    }
    spendResources(cost);
    r['level'] = lvl + 1;
    addLog('Remains: ${r['name']} raised to Lv.${lvl + 1}.');
    _evaluateVictory();
    notifyListeners();
    return true;
  }

  // --- VICTORY CONDITIONS (CLAUDE.md § Data Absolut) ---
  String _forceLabel(String force) => force == 'player' ? 'You' : force;

  int _rivalTerritory(String force) {
    for (final u in _rivalUnions) {
      if (u['name'] == force) return (u['territory'] as int?) ?? 0;
    }
    return 0;
  }

  void _defeatRivalLeader(String unionName) {
    for (final u in _rivalUnions) {
      if (u['name'] == unionName && u['defeated'] != true) {
        u['defeated'] = true;
        addLog('Final Conquest: union leader of "$unionName" defeated.');
        // Final Conquest rule 3: a defeated leader's members settle and
        // leave, so its remaining Remains revert to neutral. Construct
        // Remains has no leader-defeat rule, so holdings stay put.
        if (victoryCondition == 'Final Conquest') {
          for (final r in _remains.values) {
            if (r['owner'] == unionName) r['owner'] = 'neutral';
          }
        }
      }
    }
  }

  void _declareVictory(bool won, String mode, List<String> lines) {
    if (_gameOver) return;
    _gameOver = true;
    _gameWon = won;
    _victoryTitle = '${won ? 'Victory' : 'Defeat'} — $mode';
    _victoryLines
      ..clear()
      ..addAll(lines);
    addLog('$_victoryTitle: ${lines.join(' ')}');
  }

  /// Re-check every victory clause that can fire mid-season.
  void _evaluateVictory() {
    if (_gameOver) return;
    if (victoryCondition == 'Construct Remains') {
      final best = playerRemainsMaxLevel;
      if (best >= GameData.REMAINS_WIN_LEVEL) {
        _declareVictory(true, 'Construct Remains', [
          'A Remains reached Lv.${GameData.REMAINS_WIN_LEVEL} first.',
        ]);
        return;
      }
      final lv12 = playerRemains
          .where((r) => (r['level'] as int) >= GameData.REMAINS_WIN_COUNT_LEVEL)
          .length;
      if (lv12 >= GameData.REMAINS_WIN_COUNT) {
        _declareVictory(true, 'Construct Remains', [
          '$lv12 Remains held at Lv.${GameData.REMAINS_WIN_COUNT_LEVEL}+.',
        ]);
        return;
      }
    } else if (_rivalUnions.isNotEmpty &&
        _rivalUnions.every((u) => u['defeated'] == true)) {
      _declareVictory(true, 'Final Conquest', [
        'All other union leaders defeated.',
      ]);
    }
  }

  /// Winter begins: if every Remains sits under one force, that force wins.
  void _onWinterStart() {
    if (victoryCondition != 'Construct Remains') return;
    final holders = <String>{
      for (final r in _remains.values)
        if (r['owner'] != 'neutral') r['owner'] as String,
    };
    if (holders.length != 1) return;
    final force = holders.first;
    final holdsAll = _remains.values.every((r) => r['owner'] == force);
    if (!holdsAll) return;
    _declareVictory(force == 'player', 'Construct Remains', [
      'Winter arrived with every Remains under one force: ${_forceLabel(force)}.',
    ]);
  }

  /// Winter ends: settlement.
  /// Construct Remains -> highest Remains level, ties by territory ranking.
  /// Final Conquest -> highest total union points.
  void _onWinterEnd() {
    if (victoryCondition == 'Final Conquest') {
      final bestRival = _rivalUnions.fold<int>(
          0, (a, u) => math.max(a, (u['points'] as int?) ?? 0));
      final won = _tierWinPoints >= bestRival;
      _declareVictory(won, 'Final Conquest', [
        'Winter ended. Your union points: $_tierWinPoints'
            ' · best rival: $bestRival.',
      ]);
      return;
    }
    final totals = <String, int>{};
    for (final r in _remains.values) {
      final o = r['owner'] as String;
      if (o == 'neutral') continue;
      totals[o] = (totals[o] ?? 0) + (r['level'] as int);
    }
    if (totals.isEmpty) {
      _declareVictory(false, 'Construct Remains', [
        'Winter ended with no Remains held by any force.',
      ]);
      return;
    }
    final best = totals.entries.reduce((a, b) => b.value > a.value ? b : a);
    var tied = totals.entries
        .where((e) => e.value == best.value)
        .map((e) => e.key)
        .toList();
    if (tied.length > 1) {
      int terr(String f) =>
          f == 'player' ? _conqueredPlots.length : _rivalTerritory(f);
      tied = [tied.reduce((a, b) => terr(b) > terr(a) ? b : a)];
    }
    final winner = tied.first;
    _declareVictory(winner == 'player', 'Construct Remains', [
      'Winter ended. Remains levels: '
          '${totals.entries.map((e) => '${_forceLabel(e.key)} ${e.value}').join(', ')}'
          '${tied.length == 1 && totals.values.where((v) => v == best.value).length > 1 ? ' (tie broken by territory)' : ''}.',
    ]);
  }

  void closeVictory() {
    _gameOver = false;
    notifyListeners();
  }

  /// Start a fresh season session in the current division.
  void startNewSession() {
    _gameOver = false;
    _gameWon = false;
    _victoryTitle = '';
    _victoryLines.clear();
    _elapsedSeconds = 0;
    _seasonIndex = 0;
    _dayInSeason = 1;
    _secondsSinceSave = 0;
    _tierWinPoints = 0;
    _rewardPoints = rewardPointsCap;
    _plotBuildings.clear();
    _remains.clear();
    _botSeconds = 0;
    generateMap();
    _initRivalUnions();
    addLog('New session started: $divisionName.');
    notifyListeners();
  }

  /// Rival unions contest the Remains. The offline demo seeds each rival with
  /// one Remains so both victory paths exist from turn 1; the bot AI then
  /// keeps levelling them. Chang'an (3001) stays neutral — the player's
  /// first target.
  void _initRivalUnions() {
    _rivalUnions.clear();
    const names = [
      'Tiger Banner', 'Iron Lotus', 'Golden Harvest',
      'Crimson Spear', 'Azure Wind', 'Stone Pact',
    ];
    final rng = math.Random();
    final pool = List<String>.from(names)
      ..remove(_unionName)
      ..shuffle(rng);
    final contested = [3002, 3003, 3004];
    for (var i = 0; i < contested.length && i < pool.length; i++) {
      _rivalUnions.add({
        'name': pool[i],
        'leader': 'Warlord ${i + 1}',
        'points': 0,
        'territory': 0,
        'ticks': 0,
        'defeated': false,
      });
      final r = _remains[contested[i]];
      if (r != null) {
        r['owner'] = pool[i];
        r['level'] = 3 + rng.nextInt(4); // Lv.3-6
      }
    }
  }

  /// Policy slots open at the current capital level (ladder 1/5/10/15/20).
  int get policySlots =>
      GameData.policySlotsAt(_capitalBuildings['palace'] ?? 1);

  // --- BOT AI (rival unions, 3 difficulty levels) ---
  int get botDifficultyIndex => _botDifficultyIndex;
  Map<String, dynamic> get botDifficulty => GameData
      .BOT_DIFFICULTIES[_botDifficultyIndex.clamp(0, GameData.BOT_DIFFICULTIES.length - 1)];

  void setBotDifficulty(int index) {
    _botDifficultyIndex =
        index.clamp(0, GameData.BOT_DIFFICULTIES.length - 1);
    _botSeconds = 0;
    addLog('Bot difficulty: ${botDifficulty['name']}.');
    saveGame(silent: true);
    notifyListeners();
  }

  /// One bot move per tick of active playtime. Each surviving rival union
  /// levels its Remains every `levelsEvery` ticks and gains union points.
  void _botTurn() {
    if (_gameOver || _rivalUnions.isEmpty) return;
    final diff = botDifficulty;
    final levelsEvery = diff['levelsEvery'] as int;
    final points = diff['points'] as int;
    final territory = diff['territory'] as int;

    for (final u in _rivalUnions) {
      if (u['defeated'] == true) continue;
      final ticks = ((u['ticks'] as int?) ?? 0) + 1;
      u['ticks'] = ticks;
      u['points'] = ((u['points'] as int?) ?? 0) + points;
      if (ticks % levelsEvery == 0) {
        u['territory'] = ((u['territory'] as int?) ?? 0) + territory;
        final owned = _remains.values
            .where((r) => r['owner'] == u['name'])
            .toList();
        for (final r in owned) {
          final lvl = r['level'] as int;
          if (lvl < GameData.REMAINS_MAX_LEVEL) {
            r['level'] = lvl + 1;
            // Remains level only decides the game in Construct Remains.
            if (victoryCondition == 'Construct Remains' &&
                (r['level'] as int) >= GameData.REMAINS_WIN_LEVEL) {
              _declareVictory(false, 'Construct Remains', [
                '${u['name']} built ${r['name']} to '
                    'Lv.${GameData.REMAINS_WIN_LEVEL} first.',
              ]);
              return;
            }
          }
        }
      }
    }
  }

  /// Army cap (number of teams) = palace buildAttr effect 11 + policy type 11.
  int get armyCap =>
      (GameData.levelStats('palace', _capitalBuildings['palace'] ?? 1)['armyCap']
              as int) +
      policyEffect(11).round();

  /// Fractional reduction from a `-{0}%` policy type (0..1).
  double _pctReduce(int type) => (policyEffect(type) / 100).clamp(0.0, 0.9);

  /// Recruit time multiplier (policy type 5).
  double get recruitTimeMult => 1 - _pctReduce(5);
  /// Drill/train time multiplier (policy type 14).
  double get trainTimeMult => 1 - _pctReduce(14);
  /// Heal time multiplier (policy type 37).
  double get healTimeMult => 1 - _pctReduce(37);
  /// March time multiplier (policy type 13).
  double get marchTimeMult => 1 - _pctReduce(13);
  /// Building construction time multiplier (policy type 2).
  double get buildTimeMult => 1 - _pctReduce(2);

  /// Combat stat modifiers fed into `BattleEngine.buildPlayerUnits`.
  /// Territory assumption: attacking a neutral/enemy plot counts as enemy
  /// territory, so type 39 (+ATK) applies and type 38 (own-territory HP) does not.
  Map<String, dynamic> _battlePolicyMods() {
    final hpPctType = <String, double>{};
    final atkPctType = <String, double>{};
    final drType = <String, double>{};

    final cavPct = policyEffect(52) / 100; // HP Max & ATK all cavalry
    if (cavPct > 0) {
      hpPctType['cavalry'] = (hpPctType['cavalry'] ?? 0) + cavPct;
      atkPctType['cavalry'] = (atkPctType['cavalry'] ?? 0) + cavPct;
    }
    final bowAtk = policyEffect(61) / 100; // DMG dealt by all bowmen
    if (bowAtk > 0) atkPctType['bow'] = (atkPctType['bow'] ?? 0) + bowAtk;
    final shieldDr = policyEffect(60) / 100; // DMG taken by shield soldiers
    if (shieldDr > 0) drType['shield'] = (drType['shield'] ?? 0) + shieldDr;

    // Type 39 "Tanduk Attack": +ATK% in enemy territory (applies to every type).
    final enemyAtk = policyEffect(39) / 100;
    if (enemyAtk > 0) {
      for (final t in ['spear', 'shield', 'bow', 'cavalry', 'weaponry']) {
        atkPctType[t] = (atkPctType[t] ?? 0) + enemyAtk;
      }
    }

    // Type 42 "Kekuatan Tingkat 1": HP Max & ATK of Lv.1 soldiers.
    final lv1Pct = policyEffect(42) / 100;
    final hpPctTroop = <String, double>{};
    final atkPctTroop = <String, double>{};
    if (lv1Pct > 0) {
      for (final entry in _troops.entries) {
        if (entry.value <= 0) continue;
        if (troopLevel(entry.key) == 1) {
          hpPctTroop[entry.key] = lv1Pct;
          atkPctTroop[entry.key] = lv1Pct;
        }
      }
    }

    return {
      'hpFlatPerLevel': policyEffect(40).round(),
      'atkFlatPerLevel': policyEffect(41).round(),
      'hpPctByTroop': hpPctTroop,
      'atkPctByTroop': atkPctTroop,
      'hpPctByType': hpPctType,
      'atkPctByType': atkPctType,
      'drByType': drType,
    };
  }

  // Selected tile [row, col]
  List<int>? _selectedTile;

  // View navigation: 'lobby', 'map', 'capital', 'plot'
  String _currentView = 'lobby';
  int _plotViewRow = 0;
  int _plotViewCol = 0;

  // Combat log & event stream
  final List<String> _log = [];

  // Battle report entries (newest first) — shown in the Armies modal's
  // Battle Report tab. Each entry: {
  //  'time': DateTime, 'victory': bool, 'row': int, 'col': int,
  //  'targetLabel': String, 'rounds': int, 'kills': int, 'fallen': int,
  //  'armies': int, 'defenderLosses': int, 'attackerStart': int,
  // }
  final List<Map<String, dynamic>> _battleReports = [];
  List<Map<String, dynamic>> get battleReports =>
      List.unmodifiable(_battleReports);

  // March / march-time entries for the March List modal and per-army
  // labels in Armies → All Armies. Each entry: {
  //  'team': int, 'state': 'Training'|'Marching'|'Idle',
  //  'target': String, 'secondsLeft': int, 'chest': int?,
  // }
  final List<Map<String, dynamic>> _marches = [];
  List<Map<String, dynamic>> get marches => List.unmodifiable(_marches);

  GameState() {
    generateMap();
    _startRealtimeTicker();
    _restore();
  }

  /// notifyListeners() is protected; the save/load part file calls this.
  void _notifyAfterRestore() => notifyListeners();

  Future<void> _restore() async {
    await loadGame();
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

  int get rewardPoints => _rewardPoints;

  int get elapsedSeconds => _elapsedSeconds;
  int get seasonIndex => _seasonIndex;
  String get season => GameData.SEASONS[_seasonIndex];
  int get dayInSeason => _dayInSeason;

  // --- DIVISION ---
  Map<String, dynamic> get division => GameData.DIVISIONS[_divisionIndex];
  int get divisionIndex => _divisionIndex;
  bool get divisionChosen => _divisionChosen;
  String get divisionName => division['name'] as String;
  String get victoryCondition => division['victory'] as String;
  bool get unionMarketShared => division['unionMarket'] == 'free';
  bool get autoUnion => division['autoUnion'] == true;
  bool get earnsTierWinPoints => division['tierWinPoints'] == true;
  int get tierWinPoints => _tierWinPoints;
  String get rankTier => GameData.rankTierName(_tierWinPoints);
  int? get nextRankThreshold => GameData.nextRankThreshold(_tierWinPoints);

  /// Remaining active playtime in this season, in seconds.
  int get secondsLeftInSeason {
    final intoSeason = _elapsedSeconds % GameData.REAL_SECONDS_PER_SEASON;
    return GameData.REAL_SECONDS_PER_SEASON - intoSeason;
  }

  /// Remaining active playtime in this season, "2d 05:31:07" style.
  String get seasonTimeLeftLabel {
    final s = secondsLeftInSeason;
    final d = s ~/ GameData.REAL_SECONDS_PER_DAY;
    final h = (s % GameData.REAL_SECONDS_PER_DAY) ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    final hms = '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    return d > 0 ? '${d}d $hms' : hms;
  }

  /// Pick a division at the lobby and start a season session.
  /// Rebuild rule: no waitlist — the choice applies immediately.
  /// Re-picking the division already in play resumes it instead of
  /// restarting the season clock.
  void chooseDivision(int index) {
    final next = index.clamp(0, GameData.DIVISIONS.length - 1);
    final sameSession = _divisionChosen && next == _divisionIndex;
    _divisionIndex = next;
    _divisionChosen = true;
    if (!sameSession) {
      _elapsedSeconds = 0;
      _seasonIndex = 0;
      _dayInSeason = 1;
      _secondsSinceSave = 0;
      _gameOver = false;
      _gameWon = false;
      _victoryTitle = '';
      _victoryLines.clear();
      _botSeconds = 0;
      generateMap();
      addLog('Division: $divisionName. Victory: $victoryCondition.');
      _autoAssignUnion();
      _initRivalUnions();
    }
    _currentView = 'map';
    saveGame(silent: true);
    notifyListeners();
  }

  /// Back to the lobby (keeps the save; the season clock keeps its progress).
  void returnToLobby() {
    _currentView = 'lobby';
    notifyListeners();
  }

  int get woundedTroops => _woundedTroops;
  Map<String, int> get troopLevels => Map.unmodifiable(_troopLevels);

  /// Current training level of a troop (1-6, defaults to 1).
  int troopLevel(String id) => _troopLevels[id] ?? 1;

  /// HP/ATK interpolated linearly between Lv.1 base and Lv.6 max.
  Map<String, int> troopStats(String id) {
    final troop = GameData.TROOPS.firstWhere(
      (t) => t['id'] == id,
      orElse: () => {},
    );
    if (troop.isEmpty) return {'hp': 0, 'atk': 0};
    final lvl = troopLevel(id).clamp(1, 6);
    final hp1 = troop['hp'] as int;
    final atk1 = troop['atk'] as int;
    final hp6 = troop['hp6'] as int? ?? hp1;
    final atk6 = troop['atk6'] as int? ?? atk1;
    return {
      'hp': hp1 + ((hp6 - hp1) * (lvl - 1) / 5).round(),
      'atk': atk1 + ((atk6 - atk1) * (lvl - 1) / 5).round(),
    };
  }

  /// Baris pawnAttr untuk level berikutnya (null bila tak ada / max level).
  Map<String, dynamic>? _nextDrillRow(String id) {
    final combatId = BattleEngine.troopCombatIds[id];
    final ladder = combatId == null ? null : GameData.PAWN_LADDER[combatId];
    if (ladder == null) return null;
    final next = troopLevel(id) + 1;
    for (final r in ladder) {
      if (r['lv'] == next) return r;
    }
    return null;
  }

  /// Drill cost for the next level, exactly from pawnAttr.json lv_cost
  /// (`1`=crop, `7`=exp scroll). Falls back to the coefficient synthesis
  /// only for troops with no in-game ladder (weaponry).
  Map<String, int> drillCostFor(String id) {
    final row = _nextDrillRow(id);
    if (row != null) {
      final cost = row['cost'] as Map<String, dynamic>;
      final out = <String, int>{};
      for (final e in cost.entries) {
        final key = e.key == 'expScroll' ? 'exp_scroll' : e.key;
        out[key] = (e.value as num).round();
      }
      return out;
    }
    final lvl = troopLevel(id);
    final troop = GameData.TROOPS.firstWhere(
      (t) => t['id'] == id,
      orElse: () => {},
    );
    final coef = ((troop['coef'] as int?) ?? 50) / 100.0;
    final costMap = troop['cost'] as Map<String, dynamic>? ?? {'crop': 30};
    final baseCrop = (costMap['crop'] as int?) ?? 30;
    return {
      'crop': (baseCrop * coef * (lvl + 1)).round(),
      'exp_scroll': lvl,
    };
  }

  /// Real drill duration in seconds for the next level (0 = instant).
  int drillTimeFor(String id) => (_nextDrillRow(id)?['time'] as int?) ?? 0;

  /// Barrack level required to drill this troop to its next level
  /// (pawnAttr `lv_cond` = `4,<build>,<lv>`).
  int drillGateLevel(String id) {
    final gate = _nextDrillRow(id)?['gate'] as List?;
    return gate == null ? 1 : (gate[2] as int);
  }
  Map<String, Map<String, dynamic>> get plotBuildings => Map.unmodifiable(_plotBuildings);

  // 1000 base + real buildAttr capacity effect (barn id 3, warehouse id 4).
  // Anchors: barn Lv.3->4 = 5700->7400 (+1700) matches the in-game table.
  // Policy type 15 adds flat capacity per building level.
  int get cropCapacity =>
      1000 +
      (GameData.buildingEffects('barn', _capitalBuildings['barn'] ?? 0)[3]?.toInt() ?? 0) +
      (policyEffect(15) * (_capitalBuildings['barn'] ?? 0)).round();
  int get materialCapacity =>
      1000 +
      (GameData.buildingEffects('warehouse', _capitalBuildings['warehouse'] ?? 0)[4]?.toInt() ?? 0) +
      (policyEffect(15) * (_capitalBuildings['warehouse'] ?? 0)).round();

  Map<String, int> get capitalBuildings => Map.unmodifiable(_capitalBuildings);
  Set<String> get conqueredPlots => Set.unmodifiable(_conqueredPlots);
  Map<String, int> get troops => Map.unmodifiable(_troops);
  Map<String, int> get equipment => Map.unmodifiable(_equipment);
  Map<String, String> get exclusiveEquipmentLegacy => Map.unmodifiable(
      {for (var e in _exclusiveEquipment.entries) e.key: _exclusiveSummary(e.key)});
  Map<String, Map<String, dynamic>> get exclusiveEquipment =>
      Map.unmodifiable(_exclusiveEquipment);
  Map<String, Map<String, dynamic>> get capitalGarrison => Map.unmodifiable(_capitalGarrison);
  Set<int> get worshippedHeroes => Set.unmodifiable(_worshippedHeroes);
  Map<int, int> get heroFragments => Map.unmodifiable(_heroFragments);
  Map<int, Map<String, int>> get portraits => Map.unmodifiable(_portraits);
  Map<int, List<int?>> get portraitStrategies => Map.unmodifiable(_portraitStrategies);
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
  List<int> get heroes => _worshippedHeroes.toList();
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

  // Real-time production engine.
  // One season = 3 real days of ACTIVE play; closed/suspended time is not
  // counted. Detection is gap-based: the ticker always runs, and a wall-clock
  // gap larger than [_closedGapSeconds] means the app was closed or frozen.
  static const int _closedGapSeconds = 30;

  void _startRealtimeTicker() {
    _ticker?.cancel();
    _lastTickAt = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    final now = DateTime.now();
    final gap = now.difference(_lastTickAt).inSeconds;
    _lastTickAt = now;
    if (!_divisionChosen) return;
    // Gap > threshold = tab/app was closed/suspended: that wall-clock time is
    // not counted, but an explicit resumeClock() clears the pause flag, so we
    // keep ticking afterward. Clamping (instead of an unconditional return)
    // means a resume is never stuck when no lifecycle event arrives.
    if (_clockPaused || gap > _closedGapSeconds) {
      notifyListeners();
      return;
    }
    if (gap > 0) _advanceClock(gap);
    notifyListeners();
  }

  /// Advance active playtime, rolling days/seasons and granting their rewards.
  void _advanceClock(int seconds) {
    final prevDayAbs =
        _seasonIndex * GameData.DAYS_PER_SEASON + (_dayInSeason - 1);
    _elapsedSeconds += seconds;
    _applyRealtimeProduction(seconds);

    final newSeason =
        (_elapsedSeconds ~/ GameData.REAL_SECONDS_PER_SEASON) % 4;
    final newDay =
        (_elapsedSeconds % GameData.REAL_SECONDS_PER_SEASON) ~/
                GameData.REAL_SECONDS_PER_DAY +
            1;
    final newDayAbs = newSeason * GameData.DAYS_PER_SEASON + (newDay - 1);

    if (newDayAbs != prevDayAbs) {
      _grantDailyRewardPoints();
      if (newSeason != _seasonIndex) {
        final leftWinter = _seasonIndex == 3 && newSeason == 0;
        _seasonIndex = newSeason;
        addLog('Season changed to ${GameData.SEASONS[_seasonIndex]}!');
        if (leftWinter) _onWinterEnd();
        _grantSeasonPolicyGifts();
        if (newSeason == 3) _onWinterStart();
      }
    }
    _dayInSeason = newDay;
    _seasonIndex = newSeason;

    // Bot AI: one move per difficulty tick of active playtime.
    _botSeconds += seconds;
    final botTick = botDifficulty['tick'] as int;
    while (_botSeconds >= botTick && !_gameOver) {
      _botSeconds -= botTick;
      _botTurn();
    }

    _secondsSinceSave += seconds;
    if (_secondsSinceSave >= 30) {
      _secondsSinceSave = 0;
      saveGame(silent: true);
    }
  }

  /// Stop the season clock (app backgrounded) and persist progress.
  /// The ticker keeps running so the clock resumes by itself on return.
  void pauseClock() {
    if (_clockPaused) return;
    _clockPaused = true;
    _lastTickAt = DateTime.now();
    saveGame(silent: true);
  }

  /// Resume the season clock where it left off; closed time is not counted.
  void resumeClock() {
    if (!_clockPaused) return;
    _clockPaused = false;
    _lastTickAt = DateTime.now();
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    notifyListeners();
  }

  /// +50/day, capped at 100 (Battle Guide §5.1).
  void _grantDailyRewardPoints() {
    _rewardPoints = math.min(rewardPointsCap, _rewardPoints + 50);
  }

  /// Policy types 51/52: a fixed grant of scrolls/nails at each season start.
  void _grantSeasonPolicyGifts() {
    final scrollGift = policyEffect(51).round();
    final nailGift = policyEffect(52).round();
    if (scrollGift > 0) _scroll += scrollGift;
    if (nailGift > 0) _nail += nailGift;
    if (scrollGift > 0 || nailGift > 0) {
      addLog('Season policy gift: +$scrollGift Scroll, +$nailGift Nail.');
    }
  }

  // Hourly production rates calculated and applied per second
  Map<String, double> getHourlyProduction() {
    // Base capital tax & production
    final palaceLvl = _capitalBuildings['palace'] ?? 1;
    // Policy type 12 "Panen Melimpah": +N per hour on base production.
    final baseBonus = policyEffect(12);
    double cropHr = 100.0 + (palaceLvl * 15.0) + baseBonus;
    double woodHr = 80.0 + (palaceLvl * 10.0) + baseBonus;
    double stoneHr = 50.0 + (palaceLvl * 8.0) + baseBonus;
    // iron, specials: no production — only from chests

    // Production from Ground Buildings constructed on conquered world plots
    for (var entry in _plotBuildings.entries) {
      final type = entry.value['type'] as String;
      final lvl = entry.value['level'] as int? ?? 1;
      if (type == 'farm') cropHr += lvl * 60.0;
      if (type == 'sawmill') woodHr += lvl * 45.0;
      if (type == 'quarry') stoneHr += lvl * 35.0;
    }

    // Production from conquered plots — nilai dari `common/json/land.json`
    // (data in-game, authoritative): lvl 1 = 1/jam crop+wood+stone sekaligus;
    // lvl 2 = 4, lvl 3 = 7, lvl 4 = 10, lvl 5 = 14 per jam satu resource.
    for (var key in _conqueredPlots) {
      final plot = _plots[key];
      if (plot == null) continue;
      final lvl = plot['level'] as int? ?? 1;
      final landType = plot['landType'] as int? ?? 3;
      final yieldMap = GameData.landYield(landType, lvl);
      cropHr += yieldMap['crop']!;
      woodHr += yieldMap['wood']!;
      stoneHr += yieldMap['stone']!;
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

  void _applyRealtimeProduction(int seconds) {
    final rates = getHourlyProduction();
    _crop += (rates['crop']! / 3600.0) * seconds;
    _wood += (rates['wood']! / 3600.0) * seconds;
    _stone += (rates['stone']! / 3600.0) * seconds;
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

  // Award Chest: drops after every victorious conquest. Chest count and the
  // wood/silver/gold split come straight from landAttr (`treasures_count`,
  // `treasures_lv`); only the per-tier contents are reconstructed.
  Map<String, int> openAwardChest(int plotLvl, {int? attrId}) {
    final rand = math.Random();
    final attr = attrId != null ? GameData.LAND_ATTR[attrId] : null;
    final countRange = ((attr?['count'] as String?) ?? '1,1')
        .split(',')
        .map((s) => int.tryParse(s) ?? 1)
        .toList();
    final countLo = countRange.isNotEmpty ? countRange[0] : 1;
    final countHi = countRange.length > 1 ? countRange[1] : countLo;
    final chests = countLo + rand.nextInt(math.max(1, countHi - countLo + 1));
    final weights = ((attr?['treasures'] as String?) ?? '100,0,0')
        .split(',')
        .map((s) => int.tryParse(s) ?? 0)
        .toList();
    final wWood = weights.isNotEmpty ? weights[0] : 100;
    final wSilver = weights.length > 1 ? weights[1] : 0;
    final wGold = weights.length > 2 ? weights[2] : 0;
    final totalW = math.max(1, wWood + wSilver + wGold);

    final reward = <String, int>{};
    void add(String k, int v) => reward[k] = (reward[k] ?? 0) + v;

    for (int i = 0; i < chests; i++) {
      final roll = rand.nextInt(totalW);
      if (roll < wWood) {
        // Wood chest: basics + a small iron tip.
        add('crop', plotLvl * 60);
        add('wood', plotLvl * 45);
        add('stone', plotLvl * 30);
        add('iron', 1 + rand.nextInt(plotLvl));
      } else if (roll < wWood + wSilver) {
        // Silver chest: iron + EXP scroll.
        add('iron', plotLvl * 2 + rand.nextInt(plotLvl * 2 + 1));
        add('exp_scroll', 1 + rand.nextInt(math.max(1, plotLvl ~/ 2 + 1)));
      } else {
        // Gold chest: scroll / nail (Hard + Hell bonus rate).
        add('iron', plotLvl * 3 + rand.nextInt(plotLvl * 3 + 1));
        if (rand.nextDouble() < 0.5) add('scroll', 1);
        if (rand.nextDouble() < 0.35 + plotLvl * 0.03) {
          add('nail', 1 + (plotLvl >= 4 ? rand.nextInt(2) : 0));
        }
      }
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
  /// All construction requirements for a facility (a facility may need more
  /// than one building, e.g. Union Market = Barn Lv.3 + Warehouse Lv.3).
  List<Map<String, dynamic>> capitalBuildRequirements(String buildingId) {
    final building = GameData.BUILDINGS.firstWhere(
      (b) => b['id'] == buildingId,
      orElse: () => {},
    );
    if (building.isEmpty) return const [];
    final req = building['requires'];
    if (req == null) return const [];
    if (req is List) {
      return req.whereType<Map>().map((r) => Map<String, dynamic>.from(r)).toList();
    }
    return [Map<String, dynamic>.from(req as Map)];
  }

  Map<String, dynamic>? capitalBuildRequirement(String buildingId) {
    final all = capitalBuildRequirements(buildingId);
    if (all.isEmpty) return null;
    for (final req in all) {
      final reqId = req['id'] as String;
      final reqLvl = req['level'] as int? ?? 1;
      if ((_capitalBuildings[reqId] ?? 0) < reqLvl) return req;
    }
    return all.first;
  }

  bool capitalRequirementMet(String buildingId) {
    for (final req in capitalBuildRequirements(buildingId)) {
      final reqId = req['id'] as String;
      final reqLvl = req['level'] as int? ?? 1;
      if ((_capitalBuildings[reqId] ?? 0) < reqLvl) return false;
    }
    return true;
  }

  String capitalRequirementText(String buildingId) {
    final parts = <String>[];
    for (final req in capitalBuildRequirements(buildingId)) {
      final reqId = req['id'] as String;
      final reqLvl = req['level'] as int? ?? 1;
      final reqName = GameData.BUILDINGS.firstWhere(
        (b) => b['id'] == reqId,
        orElse: () => {'name': reqId},
      )['name'];
      final cur = _capitalBuildings[reqId] ?? 0;
      parts.add('$reqName Lv.$reqLvl (now Lv.$cur)');
    }
    return parts.join(' + ');
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
    if (buildingId == 'embassy') _syncUnionBots();
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

  // --- POLICIES: CAPITAL SLOTS, RESEARCH INSTITUTE ---
  /// Sum of one policy effect `type` across all active capital slots.
  /// Each `type` exists in exactly one policy row, so tiers never double-count.
  /// Union policy slots stack on top (design: up to 3x from capital + union
  /// + season policy).
  double policyEffect(int type) {
    double total = 0;
    for (final slot in [..._activePolicies.values, ..._unionPolicies.values]) {
      final p = GameData.policyById(slot['policyId'] ?? 0);
      if (p == null || p['type'] != type) continue;
      total += GameData.policyValue(p, slot['tier'] ?? 0).toDouble();
    }
    return total;
  }

  /// Weighted draw of policies eligible for a new slot: research-gated ones
  /// must be unlocked first, and every `use_cond` building gate must be met.
  List<Map<String, dynamic>> drawPolicyChoices({int count = 3}) {
    final enacted = {
      for (final s in [..._activePolicies.values, ..._unionPolicies.values])
        s['policyId'],
    };
    final pool = GameData.POLICIES.where((p) {
      final id = p['id'] as int;
      if (enacted.contains(id)) return false;
      final weight = (p['weight'] as int?) ?? 0;
      if (weight <= 0) return false;
      if (GameData.POLICY_RESEARCH.containsKey(id) &&
          !_researchedPolicies.contains(id)) {
        return false;
      }
      return GameData.policyGateMet(p, _capitalBuildings);
    }).toList();

    final picks = <Map<String, dynamic>>[];
    final remaining = List<Map<String, dynamic>>.from(pool);
    final rng = math.Random();
    while (picks.length < count && remaining.isNotEmpty) {
      final totalWeight = remaining.fold<int>(
          0, (a, p) => a + ((p['weight'] as int?) ?? 0));
      if (totalWeight <= 0) break;
      var roll = rng.nextInt(totalWeight);
      var idx = 0;
      for (; idx < remaining.length; idx++) {
        roll -= (remaining[idx]['weight'] as int?) ?? 0;
        if (roll < 0) break;
      }
      picks.add(remaining.removeAt(idx.clamp(0, remaining.length - 1)));
    }
    return picks;
  }

  /// Slots must be filled in order (toast `please_unlock_prev_policy`).
  bool canEnactInto(int slot) {
    if (slot < 0 || slot >= policySlots) return false;
    for (int i = 0; i < slot; i++) {
      if (!_activePolicies.containsKey(i)) return false;
    }
    return true;
  }

  /// Enact a policy into [slot] at [tier] (0..2). Fails when the slot is
  /// out of range, an earlier slot is empty, or the policy is ineligible.
  bool enactPolicy(int slot, int policyId, int tier) {
    if (!canEnactInto(slot)) {
      addLog('Policy: Fill the previous slot first.');
      return false;
    }
    final policy = GameData.policyById(policyId);
    if (policy == null) return false;
    if (GameData.POLICY_RESEARCH.containsKey(policyId) &&
        !_researchedPolicies.contains(policyId)) {
      addLog('Policy: ${policy['name']} has not been researched.');
      return false;
    }
    if (!GameData.policyGateMet(policy, _capitalBuildings)) {
      addLog('Policy: ${policy['name']} needs a higher building level.');
      return false;
    }
    final t = tier.clamp(0, ((policy['values'] as List).length - 1));
    _activePolicies[slot] = {'policyId': policyId, 'tier': t};

    // Immediate one-time grants.
    if (policy['type'] == 51) _scroll += 3;
    if (policy['type'] == 52) _nail += 3;

    addLog('Policy enacted: ${policy['name']} (Tier ${t + 1}) — '
        '${GameData.policyDesc(policy, t)}');
    notifyListeners();
    return true;
  }

  /// Free, unlimited reset (rebuild anti-grind rule).
  bool resetPolicySlot(int slot) {
    final removed = _activePolicies.remove(slot);
    if (removed == null) return false;
    final p = GameData.policyById(removed['policyId'] ?? 0);
    addLog('Policy slot ${slot + 1} reset${p == null ? '' : ' (${p['name']} removed)'}.');
    notifyListeners();
    return true;
  }

  /// Research Institute unlock. Gated by capital level (`ceri.json` need_lv),
  /// costs crop/wood/stone, and takes `time` seconds of study.
  bool researchPolicy(int policyId) {
    final row = GameData.POLICY_RESEARCH[policyId];
    if (row == null) return false;
    if (_researchedPolicies.contains(policyId)) return false;
    final needLv = row['needLv'] as int;
    final palaceLvl = _capitalBuildings['palace'] ?? 1;
    if (palaceLvl < needLv) {
      addLog('Research Institute: needs Capital Lv.$needLv.');
      return false;
    }
    final cost = Map<String, int>.from(row['cost'] as Map);
    if (!hasResources(cost)) {
      addLog('Research Institute: insufficient resources.');
      return false;
    }
    spendResources(cost);
    _researchedPolicies.add(policyId);
    final p = GameData.policyById(policyId);
    addLog('Research complete: ${p?['name'] ?? policyId} unlocked '
        '(${row['time']}s study).');
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

    final costMap = GameData.recruitCost(troopId);
    final totalCost = <String, int>{};
    for (var e in costMap.entries) {
      totalCost[e.key] = e.value * count;
    }

    if (!hasResources(totalCost)) {
      addLog('Cannot recruit ${troop['name']}: Insufficient resources.');
      return false;
    }

    spendResources(totalCost);
    _troops[troopId] = (_troops[troopId] ?? 0) + count;
    addLog('Barracks: Recruited $count ${troop['name']} '
        '(${GameData.recruitTime(troopId)}s each).');
    notifyListeners();
    return true;
  }

  // Backwards compatibility method for game_tabs
  void recruitTroop(String troopId, int count) {
    trainTroops(troopId, count);
  }

  // --- SMITHY: CRAFT EQUIPMENT (tier-gated) ---
  bool craftEquipment(String equipmentId) {
    // Common pieces gate on need_build_lv; exclusives use the session gate.
    final item = GameData.equipById(equipmentId);
    if (item == null) {
      final exc = GameData.exclusiveById(equipmentId);
      if (exc == null) return false;
      return _craftExclusive(exc);
    }

    final smithyLvl = _capitalBuildings['smithy'] ?? 0;
    final tier = GameData.equipmentSmithyLevel(item);
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
    _equipment[equipmentId] = (_equipment[equipmentId] ?? 0) + 1;
    final roll = _rollPair((item['atk'] as String?)?.isNotEmpty == true
        ? item['atk'] as String
        : (item['hp'] as String? ?? '0,0'));
    addLog('Smithy: Forged 1x ${item['name']} (roll $roll)!');
    notifyListeners();
    return true;
  }

  /// Forges one exclusive piece: 2 random effects from its own pool + lock.
  bool _craftExclusive(Map<String, dynamic> item) {
    final id = '${item['id']}';
    final blocker = exclusiveForgeBlocker(id);
    if (blocker != null) {
      addLog('Smithy: $blocker');
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
    final effects = _rollExclusiveEffects(item, excludeIds: const {});
    _exclusiveEquipment[id] = {
      'name': item['name'],
      'subtype': item['subtype'],
      'skillIntensify': item['skillIntensify'],
      'effects': effects,
      'locked': -1,
      'smelt': <Map<String, dynamic>>[],
    };
    addLog('Smithy: Forged exclusive ${item['name']}!');
    notifyListeners();
    return true;
  }

  /// Draws `random` effect count out of the piece's own equipBase pool.
  /// The `random` field is "lo,hi"; the game rolls a count in that range.
  List<Map<String, dynamic>> _rollExclusiveEffects(
    Map<String, dynamic> def, {
    required Set<int> excludeIds,
  }) {
    final pool = ((def['effects'] as List?) ?? const [])
        .cast<int>()
        .where((e) => !excludeIds.contains(e))
        .toList()
      ..shuffle(math.Random());
    final counts = ((def['random'] as String?) ?? '2,2').split(',');
    final lo = int.tryParse(counts.first) ?? 2;
    final hi = counts.length > 1 ? (int.tryParse(counts.last) ?? lo) : lo;
    final n = lo + math.Random().nextInt(math.max(1, hi - lo + 1));
    final out = <Map<String, dynamic>>[];
    for (final eid in pool.take(n)) {
      final eff = GameData.EQUIP_EFFECTS[eid];
      if (eff == null) continue;
      final raw = (eff['value'] as String?)?.isNotEmpty == true
          ? eff['value'] as String
          : (eff['odds'] as String? ?? '0,0');
      out.add({'id': eid, 'roll': _rollPair(raw)});
    }
    return out;
  }

  /// One-line summary for save-compat / legacy views.
  String _exclusiveSummary(String id) {
    final p = _exclusiveEquipment[id];
    if (p == null) return '';
    final eff = (p['effects'] as List)
        .map((e) => GameData.equipRolledEffectText((e as Map)['id'] as int))
        .join(' + ');
    return '${p['skillIntensify']} — $eff';
  }

  /// Exclusive recast: rerolls the unlocked random effects (nail-lock keeps one).
  bool recastExclusive(String excId) {
    final piece = _exclusiveEquipment[excId];
    if (piece == null) {
      addLog('Forge the exclusive piece first.');
      return false;
    }
    final def = GameData.exclusiveById(excId);
    if (def == null) return false;
    const cost = {'iron': 20, 'stone': 20};
    if (!hasResources(cost)) {
      addLog('Exclusive recast needs 20 Iron + 20 Stone.');
      return false;
    }
    spendResources(cost);
    final locked = (piece['locked'] as int?) ?? -1;
    final effects = List<Map<String, dynamic>>.from(piece['effects'] as List);
    final lockedIds = <int>{};
    if (locked >= 0 && locked < effects.length) {
      lockedIds.add(effects[locked]['id'] as int);
    }
    final fresh = _rollExclusiveEffects(def, excludeIds: lockedIds);
    for (var i = 0; i < effects.length; i++) {
      if (i == locked) continue;
      if (i < fresh.length) effects[i] = fresh[i];
    }
    piece['effects'] = effects;
    addLog('Smithy: Recast exclusive ${piece['name']}.');
    notifyListeners();
    return true;
  }

  /// Locks one random attr so exclusive recast preserves it (1 nail).
  bool toggleExclusiveLock(String excId, int index) {
    final piece = _exclusiveEquipment[excId];
    if (piece == null) return false;
    final effects = piece['effects'] as List;
    if (index < 0 || index >= effects.length) return false;
    if ((piece['locked'] as int?) == index) {
      piece['locked'] = -1;
      addLog('Smithy: Unlocked effect slot ${index + 1}.');
      notifyListeners();
      return true;
    }
    if (!hasResources({'nail': 1})) {
      addLog('Locking an attr needs 1 Nail.');
      return false;
    }
    spendResources({'nail': 1});
    piece['locked'] = index;
    addLog('Smithy: Locked effect slot ${index + 1} on ${piece['name']}.');
    notifyListeners();
    return true;
  }

  /// Smelts a common piece into an exclusive (destroys the common, 1 nail).
  bool smeltIntoExclusive(String excId, String commonId) {
    final blocker = exclusiveSmeltBlocker(excId);
    if (blocker != null) {
      addLog('Smithy: $blocker');
      return false;
    }
    if ((_equipment[commonId] ?? 0) <= 0) {
      addLog('Nothing to smelt.');
      return false;
    }
    final common = GameData.equipById(commonId);
    if (common == null) return false;
    if (!hasResources({'nail': 1})) {
      addLog('Smelt needs 1 Nail.');
      return false;
    }
    spendResources({'nail': 1});
    _equipment[commonId] = _equipment[commonId]! - 1;
    if (_equipment[commonId]! <= 0) _equipment.remove(commonId);
    final piece = _exclusiveEquipment[excId]!;
    final smelt = List<Map<String, dynamic>>.from(piece['smelt'] as List? ?? []);
    final eid = ((common['effects'] as List?) ?? const []).cast<int>();
    smelt.add({
      'id': common['id'],
      'name': common['name'],
      'effectId': eid.isEmpty ? 0 : eid.first,
    });
    piece['smelt'] = smelt;
    addLog('Smithy: Smelted ${common['name']} into ${piece['name']}!');
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
    final item = GameData.equipById(equipmentId);
    if (item == null) return false;
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
  static const Set<String> _recastableGear = {'6043', '6044'};

  bool recastEquipment(String equipmentId) {
    if (!_recastableGear.contains(equipmentId)) {
      addLog('Only Radiant Plate Armor / Thousand Tempered Blade can be recast.');
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

  // --- PORTRAITS: REPAIR / REDRAW ---
  static const int portraitFragmentCost = 3;

  static Map<String, dynamic>? heroById(int id) {
    for (final h in GameData.HEROES) {
      if (h['id'] == id) return h;
    }
    return null;
  }

  static String heroName(int id, {bool idl = false}) {
    final t = GameData.HERO_TEXT[id];
    if (t == null) return heroById(id)?['name'] as String? ?? 'Hero $id';
    return (idl ? t['nameId'] : t['name']) ?? t['name'] ?? 'Hero $id';
  }

  /// General Muster Terrace: free spin granting 1-3 fragments of a random
  /// hero (original charges coin per spin; rebuild is coin-free by design).
  int? musterFragments({math.Random? rng}) {
    final r = rng ?? math.Random();
    final hero = GameData.HEROES[r.nextInt(GameData.HEROES.length)];
    final id = hero['id'] as int;
    final gained = 1 + r.nextInt(3);
    _heroFragments[id] = fragmentsOf(id) + gained;
    _musterDraws++;
    if (_musterDraws >= musterGuarantee) _musterDraws = 0;
    addLog('Muster Terrace: $gained fragment(s) of ${heroName(id)}.');
    notifyListeners();
    return id;
  }

  /// Draws toward the guaranteed high-multiplier fragment (`20/50` HUD).
  int get musterDraws => _musterDraws;
  static const int musterGuarantee = 50;

  // --- SHOP (offline demo: grants are free, Daily Gift once per day) ---
  bool get dailyGiftClaimed => _dailyGiftClaimed;

  void claimDailyGift() {
    if (_dailyGiftClaimed) return;
    _dailyGiftClaimed = true;
    _addResource('crop', 300);
    _addResource('wood', 300);
    _addResource('stone', 300);
    addLog('Shop: Daily Gift claimed (crop/wood/stone +300).');
    notifyListeners();
  }

  /// Lucky Wheel reward: grant a mixed bundle back into the economy.
  void grantWheelReward(Map<String, int> reward) {
    reward.forEach(_addResource);
    final parts =
        reward.entries.map((e) => '${e.value} ${e.key}').join(', ');
    addLog('Lucky Wheel: $parts.');
    notifyListeners();
  }

  int fragmentsOf(int id) => _heroFragments[id] ?? 0;
  bool hasPortrait(int id) => _portraits.containsKey(id);
  int portraitGrade(int id) => _portraits[id]?['grade'] ?? 0;
  int portraitRedraws(int id) => _portraits[id]?['redraws'] ?? 0;
  int portraitPity(int id) => _portraits[id]?['pity'] ?? 0;

  /// Repair the portrait with 3 fragments (portrayal_desc_5 gate).
  bool repairPortrait(int id) {
    if (hasPortrait(id)) {
      addLog('${heroName(id)} portrait already repaired.');
      return false;
    }
    if (fragmentsOf(id) < portraitFragmentCost) {
      addLog('Repairing ${heroName(id)} needs $portraitFragmentCost fragments.');
      return false;
    }
    _heroFragments[id] = fragmentsOf(id) - portraitFragmentCost;
    _portraits[id] = {'grade': 0, 'redraws': 0, 'pity': 0};
    _portraitStrategies[id] = List<int?>.filled(
        GameData.portraitExpertiseSlots(0), null);
    addLog('Repair Portrait: ${heroName(id)} (${GameData.PORTRAIT_GRADE_LABELS[0]}).');
    notifyListeners();
    return true;
  }

  /// Redraw: reroll all unlocked expertise + a chance of a grade-up
  /// (10% base, pity guarantees it within PORTRAIT_UPGRADE_PITY redraws).
  bool redrawPortrait(int id, {math.Random? rng}) {
    if (!hasPortrait(id)) {
      addLog('Repair the portrait first.');
      return false;
    }
    if (fragmentsOf(id) < portraitFragmentCost) {
      addLog('Redrawing ${heroName(id)} needs $portraitFragmentCost fragments.');
      return false;
    }
    _heroFragments[id] = fragmentsOf(id) - portraitFragmentCost;

    final p = _portraits[id]!;
    final r = rng ?? math.Random();
    final grade = p['grade']!;
    var pity = (p['pity'] ?? 0) + 1;
    var nextGrade = grade;

    if (grade < 7) {
      final pityHit = pity >= GameData.PORTRAIT_UPGRADE_PITY;
      final chanceHit = r.nextDouble() < GameData.PORTRAIT_UPGRADE_CHANCE;
      if (pityHit || chanceHit) {
        nextGrade = grade + 1;
        pity = 0;
        addLog('Portrait upgraded: ${GameData.PORTRAIT_GRADE_LABELS[nextGrade]}!');
      }
    }

    p['grade'] = nextGrade;
    p['redraws'] = (p['redraws'] ?? 0) + 1;
    p['pity'] = pity;
    _rerollStrategies(id, r);
    addLog('Redraw Portrait: ${heroName(id)} (No.${p['redraws']}).');
    notifyListeners();
    return true;
  }

  /// Reroll every unlocked slot from the hero pool (portrayal_desc_2).
  /// Slot rarity follows the unlock order: Common, Uncommon, Rare, Rare.
  void _rerollStrategies(int id, math.Random r) {
    final hero = heroById(id);
    final pool = ((hero?['strategy'] as List?) ?? const []).cast<int>();
    final slots = GameData.portraitExpertiseSlots(portraitGrade(id));
    final next = <int?>[];
    final used = <int>{};
    for (var i = 0; i < slots; i++) {
      final rarity = i < 3 ? i + 1 : 3;
      final candidates = [
        for (final sid in pool)
          if ((GameData.STRATEGIES[sid]?['lv'] as int?) == rarity &&
              !used.contains(sid))
            sid,
      ];
      if (candidates.isEmpty) {
        next.add(null);
        continue;
      }
      final pick = candidates[r.nextInt(candidates.length)];
      next.add(pick);
      used.add(pick);
    }
    _portraitStrategies[id] = next;
  }

  /// Expertise rows currently equipped on a portrait, resolved for display.
  List<Map<String, dynamic>> portraitExpertise(int id) {
    final slots = _portraitStrategies[id] ?? const <int?>[];
    return [
      for (final sid in slots)
        if (sid != null && GameData.STRATEGIES[sid] != null)
          {'id': sid, ...GameData.STRATEGIES[sid]!},
    ];
  }

  /// Hero skill value at the portrait's current grade (8-entry ladder).
  int heroSkillValue(int id) {
    final hero = heroById(id);
    final skill = GameData.HERO_SKILLS[hero?['skill']];
    final values = (skill?['values'] as List?)?.cast<int>();
    if (values == null || values.isEmpty) return 0;
    return values[portraitGrade(id).clamp(0, values.length - 1)];
  }

  /// Hero skill value as a fractional DMG bonus, but only for skills whose
  /// text scales active-skill damage ("*ATK"); others use it for utility.
  double heroSkillDamagePct(int id) {
    final hero = heroById(id);
    final skillId = (hero?['skill'] as num?)?.toInt();
    if (skillId == null || !GameData.HERO_SKILL_DAMAGE_SCALE.contains(skillId)) {
      return 0;
    }
    return heroSkillValue(id) / 100;
  }

  /// Skill multiplier the hero's own active skill rolls at (pawnSkill.value).
  /// Lv.1..6 of the sub-type active skill maps 1.0 -> 1.5 for Stab etc.
  double heroActiveSkillMultiplier(int id) {
    final hero = heroById(id);
    final pawn = (hero?['pawn'] as num?)?.toInt();
    if (pawn == null) return 1.0;
    return GameData.activeSkillMultiplier('$pawn');
  }

  /// Exclusive skill_intensify for the hero's sub-type, if one is forged.
  /// Returns {'skillId': int, 'level': int} or null.
  Map<String, int>? _exclusiveSkillIntensify(int heroId) {
    final hero = heroById(heroId);
    final pawn = (hero?['pawn'] as num?)?.toInt();
    if (pawn == null) return null;
    for (final entry in _exclusiveEquipment.entries) {
      final piece = entry.value;
      final def = GameData.exclusiveById(entry.key);
      if (def == null || (def['pawn'] as num?)?.toInt() != pawn) continue;
      final raw = (piece['skillIntensify'] as String?) ?? '';
      final parts = raw.split(',');
      if (parts.length != 2) return null;
      return {
        'skillId': int.tryParse(parts[0]) ?? 0,
        'level': int.tryParse(parts[1]) ?? 1,
      };
    }
    return null;
  }

  /// Chosen portraits may hand-pick each expertise slot (1 Common, 1 Uncommon,
  /// 2 Rare). Lower grades are roll-only, so this is a no-op for them.
  bool pickExpertise(int heroId, int slotIdx, int strategyId) {
    if (portraitGrade(heroId) != 7) {
      addLog('Manual Expertise pick needs the Chosen portrait.');
      return false;
    }
    final hero = heroById(heroId);
    final pool = ((hero?['strategy'] as List?) ?? const []).cast<int>();
    if (!pool.contains(strategyId)) {
      addLog('That Expertise is not in this hero\'s pool.');
      return false;
    }
    final slots = _portraitStrategies[heroId] ?? <int?>[];
    if (slotIdx < 0 || slotIdx >= slots.length) return false;
    final wantRarity = slotIdx < 3 ? slotIdx + 1 : 3;
    final row = GameData.STRATEGIES[strategyId];
    if ((row?['lv'] as int?) != wantRarity) {
      addLog('Slot ${slotIdx + 1} only takes '
          '${GameData.STRATEGY_RARITY_NAMES[wantRarity - 1]} Expertise.');
      return false;
    }
    slots[slotIdx] = strategyId;
    _portraitStrategies[heroId] = slots;
    addLog('Chosen: ${GameState.heroName(heroId)} expertise slot ${slotIdx + 1} set.');
    notifyListeners();
    return true;
  }

  /// Number of times an expertise id is equipped on the portrait (stack cap
  /// comes from `strategy.overlay`: Common 3, Uncommon 2, Rare 1).
  int expertiseStacks(int id, int strategyId) {
    final slots = _portraitStrategies[id] ?? const <int?>[];
    return slots.where((s) => s == strategyId).length;
  }

  // --- HALL OF HEROES: WORSHIP HERO ---
  /// Worship slots open at hall levels 1/5/10/20 (4 slots).
  static const List<int> worshipSlotLevels = [1, 5, 10, 20];

  int get worshipSlots {
    final lvl = _capitalBuildings['hall_of_heroes'] ?? 0;
    var n = 0;
    for (final need in worshipSlotLevels) {
      if (lvl >= need) n++;
    }
    return n;
  }

  /// A hero once worshipped is permanently bound for this campaign.
  bool worshipHero(int heroId) {
    if (_worshippedHeroes.contains(heroId)) {
      addLog('Hero already worshipped.');
      return false;
    }
    final hero = heroById(heroId);
    if (hero == null) return false;
    if (!hasPortrait(heroId)) {
      addLog('Repair ${heroName(heroId)}\'s portrait first.');
      return false;
    }
    if (_worshippedHeroes.length >= worshipSlots) {
      addLog('Hall of Heroes has $worshipSlots worship slot(s). '
          'Upgrade it to worship more heroes.');
      return false;
    }

    final cost = {'stone': 100, 'wood': 50};
    if (!hasResources(cost)) {
      addLog('Need 100 Stone & 50 Wood to worship ${heroName(heroId)}.');
      return false;
    }

    spendResources(cost);
    _worshippedHeroes.add(heroId);
    addLog('Hall of Heroes: ${heroName(heroId)} has been Worshipped into active command!');
    notifyListeners();
    return true;
  }

  bool unworshipHero(int heroId) {
    if (!_worshippedHeroes.remove(heroId)) return false;
    addLog('Hall of Heroes: ${heroName(heroId)} released.');
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

  // --- DRILL GROUND: TRAIN ONE TROOP one level (1->6) ---
  // Weaponry cannot be trained. Cost: coef-scaled crop + exp_scrolls;
  // a 'scroll' item instantly grants one level without resource cost.
  bool drillTroop(String troopId) {
    final lvl = troopLevel(troopId);
    if (lvl >= 6) {
      addLog('Drill Ground: $troopId is already max level (6).');
      return false;
    }
    if (troopId == 'catapult' || troopId == 'trebuchet') {
      addLog('Drill Ground: Weaponry cannot be trained.');
      return false;
    }
    final gate = drillGateLevel(troopId);
    final barrack = _capitalBuildings['barracks'] ?? 0;
    if (barrack < gate) {
      addLog('Drill Ground: Needs Barrack Lv.$gate (now Lv.$barrack).');
      return false;
    }
    final cost = drillCostFor(troopId);
    if (!hasResources(cost)) {
      addLog('Drill Ground: Need ${cost['crop']} Crop & ${cost['exp_scroll']} EXP Scroll(s) to train $troopId to Lv.${lvl + 1}.');
      return false;
    }
    spendResources(cost);
    _troopLevels[troopId] = lvl + 1;
    addLog('Drill Ground: $troopId trained to Lv.${lvl + 1}.');
    notifyListeners();
    return true;
  }

  /// Instant level-up consuming one 'scroll' item instead of crop+exp_scroll.
  bool drillTroopInstant(String troopId) {
    final lvl = troopLevel(troopId);
    if (lvl >= 6) return false;
    if (troopId == 'catapult' || troopId == 'trebuchet') {
      addLog('Drill Ground: Weaponry cannot be trained.');
      return false;
    }
    if (_scroll <= 0) {
      addLog('Drill Ground: Need 1 Scroll for instant training.');
      return false;
    }
    _scroll -= 1;
    _troopLevels[troopId] = lvl + 1;
    addLog('Drill Ground: $troopId instantly trained to Lv.${lvl + 1} (Scroll).');
    notifyListeners();
    return true;
  }

  // --- UNION MARKET: MERCHANT-BORNE BARTER ---
  /// Merchant count for a trade channel ('market' or 'union_market').
  int tradeMerchantsFor(String buildingId) =>
      GameData.unionMarketMerchants(_capitalBuildings[buildingId] ?? 1);

  /// Exchange rate from a market ladder (75% base + 5%/level, 95% cap).
  double marketRateFor(String buildingId) =>
      math.min(0.95, 0.70 + ((_capitalBuildings[buildingId] ?? 1) * 0.05));

  /// Union membership gate. The Union Market needs a union; the Free Market
  /// (Free division) and the personal Market do not.
  bool get unionMarketNeedsUnion => !unionMarketShared && !_unionJoined;

  bool marketTrade(String fromRes, String toRes, int amount,
      {String buildingId = 'market'}) {
    if ((_capitalBuildings[buildingId] ?? 0) <= 0) {
      addLog('Market: build the facility first.');
      return false;
    }
    if (buildingId == 'union_market' && unionMarketNeedsUnion) {
      addLog('Union Market: join a union to trade.');
      return false;
    }
    const basics = {'crop', 'wood', 'stone'};
    const specials = {'iron', 'exp_scroll', 'scroll', 'nail'};
    final fromBasic = basics.contains(fromRes);
    final toBasic = basics.contains(toRes);
    if ((!fromBasic && !specials.contains(fromRes)) ||
        (!toBasic && !specials.contains(toRes))) {
      return false;
    }
    if (fromBasic != toBasic) {
      addLog('Market: basics and chest specials trade only within their own tier.');
      return false;
    }
    if (amount <= 0 || fromRes == toRes) return false;
    final merchants = tradeMerchantsFor(buildingId);
    final cap = fromBasic
        ? merchants * GameData.MERCHANT_BASIC_CAP
        : merchants * GameData.MERCHANT_SPECIAL_CAP;
    if (amount > cap) {
      addLog('Market: $merchants merchant(s) can carry at most $cap per shipment.');
      return false;
    }
    final cost = {fromRes: amount};
    if (!hasResources(cost)) {
      addLog('Market: Insufficient $fromRes to exchange.');
      return false;
    }
    spendResources(cost);
    final rate = marketRateFor(buildingId);
    final received = math.max(1, (amount * rate).round());

    switch (toRes) {
      case 'crop': _crop += received; break;
      case 'wood': _wood += received; break;
      case 'stone': _stone += received; break;
      case 'iron': _iron += received; break;
      case 'exp_scroll': _expScroll += received; break;
      case 'scroll': _scroll += received; break;
      case 'nail': _nail += received; break;
      default: break;
    }
    final rateLabel = fromBasic ? 'Rate: ${(rate * 100).toInt()}%' : 'Barter 1:1';
    addLog('Market: Exchanged $amount ${fromRes.toUpperCase()} for $received ${toRes.toUpperCase()} ($rateLabel, $merchants merchant(s)).');
    notifyListeners();
    return true;
  }

  // --- GROUND BUILDINGS: CONSTRUCT & UPGRADE ON CONQUERED PLOTS ONLY ---
  Map<String, dynamic>? getGroundBuilding(int row, int col) {
    return _plotBuildings['$row,$col'];
  }

  /// Ground building that fits this plot by default: Farm/Sawmill/Quarry on a
  /// matching resource plot, Fortress as the universal option.
  String defaultGroundBuildingType(int row, int col) {
    final resType = _plots['$row,$col']?['resource'] as String? ?? 'crop';
    if (resType == 'wood') return 'sawmill';
    if (resType == 'stone' || resType == 'iron') return 'quarry';
    return 'farm';
  }

  bool constructGroundBuilding(int row, int col, {String? type}) {
    final key = '$row,$col';
    if (!isTileConquered(row, col) || isCapitalTile(row, col)) {
      addLog('Ground facilities can only be constructed on conquered territory.');
      return false;
    }
    if (_plotBuildings.containsKey(key)) {
      addLog('A ground facility already exists on this plot.');
      return false;
    }

    final buildingType = type ?? defaultGroundBuildingType(row, col);
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

  /// Production buildings cap at Lv.5 per category (CLAUDE.md); the Fortress
  /// goes to Lv.20.
  int groundBuildingMaxLevel(String type) =>
      type == 'fortress' ? 20 : 5;

  bool upgradeGroundBuilding(int row, int col) {
    final key = '$row,$col';
    final existing = _plotBuildings[key];
    if (existing == null) return false;

    final buildingType = existing['type'] as String;
    final curLevel = existing['level'] as int? ?? 1;
    final maxLevel = groundBuildingMaxLevel(buildingType);
    if (curLevel >= maxLevel) {
      addLog('Ground Facility: ${buildingType.toUpperCase()} already at max level $maxLevel.');
      return false;
    }
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

  // --- FORTRESS: STATS & FIELD HEAL ---
  /// Watchtower replacement stats. A plot without a fortress keeps the plain
  /// Watchtower (HP 40 / ATK 12); a fortress scales +80 HP / +16 ATK per level.
  Map<String, int> plotTowerStats(int row, int col) {
    final b = _plotBuildings['$row,$col'];
    if (b == null || b['type'] != 'fortress') {
      return {'hp': 40, 'atk': 12};
    }
    final lvl = b['level'] as int? ?? 1;
    return {'hp': 80 + (lvl - 1) * 80, 'atk': 16 + (lvl - 1) * 16};
  }

  /// Heals wounded soldiers that reach a fortress plot. Fortress levels raise
  /// the share of the wounded pool it can recover at once.
  bool fieldHealAtFortress(int row, int col) {
    final b = _plotBuildings['$row,$col'];
    if (b == null || b['type'] != 'fortress') return false;
    if (_woundedTroops <= 0) return false;
    final lvl = b['level'] as int? ?? 1;
    final heal = math.min(_woundedTroops, 3 + lvl);
    _woundedTroops -= heal;
    _troops['longspearman'] = (_troops['longspearman'] ?? 0) + heal;
    addLog('Fortress: Field-healed $heal wounded soldiers at ($row, $col).');
    notifyListeners();
    return true;
  }

  // --- TURN-BASED GRID COMBAT (Battle Guide §4) ---
  // Simulasi 11x11: stack penyerang di gerbang, unit bergerak hanya bila
  // tidak ada musuh dalam jangkauan, urutan aksi ATK SPD, rage naik saat
  // menyerang/diserang. Logika di BattleEngine; casualty & chest di sini.
  /// Susun stack penyerang dari inventori + equipment + hero + policy.
  List<BattleUnit> _playerAttackers(int gateIndex) {
    // Equipment Damage Reduction: Iron Shield (equip 6022) rolls Melee DMG
    // -[10-35]%, Rattan Shield (6014) rolls Ranged DMG -[30-60]%. Use the
    // lower bound of each roll so the demo never overstates mitigation.
    double defMult = 1.0;
    if ((_equipment['6022'] ?? 0) > 0) defMult *= 1 - 0.10;
    if ((_equipment['6014'] ?? 0) > 0) defMult *= 1 - 0.30;

    final heroes = [
      for (final id in _worshippedHeroes)
        if (heroById(id) != null)
          {
            ...heroById(id)!,
            'grade': portraitGrade(id),
            'expertise': [for (final s in portraitExpertise(id)) s['id'] as int],
            'skillValue': heroSkillDamagePct(id),
            'exclusive': _exclusiveSkillIntensify(id),
          },
    ];

    final polMods = _battlePolicyMods();
    return BattleEngine.buildPlayerUnits(
      troops: _troops,
      troopLevels: _troopLevels,
      gateIndex: gateIndex,
      heroes: heroes,
      bonusDr: 1.0 - defMult,
      hpFlatPerLevel: polMods['hpFlatPerLevel'] as int,
      atkFlatPerLevel: polMods['atkFlatPerLevel'] as int,
      hpPctByTroop: polMods['hpPctByTroop'] as Map<String, double>,
      atkPctByTroop: polMods['atkPctByTroop'] as Map<String, double>,
      hpPctByType: polMods['hpPctByType'] as Map<String, double>,
      atkPctByType: polMods['atkPctByType'] as Map<String, double>,
      drByType: polMods['drByType'] as Map<String, double>,
      leapStacks: _leapStacks,
    );
  }

  /// Clinic wounded rate: 55% of casualties survive as wounded after a win,
  /// 50% after a loss — the remainder are dead. Pure so it stays testable.
  static double clinicWoundedRate(bool victory) => victory ? 0.55 : 0.50;

  /// Wounded survivors for [lost] casualties in a battle resolved as
  /// [victory]. Rounded to whole soldiers.
  static int clinicWounded(int lost, bool victory) =>
      (lost * clinicWoundedRate(victory)).round();

  /// Terapkan korban ke inventori; kembalikan jumlah wounded (Clinic).
  /// Unit pemain memakai uid == pawnBase id, jadi lookup langsung.
  int _applyCasualties(BattleResult result) {
    final uidToTroop = <String, String>{};
    for (final uid in result.attackerStart.keys) {
      final troopId = BattleEngine.troopCombatIds.entries
          .firstWhere((e) => e.value == uid,
              orElse: () => const MapEntry('', ''))
          .key;
      if (troopId.isNotEmpty) uidToTroop[uid] = troopId;
    }
    int totalLost = 0;
    result.attackerLosses.forEach((uid, lost) {
      final troopId = uidToTroop[uid];
      if (troopId == null) return;
      final cur = _troops[troopId] ?? 0;
      final take = math.min(cur, lost);
      _troops[troopId] = cur - take;
      totalLost += take;
    });

    final newlyWounded = clinicWounded(totalLost, result.victory);
    _woundedTroops += newlyWounded;
    return newlyWounded;
  }

  Map<String, dynamic> attackPlot(int row, int col) {
    final key = '$row,$col';
    if (isTileConquered(row, col)) {
      return {'victory': false, 'reason': 'Tile already controlled.'};
    }

    final plot = _plots[key];
    final int plotLvl = plot?['level'] as int? ?? 1;
    final String enemyName = plot?['garrisonName'] as String? ?? 'Wild Beasts';
    final int landType = plot?['landType'] as int? ?? 3;

    final totalTroops = _troops.values.fold<int>(0, (a, b) => a + (b > 0 ? b : 0));
    if (totalTroops <= 0) {
      addLog('Battle failed: You have no active soldiers in your army!');
      return {'victory': false, 'reason': 'No troops available.'};
    }

    final dist = math.sqrt(
      math.pow(row - 39.5, 2) + math.pow(col - 39.5, 2),
    );

    final rng = math.Random();
    final gateIndex = _approachGate(row, col);

    final attackers = _playerAttackers(gateIndex);
    final defenders = BattleEngine.buildEnemyUnits(
      attrId: plot?['attrId'] as int? ?? GameData.landAttrFor(plotLvl, dist),
      landType: landType,
      rng: rng,
    );

    final result = BattleEngine.simulate(
      attackers: attackers,
      defenders: defenders,
      rng: rng,
    );

    final newlyWounded = _applyCasualties(result);
    _gainLeapStacks(_boarKnightKills(result, defenders));
    // A fortress at the plot heals wounded troops that reach it.
    if (getGroundBuilding(row, col)?['type'] == 'fortress') {
      fieldHealAtFortress(row, col);
    }

    Map<String, int>? reward;
    if (result.victory) {
      _conqueredPlots.add(key);
      reward = openAwardChest(plotLvl, attrId: plot?['attrId'] as int?);
      final rewardText =
          reward.entries.map((e) => '+${e.value} ${_resLabel(e.key)}').join(', ');
      String tierText = '';
      if (earnsTierWinPoints) {
        final gain = plotLvl * GameData.TIER_POINTS_PER_PLOT_LEVEL;
        final before = GameData.rankTierName(_tierWinPoints);
        _tierWinPoints += gain;
        final after = GameData.rankTierName(_tierWinPoints);
        tierText = ' +$gain Tier Win'
            ' ($_tierWinPoints${before != after ? ', $after' : ''}).';
      }
      addLog('Victory at ($row, $col)! Flag claimed after ${result.rounds} rounds. '
          'Conquered $enemyName (Level $plotLvl). $newlyWounded wounded (Clinic). '
          'Award Chest: $rewardText.$tierText');
    } else {
      addLog('Defeat at ($row, $col) after ${result.rounds} rounds! Army repelled. '
          '$newlyWounded wounded (Clinic).');
    }

    // Battle report entry (target label comes from plot level+resource).
    final int startCount = result.attackerStart.length;
    int kills = 0;
    int fallen = 0;
    result.defenderLosses.forEach((_, n) => kills += n);
    result.attackerLosses.forEach((_, n) => fallen += n);
    final String targetLabel = plotLvl <= 1
        ? 'Wasteland($row,$col)'
        : '${_resTitle(_plots[key]?['resource'] as String? ?? 'crop')} '
            'Plot($row,$col)';
    _battleReports.insert(0, {
      'time': DateTime.now(),
      'victory': result.victory,
      'row': row,
      'col': col,
      'targetLabel': targetLabel,
      'rounds': result.rounds,
      'kills': kills,
      'fallen': fallen,
      'armies': startCount,
      'wounded': newlyWounded,
    });
    if (_battleReports.length > 50) _battleReports.removeLast();

    notifyListeners();

    return {
      'victory': result.victory,
      'enemyName': enemyName,
      'plotLevel': plotLvl,
      'rounds': result.rounds,
      'events': result.events,
      'frames': result.frames,
      'attackerStart': result.attackerStart,
      'attackerLosses': result.attackerLosses,
      'defenderLosses': result.defenderLosses,
      'wounded': newlyWounded,
      'reward': reward,
    };
  }

  /// Label pendek resource → kata judul untuk battle report.
  String _resTitle(String id) =>
      id == 'wood' ? 'Wood' : (id == 'stone' ? 'Stone' : 'Crop');

  /// Gerbang masuk army: sisi terdekat dengan capital.
  int _approachGate(int row, int col) {
    final dr = row - capitalMinRow;
    final dc = col - capitalMinCol;
    if (dr.abs() >= dc.abs()) return dr >= 0 ? 0 : 1; // north : south
    return dc >= 0 ? 2 : 3; // west : east
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
      'rounds': res['rounds'] ?? 0,
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

        // Plot Level 1 to 5 — five even 2-tile bands out to the 12-tile cap.
        int plotLvl = 1;
        if (cappedDist >= 10.0) {
          plotLvl = 5;
        } else if (cappedDist >= 8.0) {
          plotLvl = 4;
        } else if (cappedDist >= 6.0) {
          plotLvl = 3;
        } else if (cappedDist >= 4.0) {
          plotLvl = 2;
        }

        // Plot Resource type based on terrain
        final terrain = _map[r][c];
        String resType = 'crop';
        if (terrain == GameData.TILE_FOREST) resType = 'wood';
        // Sand dunes yield stone (quarry output); iron is chest-only special.
        if (terrain == GameData.TILE_MOUNTAIN || terrain == GameData.TILE_SAND) resType = 'stone';

        // Real garrison + difficulty from landAttr.json: the farther from the
        // capital, the harder the row picked inside the plot level's band.
        final attrId = GameData.landAttrFor(plotLvl, cappedDist);
        final attr = GameData.LAND_ATTR[attrId]!;
        final uiLv = attr['uiLv'] as int;
        final landType = resType == 'crop' ? 3 : (resType == 'wood' ? 4 : 5);

        _plots['$r,$c'] = {
          'level': plotLvl,
          'resource': resType,
          'landType': landType,
          'landId': GameData.landIdFor(landType, plotLvl),
          'attrId': attrId,
          'garrisonName': GameData.landGarrisonName(attrId, landType),
          'difficulty': GameData.landDifficultyName(uiLv),
        };
      }
    }

    // Remains: neutral 2x2 capitals. Their tiles are neither wild plots nor
    // player territory; the interior is the same 17x17 capital layout.
    _initRemains();
    for (final r in _remains.values) {
      final rr = r['row'] as int;
      final cc = r['col'] as int;
      for (int dr = 0; dr <= 1; dr++) {
        for (int dc = 0; dc <= 1; dc++) {
          final tr = rr + dr;
          final tc = cc + dc;
          if (tr >= 0 && tr < GameData.MAP_HEIGHT &&
              tc >= 0 && tc < GameData.MAP_WIDTH) {
            _map[tr][tc] = GameData.TILE_GRASS;
            _plots.remove('$tr,$tc');
          }
        }
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

  // Next turn compatibility: advances the season clock by one full day.
  void nextTurn() {
    _advanceClock(GameData.REAL_SECONDS_PER_DAY);
    notifyListeners();
  }

  // Persistence lives in game_save_codec.dart (GameStateSaveCodec).

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
