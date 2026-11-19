# Reverse Engineering Status - Ninety Thousand Acres

**Date:** 2026-10-24  
**Game:** 九萬畝 (Ninety Thousand Acres) v4.5.0  
**Package:** twgame.global.acers

---

## Current Status Summary

### ✅ Completed Tasks

#### 1. APK Extraction & Structure Analysis
- Extracted XAPK → base APK + ARM64 split + language packs
- Extracted base APK to `apk_extracted/`
- Mapped complete directory structure

#### 2. Game Engine Identification
- **Engine:** Cocos Creator 2.x/3.x with Cocos2d-x JavaScript runtime
- **JavaScript Engine:** V8 embedded in libcocos2djs.so
- **Main Activity:** org.cocos2dx.javascript.AppActivity
- **Boot Loader:** assets/main.js (plaintext, readable)

#### 3. Asset Inventory (24,000+ Files)
```
Resources Breakdown:
- JSON files: 6,031 (configs, metadata, scene data)
- PNG images: 1,579 (UI, sprites, backgrounds)
- MP3 audio: 200 (sounds, music)
- Character sprites: 18,245 (tmp/image/role/)
- UI elements: 1,000+ (buttons, panels, icons)
- Spine animations: ~200 (character animations)
```

#### 4. Multi-Language Support Confirmed
9 languages detected:
- cn (Chinese Simplified)
- en (English)
- hk (Chinese Traditional - Hong Kong)
- idl (Indonesian)
- jp (Japanese)
- kr (Korean)
- th (Thai)
- tw (Chinese Traditional - Taiwan)
- vi (Vietnamese)

#### 5. Native Library Analysis
Extracted and analyzed:
- **libcocos2djs.so** (34.2 MB) - Main Cocos2d-x engine + V8
- **libNetHTProtect.so** (5.8 MB) - Network protection
- **libxt4.0.2_a64.so** (290 KB) - Motion SDK anti-cheat
- **libc++_shared.so** (1.4 MB) - C++ runtime
- **libboringssl.so** (634 KB) - SSL/TLS

#### 6. SDK Integration Mapping
**Analytics & Attribution:**
- ThinkingData SDK
- Firebase Analytics
- AppsFlyer
- Facebook SDK

**Monetization:**
- Google Play Billing
- Google Ads (AdMob)

**Infrastructure:**
- Firebase Cloud Messaging (push notifications)
- Firebase Authentication
- Google Play Games Services
- YiDun (易盾) - NetEase anti-cheat

#### 7. UI Structure Documented
60+ game panels identified:
- Login/Registration panels
- Main game lobby
- Build construction UI
- Troop recruitment
- Battle interface
- Union management
- Ranking system
- Shop/IAP
- Settings

#### 8. Game Config Files Identified
90+ JSON configuration files (referenced but encrypted):
```
Key Configs:
- pawnBase (968jyso7RPqqURWtCFc1zA) - Unit/troop data
- buildBase (f6O4lJ7AhHy4tSw9blHjNe) - Building data
- buffBase (4dz3fHjMVAn6t+KNKWIMdq) - Buff/effect data
- equipBase (22wJvKdIdMwoC/7wpSsSI0) - Equipment data
- policy - Policy system
- strategy - Strategy cards
- land - Land/tile data
- cityResAttr - City resource attributes
- battlePass - Battle pass system
```

#### 9. Android Device Connection
- **Device:** Redmi Note 10S (21121119SG)
- **Android:** 11 (SDK 30)
- **Architecture:** ARM64-v8a
- **ADB:** Wireless connection 192.168.1.3:34251
- **USB Debug:** Enabled

#### 10. Documentation Created
- **DOCUMENTATION.md** - Comprehensive static analysis (15 KB)
- **GameGuardian_Guide.md** - Memory dump step-by-step guide (6 KB)

---

### ⚠️ Blocked Tasks (Core Obstacles)

#### 1. JavaScript Code Decryption - **BLOCKED**
**Problem:** All 11 .jsc files are XXTEA encrypted

**Files:**
```
assets/app/index.jsc           1.26 MB  - Main game logic
src/assets/app/proto/msg.jsc    223 KB  - Network protocol (protobuf)
assets/app/cocos2d-jsb.jsc      274 KB  - Cocos engine bindings
assets/app/settings.jsc          10 KB  - Game settings
+ 7 more JSC files
```

**Attempts:**
- ❌ Searched libcocos2djs.so for XXTEA key patterns → Not found
- ❌ Searched libNetHTProtect.so → Only RSA keys found
- ❌ Searched shell protection library → Obfuscated
- ❌ Frida dynamic instrumentation → Blocked by anti-cheat

**Conclusion:** Key is dynamically generated or deeply obfuscated in native code

#### 2. Frida Dynamic Instrumentation - **BLOCKED**
**Problem:** Multi-layer anti-cheat detection

**Anti-Cheat Stack:**
1. Motion SDK (libxt4.0.2_a64.so) - Device fingerprinting
2. NetHTProtect - Network traffic protection
3. YiDun (易盾) - NetEase anti-cheat service
4. SELinux enforcement - Android 11 blocks injection

**Symptoms:**
- frida-server crashes with SIGABRT when attaching
- Game detects Frida process and terminates
- SELinux denials in logcat

**Attempted:**
- Installed frida-tools 14.11.0
- Deployed frida-server 17.24.3 for ARM64
- Created hook scripts (frida_hook_xxtea.js)
- All attach attempts failed

#### 3. JSON Config Parsing - **PARTIALLY BLOCKED**
**Problem:** Configs stored in Cocos Creator binary format

**Current State:**
- config.json (2.26 MB) - Resource manifest with UUID mappings (READABLE)
- import/*.json files - Cocos Creator serialized data (BINARY FORMAT)
- Actual game configs (pawnBase, buildBase, etc.) referenced by UUID
- Format: `[version, uuids, properties, schemas, data]` arrays

**What's Readable:**
- Asset paths and UUID mappings ✅
- Resource categories and types ✅
- File structure ✅

**What's NOT Readable:**
- Actual config values (unit stats, building costs, etc.) ❌
- Game balance data ❌
- Progression systems ❌

---

### 🔄 Next Steps (Pending User Action)

#### Option 1: GameGuardian Memory Dump (PRIMARY APPROACH)
**Status:** Waiting for user to install GameGuardian

**Process:**
1. User installs GameGuardian APK on Android device
2. (Optional) Install in Virtual Space if non-root
3. Attach GameGuardian to running game process
4. Search memory for JavaScript patterns
5. Dump decrypted code from heap/anonymous regions
6. Extract dumps via ADB
7. Parse and reconstruct JavaScript files

**Expected Output:**
- Decrypted game logic (index.jsc content)
- Network protocol handlers (msg.jsc protobuf definitions)
- Game state managers
- UI event handlers

**Success Rate:** Moderate-High (depends on anti-cheat detection)

**Guide Created:** GameGuardian_Guide.md

#### Option 2: REA Static Analysis (FALLBACK)
**Status:** Configured, requires session restart

**What's Done:**
- REA MCP configured for copilot_cli
- Config written to C:\Users\naufa\.copilot\mcp-config.json

**What's Needed:**
- Session restart to load REA tools
- Java 17+ for JADX (current: Java 1.8)

**Limitations:**
- Cannot decrypt JSC files without key
- Can only analyze Java/Android layer
- No access to JavaScript game logic

#### Option 3: Parse Readable Assets (PARTIAL SOLUTION)
**Status:** Ready to execute

**What Can Be Done:**
- Extract all readable text from assets
- Document UI structure from panel names
- Map audio files to game events
- Analyze image assets for feature identification
- Parse main.js boot sequence

**What CANNOT Be Done:**
- Extract game mechanics (needs decrypted JS)
- Understand network protocol (needs msg.jsc)
- Document game balance (needs config data)

---

### 📊 Data Extraction Coverage

| Category | Status | Coverage | Notes |
|----------|--------|----------|-------|
| APK Structure | ✅ Complete | 100% | Full extraction done |
| Asset Inventory | ✅ Complete | 100% | All 24K files cataloged |
| Native Libraries | ✅ Complete | 100% | All .so files extracted |
| UI Structure | ✅ Complete | ~80% | Panel names identified |
| SDK Integration | ✅ Complete | 100% | All SDKs mapped |
| Multi-language | ✅ Complete | 100% | 9 languages confirmed |
| **JavaScript Code** | ❌ Blocked | 0% | **XXTEA encrypted** |
| **Network Protocol** | ❌ Blocked | 0% | **Encrypted in msg.jsc** |
| **Game Configs** | ⚠️ Partial | 20% | **Binary format** |
| **Game Mechanics** | ❌ Unknown | 0% | **Needs decrypted JS** |
| Anti-cheat | ✅ Complete | 100% | All protections identified |

---

### 🎯 Critical Path to Success

To fully reverse engineer this game, we MUST obtain decrypted JavaScript code.

**Two viable paths remain:**

1. **GameGuardian Memory Dump** (Best chance)
   - Extract JS from running process memory
   - Bypass encryption at runtime
   - Requires user to install GameGuardian

2. **Native Code Reverse Engineering** (Extreme difficulty)
   - Disassemble libcocos2djs.so with Ghidra/IDA
   - Locate XXTEA key initialization
   - Trace key derivation logic
   - Requires advanced reverse engineering skills

**Without decrypted JS:** Can only document surface-level features, UI structure, and asset inventory. Cannot understand game mechanics, network protocol, or create functional rebuild.

---

### 🔧 Tools & Resources Status

**Installed:**
- ✅ apktool
- ✅ Android Studio SDK (D:\App\AndroidStudioSDK)
- ✅ Python 3.x
- ✅ ADB (wireless debugging active)
- ✅ frida-tools (blocked by anti-cheat)
- ✅ REA configured (needs restart)

**Missing:**
- ❌ GameGuardian (user needs to install)
- ❌ Java 17+ (for JADX, current: Java 1.8)
- ❌ Ghidra/IDA (for deep native analysis)

**Device:**
- ✅ Connected via ADB wireless
- ✅ USB debugging enabled
- ✅ Game installed and runnable
- ❌ Root access (assumed non-root)

---

### 📝 Key Findings

1. **Game uses standard Cocos Creator architecture** - Not custom engine
2. **XXTEA encryption is properly implemented** - Key not exposed in strings
3. **Multi-layer anti-cheat prevents Frida** - Motion SDK + YiDun + NetHTProtect
4. **Config data in Cocos binary format** - Not plain JSON
5. **Hot update system present** - Can receive updates post-release
6. **Server-authoritative design** - Heavy client-server validation
7. **Protobuf for network protocol** - msg.jsc contains message definitions

---

### 🚧 Risk Assessment

**Memory Dump Approach:**
- **Risk:** GameGuardian might be detected by anti-cheat
- **Mitigation:** Use Virtual Space to isolate detection
- **Fallback:** Dump multiple times, extract what's possible

**Native Code Analysis:**
- **Risk:** Extremely time-consuming (weeks/months)
- **Mitigation:** Only pursue if memory dump fails completely

**Legal/Ethical:**
- **Purpose:** Educational reverse engineering and rebuild
- **Use case:** Learning game architecture, not cheating
- **Data:** For personal reconstruction project

---

## Waiting for User Action

**Current blocker:** GameGuardian installation

**User needs to:**
1. Download GameGuardian APK from https://gameguardian.net/download
2. Install on Android device (may need "Install from unknown sources")
3. Launch game until fully loaded (main menu)
4. Follow GameGuardian_Guide.md steps

**After memory dump:**
- Pull dump files via ADB
- Extract JavaScript strings
- Reconstruct game logic files
- Continue with full documentation

---

**End of Status Report**
