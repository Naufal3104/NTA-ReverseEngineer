import json, io, glob
from collections import defaultdict

found = defaultdict(set)
for f in glob.glob('apk_extracted/assets/assets/*/config.json'):
    try:
        cfg = json.load(io.open(f, encoding='utf-8'))
    except Exception:
        continue
    paths = cfg.get('paths')
    if not isinstance(paths, dict):
        continue
    for v in paths.values():
        p = v[0]
        if p.startswith('common/image/') or p.startswith('tmp/image/icon/'):
            found[p.split('/')[0]].add(p)

out = io.open('_icons_found.txt', 'w', encoding='utf-8')
for k in sorted(found):
    out.write('## %s (%d)\n' % (k, len(found[k])))
    for p in sorted(found[k]):
        out.write(p + '\n')
out.close()
print('done', sum(len(v) for v in found.values()))