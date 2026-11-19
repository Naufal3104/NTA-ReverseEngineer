import 'package:flutter_test/flutter_test.dart';
import 'package:nta_demo/game/models/game_state.dart';
import 'package:nta_demo/data/game_data.dart';

void main() {
  group('GameState save codec', () {
    /// Buat state dengan nilai standar, save ke map, load ke state baru.
    test('round-trip preserves all fields', () async {
      final s1 = GameState();
      await s1.loadFromMap(_baseMap());

      final map = s1.toSaveMap();

      final s2 = GameState();
      await s2.loadFromMap(map);

      expect(s2.crop, s1.crop);
      expect(s2.wood, s1.wood);
      expect(s2.stone, s1.stone);
      expect(s2.iron, s1.iron);
      expect(s2.expScroll, s1.expScroll);
      expect(s2.scroll, s1.scroll);
      expect(s2.nail, s1.nail);
      expect(s2.woundedTroops, s1.woundedTroops);
      expect(s2.rewardPoints, s1.rewardPoints);
      expect(s2.elapsedSeconds, s1.elapsedSeconds);
      expect(s2.seasonIndex, s1.seasonIndex);
      expect(s2.dayInSeason, s1.dayInSeason);
      expect(s2.divisionIndex, s1.divisionIndex);
      expect(s2.divisionChosen, s1.divisionChosen);
      expect(s2.tierWinPoints, s1.tierWinPoints);
      expect(s2.playerName, s1.playerName);
      expect(s2.botDifficultyIndex, s1.botDifficultyIndex);
      expect(s2.currentView, s1.currentView);
      expect(s2.capitalBuildings, s1.capitalBuildings);
      expect(s2.conqueredPlots, s1.conqueredPlots);
      expect(s2.plotBuildings, s1.plotBuildings);
      expect(s2.troops, s1.troops);
      expect(s2.equipment, s1.equipment);
      expect(s2.exclusiveEquipment, s1.exclusiveEquipment);
      expect(s2.recastCounts, s1.recastCounts);
      expect(s2.heroFragments, s1.heroFragments);
      expect(s2.portraits, s1.portraits);
      expect(s2.portraitStrategies, s1.portraitStrategies);
      expect(s2.worshippedHeroes, s1.worshippedHeroes);
      expect(s2.musterDraws, s1.musterDraws);
      expect(s2.dailyGiftClaimed, s1.dailyGiftClaimed);
      expect(s2.capitalGarrison, s1.capitalGarrison);
      expect(s2.troopLevels, s1.troopLevels);
      expect(s2.leapStacks, s1.leapStacks);
      expect(s2.activePolicies, s1.activePolicies);
      expect(s2.researchedPolicies, s1.researchedPolicies);
      expect(s2.unionJoined, s1.unionJoined);
      expect(s2.unionName, s1.unionName);
      expect(s2.unionIsLeader, s1.unionIsLeader);
      expect(s2.unionMembers, s1.unionMembers);
      expect(s2.unionPolicies, s1.unionPolicies);
      expect(s2.remains, s1.remains);
      expect(s2.rivalUnions, s1.rivalUnions);
      expect(s2.battleReports.length, s1.battleReports.length);
      expect(s2.marches, s1.marches);
      expect(s2.gameOver, s1.gameOver);
      expect(s2.gameWon, s1.gameWon);
      expect(s2.victoryTitle, s1.victoryTitle);
      expect(s2.victoryLines, s1.victoryLines);
      // log length differs due to constructor side-effects (generateMap + load log)
    });

    test('legacy string numbers coerced correctly', () async {
      final legacy = _baseMap()
        ..addAll({
          'crop': '1234.56',
          'wood': '789',
          'iron': '42',
          'exp_scroll': '10',
          'seasonIndex': '2',
          'divisionIndex': '1',
          'botDifficultyIndex': '0',
          'troopLevels': {'longspearman': '3'},
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      // crop/wood/stone getters return floor()
      expect(s.crop, 1234);
      expect(s.wood, 789);
      expect(s.iron, 42);
      expect(s.expScroll, 10);
      expect(s.seasonIndex, 2);
      expect(s.divisionIndex, 1);
      expect(s.botDifficultyIndex, 0);
      expect(s.troopLevels['longspearman'], 3);
    });

    test('invalid troop ids dropped on load', () async {
      final legacy = _baseMap()
        ..addAll({
          'troops': {
            'longspearman': 100,
            'invalid_troop': 50,
            'another_bad': '99',
          },
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      expect(s.troops['longspearman'], 100);
      expect(s.troops.containsKey('invalid_troop'), false);
      expect(s.troops.containsKey('another_bad'), false);
    });

    test('invalid equipment ids dropped on load', () async {
      final validId = GameData.EQUIP_MASTER.first['id'].toString();
      final legacy = _baseMap()
        ..addAll({
          'equipment': {
            validId: 5,
            'invalid_gear': 99,
          },
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      expect(s.equipment[validId], 5);
      expect(s.equipment.containsKey('invalid_gear'), false);
    });

    test('exclusive equipment normalised; legacy string skipped', () async {
      final legacy = _baseMap()
        ..addAll({
          'exclusiveEquipment': {
            '6001': 'legacy_string_must_be_dropped',
            '6002': {
              'hp': 100,
              'atk': 20,
              'effects': [
                {'type': 'dmg', 'value': 10},
                'not_a_map',
              ],
              'smelt': [
                {'type': 'dr', 'value': 5},
              ],
              'locked': '2',
            },
          },
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      expect(s.exclusiveEquipment.containsKey('6001'), false,
          reason: 'legacy string value should be skipped');
      final piece = s.exclusiveEquipment['6002'];
      expect(piece, isNotNull);
      expect(piece!['hp'], 100);
      expect(piece['atk'], 20);
      expect(piece['locked'], 2);
      expect((piece['effects'] as List).length, 1);
      expect((piece['smelt'] as List).length, 1);
    });

    test('portrait grade clamped 0..7; redraws/pity ints', () async {
      final legacy = _baseMap()
        ..addAll({
          'portraits': {
            '401': {'grade': 10, 'redraws': '5', 'pity': 99},
          },
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      final p = s.portraits[401]!;
      expect(p['grade'], 7, reason: 'grade clamped to max 7');
      expect(p['redraws'], 5);
      expect(p['pity'], 99);
    });

    test('battleReports DateTime round-trip', () async {
      final now = DateTime.now();
      final legacy = _baseMap()
        ..addAll({
          'battleReports': [
            {
              'title': 'Test Battle',
              'detail': 'won',
              'time': now.toIso8601String(),
            },
          ],
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      final r = s.battleReports.single;
      expect(r['title'], 'Test Battle');
      expect(r['detail'], 'won');
      expect(r['time'], isA<DateTime>());
      expect((r['time'] as DateTime).difference(now).inSeconds, lessThan(2));
    });

    test('conqueredPlots Set round-trip', () async {
      final legacy = _baseMap()
        ..addAll({
          'conqueredPlots': ['0,1', '2,3', '4,5'],
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      expect(s.conqueredPlots, {'0,1', '2,3', '4,5'});
    });

    test('worshippedHeroes only kept if portrait exists', () async {
      final legacy = _baseMap()
        ..addAll({
          'portraits': {
            '401': {'grade': 1, 'redraws': 0, 'pity': 0},
          },
          'worshippedHeroes': ['401', '999'],
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      expect(s.worshippedHeroes, [401]);
    });

    test('troopLevels clamped 1..6', () async {
      final legacy = _baseMap()
        ..addAll({
          'troopLevels': {'longspearman': 10, 'saber_shield': 0},
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      expect(s.troopLevels['longspearman'], 6);
      expect(s.troopLevels['saber_shield'], 1);
    });

    test('leapStacks clamped by cap', () async {
      final legacy = _baseMap()
        ..addAll({
          'troopLevels': {'sword_shield': 3}, // cap = 10 + (3-1)*18 = 46
          'leapStacks': 100,
        });

      final s = GameState();
      await s.loadFromMap(legacy);

      expect(s.leapStacks, 46, reason: 'capped at level 3 cap = 46');
    });
  });
}

Map<String, dynamic> _baseMap() => {
      'crop': 1000.0,
      'wood': 800.0,
      'stone': 600.0,
      'iron': 20,
      'exp_scroll': 0,
      'scroll': 0,
      'nail': 0,
      'woundedTroops': 0,
      'rewardPoints': 100,
      'elapsedSeconds': 0,
      'seasonIndex': 0,
      'dayInSeason': 1,
      'divisionIndex': 0,
      'divisionChosen': false,
      'tierWinPoints': 0,
      'playerName': 'Commander',
      'botDifficultyIndex': 1,
      'botSeconds': 0,
      'currentView': 'lobby',
      'capitalBuildings': {'palace': 1},
      'conqueredPlots': <String>[],
      'plotBuildings': <String, dynamic>{},
      'troops': <String, dynamic>{},
      'equipment': <String, dynamic>{},
      'exclusiveEquipment': <String, dynamic>{},
      'recastCounts': <String, dynamic>{},
      'heroFragments': <String, dynamic>{},
      'portraits': <String, dynamic>{},
      'portraitStrategies': <String, dynamic>{},
      'worshippedHeroes': <String>[],
      'musterDraws': 20,
      'dailyGiftClaimed': false,
      'capitalGarrison': <String, dynamic>{},
      'troopLevels': <String, dynamic>{},
      'leapStacks': 0,
      'activePolicies': <String, dynamic>{},
      'researchedPolicies': <int>[],
      'unionJoined': false,
      'unionName': '',
      'unionIsLeader': false,
      'unionMembers': <dynamic>[],
      'unionPolicies': <String, dynamic>{},
      'remains': <String, dynamic>{},
      'rivalUnions': <dynamic>[],
      'battleReports': <dynamic>[],
      'marches': <dynamic>[],
      'gameOver': false,
      'gameWon': false,
      'victoryTitle': '',
      'victoryLines': <String>[],
      'log': <String>[],
    };