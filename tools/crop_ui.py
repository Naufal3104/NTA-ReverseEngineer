from PIL import Image
im = Image.open('game_screen2.png')
W,H = im.size
print(W,H)
im.crop((0,0,W,220)).resize((W,220)).save('ui_crop_hud.png')
im.crop((0,H-260,W,H)).save('ui_crop_bottom.png')
im.crop((W-140,100,W,700)).save('ui_crop_rail.png')
im.crop((0,150,260,420)).save('ui_crop_leftcol.png')
