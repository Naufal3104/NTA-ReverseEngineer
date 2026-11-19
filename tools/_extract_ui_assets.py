"""Ekstrak resource icons + equip icons dari bundle resources."""
import json, io, os, sys
sys.path.insert(0, os.path.dirname(__file__))
from extract_sprites import main as extract_main

# Resource icons (common/image/* = ikon 1 frame, bukan pawnBase)
RES_ICONS = [
    'common/image/cereal',       # crop
    'common/image/timber',       # wood
    'common/image/stone',        # stone
    'common/image/iron',         # iron
    'common/image/exp_book',     # exp_scroll
    'common/image/up_scroll',    # scroll
    'common/image/fixator',      # nail
    'common/image/ingot',        # ingot (untuk shop)
    'common/image/gold',         # gold coin
    'common/image/rank_coin',    # rank coin / Bronze Tally
    'common/image/war_token',    # war token
    'common/image/win_point',    # win point
    'common/image/voucher',      # voucher
    'common/image/stamina',      # stamina
]

# Icon HUD (tmp/image/icon/*)
ICON_PATHS = [
    'tmp/image/icon/' + name for name in [
        '0', 'battle_pass_up',
        'giftbox_101', 'giftbox_102', 'giftbox_201', 'giftbox_202',
        'hero_opt_1', 'hero_opt_2', 'hero_opt_3', 'hero_opt_4', 'hero_opt_5',
        'lucky_bag_1', 'lucky_bag_2', 'lucky_bag_3',
        'pawn_empty', 'title_empty',
        'season_0', 'season_1', 'season_2', 'season_3',
        'shop_ingot_1', 'shop_ingot_2', 'shop_ingot_3',
        'shop_ingot_4', 'shop_ingot_5', 'shop_ingot_6',
        'treasure_1_0', 'treasure_1_1', 'treasure_2_0', 'treasure_2_1',
        'treasure_3_0', 'treasure_3_1', 'treasure_4_0', 'treasure_4_1',
        'treasure_5_0', 'treasure_5_1',
        'treasure_10_0', 'treasure_10_1', 'treasure_11_0', 'treasure_11_1',
        'up_recruit', 'win_point',
        'wdz_tb_1', 'wdz_tb_2', 'wdz_tb_3', 'wdz_tb_4',
    ]
]

# Equipment icons (tmp/image/equip/equip_6001 .. equip_6124)
EQUIP_IDS = [str(i) for i in range(6001, 6125)]
EQUIP_PATHS = ['tmp/image/equip/equip_' + e for e in EQUIP_IDS]

ALL = RES_ICONS + ICON_PATHS + EQUIP_PATHS

os.makedirs('extracted_ui', exist_ok=True)
ok, miss = extract_main(ALL, outdir='extracted_ui')
print('OK', len(ok), 'MISS', len(miss))
print('MISS:', miss[:20])
