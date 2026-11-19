# QUICK START - Network Capture Instructions

**STATUS:** mitmweb RUNNING on PC
**Web UI:** http://192.168.1.2:8081 (should be open in browser)
**Proxy:** 192.168.1.2:8080

---

## INSTRUKSI UNTUK ANDA (5 menit setup)

### Step 1: Configure Android WiFi Proxy

**Di HP Android:**

1. **Buka Settings** → **WiFi**
2. **Long press** network yang connected (network yang sama dengan PC)
3. **Pilih "Modify network"** atau **"Advanced options"**
4. **Proxy:** Pilih **"Manual"**
5. **Proxy hostname:** `192.168.1.2`
6. **Proxy port:** `8080`
7. **Save/Connect**

### Step 2: Install mitmproxy Certificate

**Di HP, buka browser (Chrome/Firefox):**

1. Go to: **`http://mitm.it`**
2. Akan muncul halaman mitmproxy certificate
3. Tap **"Get mitmproxy-ca-cert.cer"** untuk Android
4. Download certificate
5. **Install certificate:**
   - Settings → Security → Encryption & credentials
   - Install from storage/Install a certificate
   - Pilih file yang didownload
   - Name: "mitmproxy" 
   - Use for: VPN and apps
6. Confirm dengan PIN/password

### Step 3: Test Connection

**Buka browser di HP:**
- Go to: `https://www.google.com`
- Jika berhasil → proxy working!
- Check PC browser (http://192.168.1.2:8081) → akan muncul requests

### Step 4: Capture Game Traffic

**Di HP:**
1. **Buka game** di Parallel Space
2. **Login dan main 10-15 menit**
3. Lakukan banyak action:
   - Build/upgrade
   - Recruit troops
   - Battle
   - Union activities
   - Chat
   - Shop
   - Map exploration

**Di PC browser (mitmweb):**
- Lihat real-time traffic
- Filter untuk game-related requests
- Semua akan auto-saved ke `traffic_http.mitm`

### Step 5: Setelah Selesai

**Bilang saya: "capture selesai"**

Saya akan:
- Stop mitmproxy
- Export captured traffic
- Analyze requests/responses
- Extract API endpoints
- Decode protobuf messages (jika ada)

---

## ⚠️ Troubleshooting

### "Cannot connect to internet" setelah set proxy
- **Cek:** PC firewall might be blocking
- **Fix:** Windows Defender Firewall → Allow mitmproxy

### Certificate install gagal
- **Try:** Settings → Security → Install from storage
- **Select:** CA certificate (not user certificate)

### Game tidak connect / "Network error"
**Kemungkinan:** Certificate pinning
- Game reject mitmproxy certificate
- Ini normal untuk protected games
- Kita masih bisa capture **non-game traffic** (Firebase, Analytics)

### No traffic muncul di mitmweb
- **Cek proxy settings** di WiFi (192.168.1.2:8080)
- **Restart browser** di HP
- **Test dengan** https://www.google.com dulu

---

## What We'll Capture

**HTTP/HTTPS Traffic:**
- ✅ Firebase Analytics
- ✅ AppsFlyer tracking  
- ✅ Facebook SDK calls
- ✅ ThinkingData events
- ✅ Google Play Services
- ⚠️ Game API (if not pinned)

**Note:** Main game protocol (mqant:3653) won't be captured by mitmproxy karena bukan HTTP. Tapi kita dapat banyak data dari analytics/SDKs.

---

**MULAI SEKARANG:**
1. Set proxy di WiFi → 192.168.1.2:8080
2. Browser → mitm.it → Install cert
3. Main game 10-15 menit
4. Bilang "capture selesai"

GO! 🚀
