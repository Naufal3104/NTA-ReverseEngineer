const DATA = {
 "soldiers": [
  {
   "id": "longspearman",
   "name": "Longspearman",
   "cat": "spear",
   "hp": [
    135,
    396
   ],
   "atk": [
    10,
    30
   ],
   "atkRandom": null,
   "rage": [
    4,
    6
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 45,
   "skill": {
    "name": "Stabs",
    "desc": "Stabs 2 tiles in the target's direction, dealing ([100-150]% * Atk) DMG to up to 4 targets and restores 30% of the lost HP."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "lancer",
   "name": "Lancer",
   "cat": "spear",
   "hp": [
    104,
    305
   ],
   "atk": [
    12,
    37
   ],
   "atkRandom": null,
   "rage": [
    4,
    8
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 50,
   "skill": {
    "name": "Project",
    "desc": "Projects at the farthest enemy within 5 tiles, dealing ([70-120]% *ATK) DMG."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "daggeraxe",
   "name": "Dagger Axe",
   "cat": "spear",
   "hp": [
    88,
    257
   ],
   "atk": [
    8,
    24
   ],
   "atkRandom": null,
   "rage": [
    5,
    8
   ],
   "range": 2,
   "move": 2,
   "spd": 62,
   "crop": 3,
   "cost": 46,
   "skill": {
    "name": "Disarm",
    "desc": "Deals ([100-125]*ATK) DMG, reducing the target's ATK by [30-80]% for 3 rounds."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "modao",
   "name": "Modao",
   "cat": "spear",
   "hp": [
    94,
    277
   ],
   "atk": null,
   "atkRandom": [
    3,
    58
   ],
   "rage": [
    0,
    0
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 52,
   "skill": null,
   "passives": [
    {
     "name": "Erratic Attack",
     "desc": ""
    },
    {
     "name": "Cavalry Suffer",
     "desc": "Deals [(16-20)-(42-58)] random DMG to cavalry."
    }
   ],
   "upgradable": true
  },
  {
   "id": "longswordsman",
   "name": "Long Swordsman",
   "cat": "spear",
   "hp": [
    208,
    610
   ],
   "atk": [
    9,
    26
   ],
   "atkRandom": null,
   "rage": [
    6,
    10
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 47,
   "skill": {
    "name": "Whirlwind",
    "desc": "Deals [45-70]% DMG to up to 12 targets within 2 tiles and bleeds them, dealing ([45-70]%*ATK) True DMG each round, lasting for 3 rounds."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "twinspearman",
   "name": "Twin Spearman",
   "cat": "spear",
   "hp": [
    126,
    366
   ],
   "atk": [
    11,
    32
   ],
   "atkRandom": null,
   "rage": [
    5,
    8
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 50,
   "skill": {
    "name": "Unbridled Dance",
    "desc": "Dashes to the location with the most enemies within 4 tiles to dance wildly, dealing 2 stages of 35% DMG each to up to 8 targets within 2 tiles, with a [25-50]% chance of parrying DMG dealt by basic attacks for 1 round."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "saberandshield",
   "name": "Saber and Shield",
   "cat": "shield",
   "hp": [
    265,
    745
   ],
   "atk": [
    6,
    17
   ],
   "atkRandom": null,
   "rage": [
    12,
    15
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 60,
   "skill": {
    "name": "Shield",
    "desc": "Grants self and the ally with the lowest HP within 5 tiles a Shield which absorbs up to [30-80] DMG for 3 rounds. Rage cannot increase while self has this Shield."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "heavyshield",
   "name": "Heavy Shield",
   "cat": "shield",
   "hp": [
    318,
    895
   ],
   "atk": [
    4,
    11
   ],
   "atkRandom": null,
   "rage": [
    10,
    16
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 72,
   "skill": {
    "name": "Shield Stance",
    "desc": "DMG taken -[30-80]%, lasting for 3 rounds. While in Shield Stance, cannot act or increase Rage."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "spearandshield",
   "name": "Spear and Shield",
   "cat": "shield",
   "hp": [
    278,
    784
   ],
   "atk": [
    8,
    15
   ],
   "atkRandom": null,
   "rage": [
    5,
    10
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 63,
   "skill": {
    "name": "Charge",
    "desc": "Charges towards the furthest target within 5 tiles, dealing ([100-125]*ATK) DMG and blockingthe next attack."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "hammerandshield",
   "name": "Hammer and Shield",
   "cat": "shield",
   "hp": [
    239,
    673
   ],
   "atk": [
    5,
    14
   ],
   "atkRandom": null,
   "rage": [
    10,
    15
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 65,
   "skill": {
    "name": "Earthshaker",
    "desc": "Deals DMG to up to ([70-100]*ATK) 12 targets within 2 tiles, with a 100% chance to silence them, disabling their Rage boost and skill casting for 2 rounds."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "swordandshield",
   "name": "Sword and Shield",
   "cat": "shield",
   "hp": [
    159,
    431
   ],
   "atk": [
    3,
    8
   ],
   "atkRandom": null,
   "rage": [
    8,
    15
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 124,
   "skill": {
    "name": "Guardian Shield",
    "desc": "Deals [100-125]% ATK DMG to the target, and gains Shield point equal to 80% DMG for 3 turns."
   },
   "passives": [
    {
     "name": "Trainee Warrior",
     "desc": "With each Boar Knight slayed, Sword&Shield Soldiers gain astack of Leap for ATK +0.5 andHP +5. 0 stacks of Leap gained, up to [10-100] at current level."
    }
   ],
   "upgradable": true
  },
  {
   "id": "axeandshield",
   "name": "Axe and Shield",
   "cat": "shield",
   "hp": [
    212,
    598
   ],
   "atk": [
    10,
    30
   ],
   "atkRandom": null,
   "rage": [
    4,
    6
   ],
   "range": 1,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 67,
   "skill": {
    "name": "Whirling Axe",
    "desc": "Selects 1 random target from 4 tiles around and throws a Whirling Axe to the target, dealing ([75-100]*ATK) DMG and bouncing once within 3 tilesaround the target."
   },
   "passives": [
    {
     "name": "Shield Bash",
     "desc": "If the Whirling Axe's selected target is within 1 tile, releases Shield Bash instead of throwing the Whirling Axe out, dealing [100-125]*ATK with a[25-50]% chance to stun the target for 1 round."
    }
   ],
   "upgradable": true
  },
  {
   "id": "longbowman",
   "name": "Longbowman",
   "cat": "bow",
   "hp": [
    78,
    128
   ],
   "atk": [
    7,
    17
   ],
   "atkRandom": null,
   "rage": [
    6,
    8
   ],
   "range": 4,
   "move": 2,
   "spd": 62,
   "crop": 3,
   "cost": 82,
   "skill": {
    "name": "Scatter",
    "desc": "Additionally attacks 2 target within 6 tiles, dealing [50-100]% DMG."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "crossbowman",
   "name": "Crossbowman",
   "cat": "bow",
   "hp": [
    117,
    268
   ],
   "atk": [
    6,
    14
   ],
   "atkRandom": null,
   "rage": [
    2,
    4
   ],
   "range": 3,
   "move": 3,
   "spd": 62,
   "crop": 3,
   "cost": 81,
   "skill": {
    "name": "Rapid Fire",
    "desc": "Fires at the target 3 times, dealing 100% DMG the 1st time and [45-70]% DMG afterward."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "toxibowman",
   "name": "Toxibowman",
   "cat": "bow",
   "hp": [
    76,
    122
   ],
   "atk": [
    5,
    10
   ],
   "atkRandom": null,
   "rage": [
    4,
    6
   ],
   "range": 4,
   "move": 2,
   "spd": 62,
   "crop": 3,
   "cost": 82,
   "skill": {
    "name": "Poison Arrow",
    "desc": "Poisons the target, dealing True DMG by [1-3.5]% of max HP each round and reducing HP restoration by [55-80]% for 3 rounds. Each target can have only 1 poison debuff."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "hunter",
   "name": "Hunter",
   "cat": "bow",
   "hp": [
    94,
    150
   ],
   "atk": [
    7,
    12
   ],
   "atkRandom": null,
   "rage": [
    12,
    12
   ],
   "range": 4,
   "move": 2,
   "spd": 62,
   "crop": 3,
   "cost": 84,
   "skill": {
    "name": "Inspire",
    "desc": "Inspires all allies within the ATK Range to boost ATK by [2-9] for 3 rounds. Each target can have only 1 inspiration buff, which won't work on weaponry."
   },
   "passives": [
    {
     "name": "Hunting",
     "desc": "When attacking Beast, ATK + 30%."
    }
   ],
   "upgradable": true
  },
  {
   "id": "improvedcrossbowman",
   "name": "Improved Crossbowman",
   "cat": "bow",
   "hp": [
    55,
    70
   ],
   "atk": [
    15,
    38
   ],
   "atkRandom": null,
   "rage": [
    0,
    0
   ],
   "range": 5,
   "move": 2,
   "spd": 62,
   "crop": 3,
   "cost": 86,
   "skill": null,
   "passives": [
    {
     "name": "Draw",
     "desc": "1 round is required to reload arrows and hold the string before each attack."
    },
    {
     "name": "Anchor",
     "desc": "Per tile from the target upon attacking, DMG +[15-20]%"
    }
   ],
   "upgradable": true
  },
  {
   "id": "firebowman",
   "name": "Fire Bowman",
   "cat": "bow",
   "hp": [
    78,
    128
   ],
   "atk": [
    6,
    11
   ],
   "atkRandom": null,
   "rage": [
    8,
    10
   ],
   "range": 4,
   "move": 2,
   "spd": 62,
   "crop": 3,
   "cost": 87,
   "skill": {
    "name": "Fire Arrow",
    "desc": "Shoots a fire arrow to an enemy within 7 tiles, setting theirground on fire. The enemy on the burning ground takes ([55-80] *ATK)*Fire Intensity Level] additional True DMG each round."
   },
   "passives": [
    {
     "name": "Fire Intensity",
     "desc": "The burning fire on the ground. Each time it is triggered, the Fire Intensity Level is upgraded by 1 and will be degraded after reaching Lv. 3 until the fire burns out."
    }
   ],
   "upgradable": true
  },
  {
   "id": "swordcavalry",
   "name": "Sword Cavalry",
   "cat": "cavalry",
   "hp": [
    155,
    475
   ],
   "atk": [
    14,
    43
   ],
   "atkRandom": null,
   "rage": [
    4,
    10
   ],
   "range": 1,
   "move": 4,
   "spd": 74,
   "crop": 4,
   "cost": 82,
   "skill": {
    "name": "Leap Slash",
    "desc": "Leaps to the target with the lowest HP within 5 tiles and slashes it, dealing ([100-125]%*ATK + 10% of the target's lost HP) DMG."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "spearcavalry",
   "name": "Spear Cavalry",
   "cat": "cavalry",
   "hp": [
    186,
    569
   ],
   "atk": [
    10,
    31
   ],
   "atkRandom": null,
   "rage": [
    6,
    10
   ],
   "range": 1,
   "move": 4,
   "spd": 74,
   "crop": 4,
   "cost": 84,
   "skill": {
    "name": "Sweep",
    "desc": "Deals [45-70]% DMG to up to 20 targets within 3 tiles. If the target is within 1 tile, DMG Dealt +30%."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "broadswordcavalry",
   "name": "Broadsword Cavalry",
   "cat": "cavalry",
   "hp": [
    126,
    386
   ],
   "atk": [
    18,
    53
   ],
   "atkRandom": null,
   "rage": [
    2,
    4
   ],
   "range": 1,
   "move": 4,
   "spd": 74,
   "crop": 4,
   "cost": 92,
   "skill": {
    "name": "Chop",
    "desc": "Chops the target, dealing ([20-30]*ATK) additional True DMG. The additional True DMG stacks with each chop on the same target until another target is chosen."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "heavycavalry",
   "name": "Heavy Cavalry",
   "cat": "cavalry",
   "hp": [
    256,
    781
   ],
   "atk": [
    7,
    23
   ],
   "atkRandom": null,
   "rage": [
    4,
    12
   ],
   "range": 1,
   "move": 4,
   "spd": 74,
   "crop": 4,
   "cost": 107,
   "skill": {
    "name": "Collide",
    "desc": "Collides by 2 tiles in the target direction and knocks up encountered enemies, dealing ([75-100]*ATK) DMG. Can break shields and shield stance."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "bowcavalry",
   "name": "Bow Cavalry",
   "cat": "cavalry",
   "hp": [
    93,
    232
   ],
   "atk": [
    8,
    18
   ],
   "atkRandom": null,
   "rage": [
    2,
    6
   ],
   "range": 4,
   "move": 4,
   "spd": 74,
   "crop": 4,
   "cost": 84,
   "skill": {
    "name": "Equestrian Archery",
    "desc": "Moves by 1 tile and fires at the nearest target, dealing 100%DMG at the first time. Afterward, deals [30-80]% DMG. Can move up to 4 time(s)."
   },
   "passives": [],
   "upgradable": true
  },
  {
   "id": "axecavalry",
   "name": "Axe Cavalry",
   "cat": "cavalry",
   "hp": [
    202,
    618
   ],
   "atk": [
    9,
    26
   ],
   "atkRandom": null,
   "rage": [
    0,
    0
   ],
   "range": 1,
   "move": 4,
   "spd": 74,
   "crop": 4,
   "cost": 88,
   "skill": null,
   "passives": [
    {
     "name": "Shattered Armor",
     "desc": "DMG +[50-100]% against a target with Shield."
    },
    {
     "name": "Cleave",
     "desc": "There is a 50% chance to deal [45-70]% DMG to up to 4 enemies within 1 tile around the target upon attacking. The DMG is considered as basic attack DMG and is halved if self ATK Range is more than 1 tile."
    }
   ],
   "upgradable": true
  }
 ],
 "weaponry": [
  {
   "id": "catapult",
   "name": "Catapult",
   "cat": "weaponry",
   "hp": [
    50
   ],
   "atk": [
    15,
    15
   ],
   "atkRandom": null,
   "rage": [
    0,
    0
   ],
   "range": 5,
   "move": 1,
   "spd": 46,
   "crop": 5,
   "cost": 60,
   "skill": null,
   "passives": [
    {
     "name": "Counter Building",
     "desc": "When attacking Building, ATK +2."
    }
   ],
   "upgradable": false
  },
  {
   "id": "trebuchet",
   "name": "Trebuchet",
   "cat": "weaponry",
   "hp": [
    50
   ],
   "atk": [
    18,
    18
   ],
   "atkRandom": null,
   "rage": [
    0,
    0
   ],
   "range": 5,
   "move": 1,
   "spd": 46,
   "crop": 5,
   "cost": 60,
   "skill": null,
   "passives": [
    {
     "name": "Penetration",
     "desc": ""
    }
   ],
   "upgradable": false
  }
 ],
 "heroes": [
  {
   "id": "chendaoshuzhi",
   "num": 1,
   "name": "Chen Dao (Shuzhi)",
   "skillName": "Common Hope",
   "cat": "spear",
   "possession": "Longspearman",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    16
   ],
   "desc": "When attacking, also deals (10%*All allied Soldiers ATK) additional DMG. Meanwhile, transfers [40-80]% of ATK DMG taken by self to the Soldier with the highest HP percentage.",
   "unique": "Longspearman's Stab restores HP for the ally with the lowest HP ratio by 20% of their lost HP.",
   "subId": "longspearman"
  },
  {
   "id": "zhaoyunzilong",
   "num": 2,
   "name": "Zhao Yun (Zilong)",
   "skillName": "Valor of Loong",
   "cat": "spear",
   "possession": "Longspearman",
   "hp": [
    150,
    250
   ],
   "atk": [
    8,
    16
   ],
   "desc": "Any Dodge +10%, +5% when taking ATK DMG, stackable without limit each round. Increases next attack's DMG by [10-20]% after dodging successfully each time.",
   "unique": "Spearman's Any Dodge +5%. After dodging, Rage +1.",
   "subId": "longspearman"
  },
  {
   "id": "yangmiaozhen",
   "num": 3,
   "name": "Yang Miaozhen",
   "skillName": "True Sight",
   "cat": "spear",
   "possession": "Longspearman",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    16
   ],
   "desc": "The first target will be marked for 2 rounds when being stabbed. When self attacks the marked target, deals additional True DMG equal to 15% of their Max HP and restores HP equal to [20-50]% of the DMG.",
   "unique": "When Longspearman attacks, deals (2%*target's max HP) additional True DMG.",
   "subId": "longspearman"
  },
  {
   "id": "zhanghejunyi",
   "num": 1,
   "name": "Zhang He (Junyi)",
   "skillName": "Intimidating Force",
   "cat": "spear",
   "possession": "Lancer",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    17
   ],
   "desc": "Increases Project DMG by [10-30]%. If a target is killed by Project, horrifies up to 4 enemies within 2 tile around the target, making them unable to move or attack for I round, except those in Shield Stance or with weaponry.",
   "unique": "Lancer's Project DMG +20%",
   "subId": "lancer"
  },
  {
   "id": "qinliangyuzhensu",
   "num": 2,
   "name": "Qin Liangyu (Zhensu)",
   "skillName": "Barb",
   "cat": "spear",
   "possession": "Lancer",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    16
   ],
   "desc": "The Lance will stay at the target position when being projected. Will take the Lance back instead of attacking in the next round. When taking the Lance back, if no enemy is at the target position, increases Rage by 75%; otherwise, deals ([100-150]%*ATK) DMG to the target.",
   "unique": "After Lancers kill the target by projecting, increases Rage by 2.",
   "subId": "lancer"
  },
  {
   "id": "baiqi",
   "num": 1,
   "name": "Bai Qi",
   "skillName": "Merciless Siege",
   "cat": "spear",
   "possession": "Dagger-axe Soldier",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    14
   ],
   "desc": "When disarming the target, transfers [50-100]% of their ATK Reduction to up to 12 allies within 4 tiles around the target for 3 rounds, prioritizing disarming allies with the highest ATK.",
   "unique": "When an enemy dies, ATK +1 for up to 4 allies within 1 tile",
   "subId": "daggeraxe"
  },
  {
   "id": "zhouyugongjin",
   "num": 2,
   "name": "Zhou Yu (Gongjin)",
   "skillName": "Chains",
   "cat": "spear",
   "possession": "Dagger-axe Soldier",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    14
   ],
   "desc": "When disarming the target, connects the target with up to 8 enemies (except for Weaponry) within 2 tile for 3 rounds. When any target takes ATK DMG, other connected targets will take [30-50] DMG.",
   "unique": "When Dagger-axe Soldier attacks, deals (20%*ATK) additional True DMG to up to 4 enemies within 1 tile around the target.",
   "subId": "daggeraxe"
  },
  {
   "id": "limu",
   "num": 3,
   "name": "Li Mu",
   "skillName": "Strength Gathering",
   "cat": "spear",
   "possession": "Dagger-axe Soldier",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    14
   ],
   "desc": "When releasing Disarm, up to 8 allies with the highest ATK within self ATK Range gain 30% DMG Reduction for 1 round. Afterward, deals ([30-50]%*ATK) additional True DMG when attacking for 3 rounds.",
   "unique": "All allies' DMG Reduction +15%",
   "subId": "daggeraxe"
  },
  {
   "id": "lisiye",
   "num": 1,
   "name": "Li Siye",
   "skillName": "Brave Spirit",
   "cat": "spear",
   "possession": "Modao Soldier",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    20
   ],
   "desc": "Deals ATK DMG equal to the random DMG dealt by Cavalry Suffer. Gains 2 ATK and 3% Dodge when any enemy dies within self ATK Range, stackable up to [5-15] time(s).",
   "unique": "Modifies Modao Soldier's counter effect on Cavalry to 60%",
   "subId": "modao"
  },
  {
   "id": "yujinwenze",
   "num": 2,
   "name": "Yu Jin (Wenze)",
   "skillName": "Unwavering General",
   "cat": "spear",
   "possession": "Modao Soldier",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    18
   ],
   "desc": "When a battle starts, increases DMG dealt and taken by [50-100]% for all non-weaponry ally soldiers of the current army and make them immune to debuffs. This effect ends when Yu Jin is killed.",
   "unique": "When Modao Soldier has full HP, DMG Dealt +15%.",
   "subId": "modao"
  },
  {
   "id": "jiangweiboyue",
   "num": 1,
   "name": "Jiang Wei (Boyue)",
   "skillName": "Wisdom & Bravery",
   "cat": "spear",
   "possession": "Long Swordsman",
   "hp": [
    125,
    225
   ],
   "atk": [
    8,
    14
   ],
   "desc": "Each time Whirlwind is released, gains 4 ATK and 6% DMG Reduction, stackable up to [5-10] time(s).",
   "unique": "Long Swordsman's ATK +8 and they gain 15% DMG Reduction.",
   "subId": "longswordsman"
  },
  {
   "id": "lmengziming",
   "num": 2,
   "name": "Lü Meng (Ziming)",
   "skillName": "Self-denial",
   "cat": "spear",
   "possession": "Long Swordsman",
   "hp": [
    125,
    225
   ],
   "atk": [
    8,
    14
   ],
   "desc": "Max Rage -50%. Stops releasing Whirlwind for the first 3 times and gains 40 Shield instead. Afterward, increases DMG dealt by [20-50]%. Meanwhile, for every 1 target hit by Whirlwind, gains 40 Shield.",
   "unique": "If the battle lasts for more than 30 minutes, all allies' DMG dealt + 20%.",
   "subId": "longswordsman"
  },
  {
   "id": "xinqijiyouan",
   "num": 3,
   "name": "Xin Qiji (Youan)",
   "skillName": "Looking Back",
   "cat": "spear",
   "possession": "Long Swordsman",
   "hp": [
    125,
    225
   ],
   "atk": [
    8,
    14
   ],
   "desc": "Gains Iron Weapon in the first 23 rounds upon entering a battle, ATK +[30-50]%, and reduces DMG taken by 30%. Gains Sorrowful Dream after the 23 rounds and gains Iron Weapon for 1 round for every 3 attacks released.",
   "unique": "The DMG dealt by all allies' first 20 attacks",
   "subId": "longswordsman"
  },
  {
   "id": "wenyangciqian",
   "num": 1,
   "name": "Wen Yang (Ciqian)",
   "skillName": "Brave Charge",
   "cat": "spear",
   "possession": "Twin Spearman",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    16
   ],
   "desc": "Unbridled Dance only deals 1 stage of DMG. After each Unbridled Dance, there is a chance of dashing again. The chance of the first dash is 100% and the subsequent chances are [40-70]%. Can dash up to 7 times.",
   "unique": "Twin Spearman's Parry Rate +5% after Unbridled Dance, Rage +1 after Parry.",
   "subId": "twinspearman"
  },
  {
   "id": "dianwei",
   "num": 2,
   "name": "Dian Wei",
   "skillName": "Courage",
   "cat": "spear",
   "possession": "Twin Spearman",
   "hp": [
    125,
    225
   ],
   "atk": [
    8,
    14
   ],
   "desc": "When gaining 1 Rage, ATK +1, stackable up to [20-50] time(s). After the effect is stacked to 20 times, Unbridled Dance Stages+1.",
   "unique": "Twin Spearman's Stage of Unbridled Dance +1",
   "subId": "twinspearman"
  },
  {
   "id": "qinqiongshubao",
   "num": 3,
   "name": "Qin Qiong (Shubao)",
   "skillName": "Surmount Difficulties",
   "cat": "spear",
   "possession": "Twin Spearman",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    16
   ],
   "desc": "Unbridled Dance only dashes to the enemy hero or the target with the highest AT K, dealing 1 stage of ( 2000/0*ATK) DMG and Parry Rate +20%. Meanwhile, the following 2 basic attacks deal ([15-30]%*target's Max HP) additional DMG.",
   "unique": "DMG dealt by Spearman to Heroes +30%",
   "subId": "twinspearman"
  },
  {
   "id": "xushengwenxiang",
   "num": 1,
   "name": "Xu Sheng (Wenxiang)",
   "skillName": "Safe Shelter",
   "cat": "shield",
   "possession": "Saber&Shield Soldier",
   "hp": [
    250,
    500
   ],
   "atk": [
    2,
    5
   ],
   "desc": "When releasing Shield, also grants Safe Shelter to up to 10 allies, making them immune to debuffs and gain [10-30]% Leech for 5 rounds. When allies within 5 tiles are inflicted with debuffs, increases self Rage by 1.",
   "unique": "Saber & Shield Soldier grants shield on 2 more allies",
   "subId": "saberandshield"
  },
  {
   "id": "yuejinwenqian",
   "num": 2,
   "name": "Yue Jin (Wenqian)",
   "skillName": "First to Arrive",
   "cat": "shield",
   "possession": "Saber&Shield Soldier",
   "hp": [
    250,
    500
   ],
   "atk": [
    2,
    5
   ],
   "desc": "When a battle starts, attracts the enemy buildings to attack self, with an 80% chance of dodging the building's attacks. Deals ([20-40]%*Dodged DMG) additional DMG when attacking non-building targets the next time.",
   "unique": "All allies have a 20% chance of dodging building's attacks.",
   "subId": "saberandshield"
  },
  {
   "id": "caorenzixiao",
   "num": 1,
   "name": "Cao Ren (Zixiao)",
   "skillName": "Strong Will",
   "cat": "shield",
   "possession": "Heavy Shield Soldier",
   "hp": [
    300,
    600
   ],
   "atk": [
    1,
    4
   ],
   "desc": "When taking DMG each time, Max HP +8, stackable up to [20-50] time(s). After the effect is stacked to 20 times, restores HP by 1% of Max HP each round.",
   "unique": "Heavy Shield Soldier's Max HP + 20%",
   "subId": "heavyshield"
  },
  {
   "id": "zhoutaiyouping",
   "num": 2,
   "name": "Zhou Tai (Youping)",
   "skillName": "Support",
   "cat": "shield",
   "possession": "Heavy Shield Soldier",
   "hp": [
    300,
    600
   ],
   "atk": [
    1,
    4
   ],
   "desc": "Takes ATK DMG for allies within 5 tiles and has a [10/30]% chance to restore 20% of the Max HP when dying. The chance will be reduced by 10% after the effect is triggered each time, up to 50%.",
   "unique": "When Heavy Shield Soldier's HP is below 50%, restores 1% of the Max HP each round.",
   "subId": "heavyshield"
  },
  {
   "id": "zhangfeiyide",
   "num": 1,
   "name": "Zhang Fei (Yide)",
   "skillName": "Furious Roar",
   "cat": "shield",
   "possession": "Spear&Shield Soldier",
   "hp": [
    150,
    350
   ],
   "atk": [
    8,
    14
   ],
   "desc": "Roars after a Charge. Deals additional True DMG equal to [40-70]% of the effective DMG from this Charge to up to 8 enemies within 2 tiles and terrifies them, making them unable to move for 3 rounds.",
   "unique": "Shield Soldier's DMG taken -20% when there are no allies around.",
   "subId": "spearandshield"
  },
  {
   "id": "gaoshun",
   "num": 2,
   "name": "Gao Shun",
   "skillName": "Onslaught",
   "cat": "shield",
   "possession": "Spear&Shield Soldier",
   "hp": [
    150,
    350
   ],
   "atk": [
    8,
    14
   ],
   "desc": "When a battle starts, increases Max HP by 10% and ATK by [10-30]% for all non-weaponry ally soldiers of the current army; meanwhile, for every 1% HP lost, increases DMG dealt by 1%. This effect ends when Gao Shun is killed.",
   "unique": "When Spear & Shield Soldier has no allies around, DMG dealt +20",
   "subId": "spearandshield"
  },
  {
   "id": "huanggaigongfu",
   "num": 1,
   "name": "Huang Gai (Gongfu)",
   "skillName": "Deliberate Sacrifice",
   "cat": "shield",
   "possession": "Hammer&Shield Soldier",
   "hp": [
    200,
    400
   ],
   "atk": [
    4,
    8
   ],
   "desc": "At the start of the first round, deducts self HP by 20% of Max HP, grants the 30 closest allies and self a shield equal to [20-50]%, and increases their ATK by 10% till the end of the battle.",
   "unique": "When an ally dies, Max HP +10 for up to 4 allies within 1 tile, stackable up to 20 times.",
   "subId": "hammerandshield"
  },
  {
   "id": "lianpo",
   "num": 2,
   "name": "Lian Po",
   "skillName": "Utmost Protection",
   "cat": "shield",
   "possession": "Hammer&Shield Soldier",
   "hp": [
    200,
    400
   ],
   "atk": [
    4,
    8
   ],
   "desc": "If HP is above 50%, increases DMG dealt by 25% for self and up to 12 allies within 3 tiles; if HP is lower than 50%, reduces DMG taken by 25% for self and up to 12 allies within 3 tiles. Additionally increases self effect by [50-100]%.",
   "unique": "All allies' DMG dealt +10%, DMG taken -10%",
   "subId": "hammerandshield"
  },
  {
   "id": "caocaomengde",
   "num": 1,
   "name": "Cao Cao (Mengde)",
   "skillName": "Ambitious Spirit",
   "cat": "shield",
   "possession": "Sword&Shield Soldier",
   "hp": [
    150,
    350
   ],
   "atk": [
    4,
    8
   ],
   "desc": "Each attack grants I layer of Morale on up to 20 allies within 3 tiles. Each layer of Morale increases Max HP by 10 and ATK by I, stackable up to [10-20] layers. All layers of Morale will be removed after Cao Cao's death.",
   "unique": "All allies' Max HP +40, ATK +4",
   "subId": "swordandshield"
  },
  {
   "id": "dengaishizai",
   "num": 2,
   "name": "Deng Ai (Shizai)",
   "skillName": "Garrison Field",
   "cat": "shield",
   "possession": "Sword&Shield Soldier",
   "hp": [
    150,
    350
   ],
   "atk": [
    4,
    8
   ],
   "desc": "At the start of the first round, sends Garrison Order to 30 closest allies: reducing their DMG dealt by 20% for 5 rounds, then increasing their DMG dealt by 10% and restoring [10-30] HP each round.",
   "unique": "Restores 10 HP for all allies at the start of each round.",
   "subId": "swordandshield"
  },
  {
   "id": "menghuo",
   "num": 1,
   "name": "Meng Huo",
   "skillName": "Resurgence",
   "cat": "shield",
   "possession": "Axe&Shield Soldier",
   "hp": [
    150,
    350
   ],
   "atk": [
    8,
    16
   ],
   "desc": "After being attacked each time, DMG dealt +[10-20]% Restores 10% of the lost HP after the effect is stacked to 7 layers and then restacks from the beginning.",
   "unique": "If all allies are on the attacking side, ATK +15%.",
   "subId": "axeandshield"
  },
  {
   "id": "huangzhonghansheng",
   "num": 1,
   "name": "Huang Zhong (Hansheng)",
   "skillName": "Excellent Shot",
   "cat": "bow",
   "possession": "Longbowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    12
   ],
   "desc": "When the HP of the target is below 60%, there is a [15-30]% chance of killing them directly. The chance will be doubled when the target's HP is below 30% and prioritizes attacking the target with the lowest HP ratio.",
   "unique": "Bowman's DMG dealt +20% to the target with HP over 50%",
   "subId": "longbowman"
  },
  {
   "id": "handangyigong",
   "num": 2,
   "name": "Han Dang (Yigong)",
   "skillName": "Ape Arm",
   "cat": "bow",
   "possession": "Longbowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    12
   ],
   "desc": "Basic attack deals (current rage*[30-50]%*ATK) additional True DMG and 1 Rage is reserved after Scatter.",
   "unique": "Longbowman's Max Rage +1, DMG Dealt +20%",
   "subId": "longbowman"
  },
  {
   "id": "liubeixuande",
   "num": 1,
   "name": "Liu Bei (Xuande)",
   "skillName": "Benevolent Gesture",
   "cat": "bow",
   "possession": "Crossbowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "Rapid Fire deals no more DMG to enemies and restores HP by [10-20]% of their Max HP for the ally with the lowest HP ratio instead. Increases the restoration effect by 30% when self reaches the max level. Exclusive Equipment Effect: Rapid Fire Time +1.",
   "unique": "All allies' HP Restoration +30%",
   "subId": "crossbowman"
  },
  {
   "id": "liuchong",
   "num": 2,
   "name": "Liu Chong",
   "skillName": "Precision",
   "cat": "bow",
   "possession": "Crossbowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "When releasing Rapid Fire, for every 1 arrow shot, there is a [20-50]% chance of shooting 1 more arrow, up to 10 arrows can be shot.",
   "unique": "Crossbowman's Rapid Fire Attempt +1",
   "subId": "crossbowman"
  },
  {
   "id": "diaochan",
   "num": 3,
   "name": "Diao Chan",
   "skillName": "Moonveil",
   "cat": "bow",
   "possession": "Crossbowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "Every 4 rounds, makes 1 hero or the enemy with the highest ATK within ATK Range obsessed for 2 rounds. Obsessed targets will attack their allies; if no attack is performed, they take additional True DMG equal to [100-150]% of ATK. At self max level, affects +1 target.",
   "unique": "Crossbowman Exclusive Equipment's initial Dodge Rate + 10%.",
   "subId": "crossbowman"
  },
  {
   "id": "wangyi",
   "num": 1,
   "name": "Wang Yi",
   "skillName": "Poison Mist",
   "cat": "bow",
   "possession": "Toxibowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "When shooting Poison Arrows, reduces Hit for up to 12 enemies within 3 tiles, making them have a [40-80]% chance to miss the target for 2 rounds when attacking; if the target is paralyzed, +1 round.",
   "unique": "Toxibowman's Exclusive Equipment has 10% more chance to paralyze the target.",
   "subId": "toxibowman"
  },
  {
   "id": "liruwenyou",
   "num": 2,
   "name": "Li Ru (Wenyou)",
   "skillName": "Poisoned Wine",
   "cat": "bow",
   "possession": "Toxibowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "Poison Arrow also inflicts Poisoned Wine for 3 rounds. When the target dies or at the end of a round, deals additional True DMG equal to [20-50]% of the total DMG taken by the target within the duration of Poisoned Wine to up to 8 enemies within 2 tiles.",
   "unique": "Target's HP Restoration Reduction caused by Toxibowman's Poison +15%",
   "subId": "toxibowman"
  },
  {
   "id": "yangyoujishu",
   "num": 1,
   "name": "Yang Youji (Shu)",
   "skillName": "Call of Wild",
   "cat": "bow",
   "possession": "Hunter",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "Stops releasing Inspire and summons a beast. If the beast already exists, feeds it to restore its HP by [10-30]% of its Max HP instead. (Exclusive Equipment: When the beast is fed each time, its Max HP +4%, ATK +6%, stackable up to 25 times.).",
   "unique": "Hunter's Max Rage -50%",
   "subId": "hunter"
  },
  {
   "id": "sunquanzhongmou",
   "num": 2,
   "name": "Sun Quan (Zhongmou)",
   "skillName": "Wise Ruler",
   "cat": "bow",
   "possession": "Hunter",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "When inspiring, additionally increases[10-30]% ATK for 4 allies with the highest ATK. When self reaches the max level, inflicts the effect on 4 more targets. ( Exclusive Equipment: Also increases 50% Rage for these allies with the highest ATK, excluding self.)",
   "unique": "All allies' Max Rage can be exceeded",
   "subId": "hunter"
  },
  {
   "id": "lianghongyu",
   "num": 3,
   "name": "Liang Hongyu",
   "skillName": "War Drum",
   "cat": "bow",
   "possession": "Hunter",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "When inspiring, also grants allies [10-15]% DMG Reduction. Doubles the effect if self reaches the max level. Exclusive Equipment Effect: In the duration of inspiring, restores 2% of Max HP for self each round.",
   "unique": "Duration of Inspire released by Hunter +1",
   "subId": "hunter"
  },
  {
   "id": "caiyan",
   "num": 4,
   "name": "Cai Yan",
   "skillName": "Elegy",
   "cat": "bow",
   "possession": "Hunter",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "When inspiring, additionally restores 5% Max HP to the 3 allies with the lowest HP ratio. Has a [50-100]% chance to make them deal additional True DMG equal to 30% ATK when attacking for 3 rounds. If self is max leveled, targets +3.",
   "unique": "When Hunters inspiring, they have a 20% chance to remove 1 debuff from allies.",
   "subId": "hunter"
  },
  {
   "id": "caoxiuwenlie",
   "num": 1,
   "name": "Cao Xiu (Wenlie)",
   "skillName": "Sniper Fire",
   "cat": "bow",
   "possession": "Improved Crossbowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    12
   ],
   "desc": "Prioritizes the furthest target. If the target is at the maximum ATK Range, DMG dealt to it +[10-30]%.",
   "unique": "Improved Crossbowman's Anchor is always calculated based on the farthest distance",
   "subId": "improvedcrossbowman"
  },
  {
   "id": "sunshangxiang",
   "num": 2,
   "name": "Sun Shangxiang",
   "skillName": "Ambitious Belle",
   "cat": "bow",
   "possession": "Improved Crossbowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "For every 5 rounds, stuns I enemy with the highest ATK for 3 rounds and restores HP by [10-30]% of Max HP for 1 ally with the lowest HP ratio. When self reaches the max level, affected target +1 respectively.",
   "unique": "When Improved Crossbowman is dying for the first time, restores HP by of Max HP.",
   "subId": "improvedcrossbowman"
  },
  {
   "id": "luxunboyan",
   "num": 1,
   "name": "Lu Xun (Boyan)",
   "skillName": "Burning Tents",
   "cat": "bow",
   "possession": "Fire Bowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "After shooting a fire arrow, there is a [15-30]% chance of spreading the fire on the allies' ground by 1 tile towards the enemies.",
   "unique": "When Fire Bowman shoots a fire arrow, there is a 50% chance of spreading the fire by 1 tile towards the enemies.",
   "subId": "firebowman"
  },
  {
   "id": "zhuyuanzhang",
   "num": 2,
   "name": "Zhu Yuanzhang",
   "skillName": "Hongwu",
   "cat": "bow",
   "possession": "Fire Bowman",
   "hp": [
    50,
    100
   ],
   "atk": [
    4,
    10
   ],
   "desc": "When an enemy dies on our flames, there is a [50-100]% chance to create Imperial Legacy. Allies within Imperial Legacy deal 50% more DMG and restore 5% Max HP each turn. Imperial Legacy disappears when Zhu Yuanzhang dies.",
   "unique": "All allies' DMG dealt to the target standing on our flames +20%",
   "subId": "firebowman"
  },
  {
   "id": "zhangliaowenyuan",
   "num": 1,
   "name": "Zhang Liao (wenyuan)",
   "skillName": "Surprise Attack",
   "cat": "cavalry",
   "possession": "Sword Cavalry",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    17
   ],
   "desc": "If the target of Leap Slash survives, deals ( [20-50]% *ATK) additional True DMG again to up to 8 enemies within 2 tiles and grants self 50% DMG Reduction for 1 round.",
   "unique": "Cavalry's DMG dealt to the target with no allies around +20%",
   "subId": "swordcavalry"
  },
  {
   "id": "huoqubing",
   "num": 2,
   "name": "Huo Qubing",
   "skillName": "Swift Leap",
   "cat": "cavalry",
   "possession": "Sword Cavalry",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    17
   ],
   "desc": "When a battle starts, each time a Sword Cavalry in the current army releases Leap Slash, increases Rage by I for another Sword Cavalry in the army and increases their Leap Slash DMG by [5-10]% next time. This effect can be stacked and will end when Huo Qubing is killed.",
   "unique": "Sword Cavalry's Leap Slash Range +1",
   "subId": "swordcavalry"
  },
  {
   "id": "lbufengxian",
   "num": 1,
   "name": "Lü Bu (Fengxian)",
   "skillName": "Peerless Strike",
   "cat": "cavalry",
   "possession": "Spear Cavalry",
   "hp": [
    150,
    300
   ],
   "atk": [
    8,
    16
   ],
   "desc": "Self Leech If the targets hit are fewer than the threshold value of (4x Sweep Range) when sweeping, multiplies the DMG dealt by [Threshold value/The number of targets hit].",
   "unique": "Spear Cavalry's Sweep +10% Leech",
   "subId": "spearcavalry"
  },
  {
   "id": "machaomengqi",
   "num": 2,
   "name": "Ma Chao (Mengqi)",
   "skillName": "Full Chase",
   "cat": "cavalry",
   "possession": "Spear Cavalry",
   "hp": [
    150,
    300
   ],
   "atk": [
    8,
    16
   ],
   "desc": "Sweep Range +1. After releasing Sweep, chases the target with the lowest HP within the Sweep Range once, dealing([100-150]%*atk) True DMG.",
   "unique": "Spear Cavalry's DMG Dealt to the farthest target within the Sweep Range +30%",
   "subId": "spearcavalry"
  },
  {
   "id": "xiangyu",
   "num": 3,
   "name": "Xiang Yu",
   "skillName": "Overlord",
   "cat": "cavalry",
   "possession": "Spear Cavalry",
   "hp": [
    150,
    300
   ],
   "atk": [
    8,
    16
   ],
   "desc": "Increases Sweep's DMG by ([5-10]*number of targets hit)% and knocks targets back by 1 tile, making the targets unable to move for 1 round.",
   "unique": "When enemy soldiers outnumber ally soldiers, all ally soldiers' DMG dealt +20%.",
   "subId": "spearcavalry"
  },
  {
   "id": "guanyuyunchang",
   "num": 1,
   "name": "Guan Yu (Yunchang)",
   "skillName": "Martial Saint",
   "cat": "cavalry",
   "possession": "Broadsword Cavalry",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    20
   ],
   "desc": "Each time when attacking a new target, increases Rage by 100%. Increases Chop DMG by [20-50]% for the next 3 times.",
   "unique": "Cavalry's DMG dealt to the target with lower ATK +20%",
   "subId": "broadswordcavalry"
  },
  {
   "id": "guanyinping",
   "num": 2,
   "name": "Guan Yinping",
   "skillName": "Tiger's Roar",
   "cat": "cavalry",
   "possession": "Broadsword Cavalry",
   "hp": [
    100,
    200
   ],
   "atk": [
    8,
    18
   ],
   "desc": "After 1 chop is released, the next chop will become Tiger's Roar instead. Meanwhile, deals additional True DMG by [50-100]% of this chop to up to 4 enemies within 2 tiles around the target and stuns them for 1 round.",
   "unique": "Broadsword Cavalry keeps 2 Rage after casting skills.",
   "subId": "broadswordcavalry"
  },
  {
   "id": "xuchuzhongkang",
   "num": 1,
   "name": "Xu Chu (Zhongkang)",
   "skillName": "Blind Loyalty",
   "cat": "cavalry",
   "possession": "Heavy Cavalry",
   "hp": [
    250,
    500
   ],
   "atk": [
    4,
    10
   ],
   "desc": "After Collision, ATK +[100-200]% each round. When self HP is lower than 50% for the first time, increases DMG dealt by 30%, lasting until the end of the battle.",
   "unique": "Heavy Cavalry's Collision DMG +30%",
   "subId": "heavycavalry"
  },
  {
   "id": "peixingyanshoujing",
   "num": 2,
   "name": "Pei Xingyan (Shoujing)",
   "skillName": "Superhuman Strength",
   "cat": "cavalry",
   "possession": "Heavy Cavalry",
   "hp": [
    250,
    500
   ],
   "atk": [
    4,
    10
   ],
   "desc": "Self ATK +[15-30]%. Basic attacks will knock targets back by 1 tile. When the target is knocked back or up, deals (35%*ATK) additional DMG to the target for every tile moved.",
   "unique": "Upon entering the battle, Heavy Cavalry's DMG taken in the first 5 rounds -30%.",
   "subId": "heavycavalry"
  },
  {
   "id": "dongzhuozhongying",
   "num": 3,
   "name": "Dong Zhuo (Zhongying)",
   "skillName": "Cruelty",
   "cat": "cavalry",
   "possession": "Heavy Cavalry",
   "hp": [
    250,
    500
   ],
   "atk": [
    4,
    10
   ],
   "desc": "When Collide is released, the knocked-up target takes (8%*Max HP) additional True DMG and their Max HP is reduced by 8%, stackable up to [5-10] times and lasting until Dong Zhuo dies.",
   "unique": "When an enemy dies, restores HP by 5% of Max HP for the ally with the lowest HP ratio within 3 tiles.",
   "subId": "heavycavalry"
  },
  {
   "id": "xiahouyuanmiaocai",
   "num": 1,
   "name": "Xia Houyuan (Miaocai)",
   "skillName": "Long-range Raid",
   "cat": "cavalry",
   "possession": "Bow Cavalry",
   "hp": [
    75,
    125
   ],
   "atk": [
    4,
    8
   ],
   "desc": "For every tile moved, increases DMG by 5%, stackable up to [10-20] time(s) and will be restacked if no attack is launched within the round.",
   "unique": "Bow Cavalry's ATK +1% for every tile they move, stackable up to 50 times.",
   "subId": "bowcavalry"
  },
  {
   "id": "taishiciziyi",
   "num": 2,
   "name": "Taishi Ci (Ziyi)",
   "skillName": "Marvelous Speed",
   "cat": "cavalry",
   "possession": "Bow Cavalry",
   "hp": [
    75,
    125
   ],
   "atk": [
    4,
    8
   ],
   "desc": "After the basic attack is launched, there is a [20-40]% chance of fully charging Rage and acting 1 more round.",
   "unique": "After Bow Cavalry's Rage is full, increases their next attack's DMG dealt by 30%.",
   "subId": "bowcavalry"
  },
  {
   "id": "xuhuanggongming",
   "num": 1,
   "name": "Xu Huang (Gongming)",
   "skillName": "Fierce Assault",
   "cat": "cavalry",
   "possession": "Axe Cavalry",
   "hp": [
    175,
    325
   ],
   "atk": [
    8,
    14
   ],
   "desc": "Breaks the target's armor when DMG is dealt to them, increasing their DMG taken by [10-20]%, stackable up to 10 times and lasting for 3 rounds.",
   "unique": "Increases the Axe Cavalry's DMG dealt by every 3rd attack by 50%.",
   "subId": "axecavalry"
  },
  {
   "id": "chengyaojinyizhen",
   "num": 2,
   "name": "Cheng Yaojin (Yizhen)",
   "skillName": "Three Axe Strokes",
   "cat": "cavalry",
   "possession": "Axe Cavalry",
   "hp": [
    175,
    325
   ],
   "atk": [
    8,
    14
   ],
   "desc": "When switching to a new target each time, gains 3 special attacks: 1st - Attacks a single target, increasing DMG by 50%; 2nd - Cleave, restores HP by 5% of Max HP for every target hit; 3rd - Attacks a single target and deals ([10-30]%*lost HP) additional True DMG to the target.",
   "unique": "Axe Cavalry's ATK +10%, DMG Dealt +10%",
   "subId": "axecavalry"
  }
 ],
 "expertise": {
  "spear": {
   "common": [
    {
     "text": "{Soldier} has a 40% chance to retain 1 Rage after using a skill",
     "fx": [
      [
       "rageKeep",
       40
      ]
     ]
    },
    {
     "text": "{Soldier} ATK +[2/4/6] (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "atkFlat",
       6
      ]
     ]
    },
    {
     "text": "{Soldier} HP +[20/40/60] (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "hpFlat",
       60
      ]
     ]
    },
    {
     "text": "{Soldier} ATK +[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "atkFlat",
       15
      ],
      [
       "atkPct",
       15
      ]
     ]
    },
    {
     "text": "{Soldier} HP +[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "hpFlat",
       15
      ],
      [
       "hpPct",
       15
      ]
     ]
    },
    {
     "text": "DMG dealt by {Soldier}+[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "dmgOut",
       15
      ]
     ]
    },
    {
     "text": "DMG taken by {Soldier} -[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "dmgIn",
       -15
      ]
     ]
    },
    {
     "text": "{Soldier} restores [2/4/6] HP each round. (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "regen",
       6
      ]
     ]
    }
   ],
   "uncommon": [
    {
     "text": "{Soldier} gains [8/16]% Leech(lifesteal). (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "leech",
       16
      ]
     ]
    },
    {
     "text": "{Soldier} gains [8/16]% Dodge. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "dodge",
       16
      ]
     ]
    },
    {
     "text": "{Soldier} ignores [8/16]% Dodge. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "ignoreDodge",
       16
      ]
     ]
    },
    {
     "text": "Spearman's Max Rage -1",
     "fx": [
      [
       "maxRageMinus",
       1
      ]
     ]
    },
    {
     "text": "After Spearman kills a target, ATK +1",
     "fx": []
    },
    {
     "text": "For every 10% HP lost by Spearman, DMG dealt +[10/20]% (The Expertise Effect can be stacked 2 time(s).)",
     "fx": []
    },
    {
     "text": "Spearman's HP Restoration +[15/30]%(The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "regenPct",
       30
      ]
     ]
    }
   ],
   "rare": [
    {
     "text": "Hero's DMG dealt +30%, DMG taken -30%",
     "fx": []
    },
    {
     "text": "When {Soldier} attacks, there is a 30% chance to deal (30% * atk) additional True DMG.",
     "fx": [
      [
       "trueProc",
       30
      ],
      [
       "trueProcPct",
       30
      ]
     ]
    },
    {
     "text": "Spearman restores (5*own level) HP when attacking.",
     "fx": [
      [
       "atkHeal",
       5
      ]
     ]
    },
    {
     "text": "Spearman's ATK Range +1",
     "fx": [
      [
       "rangePlus",
       1
      ]
     ]
    },
    {
     "text": "When Spearman attacks, grants 1 extra Rage",
     "fx": []
    }
   ]
  },
  "shield": {
   "common": [
    {
     "text": "{Soldier} ATK +[2/4/6] (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "atkFlat",
       6
      ]
     ]
    },
    {
     "text": "{Soldier} HP +[20/40/60] (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "hpFlat",
       60
      ]
     ]
    },
    {
     "text": "{Soldier} ATK +[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "atkFlat",
       15
      ],
      [
       "atkPct",
       15
      ]
     ]
    },
    {
     "text": "{Soldier} HP +[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "hpFlat",
       15
      ],
      [
       "hpPct",
       15
      ]
     ]
    },
    {
     "text": "DMG dealt by {Soldier}+[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "dmgOut",
       15
      ]
     ]
    },
    {
     "text": "DMG taken by {Soldier} -[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "dmgIn",
       -15
      ]
     ]
    },
    {
     "text": "{Soldier} restores [2/4/6] HP each round. (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "regen",
       6
      ]
     ]
    }
   ],
   "uncommon": [
    {
     "text": "{Soldier} gains [8/16]% Leech(lifesteal). (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "leech",
       16
      ]
     ]
    },
    {
     "text": "{Soldier} gains [8/16]% Dodge. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "dodge",
       16
      ]
     ]
    },
    {
     "text": "{Soldier} ignores [8/16]% Dodge. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "ignoreDodge",
       16
      ]
     ]
    },
    {
     "text": "Shieldman's Max Rage -1",
     "fx": [
      [
       "maxRageMinus",
       1
      ]
     ]
    },
    {
     "text": "When being inflicted with debuffs, Shieldman's  has a [10/20]% chance of gaining immunity (The Expertise Effect can be stacked 2 time(s).)",
     "fx": []
    },
    {
     "text": "Shieldman's HP Restoration +[15/30%] (The Expertise Effect can be stacked 2 time(s).)",
     "fx": []
    },
    {
     "text": "Shieldman's  DMG taken -[3/6] (The Expertise Effect can be stacked 2 time(s).)",
     "fx": []
    }
   ],
   "rare": [
    {
     "text": "Hero's DMG dealt +30%, DMG taken -30%",
     "fx": []
    },
    {
     "text": "When {Soldier} attacks, there is a 30% chance to deal (30% * atk) additional True DMG.",
     "fx": [
      [
       "trueProc",
       30
      ],
      [
       "trueProcPct",
       30
      ]
     ]
    },
    {
     "text": "Shieldman's restores (5*own level) HP when attacking.",
     "fx": [
      [
       "atkHeal",
       5
      ]
     ]
    },
    {
     "text": "Shieldman's  restores ([2/4] %*current HP) HP each round (The Expertise Effect can be stacked 2 time(s).)- When Spearman attacks, grants 1 extra Rage",
     "fx": []
    },
    {
     "text": "When Shieldman's attacks, grants 1 extra Rage",
     "fx": []
    },
    {
     "text": "Shieldman's has a 30% chance to deal additional True DMG by 2% of self Max HP to up to 4 enemies within 1 tile each round.",
     "fx": []
    }
   ]
  },
  "bow": {
   "common": [
    {
     "text": "{Soldier} has a 40% chance to retain 1 Rage after using a skill",
     "fx": [
      [
       "rageKeep",
       40
      ]
     ]
    },
    {
     "text": "{Soldier} ATK +[2/4/6] (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "atkFlat",
       6
      ]
     ]
    },
    {
     "text": "{Soldier} HP +[20/40/60] (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "hpFlat",
       60
      ]
     ]
    },
    {
     "text": "{Soldier} ATK +[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "atkFlat",
       15
      ],
      [
       "atkPct",
       15
      ]
     ]
    },
    {
     "text": "{Soldier} HP +[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "hpFlat",
       15
      ],
      [
       "hpPct",
       15
      ]
     ]
    },
    {
     "text": "DMG dealt by {Soldier}+[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "dmgOut",
       15
      ]
     ]
    },
    {
     "text": "DMG taken by {Soldier} -[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "dmgIn",
       -15
      ]
     ]
    },
    {
     "text": "{Soldier} restores [2/4/6] HP each round. (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "regen",
       6
      ]
     ]
    }
   ],
   "uncommon": [
    {
     "text": "{Soldier} gains [8/16]% Leech(lifesteal). (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "leech",
       16
      ]
     ]
    },
    {
     "text": "{Soldier} gains [8/16]% Dodge. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "dodge",
       16
      ]
     ]
    },
    {
     "text": "{Soldier} ignores [8/16]% Dodge. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "ignoreDodge",
       16
      ]
     ]
    },
    {
     "text": "Bowman's Max Rage -1",
     "fx": [
      [
       "maxRageMinus",
       1
      ]
     ]
    },
    {
     "text": "After Bowman's kills a target, ATK +1",
     "fx": []
    },
    {
     "text": "For every 1 tile between Bowman's and the target, DMG Dealt +[2/4]% (The Expertise Effect can be stacked 2 time(s).)",
     "fx": []
    }
   ],
   "rare": [
    {
     "text": "Hero's DMG dealt +30%, DMG taken -30%",
     "fx": []
    },
    {
     "text": "When {Soldier} attacks, there is a 30% chance to deal (30% * atk) additional True DMG.",
     "fx": [
      [
       "trueProc",
       30
      ],
      [
       "trueProcPct",
       30
      ]
     ]
    },
    {
     "text": "Bowman's ATK Range +1",
     "fx": [
      [
       "rangePlus",
       1
      ]
     ]
    },
    {
     "text": "When Bowman's attacks, grants 1 extra Rage",
     "fx": []
    }
   ]
  },
  "cavalry": {
   "common": [
    {
     "text": "{Soldier} has a 40% chance to retain 1 Rage after using a skill",
     "fx": [
      [
       "rageKeep",
       40
      ]
     ]
    },
    {
     "text": "{Soldier} ATK +[2/4/6] (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "atkFlat",
       6
      ]
     ]
    },
    {
     "text": "{Soldier} HP +[20/40/60] (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "hpFlat",
       60
      ]
     ]
    },
    {
     "text": "{Soldier} ATK +[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "atkFlat",
       15
      ],
      [
       "atkPct",
       15
      ]
     ]
    },
    {
     "text": "{Soldier} HP +[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "hpFlat",
       15
      ],
      [
       "hpPct",
       15
      ]
     ]
    },
    {
     "text": "DMG dealt by {Soldier}+[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "dmgOut",
       15
      ]
     ]
    },
    {
     "text": "DMG taken by {Soldier} -[5/10/15]% (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "dmgIn",
       -15
      ]
     ]
    },
    {
     "text": "{Soldier} restores [2/4/6] HP each round. (The Expertise Effect can be stacked 3 time(s).)",
     "fx": [
      [
       "regen",
       6
      ]
     ]
    }
   ],
   "uncommon": [
    {
     "text": "{Soldier} gains [8/16]% Leech(lifesteal). (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "leech",
       16
      ]
     ]
    },
    {
     "text": "{Soldier} gains [8/16]% Dodge. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "dodge",
       16
      ]
     ]
    },
    {
     "text": "{Soldier} ignores [8/16]% Dodge. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": [
      [
       "ignoreDodge",
       16
      ]
     ]
    },
    {
     "text": "Cavalry's Max Rage -1",
     "fx": [
      [
       "maxRageMinus",
       1
      ]
     ]
    },
    {
     "text": "After Cavalry's kills a target, ATK +1",
     "fx": []
    },
    {
     "text": "When Cavalry's HP drops to 30% for the first time, restores HP by [15/30]% of Max HP. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": []
    },
    {
     "text": "Cavalry's HP Restoration +[15/30%] (The Expertise Effect can be stacked 2 time(s).)",
     "fx": []
    }
   ],
   "rare": [
    {
     "text": "Hero's DMG dealt +30%, DMG taken -30%",
     "fx": []
    },
    {
     "text": "When {Soldier} attacks, there is a 30% chance to deal (30% * atk) additional True DMG.",
     "fx": [
      [
       "trueProc",
       30
      ],
      [
       "trueProcPct",
       30
      ]
     ]
    },
    {
     "text": "Cavalry's ATK Range +1",
     "fx": [
      [
       "rangePlus",
       1
      ]
     ]
    },
    {
     "text": "When Cavalry's attacks, grants 1 extra Rage",
     "fx": []
    },
    {
     "text": "When Cavalry attacks, deals ([2/4]%*target's current HP) additional DMG. (The Expertise Effect can be stacked 2 time(s).)",
     "fx": []
    },
    {
     "text": "Converts 20% of Cavalry's DMG dealt into True DMG.",
     "fx": [
      [
       "truePct",
       20
      ]
     ]
    }
   ]
  }
 },
 "commonEquipment": [
  {
   "id": "cureblade",
   "num": 1,
   "name": "Cureblade",
   "tier": 1,
   "roll": [
    1,
    5
   ],
   "effect": "Restores [4-10] HP upon dealing effective DMG, with a 40% chance to restore the same HP for 1 ally with the lowest HP within 5 tiles. Cannot heal weaponry. The restoration is halved if the ATK Range is more than 2.",
   "fx": [
    [
     "healOnDmg",
     7
    ]
   ]
  },
  {
   "id": "critblade",
   "num": 2,
   "name": "Crit Blade",
   "tier": 1,
   "roll": [
    2,
    10
   ],
   "effect": "There is a [20-40]% chance to deal [150-180]% Crit DMG.",
   "fx": [
    [
     "crit",
     30
    ],
    [
     "critMult",
     165
    ]
   ]
  },
  {
   "id": "meteorhammer",
   "num": 3,
   "name": "Meteor Hammer",
   "tier": 1,
   "roll": [
    2,
    10
   ],
   "effect": "ATK Range +1. Ignores [30-70]% Dodge upon attacking.",
   "fx": [
    [
     "rangePlus",
     1
    ],
    [
     "ignoreDodge",
     50
    ]
   ]
  },
  {
   "id": "dualaxe",
   "num": 4,
   "name": "Dual Axe",
   "tier": 1,
   "roll": [
    2,
    10
   ],
   "effect": "Each attack grants extra 1 Rage. Has a [20-50]% chance to gain 50% more Rage after casting skills.",
   "fx": [
    [
     "ragePerAtk",
     1
    ]
   ]
  },
  {
   "id": "crescentblade",
   "num": 5,
   "name": "Crescent Blade",
   "tier": 1,
   "roll": [
    2,
    8
   ],
   "effect": "Increases DMG dealt by [20-50]% and DMG taken by 100%, ignoring 20% DMG Reduction.",
   "fx": [
    [
     "dmgOut",
     35
    ],
    [
     "dmgIn",
     100
    ],
    [
     "ignoreDR",
     20
    ]
   ]
  },
  {
   "id": "longyuansword",
   "num": 6,
   "name": "Longyuan Sword",
   "tier": 1,
   "roll": [
    2,
    8
   ],
   "effect": "ATK +[10-20]%. There is a 30% chance to +1% ATK after the first attack in each round. Stackable without limit.",
   "fx": [
    [
     "atkPct",
     15
    ]
   ]
  },
  {
   "id": "chainmail",
   "num": 7,
   "name": "Chainmail",
   "tier": 3,
   "roll": [
    20,
    70
   ],
   "effect": "DMG taken -5. For every 1 effective attack taken, there is a [5-20]% chance to reduce the DMG taken by 1. For every 50 Max HP owned, +1 stackable chance.",
   "fx": [
    [
     "dmgFlatRed",
     5
    ]
   ]
  },
  {
   "id": "winegourd",
   "num": 8,
   "name": "Wine Gourd",
   "tier": 3,
   "roll": [
    20,
    50
   ],
   "effect": "Restores [1-4]% of the max HP at the start of each round.",
   "fx": [
    [
     "regenPct",
     2.5
    ]
   ]
  },
  {
   "id": "dmgreflectionarmor",
   "num": 9,
   "name": "DMG Reflection Armor",
   "tier": 3,
   "roll": [
    20,
    80
   ],
   "effect": "There is a [20-40]% chance to reflect 5 True DMG to the attacker upon taking DMG. For every 50 Max HP owned, +1 reflected DMG.",
   "fx": [
    [
     "reflect",
     5
    ]
   ]
  },
  {
   "id": "coppershield",
   "num": 10,
   "name": "Copper Shield",
   "tier": 3,
   "roll": [
    20,
    60
   ],
   "effect": "The first time HP drops below 50%, gains (Max HP*[5-15]%) Shield point and restores 30% of the Max HP.",
   "fx": [
    [
     "shieldOnLow",
     10
    ]
   ]
  },
  {
   "id": "goldenaxe",
   "num": 11,
   "name": "Golden Axe",
   "tier": 3,
   "roll": [
    20,
    40
   ],
   "effect": "When dealing effective DMG to a target, has a [50-80]% chance to gain a Shield equal to (4 + own level)% of the target's Max HP. Cannot be stacked.",
   "fx": [
    [
     "shieldOnHit",
     6
    ]
   ]
  },
  {
   "id": "ironshield",
   "num": 12,
   "name": "Iron Shield",
   "tier": 3,
   "roll": [
    20,
    70
   ],
   "effect": "Melee DMG -[10-35]%. Doubles the effect at less than 50% HP.",
   "fx": [
    [
     "meleeRed",
     22
    ]
   ]
  },
  {
   "id": "leechsword",
   "num": 13,
   "name": "Leech Sword",
   "tier": 5,
   "roll": [
    20,
    40
   ],
   "effect": "Upon attacking, restores ([10-50]% * DMG dealt) HP and converts excessive HP into a Shield, up to self Level*6.",
   "fx": [
    [
     "leech",
     30
    ]
   ]
  },
  {
   "id": "circleblade",
   "num": 14,
   "name": "Circle Blade",
   "tier": 5,
   "roll": [
    20,
    40
   ],
   "effect": "Per DMG taken, next attack's Leech +[4-10]%, stackable up to 60%. Increases next attack's DMG by 30% upon reaching 30% Leech.",
   "fx": [
    [
     "leech",
     15
    ],
    [
     "dmgOut",
     10
    ]
   ]
  },
  {
   "id": "obsidianarmor",
   "num": 15,
   "name": "Obsidian Armor",
   "tier": 5,
   "roll": [
    20,
    50
   ],
   "effect": "In the first 5 rounds upon entering a battle, gains [40-80]% DMG Reduction. Afterward, increases DMG taken by 50%, lasting until the end of the battle.",
   "fx": [
    [
     "earlyDR",
     60
    ]
   ]
  },
  {
   "id": "radiantplatearmor",
   "num": 16,
   "name": "Radiant Plate Armor",
   "tier": 5,
   "roll": [
    20,
    50
   ],
   "effect": "Max HP +0%, DMG Reduction +0%, one of which is increased by 1% when the equipment is recast. Can be recast up to 50 times.",
   "fx": [
    [
     "hpPct",
     10
    ]
   ]
  },
  {
   "id": "thousandtemperedblade",
   "num": 17,
   "name": "Thousand Tempered Blade",
   "tier": 5,
   "roll": [
    20,
    40
   ],
   "effect": "ATK +0%, Leech +0%, one of which is increased by +1% when the equipment is recast. Can be recast up to 50 times.",
   "fx": [
    [
     "atkPct",
     10
    ]
   ]
  },
  {
   "id": "darts",
   "num": 18,
   "name": "Darts",
   "tier": 7,
   "roll": [
    4,
    14
   ],
   "effect": "Converts [20-50]% DMG dealt into True DMG.",
   "fx": [
    [
     "truePct",
     35
    ]
   ]
  },
  {
   "id": "rattanshield",
   "num": 19,
   "name": "Rattan Shield",
   "tier": 7,
   "roll": [
    20,
    60
   ],
   "effect": "Ranged DMG -[30-60]%. Halves the effect at less than 50% HP.",
   "fx": [
    [
     "rangedRed",
     45
    ]
   ]
  },
  {
   "id": "mace",
   "num": 20,
   "name": "Mace",
   "tier": 7,
   "roll": [
    2,
    8
   ],
   "effect": "Deals ([1-5]% * target's current HP) additional DMG.",
   "fx": [
    [
     "curHpPct",
     3
    ]
   ]
  },
  {
   "id": "armyflag",
   "num": 21,
   "name": "Army Flag",
   "tier": 7,
   "roll": [
    20,
    50
   ],
   "effect": "Upon death, drops an Army Flag with [2-4] HP. In 2 tiles, allies' DMG +20% while enemies' DMG -20%. Only one Army Flag can occupy a location.",
   "fx": [
    [
     "dmgOut",
     20
    ]
   ]
  },
  {
   "id": "qiankunsaber",
   "num": 22,
   "name": "Qiankun Saber",
   "tier": 7,
   "roll": [
    2,
    8
   ],
   "effect": "Basic attacks deal extra ([30-60]% * ATK) True DMG to up to 4 enemies within 1 tile around the target.",
   "fx": [
    [
     "aoeTrue",
     45
    ]
   ]
  },
  {
   "id": "sunfirearmor",
   "num": 23,
   "name": "Sunfire Armor",
   "tier": 7,
   "roll": [
    20,
    60
   ],
   "effect": "At the start of each round, there is a [20-50]% chance to deal True DMG by 4% of self Max HP to up to 4 enemies within 1 tile.",
   "fx": [
    [
     "roundTrue",
     4
    ]
   ]
  },
  {
   "id": "helmetofcalmness",
   "num": 24,
   "name": "Helmet of Calmness",
   "tier": 7,
   "roll": [
    20,
    50
   ],
   "effect": "Max HP +[10-20]%, restores 20% of the HP lost for self and up to 4 allies around self every 5 rounds.",
   "fx": [
    [
     "hpPct",
     15
    ],
    [
     "regenPct",
     1
    ]
   ]
  },
  {
   "id": "puregoldshield",
   "num": 25,
   "name": "Pure Gold Shield",
   "tier": 7,
   "roll": [
    20,
    50
   ],
   "effect": "Gains a Shield equal to 4% of Max HP every 3 rounds and increases any Shield effect on self by [20-50]%.",
   "fx": [
    [
     "shieldPeriodic",
     4
    ]
   ]
  },
  {
   "id": "silverserpentwhip",
   "num": 26,
   "name": "Silver Serpent Whip",
   "tier": 7,
   "roll": [
    2,
    10
   ],
   "effect": "Randomly selects the nearest target within the ATK Range upon launching a basic attack; if the target is new, DMG dealt to the target +[20-50]%.",
   "fx": [
    [
     "newTargetDmg",
     35
    ]
   ]
  },
  {
   "id": "lamellarcuirass",
   "num": 27,
   "name": "Lamellar Cuirass",
   "tier": 12,
   "roll": [
    20,
    80
   ],
   "effect": "DMG taken is no more than [15-30]. Reduces HP by (50% * Excessive DMG) each turn for several turns. If reduced HP is no higher than [15-30], reduces (100% * Excessive DMG) HP instead.",
   "fx": [
    [
     "dmgCap",
     22
    ]
   ]
  },
  {
   "id": "hookswords",
   "num": 28,
   "name": "Hook Swords",
   "tier": 12,
   "roll": [
    2,
    8
   ],
   "effect": "There is a [15-35]% chance to deal additional True DMG by (2 + own level)% * target's max HP, (1 + own level)% for a ranged owner.",
   "fx": [
    [
     "trueProc",
     25
    ],
    [
     "trueProcPct",
     3
    ]
   ]
  },
  {
   "id": "mirrorarmor",
   "num": 29,
   "name": "Mirror Armor",
   "tier": 12,
   "roll": [
    20,
    70
   ],
   "effect": "Upon being attacked by different targets, gains 4% DMG Reduction, stackable up to [10-15] times. Increases Max HP by 10% when stacked to 8 times.",
   "fx": [
    [
     "stackDR",
     4
    ]
   ]
  },
  {
   "id": "battleaxe",
   "num": 30,
   "name": "Battle Axe",
   "tier": 12,
   "roll": [
    2,
    8
   ],
   "effect": "When HP drops to 50% for the first time, ATK +(3 * Self Level), and Leech +[10-30]%.",
   "fx": [
    [
     "below50Atk",
     15
    ],
    [
     "leech",
     20
    ]
   ]
  },
  {
   "id": "jadependant",
   "num": 31,
   "name": "Jade Pendant",
   "tier": 12,
   "roll": [
    20,
    50
   ],
   "effect": "At the start of the first round, grants the 3 closest allies a shield equal to [5-10]% of self Max HP and defends DMG dealt by active skills for once, lasting for 10 rounds.",
   "fx": [
    [
     "allyShield",
     8
    ]
   ]
  },
  {
   "id": "lethalumbrella",
   "num": 32,
   "name": "Lethal Umbrella",
   "tier": 12,
   "roll": [
    20,
    40
   ],
   "effect": "When a battle starts, ATK +[5-15]%, DMG Taken -[5-15]%, and doubles a random effect from above.",
   "fx": [
    [
     "atkPct",
     10
    ],
    [
     "dmgIn",
     -10
    ]
   ]
  },
  {
   "id": "ringofburningheart",
   "num": 33,
   "name": "Ring of Burning Heart",
   "tier": 12,
   "roll": [
    2,
    6
   ],
   "effect": "When a skill hits a target, there is a 50% chance to inflict Burning Heart, causing the target to take additional True DMG equal to [20-40]% of ATK each round. When the target takes True DMG during their turn, splashes (self level * 10)% onto up to 4 enemies within 1 tile for 3 rounds.",
   "fx": [
    [
     "burn",
     30
    ]
   ]
  },
  {
   "id": "billhook",
   "num": 34,
   "name": "Billhook",
   "tier": 12,
   "roll": [
    2,
    8
   ],
   "effect": "Deals additional DMG equal to ([4-8] * own level)% of the target's ATK.",
   "fx": [
    [
     "atkBasedPct",
     6
    ]
   ]
  },
  {
   "id": "bloodragebelt",
   "num": 35,
   "name": "Bloodrage Belt",
   "tier": 12,
   "roll": [
    20,
    50
   ],
   "effect": "Restores (4% of Max HP + 40% of ATK) HP after casting skills. Meanwhile, when taking ATK DMG each time, there is a [30-50]% chance to additionally +1 Rage.",
   "fx": [
    [
     "castHeal",
     40
    ],
    [
     "rageOnHit",
     40
    ]
   ]
  },
  {
   "id": "spikedmace",
   "num": 36,
   "name": "Spiked Mace",
   "tier": 12,
   "roll": [
    2,
    8
   ],
   "effect": "When a target is killed, deals extra ([50-100]% * ATK) True DMG to up to 8 enemies within 2 tiles around the target.",
   "fx": [
    [
     "killAoe",
     75
    ]
   ]
  },
  {
   "id": "dodgeboots",
   "num": 37,
   "name": "Dodge Boots",
   "tier": 14,
   "roll": [
    20,
    50
   ],
   "effect": "Has a [10-35]% chance to dodge all DMG.",
   "fx": [
    [
     "dodge",
     22
    ]
   ]
  },
  {
   "id": "flyingguillotine",
   "num": 38,
   "name": "Flying Guillotine",
   "tier": 14,
   "roll": [
    2,
    8
   ],
   "effect": "Slays targets with HP lower than [5-20]% and gains ATK +1 until the battle ends.",
   "fx": [
    [
     "execute",
     12
    ]
   ]
  },
  {
   "id": "timeflag",
   "num": 39,
   "name": "Time Flag",
   "tier": 14,
   "roll": [
    30,
    43
   ],
   "effect": "1 random type(s) from the following effects: ① Only grants HP — increases HP by (3 + self level)*10 each season. ② Only grants ATK — increases ATK by (3 + self level) each season.",
   "fx": [
    [
     "hpFlat",
     60
    ]
   ]
  },
  {
   "id": "hourglass",
   "num": 40,
   "name": "Hourglass",
   "tier": 14,
   "roll": [
    2,
    4
   ],
   "effect": "Has a [5-25]% chance of acting 2 rounds.",
   "fx": [
    [
     "doubleAct",
     15
    ]
   ]
  },
  {
   "id": "blindingpendant",
   "num": 41,
   "name": "Blinding Pendant",
   "tier": 14,
   "roll": [
    20,
    50
   ],
   "effect": "When taking True DMG, there is a [10-35]% chance to stun the attacker for 1 round.",
   "fx": [
    [
     "stunOnTrue",
     22
    ]
   ]
  },
  {
   "id": "darksteelstaff",
   "num": 42,
   "name": "Darksteel Staff",
   "tier": 14,
   "roll": [
    20,
    40
   ],
   "effect": "When attacking a new target each time, deals extra ([10-25]% * target's Max HP) True DMG and gains a Shield equal to 40% of the DMG dealt. Each target can only trigger this effect once.",
   "fx": [
    [
     "newTargetTrue",
     17
    ]
   ]
  }
 ],
 "exclusiveEquipment": [
  {
   "id": "spear",
   "num": 43,
   "name": "Spear",
   "sub": "longspearman",
   "hp": [
    20,
    40
   ],
   "atk": [
    4,
    12
   ],
   "modName": "Stab",
   "mod": "Stabs +1 tile in the target's direction. For every 1 target hit, gains 15% Dodge, lasting for 3 rounds.",
   "subId": "longspearman",
   "modKey": "stab_dodge"
  },
  {
   "id": "lance",
   "num": 44,
   "name": "Lance",
   "sub": "lancer",
   "hp": [
    20,
    40
   ],
   "atk": [
    4,
    13
   ],
   "modName": "Project",
   "mod": "Also deals (allied soldier count * own level) additional DMG (multiplier cannot exceed 40).",
   "subId": "lancer",
   "modKey": "project_count"
  },
  {
   "id": "daggeraxe",
   "num": 45,
   "name": "Dagger-axe",
   "sub": "daggeraxesoldier",
   "hp": [
    20,
    40
   ],
   "atk": [
    4,
    10
   ],
   "modName": "Disarm",
   "mod": "Disarms up to 4 enemies within 1 tile around the target.",
   "subId": "daggeraxe",
   "modKey": "disarm_aoe"
  },
  {
   "id": "modaosaber",
   "num": 46,
   "name": "Modao Saber",
   "sub": "modaosoldier",
   "hp": [
    20,
    40
   ],
   "atk": [
    4,
    15
   ],
   "modName": "Steady Attack",
   "mod": "The first 3 attacks deal max DMG of the random range, and the following attack after killing the target will also deal max DMG.",
   "subId": "modao",
   "modKey": "steady_attack"
  },
  {
   "id": "twohandedsword",
   "num": 47,
   "name": "Two-handed Sword",
   "sub": "longswordsman",
   "hp": [
    25,
    45
   ],
   "atk": [
    4,
    10
   ],
   "modName": "Whirlwind",
   "mod": "When an enemy within 2 tiles triggers Bleed, self restores HP by 40% of the Bleed DMG.",
   "subId": "longswordsman",
   "modKey": "whirlwind_heal"
  },
  {
   "id": "doublehalberds",
   "num": 48,
   "name": "Double Halberds",
   "sub": "twinspearman",
   "hp": [
    20,
    40
   ],
   "atk": [
    4,
    12
   ],
   "modName": "Unbridled Dance",
   "mod": "Parry Duration after dancing wildly +1 round.",
   "subId": "twinspearman",
   "modKey": "dance_parry"
  },
  {
   "id": "woodshield",
   "num": 49,
   "name": "Wood Shield",
   "sub": "sabershieldsoldier",
   "hp": [
    50,
    100
   ],
   "atk": [
    1,
    2
   ],
   "modName": "Shield",
   "mod": "When granting Shield, additionally increases Shield value by 5% of self Max HP.",
   "subId": "saberandshield",
   "modKey": "shield_maxhp"
  },
  {
   "id": "heavyshield",
   "num": 50,
   "name": "Heavy Shield",
   "sub": "heavyshieldsoldier",
   "hp": [
    60,
    120
   ],
   "atk": [
    1,
    2
   ],
   "modName": "Shield Stance",
   "mod": "Per enemy around the shield, DMG taken -5%.",
   "subId": "heavyshield",
   "modKey": "stance_perenemy"
  },
  {
   "id": "longspear",
   "num": 51,
   "name": "Long Spear",
   "sub": "spearshieldsoldier",
   "hp": [
    45,
    90
   ],
   "atk": [
    1,
    4
   ],
   "modName": "Charge",
   "mod": "Also deals (5% * own max HP) additional DMG to the target.",
   "subId": "spearandshield",
   "modKey": "charge_maxhp"
  },
  {
   "id": "ironhammer",
   "num": 52,
   "name": "Iron Hammer",
   "sub": "hammershieldsoldier",
   "hp": [
    40,
    80
   ],
   "atk": [
    1,
    2
   ],
   "modName": "Earthshaker",
   "mod": "Also increases Rage by 1 for allies within range whose Rage is below half.",
   "subId": "hammerandshield",
   "modKey": "earthshaker_rage"
  },
  {
   "id": "swordshield",
   "num": 53,
   "name": "Sword&Shield",
   "sub": "swordshieldsoldier",
   "hp": [
    30,
    70
   ],
   "atk": [
    2,
    6
   ],
   "modName": "Guardian Sword",
   "mod": "Each time taking DMG out of own round, next attack DMG +3%.",
   "subId": "swordandshield",
   "modKey": "guardian_counter"
  },
  {
   "id": "axeshield",
   "num": 54,
   "name": "Axe&Shield",
   "sub": "axeshieldsoldier",
   "hp": [
    30,
    70
   ],
   "atk": [
    2,
    8
   ],
   "modName": "Enhancement",
   "mod": "Bounce Time of Whirling Axe +2. Shield Bash's Chance of Stunning the Target +20%.",
   "subId": "axeandshield",
   "modKey": "whirl_bounce"
  },
  {
   "id": "longbow",
   "num": 55,
   "name": "Longbow",
   "sub": "longbowman",
   "hp": [
    10,
    20
   ],
   "atk": [
    2,
    10
   ],
   "modName": "Scatter",
   "mod": "The extra attack hits 4 targets instead.",
   "subId": "longbowman",
   "modKey": "scatter_multi"
  },
  {
   "id": "crossbow",
   "num": 56,
   "name": "Crossbow",
   "sub": "crossbowman",
   "hp": [
    10,
    20
   ],
   "atk": [
    2,
    8
   ],
   "modName": "Dexterity",
   "mod": "When taking ATK DMG, there is a 30% chance to dodge it. For every 1 tile away from the attacker, the chance is reduced by 10%.",
   "subId": "crossbowman",
   "modKey": "dexterity"
  },
  {
   "id": "toxibow",
   "num": 57,
   "name": "Toxibow",
   "sub": "toxibowman",
   "hp": [
    10,
    20
   ],
   "atk": [
    2,
    8
   ],
   "modName": "Poison Arrow",
   "mod": "Has a (10 * self level)% chance of paralyzing the target for 1 round, making them unable to move or attack. If the target is paralyzed multiple times successively, they will enter the Fragile status, increasing their DMG taken by 30%.",
   "subId": "toxibowman",
   "modKey": "poison_paralysis"
  },
  {
   "id": "huntersbow",
   "num": 58,
   "name": "Hunter's Bow",
   "sub": "hunter",
   "hp": [
    10,
    20
   ],
   "atk": [
    2,
    8
   ],
   "modName": "Inspire",
   "mod": "Additionally restores (1 + own level) HP for all allies.",
   "subId": "hunter",
   "modKey": "inspire_heal"
  },
  {
   "id": "improvedcrossbow",
   "num": 59,
   "name": "Improved Crossbow",
   "sub": "improvedcrossbowman",
   "hp": [
    10,
    20
   ],
   "atk": [
    2,
    10
   ],
   "modName": "Anchor",
   "mod": "Knocks back the target by 1 tile in the max attack range, except those in Shield Stance or weaponry.",
   "subId": "improvedcrossbowman",
   "modKey": "anchor_kb"
  },
  {
   "id": "bowoffire",
   "num": 60,
   "name": "Bow of Fire",
   "sub": "firebowman",
   "hp": [
    10,
    20
   ],
   "atk": [
    2,
    8
   ],
   "modName": "Wildfire",
   "mod": "When flames are triggered, they also trigger nearby allies' flames.",
   "subId": "firebowman",
   "modKey": "wildfire"
  },
  {
   "id": "greatsword",
   "num": 61,
   "name": "Great Sword",
   "sub": "swordcavalry",
   "hp": [
    20,
    40
   ],
   "atk": [
    4,
    13
   ],
   "modName": "Leap Slash",
   "mod": "Killing a target with Leap Slash has an 85% chance of granting one more slash.",
   "subId": "swordcavalry",
   "modKey": "leap_repeat"
  },
  {
   "id": "halberd",
   "num": 62,
   "name": "Halberd",
   "sub": "spearcavalry",
   "hp": [
    30,
    60
   ],
   "atk": [
    4,
    10
   ],
   "modName": "Sweep",
   "mod": "Inflicts 20% Leech when sweeping.",
   "subId": "spearcavalry",
   "modKey": "sweep_leech"
  },
  {
   "id": "guandao",
   "num": 63,
   "name": "Guandao",
   "sub": "broadswordcavalry",
   "hp": [
    20,
    40
   ],
   "atk": [
    4,
    15
   ],
   "modName": "Chop",
   "mod": "Reserves 50% of the stacked DMG when switching the target.",
   "subId": "broadswordcavalry",
   "modKey": "chop_keep"
  },
  {
   "id": "sledgehammer",
   "num": 64,
   "name": "Sledge Hammer",
   "sub": "heavycavalry",
   "hp": [
    50,
    100
   ],
   "atk": [
    2,
    8
   ],
   "modName": "Charge",
   "mod": "Up to 4 targets knocked airborne are also stunned for 1 turn.",
   "subId": "heavycavalry",
   "modKey": "collide_stun"
  },
  {
   "id": "recurvebow",
   "num": 65,
   "name": "Recurve Bow",
   "sub": "bowcavalry",
   "hp": [
    15,
    25
   ],
   "atk": [
    2,
    8
   ],
   "modName": "Guerrilla",
   "mod": "ATK +20% to a Melee target.",
   "subId": "bowcavalry",
   "modKey": "guerrilla"
  },
  {
   "id": "mountainsplittingaxe",
   "num": 66,
   "name": "Mountain Splitting Axe",
   "sub": "axecavalry",
   "hp": [
    35,
    65
   ],
   "atk": [
    4,
    10
   ],
   "modName": "Cleave",
   "mod": "When Cleave is triggered, gains 6 Shield for each target hit; otherwise, DMG +30%.",
   "subId": "axecavalry",
   "modKey": "cleave_shield"
  }
 ],
 "bestiary": [
  {
   "id": "wolf",
   "name": "Wolf",
   "kind": "beast",
   "level": 2,
   "hp": 60,
   "rage": [
    6,
    6
   ],
   "move": 4,
   "atk": 17,
   "range": 1,
   "spd": 8,
   "skill": {
    "name": "Wolf Howl",
    "type": "active",
    "desc": "Inspires all allies within 5 tiles: +3 ATK and +20% DMG Reduction for 3 rounds."
   }
  },
  {
   "id": "leopard",
   "name": "Leopard",
   "kind": "beast",
   "level": 2,
   "hp": 88,
   "rage": [
    0,
    0
   ],
   "move": 4,
   "atk": 20,
   "range": 1,
   "spd": 7,
   "skill": {
    "name": "Evade",
    "type": "passive",
    "desc": "Every 2 times hit, gains 100% Dodge against the next incoming DMG."
   }
  },
  {
   "id": "porcupine",
   "name": "Porcupine",
   "kind": "beast",
   "level": 2,
   "hp": 91,
   "rage": [
    4,
    8
   ],
   "move": 3,
   "atk": 16,
   "range": 1,
   "spd": 7,
   "skill": {
    "name": "Spine Burst",
    "type": "active",
    "desc": "Deals 75% ATK DMG to enemies within 1 tile."
   }
  },
  {
   "id": "viper",
   "name": "Viper",
   "kind": "beast",
   "level": 2,
   "hp": 72,
   "rage": [
    4,
    8
   ],
   "move": 3,
   "atk": 17,
   "range": 2,
   "spd": 6,
   "skill": {
    "name": "Venom Spit",
    "type": "active",
    "desc": "70% ATK DMG to 1 target + Poison: 10% of current HP as True DMG each round for 3 rounds."
   }
  },
  {
   "id": "lion",
   "name": "Lion",
   "kind": "beast",
   "level": 3,
   "hp": 394,
   "rage": [
    5,
    10
   ],
   "move": 4,
   "atk": 20,
   "range": 1,
   "spd": 7,
   "skill": {
    "name": "Tear",
    "type": "active",
    "desc": "120% ATK DMG + bleed: 50% ATK True DMG/round and HP Restoration -60% for 3 rounds."
   }
  },
  {
   "id": "elephant",
   "name": "Elephant",
   "kind": "beast",
   "level": 3,
   "hp": 473,
   "rage": [
    5,
    10
   ],
   "move": 3,
   "atk": 31,
   "range": 1,
   "spd": 9,
   "skill": {
    "name": "Sling",
    "type": "active",
    "desc": "200% ATK DMG to the highest-HP target within 5 tiles."
   }
  },
  {
   "id": "bear",
   "name": "Bear",
   "kind": "beast",
   "level": 3,
   "hp": 368,
   "rage": [
    6,
    12
   ],
   "move": 3,
   "atk": 25,
   "range": 1,
   "spd": 9,
   "skill": {
    "name": "Smash",
    "type": "active",
    "desc": "Extra 5% of target Max HP DMG and stuns 1 round."
   }
  },
  {
   "id": "lizard",
   "name": "Lizard",
   "kind": "beast",
   "level": 3,
   "hp": 221,
   "rage": [
    0,
    0
   ],
   "move": 3,
   "atk": 23,
   "range": 1,
   "spd": 9,
   "skill": {
    "name": "Scale Armor",
    "type": "passive",
    "desc": "DMG taken -40%."
   }
  },
  {
   "id": "hedgehog",
   "name": "Hedgehog",
   "kind": "beast",
   "level": 4,
   "hp": 622,
   "rage": [
    0,
    0
   ],
   "move": 3,
   "atk": 26,
   "range": 1,
   "spd": 9,
   "skill": {
    "name": "DMG Reflection",
    "type": "passive",
    "desc": "Reflects 35% of DMG taken to the attacker."
   }
  },
  {
   "id": "buffalo",
   "name": "Buffalo",
   "kind": "beast",
   "level": 5,
   "hp": 725,
   "rage": [
    6,
    12
   ],
   "move": 3,
   "atk": 33,
   "range": 1,
   "spd": 9,
   "skill": {
    "name": "Wild Collision",
    "type": "active",
    "desc": "Collides 2 tiles, knocks up enemies, 50% ATK DMG. Breaks Shields and Shield Stance."
   }
  },
  {
   "id": "tiger",
   "name": "Tiger",
   "kind": "beast",
   "level": 5,
   "hp": 648,
   "rage": [
    4,
    8
   ],
   "move": 3,
   "atk": 35,
   "range": 1,
   "spd": 7,
   "skill": {
    "name": "Gash",
    "type": "active",
    "desc": "Extra 35% ATK DMG to up to 20 enemies within 1 tile around the target."
   }
  },
  {
   "id": "rhino",
   "name": "Rhino",
   "kind": "beast",
   "level": 5,
   "hp": 671,
   "rage": [
    4,
    8
   ],
   "move": 3,
   "atk": 28,
   "range": 1,
   "spd": 9,
   "skill": {
    "name": "Trample",
    "type": "active",
    "desc": "75% ATK DMG to up to 8 units within 1 tile + stun 1 round."
   }
  },
  {
   "id": "goat",
   "name": "Goat",
   "kind": "beast",
   "level": 8,
   "hp": 1213,
   "rage": [
    4,
    8
   ],
   "move": 0,
   "atk": 80,
   "range": 6,
   "spd": 9,
   "boss": true,
   "skill": {
    "name": "Rampant Charge",
    "type": "active",
    "desc": "Knocks target to the most crowded place within 6 tiles; 15% Max HP True DMG to up to 8 within 2 tiles + stun 1 round."
   },
   "passive": {
    "name": "Iron Mountain Stance",
    "desc": "Unable to move. Ignores 70% DMG Reduction when attacking; attacker's DMG -70% when attacked."
   }
  },
  {
   "id": "rat",
   "name": "Rat",
   "kind": "beast",
   "level": 8,
   "hp": 1206,
   "rage": [
    0,
    0
   ],
   "move": 0,
   "atk": 71,
   "range": 6,
   "spd": 9,
   "boss": true,
   "skill": {
    "name": "Pestilence Infection",
    "type": "passive",
    "desc": "When attacked from within 2 tiles, infects the attacker with 1 layer of Pestilence: 5% Max HP True DMG/round, stackable without limit."
   },
   "passive": {
    "name": "Iron Mountain Stance",
    "desc": "Unable to move. Ignores 70% DMG Reduction when attacking; attacker's DMG -70% when attacked."
   }
  },
  {
   "id": "ape",
   "name": "Ape",
   "kind": "beast",
   "level": 8,
   "hp": 1052,
   "rage": [
    4,
    6
   ],
   "move": 0,
   "atk": 88,
   "range": 6,
   "spd": 9,
   "boss": true,
   "skill": {
    "name": "Fury",
    "type": "active",
    "desc": "Removes debuffs; next 2 attacks deal 300% ATK DMG + 50% splash True DMG to up to 8 within 2 tiles."
   },
   "passive": {
    "name": "Iron Mountain Stance",
    "desc": "Unable to move. Ignores 70% DMG Reduction when attacking; attacker's DMG -70% when attacked."
   }
  },
  {
   "id": "minion",
   "name": "Minion",
   "kind": "bandit",
   "level": 6,
   "hp": 611,
   "rage": [
    0,
    0
   ],
   "move": 3,
   "atk": 29,
   "range": 1,
   "spd": 8,
   "skill": null
  },
  {
   "id": "assassin",
   "name": "Assassin",
   "kind": "bandit",
   "level": 6,
   "hp": 533,
   "rage": [
    0,
    0
   ],
   "move": 3,
   "atk": 37,
   "range": 1,
   "spd": 6,
   "skill": {
    "name": "Crit",
    "type": "passive",
    "desc": "Attacks have a 99% chance to deal 150% DMG."
   }
  },
  {
   "id": "banditsaberman",
   "name": "Bandit Saberman",
   "kind": "bandit",
   "level": 6,
   "hp": 625,
   "rage": [
    0,
    0
   ],
   "move": 3,
   "atk": 31,
   "range": 1,
   "spd": 9,
   "skill": null
  },
  {
   "id": "banditbowman",
   "name": "Bandit Bowman",
   "kind": "bandit",
   "level": 6,
   "hp": 247,
   "rage": [
    0,
    4
   ],
   "move": 2,
   "atk": 20,
   "range": 4,
   "spd": 6,
   "skill": {
    "name": "Snipe",
    "type": "active",
    "desc": "Deals additional DMG equal to 10% of the target's current HP. Bowman-type: counters Spearman."
   }
  },
  {
   "id": "boarknight6",
   "name": "Boar Knight",
   "kind": "bandit",
   "level": 6,
   "hp": 737,
   "rage": [
    0,
    0
   ],
   "move": 4,
   "atk": 70,
   "range": 1,
   "spd": 7,
   "skill": {
    "name": "Counter Shield Soldier",
    "type": "passive",
    "desc": "Vs Shieldman: ATK +40%, ignores 20% DMG Reduction; attacked by Shieldman: attacker ATK -40%."
   },
   "passive": {
    "name": "Fortitude",
    "type": "passive",
    "desc": "Ranged DMG taken -60%."
   }
  },
  {
   "id": "boarknight7",
   "name": "Boar Knight",
   "kind": "bandit",
   "level": 7,
   "hp": 827,
   "rage": [
    0,
    0
   ],
   "move": 4,
   "atk": 85,
   "range": 1,
   "spd": 7,
   "skill": {
    "name": "Counter Shield Soldier",
    "type": "passive",
    "desc": "Vs Shieldman: ATK +40%, ignores 20% DMG Reduction; attacked by Shieldman: attacker ATK -40%."
   },
   "passive": {
    "name": "Fortitude",
    "type": "passive",
    "desc": "Ranged DMG taken -60%."
   }
  },
  {
   "id": "soulreaper",
   "name": "Soulreaper",
   "kind": "bandit",
   "level": 10,
   "hp": 1074,
   "rage": [
    4,
    6
   ],
   "move": 0,
   "atk": 125,
   "range": 6,
   "spd": 6,
   "boss": true,
   "skill": {
    "name": "Frenzy Claw",
    "type": "active",
    "desc": "Gashes nearest target + up to 8 within 2 tiles, 3x 20% DMG; next gash +5% each, stackable without limit."
   },
   "passive": {
    "name": "Iron Mountain Stance",
    "desc": "Unable to move. Ignores 70% DMG Reduction when attacking; attacker's DMG -70% when attacked."
   }
  }
 ],
 "diffs": [
  "Easy 1",
  "Easy 2",
  "Easy 3",
  "Entry 1",
  "Entry 2",
  "Entry 3",
  "Common 1",
  "Common 2",
  "Common 3",
  "Common 4",
  "Advanced 1",
  "Advanced 2",
  "Advanced 3",
  "Advanced 4",
  "Hard 1",
  "Hard 2",
  "Hard 3",
  "Hard 4",
  "Hell 1",
  "Hell 2"
 ],
 "plotRanges": {
  "1": [
   0,
   6
  ],
  "2": [
   5,
   8
  ],
  "3": [
   9,
   12
  ],
  "4": [
   13,
   17
  ],
  "5": [
   17,
   19
  ]
 },
 "map": {
  "w": 18,
  "h": 12,
  "playerCapital": {
   "col": 2,
   "row": 6
  },
  "enemyCapital": {
   "col": 15,
   "row": 6
  },
  "plots": [
   {
    "id": "p1",
    "col": 4,
    "row": 3,
    "res": "wood",
    "level": 1
   },
   {
    "id": "p2",
    "col": 5,
    "row": 9,
    "res": "stone",
    "level": 1
   },
   {
    "id": "p3",
    "col": 6,
    "row": 5,
    "res": "crop",
    "level": 1
   },
   {
    "id": "p4",
    "col": 7,
    "row": 2,
    "res": "crop",
    "level": 2
   },
   {
    "id": "p5",
    "col": 7,
    "row": 10,
    "res": "wood",
    "level": 2
   },
   {
    "id": "p6",
    "col": 9,
    "row": 4,
    "res": "stone",
    "level": 2
   },
   {
    "id": "p7",
    "col": 10,
    "row": 8,
    "res": "crop",
    "level": 3
   },
   {
    "id": "p8",
    "col": 12,
    "row": 3,
    "res": "wood",
    "level": 3,
    "guardian": "ape"
   },
   {
    "id": "p9",
    "col": 12,
    "row": 9,
    "res": "crop",
    "level": 3,
    "guardian": "rat"
   },
   {
    "id": "p10",
    "col": 13,
    "row": 10,
    "res": "stone",
    "level": 3,
    "guardian": "goat"
   },
   {
    "id": "p11",
    "col": 11,
    "row": 6,
    "res": "wood",
    "level": 4
   },
   {
    "id": "p12",
    "col": 13,
    "row": 3,
    "res": "stone",
    "level": 4,
    "boars": true
   },
   {
    "id": "p13",
    "col": 15,
    "row": 10,
    "res": "crop",
    "level": 5,
    "boars": true
   },
   {
    "id": "p14",
    "col": 15,
    "row": 2,
    "res": "stone",
    "level": 5,
    "soulreaper": true
   }
  ]
 },
 "garrisons": {
  "p1": [
   "wolf",
   "wolf",
   "leopard"
  ],
  "p2": [
   "wolf",
   "wolf",
   "leopard"
  ],
  "p3": [
   "wolf",
   "wolf",
   "leopard"
  ],
  "p4": [
   "porcupine",
   "viper",
   "wolf"
  ],
  "p5": [
   "porcupine",
   "viper",
   "wolf"
  ],
  "p6": [
   "porcupine",
   "viper",
   "wolf"
  ],
  "p7": [
   "tiger",
   "rhino",
   "buffalo"
  ],
  "p8": [
   "ape",
   "tiger",
   "rhino"
  ],
  "p9": [
   "rat",
   "tiger",
   "rhino"
  ],
  "p10": [
   "goat",
   "tiger",
   "rhino"
  ],
  "p11": [
   "minion",
   "banditsaberman",
   "banditbowman",
   "assassin"
  ],
  "p12": [
   "boarknight7",
   "boarknight7",
   "boarknight7",
   "boarknight7",
   "minion",
   "assassin"
  ],
  "p13": [
   "boarknight7",
   "boarknight7",
   "boarknight7",
   "boarknight7",
   "minion",
   "assassin",
   "banditsaberman",
   "banditbowman"
  ],
  "p14": [
   "soulreaper",
   "boarknight7",
   "boarknight7",
   "boarknight7",
   "boarknight7"
  ],
  "enemyCapital": [
   "boarknight7",
   "boarknight7",
   "boarknight7",
   "boarknight7",
   "assassin",
   "assassin",
   "banditbowman",
   "banditbowman",
   "minion",
   "minion",
   "banditsaberman",
   "banditsaberman"
  ]
 },
 "typeTriangle": {
  "spear": "cavalry",
  "cavalry": "shield",
  "shield": "bow",
  "bow": "spear"
 },
 "reward": {
  "cap": 100,
  "perDay": 50,
  "firstCost": {
   "1": 1,
   "2": 1,
   "3": 1,
   "4": 2,
   "5": 3
  }
 },
 "demoNotes": [
  "Battle is an auto-resolve simulation with a detailed log (tactical grid movement is planned for a later version).",
  "A team fights as one stack: HP = count x per-soldier HP, ATK = count x per-soldier ATK (design choice for the demo).",
  "Hero skills are displayed with full documented text; in-battle they apply a simplified archetype (damage/heal/rage/defense) - noted per hero.",
  "Equipment effects use the documented values where mechanical; complex procs are approximated (see Help tab).",
  "Expertise numeric bonuses use the maximum documented tier.",
  "Production/march/reward-point clocks are accelerated for the demo (1 game hour = 4 real seconds).",
  "Per-level soldier stats are interpolated linearly between the documented Lv1 and Lv6 bracket values."
 ]
};
// Generated by gen_data.py from the project's verified RE documentation. Do not edit by hand.
if (typeof module !== "undefined" && module.exports) module.exports = DATA;
if (typeof window !== "undefined") window.DATA = DATA;
