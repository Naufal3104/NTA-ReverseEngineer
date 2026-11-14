import json, io
from collections import Counter

cfg = 'apk_extracted/assets/assets/resources/config.json'
d = json.load(io.open(cfg, encoding='utf-8'))
paths = d['paths']

c = Counter()
for k, v in paths.items():
    p = v[0]
    if p.startswith('tmp/image/'):
        parts = p.split('/')
        key = parts[2] if len(parts) > 2 else '(root)'
        c[key] += 1

lines = ['%6d %s' % (v, k) for k, v in sorted(c.items(), key=lambda x: -x[1])]
io.open('tmpimg_tree.txt', 'w', encoding='utf-8').write('\n'.join(lines))

# also dump every path containing 'land'
land = sorted({v[0] for v in paths.values() if '/land' in v[0]})
io.open('land_paths.txt', 'w', encoding='utf-8').write('\n'.join(land))
print('dirs', len(c), 'land', len(land))
