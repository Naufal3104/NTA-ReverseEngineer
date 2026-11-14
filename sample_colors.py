from PIL import Image
paths = {
 'building_info': 'Building-20261024T130202Z-1-001/Building/Screenshot_2026-10-24-19-10-11-515_twgame.global.acers.jpg',
 'hero': 'Hero-20261024T130155Z-1-001/Hero/Screenshot_2026-10-24-18-44-01-469_twgame.global.acers.jpg',
 'rules': 'Rules -20261024T130204Z-1-001/Rules/Screenshot_2026-10-24-14-39-19-939_twgame.global.acers.jpg',
 'hud': 'game_screen2.png',
}
for k,p in paths.items():
    im = Image.open(p).convert('RGB')
    W,H = im.size
    print(k, im.size)
    pts = {
      'center': (W//2, H//2),
      'panel_top': (W//2, int(H*0.25)),
      'panel_body': (W//2, int(H*0.55)),
      'button': (W//2, int(H*0.73)),
      'top_left': (10, 10),
    }
    for name,(x,y) in pts.items():
        r,g,b = im.getpixel((x,y))
        print('   ', name, '#%02X%02X%02X' % (r,g,b))
