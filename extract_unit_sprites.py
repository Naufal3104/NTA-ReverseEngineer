"""Extract 64x64 role icons for every unit used by the battle engine.

Source: `tmp/image/role/<id>/role_<id>` inside the Cocos `resources` bundle
(atlas frame, 64x64, untrimmed). Output: nta_demo/assets/images/units/unit_<id>.png
"""
import io
import os

from PIL import Image

import extract_sprites as ex

OUT = 'nta_demo/assets/images/units'

UNIT_IDS = (
    ['%d' % (3100 + i) for i in range(1, 7)] +   # spear
    ['%d' % (3200 + i) for i in range(1, 7)] +   # shield
    ['%d' % (3300 + i) for i in range(1, 7)] +   # bow
    ['%d' % (3400 + i) for i in range(1, 7)] +   # cavalry
    ['3501', '3502'] +                            # weaponry
    ['%d' % (4100 + i) for i in range(1, 20)] +   # beasts 4101-4119
    ['%d' % (4200 + i) for i in range(1, 7)]      # bandits 4201-4206
)


def main():
    os.makedirs(OUT, exist_ok=True)
    ok, miss = [], []
    for uid in UNIT_IDS:
        r = ex.resolve('tmp/image/role/%s/role_%s' % (uid, uid))
        if not r:
            miss.append(uid)
            continue
        img = ex.crop(*r)
        # Normalise to a square 64x64 canvas so tokens align on the grid.
        if img.size != (64, 64):
            canvas = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
            img.thumbnail((64, 64), Image.LANCZOS)
            canvas.paste(img, ((64 - img.width) // 2, (64 - img.height) // 2), img)
            img = canvas
        img.save(os.path.join(OUT, 'unit_%s.png' % uid))
        ok.append(uid)

    report = 'units: %d ok, %d miss\nmiss: %s' % (len(ok), len(miss), ' '.join(miss))
    io.open('_extract_units_report.txt', 'w', encoding='utf-8').write(report)
    print(report)


if __name__ == '__main__':
    main()
