# Network Traffic Capture Guide - Ninety Thousand Acres

**Target Server:** nine-hk.twomiles.cn:3653
**Protocol:** mqant (custom protocol over TCP)
**PC IP:** 192.168.1.2

---

## Setup mitmproxy

### Step 1: Start mitmproxy on PC

```powershell
# Start mitmproxy in transparent mode
mitmproxy --mode transparent --showhost --set block_global=false
```

**Atau gunakan mitmweb (web interface):**
```powershell
mitmweb --web-host 0.0.0.0 --web-port 8081
```

Ini akan start proxy di:
- **Proxy:** 192.168.1.2:8080
- **Web UI:** http://192.168.1.2:8081

---

## Step 2: Configure Android Device

### A. Set WiFi Proxy

1. **Buka Settings** di Android
2. **WiFi** → Long press network yang connected
3. **Modify Network** atau **Advanced Options**
4. **Proxy:** Manual
5. **Hostname:** `192.168.1.2`
6. **Port:** `8080`
7. **Save**

### B. Install mitmproxy Certificate

**Di PC, generate cert:**
```powershell
# Check if cert exists
Get-ChildItem "$env:USERPROFILE\.mitmproxy"
```

**Download cert ke Android:**
1. Buka browser di Android
2. Go to: `http://mitm.it`
3. Tap **Android** → Download certificate
4. Install certificate:
   - Settings → Security → Install from storage
   - Select downloaded cert
   - Name: "mitmproxy"
   - For: VPN and apps

---

## Step 3: Capture Traffic

**Start mitmproxy di PC:**
```powershell
# With save to file
mitmweb --web-host 0.0.0.0 --set hardump=D:\Android\NTA Project Reverse Engineering\traffic_dump.mitm
```

**Di Android:**
1. Buka game di Parallel Space
2. Login dan main 5-10 menit
3. Lakukan berbagai action

**Di PC mitmweb (http://192.168.1.2:8081):**
- Lihat real-time requests
- Filter: "nine-hk.twomiles.cn"
- Inspect request/response bodies

---

## Important Notes

### HTTPS/TLS Interception

Jika game uses certificate pinning:
- mitmproxy akan gagal intercept
- Akan muncul SSL errors
- Perlu APK patching (advanced)

### Custom Protocol (mqant)

Port 3653 bukan HTTP:
- Ini TCP socket langsung
- mitmproxy hanya capture HTTP/HTTPS
- Perlu Wireshark untuk raw TCP

---

## Alternative: Wireshark Capture (For mqant Protocol)

### Setup Wireshark on Android (Requires Root)

**Atau capture di PC dengan ADB forwarding:**

```powershell
# Forward device traffic to PC
adb -s 192.168.1.3:34251 reverse tcp:3653 tcp:3653

# Then use Wireshark on PC
# Filter: tcp.port == 3653
```

**Capture raw packets:**
```powershell
# On PC with Wireshark installed
# Interface: Wi-Fi
# Filter: ip.addr == [device IP] and tcp.port == 3653
```

---

## Expected Outputs

### HTTP/HTTPS Capture (mitmproxy):
- Firebase Analytics requests
- AppsFlyer tracking
- Facebook SDK calls
- Google Play Services
- ThinkingData analytics

### Raw TCP Capture (Wireshark):
- **mqant protocol** to nine-hk.twomiles.cn:3653
- **Protobuf messages** (binary)
- Game state updates
- Battle commands
- Chat messages
- Union data

---

## Next Steps After Capture

### 1. Analyze HTTP Traffic
```powershell
# Export from mitmweb
# File → Export → HAR format
```

### 2. Decode Protobuf Messages

Need msg.jsc definitions (still encrypted), BUT:
- Can extract raw protobuf bytes
- Use protobuf inspector tools
- Reverse engineer message structure

### 3. Replay Attacks

Test server behavior:
- Replay captured requests
- Modify parameters
- Test validation

---

## Troubleshooting

### Certificate Not Trusted
- Install as "User certificate"
- Some apps require "System certificate" (needs root)

### Connection Refused
- Check PC firewall
- Verify PC and phone on same WiFi
- Test: `ping 192.168.1.2` from Android

### No Traffic Captured
- App uses certificate pinning → Need APK patching
- App uses custom protocol → Need Wireshark

### SSL Errors in Game
- Certificate pinning detected
- Options:
  1. Patch APK to disable pinning
  2. Use Frida (blocked by anti-cheat)
  3. Capture raw TCP instead

---

**Start dengan mitmproxy dulu untuk HTTP traffic, lalu Wireshark untuk mqant protocol.**
