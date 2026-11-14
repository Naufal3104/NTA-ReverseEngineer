"""Scan every atlas import json for sprite-frame names matching keywords."""
import json, io, os, glob

BASE = 'apk_extracted/assets/assets/resources'
KEYS = ['flag', 'tower', 'fort', 'farm', 'saw', 'quarry', 'remain', 'watch',
        'occupy', 'cell', 'tonden', 'pawn_', 'wall', 'gate', 'banner',
        'march', 'army', 'camp']

hits = {k: [] for k in KEYS}
n_atlas = 0
for f in glob.glob(BASE + '/import/*/*.json'):
    try:
        d = json.load(io.open(f, encoding='utf-8'))
    except Exception:
        continue
    if not isinstance(d, list) or len(d) < 6 or d[0] != 1:
        continue
    n_atlas += 1
    body = d[5]
    if not isinstance(body, list):
        continue
    for entry in body:
        if not isinstance(entry, list) or not entry:
            continue
        fl = entry[0]
        if not isinstance(fl, list):
            continue
        for fr in fl:
            if not isinstance(fr, dict):
                continue
            nm = fr.get('name', '')
            low = nm.lower()
            for k in KEYS:
                if k in low:
                    hits[k].append('%s  [%s]' % (nm, os.path.basename(f)))

out = ['atlases scanned %d' % n_atlas]
for k in KEYS:
    uniq = sorted(set(hits[k]))
    out.append('== %s (%d)' % (k, len(uniq)))
    out.extend('  ' + u for u in uniq[:120])
io.open('_framescan.txt', 'w', encoding='utf-8').write('\n'.join(out))
print('done', n_atlas)
