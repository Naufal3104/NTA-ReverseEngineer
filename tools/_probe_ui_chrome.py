"""List candidate UI-chrome sprite paths in resources bundle."""
import json, re, os
BASE='apk_extracted/assets/assets/resources'
cfg=json.load(open(BASE+'/config.json',encoding='utf-8'))
paths=cfg['paths']
names={}
for k,v in paths.items():
    names[v[0]]=v
pat=re.compile(r'btn|button|_bg|bg_|panel|frame|nine|diamond|title_bg|tab|common_|hud|_bar|_box|board|dialog|pop|mask',re.I)
hits=sorted(n for n in names if pat.search(n) and not n.startswith('common/json') and not n.startswith('tmp/image/role') and not n.startswith('tmp/image/headicon') and not n.startswith('tmp/image/avatar_hero') and not n.startswith('tmp/image/emoji') and not n.startswith('tmp/image/buff') and '/json/' not in n)
out=[]
for n in hits:
    out.append('%s  type=%s'%(n,names[n][1]))
open('_ui_chrome_candidates.txt','w',encoding='utf-8').write('\n'.join(out))
print('hits',len(hits))
