"""Extract per-unit walk/drill animation frame sequences from role clips.

Reads cc.AnimationClip assets (name `role_<pawnId>_walk` / `_drill`), resolves
each frame sprite through the atlases, normalises every frame of a clip to one
shared canvas, writes `nta_demo/assets/images/units/anim/<pawnId>_<clip>_<i>.png`.
Also writes `nta_demo/assets/images/units/anim/clips.json`:
  { "<pawnId>": { "walk": {"count": N, "fps": F, "w": W, "h": H}, ... } }
"""
import json, io, os, glob

import extract_sprites as ex

BASE = 'apk_extracted/assets/assets/resources'
OUT = 'nta_demo/assets/images/units/anim'

B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
HEX = '0123456789abcdef'
V = {c: i for i, c in enumerate(B64)}


def dec(b):
    if len(b) != 22:
        return b
    o = b[:2]
    for i in range(2, 22, 2):
        l, r = V[b[i]], V[b[i + 1]]
        o += HEX[l >> 2] + HEX[((l & 3) << 2) | (r >> 4)] + HEX[r & 0xF]
    return o


# Only units the battle engine can field (troopCombatIds + enemy roster).
KEEP = set(
    ['%d' % (3100 + i) for i in range(1, 7)] +
    ['%d' % (3200 + i) for i in range(1, 7)] +
    ['%d' % (3300 + i) for i in range(1, 7)] +
    ['%d' % (3400 + i) for i in range(1, 7)] +
    ['3501', '3502'] +
    ['%d' % (4100 + i) for i in range(1, 20)] +
    ['%d' % (4200 + i) for i in range(1, 7)] +
    ['4201', '4202']
)


def build_frame_names():
    names = {}
    for p in glob.glob(BASE + '/import/*/*.json'):
        try:
            j = json.load(io.open(p, encoding='utf-8'))
        except Exception:
            continue
        if not (isinstance(j, list) and len(j) > 5 and j[0] == 1):
            continue
        if not (isinstance(j[1], list) and isinstance(j[2], list) and j[2]):
            continue
        if not (isinstance(j[2][0], str) and j[2][0].startswith('role_')):
            continue
        for i, nm in enumerate(j[1]):
            if isinstance(nm, str) and i < len(j[2]):
                names[nm] = j[2][i]
    return names


def read_clips(frame_names):
    """Return {clip_name: [(time, frameName), ...]} plus clip duration."""
    clips = {}
    for p in glob.glob(BASE + '/import/*/*.json'):
        try:
            txt = io.open(p, encoding='utf-8').read()
        except Exception:
            continue
        if 'cc.AnimationClip' not in txt or 'role_' not in txt:
            continue
        try:
            j = json.loads(txt)
        except Exception:
            continue
        if not (isinstance(j, list) and j[0] == 1 and len(j) > 5):
            continue
        body = j[5]
        if not (isinstance(body, list) and body and isinstance(body[0], list)):
            continue
        entry = body[0]
        if len(entry) < 2 or not isinstance(entry[1], str):
            continue
        name = entry[1]
        if not name.startswith('role_'):
            continue
        seqs = []

        def walk(x):
            if isinstance(x, list):
                if (len(x) == 4 and isinstance(x[0], dict) and 'frame' in x[0]
                        and x[1] == 'value' and isinstance(x[3], int)):
                    seqs.append((x[0]['frame'], x[3]))
                else:
                    for y in x:
                        walk(y)
            elif isinstance(x, dict):
                for y in x.values():
                    walk(y)

        walk(entry)
        seqs.sort()
        deps = j[1] if isinstance(j[1], list) else []
        frames = []
        for t, di in seqs:
            if di < len(deps):
                fn = frame_names.get(deps[di])
                if fn:
                    frames.append((t, fn))
        if frames:
            clips[name] = frames
    return clips


def find_path(frame_name):
    cands = [p for p in ex.idx_of_path if p.rsplit('/', 1)[-1] == frame_name]
    return cands[0] if cands else None


def trimmed_piece(png_path, frame):
    """Return the trimmed sprite only (no originalSize canvas).

    `extract_sprites.crop` pastes onto the originalSize canvas, which clips
    frames whose trim offset is negative (mounted cavalry). For animation we
    only need the pixels; placement comes from the frame offsets.
    """
    from PIL import Image
    im = Image.open(png_path).convert('RGBA')
    x, y, w, h = frame['rect']
    if frame.get('rotated'):
        piece = im.crop((x, y, x + h, y + w)).transpose(Image.Transpose.ROTATE_90)
    else:
        piece = im.crop((x, y, x + w, y + h))
    return piece, (frame.get('offset') or [0, 0])


def main():
    os.makedirs(OUT, exist_ok=True)
    frame_names = build_frame_names()
    clips = read_clips(frame_names)

    manifest = {}
    for clip_name, frames in sorted(clips.items()):
        # role_<pawnId>_<walk|drill>
        parts = clip_name.split('_')
        if len(parts) != 3:
            continue
        _, pawn_id, clip = parts
        if pawn_id not in KEEP:
            continue

        pieces = []
        for _, fn in frames:
            p = find_path(fn)
            r = ex.resolve(p) if p else None
            if not r:
                pieces.append(None)
                continue
            pieces.append(trimmed_piece(*r))
        if not pieces or any(p is None for p in pieces):
            continue

        # Place every trimmed piece on one shared canvas using its trim offset.
        # Cocos `offset` is from the original sprite's bottom-left, y-up, so the
        # union bbox in y-up space maps to raster rows as `maxY - (off.y + ph)`.
        min_x = min(off[0] for _, off in pieces)
        max_x = max(off[0] + p.width for p, off in pieces)
        min_y = min(off[1] for _, off in pieces)
        max_y = max(off[1] + p.height for p, off in pieces)
        w, h = max(1, int(round(max_x - min_x))), max(1, int(round(max_y - min_y)))

        from PIL import Image
        for i, (img, off) in enumerate(pieces):
            canvas = Image.new('RGBA', (w, h), (0, 0, 0, 0))
            left = int(round(off[0] - min_x))
            top = int(round(max_y - (off[1] + img.height)))
            canvas.paste(img, (left, top), img)
            canvas.save(os.path.join(OUT, '%s_%s_%d.png' % (pawn_id, clip, i)))

        span = frames[-1][0] or 1.0
        fps = round(len(frames) / span, 1) if span else 8.0
        manifest.setdefault(pawn_id, {})[clip] = {
            'count': len(pieces), 'fps': fps, 'w': w, 'h': h,
        }

    with io.open(os.path.join(OUT, 'clips.json'), 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=1, sort_keys=True)
    print('units %d clips %d' % (len(manifest), sum(len(v) for v in manifest.values())))


if __name__ == '__main__':
    main()
