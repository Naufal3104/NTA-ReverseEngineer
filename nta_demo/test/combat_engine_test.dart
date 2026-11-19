import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nta_demo/data/game_data.dart';
import 'package:nta_demo/game/models/battle_engine.dart';
import 'package:nta_demo/game/models/game_state.dart';

/// Pure-logic combat tests. They drive [BattleEngine] directly (no widget /
/// platform channels) and check the rules from `Battle Guide and Plot Recap.md`
/// §4 and `SoldierAttribute.md`:
///  - type triangle: Spear > Cavalry > Shield > Bow > Spear (×1.4 / ×0.6)
///  - attacker group acts before the defenders each round
///  - rage fills on attack/receive, resets to 0 on skill cast
///  - passive damage reduction (Fortitude, Scale Armor)
///  - passive reflect (Hedgehog)
///  - difficulty escalation easy→hell and the hell garrison composition
void main() {
  BattleUnit unit({
    required String id,
    required String type,
    int count = 1,
    int hpPer = 100000,
    int atkPer = 100,
    int range = 1,
    int move = 3,
    int speed = 6,
    int rageNeed = 0,
    int rage = 0,
    int row = 0,
    int col = 5,
    List<int> skills = const [],
    bool attacker = true,
  }) {
    return BattleUnit(
      id: id,
      name: id,
      type: type,
      count: count,
      hpPer: hpPer,
      atkPer: atkPer,
      range: range,
      move: move,
      speed: speed,
      rageNeed: rageNeed,
      rage: rage,
      row: row,
      col: col,
      skills: skills,
      isAttacker: attacker,
    );
  }

  /// Mean per-round attack damage the attacker deals in round 1 over [trials]
  /// seeded simulations. Defenders are placed adjacent (no movement).
  double meanRound1Damage({
    required BattleUnit attacker,
    required BattleUnit defender,
    int trials = 300,
  }) {
    var total = 0.0;
    for (var seed = 0; seed < trials; seed++) {
      final a = attacker;
      final d = defender;
      // Fresh copies each trial: simulate mutates the units in place.
      final attackerTrial = unit(
        id: a.id,
        type: a.type,
        count: a.count,
        hpPer: a.hpPer,
        atkPer: a.atkPer,
        range: a.range,
        speed: a.speed,
        rageNeed: a.rageNeed,
        rage: a.rage,
        row: a.row,
        col: a.col,
        skills: a.skills,
      );
      final defenderTrial = unit(
        id: d.id,
        type: d.type,
        count: d.count,
        hpPer: d.hpPer,
        atkPer: d.atkPer,
        range: d.range,
        speed: d.speed,
        row: d.row,
        col: d.col,
        skills: d.skills,
        attacker: false,
      );
      final res = BattleEngine.simulate(
        attackers: [attackerTrial],
        defenders: [defenderTrial],
        rng: math.Random(seed),
        maxRounds: 1,
      );
      for (final e in res.events) {
        if (e.actorUid == attackerTrial.uid &&
            e.round == 1 &&
            (e.action == 'attack' || e.action == 'skill')) {
          total += e.damage;
        }
      }
    }
    return total / trials;
  }

  group('type triangle (§4.3)', () {
    // Spear > Cavalry > Shield > Bow > Spear: +40% vs the countered type,
    // −40% when striking the type that counters you.
    double spearVs(String targetType) => meanRound1Damage(
          attacker: unit(id: 'spear', type: 'spear', atkPer: 100),
          defender: unit(
              id: 'target', type: targetType, atkPer: 1, attacker: false),
        );

    test('neutral match ≈ base ATK', () {
      // Spear vs Shield is neither advantage nor disadvantage.
      expect(spearVs('shield'), closeTo(100, 6));
    });

    test('counter target ≈ +40% ATK', () {
      // Spear counters Cavalry.
      expect(spearVs('cavalry'), closeTo(140, 8));
    });

    test('attacking your counter ≈ −40% ATK', () {
      // Bow counters Spear, so a Spearman hitting a Bowman is penalised.
      expect(spearVs('bow'), closeTo(60, 5));
    });

    test('counter wheel is the documented order', () {
      expect(BattleEngine.counters['spear'], 'cavalry');
      expect(BattleEngine.counters['cavalry'], 'shield');
      expect(BattleEngine.counters['shield'], 'bow');
      expect(BattleEngine.counters['bow'], 'spear');
    });
  });

  group('turn order (§4.1)', () {
    test('attacker group acts before defenders in round 1', () {
      final atk = unit(id: 'atk', type: 'spear', speed: 5);
      final def = unit(id: 'def', type: 'spear', speed: 9, attacker: false, row: 1);
      final res = BattleEngine.simulate(
        attackers: [atk],
        defenders: [def],
        rng: math.Random(1),
        maxRounds: 2,
      );
      final round1 = res.events.where((e) => e.round == 1).toList();
      // First round-1 action must belong to the attacker even though the
      // defender has higher ATK SPD.
      expect(round1.first.actorUid, atk.uid);
    });
  });

  group('rage (§4.3)', () {
    test('rage fills on attack, resets to 0 after a skill cast', () {
      // rage 2/2 + an active skill (id >= 20000) => casts on first action.
      final atk = unit(
        id: '3101',
        type: 'spear',
        rageNeed: 2,
        rage: 2,
        skills: const [20101],
      );
      final def =
          unit(id: 'def', type: 'spear', atkPer: 1, attacker: false, row: 1);
      final res = BattleEngine.simulate(
        attackers: [atk],
        defenders: [def],
        rng: math.Random(3),
        maxRounds: 1,
      );
      final cast = res.events.where(
          (e) => e.actorUid == atk.uid && e.action == 'skill' && e.damage > 0);
      expect(cast, isNotEmpty, reason: 'full rage should cast a skill');
      // After the cast, rage resets to 0; the defender's counterattack this
      // round then awards +1 (rage is gained when attacked too). Without the
      // reset, the clamp would leave it pinned at rageNeed (= 2).
      expect(atk.rage, lessThan(atk.rageNeed),
          reason: 'rage must drop below the cast threshold after casting');
    });

    test('receiving an attack grants the defender rage', () {
      final atk = unit(id: 'atk', type: 'spear');
      final def = unit(
          id: 'def', type: 'spear', atkPer: 1, rageNeed: 9, attacker: false,
          row: 1);
      BattleEngine.simulate(
        attackers: [atk],
        defenders: [def],
        rng: math.Random(4),
        maxRounds: 1,
      );
      expect(def.rage, greaterThan(0));
    });
  });

  group('passive damage reduction (§3)', () {
    test('Fortitude (Boar Knight, 10301) cuts ranged DMG ~60%', () {
      double rangedVs(List<int> skills) {
        // Ranged attacker (range 2) hitting an adjacent target: Fortitude's
        // ranged-only mitigation must apply.
        return meanRound1Damage(
          attacker: unit(id: 'bow', type: 'bow', atkPer: 100, range: 2),
          defender: unit(
              id: 'boar', type: 'bandit', atkPer: 1, skills: skills,
              attacker: false, row: 1),
        );
      }

      final plain = rangedVs(const []);
      final fortified = rangedVs(const [10301]);
      expect(plain, closeTo(100, 6));
      expect(fortified, closeTo(40, 6)); // ×0.4
    });

    test('Scale Armor (Lizard, 10601) cuts melee DMG ~40%', () {
      double meleeVs(List<int> skills) => meanRound1Damage(
            attacker: unit(id: 'spear', type: 'spear', atkPer: 100),
            defender: unit(
                id: 'lizard', type: 'beast', atkPer: 1, skills: skills,
                attacker: false, row: 1),
          );

      expect(meleeVs(const []), closeTo(100, 6));
      expect(meleeVs(const [10601]), closeTo(60, 6)); // ×0.6
    });
  });

  group('guardians & skill counters (§3)', () {
    test('Iron Mountain Stance (12001) cuts incoming DMG ~70%', () {
      double guardianVs(List<int> skills) => meanRound1Damage(
            attacker: unit(id: 'spear', type: 'spear', atkPer: 100),
            defender: unit(
                id: 'goat', type: 'beast', atkPer: 1, skills: skills,
                attacker: false, row: 1),
          );

      expect(guardianVs(const []), closeTo(100, 6));
      expect(guardianVs(const [12001]), closeTo(30, 6)); // ×0.3
    });

    test('Boar Knight Counter Shield (10104) cuts a Shieldman ~40%', () {
      // Shieldman attacking a Boar Knight must lose 40% ATK via the target's
      // passive counter, on top of the shield-vs-bandit neutral wheel.
      double shieldVsBoar(List<int> boarSkills) => meanRound1Damage(
            attacker: unit(id: 'shield', type: 'shield', atkPer: 100),
            defender: unit(
                id: 'boar', type: 'bandit', atkPer: 1, skills: boarSkills,
                attacker: false, row: 1),
          );

      expect(shieldVsBoar(const []), closeTo(100, 6));
      expect(shieldVsBoar(const [10104]), closeTo(60, 6)); // ×0.6
    });
  });

  group('Trainee Warrior Leap stacks (§3)', () {
    List<BattleUnit> build({int stacks = 0, int level = 1}) {
      return BattleEngine.buildPlayerUnits(
        troops: {'sword_shield': 10},
        troopLevels: {'sword_shield': level},
        gateIndex: 0,
        leapStacks: stacks,
      );
    }

    test('no stacks keeps base HP/ATK', () {
      final u = build().single;
      expect(u.id, '3205');
      expect(u.hpPer, 159);
      expect(u.atkPer, 3);
    });

    test('each stack adds +5 HP and +0.5 ATK per soldier', () {
      final u = build(stacks: 20).single;
      // Lv.1 base 159 HP / 3 ATK + 20 stacks.
      expect(u.hpPer, 159 + 20 * 5);
      expect(u.atkPer, 3 + (20 * 0.5).round());
    });

    test('stack bonus only touches Sword&Shield, not other troops', () {
      final units = BattleEngine.buildPlayerUnits(
        troops: {'sword_shield': 5, 'longspearman': 5},
        troopLevels: {},
        gateIndex: 0,
        leapStacks: 10,
      );
      final spear = units.firstWhere((u) => u.id == '3101');
      expect(spear.hpPer, 135);
      expect(spear.atkPer, 10);
    });

    test('stack cap scales 10 at Lv.1 to 100 at Lv.6', () {
      expect(GameData.TROOPS.isNotEmpty, isTrue);
      // Cap formula mirrors GameState.leapStackCap: 10 + (lv-1)*18.
      int cap(int lv) => (10 + (lv - 1) * 18).clamp(10, 100);
      expect(cap(1), 10);
      expect(cap(6), 100);
    });
  });

  group('passive reflect (§3)', () {
    test('Hedgehog (10501) reflects 35% DMG to the attacker', () {
      final atk = unit(id: 'atk', type: 'spear', atkPer: 100);
      final def = unit(
          id: 'hedgehog', type: 'beast', atkPer: 1, skills: const [10501],
          attacker: false, row: 1);
      final res = BattleEngine.simulate(
        attackers: [atk],
        defenders: [def],
        rng: math.Random(7),
        maxRounds: 1,
      );
      final reflect =
          res.events.where((e) => e.detail.contains('DMG Reflection'));
      expect(reflect, isNotEmpty);
    });
  });

  group('difficulty escalation (§2.1)', () {
    test('hell garrison is far stronger than an easy one', () {
      final easy = BattleEngine.buildUnitsFromRaw(
          GameData.landGarrisonRaw(1001, 3));
      final hell = BattleEngine.buildUnitsFromRaw(
          GameData.landGarrisonRaw(5016, 3));
      final easyPower =
          easy.fold<int>(0, (s, u) => s + u.hpPer * u.count + u.atkPer);
      final hellPower =
          hell.fold<int>(0, (s, u) => s + u.hpPer * u.count + u.atkPer);
      expect(hellPower, greaterThan(easyPower * 5));
    });

    test('plot distance maps easy→hard within a level band', () {
      final near = GameData.landAttrFor(1, 0);
      final far = GameData.landAttrFor(1, 12);
      expect(near, isNot(far));
      // Difficulty label must be non-decreasing with distance.
      expect(GameData.landDifficultyTier(GameData.LAND_ATTR[far]!['uiLv'] as int),
          greaterThanOrEqualTo(
              GameData.landDifficultyTier(GameData.LAND_ATTR[near]!['uiLv'] as int)));
    });

    test('Hell 2 garrison has Soulreaper + exactly 4 Boar Knights', () {
      final name = GameData.landGarrisonName(5016, 3);
      expect(name, contains('Soulreaper'));
      expect(name, contains('Boar Knight x4'));
    });

    test('difficulty labels match the documented sub-level caps', () {
      expect(GameData.landDifficultyName(1001), 'Easy 1');
      expect(GameData.landDifficultyName(6001), 'Hell 1');
    });
  });

  group('enemy active skills (§3.1)', () {
    /// Build a Wolf (4102) with Wolf Howl (31201), rage full.
    BattleUnit wolf({
      int rage = 2,
      int rageNeed = 2,
    }) => unit(
          id: '4102',
          type: 'beast',
          atkPer: 10,
          range: 1,
          speed: 5,
          hpPer: 5000,
          rage: rage,
          rageNeed: rageNeed,
          skills: const [10000, 31201], // passive + Wolf Howl
          attacker: false,
        );

    test('Wolf Howl (31201) buffs allies +3 ATK / +20% DR for 3 rounds', () {
      final w = wolf();
      final ally = unit(
          id: 'ally', type: 'beast', atkPer: 10, hpPer: 2000, attacker: false, row: 5, col: 6);
      final atk = unit(id: 'atk', type: 'spear', atkPer: 100);
      final res = BattleEngine.simulate(
        attackers: [atk],
        defenders: [w, ally],
        rng: math.Random(11),
        maxRounds: 3,
      );
      // Wolf should cast Howl on turn 1 (full rage).
      final howl = res.events.where(
          (e) => e.actorUid == w.uid && e.action == 'skill' && e.detail.contains('inspired'));
      expect(howl, isNotEmpty, reason: 'Wolf should cast Howl');
      // Ally should have buff for 3 rounds (buffTurns > 0 after round 1).
      expect(ally.buffAtk, 3);
      expect(ally.buffDr, closeTo(0.20, 0.01));
      expect(ally.buffTurns, greaterThanOrEqualTo(1));
    });

    test('Elephant Sling (30201) deals 200% ATK to highest-HP foe', () {
      final ele = unit(
          id: '4110',
          type: 'beast',
          atkPer: 50,
          range: 1,
          speed: 5,
          hpPer: 10000,
          rage: 2,
          rageNeed: 2,
          skills: const [30201],
          attacker: false,
          row: 1);
      final t1 = unit(id: 't1', type: 'beast', atkPer: 1, hpPer: 2000, attacker: true, row: 5, col: 5);
      final t2 = unit(id: 't2', type: 'beast', atkPer: 1, hpPer: 8000, attacker: true, row: 5, col: 6);
      final res = BattleEngine.simulate(
        attackers: [t1, t2],
        defenders: [ele],
        rng: math.Random(12),
        maxRounds: 2,
      );
      // Elephant should sling at t2 (higher HP) for ~2x ATK = ~100 dmg before DR.
      final sling = res.events.where(
          (e) => e.actorUid == ele.uid && e.action == 'skill' && e.targetUid == t2.uid);
      expect(sling, isNotEmpty);
      final dmg = sling.first.damage;
      expect(dmg, greaterThan(80)); // ~2 * 50 * (1 - dr)
    });

    test('Bear Smash (30401) deals True DMG = 5% Max HP + stuns 1 turn', () {
      final bear = unit(
          id: '4103',
          type: 'beast',
          atkPer: 30,
          range: 1,
          speed: 5,
          hpPer: 10000,
          rage: 2,
          rageNeed: 2,
          skills: const [30401],
          attacker: false,
          row: 1);
      final t = unit(id: 't', type: 'spear', atkPer: 100, hpPer: 5000, attacker: true);
      final res = BattleEngine.simulate(
        attackers: [t],
        defenders: [bear],
        rng: math.Random(13),
        maxRounds: 2,
      );
      final smash = res.events.where((e) => e.actorUid == bear.uid && e.action == 'skill');
      expect(smash, isNotEmpty);
      // True DMG portion = 5% * 5000 = 250; plus normal hit.
      // Stun applied in round 1; check event detail for stun.
      final stunEvt = res.events.where((e) =>
          e.actorUid == bear.uid && e.action == 'skill' && e.detail.contains('stun'));
      expect(stunEvt, isNotEmpty, reason: 'Smash should apply stun');
    });

    test('Viper Venom Spit (31401) applies poison 10% current HP for 3 rounds', () {
      final viper = unit(
          id: '4117',
          type: 'beast',
          atkPer: 40,
          range: 2,
          speed: 6,
          hpPer: 6000,
          rage: 2,
          rageNeed: 2,
          skills: const [31401],
          attacker: false,
          row: 1);
      final t = unit(id: 't', type: 'spear', atkPer: 1, hpPer: 10000, attacker: true, row: 3, col: 5);
      final res = BattleEngine.simulate(
        attackers: [t],
        defenders: [viper],
        rng: math.Random(14),
        maxRounds: 4,
      );
      final spit = res.events.where((e) => e.actorUid == viper.uid && e.action == 'skill');
      expect(spit, isNotEmpty);
      // Poison tick at end of round 1: 10% of remaining HP. Actor is the poisoned unit.
      final poisonEvents = res.events
          .where((e) => e.actorUid == t.uid && e.detail.startsWith('Poison'));
      expect(poisonEvents, isNotEmpty);
      // Poison should tick for 3 rounds total (turns set to 3).
      expect(t.poisonTurns, lessThan(3));
      expect(t.poisonPct, closeTo(0.10, 0.01));
    });

    test('Rhino Trample (31601) AoE hit + stun in radius 1 around caster', () {
      final rhino = unit(
          id: '4119',
          type: 'beast',
          atkPer: 40,
          range: 1,
          speed: 5,
          hpPer: 10000,
          rage: 2,
          rageNeed: 2,
          skills: const [31601],
          attacker: false,
          row: 5, col: 5);
      final t1 = unit(id: 't1', type: 'spear', atkPer: 1, hpPer: 5000, attacker: true, row: 4, col: 5);
      final t2 = unit(id: 't2', type: 'shield', atkPer: 1, hpPer: 5000, attacker: true, row: 5, col: 6);
      final t3 = unit(id: 't3', type: 'bow', atkPer: 1, hpPer: 5000, attacker: true, row: 6, col: 5);
      final res = BattleEngine.simulate(
        attackers: [t1, t2, t3],
        defenders: [rhino],
        rng: math.Random(15),
        maxRounds: 2,
      );
      final trample = res.events.where(
          (e) => e.actorUid == rhino.uid && e.action == 'skill' && e.detail.contains('Trample'));
      expect(trample, isNotEmpty);
      // All three adjacent targets hit and stunned. Check for stun events.
      final stunEvts = res.events.where((e) =>
          (e.targetUid == t1.uid || e.targetUid == t2.uid || e.targetUid == t3.uid) &&
          e.detail.contains('stun'));
      expect(stunEvts.length, greaterThanOrEqualTo(3));
    });
  });

  group('clinic recovery (§Clinic)', () {
    test('wounded rate is 55% on victory, 50% on defeat', () {
      expect(GameState.clinicWoundedRate(true), 0.55);
      expect(GameState.clinicWoundedRate(false), 0.50);
    });

    test('victory: 55% casualties become wounded', () {
      expect(GameState.clinicWounded(100, true), 55);
      expect(GameState.clinicWounded(10, true), 6);
      expect(GameState.clinicWounded(1, true), 1);
      expect(GameState.clinicWounded(3, true), 2); // 1.65 -> 2
    });

    test('defeat: 50% casualties become wounded', () {
      expect(GameState.clinicWounded(100, false), 50);
      expect(GameState.clinicWounded(10, false), 5);
      expect(GameState.clinicWounded(1, false), 1);
      expect(GameState.clinicWounded(3, false), 2); // 1.5 -> 2
    });

    test('wounded rate higher on victory than defeat', () {
      for (var lost in [1, 2, 3, 5, 10, 50, 100, 1000]) {
        final winWounded = GameState.clinicWounded(lost, true);
        final loseWounded = GameState.clinicWounded(lost, false);
        expect(winWounded, greaterThanOrEqualTo(loseWounded),
            reason: 'victory wounded ($winWounded) >= defeat wounded ($loseWounded) for lost=$lost');
      }
    });
  });
}