# -*- coding: utf-8 -*-
"""Contact sheet dari PNG unmapped asset_catalog — identifikasi visual massal.

Grid tiap sheet: 12 kolom x 10 baris = 120 thumbnail per sheet, tiap thumb
max 96px, label nomor urut. Output: contact_sheet_NN.png di folder kerja.
"""
import os
import glob
from PIL import Image, ImageDraw

ROOT = r"D:\Android\NTA Project Reverse Engineering"
SRC = os.path.join(ROOT, "asset_catalog", "_unmapped")
OUT_DIR = os.path.join(ROOT, "contact_sheets")
os.makedirs(OUT_DIR, exist_ok=True)

COLS, ROWS = 12, 10
THUMB = 96
LABEL_H = 14
CELL_W, CELL_H = THUMB + 4, THUMB + LABEL_H + 2

files = sorted(glob.glob(os.path.join(SRC, "**", "*.png"), recursive=True))
print("total png:", len(files))

per_sheet = COLS * ROWS
for sheet_i in range(0, len(files), per_sheet):
    chunk = files[sheet_i:sheet_i + per_sheet]
    sheet = Image.new("RGB", (COLS * CELL_W, ROWS * CELL_H), (40, 40, 40))
    d = ImageDraw.Draw(sheet)
    for idx, fp in enumerate(chunk):
        r, c = divmod(idx, COLS)
        x, y = c * CELL_W + 2, r * CELL_H + 2
        try:
            im = Image.open(fp).convert("RGBA")
            w, h = im.size
            scale = min(THUMB / w, THUMB / h, 1.0)
            im = im.resize((max(1, int(w * scale)), max(1, int(h * scale))))
            bg = Image.new("RGBA", (THUMB, THUMB), (90, 90, 90, 255))
            bg.paste(im, ((THUMB - im.width) // 2, (THUMB - im.height) // 2), im)
            sheet.paste(bg.convert("RGB"), (x, y))
        except Exception as e:
            d.text((x, y), "ERR", fill=(255, 0, 0))
        num = sheet_i + idx
        d.text((x, y + THUMB + 1), str(num), fill=(255, 255, 0))
    out = os.path.join(OUT_DIR, "sheet_%03d.png" % (sheet_i // per_sheet))
    sheet.save(out)
    print("saved", out, "entries", sheet_i, "-", sheet_i + len(chunk) - 1)
print("done")
