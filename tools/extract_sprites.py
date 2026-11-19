"""Extract Cocos Creator 2.4 sprite frames from packed atlases.

Chain: config.json paths[idx] -> find atlas in config.packs -> atlas import json
(import/xx/atlas.json, list format d[0]==1) -> frame rect by name -> crop from
native/xx/<textureUuid>.png (rect y measured from bottom).
"""
import json, io, os, sys

BASE = 'apk_extracted/assets/assets/resources'
OUT = 'extracted_sprites'

cfg = json.load(io.open(BASE + '/config.json', encoding='utf-8'))
PATHS = cfg['paths']          # idx(str) -> [path, type, ...]
UUIDS = cfg['uuids']          # list
PACKS = cfg['packs']          # atlasUuid -> [pathIdx,...]

idx_of_path = {}
for idx, v in PATHS.items():
    idx_of_path.setdefault(v[0], int(idx))

pack_of_idx = {}
for atlas, idxs in PACKS.items():
    for i in idxs:
        pack_of_idx[i] = atlas

_import_cache = {}


def load_atlas(atlas):
    if atlas in _import_cache:
        return _import_cache[atlas]
    p = '%s/import/%s/%s.json' % (BASE, atlas[:2], atlas)
    data = None
    if os.path.exists(p):
        data = json.load(io.open(p, encoding='utf-8'))
    _import_cache[atlas] = data
    return data


def atlas_frames(atlas):
    """Return (texture_uuids, {name: (texIdx, frame_dict)})."""
    data = load_atlas(atlas)
    if not isinstance(data, list) or not data or data[0] != 1:
        return [], {}
    tex_uuids = data[1] if isinstance(data[1], list) else []
    frames = {}
    body = data[5] if len(data) > 5 else []
    if not isinstance(body, list):
        return tex_uuids, frames
    for entry in body:
        if not isinstance(entry, list) or not entry:
            continue
        frame_list = entry[0]
        tex_idx = entry[1][0] if isinstance(entry[1], list) and entry[1] else 0
        if not isinstance(frame_list, list):
            continue
        for fr in frame_list:
            if isinstance(fr, dict) and 'name' in fr:
                frames[fr['name']] = (tex_idx, fr)
    return tex_uuids, frames


def resolve(path):
    """Return (texturePngPath, frame_dict) or None."""
    idx = idx_of_path.get(path)
    if idx is None:
        return None
    atlas = pack_of_idx.get(idx)
    if not atlas:
        return None
    tex_uuids, frames = atlas_frames(atlas)
    name = path.rsplit('/', 1)[-1]
    if name not in frames:
        return None
    tex_idx, frame = frames[name]
    if tex_idx >= len(tex_uuids):
        return None
    tex = tex_uuids[tex_idx]
    png = '%s/native/%s/%s.png' % (BASE, tex[:2], tex)
    if not os.path.exists(png):
        return None
    return png, frame


def crop(png, frame):
    """Crop a frame and restore it to its original (untrimmed) size.

    Cocos 2.4 trim metadata: `rect` y is measured from the atlas top;
    `rotated` means the frame is stored transposed in the atlas;
    `offset` is the trim offset from the original sprite's bottom-left.
    """
    from PIL import Image
    im = Image.open(png).convert('RGBA')
    x, y, w, h = frame['rect']
    if frame.get('rotated'):
        # Atlas stores the sprite rotated 90° CW with swapped rect dims.
        # Crop the swapped rect, then rotate 90° CCW to recover upright art.
        piece = im.crop((x, y, x + h, y + w))
        piece = piece.transpose(Image.Transpose.ROTATE_90)
    else:
        piece = im.crop((x, y, x + w, y + h))
    orig = frame.get('originalSize')
    if not orig or (piece.width == orig[0] and piece.height == orig[1]):
        return piece
    off = frame.get('offset') or [0, 0]
    canvas = Image.new('RGBA', (int(orig[0]), int(orig[1])), (0, 0, 0, 0))
    # offset is from the original's bottom-left, y-up. Some frames carry
    # half-pixel offsets (e.g. [-1.5, 0]); round so PIL accepts them.
    left = int(round(off[0]))
    top = int(round(orig[1] - piece.height - off[1]))
    canvas.paste(piece, (left, top))
    return canvas


def main(paths, outdir=OUT, sheet=None):
    os.makedirs(outdir, exist_ok=True)
    ok, miss = [], []
    for path in paths:
        r = resolve(path)
        if not r:
            miss.append(path)
            continue
        png, frame = r
        img = crop(png, frame)
        safe = path.replace('tmp/image/', '').replace('/', '__')
        img.save('%s/%s.png' % (outdir, safe))
        ok.append((path, img.size))
    io.open(outdir + '/_report.txt', 'w', encoding='utf-8').write(
        'OK %d\n' % len(ok) +
        '\n'.join('%s %s' % (p, s) for p, s in ok) +
        '\nMISS %d\n' % len(miss) +
        '\n'.join(miss))
    return ok, miss


if __name__ == '__main__':
    targets = sys.argv[1:]
    if not targets:
        targets = ['tmp/image/land/' + n for n in
                   ['comm_103_0', 'comm_103_1', 'comm_103_2', 'comm_103_3',
                    'comm_103_4', 'comm_area_01', 'comm_area_main_0',
                    'comm_area_main_2000101', 'comm_area_main_2000102',
                    'comm_area_main_2000103', 'comm_106_1',
                    'army_min_icon', 'avoidwar_icon_1', 'avoidwar_icon_2']]
    ok, miss = main(targets)
    print('ok', len(ok), 'miss', len(miss))
