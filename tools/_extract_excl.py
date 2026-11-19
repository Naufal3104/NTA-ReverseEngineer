import os, sys
sys.path.insert(0, os.path.dirname(__file__))
import extract_sprites as es

ids = [str(i) for i in range(6045, 6125)]
paths = ['tmp/image/equip/equip_' + i for i in ids]

ok = []
miss = []
for p in paths:
    r = es.resolve(p)
    if not r:
        # why miss?
        idx = es.idx_of_path.get(p)
        miss.append((p, 'idx=' + str(idx)))
        continue
    png, frame = r
    img = es.crop(png, frame)
    out = 'extracted_ui/equip__equip_%s.png' % p.rsplit('_', 1)[-1]
    img.save(out)
    ok.append((p, img.size))

print('OK', len(ok))
for o in ok[:10]:
    print(' ', o)
print('MISS', len(miss))
for m in miss[:20]:
    print(' ', m)