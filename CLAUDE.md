# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Tujuan Project

Reverse engineering + rebuild offline **Ninety Thousand Acres** (九萬畝, `twgame.global.acers` v4.5.0) untuk dimainkan sendiri secara **offline 1:1 seperti game aslinya**. Game asli online multiplayer Cocos Creator 2.4.11 (mqant TCP port 3653, protobuf, server `nine-hk.twomiles.cn`). Game logic ada di server-side dan dilindungi anticheat (XXTEA .jsc, key tidak ditemukan) — yang bisa diambil hanya asset UI/musik/desain. Fungsionalitas direkonstruksi dari OCR screenshot + pengalaman main asli + dokumentasi user.

Motivasi utama (user): game asli memaksa main rutin agar tidak tertinggal dari player lain. Versi rebuild harus **anti-grind / santai**: langsung main tanpa menunggu, tanpa tekanan waktu.

## Commands

```bash
# Jalankan demo rebuild
cd nta_demo && flutter pub get && flutter run

# Build/publish dari sumber asli (bila perlu file asli — tidak ikut push)
# Ekstrak ulang dari NINETY+THOUSAND+ACRES_4.5.0_APKPure.xapk
```

Demo pakai Flame (game engine), provider (state), shared_preferences (save). Tidak ada test suite.

## Struktur Repo

| Path | Isi |
|------|-----|
| `nta_demo/` | Flutter demo rebuild (main target development) |
| `NTAGame/` | Prototipe Android native (Kotlin) |
| `game-demo/` | Prototipe web/JS |
| `apk_extracted/`, `apk_out/`, `arm64_*` | Hasil ekstrak APK (tidak ikut push) |
| `*.md` | Dokumentasi RE |
| `ocr_*.txt`, `cocos_scenes.txt`, `gallery*.txt` | Hasil OCR & scene Cocos |
| `game_packets*.pcap`, `captured_flows.json` | Network capture |
| `frida_hook_xxtea.js`, `gen_data.py`, `ocr_extract.py` | Script bantu RE |

## Sumber Data Authoritative (urutan kepercayaan)

1. **`SoldierAttribute.md`** — data soldier (HP/Rage/ATK/Range/Move/Crop/March SPD/Cost/Skill per level 1–6). User-authored, paling valid. Type triangle: **Spearman > Cavalry > Shieldman > Bowman > Spearman** (counter: +40% ATK, ignore 20% DMG Reduction; dikunci balik: ATK −40%).
2. **`Battle Guide and Plot Recap.md`** — bestiary 21 enemy (15 beast + 6 bandit), plot system, difficulty, chest, reward points.
3. **`Hero Skill and Expertise.md`** — 56/59 hero: skill, possession troop, HP/ATK ranges, expertise pools.
4. **`Policy and Equipment Recap.md`** — policy & equipment effects.
5. **`REBUILD_GUIDE.md`** — arsitektur game asli + spesifikasi rebuild offline (§13–15).

**§ "Data Absolut Game Asli" di file ini** = narasi playthrough user (dicatat 2026-11-01), user-confirmed, **fundamental untuk semua logika rebuild**. Kalau bertentangan dengan docs di atas → tanya user, jangan pilih sendiri. Data belum lengkap ditandai `TODO`.

## Arsitektur Demo (`nta_demo/`)

```
lib/
  main.dart                      # Entry, theme, BuildingListModal, FacilityAccessModal, GameScreen
  data/game_data.dart            # Konstanta: map 80x80, buildings, troop defs, plot specs
  game/models/game_state.dart    # GameState (ChangeNotifier) — SEMUA game logic: resource tick,
                                 #   production hourly, battle sim, conquest, save/load
  game/components/
    lobby_view.dart              # Entry: pilih divisi (Newbie/Free/Ranked) + resume bar
    game_map.dart                # World map 80x80 CustomPainter
    capital_interior_view.dart   # Capital interior 17x17 (court 7x7, palace, barracks, dsb)
    plot_interior_view.dart      # Tampilan dalam 1 plot (battle/garrison)
    viewport.dart                # GameViewport util (lobby/map/capital/plot)
  game/ui/
    game_tabs.dart               # Tab bawah: Citadel/Barracks/Smithy/Heroes/Expedition/Log
    resource_bar.dart            # HUD resource + season indicator
```

Pola: GameState hold semua state + logika, UI read via provider. Save/load via shared_preferences (JSON). Konstanta gameplay di `game_data.dart`.

## Aturan Desain Offline (keputusan user, ikuti ini)

- **Tidak ada coin/ingot / top-up.** Asli: 5 spin General Muster Terrace = 598 coin (user cuma punya 10 coin dari quest; top-up mahal). Rebuild: **spin bebas tanpa biaya**.
- **Tidak ada sistem sesi/waitlist.** Asli: daftar dulu; newbie langsung gabung, sesi free/ranked buka pukul 9 pagi H+1..H+5. Rebuild: pilih division → **langsung main**. Lawan = bot dengan **3 level kesulitan**.
- **Reset tak terbatas** untuk semua pemilihan acak (asli: hanya 1x reset): pemilihan policy capital, pemilihan pasukan awal di Barrack, pemilihan equipment (1 dari 3), pemilihan exclusive equipment, pemilihan policy union.
- **Season timer pause saat game ditutup** — durasi season tetap 3 hari real-time, waktunya berhenti saat close, lanjut saat dibuka lagi.
- **Division tetap ada**: Newbie / Free / Ranked. Victory Newbie & Free = **Construct Remains** (lihat § Data Absolut). Ranked = **Final Conquest** (rank Iron→Ace).
- **Bronze Tallies** = currency earned (reward ranking [1-100], dipakai rekrut hero lebih kuat) — bukan coin top-up; pertahankan atau buat gratis.
- **Mall** (capital skin 2000 coin, soldier skin 500, avatar 150/300, chat emoji 300) asli pakai coin — rebuild: gratis atau tidak diperlukan.
- **Anti-grind**: resource jangan memaksa main rutin; production berjalan offline-realtime.

## Data Absolut Game Asli (playthrough user — fundamental semua logika rebuild)

### Divisi & Victory Rules

| Division | Sesi | Victory |
|----------|------|---------|
| **Newbie** | langsung gabung | Construct Remains (sama dengan Free) |
| **Free** | waitlist buka 9 pagi H+1..H+5 | Construct Remains; Union Market → **Free Market** (barter dengan pemain mana pun, tidak harus satu union) |
| **Ranked** | waitlist buka 9 pagi H+1..H+5 | **Final Conquest** |

- **Implementasi demo (2026-11-14)**: lobby (`lobby_view.dart`) = entry screen; `GameData.DIVISIONS` (3 entri, teks rules di atas) + `GameData.RANK_TIERS` (24 tier dari `seasonReward.json`); `GameState.chooseDivision(i)` langsung mulai (tanpa waitlist), divisi sama = lanjut sesi, divisi beda = season reset; Ranked dapat Tier Win Points saat conquest (`TIER_POINTS_PER_PLOT_LEVEL = 5`, TODO angka asli server-side) dan HUD menampilkan `poin + tier`.
- **Rules verbatim (screenshot Rules/, 2026-10-24)**:
  - **Newbie**: (1) create unions freely; (2) Union Market — hanya anggota union bisa trade; (3) reward **[1-100] Bronze Tallies** sesuai ranking akhir — dipakai rekrut hero lebih kuat; (4) tidak dapat Tier Win Points; (5) Victory: Construct Remains.
  - **Free**: sama dengan Newbie + **No Reward Points Limit**; Victory: Construct Remains.
  - **Ranked**: daftar dulu; **union di-assign otomatis**; top 3 alliance dapat bonus **Scroll Fragments**; dapat **Tier Win Points** sesuai ranking; Victory: Final Conquest.
- **Construct Remains** (verbatim): (1) build remains ke **Lv.20** pertama → menang; (2) kuasai **3 remains Lv.12** → menang; (3) saat **winter datang** remains hanya dikuasai 1 force → menang; (4) winter berakhir → settlement berdasarkan **level remains** (jika sama → berdasarkan **territory ranking**); (5) remains yang direbut ulang → **level turun 3**; (6) union yang kuasai 2 remains → semua anggota **tidak bisa menghindar dari fight**. Mode ini memperbolehkan buat/keluar/masuk union.
- **Remains** = capital netral: **Chang'an, Luoyang, Yanjing, Jinling** (total 4). Isinya banyak prajurit netral **lvl 6** yang menyerang siapa pun yang masuk. Bisa dikuasai lewat kerja sama union. Layout dalam = sama seperti capital.
- **Final Conquest** (verbatim): (1) kalahkan semua Union Leader lain → menang; (2) settlement berdasarkan **total union points saat winter berakhir**; (3) union leader dikalahkan → **semua anggota settle & keluar langsung**; (4) individu yang dikalahkan bisa pilih settle sendiri (posisi terakhir saat itu) atau ikut leader; (5) poin individu yang dikalahkan **dikurangi dari total poin union**.
- **Season Rewards — rank ladder** (screenshot Rules/): Iron II/I → Bronze III-I → Silver III-I → Gold III-I → Platinum IV-I → Diamond V-I → Master III-I → **Ace**. Threshold poin & reward Coin naik (Iron 100 → Ace 500) + hero fragment di tier tertentu + hero frame di Ace. Ladder ranked diisi dari **Tier Win Points**.

### Awal Game & Layout

- **Capital awal**: 4 tile (2x2). Army 1 berisi **2 unit Longspearman** (Spearman type) untuk penyerbuan awal.
- **Capital interior**: 17x17 total. **City wall 7x7** di tengah (HP 200, ATK 22, ATK Range 6) — termasuk city wall 7x7, area di dalamnya **5x5** untuk bangunan (user konfirmasi dari video dokumentasi, 2026-11-01).
- **City wall punya 4 gerbang** (atas/bawah/kiri/kanan), masing-masing 1 petak. Pasukan **melee musuh hanya bisa menyerang city wall di 4 titik gerbang**; pasukan **ranged** bisa menyerang di mana pun selama dalam ATK Range.
- **Plot biasa interior: 11x11.** Jarak city wall/bendera ↔ pintu masuk selalu **5 tiles** (capital juga 5 tiles dari pintu masuk ke hitbox city wall). Army masuk dari atas/bawah/kiri/kanan sesuai arah datang.
- Semua dimensi **kotak**.

### Sistem Plot

**Plot = 1 petak wilayah.** 5 level:

| Level | Tipe | Produksi |
|-------|------|----------|
| 1 | Wasteland | **1/jam SEMUA resource** (crop+wood+stone sekaligus) |
| 2 | crop / wood / stone | **4/jam 1 resource spesifik** |
| 3 | crop / wood / stone | **7/jam** 1 resource |
| 4 | crop / wood / stone | **10/jam** 1 resource |
| 5 | crop / wood / stone | **14/jam** 1 resource |

> Sumber: `common/json/land.json` (data in-game, authoritative) — field `cereal`/`timber`/`stone` per level. 4/7/10/14 menggantikan 3/5/7/14 dari narasi playthrough; user konfirmasi 2026-11-13 pilih data in-game.

- **Conquest flow**: army menyerang plot → kalahkan garrison (mis. plot lvl 1 isi boar, beast type, easy win) → serang **bendera 4x** → tile jadi milik → otomatis jadi **Watchtower: HP 40, ATK 12, ATK Range 6** — auto-menyerang pasukan musuh yang menyerang area itu.
- Menghancurkan flag plot unowned / enemy watchtower → territory pindah ke attacker.

### Difficulty Plot

- Semakin jauh plot dari capital → makin sulit; berhenti naik di **12 tiles** (selisih jarak capital–plot).
- 6 tier kesulitan: **Easy → Entry → Common → Advanced → Hard → Hell** (user konfirmasi 2026-11-01: Common ada, muncul di plot lvl 2–3 dekat capital).
- Rentang per plot level (Battle Guide §2.1): lvl 1 = Easy 1→Common 1; lvl 2 = Entry 3→Common 3; lvl 3 = Common 4→Advanced 3; lvl 4 = Advanced 4→Hard 3; lvl 5 = Hard 4→Hell 2.
- Sub-level: Easy 1–3, Entry 1–3, Common 1–4, Advanced 1–4, Hard 1–4, Hell 1–2 = **20 sub-level**.
- **Komposisi garrison (user, tervalidasi 2026-11-01)**: Easy 1–Advanced 2 = beast biasa (jumlah bisa banyak); Advanced 3 = **1 beast Iron Mountain Stance** (guardian, sangat kuat); Advanced 4–Hard 2 = bandit banyak (belum ada Boar Knight); Hard 3 = bandit + **2 Boar Knight**; Hell 1 = bandit + **4 Boar Knight**; Hell 2 = **4 Boar Knight + 1 Soulreaper** (bandit Iron Mountain Stance) — tersulit.

### Reward Points & Chest

- **Reward point**: cap **100**, income **+50/hari**.
- Conquest baru: plot lvl 1–3 = **1 poin**, lvl 4 = **2 poin**, lvl 5 = **3 poin**.
- **Grain Garrison**: tempatkan prajurit di plot **1 jam** → dapat chest **jumlah sama** seperti conquest plot itu (**tanpa Special Chest**, Battle Guide §5.1), biaya **3x** poin conquest (lvl 1–3 = 3; lvl 4 = 6; lvl 5 = 9).
- **Drop chest per difficulty (user)**:

| Difficulty | Chest | Bonus |
|-----------|-------|-------|
| Easy | 100% Wood Chest | — |
| Entry | 75% Wood, 25% Silver | — |
| Advanced | 25% Wood, 50% Silver, 25% Gold | — |
| Hard | 25% Silver, 75% Gold | +50% chance Scroll/Nail |
| Hell | 100% Gold | +100% chance Scroll/Nail |

- EXP Scroll & Iron bisa muncul di **chest mana pun**, jumlah tergantung difficulty plot.
- Chest lain (Battle Guide §5): Wood/Silver/Gold/Special dari plot unowned; **Special Chest** = Nails/Scroll; **Universal Chest** dari merebut enemy capital (dapat walau cuma ikut menyerang).
- Resource-typed plots bias chest: Wood → EXP Scroll, Stone → Iron, Crop → crop.

### Capital Buildings

Semua bangunan max level **mengikuti level capital** (capital 5 → bangunan mentok lvl 5, harus upgrade capital dulu). Max level **20**.

| Bangunan | Unlock | Fungsi |
|----------|--------|--------|
| **Capital** | awal | Dimensi 3x1, posisi paling atas. Panel: building info (deskripsi, info army cap/capacity, upgrade) + admin duty (policy). |
| **Barrack** | awal | Posisi paling bawah. Panel: building info (recruitment time, soldier level cap, upgrade) + recruit soldier. |
| **Clinic** | awal | Pulihkan pasukan yang dikalahkan — rasio persentase menentukan prajurit bisa dibawa kembali atau hilang. |
| **Warehouse** | awal | Capacity **wood + stone**. |
| **Barn** | awal | Capacity **crop**. |
| **Smithy** | lvl 3 | Craft/recast equipment & exclusive. 3 panel: building info (craft time, upgrade), equipment, exclusive. |
| **Embassy** | lvl 3 | Fitur union: join di lvl 1, buat union (jadi leader) di lvl 3. |
| **Drill Ground** | lvl 5 | Train soldier (naik level). Panel: building info (march time, upgrade) + train soldier. |
| **Union Market** | barn lvl 3 + warehouse lvl 3 | Jalur dagang antar anggota union. **+1 merchant per level**; 3 tab: Building Info / Market / Exchange. |
| **Ting System** | lvl 10 | Naikkan level watchtower: **HP +5, ATK +2** per level. |
| **Hall of Heroes** | lvl 10 | Worship hero (bawa hero ke sesi ini). Panel: building info (jumlah worship, upgrade) + worship. |
| **Frontier Garrison** | lvl 15 + city wall lvl 5 | Naikkan level fortress: **HP +10, ATK +1** per level. |

- **Barrack — opsi tipe pasukan**: lvl 1 = spearman + shieldman; lvl 4 + pasukan jarak jauh; lvl 7 + cavalry; lvl 10 = semua pasukan. **4 slot pasukan** terbuka di barrack lvl 1/4/7/10. Stat panel Barrack Lv.8: Soldier Level Cap 3 (konsisten dengan tabel train cap); Recruitment Time -20% → -22% (Lv.8→9).
- **Recruit pertama**: pilih 1 dari 3 pasukan yang ditawarkan (reset bisa di rebuild). Biaya recruit: crop + waktu. Harus **buat army dulu** (nama bebas, mis. Army 1).
- **Recruit** → pasukan langsung muncul sebagai **garrison di salah satu plot dalam capital**; armies bisa dipindah ke plot lain.
- **Army troop capacity**: capital lvl 1–4 = **5 pasukan/army**; dari capital lvl 5 = **9 pasukan** (user konfirmasi 2026-11-01; terkonfirmasi screenshot: Army Capacity 9 di Capital Lv.10).
- **Army cap** (jumlah army): naik ~1 per 2 level — teramati **Lv.10 = 7, Lv.12 = 8** (screenshot Building/); total 12 di Lv.20. Formula persis per level TODO.
- **Clinic (mechanik)**: pasukan yang kalah punya peluang kembali ke Clinic — **Minor Injury 40% (Clinic Lv.1) / 50% (Lv.2–6)**; **Severe Wound 0% (Lv.1) / 30% (Lv.2–6)**. Prajurit severe wound **turun 1 level** saat kembali. Heal queue **6 slot**; Healing Time **-4%/level**.
- Stat Capital menampilkan **Territory** = jumlah plot dikuasai (teramati 51 di Capital Lv.10).

### Biaya Upgrade Bangunan

- Bangunan biasa (teramati screenshot Building/): Embassy Lv.1→2 = **185/185**, Clinic = **189/155**, Drill Ground = **198/162**, Ting System = **226/185**, Warehouse Lv.3→4 = **180/219**, Barn Lv.3→4 = **219/180**, Smithy Lv.7→8 = **527/645**, Barrack Lv.8→9 = **796/652**; skala ke ~**10.000** di lvl 19→20 (estimasi user).
- Capital (lebih mahal): teramati Lv.10→11 = **1184/1184**, waktu **43:40**; estimasi user ~**14.000** di lvl 19→20.
- **City wall upgrade** per level: **+20 HP / +3 ATK** (user konfirmasi 2026-11-01).

### Smithy — Equipment

- **7 slot equipment** terbuka di smithy lvl **1/3/5/7/13/15/19**.
- **Equipment biasa**: pilih 1 dari 3 (reset bisa) → craft **200 wood + 200 stone + 2 iron**; recast (acak ulang atribut + efek) **400 wood + 400 stone + 4 iron** (keputusan user). Tier unlock craft common: smithy 1/3/5/7/12/14 (Policy Recap §2). Tombol **Revert/Recast** saat recast; Craft Time -21% → -24% (Lv.7→8, teramati).
- **Exclusive equipment**: 2 slot — slot 1 di smithy **lvl 10**, slot 2 di **lvl 18**. Pilih pasukan yang dimiliki → pasang exclusive ke pasukan itu. Pilih 1 dari 3 (reset bisa). Craft **800 wood + 800 stone + 12 iron**; recast biaya sama. Exclusive = **2 efek random dari equipment lain** (berubah tiap recast) + **1 efek spesial fixed** untuk sub-type pasukan itu.
- **Recast exclusive dengan lock**: kunci 1 dari 2 efek random (bukan yang smelt) agar tidak ikut berganti — biaya tambahan **1 nail** per recast yang pakai lock.
- **Smelt**: gabungkan efek dari equipment yang dimiliki ke exclusive. 2 slot smelt: exclusive 1 bisa smelt di smithy **lvl 14 & 16**, exclusive 2 di **lvl 18 & 20**. Biaya **2 nail**.

### Drill Ground — Train Soldier

- Soldier level cap: lvl 2 di barrack 1; lvl 3 di barrack 5; lvl 4 di barrack 10; lvl 5 di barrack 15; lvl 6 di barrack 20.
- Biaya upgrade: crop + exp scroll + waktu, berskala **cost coefficient** tiap pasukan (makin tinggi % makin mahal). Paling murah **1 exp scroll** (lvl 1→2), paling mahal **3 exp scroll** (lvl 1→2), begitu seterusnya di level berikutnya.

### Hall of Heroes — Worship

- Hero dimiliki = hasil **3 fragment** disatukan (repair portrait).
- Worship: pilih hero yang bisa dipakai di sesi ini. Hero di-summon ke pasukan dengan **possession sama** (mis. Dian Wei possession Twin Spearman → summon ke pasukan Twin Spearman) dan buff hero itu aktif ke pasukan tsb.
- **Slot worship**: **4 slot, terbuka di hall lvl 1/5/10/20** (keputusan user; teramati 1/10/15/20). Worship tab menampilkan **Expertise Effect** hero yang di-worship.
- **Worship hero → otomatis dapat pasukan possession-nya**: kalau belum punya tipe pasukan itu di Barracks → langsung bisa direkrut; kalau sudah punya → tipe itu bisa dipilih lagi di Barrack.

### Season & Policy

- **4 season**: spring → summer → autumn → winter. Asli: masing-masing **3 hari real-time**. Rebuild: durasi tetap (`REAL_SECONDS_PER_DAY = 86400`), **pause saat game ditutup** — deteksi berbasis gap: ticker tetap jalan, gap wall-clock > 30 detik dianggap waktu tertutup dan tidak dihitung. HUD menampilkan sisa waktu season (`2d 23:59:58`).
- Tiap **season baru → 1 policy random untuk semua pemain** di sesi.
- **Policy capital**: **5 slot** (teramati di Capital Lv.10: 3 aktif + 2 locked; "New Policy unlocks at Lv.15"). Pola unlock kemungkinan di capital **1/5/10/15/20** (3 aktif @ Lv.10 — TODO konfirmasi). Tiap slot: pilih 1 dari 3 opsi (reset bisa di rebuild).
- **Policy union**: 3 slot, terbuka di total embassy union level **1/200/400** (total = jumlah level embassy semua anggota). Leader pilih 1 dari 3, reset bisa.
- **Stacking**: efek policy bisa menumpuk **hingga 3x** (dari policy capital + policy union + policy season).

### Embassy & Union

- Union max **40 player**. Slot anggota = level embassy **leader union** (lvl 20 → 40 slot; lvl 1 → 2; lvl 3 → 6; seterusnya).
- Join union di embassy **lvl 1**; buat union (jadi leader) di embassy **lvl 3**.
- **Union Market**: barter resource antar anggota union. Lvl 1 = **1 merchant** angkut **1000** basic (crop/wood/stone) ATAU **10** special (exp scroll/iron/scroll/nail). Upgrade → merchant bertambah.

### Ground Buildings (dibangun di plot yang dikuasai)

| Bangunan | Efek | Catatan |
|----------|------|---------|
| **Fortress** | Ganti watchtower → **HP 80, ATK 16**; percepat marching capital↔fortress atau fortress↔fortress **3x lebih cepat**; sembuhkan pasukan luka yang masuk plot fortress | Biaya **1550 wood + 1550 stone**, build **33:20**, max **20** (kecuali policy) |
| **Farm** (crop plot) / **Sawmill** (wood plot) / **Quarry** (stone plot) | Produksi plot **x5** nilai awal | Cost **650 wood + 650 stone**, build **31:40**; wasteland tidak bisa membangun; max **5 per kategori** (kecuali policy) |

### Battle Mechanics

- **Turn-based, otomatis oleh sistem**.
- Army masuk plot sendiri/kawan → posisi **disebar** di arah pintu masuk (tidak bertumpuk). Saat **menyerang** → semua pasukan **bertumpuk di 1 tile** pintu masuk army itu. Melee maju sampai menjangkau musuh; ranged menyerang dari posisi tumpuk selama musuh dalam jangkauan, atau bergerak — saat bergerak untuk menyerang, **tidak boleh bertumpuk lagi**.
- **ATK SPD** diatur 1–9: speed **9** = prioritas tertinggi (menyerang & diserang dulu); speed **1** = terakhir. Tapi urutan antar-army selalu berdasarkan **army yang tiba lebih dulu**. (Battle Guide: ATK SPD tinggi = gerak duluan & lebih mungkin jadi target.)
- **Urutan turn** (Battle Guide §4.1): Turn 1 = group yang masuk pertama menyerang, lalu musuh. Turn 2 = group 2–5 urutan masuk, lalu group 1 lagi di akhir, lalu musuh. Contoh user: army 1 → musuh → army 2 → army 1 → musuh → …
- Musuh maju sampai dalam jangkauan tile masuk kita → semua pasukan kita **menyerang di tempat, tidak bergerak**, walau seluruh army bertumpuk 1 tile (Battle Guide §4.2).
- Army bisa dipindah ke plot sendiri, plot kawan (satu union), atau **menyerang plot yang terhubung bersebelahan** dengan plot sendiri/kawan. Multiple armies bisa conquere 1 land bersamaan (naikkan survival) atau beberapa land terpisah (naikkan efisiensi).
- **Rage**: didapat dengan menyerang **dan** diserang; skill jalan saat rage penuh, lalu reset 0.
- Nama passive counter per unit (screenshot troop gallery): Longspearman = **Counter Cavalry**, Saber&Shield = **Counter Bowman**, Longbowman = **Counter Spearman**, Sword Cavalry = **Counter Shield Soldier**.

### Strategi Tempur User (data autentik — blueprint desain bot)

- **One Tile Army** (nama strategi user): army masuk berurutan ke 1 pintu masuk — ranged dulu, lalu tank, lalu damage. Saat pasukan terperangkap di 1 tile dan musuh terus datang menutup, semua pasukan sendiri menyerang di tempat; musuh memukul **satu per satu** (hanya 1 army kena serangan dalam satu waktu) → korban minimum, plot bisa dikuasai.
- Musuh menyerang target dengan **ATK SPD tertinggi dulu** → army shieldman dipakai jadi **"sacrifice army"** (umpan).
- Spearman jadi damage utama vs Boar Knight: Boar Knight punya **Fortitude** (ranged DMG taken −60%) dan hanya counter Shieldman, bukan Spearman.
- Urutan serang musuh teramati: Minion → Bandit Saberman → Bandit Bowman → Boar Knight (satu per satu).
- **Stack farming**: Sword & Shield yang mengeliminasi Boar Knight dapat 1 stack Leap: ATK +0.5, HP +5 (SoldierAttribute.md, authoritative), stackable hingga **100** tergantung level pasukan.
- **Combo hero farm Hard 3/Hell 1**:
  - Army ranged (biasanya **Hunter**) masuk paling awal.
  - **Chen Dao** (Longspearman) = tank: transfer [40-80]% ATK DMG yang diterima ke pasukan dengan HP % tertinggi; pasang **Mirror Armor** (makin diserang makin kuat DMG Reduction).
  - 8 pasukan Sword & Shield lain: item regen HP (**Wine Gourd / Helmet of Calmness**) atau lebih baik exclusive equipment mereka sendiri (Guardian Sword: tiap kena DMG di luar giliran → DMG serangan berikut +3%).
  - **Cao Cao** (Sword & Shield) = buffer: tiap menyerang beri layer Morale ke allies dalam 3 tiles (Max HP +10, ATK +1 per layer); pasang item damage.
  - Hasil: **Hard 3 & Hell 1 mudah ditaklukkan**, stack cepat.
- **Pertahanan wilayah union**: kirim army lewat **fortress dulu** (marching lebih cepat), lalu bantu kawan. Masuk dari **sisi berbeda dari musuh** (mis. musuh dari kiri, kita masuk lewat atas) → menghabisi musuh satu per satu; kalau musuh pakai one-tile strategy, serangan kita mengenai banyak musuh yang menumpuk sekaligus.

## Hero System (dari cerita playthrough user + docs)

- General Muster Terrace: spin → dapat **fragment hero** (mis. Dian Wei 3 fragment). Asli: 5 spin = 598 coin.
- **Repair portrait** dengan fragment → dapat hero. Level awal rendah → atribut & nilai skill `[a-b]` roll kecil.
- **Redraw** pakai jumlah fragment **sama dengan repair** (3 fragment untuk hero 3-fragment) → reroll atribut, skill, expertise. Repair & redraw cost 3 fragment terkonfirmasi screenshot.
- **Reroll expertise hanya menghasilkan expertise dengan rarity yang sama** (verbatim screenshot hero).
- Redraw punya **10% chance** langsung dapat tier **Chosen**.
- Redraw terus → **tier naik** (7 tier: Level 1 → … → **Chosen** max, ~100 redraw).
- Tier **Chosen**: atribut & skill hero **pasti roll maksimum**; bisa **pilih manual** 1 common + 1 uncommon + 2 rare expertise.
- Tier bawah: slot expertise dapat dari roll (1 common + 1 uncommon + 1 rare dari level 1; +1 slot ekstra di Chosen).
- Stacking expertise: common 3x, uncommon 2x, rare tidak stackable. Pool per hero = category + sub-type unique + hero's own unique rare.
- Hero possession = 1 dari 24 sub-type troop; summon juga unlock troop tsb di Barracks.
- **1 hero per army** — hero hanya bisa di-summon ke 1 pasukan dalam 1 army (contoh: Dian Wei & Wen Yang wajib di 2 army terpisah).

## Sistem Resource

- **Biasa** (diproduksi/jam): `crop`, `wood`, `stone` — dari plot yang dikuasai (lihat tabel plot di § Data Absolut) + farm/sawmill/quarry (x5) + palace + modifier musim. 4 musim x 3 hari real-time, pause saat close.
- **Khusus** (chest-only, tidak diproduksi): `iron`, `exp_scroll`, `scroll`, `nail` — hanya dari Award Chest tiap conquest menang atau merebut capital musuh. Wood plots → EXP Scroll, Stone plots → Iron, Crop plots → crop.
- **Kapasitas**: tanpa barn/warehouse → max **1000**; dengan barn (crop) & warehouse (wood+stone) → **3000**; tiap upgrade bangunan **+1700 capacity** (teramati Warehouse Lv.3→4 = 5700→7400).

## Status Pengerjaan UI (task list — sinkron 2026-11-15)

Referensi desain: folder `Main UI/` (screenshot 1080×2400, nama = tampilan). Modal panel ada di `nta_demo/lib/game/ui/panels/`, wiring di `nta_demo/lib/main.dart`. Semua panel pakai design-token `design_tokens.dart` (`ntaPanel()`, `NtaText`, `NtaColors`, `NtaRadius`, `NtaBorder`, `NtaResIcon`). Pola modal: `static Future<void> show(BuildContext)` → `showDialog` + `ChangeNotifierProvider.value(value: context.read<GameState>())`.

### Cara kerja umum tiap task UI (baca dulu)
1. Buka screenshot ref di `Main UI/<nama>.jpg`, identifikasi: judul, tab/toggle, list/grid, tombol aksi, HUD counter.
2. Cek data pendukung di `game/models/game_state.dart` (getter yang sudah ada) + `data/game_data.dart` (konstanta). Kalau butuh field baru → tambah ke `GameState` dengan pola `notifyListeners()`.
3. Tulis panel di `lib/game/ui/panels/<nama>_panel.dart` pakai token; reuse ikon asli (`NtaAssets.heroPortrait`, `NtaResIcon`, `season`).
4. Wiring di `main.dart` (ganti `showStubPanel(...)` → `XxxPanel.show(context)`).
5. `cd nta_demo && flutter analyze lib` → harus "No issues found!".
6. `flutter build web --profile -o build/web_prof`, cek mtime `main.dart.js` maju.
7. Verifikasi screenshot via harness `_drive.py` (port 9441, static server 8899), bandingkan dgn ref. Simpan di `_shots/p_<nama>.png`.

---

### Selesai (sudah dibangun + diverifikasi)
- **#28** Harness web + Edge CDP (`_drive.py`) jalan — `boot/shoot/click/drag/wheel/js/kill`, viewport 504×860.
- **#31** Redesign map-view capital & plot sprite (sprite asli `city_1001`; checkerboard wild `#7BAF81`/`#80B486`, owned `#8FC17A`/`#91C078`, outline `#3C854D`).
- **#32** Tile action panel map gaya asli (4 tombol vertikal: Enter/Grain Garrison/Build/March) saat tile dikuasai diklik.
- **#33** Modal Armies 3 tab (All Armies / Territory / Battle Report) — verified.
- **#47** Right icon rail (map kanan atas) — verified.
- **#39** Modal Map (minimap overview) — verified (`_shots/p_mapoverview.png`). Arahan bila revisi: legend, `_MiniMapPainter` 80×80, InteractiveViewer, chip koordinat X/Y, tombol View untuk lompat ke posisi.
- **#41** Modal Profil (Personal Info/Add/Battle Info) — verified layout (`_shots/p_profile.png`). Arahan bila revisi: tab Personal Info (Commander + UID + class + win pts + ranked battles + reaction count), tab Add (cari teman by UID), tab Battle Info (statistik tempur); avatar hero pakai `portrayal_*` topCenter.
- **#34** Battle Rankings (`battle_rankings_panel.dart`) — verified (`_shots/p_rankings.png`). Buka: rail `help_outline` (467,232) atau gold `emoji_events`. Avatar pakai portrait valid, poin + league tampil.
- **#35** Chat (`chat_panel.dart`) — verified (`_shots/p_chat2.png`). Buka: tombol chat kiri bawah. World/Alles/Private + Union/Team toggle, counter 39/40, pesan seed + avatar, input bar.
- **#36** Construction Queue (`construction_queue_panel.dart`) — verified (`_shots/p_constrq2.png`). Buka: chip `home_repair_service "13:05"` (459,468). Item + progress + ETA + Quick Complete.
- **#40** March List (`march_list_panel.dart`) — verified (`_shots/p_marchlist.png`). Buka: chip `hourglass_bottom "120:35"` (460,500). Baris march + ETA + tombol cancel.
- **#44** Output Overview (`output_overview_panel.dart`) — verified (`_shots/p_output2.png`). Buka: tap pill crop/wood/stone top-left (50,25). Tabel plot per level, baris stat, tab Crop/Wood/Stone, "Current Resources/Capacity".
- **#45** Season Detail (`season_detail_panel.dart`) — verified (`_shots/p_season2.png`). Buka: lingkaran red `card_giftcard` rail (467,362). Ikon musim, 4 tile, mystic remains, victory rules, Server Activeness/Time.
- **#46** Special Resource Info (`special_resource_panel.dart`) — verified (`_shots/p_special2.png`). Buka: tap mini pill special (25,137). 4 baris EXP Scroll/Iron/Scroll/Nail + deskripsi + count.
- **#37** General Muster Terrace fullscreen (`general_muster_panel.dart`) — verified (`_shots/p_muster.png`, `p_muster_result.png`). Buka: rail `workspace_premium` emas (467,420) atau tombol Muster di Heroes List. Drum + counter `n/50` + banner guaranteed + 3 tombol Free + skip checkbox + grid hasil fragment + tap fragment → repair dialog. **Semua muster GRATIS** (anti-coin).
- **#38** Heroes List modal (`heroes_list_panel.dart`) — verified (`_shots/p_heroeslist.png`). Buka: rail `person` (467,198). 3 tab (Hero Portrait/Skin/Socialization), sort dropdown + ALL(n/59), grid 3 kolom dengan frame tier (gold Chosen/purple/blue), badge fragment + tier, footer Exchange + Muster.
- **#42** Shop modal (`shop_panel.dart`) — verified (`_shots/p_shop.png`). Buka: tombol Shop bawah (325,717). Rail kategori (Limited-Time/Value/Top-up/Skin Mall/Exclusive), Daily/Weekly tabs, kartu diskon + tombol **Free**, Daily Gift claim. Top-up = "Not available in offline build".
- **#43** Lucky Wheel (`lucky_wheel_panel.dart`) — verified (`_shots/p_wheel2.png`, `p_wheel_spin2.png`). Buka: thumb prajurit pojok kanan bawah (461,714). 12 slot wheel (`_WheelPainter`), spin animasi 5 putaran, "Unlimited" chances, reward masuk `GameState.grantWheelReward`. Catatan: label segmen **text-only** — `WidgetSpan(Icon)` di dalam `CustomPainter` bikin painter abort.

### Belum dibangun (masih showStubPanel)
(tidak ada — semua panel sudah dibangun + diverifikasi 2026-11-15)

### Verifikasi & QA

- **#48** Screenshot-verify tiap panel via Edge CDP vs `Main UI/*.jpg` — **SELESAI 2026-11-15**: semua panel (#34–#46, #37/#38/#42/#43) sudah di-screenshot & dicocokkan dgn ref (`_shots/p_*.png`).
  - **Langkah**: `cd nta_demo/build/web_prof && python -m http.server 8899` → `python _drive.py boot` → per panel: `python _drive.py click X Y` lalu `python _drive.py shot p_<nama>` (panggil click lalu shot terpisah; jangan andalkan arg wait di `click`). Viewport 504×860.
  - **Koordinat klik terverifikasi**: rail=heroes(467,198)/rankings(467,232)/profile(467,270)/season(467,362)/armies(467,584); rail chips constrq(459,468)/march(460,500); rail gold-spin=wheel asc? **(461,714 = thumb prajurit → Lucky Wheel)**; HUD crop pill(50,25)/special pill(25,137); bawah: chat kiri(40,650 di capital / 40,693 di map), Shop(325,717), Armies-swap; Heroes List footer Muster(364,694); Muster*1(84,556); back muster(39,722).
- **#29** Season timer pause saat close — **SELESAI 2026-11-15**.
  - **Semantik terverifikasi**: `_elapsedSeconds` hanya menghitung *active playtime*. Close 60s → elapsed tidak berubah (15577→15607 cuma autosave pra-kill, bukan closed time). Gap guard `_closedGapSeconds=30` di `_onTick()` self-heal walau lifecycle event tidak datang; `pauseClock()`/`resumeClock()` dipanggil dari `WidgetsBindingObserver` (`main.dart:321`).
  - **Catatan harness**: headless Edge men-throttle `Timer.periodic` (~30s/menit) walau `document.visibilityState=visible` + flag `--disable-background-timer-throttling`. Ini artefak harness (tab headless tanpa fokus), **bukan bug produk** — tab/device asli tick 1s. Sudah tambah flag anti-throttle di `_drive.py` (sebagian menolong, tidak penuh di headless).
- **#30** Combat testing exhaustif — **SELESAI 2026-11-15** (`test/combat_engine_test.dart`, 26 tes lulus).
  - **Diverifikasi via sim langsung `BattleEngine`**: type-triangle (Spear>Cavalry>Shield>Bow>Spear; ×1.4 counter / ×0.6 reverse), urutan aksi (grup attacker dulu tiap ronde walau SPD musuh lebih tinggi), rage (isi saat menyerang/diserang, reset 0 saat cast skill), passive DR (Fortitude 10301 ranged ×0.4, Scale Armor 10601 ×0.6), reflect Hedgehog 10501 (35%), eskalasi kesulitan (Hell≫Easy, distance→hard, Hell2 = Soulreaper + 4 Boar Knight, label Easy1/Hell1).
  - **2 bug diperbaiki di `battle_engine.dart`**: (1) **Iron Mountain Stance (12001)** guardian sebelumnya **tidak dimodelkan** → guardian kena DMG penuh, Hell jadi sepele; kini +70% DR saat diserang + attacker 12001 menembus 70% DR target. (2) **Counter pasif terbalik**: target ber-`Counter Shield` (Boar Knight 10104) kini memotong ATK Shieldman penyerang ×0.6.
  - **Stack Leap Trainee Warrior (11401-6)** — SELESAI 2026-11-15: tiap Boar Knight (enemy 4205) mati = +1 stack, +0.5 ATK / +5 HP per prajurit Sword&Shield (3205). Cap 10→100 mengikuti level drill (`10+(lv-1)*18`). Field `_leapStacks` di GameState, disimpan di save (`leapStacks`), diterapkan di `BattleEngine.buildPlayerUnits(leapStacks:)`, gain di `_gainLeapStacks` dari `attackPlot`/`attackRemains` via `_boarKnightKills` (defenderLosses uid→id). Tes: 4 di `combat_engine_test.dart` (20 lulus).
  - **Enemy active skills (§3.1)** — SELESAI 2026-11-15: 16 families dimodelkan (Wolf Howl buff, Elephant Sling 200%, Bear Smash 5% Max HP true DMG + stun, Lion Tear 120% ATK + bleed, Viper Venom Spit poison 10% cur HP, Rhino Trample AoE stun, dsb). Diwire ke `_act()` + `_tickStatuses()` end-of-round. Tes: 6 di `combat_engine_test.dart` (26 total lulus).
  - **Clinic recovery** — SELESAI 2026-11-15: `_applyCasualties` formula (wounded = round(lost × 0.55 menang / ×0.50 kalah)) dikunci 4 tes di group `clinic recovery (§Clinic)` yang memanggil `GameState.clinicWounded()` + `clinicWoundedRate()` (29 total lulus). Helper static diekstrak supaya testable tanpa instance GameState.
- **Save codec** — SELESAI 2026-11-15: `test/save_codec_test.dart` (11 tes) mengunci round-trip semua field + loader toleran legacy: string-number coercion, drop troop/equip id invalid, exclusiveEquipment normalisasi (string legacy di-skip, effects/smelt difilter, locked int), portrait grade clamp 0..7, battleReports DateTime round-trip, worshippedHeroes hanya yang punya portrait, troopLevels clamp 1..6, leapStacks clamp ke cap. Suite total: 41 tes lulus (29 combat + 11 codec + 1 plot widget).
  - **TIER_POINTS_PER_PLOT_LEVEL** — SELESAI 2026-11-15: user-confirmed curve plot Lv.1=2, Lv.2=4, Lv.3=6, Lv.4=8, Lv.5=10 → `TIER_POINTS_PER_PLOT_LEVEL = 2` (linear 2× plot level). Dipakai di `attackPlot` conquest ranked.
  - **Army cap formula** — SUDAH DATA ASLI: `BUILD_LADDER[2001]` effect 11 Lv1=2, Lv10=7, Lv12=8, Lv20=12 (cocok screenshot).
  - **Policy capital unlock pattern** — SUDAH DATA ASLI: `POLICY_SLOT_LEVELS = [1, 5, 10, 15, 20]` → Lv.10 = 3 slot (1,5,10), unlock baru Lv.15.

### Catatan teknis
- **Avatar hero fix (2026-11-15)**: `avatar_pawn_*.png` hasil ekstrak **korup** (bar kuning 40×80 / silhouette putih). `NtaAssets.heroAvatar()` sekarang menunjuk `portrayal_<id>.png` (ilustrasi valid, 63 file). Caller (profil/battle_rankings/chat) pakai `BoxFit.cover` + `alignment: Alignment.topCenter`.
- **`NtaAssets.heroPortrait(id)`** = `portrayal_<id>.png`; **`heroAvatar(id)`** kini juga `portrayal_<id>.png` (dulu `avatar_pawn_*_01.png`).
- **`NtaAssets.heroAvatar(id)`** dipakai di 3 panel + `heroPortrait` di `capital_interior_view.dart`, `game_tabs.dart`.

## Konvensi

- Data numerik game (HP, ATK, drop, difficulty) harus mengikuti sumber authoritative di atas — jangan mengarang angka. Kalau belum ada data, tandai TODO.
- Item bertanda (konfirmasi) = data user bentrok dengan docs → konfirmasi ke user sebelum dipakai.
- File besar (APK, video, frida-server, logcat) di-exclude dari git — lihat README.
- Bahasa komunikasi dengan user: Indonesia.
