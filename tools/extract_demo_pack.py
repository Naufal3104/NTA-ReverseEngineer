"""Extract the complete plot-element sprite pack into nta_demo/assets/images/."""
import json, io, os, glob, shutil
import extract_sprites as ex

BASE = ex.BASE
cfg = json.load(io.open(BASE + '/config.json', encoding='utf-8'))
ALL_PATHS = sorted({v[0] for v in cfg['paths'].values()})

OUT = 'nta_demo/assets/images'
PLAN = {
    'plots': 'tmp/image/land_0/',
    'terrain': 'tmp/image/land_1/',
    'ui': 'tmp/image/icon/',
    'flags': 'tmp/image/map_flag_num/',
    'capital': 'tmp/image/city/',
    'buildings': 'tmp/image/build/',
}

# Explicit allow-lists keep the demo small.
PLOT_NAMES = (['grain_10%d' % i for i in range(1, 5)] +
              ['tree_10%d' % i for i in range(1, 5)] +
              ['stone_10%d' % i for i in range(1, 5)] +
              ['grass_10%d' % i for i in range(1, 5)] +
              ['land_tonden', 'land_build_di',
               'land_area_boss_3', 'land_area_boss_4', 'land_area_boss_5'])
TERRAIN_PREFIX = ('grass_', 'hill_', 'lake_', 'river_', 'sea_', 'mountain_',
                  'beach_', 'bridge_', 'mud_', 'stone_', 'tree_', 'shadow_', 'grain_')
UI_NAMES = (['season_%d' % i for i in range(4)] +
            ['treasure_%d_%d' % (i, j) for i in range(1, 12) for j in (0, 1)] +
            ['win_point', 'pawn_empty', 'up_recruit', 'battle_pass_up',
             'giftbox_101', 'giftbox_102', 'giftbox_201', 'giftbox_202'])
FLAG_NAMES = ['map_flag_%s' % c for c in list('0123456789') + ['x']]
CAPITAL_NAMES = ['city_1001', 'city_10010'] + \
                ['city_10011%02d' % i for i in range(1, 23)] + \
                ['city_2102', 'city_2201', 'city_2202', 'city_2203']
BUILD_NAMES = ['build_2000', 'build_2001', 'build_2002', 'build_2003', 'build_2004',
               'build_2005', 'build_2006', 'build_2008', 'build_2010', 'build_2011',
               'build_2012', 'build_2013', 'build_2014', 'build_2015', 'build_2016',
               'build_2017', 'build_2101', 'build_2102', 'build_2103',
               'build_3001', 'build_3002', 'build_3003', 'build_3004']


def pick(prefix, names):
    have = {p.rsplit('/', 1)[-1] for p in ALL_PATHS if p.startswith(prefix)}
    return [prefix + n for n in names if n in have]


def pick_prefix(prefix, prefixes):
    return [p for p in ALL_PATHS
            if p.startswith(prefix) and p.rsplit('/', 1)[-1].startswith(prefixes)]


jobs = {
    'plots': pick('tmp/image/land_0/', PLOT_NAMES),
    'terrain': pick_prefix('tmp/image/land_1/', TERRAIN_PREFIX),
    'ui': pick('tmp/image/icon/', UI_NAMES),
    'flags': pick('tmp/image/map_flag_num/', FLAG_NAMES),
    'capital': pick('tmp/image/city/', CAPITAL_NAMES),
    'buildings': pick('tmp/image/build/', BUILD_NAMES),
}

report = []

# Autotile sheets (hill_/mountain_) pack many 80x80 variants in one frame.
# Crop the fully-opaque interior cells so the world map can use them as
# seamless fill tiles instead of hand-painted polygons.
FILL_CELLS = {
    'fill_forest': ('decorate/hill_101', 1, 2),
    'fill_mountain_1': ('mountain/mountain_1/mountain_1_101', 2, 1),
    'fill_mountain_2': ('mountain/mountain_1/mountain_1_101', 2, 2),
    'fill_mountain_3': ('mountain/mountain_2/mountain_2_101', 2, 2),
    'fill_mountain_4': ('mountain/mountain_4/mountain_4_101', 1, 1),
    'fill_mountain_5': ('mountain/mountain_5/mountain_5_101', 1, 1),
}


def extract_fill_cells():
    from PIL import Image
    outdir = os.path.join(OUT, 'terrain')
    ok = miss = 0
    for out_name, (src, row, col) in FILL_CELLS.items():
        path = 'tmp/image/land_1/' + src
        r = ex.resolve(path)
        if not r:
            miss += 1
            continue
        png, frame = r
        sheet = ex.crop(png, frame)
        cell = sheet.crop((col * 80, row * 80, col * 80 + 80, row * 80 + 80))
        cell.save(os.path.join(outdir, out_name + '.png'))
        ok += 1
    return ok, miss


for bucket, paths in jobs.items():
    outdir = os.path.join(OUT, bucket)
    if os.path.isdir(outdir):
        shutil.rmtree(outdir)
    os.makedirs(outdir, exist_ok=True)
    ok = miss = 0
    for p in paths:
        r = ex.resolve(p)
        if not r:
            miss += 1
            continue
        png, frame = r
        img = ex.crop(png, frame)
        name = p.rsplit('/', 1)[-1]
        img.save(os.path.join(outdir, name + '.png'))
        ok += 1
    report.append('%s: %d ok, %d miss' % (bucket, ok, miss))

fill_ok, fill_miss = extract_fill_cells()
report.append('fill_cells: %d ok, %d miss' % (fill_ok, fill_miss))

io.open('_extract_report.txt', 'w', encoding='utf-8').write('\n'.join(report))
print('\n'.join(report))
