import os, sys, json
from rapidocr_onnxruntime import RapidOCR

ocr = RapidOCR()

def process_folder(folder, outpath):
    files = sorted([f for f in os.listdir(folder) if f.lower().endswith(('.jpg', '.png', '.jpeg'))])
    results = []
    for f in files:
        path = os.path.join(folder, f)
        try:
            res, _ = ocr(path)
            lines = []
            if res:
                for box, text, conf in res:
                    # box: 4 points; use top-left y for sorting, x for position
                    ys = [p[1] for p in box]; xs = [p[0] for p in box]
                    lines.append((min(ys), min(xs), text, float(conf)))
            lines.sort(key=lambda t: (round(t[0]/25), t[1]))  # group by row bands
            results.append((f, [(t[2], t[3]) for t in lines]))
            print(f"OK {f}: {len(lines)} lines")
        except Exception as e:
            print(f"ERR {f}: {e}")
            results.append((f, []))
    with open(outpath, 'w', encoding='utf-8') as fo:
        for f, lines in results:
            fo.write(f"\n{'='*80}\nIMAGE: {f}\n{'='*80}\n")
            for text, conf in lines:
                fo.write(f"{text}\n")
    print(f"\nSaved: {outpath}")

if __name__ == '__main__':
    root = r"D:\Android\NTA Project Reverse Engineering"
    mode = sys.argv[1] if len(sys.argv) > 1 else 'policy'
    folders = {
        'policy': (os.path.join(root, "Policy-20261024T113120Z-1-001", "Policy"), os.path.join(root, "ocr_policy.txt")),
        'weapon': (os.path.join(root, "Weapon-20261024T114708Z-1-001", "Weapon"), os.path.join(root, "ocr_weapon.txt")),
        'battleguide': (os.path.join(root, "Battle Guide"), os.path.join(root, "ocr_battleguide.txt")),
        'plot': (os.path.join(root, "Plot"), os.path.join(root, "ocr_plot.txt")),
    }
    if mode in folders:
        folder, out = folders[mode]
    else:
        # generic: mode = subfolder name inside root, output = ocr_<mode>.txt
        folder = os.path.join(root, mode)
        out = os.path.join(root, f"ocr_{mode.replace(' ', '_').lower()}.txt")
    process_folder(folder, out)
