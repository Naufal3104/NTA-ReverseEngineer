"""Extract UI chrome (buttons, frames, panels) from Cocos atlases."""
import extract_sprites as E
import os, json
from PIL import Image

# frame name -> (out_name, kind)
CHROME = {
  # gold buttons (anniu = button)
  'ty_anniu1_001': ('btn_gold_round_diamond', '9'),
  'ty_anniu2_001': ('btn_gold_round', '9'),
  'ty_anniu5':     ('btn_gold_wide', '9'),
  'ty_anniu6':     ('btn_gold_wide2', '9'),
  'dl_button_bg':  ('btn_white_wide', '9'),
  'dl_button_area_bg': ('btn_white_round', '9'),
  'dl_button_jt':  ('btn_arrow', '0'),
  # frames / panels (kuang = frame)
  'ty_kuang_001':  ('panel_wide', '9'),
  'ty_kuang_002':  ('panel_ring', '9'),
  'ty_kuang_004':  ('panel_cream', '9'),
  'ty_kuang_005':  ('panel_square', '9'),
  'ty_kuang_006':  ('panel_dark', '9'),
  'ty_kuang_007':  ('panel_inset', '9'),
  'ty_kuang_xuanzhong': ('frame_selected', '9'),
  'ty_kuang_jiahao': ('frame_plus', '0'),
  'manghe_kuang_1': ('box_frame_1', '9'),
  'manghe_kuang_2': ('box_frame_2', '9'),
  'title_quality_1': ('title_q1', '0'),
  'title_quality_2': ('title_q2', '0'),
  'title_quality_3': ('title_q3', '0'),
  'title_quality_4': ('title_q4', '0'),
  'title_quality_5': ('title_q5', '0'),
  'title_quality_6': ('title_q6', '0'),
  'title_quality_7': ('title_q7', '0'),
  'title_empty': ('title_empty', '0'),
  # button icons
  'btn_confirm_icon': ('ic_confirm', '0'),
  'btn_cancel_icon':  ('ic_cancel', '0'),
  'btn_send_chat_icon': ('ic_chat_send', '0'),
  'btn_back_icon':    ('ic_back', '0'),
  'btn_chat_icon':    ('ic_chat', '0'),
  'btn_add_friend':   ('ic_add_friend', '0'),
  'btn_user_icon':    ('ic_user', '0'),
  'btn_max':          ('ic_max', '0'),
  'btn_min':          ('ic_min', '0'),
  'btn_change_show_0':('ic_eye_on', '0'),
  'btn_change_show_1':('ic_eye_off', '0'),
  'btn_bgm_icon_0':   ('ic_bgm_off', '0'),
  'btn_bgm_icon_1':   ('ic_bgm_on', '0'),
  'btn_sfx_icon_0':   ('ic_sfx_off', '0'),
  'btn_sfx_icon_1':   ('ic_sfx_on', '0'),
  # hp bar
  'hp_bar_x':         ('bar_hp', '0'),
  # map flag bg
  'map_flag_bg':      ('flag_bg', '0'),
  'map_mask_bg':      ('map_mask', '0'),
  # misc
  'add_popularity_icon': ('ic_popularity', '0'),
  'popularity_record_icon': ('ic_record', '0'),
  'buff_di_0':        ('buff_bg_0', '0'),
  'buff_di_1':        ('buff_bg_1', '0'),
  'season_di_0':      ('season_bg_0', '0'),
  'season_di_1':      ('season_bg_1', '0'),
  'season_di_2':      ('season_bg_2', '0'),
  'season_di_3':      ('season_bg_3', '0'),
}

allf = {}
for atlas, idxs in E.cfg['packs'].items():
    tex, frames = E.atlas_frames(atlas)
    for nm, (ti, fr) in frames.items():
        allf[nm] = (atlas, ti, fr)

OUT = 'nta_demo/assets/images/ui_chrome'
os.makedirs(OUT, exist_ok=True)
ok, miss = [], []
manifest = {}
for name, (out, kind) in CHROME.items():
    if name not in allf:
        miss.append(name); continue
    atlas, ti, fr = allf[name]
    tex, _ = E.atlas_frames(atlas)
    png = '%s/native/%s/%s.png' % (E.BASE, tex[ti][:2], tex[ti])
    if not os.path.exists(png):
        miss.append(name + ' (no png)'); continue
    img = E.crop(png, fr).convert('RGBA')
    img.save('%s/%s.png' % (OUT, out))
    ci = fr.get('capInsets') or [0, 0, 0, 0]
    manifest[out] = {'src': name, 'size': list(img.size), 'capInsets': list(ci), 'kind': kind}
    ok.append((out, img.size, ci))

json.dump(manifest, open('_chrome_manifest.json', 'w'), indent=1)
print('OK', len(ok), 'MISS', len(miss))
for o, s, ci in ok:
    print(' ', o, s, 'cap', ci)
print('MISSING:', miss)
