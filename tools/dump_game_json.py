"""Dump Cocos JsonAsset (common/json/*) to readable JSON files."""
import json, io, os, glob

B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
V = {c: i for i, c in enumerate(B64)}


def dec(s):
    if len(s) != 22:
        return s
    out = s[:2]
    for i in range(2, 22, 2):
        out += '%03x' % ((V[s[i]] << 6) | V[s[i + 1]])
    h = out
    return '%s-%s-%s-%s-%s' % (h[0:8], h[8:12], h[12:16], h[16:20], h[20:32])


BASE = 'apk_extracted/assets/assets/resources'
cfg = json.load(io.open(BASE + '/config.json', encoding='utf-8'))
P, U = cfg['paths'], cfg['uuids']

OUT = 'game_json'
os.makedirs(OUT, exist_ok=True)

wanted = [k for k, v in P.items() if v[0].startswith('common/json/')]
report = []
for idx in wanted:
    name = P[idx][0].rsplit('/', 1)[-1]
    uid = dec(U[int(idx)])
    f = '%s/import/%s/%s.json' % (BASE, uid[:2], uid)
    if not os.path.exists(f):
        report.append('MISS %s %s' % (name, uid))
        continue
    try:
        d = json.load(io.open(f, encoding='utf-8'))
    except Exception as e:
        report.append('ERR %s %s' % (name, e))
        continue
    payload = None
    if isinstance(d, list) and len(d) > 5 and isinstance(d[5], list) and d[5]:
        ent = d[5][0]
        if isinstance(ent, list) and len(ent) >= 3:
            payload = ent[2]
    if payload is None:
        report.append('NOPAYLOAD %s' % name)
        continue
    io.open('%s/%s.json' % (OUT, name), 'w', encoding='utf-8').write(
        json.dumps(payload, ensure_ascii=False, indent=1))
    report.append('OK %s (%d bytes)' % (name, len(json.dumps(payload))))

io.open(OUT + '/_report.txt', 'w', encoding='utf-8').write('\n'.join(report))
print('done', len(report))
