# Ninety Thousand Acres (九萬畝) - Reverse Engineering Documentation

**Version:** 4.5.0 (Build 73)  
**Package:** twgame.global.acers  
**Developer:** DH-Publisher  
**Analysis Date:** 2026-10-24

---

## Executive Summary

Ninety Thousand Acres is a server-side multiplayer strategy game built with Cocos Creator (JavaScript/Cocos2d-x). The game uses encrypted JavaScript bytecode (.jsc files) protected by a shell (version 4.23.201.3). Native components include network protection (NetHTProtect), crash reporting, and anti-cheat measures (Motion SDK, YiDun).

**Key Challenge:** Game logic is compiled to XXTEA-encrypted JSC bytecode. Decryption key not yet located in static analysis.

---

## Game Overview

### Game Modes
1. **Newbie Division** - First-time player mode (max 2 sessions per account)
2. **Ranked Division** - Competitive ranking from Iron 1 to Ace
3. **Free Division** - Unlimited practice sessions

### Win Conditions

**Construct Remains:**
- Control 1 remains upgraded to level 20, OR
- Control 3 remains upgraded to level 12, OR
- Control all 4 remains, OR
- Most remains + highest level when winter season starts

**Final Conquest:**
- Fixed unions from session start
- Must control all enemy unions until winter season ends
- Highest points win if no full conquest

### Season System
- **4 Seasons:** Spring, Summer, Autumn, Winter
- **Duration:** 3 real-time days per season
- **Total Session:** ~12 days

### Core Mechanics
- Build and upgrade structures
- Recruit troops
- Control land tiles
- Capture remains (landmarks with bonuses)
- Form/join unions (guilds/alliances)
- Real-time PvP battles

---

## Technical Architecture

### Platform & Engine
- **Framework:** Cocos Creator 2.x/3.x
- **Runtime:** Cocos2d-x with JavaScript bindings
- **Min SDK:** Android 23 (Android 6.0)
- **Target SDK:** Android 36

### Native Libraries (ARM64)

| Library | Size | Purpose |
|---------|------|---------|
| libcocos2djs.so | 34.2 MB | Cocos2d-x engine + JS runtime |
| libNetHTProtect.so | 5.8 MB | Network traffic protection/anti-tamper |
| libhtpcrash.so | 76 KB | Crash reporting |
| libhtpcrash_dumper.so | 101 KB | Crash dump collector |
| libxt4.0.2_a64.so | 290 KB | Motion SDK - device fingerprinting/anti-cheat |

### Code Structure

```
assets/
├── main.js                 # Bootstrap loader (6KB, plaintext)
├── project.json            # Cocos Creator project config
├── shellinfo               # Protection shell metadata
├── src/
│   ├── cocos2d-jsb.jsc    # Engine bindings (275KB, encrypted)
│   ├── settings.jsc        # Game settings (268B, encrypted)
│   └── assets/app/
│       ├── lib/            # Third-party libraries
│       │   ├── thinkingdata.mg.cocoscreator.min.jsc  # Analytics
│       │   └── pb/         # Protobuf
│       │       ├── long/long.jsc
│       │       └── protobuf/protobuf.jsc
│       └── proto/
│           └── msg.jsc     # Network protocol (223KB, encrypted)
├── assets/
│   ├── app/                # Main game bundle
│   │   ├── index.jsc       # Main game logic (1.26MB, encrypted)
│   │   └── import/         # Asset metadata
│   ├── resources/          # Game assets
│   │   ├── import/         # 6030 JSON asset descriptors
│   │   └── native/         # 1768 actual assets (PNG, MP3, etc)
│   ├── main/               # UI scenes
│   ├── internal/           # Engine resources
│   └── manifest/           # Hot update manifest
└── motion/                 # Anti-cheat native modules
```

### Encryption

**Status:** JSC files are encrypted  
**Method:** Likely XXTEA (standard for Cocos Creator)  
**Evidence:**
- `config.json`: `"encrypted": true`
- shellinfo: `shellversion=4.23.201.3 protecTime::2026-10-17 15:51:05`
- No standard file headers in JSC files
- Random-looking byte patterns

**Decryption Key:** Not yet located in static analysis

---

## Asset Inventory

### Total Counts
- **Images:** 1,579 PNG files
- **Audio:** 200 MP3 files  
- **JSON Configs:** ~6,049 files
- **Prefabs:** ~1,755 files
- **Fonts:** Multi-language support (9 languages)

### Asset Categories

**Images (by category):**
- `tmp/image/role/`: 18,245 files - Character sprites/animations
- `tmp/image/avatar_hero/`: 663 files - Hero portraits
- `tmp/image/land_*/`: 1,171 files - Terrain tiles (4 land types)
- `tmp/image/bullet/`: 289 files - Projectile animations
- `tmp/image/buff_icon/`: 121 files - Status effect icons
- `tmp/image/build/`: 99 files - Building sprites
- `tmp/image/story/`: 166 files - Story/cutscene assets
- Others: strategy, activities, equip, skill icons, etc.

**Audio (by category):**
- `sound/pawn/`: 152 files - Character sounds
- `sound/novice/`: 14 files - Tutorial sounds
- `sound/common/`: 15 files - UI sounds
- `sound/build/`, `sound/area/`, `sound/main/`, etc.

### Config Data (common/json/)

| Config File | Purpose (Inferred) |
|-------------|-------------------|
| pawnBase | Unit/troop definitions |
| buildBase | Building definitions |
| buffBase | Status effect/buff definitions |
| buffAttr | Buff attributes |
| equipBase | Equipment definitions |
| land | Land tile properties |
| strategy | Strategy/tactic configs |
| policy | Policy/governance configs |
| antiCheat | Anti-cheat parameters |
| achieveTask | Achievement definitions |
| battlePass | Battle pass configs |
| artofwarTask | Tutorial/scenario tasks |
| behavior | AI behavior configs |
| botany | Plant/farming system |
| _map_scene_grid | Map grid data |
| _snailIsle_build | Special map configs |

**UUID Mappings (sample):**
- pawnBase: `968jyso7RPqqURWtCFc1zA`
- buildBase: `f6O4lJ7AhHy4tSw9blHjNe`
- buffBase: `4dz3fHjMVAn6t+KNKWIMdq`
- land: `711TL1W7lMQpz3MKNlS4RB`
- strategy: `4cQhCQ85BFn4DYM3vh6WEG`
- policy: `9fjeRqbzRP1JKu+YS4qOpt`
- equipBase: `8d2eRjMwJMn65HhinrXDft`

---

## Java/Android Components

### Main Activity
- **Launch Activity:** `org.cocos2dx.javascript.AppActivity`
- **Package Structure:** `org.cocos2dx.javascript.*`

### Key Components

**SDK Integrations:**
- `AppsFlyerHelper` - Attribution tracking
- `FacebookHelper` - Facebook SDK integration
- `GoogleHelper` - Google Sign-In
- `GooglePayHelper` - In-app purchases
- `GooglePlayGamesHelper` - Play Games services
- `YiDunHelper` - NetEase YiDun anti-cheat (易盾)
- `FirebaseAppleHelper` - Firebase Analytics
- `DeviceHelper` - Device info collection

**Game Services:**
- `ApkUpdateHelper` - Hot update mechanism
- `JsbHelper` - JavaScript bridge utilities
- `MessageHelper` / `MyFirebaseMessagingService` - Push notifications
- `SDKWrapper` - Native SDK bridge
- `CocosCreatorProxyApi` - Engine API proxy

### Permissions

**Network:**
- INTERNET
- ACCESS_NETWORK_STATE
- ACCESS_WIFI_STATE

**Advertising:**
- AD_ID
- ACCESS_ADSERVICES_ATTRIBUTION
- ACCESS_ADSERVICES_AD_ID

**Device ID (for multiple vendors):**
- Various OEM-specific device ID permissions (Asus, Samsung, Huawei, etc.)

**Billing:**
- com.android.vending.BILLING

**Notifications:**
- POST_NOTIFICATIONS
- WAKE_LOCK
- RECEIVE (C2DM)

---

## Network Protocol

### Protocol Format
- **Serialization:** Protocol Buffers (protobuf)
- **Proto Definitions:** Included in APK (`google/protobuf/*.proto`)
- **Message Definitions:** Compiled in `msg.jsc` (encrypted, 223KB)

### Network Protection
- **NetHTProtect** library (5.8MB)
- Likely implements:
  - Traffic encryption
  - Anti-replay protection
  - Integrity checks
  - Anti-tampering

### Server Communication
- Game is server-authoritative (all game state on server)
- Likely uses WebSocket or HTTP for real-time communication
- Firebase for push notifications

---

## Anti-Cheat & Protection

### Code Protection
1. **JavaScript Encryption:** XXTEA-encrypted JSC bytecode
2. **Shell Protection:** Version 4.23.201.3
3. **Obfuscation:** Likely minified/obfuscated JS source before compilation

### Runtime Protection
1. **Motion SDK (libxt4.0.2):** Device fingerprinting, behavior analysis
2. **YiDun (易盾):** NetEase anti-cheat service
3. **NetHTProtect:** Network traffic protection
4. **SafetyNet/Play Integrity:** Google Play Services integrity checks

### Detection Methods (Likely)
- Root/jailbreak detection
- Emulator detection
- Memory tampering detection
- Speed hack detection
- Network packet modification detection

---

## UI Structure (Views)

### Main View Categories

**Login/Lobby:**
- `view/login/` - Login screens
- `view/lobby/` - Main lobby UI

**Main Game:**
- `view/main/` - Main game screen
- `view/area/` - Area/map view
  - AreaArmyPnl, AreaUIPnl, BattleEndPnl, etc.
- `view/menu/` - Game menus

**Activities:**
- `view/activity/` - 42 different activity panels
  - BuildMasterPnl, CorsairArenaPnl, DrawPnl, etc.
- `view/artofwar/` - Tutorial/scenario mode (16 panels)
- `view/artofwarMain/` - Tutorial main screens

**Other:**
- `view/build/` - Building UI
- `view/common/` - Shared UI components (106 files)
- `view/novice/` - New player tutorial
- `view/notice/` - Announcement/notice panels
- `view/help/` - Help screens
- `view/playback/` - Replay system

---

## Localization

**Supported Languages:**
1. Chinese Simplified (cn)
2. English (en)
3. Chinese Traditional - Hong Kong (hk)
4. Indonesian (idl)
5. Japanese (jp)
6. Korean (kr)
7. Thai (th)
8. Chinese Traditional - Taiwan (tw)
9. Vietnamese (vi)

**Font Assets:** Each language has dedicated font files (~21 files per language)

---

## Third-Party SDKs

### Analytics & Attribution
- **ThinkingData:** Analytics SDK (`thinkingdata.mg.cocoscreator.min.jsc`)
- **AppsFlyer:** Attribution tracking
- **Firebase Analytics:** User behavior tracking
- **Firebase Performance:** Performance monitoring

### Social & Auth
- **Facebook SDK:** Social features and login
- **Google Sign-In:** Authentication
- **Google Play Games:** Leaderboards, achievements, cloud save

### Monetization
- **Google Play Billing:** In-app purchases
- **Google Ads:** Advertising (APPLICATION_ID in manifest)

### Infrastructure
- **Firebase Cloud Messaging:** Push notifications
- **Firebase Auth:** Authentication backend

---

## File Formats

### .jsc Files (JavaScript Compiled)
- **Format:** Cocos Creator compiled JavaScript
- **Encryption:** XXTEA (suspected)
- **Structure:** Binary bytecode executable by Cocos2d-x JSB
- **No Standard Header:** Encrypted files have no recognizable magic bytes

### .json Files (Asset Metadata)
- **Format:** Cocos Creator asset serialization
- **Structure:**
  ```json
  [version, [uuids], [property_names], [type_schemas], [data_arrays], ...]
  ```
- **Contains:** Scene hierarchies, component data, asset references

### Asset Bundles
- **config.json:** Bundle manifest with path-to-UUID mappings
- **index.jsc:** Bundle entry point (encrypted)
- **import/:** Asset metadata JSON files
- **native/:** Actual asset files (PNG, MP3, etc.)

---

## Hot Update System

### Mechanism
- `ApkUpdateHelper.java` - Handles update downloads
- `manifest/` bundle - Update manifest
- `HotUpdateSearchPaths` - Local storage key for update cache
- Versioned bundles in `slg-hot-update/` directory
- Version check: localStorage key `jwm_big_version`

### Update Process
1. Check current version vs. server version
2. Download update bundle if needed
3. Extract to local storage
4. Update search paths
5. Clear cache on major version change

---

## Build Information

**Compiled:** 2026-10-17 15:51:05  
**Platform:** Android ARM64-v8a (primary), also has x86, x86_64, armeabi-v7a  
**Compiler:** Cocos Creator (exact version TBD)  
**Target API:** Android 36 (Android 16, not yet released in 2024)  
**Split APKs:** Base + ARM64 + EN language + MDPI density

---

## Reverse Engineering Status

### ✅ Completed
- APK extraction and structure analysis
- Asset inventory and categorization
- Native library identification
- Java/Android component mapping
- UI structure mapping
- SDK integration identification
- Localization mapping

### ⚠️ In Progress
- JSC decryption (blocked - key not found)
- Network protocol analysis (requires decrypted proto definitions)
- Game logic reconstruction (requires decrypted game code)

### ❌ Blocked
- **JSC Decryption Key:** Not located in static analysis
- **Game Logic Source:** Encrypted in app/index.jsc (1.26MB)
- **Network Protocol Details:** Encrypted in proto/msg.jsc (223KB)

### 🔧 Next Steps Required

**Option 1: Dynamic Analysis**
- Run game in emulator with memory dumps
- Hook libcocos2djs.so to intercept decryption
- Extract decrypted JS from memory

**Option 2: Native Reverse Engineering**
- Disassemble libcocos2djs.so
- Locate XXTEA decryption function
- Extract hardcoded key or key derivation algorithm

**Option 3: Existing Tools**
- Search for Cocos Creator JSC decryption tools
- Check if this shell version has known vulnerabilities
- Community tools for shellversion 4.23.x

---

## Security Considerations

### Client-Side Security
- All game logic runs on client (but encrypted)
- Server validates all actions (server-authoritative)
- Anti-cheat measures in multiple layers

### Data Privacy
- Extensive device fingerprinting (Motion SDK)
- Multiple analytics SDKs tracking behavior
- Device ID collection from multiple vendors
- Location data may be collected (per Play Store listing)

### Network Security
- NetHTProtect for traffic protection
- Likely uses HTTPS for all server communication
- Firebase for secure push messaging

---

## References

### Documentation
- Cocos Creator Official Docs: https://docs.cocos.com/
- Cocos2d-x GitHub: https://github.com/cocos2d/cocos2d-x
- XXTEA Encryption: Standard tea cipher variant

### Tools Used
- aapt2 (Android Asset Packaging Tool)
- dexdump (DEX file analyzer)
- Python (script analysis)
- Standard ZIP tools (APK/XAPK extraction)

### Play Store
- https://play.google.com/store/apps/details?id=twgame.global.acers
- Rating: 4.7/5 (78.9K reviews)
- Downloads: 1M+
- Contains ads and in-app purchases

---

## Appendix: Key File Paths

### Critical Files
```
NINETY_THOUSAND_ACRES_base.apk           # Main APK (89MB)
config.arm64_v8a.apk                     # ARM64 native libs (13MB)

assets/main.js                           # Bootstrap (plaintext)
assets/src/cocos2d-jsb.jsc              # Engine (encrypted, 275KB)
assets/assets/app/index.jsc             # Main game logic (encrypted, 1.26MB)
assets/src/assets/app/proto/msg.jsc     # Network protocol (encrypted, 223KB)

assets/assets/resources/config.json      # Asset manifest (2.2MB)
assets/assets/app/config.json           # App bundle config
assets/assets/main/config.json          # Main bundle config

lib/arm64-v8a/libcocos2djs.so          # Engine (34MB)
lib/arm64-v8a/libNetHTProtect.so       # Network protection (5.8MB)
assets/motion/libxt4.0.2_a64.so        # Anti-cheat (290KB)
```

### Config UUIDs (Sample)
```
pawnBase:    968jyso7RPqqURWtCFc1zA
buildBase:   f6O4lJ7AhHy4tSw9blHjNe
buffBase:    4dz3fHjMVAn6t+KNKWIMdq
equipBase:   8d2eRjMwJMn65HhinrXDft
land:        711TL1W7lMQpz3MKNlS4RB
strategy:    4cQhCQ85BFn4DYM3vh6WEG
policy:      9fjeRqbzRP1JKu+YS4qOpt
```

---

**Document Version:** 1.0  
**Last Updated:** 2026-10-24  
**Status:** Initial static analysis complete, decryption pending
