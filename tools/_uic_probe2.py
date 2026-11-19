import json, io, os
import extract_sprites as es

# All non-tmp, non-view sprite paths
paths = []
for idx, v in es.PATHS.items():
    p = v[0]
    if p.endswith('/'): continue
    paths.append((p, v[1] if len(v) > 1 else None))
paths.sort()

# 1) dump all common/image/* paths
print('=== common/image/* ===')
for p, t in paths:
    if p.startswith('common/image/'):
        print(p, 'type', t)

print()
print('=== tmp/image/ root-ish (chrome candidates) ===')
for p, t in paths:
    if p.startswith('tmp/image/') and t == 3:
        print(p)
