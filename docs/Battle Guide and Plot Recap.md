# Battle Guide and Plot Recap — Ninety Thousand Acres (九萬畝)

> **Package:** twgame.global.acers (v4.5.0) | **Sources:** OCR of `Battle Guide/` (8 screenshots) + `Plot/` (65 screenshots; 46 re-cut detail crops captured 2026-10-26 PM → `ocr_plot_crops.txt`); `SoldierAttribute.md` (user-authored, authoritative soldier data); user-confirmed rules (plot composition, spawn rules, turn order, chests, difficulty cap, guardian equipment) recorded 2026-10-26.
> **Companion files:** `ocr_battleguide.txt`, `ocr_plot.txt`, `ocr_plot_crops.txt` (raw OCR), `SoldierAttribute.md`, `Policy and Equipment Recap.md`, `Hero Skill and Expertise.md`.

---

## Extraction Notes (read first)

1. **Enemy stat panel layout:** HP `x/x`, Rage `initial/needed`, **Move Range** `Tile*n`, ATK, **ATK Range** `Tile*n`. The tile values' OCR order is scrambled on the four guardian bosses — resolved by constraints: Bandit Bowman reads `Tile*2 … Tile*4` = Move 2 / Range 4 (matches the Longbowman pattern), and every Iron Mountain Stance boss ("Unable to move") reads `Tile*0 … Tile*6` = **Move 0 / Range 6**.
2. **Unit "Level"** in the enemy panel is the unit's combat level, **not** the plot level (plot levels are 1–5, see Part 2).
3. **Rage `x/y`** for enemies uses the same format as soldiers (`SoldierAttribute.md`): initial Rage on battle entry / Rage needed to cast; reset to 0 after casting. Enemies with `0/0` have no active skill (passive-only).
4. Several screenshots are **event notifications** (Fortune's Favorite, Heaven Bestows Great Blessings, Smithy quest watermark "Upgrade 'Smithy' to Lv.10 (7/10)") and contain no enemy data.
5. **Skill panels:** Minion and Bandit Saberman have **no skills** (user-confirmed; Rage 0/0). Bandit Bowman's attribute panel is captured; its skill is user-documented (see §3.2). User notes the bestiary may still be missing a few beasts.

---

# PART 1 — BATTLEFIELD GUIDE (official in-game tips, 8 panels)

| # | Topic | Content |
|---|-------|---------|
| 1 | **Select suitable troops** | Deploy melee and ranged soldiers appropriately to maximize damage output. Too many melee soldiers reduces efficiency. |
| 2 | **Wear suitable equipment** | Different equipment suits different troops. DMG Reduction and Restoration types improve survival (Shield + DMG Reduction, ATK + HP Restoration). Pick per enemy: **Iron Shield** reduces enemy Melee DMG; **Rattan Shield** reduces enemy Ranged DMG. |
| 3 | **How to Adjust Army** | Soldier Editing Guide: open a single soldier's operation interface to change its team. **Teams: max 12 at Capital level 20** (user-confirmed); soldiers can be moved between teams and reordered within a team (e.g., slot 1 → slot 4). |
| 4 | **Land Level** | Lands are divided into **5 levels**. Higher land level → more Reward Points consumed, higher resource output, richer chest rewards. **6 difficulty levels of land conquest: Easy, Entry, Common, Advanced, Hard, Hell** (numbered sub-levels observed in play: Hard 3, Hell 1, Hell 2). Harder conquest → richer chests. **The longer the distance from the Capital, the harder the conquest**; at equal distance, higher land level = harder. |
| 5 | **Land Conquering Tips** | Multiple armies can conquer **one land at the same time** (significantly increases soldier survival with proper attack/defense strategy). Multiple armies can also conquer **multiple lands separately** (increases efficiency). |
| 6 | **Special Resources** | Resource lands boost output of the matching resource. **Wood Plots** → chance of EXP Scrolls from chests; **Stone Plots** → chance of Iron; **Crop Plots** → more crops. Higher difficulty → chance of **extra chests with special resources**; drop chances are shown in the chest details interface. (Observed plot chip: "10/10 · Hell 1 · +14/h · +10 Points".) |
| 7 | **Soldier's ATK SPD and Rage** | **Higher ATK SPD moves first and is more likely to be attacked.** Tap a soldier to check/adjust ATK SPD. Rage is gained by **both launching and receiving attacks**; equipment and expertise effects speed up Rage restoration. Skills cast once Rage accumulation completes. |
| 8 | **Barrack Recruitment Settings** | Default recruitment settings adjustable in the Barrack: **Change Soldier Skin, Change Initial SPD, Add Equipment**. |

---

# PART 2 — LAND / PLOT SYSTEM (user-confirmed)

## 2.1 Plot levels (1–5) and enemy composition

| Plot level | Typical garrison (user-confirmed) |
|------------|-----------------------------------|
| **1** | Beasts, low level — **random** from the beast pool, ordered by strength and plot distance from the capital |
| **2** | Beasts with unique skills, low level — **random**, ordered by strength and plot distance from the capital |
| **3** | High-level beasts |
| **4** | Bandits, low level, few |
| **5** | Bandits, high level, many |

- **Distance scaling:** the farther a plot is from the player's own capital, the stronger its beasts and bandits (same plot level, stronger units).
- **Difficulty cap (user-confirmed):** a plot's difficulty stops increasing at **12 tiles from the player's current capital** — beyond that distance, every plot of a given level sits at that level's maximum difficulty.
- **Difficulty sub-levels (user-confirmed):** Easy 1–3, Entry 1–3, Common 1–4, Advanced 1–4, Hard 1–4, Hell 1–2 (20 sub-levels total). Each plot level spans a fixed difficulty range — starting at its minimum near the capital and reaching its maximum at the 12-tile cap:

| Plot level | Difficulty range (near → far) |
|------------|-------------------------------|
| **1** | Easy 1 → Common 1 |
| **2** | Entry 3 → Common 3 |
| **3** | Common 4 → Advanced 3 |
| **4** | Advanced 4 → Hard 3 |
| **5** | Hard 4 → Hell 2 |

## 2.2 Special encounters (user-confirmed)

- **Boar Knight** spawns on **plot levels 4 and 5** at **Hard 3, Hell 1, and Hell 2**. At Hard 3 and Hell 1 it is accompanied by other bandits (count depends on difficulty), but **the Boar Knight count is always exactly 4**.
- **Soulreaper** — the strongest enemy in the game — appears at **Hell 2 together with 4 Boar Knights**.
- **Guardian beasts** (user-confirmed) appear on **plot level 3 beyond 12 tiles from the capital**, one per resource type: **Goat → Stone plot**, **Rat → Crop plot**, **Ape → Wood plot**.
- **Cross-reference with the difficulty ranges (§2.1):** Boar Knight's "Hard 3" = the maximum of level-4 plots; Hell 1–2 = the level-5 range; level-3 guardians (≥12 tiles) sit at **Advanced 3**, the level-3 maximum.

## 2.3 Territory capture (user-confirmed)

- Destroying an **unowned plot's flag** or an **enemy watchtower** transfers that territory to the attacker.

---

# PART 3 — BESTIARY (from 65 Plot screenshots)

## 3.1 Beasts (15)

| Beast | Level | HP | Rage | Move | ATK | Range | SPD | Skill |
|-------|-------|----|------|------|-----|-------|-----|-------|
| **Wolf** | 2 | 60 | 6/6 | 4 | 17 | 1 | 8 | **Wolf Howl** (Active): roars to inspire all allies within 5 tiles, +3 ATK and +20% DMG Reduction for 3 rounds. |
| **Leopard** | 2 | 88 | 0/0 | 4 | 20 | 1 | 7 | **Evade** (Passive): every 2 times hit, gains 100% Dodge against the next incoming DMG. |
| **Porcupine** | 2 | 91 | 4/8 | 3 | 16 | 1 | 7 | **Spine Burst** (Active): deals 75% ATK DMG to enemies within 1 tile. |
| **Viper** | 2 | 72 | 4/8 | 3 | 17 | 2 | 6 | **Venom Spit** (Active): randomly deals 70% ATK DMG to 1 target + Poison for 3 rounds (additional True DMG = 10% of target's current HP each round). |
| **Lion** | 3 | 394 | 5/10 | 4 | 20 | 1 | 7 | **Tear** (Active): deals (120%*ATK) DMG + bleed — (50%*ATK) True DMG each round and HP Restoration −60%, for 3 rounds. |
| **Elephant** | 3 | 473 | 5/10 | 3 | 31 | 1 | 9 | **Sling** (Active): hurls stones at the highest-HP target within 5 tiles, dealing (200%*ATK) DMG. |
| **Bear** | 3 | 368 | 6/12 | 3 | 25 | 1 | 9 | **Smash** (Active): deals extra (5% * target's Max HP) DMG and stuns the target for 1 round. |
| **Lizard** | 3 | 221 | 0/0 | 3 | 23 | 1 | 9 | **Scale Armor** (Passive): DMG taken −40%. |
| **Hedgehog** | 4 | 622 | 0/0 | 3 | 26 | 1 | 9 | **DMG Reflection** (Passive): reflects 35% of DMG taken to the attacker. |
| **Buffalo** | 5 | 725 | 6/12 | 3 | 33 | 1 | 9 | **Wild Collision** (Active): collides 2 tiles in the target direction, knocks up encountered enemies, dealing (50%*ATK) DMG. **Can break Shields and Shield Stance.** |
| **Tiger** | 5 | 648 | 4/8 | 3 | 35 | 1 | 7 | **Gash** (Active): deals extra (35%*ATK) DMG to up to 20 enemies within 1 tile around the target. |
| **Rhino** | 5 | 671 | 4/8 | 3 | 28 | 1 | 9 | **Trample** (Active): deals 75% ATK DMG to up to 8 units within 1 tile and stuns them for 1 round. |
| **Goat** ◆ | 8 | 1213 | 4/8 | **0** | 80 | **6** | 9 | **Iron Mountain Stance** (Passive): unable to move; ignores 70% DMG Reduction when attacking; reduces the attacker's DMG dealt by 70% when attacked. **Rampant Charge** (Active): knocks the target to the most-crowded place within 6 tiles, dealing (15%*Max HP) additional True DMG to up to 8 targets within 2 tiles + stun 1 round. |
| **Rat** ◆ | 8 | 1206 | 0/0 | **0** | 71 | **6** | 9 | **Iron Mountain Stance** (Passive). **Pestilence Infection** (Passive): when attacked by an enemy within 2 tiles, infects the attacker with 1 layer of Pestilence — each layer deals (5%*Max HP) True DMG to the owner each round; **stackable without limit**. |
| **Ape** ◆ | 8 | 1052 | 4/6 | **0** | 88 | **6** | 9 | **Iron Mountain Stance** (Passive). **Fury** (Active): removes all debuffs; each of the next 2 attacks deals (300%*ATK) DMG to the nearest target randomly + (50% of DMG dealt) additional True DMG to up to 8 enemies within 2 tiles. |

◆ = **guardian boss** (stationary artillery: Move 0, Range 6, Iron Mountain Stance). Placement **user-confirmed**: plot level 3, ≥12 tiles from the capital — Goat on Stone plots, Rat on Crop plots, Ape on Wood plots.

## 3.2 Bandits (6 types, 7 entries)

| Bandit | Level | HP | Rage | Move | ATK | Range | SPD | Skill |
|--------|-------|----|------|------|-----|-------|-----|-------|
| **Minion** | 6 | 611 | 0/0 | 3 | 29 | 1 | 8 | No skill (user-confirmed; Rage 0/0). |
| **Assassin** | 6 | 533 | 0/0 | 3 | 37 | 1 | 6 | **Crit** (Passive): attacks have a 99% chance to deal 150% DMG. |
| **Bandit Saberman** | 6 | 625 | 0/0 | 3 | 31 | 1 | 9 | No skill (user-confirmed; Rage 0/0). |
| **Bandit Bowman** | 6 | 247 | 0/4 | 2 | 20 | 4 | 6 | **(Active, user-documented):** deals additional DMG equal to **10% of the target's current HP**. A **Bowman-type** unit — counters **Spearman** per the type triangle (§4.3). Only the attribute panel was screenshotted; skill text is user-provided. |
| **Boar Knight** (weak variant) | 6 | 737 | 0/0 | 4 | 70 | 1 | 7 | Skills **never change across levels** (user-confirmed) — see Level 7 row. |
| **Boar Knight** (strong variant) | 7 | 827 | 0/0 | 4 | 85 | 1 | 7 | **Counter Shield Soldier** (Passive): when attacking Shieldman, ATK +40% and ignores 20% DMG Reduction; when attacked by Shieldman, the attacker's ATK −40%. **Fortitude** (Passive): Ranged DMG taken −60%. Attributes at unobserved levels may be estimated from the L6→L7 delta: **≈ +90 HP / +15 ATK per level**. |
| **Soulreaper** ◆ | 10 | 1074 | 4/6 | **0** | 125 | **6** | 6 | **Iron Mountain Stance** (Passive): unable to move; ignores 70% DMG Reduction when attacking; reduces the attacker's DMG dealt by 70% when attacked. **Frenzy Claw** (Active): randomly gashes the nearest target and up to 8 enemies within 2 tiles around it, 3 times, each dealing 20% DMG; after each gash the next gash's DMG +5%, **stackable without limit**. |

◆ = guardian boss. Soulreaper = strongest enemy in the game (Hell 2, escorted by exactly 4 Boar Knights — user-confirmed).

## 3.3 Bestiary design notes

- **Boar Knight's "Counter Shield Soldier"** uses the exact numbers of the soldier type-advantage system (Spearman vs Shieldman: +40% ATK, ignore 20% DMG Reduction, attacker ATK −40%) — it is engineered as a **Shieldman-counter**.
- **Sword&Shield Soldier's "Trainee Warrior"** passive (`SoldierAttribute.md`) gains a Leap stack (ATK +0.5, HP +5, up to [10–100]) **per Boar Knight slain** — a direct counterpick for Boar Knight encounters.
- **Hunter's "Hunting"** passive: ATK +30% vs Beasts — the anti-beast specialist.
- Guardian bosses (Goat, Rat, Ape, Soulreaper) share **Iron Mountain Stance** and the Move 0 / Range 6 profile: they must be approached under 70% incoming-DMG reduction; Rat punishes melee attackers with unlimited-stacking Pestilence.
- **Guardian equipment (user-confirmed):** every Iron Mountain Stance unit (Goat, Rat, Ape, Soulreaper) **wears random equipment** — the roll differs per game session but is identical throughout one session. Presumably drawn from the common-equipment effect pool (`Policy and Equipment Recap.md` §2).
- **Guardian ↔ resource-type matching (user-confirmed):** each plot-3 guardian matches its plot's resource — Goat guards **Stone**, Rat guards **Crop**, Ape guards **Wood** — the same resource axis that biases chest contents (Part 5).
- Buffalo's Wild Collision and Heavy Cavalry's Collide share the "breaks Shields and Shield Stance" wording — the anti-shield answer for beast and player armies alike.

---

# PART 4 — BATTLE MECHANICS (user-confirmed rules)

## 4.1 Attack deployment & turn order

1. When attacking a plot, the attacking armies are **stacked onto 1 tile at each entrance**.
2. **Turn 1:** the group that entered first attacks; then the enemies attack.
3. **Turn 2:** entering groups 2–5 attack (in entry order); then group 1 attacks **again, last in this turn**; then the enemies attack.
4. **Turn 3 onward:** the cycle continues (our groups attack, then enemies).

## 4.2 Positioning rule

- If an enemy advances to a tile adjacent to (within attack range of) our entry tile, **all our troops attack it in place and do not move** — even with the whole army stacked on 1 tile.
- Troops only move when **no enemy is within the tile range they can attack**.

## 4.3 Speed, Rage and order (from Battle Guide + SoldierAttribute.md)

- **ATK SPD** decides move order; a faster unit is also **more likely to be targeted**.
- Rage is gained by attacking **and** being attacked; equipment/expertise can accelerate it; the skill casts when Rage is full, then resets to 0.
- Soldier type advantage (from `SoldierAttribute.md`): **Spearman > Cavalry > Shieldman > Bowman > Spearman**. Attacking the countered type: +40% ATK and ignore 20% of their DMG Reduction. Being attacked by your counter: the attacker's ATK −40%.

---

# PART 5 — CHEST SYSTEM (user-confirmed)

| Chest | Source | Contents |
|-------|--------|----------|
| **Wood Chest** | unowned (conquered) plots | plot rewards |
| **Silver Chest** | unowned (conquered) plots | plot rewards |
| **Gold Chest** | unowned (conquered) plots | plot rewards |
| **Special Chest** | unowned (conquered) plots | **Nails or Scroll** |
| **Universal Chest** | capturing an **enemy capital** | granted whether you capture it yourself **or join the attack** on it |

- Higher plot level and higher difficulty → richer chests; higher difficulty can add **extra special-resource chests** (drop rates shown in the chest details UI).
- Resource-typed plots bias chest contents: Wood → EXP Scrolls, Stone → Iron, Crop → crops (Battle Guide Part 1 #6).

## 5.1 Reward Points economy (user-confirmed)

- **Reward Points:** capped at **100**; income **+50 per day**.
- **First-time conquest chest cost** (spent to receive the plot's chests): plot **lvl 1–3 = 1 point**, **lvl 4 = 2**, **lvl 5 = 3**.
- **Grain Garrison** (repeatable): grants the plot's chests again — **same count as first-time conquest, except no Special Chest** — at **3× the reward point cost** (lvl 1–3 = 3, lvl 4 = 6, lvl 5 = 9).

---

# PART 6 — CROSS-REFERENCES

- **Weaponry** (Catapult, Trebuchet — `SoldierAttribute.md`): cannot be healed, immune to knock-back (equipment text). Catapult: Counter Building (+2 ATK vs buildings). Trebuchet: Penetration (+1% target Max HP DMG, rising to 3.5% at Smithy Lv.14) — a direct Smithy-progression link.
- **Shield Stance** (Heavy Shield Soldier): while active the unit cannot act or gain Rage; Improved Crossbowman's exclusive equipment (Anchor) cannot knock back Shield Stance units; Buffalo's Wild Collision **breaks** it.
- **Rage economy** on enemies mirrors soldiers (initial/needed, reset on cast) — the same engine drives both sides.
- Event system observed in captures: "Fortune's Favorite" and "Heaven Bestows Great Blessings" grant hero fragments (Xu Huang, Xia Houyuan, Zhu Yuanzhang, Fan Kuai, Meng Huo, Zhou Tong) at the **General Muster Terrace**.
- HUD resource counters observed across captures: crops ≈ 2955→2962 (+66/step), 142, 5700 (+165/+177), 153 — consistent with hourly production ticks.

---

## Open questions / to verify in-game

1. ~~Skill panels missing~~ — **RESOLVED (user-confirmed):** Minion and Bandit Saberman have **no skills**; Bandit Bowman's skill is user-documented (10% current HP additional DMG, Bowman-type countering Spearman).
2. ~~Placement of guardian beasts~~ — **RESOLVED (user-confirmed):** plot level 3, ≥12 tiles from the capital — Goat on Stone plots, Rat on Crop plots, Ape on Wood plots.
3. ~~Difficulty sub-level counts~~ — **RESOLVED (user-confirmed):** Easy 1–3, Entry 1–3, Common 1–4, Advanced 1–4, Hard 1–4, Hell 1–2; per-level ranges in §2.1.
4. ~~"Team 15"~~ — **RESOLVED (user-confirmed):** teams are capped at **12 (Capital level 20)**; soldiers can be moved between teams and reordered within a team (e.g., slot 1 → slot 4). The "Team 15" OCR reading conflicts with the 12-team cap — most likely an OCR artifact of the example panel.
5. ~~Reward Points~~ — **RESOLVED (user-confirmed):** cap 100, +50/day; first-conquest chest costs 1/2/3 points by plot level; Grain Garrison at 3× (no Special Chest). Still unclear: the observed plot chip "10/10 · Hell 1 · +14/h · +10 Points" — what the "10/10" counts and what "+10 Points" pays out.

---

*Recap generated from OCR of 73 screenshots (8 Battle Guide + 65 Plot, incl. 46 re-cut detail crops) plus user-confirmed rules (2026-10-26). Raw text: `ocr_battleguide.txt`, `ocr_plot.txt`, `ocr_plot_crops.txt`. Soldier data: `SoldierAttribute.md` (authoritative). For the rebuild plan see `REBUILD_GUIDE.md` §17.*
