"""Interactive CDP driver for the NTA demo.

Usage:
  python _drive.py boot                 # launch Edge + load game
  python _drive.py shot NAME            # screenshot to _shots/NAME.png
  python _drive.py click X Y [WAIT]     # left click at CSS px
  python _drive.py drag X1 Y1 X2 Y2 [W] # drag (map pan)
  python _drive.py wheel X Y DY         # wheel (zoom, or scroll a list)
  python _drive.py save                 # print save summary
  python _drive.py js EXPR              # evaluate JS, print result
  python _drive.py kill                 # close the browser
"""
import base64, json, os, subprocess, sys, time
import urllib.request
from websocket import create_connection

ROOT = r"D:\Android\NTA Project Reverse Engineering"
OUT = os.path.join(ROOT, "_shots")
PROFILE = os.path.join(ROOT, "_edgeprof_test")
URL = "http://127.0.0.1:8899/"
PORT_DBG = 9441
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
STATE = os.path.join(ROOT, "_drive_state.json")

os.makedirs(OUT, exist_ok=True)


def edge_running():
    try:
        json.load(urllib.request.urlopen("http://127.0.0.1:%d/json" % PORT_DBG, timeout=2))
        return True
    except Exception:
        return False


def attach():
    targets = json.load(urllib.request.urlopen("http://127.0.0.1:%d/json" % PORT_DBG))
    page = [t for t in targets if t["type"] == "page"][0]
    return create_connection(page["webSocketDebuggerUrl"], timeout=180)


class Drv:
    def __init__(self, ws):
        self.ws = ws
        self._id = 0
        self.logs = []

    def send(self, method, params=None):
        self._id += 1
        self.ws.send(json.dumps({"id": self._id, "method": method, "params": params or {}}))
        while True:
            msg = json.loads(self.ws.recv())
            if msg.get("id") == self._id:
                return msg
            if msg.get("method") in ("Runtime.consoleAPICalled", "Runtime.exceptionThrown"):
                self.logs.append(msg)

    def ev(self, expr):
        r = self.send("Runtime.evaluate",
                      {"expression": expr, "returnByValue": True, "awaitPromise": True})
        res = r.get("result", {})
        if res.get("exceptionDetails"):
            return {"__error__": json.dumps(res["exceptionDetails"])[:400]}
        return res.get("result", {}).get("value")

    def shot(self, name):
        r = self.send("Page.captureScreenshot", {"format": "png"})
        data = r.get("result", {}).get("data")
        if not data:
            print("SHOT FAIL", name)
            return
        raw = base64.b64decode(data)
        p = os.path.join(OUT, name + ".png")
        open(p, "wb").write(raw)
        print("shot %s (%d bytes) -> %s" % (name, len(raw), p))

    def click(self, x, y, wait=1.2):
        self.send("Input.dispatchMouseEvent", {"type": "mouseMoved", "x": x, "y": y})
        self.send("Input.dispatchMouseEvent",
                  {"type": "mousePressed", "x": x, "y": y, "button": "left", "clickCount": 1})
        time.sleep(0.08)
        self.send("Input.dispatchMouseEvent",
                  {"type": "mouseReleased", "x": x, "y": y, "button": "left", "clickCount": 1})
        time.sleep(wait)

    def drag(self, x1, y1, x2, y2, steps=12, wait=1.0):
        self.send("Input.dispatchMouseEvent", {"type": "mouseMoved", "x": x1, "y": y1})
        self.send("Input.dispatchMouseEvent",
                  {"type": "mousePressed", "x": x1, "y": y1, "button": "left", "clickCount": 1})
        for i in range(1, steps + 1):
            self.send("Input.dispatchMouseEvent", {
                "type": "mouseMoved",
                "x": x1 + (x2 - x1) * i / steps,
                "y": y1 + (y2 - y1) * i / steps,
                "button": "left"})
            time.sleep(0.02)
        self.send("Input.dispatchMouseEvent",
                  {"type": "mouseReleased", "x": x2, "y": y2, "button": "left", "clickCount": 1})
        time.sleep(wait)

    def wheel(self, x, y, dy, wait=0.6):
        self.send("Input.dispatchMouseEvent",
                  {"type": "mouseWheel", "x": x, "y": y, "deltaX": 0, "deltaY": dy})
        time.sleep(wait)


def boot():
    if edge_running():
        print("browser already running")
    else:
        subprocess.Popen(
            [EDGE, "--headless=new", "--disable-gpu", "--no-first-run",
             "--disable-extensions",
             "--disable-component-extensions-with-background-pages",
             # Keep rAF/Timer at full speed in headless: without these, hidden
             # pages throttle timers to ~1/min, so the season-clock ticker's
             # inter-tick gap always exceeds the 30s "closed" threshold.
             "--disable-background-timer-throttling",
             "--disable-renderer-backgrounding",
             "--disable-backgrounding-occluded-windows",
             "--remote-debugging-port=%d" % PORT_DBG,
             "--user-data-dir=%s" % PROFILE, "--window-size=504,860",
             "--no-default-browser-check", "--disable-sync", "--disable-features=msEdgeOnRampFRE",
             '--disable-features=msImplicitSignin,msEdgeSyncPromos',
             "about:blank"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for _ in range(40):
            if edge_running():
                break
            time.sleep(1)
    d = Drv(attach())
    d.send("Page.enable")
    d.send("Runtime.enable")
    d.send("Emulation.setDeviceMetricsOverride",
           {"width": 504, "height": 860, "deviceScaleFactor": 1, "mobile": False})
    d.send("Page.navigate", {"url": URL})
    t0 = time.time()
    while time.time() - t0 < 120:
        time.sleep(2)
        ok = d.ev("(function(){var c=document.querySelector('canvas');"
                  "return c?c.width:0;})()")
        if isinstance(ok, int) and ok > 100:
            print("canvas ready %.0fs w=%d" % (time.time() - t0, ok))
            break
    time.sleep(3)
    print("viewport:", d.ev("[window.innerWidth, window.innerHeight, window.devicePixelRatio]"))


def kill():
    subprocess.run(["powershell", "-NoProfile", "-Command",
                    "Get-CimInstance Win32_Process -Filter \"Name='msedge.exe'\" | "
                    "Where-Object { $_.CommandLine -like '*_edgeprof_test*' } | "
                    "ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"],
                   capture_output=True)
    print("killed harness edge")


def save_summary():
    raw = None
    d = Drv(attach())
    raw = d.ev("localStorage.getItem('flutter.nta_save_state_v2')")
    if not raw:
        print("no save")
        return
    s = json.loads(json.loads(raw))
    keys = ["crop", "wood", "stone", "iron", "exp_scroll", "scroll", "nail",
            "woundedTroops", "rewardPoints", "elapsedSeconds", "seasonIndex",
            "dayInSeason", "divisionIndex", "divisionChosen", "tierWinPoints",
            "botDifficultyIndex", "currentView", "gameOver", "gameWon"]
    for k in keys:
        print("%-18s %s" % (k, s.get(k)))
    print("%-18s %s" % ("capitalBuildings", s.get("capitalBuildings")))
    print("%-18s %s" % ("troops", s.get("troops")))
    print("%-18s %s" % ("conquered", len(s.get("conqueredPlots") or [])))
    print("%-18s %s" % ("remains", {k: (v.get("level"), v.get("owner"))
                                     for k, v in (s.get("remains") or {}).items()}))
    print("%-18s %s" % ("rivals", [(u.get("name"), u.get("points"), u.get("ticks"))
                                   for u in (s.get("rivalUnions") or [])]))
    print("%-18s %d lines" % ("log", len(s.get("log") or [])))
    for line in (s.get("log") or [])[-8:]:
        print("   · " + str(line))


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "boot"
    if cmd == "boot":
        boot()
    elif cmd == "kill":
        kill()
    elif cmd == "save":
        save_summary()
    elif cmd in ("shot", "click", "drag", "wheel", "js"):
        d = Drv(attach())
        if cmd == "shot":
            d.shot(sys.argv[2])
        elif cmd == "click":
            d.click(float(sys.argv[2]), float(sys.argv[3]),
                    float(sys.argv[4]) if len(sys.argv) > 4 else 1.2)
        elif cmd == "drag":
            d.drag(float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]),
                   float(sys.argv[5]), wait=float(sys.argv[6]) if len(sys.argv) > 6 else 1.0)
        elif cmd == "wheel":
            d.wheel(float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]))
        elif cmd == "js":
            print(json.dumps(d.ev(" ".join(sys.argv[2:])))[:2000])
    else:
        print(__doc__)


if __name__ == "__main__":
    main()