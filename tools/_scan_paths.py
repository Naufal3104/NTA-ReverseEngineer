import json, io, glob

for f in glob.glob('apk_extracted/assets/assets/*/config.json'):
    try:
        cfg = json.load(io.open(f, encoding='utf-8'))
    except Exception as e:
        print('ERR', f, e)
        continue
    paths = cfg.get('paths')
    if not isinstance(paths, dict):
        print('no paths dict in', f)
        continue
    print('==', f, len(paths), 'paths')
    hits = [v[0] for v in paths.values()
            if any(k in v[0].lower() for k in
                   ['cereal', 'timber', 'iron', 'stone', 'exp_book',
                    'fixator', 'ingot', 'nail', 'wood', 'crop'])]
    for h in hits[:80]:
        print('  ', h)