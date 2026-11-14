part of 'game_state.dart';

const String kSaveKey = 'nta_save_state_v2';

// Persistence for GameState: JSON encode/decode, the shared_preferences
// round-trip, and the tolerant legacy-save loader.
//
// Legacy saves arrive from three places — old shared_preferences payloads,
// hand-staged browser snapshots, and the demo's own previous builds — so
// every field is read through typed helpers instead of raw casts. A
// malformed entry is skipped rather than aborting the whole restore.

extension GameStateSaveCodec on GameState {
  // --- typed readers: a wrong type in a legacy save must not abort loading ---

  static double numOr(Object? v, double fallback) => v is num
      ? v.toDouble()
      : (v is String ? (double.tryParse(v) ?? fallback) : fallback);

  static int intOr(Object? v, int fallback) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static String strOr(Object? v, String fallback) =>
      v is String ? v : (v == null ? fallback : v.toString());

  static bool boolOr(Object? v, bool fallback) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is num) return v != 0;
    return fallback;
  }

  static Map<String, dynamic> mapOr(Object? v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  // --- SAVE ---

  Map<String, dynamic> toSaveMap() => {
        'crop': _crop,
        'wood': _wood,
        'stone': _stone,
        'iron': _iron,
        'exp_scroll': _expScroll,
        'scroll': _scroll,
        'nail': _nail,
        'woundedTroops': _woundedTroops,
        'rewardPoints': _rewardPoints,
        'elapsedSeconds': _elapsedSeconds,
        'seasonIndex': _seasonIndex,
        'dayInSeason': _dayInSeason,
        'divisionIndex': _divisionIndex,
        'divisionChosen': _divisionChosen,
        'tierWinPoints': _tierWinPoints,
        'botDifficultyIndex': _botDifficultyIndex,
        'botSeconds': _botSeconds,
        'currentView': _currentView,
        'capitalBuildings': _capitalBuildings,
        'conqueredPlots': _conqueredPlots.toList(),
        'plotBuildings': _plotBuildings,
        'troops': _troops,
        'equipment': _equipment,
        'exclusiveEquipment': _exclusiveEquipment,
        'recastCounts': _recastCounts,
        'heroFragments': {
          for (final e in _heroFragments.entries) e.key.toString(): e.value,
        },
        'portraits': {
          for (final e in _portraits.entries) e.key.toString(): e.value,
        },
        'portraitStrategies': {
          for (final e in _portraitStrategies.entries) e.key.toString(): e.value,
        },
        'worshippedHeroes': _worshippedHeroes.toList(),
        'capitalGarrison': _capitalGarrison,
        'troopLevels': _troopLevels,
        'activePolicies': {
          for (final e in _activePolicies.entries) e.key.toString(): e.value,
        },
        'researchedPolicies': _researchedPolicies.toList(),
        'unionJoined': _unionJoined,
        'unionName': _unionName,
        'unionIsLeader': _unionIsLeader,
        'unionMembers': _unionMembers,
        'unionPolicies': {
          for (final e in _unionPolicies.entries) e.key.toString(): e.value,
        },
        'remains': {
          for (final e in _remains.entries) e.key.toString(): e.value,
        },
        'rivalUnions': _rivalUnions,
        'gameOver': _gameOver,
        'gameWon': _gameWon,
        'victoryTitle': _victoryTitle,
        'victoryLines': _victoryLines,
        'log': _log,
      };

  Future<void> saveGame({bool silent = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kSaveKey, jsonEncode(toSaveMap()));
      if (!silent) addLog('Game state saved locally.');
    } catch (e) {
      addLog('Save failed: $e');
    }
  }

  // --- LOAD ---

  Future<bool> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(kSaveKey);
      if (str == null) return false;

      final data = jsonDecode(str);
      if (data is! Map) return false;
      await loadFromMap(Map<String, dynamic>.from(data));
      addLog('Game loaded successfully.');
      _notifyAfterRestore();
      return true;
    } catch (e, st) {
      debugPrint('loadGame failed: $e\n$st');
      addLog('Load failed: $e');
      return false;
    }
  }

  /// Restore state from an already-decoded save map.
  ///
  /// Split out of [loadGame] so the demo can rebuild state from a snapshot
  /// handed over by `window` (web) without round-tripping through
  /// shared_preferences, whose legacy-typed payloads can trip the loader.
  Future<void> loadFromMap(Map<String, dynamic> data) async {
    _crop = numOr(data['crop'], 1000.0);
    _wood = numOr(data['wood'], 800.0);
    _stone = numOr(data['stone'], 600.0);
    _iron = intOr(data['iron'], 20);
    _expScroll = intOr(data['exp_scroll'], 0);
    _scroll = intOr(data['scroll'], 0);
    _nail = intOr(data['nail'], 0);
    _woundedTroops = intOr(data['woundedTroops'], 0);
    _rewardPoints = intOr(data['rewardPoints'], GameState.rewardPointsCap);
    _elapsedSeconds = intOr(data['elapsedSeconds'], 0);
    _seasonIndex = intOr(data['seasonIndex'], 0).clamp(0, 3);
    _dayInSeason = intOr(data['dayInSeason'], 1);
    _divisionIndex =
        intOr(data['divisionIndex'], 0).clamp(0, GameData.DIVISIONS.length - 1);
    _divisionChosen = boolOr(data['divisionChosen'], false);
    _tierWinPoints = intOr(data['tierWinPoints'], 0);
    _botDifficultyIndex = intOr(data['botDifficultyIndex'], 1)
        .clamp(0, GameData.BOT_DIFFICULTIES.length - 1);
    _botSeconds = intOr(data['botSeconds'], 0);
    // Lobby is the entry screen until a division has been picked.
    _currentView =
        _divisionChosen ? strOr(data['currentView'], 'map') : 'lobby';

    _capitalBuildings.clear();
    mapOr(data['capitalBuildings'])
        .forEach((k, v) => _capitalBuildings[k] = intOr(v, 0));

    _conqueredPlots.clear();
    if (data['conqueredPlots'] is List) {
      for (final p in data['conqueredPlots'] as List) {
        _conqueredPlots.add(p.toString());
      }
    }

    _plotBuildings.clear();
    mapOr(data['plotBuildings']).forEach((k, v) {
      if (v is Map) _plotBuildings[k] = Map<String, dynamic>.from(v);
    });

    // Legacy saves held old unit/gear ids — drop ids no longer in the roster.
    _troops.clear();
    final validTroopIds = GameData.TROOPS.map((t) => t['id'] as String).toSet();
    mapOr(data['troops']).forEach((k, v) {
      if (validTroopIds.contains(k)) _troops[k] = intOr(v, 0);
    });

    _equipment.clear();
    // Exclusive pieces live only in _exclusiveEquipment now, not _equipment.
    final validGear = GameData.EQUIP_MASTER.map((e) => '${e['id']}').toSet();
    mapOr(data['equipment']).forEach((k, v) {
      if (validGear.contains(k)) _equipment[k] = intOr(v, 0);
    });

    _exclusiveEquipment.clear();
    // New shape: {id: {hp, atk, effects, locked, smelt, ...}}.
    // Legacy string saves (v2 text): skip — piece must be reforged.
    mapOr(data['exclusiveEquipment']).forEach((k, v) {
      if (v is! Map) return;
      final m = Map<String, dynamic>.from(v);
      m['locked'] = intOr(m['locked'], -1);
      m['effects'] = [
        for (final e in (m['effects'] is List ? m['effects'] as List : const []))
          if (e is Map) Map<String, dynamic>.from(e),
      ];
      m['smelt'] = [
        for (final e in (m['smelt'] is List ? m['smelt'] as List : const []))
          if (e is Map) Map<String, dynamic>.from(e),
      ];
      _exclusiveEquipment[k] = m;
    });

    _recastCounts.clear();
    mapOr(data['recastCounts'])
        .forEach((k, v) => _recastCounts[k] = intOr(v, 0));

    _heroFragments.clear();
    mapOr(data['heroFragments']).forEach((k, v) {
      final id = int.tryParse(k);
      if (id != null) _heroFragments[id] = intOr(v, 0);
    });

    _portraits.clear();
    mapOr(data['portraits']).forEach((k, v) {
      final id = int.tryParse(k);
      if (id == null || v is! Map) return;
      final m = Map<String, dynamic>.from(v);
      _portraits[id] = {
        'grade': intOr(m['grade'], 0).clamp(0, 7),
        'redraws': intOr(m['redraws'], 0),
        'pity': intOr(m['pity'], 0),
      };
    });

    _portraitStrategies.clear();
    mapOr(data['portraitStrategies']).forEach((k, v) {
      final id = int.tryParse(k);
      if (id == null || v is! List) return;
      _portraitStrategies[id] = [
        for (final s in v) s == null ? null : int.tryParse(s.toString()),
      ];
    });

    // Legacy string saves stored hero ids as names — those are dropped.
    _worshippedHeroes.clear();
    if (data['worshippedHeroes'] is List) {
      for (final h in data['worshippedHeroes'] as List) {
        final id = int.tryParse(h.toString());
        if (id != null && _portraits.containsKey(id)) {
          _worshippedHeroes.add(id);
        }
      }
    }

    _troopLevels.clear();
    mapOr(data['troopLevels'])
        .forEach((k, v) => _troopLevels[k] = intOr(v, 1).clamp(1, 6));

    _capitalGarrison.clear();
    mapOr(data['capitalGarrison']).forEach((k, v) {
      if (v is Map) _capitalGarrison[k] = Map<String, dynamic>.from(v);
    });

    _activePolicies.clear();
    mapOr(data['activePolicies']).forEach((k, v) {
      final slot = int.tryParse(k);
      if (slot == null || v is! Map) return;
      final m = Map<String, dynamic>.from(v);
      _activePolicies[slot] = {
        'policyId': intOr(m['policyId'], 0),
        'tier': intOr(m['tier'], 0).clamp(0, 2),
      };
    });

    _researchedPolicies.clear();
    if (data['researchedPolicies'] is List) {
      for (final id in data['researchedPolicies'] as List) {
        final n = int.tryParse(id.toString());
        if (n != null) _researchedPolicies.add(n);
      }
    }

    _unionJoined = boolOr(data['unionJoined'], false);
    _unionName = strOr(data['unionName'], '');
    _unionIsLeader = boolOr(data['unionIsLeader'], false);
    _unionMembers.clear();
    if (data['unionMembers'] is List) {
      for (final m in data['unionMembers'] as List) {
        if (m is Map) _unionMembers.add(Map<String, dynamic>.from(m));
      }
    }
    _unionPolicies.clear();
    mapOr(data['unionPolicies']).forEach((k, v) {
      final slot = int.tryParse(k);
      if (slot == null || v is! Map) return;
      final m = Map<String, dynamic>.from(v);
      _unionPolicies[slot] = {
        'policyId': intOr(m['policyId'], 0),
        'tier': intOr(m['tier'], 0).clamp(0, 2),
      };
    });

    // Remains are seeded by generateMap(); a save carries their state.
    // Values arrive as JSON maps, so normalise keys to the field types the
    // runtime expects (int level/row/col, String owner).
    mapOr(data['remains']).forEach((k, v) {
      final id = int.tryParse(k);
      if (id == null || v is! Map) return;
      final m = Map<String, dynamic>.from(v);
      _remains[id] = {
        'id': intOr(m['id'], id),
        'name': strOr(m['name'], ''),
        'row': intOr(m['row'], 0),
        'col': intOr(m['col'], 0),
        'level': intOr(m['level'], 1),
        'owner': strOr(m['owner'], 'neutral'),
      };
    });

    _rivalUnions.clear();
    if (data['rivalUnions'] is List) {
      for (final u in data['rivalUnions'] as List) {
        if (u is! Map) continue;
        final m = Map<String, dynamic>.from(u);
        _rivalUnions.add({
          'name': strOr(m['name'], ''),
          'leader': strOr(m['leader'], ''),
          'points': intOr(m['points'], 0),
          'territory': intOr(m['territory'], 0),
          'ticks': intOr(m['ticks'], 0),
          'defeated': boolOr(m['defeated'], false),
        });
      }
    }

    _gameOver = boolOr(data['gameOver'], false);
    _gameWon = boolOr(data['gameWon'], false);
    _victoryTitle = strOr(data['victoryTitle'], '');
    _victoryLines.clear();
    if (data['victoryLines'] is List) {
      _victoryLines.addAll(
          (data['victoryLines'] as List).map((e) => e.toString()));
    }

    if (_divisionChosen) _autoAssignUnion();
    if (_divisionChosen && _rivalUnions.isEmpty) _initRivalUnions();
    if (_divisionChosen && _remains.isEmpty) _initRemains();

    // A save that already satisfies a win clause (e.g. Remains was raised
    // to Lv.20 before closing) must settle on load, not next season tick.
    if (_divisionChosen && !_gameOver) _evaluateVictory();
  }
}
