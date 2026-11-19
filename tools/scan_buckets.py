import json, io
from collections import defaultdict

cfg = 'apk_extracted/assets/assets/resources/config.json'
d = json.load(io.open(cfg, encoding='utf-8'))
paths = d['paths']

buckets = defaultdict(list)
for k, v in paths.items():
    p = v[0]
    parts = p.split('/')
    if p.startswith('tmp/image/') and len(parts) > 3:
        buckets[parts[2]].append(p)

out = []
for b in ['strategy', 'build', 'city', 'village', 'map_flag_num', 'icon', 'img', 'novice', 'guide', 'tips', 'unlock_tip', 'land', 'corsair', 'ancient_buff']:
    out.append('=== %s (%d)' % (b, len(buckets[b])))
    for p in sorted(buckets[b]):
        out.append('  ' + p)
io.open('buckets.txt', 'w', encoding='utf-8').write('\n'.join(out))
print('ok', len(out))
