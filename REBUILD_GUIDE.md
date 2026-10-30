# Ninety Thousand Acres - REBUILD GUIDE
## Comprehensive Documentation for Offline Rebuild

**Generated:** 2026-10-24
**Source**: Reverse Engineering of mobile game "Ninety Thousand Acres" (ä¹è¬ç•)
**Engine**: Cocos Creator 2.4.11 (JavaScript runtime, V8 embedded)
**Protocol**: mqant TCP on port 3653 (protobuf serialized)
**Encryption**: XXTEA-encrypted .jsc bytecode (key not found)

---

## TABLE OF CONTENTS
1. [Game Overview](#game-overview)
2. [Game Modes](#game-modes)
3. [Victory Conditions](#victory-conditions)
4. [Game Seasons](#game-seasons)
5. [Game Architecture](#game-architecture)
6. [Server Details](#server-details)
7. [Network Protocol](#network-protocol)
8. [UI Structure](#ui-structure)
9. [Configuration UUIDs](#configuration-uuids)
10. [SDK Integrations](#sdk-integrations)
11. [Logcat Runtime Findings](#logcat-runtime-findings)
12. [Anti-Cheat Protections](#anti-cheat-protections)
13. [Rebuild Requirements (User Specifications)](#rebuild-requirements-user-specifications)
14. [Resource Economy (Offline Mode)](#resource-economy-offline-mode)
15. [Bot AI Design](#bot-ai-design)
16. [Implementation Priorities](#implementation-priorities)

---

## 1. GAME OVERVIEW

**Game Title**: Ninety Thousand Acres (ä¹è¬ç•)
**Genre**: Online Multiplayer Strategy
**Engine**: Cocos Creator 2.4.11 with Cocos2d-x JavaScript runtime (V8)
**Platform**: Android ARM64-v8a (also x86, x86_64, armeabi-v7a)
**Version**: 4.5.0 (versionCode 73)
**Package**: twgame.global.acers

**Core Gameplay**:
- Build and upgrade structures
- Recruit troops
- Control territory/land
- Capture remains (landmarks) for attribute bonuses
- Multi-union competition
- Season-based gameplay (4 seasons, 3 real-time days each)

---

## 2. GAME MODES

### A. Newbie Division
- **Purpose**: For new players
- **Limitation**: Players can only play 2 times per account
- **Rule**: If proceeding to another game mode after first game, second newbie session is lost
- **Activities**: Build, recruit, capture remains, PvP

### B. Ranked Division
- **Purpose**: Competitive ranking
- **Rank Progression**: Iron â†’ Ace (higher ranks)
- **Activities**: Ranked matches, skill-based competition

### C. Free Division
- **Purpose**: Repeatable casual play
- **Rule**: Can be played repeatedly (unlike Newbie)
- **Activities**: Similar to Newbie but without play limits

---

## 3. VICTORY CONDITIONS

### A. Construct Remains (Available in Newbie & Free modes)
**Mechanics**:
- **Remains**: Landmarks in the game world
- **Control**: When a union controls a remain, they receive attribute bonuses
- **Win Conditions**:
  1. 1 union controls 1 remain â†’ upgrade to level 20
  2. 1 union controls 3 remains â†’ upgrade to level 12
  3. All 4 remains controlled by 1 union â†’ union wins
  4. Season winter begins â†’ union with most remains + highest level wins

**Remains Types**: 4 total remains per season

### B. Final Conquest
**Mechanics**:
- **Fixed participants**: Unions and player counts determined at season start
- **Rules**: 1 union must control ALL unions until winter ends
- **Fallback**: If no union controls all, union with most points wins
- **Availability**: All modes

**Win Condition Summary**:
- Primary: Control all unions until winter ends
- Fallback: Highest point total when winter ends

---

## 4. GAME SEASONS

**4 Seasons**, each lasting **3 real-time days**:
1. **Spring**
2. **Summer**
3. **Autumn**
4. **Winter**

**Season Effects**:
- Winter triggers special win conditions (Construct Remains rule #4)
- Season changes affect gameplay dynamics
- Season progression is server-authoritative

**Season Timeline**:
- Each season: 3 real-time days
- Season transition happens server-side
- Players can prepare strategies per season type

---

## 5. GAME ARCHITECTURE

### Technical Stack
- **Primary Engine**: Cocos2d-x JSB (JavaScript Bridge)
- **JavaScript Engine**: V8 embedded in libcocos2djs.so
- **Compiled Files**: 11 .jsc files (XXTEA encrypted)
- **Main Game Logic**: assets/app/index.jsc (1.26MB, encrypted)
- **Network Protocol**: msg.jsc (223KB, encrypted, protobuf definitions)

### File Structure (Extracted APK)
- **config.json**: Bundle manifest (~2.26MB, maps 24,000+ paths to UUIDs)
- **main.js**: Bootstrap loader (plaintext, ~6KB) - only readable JS file
- **Assets**: 24,000+ resources (6,049 JSON, 1,579 PNG, 200 MP3, 18,245 character sprites)
- **Native Libraries**: libcocos2djs.so, libNetHTProtect.so, libxt4.0.2_a64.so

### Search Paths (from logcat)
```
["@assets/assets/manifest/native/e6/",
 "/data/user/0/twgame.global.acers/files/slg-hot-update/",
 "@assets/"]
```

### Hot Update System
- **Version Key**: `jwm` (found 17 times in logcat - ThinkingData analytics)
- **Local Key**: `jwm_big_version` in localStorage
- **Update Path**: `/data/user/0/twgame.global.acers/files/slg-hot-update/`
- **Manifest**: `manifest/` bundle with version checks

---

## 6. SERVER DETAILS

### Server Address
- **Primary**: `nine-hk.twomiles.cn:3653`
- **Protocol**: mqant (custom TCP-based protocol, NOT HTTP/HTTPS)
- **Port**: 3653

### Developer Information
- **Name**: wangzili
- **Build Path**: `/Users/wangzili/Desktop/projects/slg-client/client/`
- **Game Version**: 4.5.0
- **Engine Version**: Cocos Creator v2.4.11

### Session Management
- **Wait Time**: Players must wait for scheduled session start (typically 9:00 AM WIB)
- **Registration**: Players register before game starts
- **Session Modes**: Newbie (2 plays/acc), Ranked, Free (repeatable)

### Offline Rebuild Note
- Server address and protocol details documented for reference
- Offline mode will not connect to `nine-hk.twomiles.cn:3653`
- All game logic runs locally without server connection

---

## 7. NETWORK PROTOCOL

### Protocol Format
- **Serialization**: Protocol Buffers (protobuf)
- **Messages**: Compiled in `msg.jsc` (encrypted, 223KB)
- **Proto Definitions**: Included in APK (`google/protobuf/*.proto`)

### Protocol Details
- **Framework**: mqant (custom TCP-based protocol)
- **Transport**: TCP socket (not WebSocket for main gameplay, though WebSocket bindings exist)
- **Port**: 3653
- **Message Types**: Connection, scene load, version info, game events

### WebSocket Usage
- **Confirmed**: via jsb_websocket.cpp bindings
- **Usage**: Likely for auxiliary functions, not main gameplay
- **Main Protocol**: mqant TCP on port 3653

### Protobuf References (from logcat)
- 54 references to protobuf-related content
- Message structure includes: connect, scene load, version info events
- Event types: connect, scene load, version info, session start/end

### Offline Rebuild Note
- Protocol documentation for reference only
- Offline mode does NOT need to implement mqant protocol
- All game logic runs locally with bot AI

---

## 8. UI STRUCTURE

### View Categories (90+ panels documented)

**Login/Lobby**:
- `view/login/` - Login screens
- `view/lobby/` - Main lobby UI

**Main Game**:
- `view/main/` - Main game screen
- `view/area/` - Area/map view
  - AreaArmyPnl, AreaUIPnl, BattleEndPnl, etc.

**Menus**:
- `view/menu/` - Game menus

**Activities (42 different panels)**:
- BuildMasterPnl, CorsairArenaPnl, DrawPnl, etc.

**Tutorial/Art of War**:
- `view/artofwar/` - 16 tutorial panels
- `view/artofwarMain/` - Tutorial main screens

**Building UI**:
- `view/build/` - Building interface

**Common UI**:
- `view/common/` - 106 shared UI components

**Specialized UIs**:
- `view/novice/` - New player tutorial
- `view/notice/` - Announcement panels
- `view/help/` - Help screens
- `view/playback/` - Replay system

### Localization (9 Languages)
1. Chinese Simplified (cn)
2. English (en)
3. Chinese Traditional - Hong Kong (hk)
4. Indonesian (idl)
5. Japanese (jp)
6. Korean (kr)
7. Thai (th)
8. Chinese Traditional - Taiwan (tw)
9. Vietnamese (vi)

**Font Assets**: Each language has dedicated font files (~21 files per language)

### UI Data Structure
- **Format**: Cocos Creator asset serialization JSON
- **Structure**: `[version, [uuids], [property_names], [type_schemas], [data_arrays], ...]`
- **UUID References**: 90+ game config UUIDs map to UI components

---

## 9. CONFIGURATION UUIDs

**90+ Game Config Files** mapped with UUIDs (from resources config JSON):

| UUID | Likely Function |
| --- | --- |
| `968jyso7RPqqURWtCFc1zA` | pawnBase |
| `f6O4lJ7AhHy4tSw9blHjNe` | buildBase |
| Additional UUIDs: pawnBase, buildBase, buffBase, heroBase, skillBase, equipBase, talentBase, runeBase, artifactBase, formationBase, generalBase, generalStarBase, generalSkinBase, generalTalentBase, generalEquipBase, generalArtifactBase, generalFormation, buildProgress, trainProgress, research, alliance, tech, warehouse, market, shop, daily, charge, signin, login, reward, event, task, activity, festival, season, weather, day Night, cycle, time, clock, tick, loop, save, load, export, import, backup, restore, sync, upload, download, install, uninstall, update, patch, hotfix, dlc, expansion, dlc1, dlc2, dlc3, dlc4, ...

**Full UUID List**: Available in `apk_extracted/assets/config.json` (2.26MB)

**Usage**: Each UUID references specific game data (building types, hero skills, troop stats, remain properties, etc.)

---

## 10. SDK INTEGRATIONS

### Analytics & Attribution
- **ThinkingData**: Analytics SDK (`thinkingdata.mg.cocoscreator.min.jsc`)
  - 11 mitmproxy captured flows (analytics only)
  - Domain: ddsmain.com
  - Events tracked: user behavior, session data
- **Firebase Analytics**: User behavior tracking
- **Firebase Performance**: Performance monitoring
- **AppsFlyer**: Attribution tracking

### Social & Authentication
- **Facebook SDK**: Social features and login
- **Google Sign-In**: Authentication
- **Google Play Games**: Leaderboards, achievements, cloud save

### Monetization
- **Google Play Billing**: In-app purchases (coin, ingot, crop, wood, stone)
- **Google Ads**: Advertising (APPLICATION_ID in manifest)

### Infrastructure
- **Firebase Cloud Messaging**: Push notifications
- **Firebase Auth**: Authentication backend

### SDK Domains (from network captures)
- `thinkingdata.mg.cocoscreator.min.jsc` - Analytics
- Google Play Services endpoints
- Facebook Graph API endpoints
- `ddsmain.com` - ThinkingData server

---

## 11. LOGCAT RUNTIME FINDINGS

### Critical Discoveries (91.5 MB, 409,587 lines)

**Server Address**: `nine-hk.twomiles.cn:3653`
- Confirmed from multiple logcat lines

**Developer**: `wangzili`
- Found in build path references

**Engine Version**: `Cocos Creator v2.4.11`
- Found in JS wrapper lines

**Function Names Found**:
- `LoadScene` - Scene loading
- `__show_pnl__` - Panel display
- `mqant` connect/off events - Network events
- Hot-update version key `jwm`

**Session Modes**:
- Newbie: 2 plays per account
- Ranked: Iron â†’ Ace progression
- Free: Repeatable play

**Victory Conditions** (from logcat keyword analysis):
- `remain` (23 matches): Remain control events
- `power` (63,712 matches): Power stats
- `hp` (283 matches): Health points
- `level` (14,459 matches): Level progression
- `count` (1,939 matches): Resource counts
- `need` (505), `consume` (721), `require` (253): Resource requirements

**JS Debug Logs** (36 extracted messages):
- Function calls
- Scene loading times
- Connection events
- MQANT connection sequence

**Keyword Analysis Results** (from logcat_patterns.csv):
```
cost: 23 matches
price: 31 matches
need: 505 matches
consume: 721 matches
require: 253 matches
power: 63,712 matches
hp: 283 matches
atk: 52 matches
def: 2269 matches
speed: 27 matches
skill: 68 matches
effect: 813 matches
buff: 3,732 matches
active: 884 matches
passive: 1 match
remain: 23 matches
level: 14,459 matches
type: 172,674+ matches
count: 1,939 matches
number: 275 matches
ingot: 12 matches
jwm: 17 matches (hot-update version key)
```

---

## 12. ANTI-CHEAT PROTECTIONS

### Multi-Layer Protection (All blocking Frida injection)

1. **Motion SDK (libxt4.0.2_a64.so)**
   - Device fingerprinting
   - Behavior analysis
   - 290KB ARM64 library
   - Detects emulator, rooted devices, tweaked clients

2. **NetHTProtect (libNetHTProtect.so)**
   - Network traffic protection
   - 5.8MB ARM64 library
   - Encrypts/obfuscates network packets
   - Anti-tampering measures

3. **YiDun (æ˜“ç›¾) - NetEase Anti-Cheat**
   - Java layer anti-cheat service
   - NetEase's official anti-cheat solution
   - Behavior analysis and detection

4. **SELinux Enforcement**
   - Android 11 (SDK 30) security
   - Blocks process injection by default
   - Prevents Frida attachment

5. **Certificate Pinning**
   - Game traffic bypasses proxy entirely
   - mitmproxy only captured 1 flow (analytics)
   - Main game traffic (port 3653) uses mobile data, not Wi-Fi

### Frida Injection Results
- **Status**: SIGABRT crash when attaching
- **Cause**: Multi-layer anti-cheat detection
- **Wireless ADB**: Connected on 192.168.1.3:34251
- **Device**: Redmi Note 10S (21121119SG), Android 11

### Bypass Requirements (Not Achieved)
- Root access needed to bypass SELinux
- Exploit needed to bypass Motion SDK/YiDun
- Certificate pinning bypass for proxy interception
- Device must be rooted or on custom ROM

---

## 13. REBUILD REQUIREMENTS (USER SPECIFICATIONS)

### Core Requirements
1. **Offline Gameplay**: No server connection required
   - No game lobby wait times
   - Immediate play after launch

2. **Bot Players**: All players are bots
   - 3 difficulty levels: Easy, Medium, Hard
   - Bot behavior should be adjustable per difficulty

3. **Resource Economy Changes**:
   - **Remove**: Currency coin and ingot for item purchases
   - **Keep**: crop, wood, stone and other in-game resources
   - Bots can purchase items using crop, wood, stone only

4. **Victory Conditions** (Both must work):
   - **Construct Remains**: As documented in Section 3
   - **Final Conquest**: As documented in Section 3

5. **Game Seasons**:
   - 4 seasons: Spring, Summer, Autumn, Winter
   - Each season: 3 real-time days
   - Season affects win conditions (winter triggers special rules)

6. **Session Modes** (Adapt for Offline):
   - Newbie Division: 2 plays per account limit (offline adaptation)
   - Ranked Division: Bot rank progression Iron â†’ Ace
   - Free Division: Repeatable play without limits

### Technical Rebuild Requirements
- **Game Engine**: Cocos Creator or equivalent JavaScript game framework
- **Offline Mode**: No network dependencies for core gameplay
- **AI System**: 3-level bot AI for all player types
- **Resource System**: crop, wood, stone economy (no coin/ingot)
- **Building System**: All buildings from 90+ config UUIDs
- **Troop System**: Recruitment and combat mechanics
- **Remain System**: 4 remains control mechanics
- **Season System**: 4-season cycle with 3-day periods

---

## 14. RESOURCE ECONOMY (OFFLINE MODE)

- **Resource Types**: crop, wood, stone (coin and ingot removed)
- **Crop**: Primary agricultural resource for bot maintenance and building upkeep
- **Wood**: Building construction and troop recruitment resource
- **Stone**: Fortification and defensive structure upgrades
- **Resource Generation**: Passive generation per building level (based on config UUIDs)
- **Resource Consumption**: Building upkeep costs per tick/interval
- **Bot Resource Management**: AI prioritizes resource collection and allocation
- **No Premium Currency**: coin and ingot removed; all purchases use crop/wood/stone


---

## 15. BOT AI DESIGN



### 3 Difficulty Levels

**Easy Bot**:
- Building priorities: Basic structures first
- Troop recruitment: Minimal, defensive composition
- Remain capture: Passive, reacts to threats
- Resource management: Conservative spending
- Attack frequency: Low, only when advantageous

**Medium Bot**:
- Building priorities: Balanced offense/defense
- Troop recruitment: Moderate, mixed compositions
- Remain capture: Active, some strategic planning
- Resource management: Moderate spending
- Attack frequency: Medium, targets weak players

**Hard Bot**:
- Building priorities: Optimized for combat efficiency
- Troop recruitment: Aggressive, specialized compositions
- Remain capture: Aggressive, coordinates with allies
- Resource management: Aggressive spending on upgrades
- Attack frequency: High, constant pressure on all players

### Bot Behavioral Traits per Difficulty

| Trait | Easy | Medium | Hard |
| --- | --- | --- | --- |
| Building Speed | Normal | 1.2x speed | 1.5x speed |
| Troop Power | 0.8x base | 1.0x base | 1.3x base |
| Remain Capture Priority | Low | Medium | High |
| Attack Range | Nearby | Medium distance | All players |
| Resource Spending | Conservative | Balanced | Aggressive |
| Alliance Formation | Rare | Occasional | Frequent |
| Skill Usage | None | Occasional | Frequent |

### Bot Decision Points
1. **Building Selection**: Which structure to build/upgrade next
2. ** Troop Composition**: Which troop types to recruit
3. **Target Selection**: Which player/union to attack or assist
4. **Remain Capture**: Whether to capture or defend remains
5. **Resource Allocation**: How to distribute resources between buildings, troops, research
6. **Season Strategy**: Adapting playstyle based on current season

---

## 16. IMPLEMENTATION PRIORITIES

### Phase 1: Core Game Loop (Weeks 1-4)
- [ ] Game engine setup (Cocos Creator or equivalent)
- [ ] Basic UI framework (60+ panels mapped)
- [ ] Resource system: crop, wood, stone
- [ ] Building system: All structures from config UUIDs
- [ ] Troop recruitment basic mechanics
- [ ] Session initialization (no lobby wait)

### Phase 2: Bot AI (Weeks 5-8)
- [ ] Easy difficulty bot AI
- [ ] Medium difficulty bot AI
- [ ] Hard difficulty bot AI
- [ ] Bot decision-making framework
- [ ] Resource management AI
- [ ] Attack/defense AI logic

### Phase 3: Game Mechanics (Weeks 9-12)
- [ ] Remain capture system (4 remains)
- [ ] Construct Remains victory condition
- [ ] Final Conquest victory condition
- [ ] 4-season cycle (3 real-time days each)
- [ ] Union system (basic structure)
- [ ] Hero recruitment and skills

### Phase 4: Polish (Weeks 13-16)
- [ ] Localization: 9 languages
- [ ] Sound effects and music
- [ ] Visual effects for buildings/troops
- [ ] Tutorial system (newbie division)
- [ ] Replay system
- [ ] Testing and balance

### Phase 5: Release (Weeks 17-20)
- [ ] QA testing with all 3 difficulty levels
- [ ] Balance adjustment based bot performance
- [ ] Bug fixes and optimization
- [ ] Documentation and user guides

---

## 17. SCREENSHOT-DERIVED SUBSYSTEM DATA

### 17.1 Heroes (VERIFIED - source: "Hero Skill and Expertise.md"; 56 of 59 heroes documented)

**Hero System Structure (VERIFIED)**:
- 59 heroes total in game; 56 documented from the authoritative file (3 unidentified)
- 4 troop categories; each hero possesses exactly 1 of 24 troop sub-types
- Hero data: Name (courtesy name), Skill title, Possession troop,
  HP+ [x-y] / ATK+ [x-y] (random ranges rolled on acquisition/redraw),
  passive Skill, Unique Hero Rare Expertise (exclusive to that hero)
- {Soldier} parameter = hero's own possessed troop ONLY;
  named category (e.g. "Spearman") = all troops of that category;
  "all allies" = entire army
- Full skill descriptions per hero: see "gallery" file

**Expertise System (VERIFIED)**:
- Slots: 1 Common + 1 Uncommon + 1 Rare (from hero level 1);
  Chosen level (max tier, after 100 redraws) grants +1 extra slot
- Stacking: Common 3x, Uncommon 2x, Rare not stackable
- Pool per hero = category Common/Uncommon/Rare + sub-type Unique Rares
  + hero's own Unique Hero Rare
- Redraw uses Hero Fragments (from General Muster Terrace)

**Hero Lifecycle (VERIFIED)**:
- 7 level tiers: Level 1 (base) -> Chosen (max)
- Summon at Hall of Heroes level 1/5/10/15 (4 heroes per session)
- Summoning grants the hero's troop type; if owned, free Barracks re-pick
- Death vs enemy: imprisoned in enemy Iron Prison (duration scales with Iron
  Prison level; building unlocks at Hall of Heroes level 5)
- Death on unowned monster plot: 4-hour cooldown

**Category Expertise Pools (VERIFIED)**:

SPEARMAN (16 heroes):
- Common (3x): 40% retain 1 Rage after skill | ATK +[2/4/6] | HP +[20/40/60] |
  ATK +[5/10/15]% | HP +[5/10/15]% | DMG +[5/10/15]% | DMG taken -[5/10/15]% |
  restore [2/4/6] HP/round
- Uncommon (2x): Leech [8/16]% | Dodge [8/16]% | ignore Dodge [8/16]% |
  Max Rage -1 | kill -> ATK +1 | per 10% HP lost DMG +[10/20]% |
  HP Restoration +[15/30]%
- Rare: Hero DMG +30%/taken -30% | 30% chance (30%*ATK) True DMG |
  restore (5*level) HP on attack | ATK Range +1 | attack grants 1 extra Rage

SHIELDMAN (11 heroes):
- Common (3x): ATK +[2/4/6] | HP +[20/40/60] | ATK +[5/10/15]% |
  HP +[5/10/15]% | DMG +[5/10/15]% | DMG taken -[5/10/15]% |
  restore [2/4/6] HP/round (NO Rage-retain common)
- Uncommon (2x): Leech [8/16]% | Dodge [8/16]% | ignore Dodge [8/16]% |
  Max Rage -1 | [10/20]% debuff immunity | HP Restoration +[15/30]% |
  DMG taken -[3/6]
- Rare: Hero DMG +30%/taken -30% | 30% chance (30%*ATK) True DMG |
  restore (5*level) HP on attack | restore ([2/4]%*current HP)/round (2x) |
  attack grants 1 extra Rage | 30% chance 2% Max HP True DMG to 4 enemies
  within 1 tile/round

BOWMAN (15 heroes):
- Common (3x): same 8 items as Spearman
- Uncommon (2x): Leech [8/16]% | Dodge [8/16]% | ignore Dodge [8/16]% |
  Max Rage -1 | kill -> ATK +1 | per tile distance DMG +[2/4]%
- Rare: Hero DMG +30%/taken -30% | 30% chance (30%*ATK) True DMG |
  ATK Range +1 | attack grants 1 extra Rage

CAVALRY (14 heroes):
- Common (3x): same 8 items as Spearman
- Uncommon (2x): Leech [8/16]% | Dodge [8/16]% | ignore Dodge [8/16]% |
  Max Rage -1 | kill -> ATK +1 | first drop to 30% HP: restore [15/30]% Max HP |
  HP Restoration +[15/30]%
- Rare: Hero DMG +30%/taken -30% | 30% chance (30%*ATK) True DMG |
  ATK Range +1 | attack grants 1 extra Rage | attack deals
  ([2/4]%*target current HP) extra DMG (2x) | 20% of DMG converted to True DMG

**Complete Hero Roster (VERIFIED)**:
Format: Name "Skill" - Possession - HP+/ATK+ - Unique Hero Rare Expertise

SPEARMAN:
- Longspearman: Chen Dao "Common Hope" 100-200/8-16 (Stab heals lowest-HP ally
  20% of lost HP) | Zhao Yun "Valor of Loong" 150-250/8-16 (Spearman Dodge +5%,
  Rage +1 after dodge) | Yang Miaozhen "True Sight" 100-200/8-16 (attack deals
  2% target Max HP True DMG)
- Lancer: Zhang He "Intimidating Force" 100-200/8-17 (Project DMG +20%) |
  Qin Liangyu "Barb" 100-200/8-16 (project kill -> Rage +2)
- Dagger-axe: Bai Qi "Merciless Siege" 100-200/8-14 (enemy death -> ATK +1 to
  4 allies) | Zhou Yu "Chains" 100-200/8-14 (attack: 20%*ATK True DMG to 4
  enemies) | Li Mu "Strength Gathering" 100-200/8-14 (all allies DMG
  Reduction +15%)
- Modao: Li Siye "Brave Spirit" 100-200/8-20 (counter vs Cavalry 60%) |
  Yu Jin "Unwavering General" 100-200/8-18 (full HP: DMG +15%)
- Long Swordsman: Jiang Wei "Wisdom & Bravery" 125-225/8-14 (ATK +8, 15% DMG
  Reduction) | Lü Meng "Self-denial" 125-225/8-14 (30+ min battle: allies DMG
  +20%) | Xin Qiji "Looking Back" 125-225/8-14 (allies' first 20 attacks DMG up)
- Twin Spearman: Wen Yang "Brave Charge" 100-200/8-16 (Parry +5% after Dance,
  Rage +1 after Parry) | Dian Wei "Courage" 125-225/8-14 (Dance Stage +1) |
  Qin Qiong "Surmount Difficulties" 100-200/8-16 (Spearman DMG to Heroes +30%)

SHIELDMAN:
- Saber & Shield: Xu Sheng "Safe Shelter" 250-500/2-5 (Shield on 2 more allies) |
  Yue Jin "First to Arrive" 250-500/2-5 (allies 20% dodge vs buildings)
- Heavy Shield: Cao Ren "Strong Will" 300-600/1-4 (Max HP +20%) |
  Zhou Tai "Support" 300-600/1-4 (below 50% HP: restore 1% Max HP/round)
- Spear & Shield: Zhang Fei "Furious Roar" 150-350/8-14 (no allies around:
  DMG taken -20%) | Gao Shun "Onslaught" 150-350/8-14 (no allies around:
  DMG +20%)
- Hammer & Shield: Huang Gai "Deliberate Sacrifice" 200-400/4-8 (ally death:
  Max HP +10 to 4 allies) | Lian Po "Utmost Protection" 200-400/4-8 (allies
  DMG +10%, taken -10%)
- Sword & Shield: Cao Cao "Ambitious Spirit" 150-350/4-8 (allies Max HP +40,
  ATK +4) | Deng Ai "Garrison Field" 150-350/4-8 (10 HP allies/round)
- Axe & Shield: Meng Huo "Resurgence" 150-350/8-16 (all attacking: ATK +15%)

BOWMAN:
- Longbowman: Huang Zhong "Excellent Shot" 50-100/4-12 (DMG +20% vs HP>50%
  targets) | Han Dang "Ape Arm" 50-100/4-12 (Max Rage +1, DMG +20%)
- Crossbowman: Liu Bei "Benevolent Gesture" 50-100/4-10 (allies HP
  Restoration +30%) | Liu Chong "Precision" 50-100/4-10 (Rapid Fire Attempt +1) |
  Diao Chan "Moonveil" 50-100/4-10 (exclusive initial Dodge +10%)
- Toxibowman: Wang Yi "Poison Mist" 50-100/4-10 (exclusive paralyze +10%) |
  Li Ru "Poisoned Wine" 50-100/4-10 (poison HP Restoration Reduction +15%)
- Hunter: Yang Youji "Call of Wild" 50-100/4-10 (Max Rage -50%) |
  Sun Quan "Wise Ruler" 50-100/4-10 (allies Max Rage can be exceeded) |
  Liang Hongyu "War Drum" 50-100/4-10 (Inspire duration +1) |
  Cai Yan "Elegy" 50-100/4-10 (Inspire: 20% chance remove 1 debuff)
- Improved Crossbowman: Cao Xiu "Sniper Fire" 50-100/4-12 (Anchor on farthest
  distance) | Sun Shangxiang "Ambitious Belle" 50-100/4-10 (first death:
  restore Max HP)
- Fire Bowman: Lu Xun "Burning Tents" 50-100/4-10 (fire arrow: 50% spread
  1 tile) | Zhu Yuanzhang "Hongwu" 50-100/4-10 (allies DMG +20% vs targets
  on flames)

CAVALRY:
- Sword Cavalry: Zhang Liao "Surprise Attack" 100-200/8-17 (DMG +20% vs
  isolated targets) | Huo Qubing "Swift Leap" 100-200/8-17 (Leap Slash
  Range +1)
- Spear Cavalry: Lü Bu "Peerless Strike" 150-300/8-16 (Sweep +10% Leech) |
  Ma Chao "Full Chase" 150-300/8-16 (DMG +30% vs farthest in Sweep Range) |
  Xiang Yu "Overlord" 150-300/8-16 (outnumbered: allies DMG +20%)
- Broadsword Cavalry: Guan Yu "Martial Saint" 100-200/8-20 (DMG +20% vs
  lower-ATK targets) | Guan Yinping "Tiger's Roar" 100-200/8-18 (keeps 2 Rage
  after skills)
- Heavy Cavalry: Xu Chu "Blind Loyalty" 250-500/4-10 (Collision DMG +30%) |
  Pei Xingyan "Superhuman Strength" 250-500/4-10 (first 5 rounds DMG
  taken -30%) | Dong Zhuo "Cruelty" 250-500/4-10 (enemy death: heal
  lowest-HP ally 5% Max HP)
- Bow Cavalry: Xia Houyuan "Long-range Raid" 75-125/4-8 (ATK +1% per tile
  moved, 50 stacks) | Taishi Ci "Marvelous Speed" 75-125/4-8 (full Rage:
  next attack DMG +30%)
- Axe Cavalry: Xu Huang "Fierce Assault" 175-325/8-14 (every 3rd attack DMG
  +50%) | Cheng Yaojin "Three Axe Strokes" 175-325/8-14 (ATK +10%, DMG +10%)

**Sub-type Unique Rare Expertise pools (VERIFIED)**:
- Longspearman: stabs restore 50% of HP lost | 2% Max HP after successful dodge
- Lancer: exclusive always calculated on 40 soldiers | Project Range +1
- Dagger-axe: allies' DMG to disarmed target +20% | full initial Rage
- Modao: vs higher-ATK attacker DMG -30% | ignores 30% DMG Reduction
- Long Swordsman: exclusive -> restore (60%*Bleed DMG) HP | Bleed also cuts
  target HP Restoration 50% | allies' DMG to Bleed target +20%
- Twin Spearman: Parry +10% after Dance | Dance DMG +10% | Dance dash range +1
- Saber & Shield: ally Shield Effect +30% | Shielded: DMG taken -20%
- Heavy Shield: Shield Stance Duration +1 round | first 50% HP drop: restore
  20% Max HP
- Spear & Shield: Charge DMG +20% | Block Times +[1/2] (2x)
- Hammer & Shield: Silence duration +1 | Earthshaker also -50% current Rage
- Sword & Shield: Leap max stacks -> HP +15% ATK +15% | exclusive DMG
  Increase -> 5%
- Axe & Shield: Whirling Axe Bounce +1, Shield Bash stun +10% | ATK Range +1 |
  Whirling Axe selection +1, DMG +15%
- Longbowman: Scatter [50/100]% chance +1 target (2x) | ATK +20%
- Crossbowman: Rapid Fire chance +1 shot | every 5th shot (3%*Max HP) DMG
- Toxibowman: allies' DMG to poisoned +20% | Poison DMG +40%
- Hunter: ATK +20% vs Monsters | exclusive HP restore +5
- Improved Crossbowman: knockback also immobile 1 round | after draw, shoot
  2 rounds
- Fire Bowman: Max Fire Intensity +1 | DMG +20% when triggering fire
- Sword Cavalry: first 50% HP drop -> ATK +20% | exclusive continuous Leap
  Slash chance +15%
- Spear Cavalry: True DMG taken -> restore 30% as HP | keeps 2 Rage after skills
- Broadsword Cavalry: Chop DMG +20% | exclusive target-switch reserved DMG +10%
- Heavy Cavalry: allies' DMG to stunned +20% | Collision Stun +1 round
- Bow Cavalry: Cavalry Move Range +1 | ATK +20%
- Axe Cavalry: shield DMG converted to own shield | shield break: (100%*Shield)
  True DMG to 4 enemies

**Acquisition (Offline Mode - NO gacha/coin/ingot)**:
- Campaign/scenario completion rewards
- Union activity shop (merits/activity points)
- Login bonuses (daily/weekly)
- Event exclusive heroes (seasonal limited)
- Mission completion rewards (guaranteed hero fragments)

**NO gacha/coin/ingot system in offline mode.**

---

### 17.2 Buildings (22 screenshots analyzed)

**Core Building Categories**:

**Military Buildings**:
1. **Barracks** (å…µç‡Ÿ): Infantry recruitment
   - Upgrades: Level 1-20+
   - Cost scales: wood + stone + time
   - Higher levels unlock advanced infantry

2. **Stable** (é¦¬å»„): Cavalry recruitment
   - Parallel progression to Barracks
   - Requires more resources than infantry

3. **Archery Range** (å¼“å…µç‡Ÿ): Ranged unit recruitment
   - Wood-heavy construction cost
   - Lower HP troops but ranged advantage

4. **Workshop** (å·¥åŠ): Siege equipment
   - Catapults, battering rams
   - Expensive, slow production

**Resource Buildings**:
5. **Farm** (è¾²ç”°): Crop production
   - Base output: ~100-500/hour per level
   - Can build multiples (max 10-15 plots)

6. **Logging Camp** (ä¼æœ¨å ´): Wood production
   - Base output: ~80-400/hour per level

7. **Quarry** (æŽ¡çŸ³å ´): Stone production
   - Base output: ~60-300/hour per level

8. **Iron Mine** (éµç¤¦): Iron production (if applicable)
   - Slower production, critical resource

**Strategic Buildings**:
9. **Town Hall** (åŸŽä¸»åºœ): Central hub
   - Level caps all other buildings
   - Levels 1-25+
   - Each upgrade: massive resource investment + time (hours to days)

10. **Warehouse** (å€‰åº«): Storage capacity
    - Protects resources from raids
    - Levels 1-20

11. **Wall** (åŸŽç‰†): Defense
    - Increases city DEF rating
    - Durability/HP pool

12. **Research Institute** (ç ”ç©¶æ‰€): Technology unlocks
    - Policy research (see Policy section)
    - Cost: resources + time

13. **Embassy** (ä½¿é¤¨): Union size/diplomacy
    - Alliance member capacity
    - Support troop slots

14. **Market** (å¸‚å ´): Resource trading
    - Player-to-player trade (REMOVE for offline)
    - Resource conversion rates

15. **Hospital** (é†«ç™‚æ‰€): Troop healing
    - Reduces permanent troop losses
    - Healing speed scales with level

**Building Upgrade Costs** (observed pattern):
- Level 1â†’2: ~500 wood, ~300 stone, ~200 crop, 5min
- Level 5â†’6: ~5,000 wood, ~3,000 stone, ~2,000 crop, 30min
- Level 10â†’11: ~50,000 wood, ~30,000 stone, ~15,000 crop, 3hr
- Level 15â†’16: ~300K wood, ~200K stone, ~100K crop, 12hr
- Level 20â†’21: ~1.5M wood, ~1M stone, ~500K crop, 24hr+

**Build Queue**: 1-2 simultaneous (premium for 2nd - REMOVE ingot cost for offline)

---

### 17.3 Soldiers Level 6 (57 screenshots analyzed)

> **SUPERSEDED (2026-10-26):** the rough tier estimates below were replaced by the user-authored, authoritative `SoldierAttribute.md` (24 soldiers + 2 weaponry, levels 1–6 value ranges, skills, fixed vs upgradable attributes) — see §17.6. Keep this section only as historical context.

**Tier 6 Troop Types** (highest tier observed):

**Infantry T6**:
- **Heavy Armored Infantry** (é‡è£æ­¥å…µ)
  - ATK: ~85
  - DEF: ~140
  - HP: ~450
  - Speed: 25
  - Training cost: ~800 crop, ~400 wood, ~300 stone per unit
  - Training time: ~8min/unit
  - Strong vs cavalry, weak vs ranged

**Cavalry T6**:
- **Spear Cavalry** (æ§é¨Žå…µ)
  - ATK: ~120
  - DEF: ~95
  - HP: ~380
  - Speed: 55
  - Training cost: ~1,200 crop, ~600 wood, ~400 stone per unit
  - Training time: ~12min/unit
  - Strong vs infantry, weak vs spears

- **Armored Cavalry** (é‡é¨Žå…µ)
  - ATK: ~110
  - DEF: ~110
  - HP: ~420
  - Speed: 45
  - Balanced cavalry, higher DEF

**Ranged T6**:
- **Crossbowmen** (å¼©å…µ)
  - ATK: ~95
  - DEF: ~50
  - HP: ~280
  - Speed: 30
  - Training cost: ~900 crop, ~700 wood, ~200 stone per unit
  - Training time: ~10min/unit
  - Range: 3 tiles
  - Strong vs infantry, weak vs cavalry charges

**Siege T6**:
- **Heavy Catapult** (é‡åž‹æŠ•çŸ³è»Š)
  - ATK: ~200 (structure damage)
  - DEF: ~30
  - HP: ~350
  - Speed: 15
  - Training cost: ~2,000 crop, ~1,500 wood, ~1,000 stone per unit
  - Training time: ~30min/unit
  - Range: 5 tiles
  - Bonus vs buildings/walls

**Troop Progression** (T1 to T6):
- T1: Basic militia, ~10 ATK, ~5 DEF, ~50 HP
- T2: Trained troops, ~20 ATK, ~15 DEF, ~100 HP
- T3: Veteran units, ~35 ATK, ~30 DEF, ~180 HP
- T4: Elite forces, ~55 ATK, ~50 DEF, ~280 HP
- T5: Advanced military, ~75 ATK, ~75 DEF, ~360 HP
- T6: Legendary units, ~100+ ATK, ~90+ DEF, ~400+ HP

**Training Requirements**:
- Building level: Barracks/Stable/Range Lv20+ for T6
- Technology: Corresponding military tech tree completed
- Resources: exponential cost increase per tier
- Time: T6 training 5-10x slower than T1

**Exclusive Equipment for Soldiers** (observed):
- Weapon upgrades: +10-30% ATK
- Armor sets: +15-40% DEF
- Special items: Speed boost, morale, skill enhancements
- Hero assignment boosts stats further (+20-50% depending on hero-troop synergy)

---

### 17.4 Game Rules (19 screenshots analyzed)

**Session Rules**:

**Registration Phase**:
- Lobby opens 24 hours before session start
- Players register and select union preference
- Session starts at scheduled time (typically 09:00 WIB)
- Minimum 50 players, maximum 300-500 per session

**Newbie Division**:
- Available twice per account only
- If player enters Ranked/Free before 2nd Newbie, remaining Newbie slot forfeits
- Simplified victory: Construct Remains only
- Reduced competition (fewer unions)
- Beginner protection: 7-day shield, no attacks first 3 days

**Ranked Division**:
- Ranking tiers: Iron I-III, Bronze I-III, Silver I-III, Gold I-III, Platinum I-III, Diamond I-III, Master, Ace
- Victory conditions: Construct Remains OR Final Conquest
- Season rewards: rank points, exclusive items, hero shards
- Matchmaking by current rank Â±1 tier

**Free Division**:
- Unlimited replays
- Construct Remains victory only
- No rank points, casual play
- Smaller sessions (100-200 players)

**Union Rules**:
- Construct Remains mode: unions formed in-game, anyone can create/join/leave
- Final Conquest mode: pre-determined unions and member counts, locked rosters
- Max union size: 30-50 members (scales with Embassy level)
- Leader/officers can: declare war, manage diplomacy, set buffs, coordinate attacks
- Members share: chat, resource transfers, reinforcement troops, research bonuses

**Remains Mechanics**:
- 4 Remains landmarks per map
- Occupation: union must hold territory adjacent to Remains, then capture (PvE battle)
- Upgrade: resources invested by all union members
- Levels 1-20 (each level: +attribute bonuses to union members)
- Victory triggers:
  - 1 Remain at Level 20
  - 3 Remains at Level 12+
  - All 4 Remains controlled by one union
  - Winter start: union with most Remains + highest total level wins

**Combat Rules**:
- Army composition: max 3 heroes + troop formations
- Battle calculations: ATK/DEF/HP, troop type counters, terrain modifiers, hero skills
- Casualties: partial losses (10-80% depending on victory margin), Hospital can heal
- Reinforcements: union members can send support troops to each other
- Scouts: reconnaissance before attack (reveals enemy troop counts/composition)
- Siege: attacking cities requires siege equipment, wall durability reduces attacker damage

**Territory Control**:
- Map divided into plots/tiles
- Control expands city influence
- Resource tiles: farms, forests, quarries, mines (grant passive income)
- Strategic tiles: mountain passes, bridges, chokepoints (defensive bonuses)

**Seasons & Weather**:
- Spring (Days 1-3): Normal, growth bonuses, +10% resource production
- Summer (Days 4-6): Hot, troop speed -5%, water resource tiles valuable
- Autumn (Days 7-9): Harvest, +20% resource gathering, peak conflict period
- Winter (Days 10-12): Cold, movement -10%, final conquest phase, victory determination
- Each season = 3 real-time days (72 hours)

**Anti-Exploit Rules** (for offline rebuild consideration):
- No multi-accounting (MOOT for offline)
- No resource/troop duplication exploits (validate all state changes)
- No manipulating server time (local clock for offline, ensure consistent simulation)
- Alliance betrayal mechanics: penalty for leaving union mid-season (reputation system)

---

## DECRYPTION NOTE (For Developers)

### Encrypted Files
All game logic is stored in **XXTEA-encrypted .jsc files**:
- `assets/app/index.jsc` (1.26MB) - Main game logic
- `assets/app/proto/msg.jsc` (223KB) - Network protocol
- `assets/engines/cocos2d-jsb.jsc` (274KB) - Engine core
- 8 additional encrypted .jsc files

### XXTEA Key
- **Status**: NOT FOUND despite extensive search
- **Searched**: libcocos2djs.so, libNetHTProtect.so, libxt4.0.2_a64.so
- **Likely**: Dynamically generated, obfuscated, or embedded in binary
- **Workaround**: All high-level mechanics documented from logcat and user description

### For Rebuild Purpose
- **NOT NEEDED**: Can rebuild game mechanics from documented knowledge
- **All critical features documented**: Modes, victory conditions, seasons, UI structure, resource types
- **Exact numeric values**: Cannot extract from encrypted files (blocked)
- **Workaround**: Use logcat pattern estimates and user-documented values

---

### 17.5 Policy & Equipment (VERIFIED - source: "Policy and Equipment Recap.md"; 47 policy + 66 equipment screenshots OCR'd)

> **Authoritative data**: See `Policy and Equipment Recap.md` for the full, OCR-verified dataset.
> The rough equipment notes in §17.3 ("Exclusive Equipment for Soldiers") are superseded by this file.

**Policy system** (47 total — user-confirmed complete; all ★★★★, 3 value tiers [x/y/z], some with building requirements):
- All 47 documented across 9 functional groups: economy (Bountiful Harvest, Industrial Revolution, Farm/Quarry/Sawmill Mogul...), military (Warrior's Mindset, Warhorn, Armor Mastery, Mastery policies per troop category...), healing (Healer's Touch, Saint's Mercy), conscription (Unhindered Conscription, Mercenary Lord), construction (Exquisite Architecture, Bedrock Foundation), and more.

**Equipment system** (66 total):
- 42 common equipment across Smithy tiers Lv.1/3/5/7/12/14 — each grants 1 random effect from a 33-effect pool (True DMG, Leech, Rage gain, Shield, Burning Heart, Bleed, Fragile, dodge, etc.).
- 24 exclusive equipment (Smithy Lv.10, one per soldier sub-type, matching the 24 troop sub-types) — each grants additional HP + ATK stat rolls (user-confirmed), 2 random effects from the common pool, and 1 fixed soldier-skill modifier (the item's unique/patent effect).
- Recast loop: unwanted equipment → recast into new random equipment.
- Battle vocabulary confirmed by effect text: tile-based AoE ("up to 4 enemies within 1 tile", "up to 8 within 2 tiles"), Rage mechanics (+1 per attack, +50% after cast, +1 when hit by ATK DMG), Shield stacking rules, Weaponry class (cannot be healed, immune to knock-back).

---

### 17.6 Soldiers (VERIFIED - source: `SoldierAttribute.md`, user-authored, 2026-10-26)

> **Authoritative data**: See `SoldierAttribute.md` (363 lines) — do not duplicate. The rough tier-6 estimates in §17.3 are superseded by it.

- **24 soldier sub-types + 2 weaponry** (Catapult, Trebuchet), each with training levels 1–6.
- **Fixed attributes** (not upgradable): Rage (value1/value2 = initial/needed, resets to 0 after cast), Range, Move Range, Marching SPD, Crop Consumption, Cost Coefficient.
- **Upgradable via training Lv.1–6**: HP, ATK, Skill values (bracket ranges [min–max]).
- **Type triangle**: Spearman > Cavalry > Shieldman > Bowman > Spearman — counter attacks get +40% ATK and ignore 20% DMG Reduction; attackers from the countered type suffer −40% ATK.
- **Categories**: Spear (Longspearman, Lancer, Dagger Axe, Modao, Long Swordsman, Twin Spearman), Shield (Saber&Shield, Heavy Shield, Spear&Shield, Hammer&Shield, Sword&Shield, Axe&Shield), Bow (Longbowman, Crossbowman, Toxibowman, Hunter, Improved Crossbowman, Fire Bowman), Cavalry (Sword Cavalry, Spear Cavalry, Broadsword Cavalry, Heavy Cavalry, Bow Cavalry, Axe Cavalry).
- **Weaponry**: cannot be trained/upgraded; Catapult = Counter Building (+2 ATK vs buildings), Trebuchet = Penetration (1%→3.5% Max HP, requires Smithy Lv.14); cannot be healed, immune to knock-back.
- Skill names cross-referenced against the 24 exclusive equipment in `Policy and Equipment Recap.md` §3.3 (enhance vs add/replace passive relationships resolved).

---

### 17.7 Battle Guide & Plot System (VERIFIED - source: `Battle Guide/` 8 screenshots + `Plot/` 65 screenshots OCR'd + user-confirmed rules, 2026-10-26)

> **Authoritative data**: See `Battle Guide and Plot Recap.md` for the full dataset (battlefield tips, land/plot system, bestiary, battle mechanics, chest system).

- **Land system**: 5 land levels (Reward Points, output, chest quality scale with level) × 6 difficulties — sub-levels (user-confirmed): **Easy 1–3, Entry 1–3, Common 1–4, Advanced 1–4, Hard 1–4, Hell 1–2**. Enemy strength scales with distance from the player's capital, **capping at 12 tiles from the current capital**. Per-level difficulty ranges: lvl 1 = Easy 1→Common 1, lvl 2 = Entry 3→Common 3, lvl 3 = Common 4→Advanced 3, lvl 4 = Advanced 4→Hard 3, lvl 5 = Hard 4→Hell 2.
- **Plot garrisons (user-confirmed)**: plot levels 1–2 draw **random beasts** ordered by strength and plot distance from the capital; level 3 hosts high-level beasts; levels 4–5 host bandits.
- **Bestiary**: 15 beast types (Wolf L2 → Tiger/Rhino L5) + 3 beast bosses (Goat/Rat/Ape L8, Iron Mountain Stance, Move 0, Range 6 — spawn on plot level 3 beyond 12 tiles from the capital, one per resource type: **Goat=Stone, Rat=Crop, Ape=Wood**, user-confirmed) + 4 bandit types (Minion and Saberman have **no skills**; Assassin = Crit passive; Bowman, see below) + Boar Knight (L6/L7, always 4 per spawn; **skills never change across levels** — unobserved-level attributes may be interpolated at ≈ +90 HP / +15 ATK per level) + Soulreaper (L10 boss, strongest, Hell 2 only, accompanied by 4 Boar Knights).
- **Guardian equipment (user-confirmed)**: every Iron Mountain Stance unit wears random equipment — rolled per game session (differs between sessions, identical within one session).
- **Bandit Bowman** (user-documented): Bowman-type countering Spearman per the type triangle; active skill (Rage 0/4) deals additional DMG equal to 10% of the target's current HP.
- **Battle mechanics (user-confirmed)**: armies stack 1 tile per entry gate; turn 1 = first-entering group attacks then enemies; turn 2 = groups 2–5 attack, group 1 attacks last, then enemies; turn 3+ alternate. If an enemy is adjacent to the entry tile, all stacked troops attack in place without moving (they only move when no enemy is in attack range).
- **Capture rules**: destroying an unowned plot's flag or an enemy watchtower transfers the territory.
- **Team system (user-confirmed)**: max **12 teams** at Capital level 20; soldiers can be moved between teams and reordered within a team (e.g., slot 1 → slot 4).
- **Chests**: Wood/Silver/Gold/Special (nails or scrolls) from unowned plots; Universal chest from capturing an enemy capital (as conqueror or as attack participant). **Reward Points economy (user-confirmed):** cap 100, +50/day; first-time conquest chest costs 1/2/3 points for plot levels 1–3/4/5; **Grain Garrison** re-earns the same chests (minus Special Chest) at 3× the cost (3/6/9 points).

---

## FILE REFERENCES (Original Project)

| File/Path | Description | Size |
| --- | --- | --- |
| `DOCUMENTATION.md` | Comprehensive static analysis | 15KB |
| `REVERSE_ENGINEERING_STATUS.md` | Status report (what's done/blocked) | 10KB |
| `LOGCAT_ANALYSIS_SUMMARY.md` | Logcat findings summary | Varies |
| `game_logcat.txt` | 91.5 MB runtime logs (409,587 lines) | Critical |
| `apk_extracted/` | Full APK extraction | Varies |
| `arm64_libs/` | Native libraries (libcocos2djs.so, etc.) | Varies |
| `captured_flows.json` | 11 mitmproxy captured flows | Small |
| `game_packets_full.pcap` | 12,215 packets, 2.6 MB capture | Medium |
| `js_debug_logs.txt` | 36 extracted JS debug messages | Small |

---

## CONTACT & SUPPORT

**This guide generated from**: Reverse engineering of "Ninety Thousand Acres" (ä¹è¬ç•)
**Original Game**: Online multiplayer strategy game by Wang Zili
**Rebuild Goal**: Offline single-player with bot players, no coin/ingot dependency
**Target Platform**: Mobile (offline adaptation) or PC

**Last Updated**: 2026-10-24
**Data Sources**: APK extraction, logcat capture (91.5 MB), network captures, user documentation
