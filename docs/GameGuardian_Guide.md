# GameGuardian Memory Dump Guide - Ninety Thousand Acres

## Objective
Extract decrypted JavaScript code from game memory while running.

---

## Prerequisites

### 1. Install GameGuardian
**Download:** https://gameguardian.net/download
- APK versi terbaru (tidak ada di Play Store)
- Install dengan "Allow from this source"

### 2. Setup Virtual Space (Jika Non-Root)
GameGuardian butuh Virtual Space jika HP tidak root:
- **Parallel Space** (Google Play Store), atau
- **Virtual Master** (Google Play Store)
- Install Ninety Thousand Acres di dalam Virtual Space

**Atau gunakan langsung jika HP sudah root.**

---

## Step-by-Step Memory Dump

### Step 1: Start GameGuardian
1. Buka GameGuardian
2. Tap icon floating button
3. Pilih process: **NINETY THOUSAND ACRES** (atau twgame.global.acers)
4. Tunggu attach berhasil

### Step 2: Start Game
1. Buka game Ninety Thousand Acres
2. Login sampai masuk lobby/main menu
3. **Penting:** Tunggu game fully loaded (logo Cocos selesai)

### Step 3: Search Memory Region
1. Di GameGuardian, tap **icon magnifying glass** (Search)
2. Pilih **Memory Regions** (icon gear)
3. Centang HANYA:
   - **Anonymous (A)**
   - **Java Heap (Jh)**
   - **C++ alloc (Ca)**
4. OK

### Step 4: Search JavaScript Patterns

**Option A: Search String Pattern**
1. Tap Search (magnifying glass)
2. Select: **String** type
3. Search: `function` atau `var ` atau `require(`
4. Tap Search
5. Akan muncul banyak results (ribuan)

**Option B: Search Known Function Name**
Dari dokumentasi, cari nama function game seperti:
- `pawnBase`
- `buildBase`
- `LoadScene`
- `GameManager`

### Step 5: Dump Memory Region
1. Setelah search, pilih **ANY result** yang muncul
2. Tap **Address** dari result
3. Akan masuk ke Memory Viewer
4. Tap **icon menu** (3 dots)
5. Pilih **Save**
6. Set:
   - **Start Address:** (address saat ini minus 50000) - format hex
   - **End Address:** (address saat ini plus 500000)
   - **File name:** `dump_heap_1.bin`
7. Save ke `/sdcard/`

**Ulangi untuk beberapa region berbeda** (3-5 dumps)

### Step 6: Alternative - Full Process Dump
1. Tap icon menu (3 dots) di main GameGuardian
2. Pilih **Memory Dump**
3. Select regions: **Ca**, **Jh**, **Anonymous**
4. Output: `/sdcard/GameGuardian/dump_<timestamp>.bin`
5. Ini akan dump SEMUA memory (bisa 500MB-2GB)

---

## Step 7: Extract Dumps ke PC

```powershell
# Pull dump files via ADB
adb -s 192.168.1.3:34251 pull /sdcard/GameGuardian/ "D:\Android\NTA Project Reverse Engineering\memory_dumps\"

# Atau pull manual
adb -s 192.168.1.3:34251 pull /sdcard/dump_heap_1.bin "D:\Android\NTA Project Reverse Engineering\"
```

---

## Step 8: Analyze Memory Dumps (PC)

### Extract JavaScript Strings

```powershell
# Extract all ASCII strings from dump
python -c "
import sys, re
data = open('dump_heap_1.bin', 'rb').read()
strings = re.findall(b'[\x20-\x7e]{50,5000}', data)
with open('extracted_strings.txt', 'w', encoding='utf-8') as f:
    for s in strings:
        try:
            f.write(s.decode('utf-8') + '\n---\n')
        except:
            pass
"
```

### Search for JavaScript Functions

```powershell
# Search for function definitions
Select-String -Path "extracted_strings.txt" -Pattern "function \w+\(" -Context 0,10 | Out-File "found_functions.txt"

# Search for game-specific code
Select-String -Path "extracted_strings.txt" -Pattern "pawnBase|buildBase|GameManager|LoadScene" -Context 5,5
```

### Look for Complete JS Files

JavaScript biasanya ada marker seperti:
- `"use strict";` di awal
- `module.exports = ` 
- `require("` 
- `cc.Class({` (Cocos Creator class definition)

Cari block lengkap dari marker ini sampai closing brace `}`

---

## Expected Output

Dari memory dump, kita expect dapat:
1. **Decrypted game logic** - function definitions, class definitions
2. **Network protocol handlers** - protobuf message processing
3. **Game state managers** - inventory, battle, union management
4. **Configuration loaders** - yang load pawnBase, buildBase configs
5. **UI event handlers** - button clicks, panel navigation

---

## Tips & Troubleshooting

### Jika Tidak Ada Results
- Game belum fully load - tunggu sampai main screen
- Memory region salah - centang **Anonymous** dan **C++ alloc**
- Search string terlalu spesifik - coba `var ` atau `function `

### Jika Dump Terlalu Besar
- Jangan dump seluruh process (2GB+)
- Dump per-region (500KB-50MB per file)
- Focus pada **Ca** (C++ alloc) - ini heap Cocos2d-x

### Jika String Terputus-putus
- Memory fragmented - normal
- Cari multiple dumps dari address berbeda
- Reconstruct dengan cari pattern `function xxx` start dan closing `}`

### Verification
Cek hasil extract mengandung:
```javascript
// Should see patterns like:
cc.Class({
    extends: cc.Component,
    properties: {
        // ...
    },
    onLoad: function() {
        // ...
    }
});
```

---

## Next Steps After Dump

1. **Organize extracted JS** - pisahkan per-file based on module names
2. **Reconstruct structure** - gabungkan fragments jadi complete files
3. **Document functions** - list semua function names dan purpose
4. **Map to configs** - hubungkan code dengan JSON configs
5. **Analyze network protocol** - cari protobuf message handlers

---

## Alternative: Dumping Specific Library

Jika ingin focus pada libcocos2djs.so memory:

```
GameGuardian → Memory Regions → Centang ONLY:
- Code app (Ca)
- Anonymous (A)

Filter by module:
- Tap "Select" 
- Choose "libcocos2djs.so"
- Ini akan show memory yang allocated oleh library ini
```

---

## Safety Notes

- GameGuardian untuk learning/research
- Jangan modify memory (cheat) - fokus READ only
- Game bisa detect GameGuardian → main di offline mode / local test
- Anti-cheat (Motion SDK, YiDun) mungkin deteksi → gunakan Virtual Space

---

**Time estimate:** 30-60 menit untuk full dump dan extract process
**Output size:** 100MB-500MB dumps, 10-50MB extracted JS (estimated)
