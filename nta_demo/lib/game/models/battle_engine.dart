import 'dart:math' as math;

import '../../data/game_data.dart';

/// Satu stack pasukan di grid 11x11. Satu stack = satu tipe prajurit/monster
/// dengan `count` anggota; HP/ATK total = nilai per-anggota x count.
class BattleUnit {
  BattleUnit({
    required this.id,
    required this.name,
    required this.type,
    required this.count,
    required this.hpPer,
    required this.atkPer,
    required this.range,
    required this.move,
    required this.speed,
    required this.rageNeed,
    required this.rage,
    required this.row,
    required this.col,
    required this.skills,
    required this.isAttacker,
    this.bonusDr = 0,
    this.dmgDealt = 0,
    this.leech = 0,
    this.dodge = 0,
    this.ignoreDodge = 0,
    this.hpRegen = 0,
    this.extraRageOnAttack = 0,
    this.skillMultiplier = 1.0,
    this.skillFlatDamage = 0,
    this.skillBonusPct = 0,
    String? uid,
  })  : uid = uid ?? id,
        hp = hpPer * count;

  /// Unik per-instance (enemy garrison bisa punya beberapa unit id sama).
  final String uid;
  final String id;
  final String name;
  final String type;
  final int count;
  final int hpPer;
  final int atkPer;
  final int range;
  final int move;
  final int speed;
  final int rageNeed;
  final List<int> skills;
  final bool isAttacker;

  /// Extra Damage Reduction dari equipment/hero (0..1).
  final double bonusDr;

  /// Hero expertise modifiers (fractions 0..1 unless noted).
  final double dmgDealt;
  final double leech;
  final double dodge;
  final double ignoreDodge;
  final int hpRegen;
  final int extraRageOnAttack;

  /// Active-skill damage: pawnSkill.value multiplier at the unit's level.
  /// 1.0 = no active skill / flat family.
  final double skillMultiplier;

  /// Flat DMG for flat-damage families (Earthshaker, Unbridled Dance).
  final int skillFlatDamage;

  /// Extra % on active-skill damage from a hero's exclusive skill_intensify
  /// (equipBase.skill_intensify, e.g. "201,1"). 0 when none is forged.
  final double skillBonusPct;

  int hp;
  int rage;
  int row;
  int col;

  bool get alive => hp > 0 && count > 0;

  /// Sisa anggota hidup (dibulatkan) — dipakai untuk casualty report.
  int get aliveCount =>
      count <= 0 ? 0 : ((hp / hpPer).ceil()).clamp(0, count);

  /// Apakah unit punya passive tertentu (skill id berbasis 10000).
  bool hasSkill(int skillId) => skills.contains(skillId);

  /// Skill aktif level tertinggi (id >= 20000) — dipakai saat rage penuh.
  int? get activeSkill {
    final actives = skills.where((s) => s >= 20000).toList()..sort();
    return actives.isEmpty ? null : actives.last;
  }
}

/// Posisi + HP satu unit pada satu titik waktu (untuk replay di UI).
class UnitSnapshot {
  const UnitSnapshot({
    required this.id,
    required this.pawnId,
    required this.name,
    required this.type,
    required this.row,
    required this.col,
    required this.hp,
    required this.maxHp,
    required this.count,
    required this.aliveCount,
    required this.isAttacker,
  });

  /// Unik per instance (dua Boar Knight punya uid beda).
  final String id;

  /// pawnBase id — kunci sprite (`assets/images/units/unit_<pawnId>.png`).
  final String pawnId;
  final String name;
  final String type;
  final int row;
  final int col;
  final int hp;
  final int maxHp;
  final int count;
  final int aliveCount;
  final bool isAttacker;
}

/// Satu event dalam log pertempuran (untuk replay di UI).
class BattleEvent {
  const BattleEvent({
    required this.round,
    required this.actor,
    required this.action,
    required this.detail,
    this.actorUid,
    this.target,
    this.targetUid,
    this.damage = 0,
  });

  final int round;
  final String actor;
  final String action; // move | attack | skill | die
  final String detail;

  /// Instance id unit pelaku (`BattleUnit.uid`) — dipakai UI untuk animasi.
  final String? actorUid;
  final String? target;
  final String? targetUid;
  final int damage;
}

/// Hasil simulasi pertempuran.
class BattleResult {
  const BattleResult({
    required this.victory,
    required this.rounds,
    required this.events,
    required this.frames,
    required this.attackerLosses,
    required this.defenderLosses,
    required this.attackerStart,
    required this.defenderStart,
  });

  final bool victory;
  final int rounds;
  final List<BattleEvent> events;

  /// Snapshot grid setelah tiap event; `frames.length == events.length`.
  final List<List<UnitSnapshot>> frames;
  final Map<String, int> attackerLosses;
  final Map<String, int> defenderLosses;
  final Map<String, int> attackerStart;
  final Map<String, int> defenderStart;
}

/// Engine tempur turn-based di grid 11x11 mengikuti aturan game asli
/// (Battle Guide §4): pasukan penyerang menumpuk di 1 tile pintu masuk,
/// unit bergerak hanya bila tidak ada musuh dalam jangkauan, urutan aksi
/// menurut ATK SPD, rage naik saat menyerang dan diserang.
class BattleEngine {
  BattleEngine._();

  static const int gridSize = 11;
  static const int flagRow = 5;
  static const int flagCol = 5;

  /// Empat pintu masuk: utara, selatan, barat, timur.
  static const List<List<int>> gates = [
    [0, 5], [10, 5], [5, 0], [5, 10],
  ];

  /// Counter wheel: spear > cavalry > shield > bow > spear.
  static const Map<String, String> counters = {
    'spear': 'cavalry',
    'cavalry': 'shield',
    'shield': 'bow',
    'bow': 'spear',
  };

  static const Map<int, String> _counterSkillType = {
    10101: 'cavalry',
    10102: 'bow',
    10103: 'spear',
    10104: 'shield',
  };

  static Map<String, dynamic>? _lookup(List<Map<String, dynamic>> pool, String id) {
    for (final u in pool) {
      if (u['id'] == id) return u;
    }
    return null;
  }

  /// ATK SPD (1-9) asli dari pawnBase.json; fallback 6 bila tidak diketahui.
  static int pawnAttackSpeed(String pawnId) {
    final base = GameData.PAWN_BASE[pawnId];
    return (base?['attackSpeed'] as int?) ?? 6;
  }

  static Map<String, dynamic> _levelRow(Map<String, dynamic> unit, int lv) {
    final levels = (unit['levels'] as List).cast<Map<String, dynamic>>();
    return levels.firstWhere(
      (r) => r['lv'] == lv,
      orElse: () => levels.last,
    );
  }

  /// Barracks troop id -> pawnBase id (SOLDIER_COMBAT).
  /// Urutan mengikuti GameData.TROOPS: 6 spear, 6 shield, 6 bow, 6 cavalry, 2 weaponry.
  static const Map<String, String> troopCombatIds = {
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

  /// Bangun stack prajurit pemain dari inventori `troops` (id -> count).
  /// Level prajurit diambil dari `troopLevels`.
  /// Hero yang di-worship masuk sebagai unit tersendiri (1 hero per army).
  static List<BattleUnit> buildPlayerUnits({
    required Map<String, int> troops,
    required Map<String, int> troopLevels,
    required int gateIndex,
    List<Map<String, dynamic>> heroes = const [],
    double bonusDr = 0,
    int hpFlatPerLevel = 0,
    int atkFlatPerLevel = 0,
    Map<String, double> hpPctByTroop = const {},
    Map<String, double> atkPctByTroop = const {},
    Map<String, double> hpPctByType = const {},
    Map<String, double> atkPctByType = const {},
    Map<String, double> drByType = const {},
  }) {
    final gate = gates[gateIndex % gates.length];
    final units = <BattleUnit>[];
    troops.forEach((id, count) {
      if (count <= 0) return;
      final combatId = troopCombatIds[id];
      if (combatId == null) return;
      final def = _lookup(GameData.SOLDIER_COMBAT, combatId);
      if (def == null) return;
      final lv = (troopLevels[id] ?? 1).clamp(1, 6);
      final row = _levelRow(def, lv);
      final type = def['type'] as String;
      final hpPct = (hpPctByTroop[id] ?? 0) + (hpPctByType[type] ?? 0);
      final atkPct = (atkPctByTroop[id] ?? 0) + (atkPctByType[type] ?? 0);
      final hpPer =
          (((row['hp'] as int) + hpFlatPerLevel * lv) * (1 + hpPct)).round();
      final atkPer =
          (((row['atk'] as int) + atkFlatPerLevel * lv) * (1 + atkPct)).round();
      units.add(BattleUnit(
        id: combatId,
        name: def['name'] as String,
        type: type,
        count: count,
        hpPer: math.max(1, hpPer),
        atkPer: math.max(1, atkPer),
        range: row['range'] as int,
        move: row['move'] as int,
        speed: pawnAttackSpeed(combatId),
        rageNeed: row['rage'] as int,
        rage: row['initRage'] as int,
        row: gate[0],
        col: gate[1],
        skills: (row['skills'] as List).cast<int>(),
        isAttacker: true,
        bonusDr: (bonusDr + (drByType[type] ?? 0)).clamp(0.0, 0.9),
        skillMultiplier: GameData.activeSkillMultiplier(combatId, level: lv),
        skillFlatDamage: GameData.activeSkillFlatDamage(combatId, level: lv),
      ));
    });

    for (final hero in heroes) {
      final pawn = (hero['pawn'] as num?)?.toInt();
      if (pawn == null) continue;
      final combatId = pawn.toString();
      final def = _lookup(GameData.SOLDIER_COMBAT, combatId);
      if (def == null) continue;

      final grade = ((hero['grade'] as num?)?.toInt() ?? 0).clamp(0, 7);
      final hpLadder = (hero['hp'] as List).cast<int>();
      final atkLadder = (hero['atk'] as List).cast<int>();
      final type = def['type'] as String;
      final row = _levelRow(def, 1);

      // Expertise rows equipped on the portrait feed per-unit modifiers.
      final mods = _heroExpertiseMods(
        ids: ((hero['expertise'] as List?) ?? const []).cast<int>(),
        pawnId: combatId,
        type: type,
      );

      units.add(BattleUnit(
        id: 'hero_${hero['id']}',
        name: hero['name'] as String,
        type: type,
        count: 1,
        hpPer: math.max(1, ((hpLadder[grade] + mods.hpFlat) * (1 + mods.hpPct)).round()),
        atkPer: math.max(1, ((atkLadder[grade] + mods.atkFlat) * (1 + mods.atkPct)).round()),
        range: math.max(1, (row['range'] as int) + mods.rangeDelta),
        move: row['move'] as int,
        speed: pawnAttackSpeed(combatId),
        rageNeed: math.max(1, (row['rage'] as int) + mods.rageNeedDelta),
        rage: row['initRage'] as int,
        row: gate[0],
        col: gate[1],
        skills: (row['skills'] as List).cast<int>(),
        isAttacker: true,
        bonusDr: (bonusDr + mods.dmgTaken).clamp(0.0, 0.9),
        dmgDealt: mods.dmgDealt,
        leech: mods.leech,
        dodge: mods.dodge,
        ignoreDodge: mods.ignoreDodge,
        hpRegen: mods.hpRegen,
        extraRageOnAttack: mods.extraRage,
        skillMultiplier: GameData.activeSkillMultiplier(combatId),
        skillFlatDamage: GameData.activeSkillFlatDamage(combatId),
        // Hero skill value arrives already filtered to skills that scale
        // active-skill damage, as a fraction (0.40 == +40%).
        skillBonusPct: ((hero['skillValue'] as num?)?.toDouble() ?? 0) +
            ((hero['exclusive'] as Map<String, dynamic>?) != null
                ? GameData.exclusiveSkillBonusPct(
                    combatId,
                    (hero['exclusive']! as Map<String, dynamic>)['level']
                            as int? ??
                        1)
                : 0.0),
      ));
    }
    return units;
  }

  /// Resolve equipped expertise rows into flat combat modifiers.
  /// Conditional rows (true DMG procs, kill stacks, dodge reactions) are
  /// not modelled yet.
  static _HeroMods _heroExpertiseMods({
    required List<int> ids,
    required String pawnId,
    required String type,
  }) {
    final m = _HeroMods();
    for (final id in ids) {
      final row = GameData.STRATEGIES[id];
      if (row == null) continue;
      final target = (row['target'] as String?) ?? '';
      final kind = target.split(',').first;
      // target kind: 10 = possessed troop, 1 = pawn id, 2 = troop type,
      // 4 = hero, 0 = all allies.
      final applies = switch (kind) {
        '10' => true,
        '1' => target.split(',').last == pawnId,
        '2' => _typeKindMatches(target.split(',').last, type),
        '4' || '0' => true,
        _ => false,
      };
      if (!applies) continue;
      final value = int.tryParse((row['value'] as String?) ?? '') ?? 0;
      switch (id) {
        case 10001:
          m.dmgDealt += value / 100;
          m.dmgTaken += value / 100;
        case 20001:
          m.atkFlat += value;
        case 20002:
          m.hpFlat += value;
        case 20003:
          m.atkPct += value / 100;
        case 20004:
          m.hpPct += value / 100;
        case 20005:
          m.dmgDealt += value / 100;
        case 20006:
          m.dmgTaken += value / 100;
        case 20007:
          m.hpRegen += value;
        case 20008:
          m.leech += value / 100;
        case 20009:
          m.dodge += value / 100;
        case 20010:
          m.ignoreDodge += value / 100;
        case 30102:
          m.hpRegen += value;
        case 40101:
          m.rangeDelta += value;
        case 40102:
          m.rageNeedDelta -= value;
        case 40103:
          m.extraRage += value;
        case 40105:
          m.dmgDealt += value / 100;
        case 40106:
          m.hpRegen += value;
      }
    }
    return m;
  }

  /// `strategy.target_id` kind 2 sub-id -> troop type string.
  static bool _typeKindMatches(String sub, String type) {
    const byType = {'1': 'spear', '2': 'shield', '3': 'bow', '4': 'cavalry'};
    return byType[sub] == type;
  }

  /// Susun garrison musuh langsung dari `landAttr.json` — satu baris per
  /// plot, dengan string `armys_<landType>` berformat "pawnId,row_col,level"
  /// yang posisinya sudah relatif ke grid interior plot 11x11 (sama dengan
  /// gridSize kita), jadi dipakai apa adanya.
  static List<BattleUnit> buildEnemyUnits({
    required int attrId,
    required int landType,
    required math.Random rng,
  }) {
    return buildUnitsFromRaw(GameData.landGarrisonRaw(attrId, landType));
  }

  /// Susun garrison dari string mentah "pawnId,row_col,level" (dipakai
  /// Remains, yang datanya tidak ada di landAttr).
  static List<BattleUnit> buildUnitsFromRaw(String raw) {
    final units = <BattleUnit>[];
    int i = 0;
    for (final part in raw.split('|')) {
      if (part.isEmpty) continue;
      final bits = part.split(',');
      if (bits.length < 3) continue;
      final def = _lookup(GameData.ENEMY_COMBAT, bits[0]);
      if (def == null) continue;
      final pos = bits[1].split('_');
      final r = pos.length == 2 ? (int.tryParse(pos[0]) ?? flagRow) : flagRow;
      final c = pos.length == 2 ? (int.tryParse(pos[1]) ?? flagCol) : flagCol;
      final lv = int.tryParse(bits[2]) ?? 1;
      final row = _levelRow(def, lv);
      units.add(BattleUnit(
        uid: '${def['id']}_$i',
        id: def['id'] as String,
        name: def['name'] as String,
        type: def['type'] as String,
        count: 1,
        hpPer: row['hp'] as int,
        atkPer: row['atk'] as int,
        range: row['range'] as int,
        move: row['move'] as int,
        speed: pawnAttackSpeed(def['id'] as String),
        rageNeed: row['rage'] as int,
        rage: row['initRage'] as int,
        row: r.clamp(0, gridSize - 1),
        col: c.clamp(0, gridSize - 1),
        skills: (row['skills'] as List).cast<int>(),
        isAttacker: false,
      ));
      i++;
    }
    return units;
  }

  static int _dist(BattleUnit a, BattleUnit b) =>
      (a.row - b.row).abs() + (a.col - b.col).abs();

  /// Damage Reduction pasif bawaan unit (persen, 0..1).
  static double _damageReduction(BattleUnit u, {required bool ranged}) {
    double dr = u.bonusDr;
    if (u.hasSkill(10601)) dr += 0.40; // Scale Armor
    if (ranged && u.hasSkill(10301)) dr += 0.60; // Fortitude (Boar Knight)
    return dr.clamp(0.0, 0.9);
  }

  /// Pilih target: musuh terdekat; kalau seri, yang ATK SPD-nya tertinggi
  /// (aturan Battle Guide: unit cepat lebih sering jadi target).
  static BattleUnit? _pickTarget(BattleUnit self, List<BattleUnit> foes) {
    BattleUnit? best;
    int bestDist = 1 << 30;
    for (final f in foes) {
      if (!f.alive) continue;
      final d = _dist(self, f);
      if (d < bestDist || (d == bestDist && best != null && f.speed > best.speed)) {
        best = f;
        bestDist = d;
      }
    }
    return best;
  }

  /// Satu langkah greedy menuju target (Chebyshev-free: pakai Manhattan,
  /// geser sumbu dengan selisih terbesar dulu).
  static void _stepToward(BattleUnit self, BattleUnit target) {
    final dr = target.row - self.row;
    final dc = target.col - self.col;
    if (dr.abs() >= dc.abs() && dr != 0) {
      self.row += dr.sign;
    } else if (dc != 0) {
      self.col += dc.sign;
    }
    self.row = self.row.clamp(0, gridSize - 1);
    self.col = self.col.clamp(0, gridSize - 1);
  }

  static int _rollDamage({
    required BattleUnit attacker,
    required BattleUnit target,
    required math.Random rng,
    bool skillCast = false,
  }) {
    double mult = 0.85 + rng.nextDouble() * 0.30;

    // Type triangle: counter +40% ATK, dan menembus 20% DMG Reduction.
    double ignoredDr = 0;
    final counterTarget = counters[attacker.type];
    if (counterTarget == target.type) {
      mult *= 1.4;
      ignoredDr = 0.20;
    }
    // Kalau target meng-counter penyerang: ATK penyerang -40%.
    if (counters[target.type] == attacker.type) {
      mult *= 0.6;
    }
    // Passive counter eksplisit (mis. Boar Knight Counter Shield Soldier).
    for (final s in attacker.skills) {
      final t = _counterSkillType[s];
      if (t != null && t == target.type) {
        mult *= 1.4;
        ignoredDr = math.max(ignoredDr, 0.20);
      }
    }

    if (skillCast) {
      mult *= attacker.skillMultiplier * (1 + attacker.skillBonusPct);
    }

    // Expertise: DMG dealt bonus, dan ignore Dodge milik target.
    mult *= 1 + attacker.dmgDealt;

    final ranged = attacker.range > 1;
    var dr = _damageReduction(target, ranged: ranged) - ignoredDr;
    dr = dr.clamp(0.0, 0.9);

    var raw = attacker.atkPer * attacker.count * mult * (1 - dr);
    if (skillCast && attacker.skillFlatDamage > 0) {
      raw += attacker.skillFlatDamage.toDouble();
    }
    return math.max(1, raw.round());
  }

  static void _applyRage(BattleUnit u, int amount) {
    if (u.rageNeed <= 0) return;
    u.rage = (u.rage + amount).clamp(0, u.rageNeed);
  }

  static List<UnitSnapshot> _snapshot(
      List<BattleUnit> attackers, List<BattleUnit> defenders) {
    return [
      for (final u in [...attackers, ...defenders])
        UnitSnapshot(
          id: u.uid,
          pawnId: u.id,
          name: u.name,
          type: u.type,
          row: u.row,
          col: u.col,
          hp: math.max(0, u.hp),
          maxHp: u.hpPer * u.count,
          count: u.count,
          aliveCount: u.aliveCount,
          isAttacker: u.isAttacker,
        ),
    ];
  }

  static BattleResult simulate({
    required List<BattleUnit> attackers,
    required List<BattleUnit> defenders,
    required math.Random rng,
    int maxRounds = 30,
  }) {
    final events = <BattleEvent>[];
    final frames = <List<UnitSnapshot>>[];
    final attackerStart = {for (final u in attackers) u.uid: u.count};
    final defenderStart = {for (final u in defenders) u.uid: u.count};

    void act(BattleUnit unit, List<BattleUnit> foes, int round) {
      final before = events.length;
      _act(unit, foes, events, round, rng);
      for (var i = before; i < events.length; i++) {
        frames.add(_snapshot(attackers, defenders));
      }
    }

    // Urutan aksi awal: ATK SPD tertinggi dulu (Battle Guide §4.3).
    int round = 1;
    int lastRound = 1;
    while (round <= maxRounds &&
        attackers.any((u) => u.alive) &&
        defenders.any((u) => u.alive)) {
      lastRound = round;
      final actingAttackers = attackers.where((u) => u.alive).toList()
        ..sort((a, b) => b.speed.compareTo(a.speed));
      for (final unit in actingAttackers) {
        if (!unit.alive) continue;
        act(unit, defenders, round);
        if (!defenders.any((u) => u.alive)) break;
      }
      if (!defenders.any((u) => u.alive)) break;

      final actingDefenders = defenders.where((u) => u.alive).toList()
        ..sort((a, b) => b.speed.compareTo(a.speed));
      for (final unit in actingDefenders) {
        if (!unit.alive) continue;
        act(unit, attackers, round);
        if (!attackers.any((u) => u.alive)) break;
      }
      round++;
    }

    final victory = defenders.every((u) => !u.alive);

    final attackerLosses = <String, int>{};
    for (final u in attackers) {
      final lost = (u.count - u.aliveCount).clamp(0, u.count);
      if (lost > 0) attackerLosses[u.uid] = (attackerLosses[u.uid] ?? 0) + lost;
    }
    final defenderLosses = <String, int>{};
    for (final u in defenders) {
      final lost = (u.count - u.aliveCount).clamp(0, u.count);
      if (lost > 0) defenderLosses[u.uid] = (defenderLosses[u.uid] ?? 0) + lost;
    }

    return BattleResult(
      victory: victory,
      rounds: lastRound,
      events: events,
      frames: frames,
      attackerLosses: attackerLosses,
      defenderLosses: defenderLosses,
      attackerStart: attackerStart,
      defenderStart: defenderStart,
    );
  }

  static void _act(
    BattleUnit unit,
    List<BattleUnit> foes,
    List<BattleEvent> events,
    int round,
    math.Random rng,
  ) {
    final target = _pickTarget(unit, foes);
    if (target == null) return;

    // Gerak hanya bila tidak ada musuh dalam jangkauan (Battle Guide §4.2).
    if (_dist(unit, target) > unit.range) {
      final startRow = unit.row;
      final startCol = unit.col;
      for (int step = 0; step < unit.move; step++) {
        if (_dist(unit, target) <= unit.range) break;
        _stepToward(unit, target);
      }
      if (unit.row != startRow || unit.col != startCol) {
        events.add(BattleEvent(
          round: round,
          actor: unit.name,
          actorUid: unit.uid,
          action: 'move',
          detail: '($startRow,$startCol) -> (${unit.row},${unit.col})',
        ));
      }
      if (_dist(unit, target) > unit.range) return;
    }

    // Expertise Dodge: chance to evade the hit entirely.
    final dodgeChance =
        (target.dodge - unit.ignoreDodge).clamp(0.0, 0.9);
    if (dodgeChance > 0 && rng.nextDouble() < dodgeChance) {
      events.add(BattleEvent(
        round: round,
        actor: target.name,
        actorUid: target.uid,
        action: 'skill',
        detail: 'Dodge',
        target: unit.name,
        targetUid: unit.uid,
      ));
      _applyRage(target, 1);
      return;
    }

    // Rage penuh -> cast skill, reset ke 0 (SoldierAttribute.md).
    final canCast = unit.rageNeed > 0 &&
        unit.rage >= unit.rageNeed &&
        unit.activeSkill != null;
    final dmg = _rollDamage(
      attacker: unit,
      target: target,
      rng: rng,
      skillCast: canCast,
    );
    target.hp -= dmg;
    _applyRage(unit, 1 + unit.extraRageOnAttack);
    _applyRage(target, 1);
    if (canCast) {
      unit.rage = 0;
    }

    // Expertise Leech: heal the attacker by a share of damage dealt.
    if (unit.leech > 0 && unit.alive) {
      final maxHp = unit.hpPer * unit.count;
      unit.hp = math.min(maxHp, unit.hp + (dmg * unit.leech).round());
    }
    // Expertise per-round regen, applied when the unit takes its turn.
    if (unit.hpRegen > 0 && unit.alive) {
      final maxHp = unit.hpPer * unit.count;
      unit.hp = math.min(maxHp, unit.hp + unit.hpRegen);
    }

    // Passive reflect (Hedgehog DMG Reflection 35%).
    if (target.hasSkill(10501) && target.alive) {
      final reflect = (dmg * 0.35).round();
      unit.hp -= reflect;
      events.add(BattleEvent(
        round: round,
        actor: target.name,
        actorUid: target.uid,
        action: 'skill',
        detail: 'DMG Reflection: $reflect',
        target: unit.name,
        targetUid: unit.uid,
        damage: reflect,
      ));
    }

    events.add(BattleEvent(
      round: round,
      actor: unit.name,
      actorUid: unit.uid,
      action: canCast ? 'skill' : 'attack',
      detail: canCast ? 'Skill cast' : 'Attack',
      target: target.name,
      targetUid: target.uid,
      damage: dmg,
    ));

    if (!target.alive) {
      events.add(BattleEvent(
        round: round,
        actor: target.name,
        actorUid: target.uid,
        action: 'die',
        detail: 'Defeated',
      ));
    }
  }
}

/// Mutable accumulator for hero expertise effects.
class _HeroMods {
  int hpFlat = 0;
  int atkFlat = 0;
  double hpPct = 0;
  double atkPct = 0;
  double dmgDealt = 0;
  double dmgTaken = 0;
  double leech = 0;
  double dodge = 0;
  double ignoreDodge = 0;
  int hpRegen = 0;
  int extraRage = 0;
  int rageNeedDelta = 0;
  int rangeDelta = 0;
}
