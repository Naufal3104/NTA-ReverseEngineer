import json, io, os
BASE = 'apk_extracted/assets/assets/resources'
cfg = json.load(io.open(BASE + '/config.json', encoding='utf-8'))
PATHS = cfg['paths']
KEYS = ['btn','button','common_bg','bg_','panel','frame','nine','diamond',
        'title_bg','tab','base_res','cereal','timber','stone','iron','exp_book',
        'exp_scroll','up_scroll','fixator','nail','gold','ingot','rank_coin',
        'war_token','voucher','stamina','wood','crop','res_','_res','header',
        'dialog','popup','cu_bg','titlebg','main_bg','bar_','circle','tip']
hits = []
for idx, v in PATHS.items():
    p = v[0]
    if not p.lower().endswith('.png') and v[1] != 3:
        pass
    low = p.lower()
    if any(k in low for k in KEYS):
        hits.append(p)
hits.sort()
io.open('_uic_probe.txt','w',encoding='utf-8').write('\n'.join(hits))
print(len(hits), 'hits')
for h in hits:
    print(h)
