# NTA-ReverseEngineer

Reverse engineering + rebuild demo game **Ninety Thousand Acres** (`twgame.global.acers`, v4.5.0).
Target: pahami sistem game (map, resource, building, battle, gacha/hero) lalu rebuild playable demo.

## Isi Repo

| Path | Keterangan |
|------|------------|
| `nta_demo/` | **Flutter demo rebuild** — world map 80×80, capital interior 17×17, plot interior, sistem resource, battle sim. Jalankan: `cd nta_demo && flutter pub get && flutter run` |
| `NTAGame/` | Proyek Android native (`MainActivity.kt`, `MapView.kt`) |
| `game-demo/` | Prototipe web/JS (battle, map, UI debug) |
| `*.md` | Dokumentasi: `Battle Guide and Plot Recap`, `Policy and Equipment Recap`, `Hero Skill and Expertise`, `SoldierAttribute`, `DOCUMENTATION`, `REBUILD_GUIDE`, `REVERSE_ENGINEERING_STATUS`, `GameGuardian_Guide`, `CAPTURE_INSTRUCTIONS`, `NETWORK_CAPTURE_GUIDE` |
| `ocr_*.txt`, `cocos_scenes.txt`, `gallery*.txt` | Hasil ekstraksi OCR & scene Cocos |
| `game_packets*.pcap`, `captured_flows.json`, `network_urls.txt` | Hasil network capture |
| `game_screen*.png`, `map_*.png`, `screenshot*.png` | Screenshot referensi kecil |
| `frida_hook_xxtea.js`, `frida_simple.js`, `gen_data.py`, `ocr_extract.py` | Script bantu RE |

## Sistem Resource (`nta_demo`)

Dua tipe:

- **Biasa** — `crop`, `wood`, `stone`. Diproduksi per jam berdasarkan jumlah + level plot yang dikuasai (farm/sawmill/quarry, palace, musim). Juga didapat via chest.
- **Khusus** — `iron`, `exp_scroll`, `scroll`, `nail`. **Tidak bisa diproduksi**, hanya dari **Award Chest** tiap conquest menang. Basics skala dengan level plot, specials roll peluang (makin tinggi level makin besar chance). Tidak bisa di-trade di Market, tidak ada cap warehouse.

## Artefak yang Di-exclude

File besar tidak ikut push (lihat `.gitignore`): APK/XAPK (±190MB), video rekaman (±440MB),
`frida-server`, `game_logcat.txt` (87MB), folder `build/`, `.gradle/`, `.dart_tool/`,
hasil ekstrak APK, dan dump screenshot mentah (OCR-nya tetap ada di `ocr_*.txt`).
Butuh file asli? Ekstrak ulang dari `NINETY+THOUSAND+ACRES_4.5.0_APKPure.xapk` (sumber instalasi, tidak ikut push).

## Catatan

Repo riset/rebuild untuk pembelajaran. Aset game milik developer asli.
