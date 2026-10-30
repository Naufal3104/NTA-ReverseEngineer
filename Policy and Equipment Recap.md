# Policy and Equipment Recap — Ninety Thousand Acres (九萬畝)

> **Package:** twgame.global.acers (v4.5.0) | **Source:** OCR extraction of 47 Policy + 66 Weapon/Equipment in-game screenshots (Gallery → Policy / Equipment tabs), captured 2026-10-24.
> **Companion files:** `ocr_policy.txt`, `ocr_weapon.txt` (raw OCR output), `ocr_extract.py` (extraction script), `Hero Skill and Expertise.md` (hero data).

---

## Extraction Notes (read first)

1. **Rarity:** Every policy and every equipment card displays a 4-star (★★★★) rarity badge in the detail panel. Some sidebar rows render as ★★★★★ in OCR — this is most likely an OCR artifact of the star glyphs (CJK look-alikes such as `大`/`食`/`人` appear in place of `★`), but a small number of higher-tier items may genuinely be 5-star. **Needs one manual in-game check to confirm.**
2. **Policy value brackets `[x/y/z]`** = the three policy levels (Lv.1/Lv.2/Lv.3). All policies are 4-star cards with 3 levels.
3. **Equipment value brackets `[X-Y]`** = the equipment's rolled stat range (min–max). **Exclusive equipment shows two brackets = additional HP and additional ATK (user-confirmed 2026-10-26)** — first bracket HP, second ATK (e.g. Mountain Splitting Axe `[35-65]` HP / `[4-10]` ATK; shields roll `[50-100]/[1-2]`, bows roll `[10-20]/[2-10]`). Common equipment shows one bracket — by magnitude this is most likely the item's main stat (weapons roll small ranges like `[2-10]` ≈ ATK, armor rolls large ranges like `[20-70]` ≈ HP; inference, unconfirmed). The numeric ranges inside each effect description scale with the roll.
4. **OCR errors corrected** in this recap: `[15-301` → `[15-30]`, `[10-3010/` → `[10-30]%`, `icno more than` → `is no more than`, `RedurecHPhv(5no/*FvrecciveDMG)` → `Reduces HP by (50%*Excessive DMG)`, `Haca[1n-3510%rhanretodndae` → `Has a [10-35]% chance to dodge all DMG`, `Farh attarl orantc ovtra 1 Raae` → `Each attack grants extra 1 Rage`, `ctarkahleiinto[1n-15ltimeclnrreae` → `stackable up to [10-15] times. Increases`, `PerDMGtalen nevtattark'cIeerh` → `Per DMG taken, next attack's Leech…`.
5. **Sidebar name truncation:** item names in the left list are cut off (e.g. `Bountifu...`, `Siege Ex...`). Full names are only readable in the detail panel of each screenshot.

---

# PART 1 — POLICIES (47 total — COMPLETE, user-confirmed 2026-10-26)

All policies are **★★★★ cards with 3 levels**. Policies in the same list position order as the in-game Gallery sidebar. Building requirements are shown in parentheses.

## 1.1 Economy & Production (10)

| # | Policy | Effect [Lv.1/Lv.2/Lv.3] | Requirement |
|---|--------|------------------------|-------------|
| 1 | **Bountiful Harvest** | Basic Output +[100/150/200]/h | — |
| 2 | **Super Bounty** | Basic Resource via Super Chest +[20/40/60]% | — |
| 3 | **Idle Profits** | EXP Scroll & Iron +[2/4/8]% per day | — |
| 4 | **Abundant Resources** | If EXP Scroll & Iron > 100, +[5/10/15]% per day | — |
| 5 | **Farm Mogul** | Farm has a [10/20/30]% chance to produce EXP Scrolls/Iron per hour | — |
| 6 | **Quarry Mogul** | Quarry has a [10/20/30]% chance to produce Iron per hour | — |
| 7 | **Sawmill Mogul** | Sawmill has a [10/20/30]% chance to produce EXP Scrolls per hour | — |
| 8 | **Hidden Prowess** | Barn & Warehouse capacity +[500/1000/1500] per level | Barn Lv.1, Warehouse Lv.1 |
| 9 | **Empower Trade** | Merchant Freight Volume +1000, Transit Time -[20/40/60]% | — |
| 10 | **Fantastic Bargain** | Nature Exchange +1/day, Handling Fee -[30/45/60]% | — |

## 1.2 Construction & Time Reduction (3)

| # | Policy | Effect [Lv.1/Lv.2/Lv.3] | Requirement |
|---|--------|------------------------|-------------|
| 11 | **Industrial Revolution** | Construction time -[20/40/60]% | — |
| 12 | **Imminent Victory** | Construction & Removal Time of All Ground Buildings -[40/60/80]% | — |
| 13 | **Exquisite Architecture** | Capacity of All Ground Buildings +[2/3/4] | — |

## 1.3 Recruitment, Training & March (10)

| # | Policy | Effect [Lv.1/Lv.2/Lv.3] | Requirement |
|---|--------|------------------------|-------------|
| 14 | **Warrior's Mindset** | Recruiting time -[10/20/30]% | — |
| 15 | **Perseverance** | Training time -[30/45/60]% | Drill Ground Lv.1 |
| 16 | **Talent Acquisition** | [20/30/40]% chance to recruit Lv.2 soldiers | — |
| 17 | **Unhindered Conscription** | Recruitment Queue of Barrack +[3/6/9] | — |
| 18 | **Talents Gathering** | Training Queue of Drill Ground +[3/6/9] | Drill Ground Lv.1 |
| 19 | **Mercenary Lord** | Gains [10/20/30] free attempt(s) to recruit soldiers | — |
| 20 | **Council of Sages** | Gains [10/20/30] free attempt(s) to train soldiers | — |
| 21 | **Expansion Protocol** | Army capacity +[1/2/3] | — |
| 22 | **Rapid March** | Marching time -[10/20/30]% | — |
| 23 | **Emergency Relief** | Marching SPD +[4/5/6] between Capital and Fortress | — |

## 1.4 Healing & Clinic (3)

| # | Policy | Effect [Lv.1/Lv.2/Lv.3] | Requirement |
|---|--------|------------------------|-------------|
| 24 | **Prosperous Hub** | Healing Queue of Clinic +[3/6/9] | Clinic Lv.1 |
| 25 | **Healer's Touch** | Wounded Soldier's Heal time -[10/20/30]% | Clinic Lv.1 |
| 26 | **Saint's Mercy** | Gains [3/6/9] free attempt(s) to heal soldiers | Clinic Lv.1 |

## 1.5 Smithy & Equipment (2)

| # | Policy | Effect [Lv.1/Lv.2/Lv.3] | Requirement |
|---|--------|------------------------|-------------|
| 27 | **Rekindled** | [20/30/40]% chance to recast equipment for free | Smithy Lv.1 |
| 28 | **Thoroughly Tempered** | Gains [3/6/9] free attempt(s) to craft or recast equipment | Smithy Lv.1 |

## 1.6 Defense & Garrison (3)

| # | Policy | Effect [Lv.1/Lv.2/Lv.3] | Requirement |
|---|--------|------------------------|-------------|
| 29 | **Heart of Protection** | Watchtower level +[3/6/9] | — |
| 30 | **Bountiful Year** | Grain Garrison Time -[20/40/60]% | — |
| 31 | **Timely Rain** | Gains a Chest when Grain Garrison +[1/2/3] | — |

## 1.7 Seasonal (2)

| # | Policy | Effect [Lv.1/Lv.2/Lv.3] | Requirement |
|---|--------|------------------------|-------------|
| 32 | **Golden Opportunity** | Gains 3 Scrolls immediately; gains [3/6/9] Scroll(s) when each season starts | — |
| 33 | **Bedrock Foundation** | Gains 3 Nails immediately; gains [3/6/9] Nail(s) when each season starts | — |

## 1.8 Battle — All Soldiers (10)

| # | Policy | Effect [Lv.1/Lv.2/Lv.3] | Requirement |
|---|--------|------------------------|-------------|
| 34 | **Guardian Aura** | Soldiers' Max HP +[15/20/30]% when they battle on the Territory of your own side | — |
| 35 | **Warhorn** | Soldiers' ATK +[10/15/20]% when they battle on the Territory of the enemy side | — |
| 36 | **Armor Mastery** | +[10/20/30] Max HP per Level for All Soldiers | — |
| 37 | **Beastbane** | All soldiers' DMG dealt to the Neutral Unit +[20/30/50]% | — |
| 38 | **Siege Expert** | All soldiers have a [30/40/50]% chance to deal +1 DMG to buildings | — |
| 39 | **Perpetual Cycle** | All soldiers restore HP by ([1/2/3] * own level) each round | — |
| 40 | **Mighty Power** | All max-level soldiers' DMG dealt +[10/15/20]%, DMG taken -[10/15/20]% | — |
| 41 | **Devastating Move** | Increases all soldiers' DMG dealt to targets with a lower level than themselves by ([10/15/20] * Level Gap)% | — |
| 42 | **Siege and Conquer** | Immediately unlocks Catapult; Catapult's DMG dealt to buildings +[1/2/3] | — |
| 43 | **Fortress Chain** | When City Wall, Fortress, and Watchtower attack the same target continuously, each DMG +[4/8/12]%, stackable up to 20 times | — |

## 1.9 Battle — Troop-Category Mastery (4)

| # | Policy | Effect [Lv.1/Lv.2/Lv.3] | Requirement |
|---|--------|------------------------|-------------|
| 44 | **Spearman Mastery** | All Spearmen's Leech +[10/20/30]% | — |
| 45 | **Shield Soldier Mastery** | All Shield Soldiers' DMG taken -[15/25/35]% | — |
| 46 | **Bowman Mastery** | All Bowmen's DMG dealt +[10/15/20]% | — |
| 47 | **Cavalry Mastery** | All Cavalry's Max HP and ATK +[8/12/16]% | — |

## 1.10 Sidebar OCR artifacts — RESOLVED (no undocumented policies)

Initial OCR of the Gallery sidebar suggested 4 extra policies between "Warhorn" and "Bountiful Year" (`Weapon M...`, `Primordi...`, `Opportun...`, `Plunderer`). **User confirmed (2026-10-26) that the 47 policies above are the complete set** — every policy in the game was screenshotted. The 4 truncated strings were OCR artifacts of already-documented rows, most plausibly:

| Truncated string | Most likely actual policy |
|------------------|---------------------------|
| `Opportun...` | **Golden Opportunity** (#34) |
| `Weapon M...` | one of the Mastery policies (#41–47), e.g. Bowman Mastery ("Bowman" misread as "Weapon") |
| `Primordi...` | garbled row — no separate policy exists |
| `Plunderer` | garbled row — no separate policy exists |

---

# PART 2 — EQUIPMENT (66 total: 42 Common + 24 Exclusive)

Equipment is crafted/recast at the **Smithy**. Each item shows a rolled stat range `[X-Y]` and one passive effect. Smithy unlock tiers observed: **Lv.1, 3, 5, 7, 12, 14** for common gear; **Lv.10** for all exclusive gear.

## 2.1 Common Equipment — Smithy Lv.1 (6)

| # | Equipment | Roll | Effect |
|---|-----------|------|--------|
| 1 | **Cureblade** | [1-5] | Restores [4-10] HP upon dealing effective DMG, with a 40% chance to restore the same HP for 1 ally with the lowest HP within 5 tiles. Cannot heal weaponry. The restoration is halved if the ATK Range is more than 2. |
| 2 | **Crit Blade** | [2-10] | There is a [20-40]% chance to deal [150-180]% Crit DMG. |
| 3 | **Meteor Hammer** | [2-10] | ATK Range +1. Ignores [30-70]% Dodge upon attacking. |
| 4 | **Dual Axe** | [2-10] | Each attack grants extra 1 Rage. Has a [20-50]% chance to gain 50% more Rage after casting skills. |
| 5 | **Crescent Blade** | [2-8] | Increases DMG dealt by [20-50]% and DMG taken by 100%, ignoring 20% DMG Reduction. |
| 6 | **Longyuan Sword** | [2-8] | ATK +[10-20]%. There is a 30% chance to +1% ATK after the first attack in each round. Stackable without limit. |

## 2.2 Common Equipment — Smithy Lv.3 (6)

| # | Equipment | Roll | Effect |
|---|-----------|------|--------|
| 7 | **Chainmail** | [20-70] | DMG taken -5. For every 1 effective attack taken, there is a [5-20]% chance to reduce the DMG taken by 1. For every 50 Max HP owned, +1 stackable chance. |
| 8 | **Wine Gourd** | [20-50] | Restores [1-4]% of the max HP at the start of each round. |
| 9 | **DMG Reflection Armor** | [20-80] | There is a [20-40]% chance to reflect 5 True DMG to the attacker upon taking DMG. For every 50 Max HP owned, +1 reflected DMG. |
| 10 | **Copper Shield** | [20-60] | The first time HP drops below 50%, gains (Max HP*[5-15]%) Shield point and restores 30% of the Max HP. |
| 11 | **Golden Axe** | [20-40] | When dealing effective DMG to a target, has a [50-80]% chance to gain a Shield equal to (4 + own level)% of the target's Max HP. Cannot be stacked. |
| 12 | **Iron Shield** | [20-70] | Melee DMG -[10-35]%. Doubles the effect at less than 50% HP. |

## 2.3 Common Equipment — Smithy Lv.5 (5)

| # | Equipment | Roll | Effect |
|---|-----------|------|--------|
| 13 | **Leech Sword** | [20-40] | Upon attacking, restores ([10-50]% * DMG dealt) HP and converts excessive HP into a Shield, up to self Level*6. |
| 14 | **Circle Blade** | [20-40] | Per DMG taken, next attack's Leech +[4-10]%, stackable up to 60%. Increases next attack's DMG by 30% upon reaching 30% Leech. |
| 15 | **Obsidian Armor** | [20-50] | In the first 5 rounds upon entering a battle, gains [40-80]% DMG Reduction. Afterward, increases DMG taken by 50%, lasting until the end of the battle. |
| 16 | **Radiant Plate Armor** | [20-50] | Max HP +0%, DMG Reduction +0%, one of which is increased by 1% when the equipment is recast. Can be recast up to 50 times. |
| 17 | **Thousand Tempered Blade** | [20-40] | ATK +0%, Leech +0%, one of which is increased by +1% when the equipment is recast. Can be recast up to 50 times. |

## 2.4 Common Equipment — Smithy Lv.7 (9)

| # | Equipment | Roll | Effect |
|---|-----------|------|--------|
| 18 | **Darts** | [4-14] | Converts [20-50]% DMG dealt into True DMG. |
| 19 | **Rattan Shield** | [20-60] | Ranged DMG -[30-60]%. Halves the effect at less than 50% HP. |
| 20 | **Mace** | [2-8] | Deals ([1-5]% * target's current HP) additional DMG. |
| 21 | **Army Flag** | [20-50] | Upon death, drops an Army Flag with [2-4] HP. In 2 tiles, allies' DMG +20% while enemies' DMG -20%. Only one Army Flag can occupy a location. |
| 22 | **Qiankun Saber** | [2-8] | Basic attacks deal extra ([30-60]% * ATK) True DMG to up to 4 enemies within 1 tile around the target. |
| 23 | **Sunfire Armor** | [20-60] | At the start of each round, there is a [20-50]% chance to deal True DMG by 4% of self Max HP to up to 4 enemies within 1 tile. |
| 24 | **Helmet of Calmness** | [20-50] | Max HP +[10-20]%, restores 20% of the HP lost for self and up to 4 allies around self every 5 rounds. |
| 25 | **Pure Gold Shield** | [20-50] | Gains a Shield equal to 4% of Max HP every 3 rounds and increases any Shield effect on self by [20-50]%. |
| 26 | **Silver Serpent Whip** | [2-10] | Randomly selects the nearest target within the ATK Range upon launching a basic attack; if the target is new, DMG dealt to the target +[20-50]%. |

## 2.5 Common Equipment — Smithy Lv.12 (10)

| # | Equipment | Roll | Effect |
|---|-----------|------|--------|
| 27 | **Lamellar Cuirass** | [20-80] | DMG taken is no more than [15-30]. Reduces HP by (50% * Excessive DMG) each turn for several turns. If reduced HP is no higher than [15-30], reduces (100% * Excessive DMG) HP instead. |
| 28 | **Hook Swords** | [2-8] | There is a [15-35]% chance to deal additional True DMG by (2 + own level)% * target's max HP, (1 + own level)% for a ranged owner. |
| 29 | **Mirror Armor** | [20-70] | Upon being attacked by different targets, gains 4% DMG Reduction, stackable up to [10-15] times. Increases Max HP by 10% when stacked to 8 times. |
| 30 | **Battle Axe** | [2-8] | When HP drops to 50% for the first time, ATK +(3 * Self Level), and Leech +[10-30]%. |
| 31 | **Jade Pendant** | [20-50] | At the start of the first round, grants the 3 closest allies a shield equal to [5-10]% of self Max HP and defends DMG dealt by active skills for once, lasting for 10 rounds. |
| 32 | **Lethal Umbrella** | [20-40] | When a battle starts, ATK +[5-15]%, DMG Taken -[5-15]%, and doubles a random effect from above. |
| 33 | **Ring of Burning Heart** | [2-6] | When a skill hits a target, there is a 50% chance to inflict Burning Heart, causing the target to take additional True DMG equal to [20-40]% of ATK each round. When the target takes True DMG during their turn, splashes (self level * 10)% onto up to 4 enemies within 1 tile for 3 rounds. |
| 34 | **Billhook** | [2-8] | Deals additional DMG equal to ([4-8] * own level)% of the target's ATK. |
| 35 | **Bloodrage Belt** | [20-50] | Restores (4% of Max HP + 40% of ATK) HP after casting skills. Meanwhile, when taking ATK DMG each time, there is a [30-50]% chance to additionally +1 Rage. |
| 36 | **Spiked Mace** | [2-8] | When a target is killed, deals extra ([50-100]% * ATK) True DMG to up to 8 enemies within 2 tiles around the target. |

## 2.6 Common Equipment — Smithy Lv.14 (6)

| # | Equipment | Roll | Effect |
|---|-----------|------|--------|
| 37 | **Dodge Boots** | [20-50] | Has a [10-35]% chance to dodge all DMG. |
| 38 | **Flying Guillotine** | [2-8] | Slays targets with HP lower than [5-20]% and gains ATK +1 until the battle ends. |
| 39 | **Time Flag** | [30-43] | 1 random type(s) from the following effects: ① Only grants HP — increases HP by (3 + self level)*10 each season. ② Only grants ATK — increases ATK by (3 + self level) each season. |
| 40 | **Hourglass** | [2-4] | Has a [5-25]% chance of acting 2 rounds. |
| 41 | **Blinding Pendant** | [20-50] | When taking True DMG, there is a [10-35]% chance to stun the attacker for 1 round. |
| 42 | **Darksteel Staff** | [20-40] | When attacking a new target each time, deals extra ([10-25]% * target's Max HP) True DMG and gains a Shield equal to 40% of the DMG dealt. Each target can only trigger this effect once. |

## 2.7 Exclusive Equipment — Smithy Lv.10 (24)

Each of the **24 soldier sub-types** has exactly one exclusive equipment. Structure of every exclusive item:

```
[Name]  —  <Sub-type> Exclusive Equipment
[Additional HP range] / [Additional ATK range]         ← user-confirmed
"2 random type(s) from the following effects:"        ← rolled from the COMMON equipment effect pool (see 2.8)
+ one fixed skill modification unique to the sub-type  ← the item's patent/unique effect
Unlocks at Lv.10 Smithy
```

### Spear category (6)

| # | Equipment | Sub-type | HP / ATK | Skill modification |
|---|-----------|----------|------|--------------------|
| 43 | **Spear** | Longspearman | [20-40] / [4-12] | **Stab:** Stabs +1 tile in the target's direction. For every 1 target hit, gains 15% Dodge, lasting for 3 rounds. |
| 44 | **Lance** | Lancer | [20-40] / [4-13] | **Project:** Also deals (allied soldier count * own level) additional DMG (multiplier cannot exceed 40). |
| 45 | **Dagger-axe** | Dagger-axe Soldier | [20-40] / [4-10] | **Disarm:** Disarms up to 4 enemies within 1 tile around the target. |
| 46 | **Modao Saber** | Modao Soldier | [20-40] / [4-15] | **Steady Attack:** The first 3 attacks deal max DMG of the random range, and the following attack after killing the target will also deal max DMG. |
| 47 | **Two-handed Sword** | Long Swordsman | [25-45] / [4-10] | **Whirlwind:** When an enemy within 2 tiles triggers Bleed, self restores HP by 40% of the Bleed DMG. |
| 48 | **Double Halberds** | Twin Spearman | [20-40] / [4-12] | **Unbridled Dance:** Parry Duration after dancing wildly +1 round. |

### Shield category (6)

| # | Equipment | Sub-type | HP / ATK | Skill modification |
|---|-----------|----------|------|--------------------|
| 49 | **Wood Shield** | Saber&Shield Soldier | [50-100] / [1-2] | **Shield:** When granting Shield, additionally increases Shield value by 5% of self Max HP. |
| 50 | **Heavy Shield** | Heavy Shield Soldier | [60-120] / [1-2] | **Shield Stance:** Per enemy around the shield, DMG taken -5%. |
| 51 | **Long Spear** | Spear&Shield Soldier | [45-90] / [1-4] | **Charge:** Also deals (5% * own max HP) additional DMG to the target. |
| 52 | **Iron Hammer** | Hammer&Shield Soldier | [40-80] / [1-2] | **Earthshaker:** Also increases Rage by 1 for allies within range whose Rage is below half. |
| 53 | **Sword&Shield** | Sword&shield Soldier | [30-70] / [2-6] | **Guardian Sword:** Each time taking DMG out of own round, next attack DMG +3%. |
| 54 | **Axe&Shield** | Axe&Shield Soldier | [30-70] / [2-8] | **Enhancement:** Bounce Time of Whirling Axe +2. Shield Bash's Chance of Stunning the Target +20%. |

### Bow category (6)

| # | Equipment | Sub-type | HP / ATK | Skill modification |
|---|-----------|----------|------|--------------------|
| 55 | **Longbow** | Longbowman | [10-20] / [2-10] | **Scatter:** The extra attack hits 4 targets instead. |
| 56 | **Crossbow** | Crossbowman | [10-20] / [2-8] | **Dexterity:** When taking ATK DMG, there is a 30% chance to dodge it. For every 1 tile away from the attacker, the chance is reduced by 10%. |
| 57 | **Toxibow** | Toxibowman | [10-20] / [2-8] | **Poison Arrow:** Has a (10 * self level)% chance of paralyzing the target for 1 round, making them unable to move or attack. If the target is paralyzed multiple times successively, they will enter the Fragile status, increasing their DMG taken by 30%. |
| 58 | **Hunter's Bow** | Hunter | [10-20] / [2-8] | **Inspire:** Additionally restores (1 + own level) HP for all allies. |
| 59 | **Improved Crossbow** | Improved Crossbowman | [10-20] / [2-10] | **Anchor:** Knocks back the target by 1 tile in the max attack range, except those in Shield Stance or weaponry. |
| 60 | **Bow of Fire** | Fire Bowman | [10-20] / [2-8] | **Wildfire:** When flames are triggered, they also trigger nearby allies' flames. |

### Cavalry category (6)

| # | Equipment | Sub-type | HP / ATK | Skill modification |
|---|-----------|----------|------|--------------------|
| 61 | **Great Sword** | Sword Cavalry | [20-40] / [4-13] | **Leap Slash:** Killing a target with Leap Slash has an 85% chance of granting one more slash. |
| 62 | **Halberd** | Spear Cavalry | [30-60] / [4-10] | **Sweep:** Inflicts 20% Leech when sweeping. |
| 63 | **Guandao** | Broadsword Cavalry | [20-40] / [4-15] | **Chop:** Reserves 50% of the stacked DMG when switching the target. |
| 64 | **Sledge Hammer** | Heavy Cavalry | [50-100] / [2-8] | **Charge:** Up to 4 targets knocked airborne are also stunned for 1 turn. |
| 65 | **Recurve Bow** | Bow Cavalry | [15-25] / [2-8] | **Guerrilla:** ATK +20% to a Melee target. |
| 66 | **Mountain Splitting Axe** | Axe Cavalry | [35-65] / [4-10] | **Cleave:** When Cleave is triggered, gains 6 Shield for each target hit; otherwise, DMG +30%. |

## 2.8 Random Effect Pool (for Exclusive Equipment)

Every exclusive equipment rolls **2 random effects** drawn from the common-equipment effect pool. The effects observed across the 24 exclusive panels (each panel lists ~6-9 candidate effects) map 1:1 to common equipment effects:

| Pool effect (paraphrased) | Source common item |
|---------------------------|---------------------|
| Restores [4-10] HP on effective DMG + 40% chance to heal lowest-HP ally within 5 tiles | Cureblade |
| [20-40]% chance to deal [150-180]% Crit DMG | Crit Blade |
| DMG dealt +[20-50]%, DMG taken +100%, ignores 20% DMG Reduction | Crescent Blade |
| ATK +[10-20]%, 30% chance +1% ATK after first attack each round (stackable) | Longyuan Sword |
| Each attack +1 Rage; [20-50]% chance +50% Rage after casting skills | Dual Axe |
| DMG taken -5; [5-20]% chance -1 DMG per effective attack taken; +1 chance per 50 Max HP | Chainmail |
| Restores [1-4]% max HP at start of each round | Wine Gourd |
| [20-40]% chance to reflect 5 True DMG; +1 per 50 Max HP | DMG Reflection Armor |
| First time HP < 50%: Shield (Max HP*[5-15]%) + restore 30% Max HP | Copper Shield |
| Effective DMG → [50-80]% chance Shield = (4+level)% of target's Max HP | Golden Axe |
| Melee DMG -[10-35]% (doubled below 50% HP) | Iron Shield |
| Attack restores ([10-50]%*DMG) HP; excess HP → Shield up to Level*6 | Leech Sword |
| Per DMG taken: next attack Leech +[4-10]% (max 60%); 30% DMG boost at 30% Leech | Circle Blade |
| First 5 rounds: [40-80]% DMG Reduction; then +50% DMG taken | Obsidian Armor |
| Converts [20-50]% DMG dealt into True DMG | Darts |
| Ranged DMG -[30-60]% (halved below 50% HP) | Rattan Shield |
| Deals ([1-5]%*target's current HP) additional DMG | Mace |
| Basic attacks: extra ([30-60]%*ATK) True DMG to up to 4 enemies within 1 tile | Qiankun Saber |
| Each round: [20-50]% chance True DMG = 4% self Max HP to up to 4 enemies within 1 tile | Sunfire Armor |
| Max HP +[10-20]%; restores 20% of HP lost for self + 4 allies every 5 rounds | Helmet of Calmness |
| Shield = 4% Max HP every 3 rounds; Shield effects +[20-50]% | Pure Gold Shield |
| Basic attack targets nearest enemy; new target → DMG +[20-50]% | Silver Serpent Whip |
| DMG taken ≤ [15-30]; excess HP loss deferred over turns | Lamellar Cuirass |
| [15-35]% chance: True DMG (2+level)%*target's Max HP ((1+level)% ranged) | Hook Swords |
| Attacked by different targets → 4% DMG Reduction (max [10-15] stacks; +10% Max HP at 8) | Mirror Armor |
| First time HP ≤ 50%: ATK +(3*level), Leech +[10-30]% | Battle Axe |
| Round 1: 3 closest allies get Shield [5-10]% Max HP; blocks 1 active-skill DMG (10 rounds) | Jade Pendant |
| Battle start: ATK +[5-15]%, DMG taken -[5-15]%, doubles one of them | Lethal Umbrella |
| Skill hit → 50% chance Burning Heart ([20-40]% ATK True DMG/round; splash on True DMG) | Ring of Burning Heart |
| Additional DMG = ([4-8]*level)% of target's ATK | Billhook |
| After casting skills: restore (4% Max HP + 40% ATK) HP; [30-50]% chance +1 Rage when hit | Bloodrage Belt |
| Target killed → ([50-100]%*ATK) True DMG to up to 8 enemies within 2 tiles | Spiked Mace |
| [10-35]% chance to dodge all DMG | Dodge Boots |
| Slays targets below [5-20]% HP; +1 ATK per kill | Flying Guillotine |
| New target → extra ([10-25]%*Max HP) True DMG + Shield = 40% of that DMG (once per target) | Darksteel Staff |

> **Design insight:** the exclusive equipment system = 2 random common-gear passives + 1 fixed sub-type skill upgrade + exclusive stat rolls. This means the passive pool for exclusives can be implemented by reusing the 42 common effect definitions.

---

# PART 3 — SYSTEM NOTES & CROSS-REFERENCES

## 3.1 Equipment crafting / recast loop

- **Smithy** unlocks equipment tiers: Lv.1 → Lv.3 → Lv.5 → Lv.7 → Lv.12 → Lv.14 (common), Lv.10 (exclusive). The capture device's Smithy was Lv.7→10 in progress ("Upgrade 'Smithy' to Lv.10 (7/10)" watermark on every screenshot).
- **Recast** re-rolls equipment. `Radiant Plate Armor` and `Thousand Tempered Blade` explicitly grow per recast (+1% to one of two stats, up to 50 recasts). Policy **Rekindled** gives a chance for free recasts; **Thoroughly Tempered** grants free craft/recast attempts.
- **Time Flag** is the only equipment with *season-scaling* stats (HP or ATK per season), matching the game's season system (see Golden Opportunity / Bedrock Foundation policies).

## 3.2 Battle-mechanics vocabulary confirmed by equipment text

- **True DMG** — separate damage type (ignores reduction; reflected, splashed, converted).
- **Shield** — absorbable HP layer (stacking rules per item; "Cannot be stacked", "increases any Shield effect").
- **Leech** — heal from damage dealt.
- **Rage** — skill resource; equipment can grant +1 Rage per attack, +50% after casting, +1 when taking ATK DMG (consistent with the hero Rage system in `Hero Skill and Expertise.md`).
- **Burning Heart / Bleed / Fragile / Paralysis(Paralyzed) / Stun / Knock-back / Knock airborne / Disarm** — status effects.
- **Burning Heart splash** and several AoE passives use the "up to 4 enemies within 1 tile" pattern; Spiked Mace uses "up to 8 enemies within 2 tiles" — battle is tile-based, consistent with the round-based + tile-based battle model.
- **Weaponry** is a distinct unit class that cannot be healed (Cureblade: "Cannot heal weaponry") and is immune to knock-back (Anchor: "except those in Shield Stance or weaponry").
- **Shield Stance** is a soldier state referenced by both Crossbowman's Dexterity (dodge vs distance) and Improved Crossbowman's Anchor (knock-back immunity) — matches the Heavy Shield Soldier skill of the same name.

## 3.3 Soldier skills × exclusive equipment cross-reference (verified against `SoldierAttribute.md`, 2026-10-26)

The 24 sub-types in the exclusive equipment list match `SoldierAttribute.md` 1:1. The exclusive's "skill modification" either **enhances the soldier's existing skill** or **adds/replaces a named passive**:

| Sub-type | Soldier skill (authoritative) | Exclusive's modification | Relationship |
|----------|------------------------------|--------------------------|--------------|
| Longspearman | **Stabs** | Stab: +1 tile reach; +15% Dodge per target hit (3 rounds) | enhances Stabs |
| Lancer | **Project** | + (allied soldier count * level) DMG, cap 40 | enhances Project |
| Dagger-axe Soldier | **Disarm** | disarms up to 4 enemies within 1 tile of target | enhances Disarm |
| Modao | passives **Erratic Attack** + **Cavalry Suffer** (no active, Rage 0/0) | Steady Attack: first 3 attacks deal max DMG of the random range | stabilizes Erratic Attack's random roll |
| Long Swordsman | **Whirlwind** | heals 40% of Bleed DMG triggered within 2 tiles | enhances Whirlwind |
| Twin Spearman | **Unbridled Dance** | Parry duration +1 round | enhances Unbridled Dance |
| Saber&Shield Soldier | **Shield** | +5% self Max HP to Shield value | enhances Shield |
| Heavy Shield Soldier | **Shield Stance** | −5% DMG taken per adjacent enemy | enhances Shield Stance |
| Spear&Shield Soldier | **Charge** | + (5% * own max HP) DMG | enhances Charge |
| Hammer&Shield Soldier | **Earthshaker** | +1 Rage to in-range allies below half Rage | enhances Earthshaker |
| Sword&Shield Soldier | **Guardian Shield** (+ **Trainee Warrior** passive) | Guardian Sword: +3% next attack DMG per out-of-turn hit taken | adds offensive counterpart passive |
| Axe&Shield Soldier | **Whirling Axe** (+ **Shield Bash** passive) | bounce +2; stun chance +20% | enhances both |
| Longbowman | **Scatter** | extra attack hits 4 targets | enhances Scatter |
| Crossbowman | **Rapid Fire** | Dexterity: 30% dodge vs ATK DMG, −10% per tile of distance | adds defensive passive (does not touch Rapid Fire) |
| Toxibowman | **Poison Arrow** | (10*level)% paralysis 1 round; repeat → Fragile (+30% DMG taken) | enhances Poison Arrow |
| Hunter | **Inspire** (+ **Hunting** passive: ATK +30% vs Beasts) | + (1+level) HP to all allies | enhances Inspire |
| Improved Crossbowman | passives **Draw** + **Anchor** (DMG +[15-20]% per tile) | Anchor: knock-back 1 tile at max attack range (not Shield Stance / weaponry) | **replaces** Anchor's distance bonus with knock-back |
| Fire Bowman | **Fire Arrow** (+ **Fire Intensity** passive) | Wildfire: flames also trigger nearby allies' flames | enhances Fire Arrow's flames |
| Sword Cavalry | **Leap Slash** | 85% chance one more slash on kill | enhances Leap Slash |
| Spear Cavalry | **Sweep** | +20% Leech while sweeping | enhances Sweep |
| Broadsword Cavalry | **Chop** | keeps 50% of stacked DMG on target switch | enhances Chop |
| Heavy Cavalry | **Collide** | Charge: up to 4 targets knocked airborne are also stunned 1 turn | enhances Collide (exclusive calls it "Charge") |
| Bow Cavalry | **Equestrian Archery** | Guerrilla: +20% ATK vs Melee targets | adds passive (does not touch Equestrian Archery) |
| Axe Cavalry | passives **Shattered Armor** + **Cleave** | 6 Shield per target hit when Cleave triggers, else +30% DMG | enhances Cleave |

## 3.4 Open questions / to verify in-game

1. ~~4 undocumented policies~~ — **RESOLVED 2026-10-26**: user confirmed the 47 documented policies are the complete set (§1.10 sidebar strings were OCR artifacts).
2. ~~Meaning of the two roll brackets on exclusive equipment~~ — **RESOLVED 2026-10-26**: user confirmed the top brackets = additional HP and additional ATK.
3. **Rarity of equipment** — confirm whether all gear is ★★★★ or if Smithy-tier ≥5 gear is ★★★★★ (sidebar stars were ambiguous in OCR).
4. **Stat type of common equipment's single bracket** — likely ATK for weapons / HP for armor based on magnitude (Extraction Notes #3), needs one labeled screenshot.
5. **Whether common equipment can also roll 2 effects at higher tiers** — all captured common items show exactly 1 effect.
6. **Equipment slot count per hero/army** — not visible in any captured screen (how many items a single soldier/hero can wear).
7. ~~Soldier attribute documentation~~ — **RESOLVED 2026-10-26**: user delivered `SoldierAttribute.md` (24 soldiers + 2 weaponry, authoritative). Skill names reconciled in §3.3.

---

*Recap generated from OCR of 113 screenshots (47 Policy + 66 Weapon). Raw text: `ocr_policy.txt`, `ocr_weapon.txt`. For hero data see `Hero Skill and Expertise.md`; for the rebuild plan see `REBUILD_GUIDE.md` §17.*
