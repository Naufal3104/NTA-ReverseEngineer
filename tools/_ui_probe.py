import json, os, subprocess, sys, time
import urllib.request
from websocket import create_connection

ROOT = r"D:\Android\NTA Project Reverse Engineering"
OUT = os.path.join(ROOT, "_shots")
PROFILE = os.path.join(ROOT, "_edgeprof_test")
URL = "http://127.0.0.1:8899/"
PORT_DBG = 9441
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

os.makedirs(OUT, exist_ok=True)
edge = subprocess.Popen(
    [EDGE, "--headless=new", "--disable-gpu", "--no-first-run",
     "--disable-extensions", "--disable-component-extensions-with-background-pages",
     "--remote-debugging-port=%d" % PORT_DBG,
     "--user-data-dir=%s" % PROFILE, "--window-size=504,860", "about:blank"],
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

targets = None
for _ in range(40):
    try:
        targets = json.load(urllib.request.urlopen("http://127.0.0.1:%d/json" % PORT_DBG))
        break
    except Exception:
        time.sleep(1)
if targets is None:
    print("CDP down"); edge.terminate(); sys.exit(2)

ws = create_connection([t for t in targets if t["type"] == "page"][0]["webSocketDebuggerUrl"], timeout=180)
_id = [0]
logs = []

def send(method, params=None):
    _id[0] += 1
    ws.send(json.dumps({"id": _id[0], "method": method, "params": params or {}}))
    while True:
        msg = json.loads(ws.recv())
        if msg.get("id") == _id[0]:
            return msg
        if msg.get("method") in ("Runtime.consoleAPICalled", "Runtime.exceptionThrown"):
            logs.append(msg)

def ev(expr):
    r = send("Runtime.evaluate", {"expression": expr, "returnByValue": True, "awaitPromise": True})
    res = r.get("result", {})
    if res.get("exceptionDetails"):
        return {"__error__": json.dumps(res["exceptionDetails"])[:300]}
    return res.get("result", {}).get("value")

def shot(name):
    r = send("Page.captureScreenshot", {"format": "png"})
    data = r.get("result", {}).get("data")
    if not data:
        print("shot fail", name); return 0
    raw = __import__("base64").b64decode(data)
    p = os.path.join(OUT, name + ".png")
    open(p, "wb").write(raw)
    print("shot", name, len(raw), "bytes")
    return len(raw)

def click(x, y, w=1.2):
    for t in ("mouseMoved",):
        send("Input.dispatchMouseEvent", {"type": t, "x": x, "y": y})
    send("Input.dispatchMouseEvent", {"type": "mousePressed", "x": x, "y": y, "button": "left", "clickCount": 1})
    time.sleep(0.08)
    send("Input.dispatchMouseEvent", {"type": "mouseReleased", "x": x, "y": y, "button": "left", "clickCount": 1})
    time.sleep(w)

def wheel(x, y, dy):
    send("Input.dispatchMouseEvent", {"type": "mouseWheel", "x": x, "y": y, "deltaX": 0, "deltaY": dy})
    time.sleep(0.4)

def save():
    raw = ev("localStorage.getItem('flutter.nta_save_state_v2')")
    if not raw:
        return None
    try:
        return json.loads(json.loads(raw))
    except Exception:
        return {"__raw__": raw[:200]}

def log(msg):
    print("::", msg)

send("Page.enable"); send("Runtime.enable"); send("Log.enable")
send("Emulation.setDeviceMetricsOverride", {"width": 504, "height": 860, "deviceScaleFactor": 1, "mobile": False})
send("Page.navigate", {"url": URL})
# DDC debug build compiles ~575 modules on first load; wait for the Flutter
# view to report a real size instead of a fixed sleep.
t0 = time.time()
while time.time() - t0 < 180:
    time.sleep(3)
    probe = ev("(function(){var f=document.querySelector('flt-glass-pane')||document.querySelector('flutter-view');"
               "if(!f)return 0;var c=document.querySelector('canvas');return c?c.width:0;})()")
    canvas_w = probe if isinstance(probe, int) else 0
    if canvas_w > 100:
        print("canvas ready after %.0fs (w=%d)" % (time.time()-t0, canvas_w))
        break
else:
    print("canvas never ready")
time.sleep(4)

print("viewport:", ev("[window.innerWidth, window.innerHeight, window.devicePixelRatio]"))
shot("01_lobby")

results = {}
s = save()
results["lobby_view"] = s and s.get("currentView") if s else "no save"
log("after boot save=%s" % ("yes" if s else "none"))

# --- pick Newbie division (gold "Pilih" button on first card) ---
click(435, 243, 2.0)
s = save()
results["division_chosen"] = s.get("divisionChosen") if s else None
results["division_index"] = s.get("divisionIndex") if s else None
results["view_after_pick"] = s.get("currentView") if s else None
shot("02_map")

ws.close()
edge.terminate()

print("\n=== SUMMARY ===")
for k, v in results.items():
    print("%-24s %s" % (k, v))
print("errors logged:", len(logs))
for m in logs[:5]:
    print(json.dumps(m)[:300])
