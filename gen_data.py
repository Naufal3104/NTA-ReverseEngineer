# -*- coding: utf-8 -*-
"""Generate game-demo/data.js from the project's reverse-engineering documentation.
Sources (observed game data):
  - SoldierAttribute.md            (24 soldiers + 2 weaponry, user-authored, authoritative)
  - Hero Skill and Expertise.md   (56 heroes + per-category expertise lists)
  - Policy and Equipment Recap.md (42 common + 24 exclusive equipment)
  - Battle Guide and Plot Recap.md (bestiary, plot rules - embedded below from the verified recap)
Demo-only approximations are flagged in DEMO_NOTES (rendered in the demo Help tab).
"""
import re, os, json, io

ROOT = r"D:\Android\NTA Project Reverse Engineering"
OUT = os.path.join(ROOT, "game-demo", "data.js")

def read(p):
    with io.open(p, "r", encoding="utf-8") as f:
        return f.read()

# ---------------------------------------------------------------- soldiers
def parse_soldiers():
    txt = read(os.path.join(ROOT, "SoldierAttribute.md"))
    cat_map = {"Spearman": "spear", "Shieldman": "shield", "Bowman": "bow", "Cavalry": "cavalry", "Weaponry": "weaponry"}
    soldiers, weaponry = [], []
    cur_cat = None
    # split into blocks by headings
    lines = txt.splitlines()
    blocks, cur = [], []
    for ln in lines:
        if ln.startswith("## ") or ln.startswith("### "):
            if cur: blocks.append(cur)
            cur = [(ln,)]
        else:
            if cur: cur.append((ln,))
    if cur: blocks.append(cur)

    def val(pat, s, default=None):
        m = re.search(pat, s)
        return m.group(1).strip() if m else default

    for blk in blocks:
        head = blk[0][0]
        if head.startswith("## "):
            name = head[3:].strip()
            cur_cat = cat_map.get(name)
            continue
        if head.startswith("### "):
            sname = head[4:].strip()
            body = "\n".join(x[0] for x in blk[1:])
            if "* HP" not in body:
                continue  # stray empty heading
            mhp = re.search(r"\* HP = \[(\d+)-(\d+)\]", body) or re.search(r"\* HP = (\d+)$", body, re.M)
            hp = [int(x) for x in mhp.groups()]
            rg = re.search(r"\* Rage = (\d+)/(\d+)", body)
            rage = [int(rg.group(1)), int(rg.group(2))] if rg else [0, 0]
            # ATK: normal bracket, Modao random range, Improved Crossbowman malformed, weaponry fixed
            atk, atk_random = None, None
            m = re.search(r"\* ATK = \[(\d+)-(\d+)\]", body)
            if m:
                atk = [int(m.group(1)), int(m.group(2))]
            else:
                m2 = re.search(r"\* ATK = \[\((\d+)-(\d+)\)-\((\d+)-(\d+)\)\]", body)
                if m2:
                    atk_random = [int(m2.group(1)), int(m2.group(4))]
                else:
                    m3 = re.search(r"\* ATK = \[\((\d+)-(\d+)\)", body)
                    if m3:
                        atk = [int(m3.group(1)), int(m3.group(2))]
                    else:
                        m4 = re.search(r"\* ATK = (\d+)$", body, re.M)
                        if m4:
                            atk = [int(m4.group(1)), int(m4.group(1))]
            rng = int(val(r"\* Range = (\d+) Tile", body, 1))
            mov = int(val(r"\* Move Range = (\d+) Tile", body, 1))
            crop = int(val(r"\* Crop Consumption = (\d+)", body, 3))
            spd = int(val(r"\* Marching SPD = (\d+)", body, 62))
            cost = int(val(r"\* Cost Coefficient = (\d+)", body, 100))
            skill, passives = None, []
            ms = re.search(r"\* Skill = (.+)", body)
            if ms:
                sd = val(r"\* Skill Description = (.+)", body, "")
                skill = {"name": ms.group(1).strip(), "desc": sd}
            for pk in ["Skill Passive", "Skill Passive 1", "Skill Passive 2"]:
                mp = re.search(r"\* " + pk + r"\s*=\s*(.+)", body)
                if mp:
                    pd = val(r"\* " + pk + r" Description = (.+)", body, "")
                    passives.append({"name": mp.group(1).strip(), "desc": pd})
            entry = {
                "id": re.sub(r"[^a-z0-9]+", "", sname.lower()),
                "name": sname,
                "cat": cur_cat,
                "hp": hp, "atk": atk, "atkRandom": atk_random,
                "rage": rage, "range": rng, "move": mov, "spd": spd,
                "crop": crop, "cost": cost,
                "skill": skill, "passives": passives,
                "upgradable": cur_cat != "weaponry",
            }
            (weaponry if cur_cat == "weaponry" else soldiers).append(entry)
    return soldiers, weaponry

# ---------------------------------------------------------------- heroes + expertise
def parse_heroes():
    txt = read(os.path.join(ROOT, "Hero Skill and Expertise.md"))
    cat_map = {"Spearman": "spear", "Shieldman": "shield", "Bowman": "bow", "Cavalry": "cavalry"}
    heroes, expertise = [], {"spear": {}, "shield": {}, "bow": {}, "cavalry": {}}
    cur_cat, cur_sub, tier = None, None, None
    lines = txt.splitlines()
    i = 0
    cur_hero = None
    def flush():
        nonlocal cur_hero
        if cur_hero:
            heroes.append(cur_hero)
            cur_hero = None
    while i < len(lines):
        ln = lines[i]
        if ln.startswith("### ") and ln[4:].strip() in cat_map:
            flush(); cur_cat = cat_map[ln[4:].strip()]; cur_sub = None; tier = None
        elif ln.startswith("#### "):
            flush(); cur_sub = ln[5:].strip(); tier = None
        elif ln.strip() in ("Common Expertise", "Uncommon Expertise", "Rare Expertise") and cur_cat and not cur_sub:
            tier = ln.strip().split()[0].lower()
            expertise[cur_cat][tier] = []
        elif ln.startswith("- ") and tier and cur_cat and not cur_sub:
            expertise[cur_cat][tier].append(ln[2:].strip())
        elif re.match(r"^\*?\*?\d+\.", ln) and cur_cat:
            flush()
            m = re.match(r"^\*?\*?(\d+)\.\s*(.+?)\s*\:?\s*$", ln)
            name = m.group(2).strip().rstrip(":").strip()
            # gather until next numbered hero / heading
            j = i + 1
            buf = []
            while j < len(lines) and not re.match(r"^\*?\*?\d+\.", lines[j]) and not lines[j].startswith("#"):
                buf.append(lines[j]); j += 1
            blob = " ".join(b.strip() for b in buf if b.strip())
            skill_name = re.match(r"^\s*([^,]+),?", buf[0]).group(1).strip() if buf else ""
            poss = re.search(r"Possession:\s*(.+?)\s*(?=(?:hp|atk)\s*\+|Unique\s+Hero|$)", blob, re.I)
            poss = poss.group(1).strip() if poss else (cur_sub or "")
            hp = re.search(r"hp\+\s*\[(\d+)-(\d+)\]", blob, re.I)
            atk = re.search(r"atk\+\s*\[(\d+)-(\d+)\]", blob, re.I)
            uniq = ""
            mu = re.search(r"Unique\s+Hero\s+Rare\s+Expertise\s*=\s*(.+)$", blob)
            if mu:
                uniq = mu.group(1).strip()
                blob = blob[:mu.start()].strip()
            desc = blob
            # strip leading skill name / possession / stat lines from desc
            if skill_name:
                desc = re.sub(r"^\s*" + re.escape(skill_name) + r"\s*,?\s*", "", desc, count=1, flags=re.I)
            desc = re.sub(r"Possession:\s*.+?(?=(?:hp|atk)\s*\+|Unique\s+Hero|$)", "", desc, flags=re.I)
            desc = re.sub(r"hp\+\s*\[\d+-\d+\]", "", desc, flags=re.I)
            desc = re.sub(r"atk\+\s*\[\d+-\d+\]", "", desc, flags=re.I)
            desc = re.sub(r"\s+", " ", desc).strip(" ,")
            heroes.append({
                "id": re.sub(r"[^a-z0-9]+", "", name.lower()),
                "num": int(m.group(1)), "name": name,
                "skillName": skill_name.rstrip(","),
                "cat": cur_cat, "possession": poss,
                "hp": [int(hp.group(1)), int(hp.group(2))] if hp else [0, 0],
                "atk": [int(atk.group(1)), int(atk.group(2))] if atk else [0, 0],
                "desc": desc, "unique": uniq,
            })
            i = j
            continue
        i += 1
    flush()
    return heroes, expertise

# ---------------------------------------------------------------- equipment
def parse_equipment():
    txt = read(os.path.join(ROOT, "Policy and Equipment Recap.md"))
    common, excl = [], []
    # common tables 2.1-2.6: | # | **Name** | [roll] | effect |
    for m in re.finditer(r"\|\s*(\d+)\s*\|\s*\*\*(.+?)\*\*\s*\|\s*\[(.+?)\]\s*\|\s*(.+?)\s*\|", txt):
        num, name, roll, eff = int(m.group(1)), m.group(2).strip(), m.group(3).strip(), m.group(4).strip()
        if num > 42 or "Exclusive" in eff:
            continue
        rl = [int(x) for x in re.findall(r"\d+", roll)][:2]
        common.append({"id": re.sub(r"[^a-z0-9]+", "", name.lower()), "num": num, "name": name,
                       "tier": 1 if num <= 6 else 3 if num <= 12 else 5 if num <= 17 else 7 if num <= 26 else 12 if num <= 36 else 14,
                       "roll": rl, "effect": eff})
    # exclusive table 2.7: | # | **Name** | Sub-type | HP/ATK | mod |
    for m in re.finditer(r"\|\s*(4[3-9]|5\d|6[0-6])\s*\|\s*\*\*(.+?)\*\*\s*\|\s*(.+?)\s*\|\s*\[(\d+)-(\d+)\]\s*/\s*\[(\d+)-(\d+)\]\s*\|\s*\*\*(.+?):\*\*\s*(.+?)\s*\|", txt):
        num, name, sub = int(m.group(1)), m.group(2).strip(), m.group(3).strip()
        hp = [int(m.group(4)), int(m.group(5))]
        atk = [int(m.group(6)), int(m.group(7))]
        modname, modtext = m.group(8).strip(), m.group(9).strip()
        excl.append({"id": re.sub(r"[^a-z0-9]+", "", name.lower()), "num": num, "name": name,
                     "sub": re.sub(r"[^a-z0-9]+", "", sub.lower()), "hp": hp, "atk": atk,
                     "modName": modname, "mod": modtext})
    return common, excl

# battle-engine effect vocabulary for the 42 common items (demo approximation of effect text)
COMMON_FX = {
 "cureblade": [["healOnDmg", 7]], "critblade": [["crit", 30], ["critMult", 165]],
 "meteorhammer": [["rangePlus", 1], ["ignoreDodge", 50]], "dualaxe": [["ragePerAtk", 1]],
 "crescentblade": [["dmgOut", 35], ["dmgIn", 100], ["ignoreDR", 20]],
 "longyuansword": [["atkPct", 15]], "chainmail": [["dmgFlatRed", 5]],
 "winegourd": [["regenPct", 2.5]], "dmgreflectionarmor": [["reflect", 5]],
 "coppershield": [["shieldOnLow", 10]], "goldenaxe": [["shieldOnHit", 6]],
 "ironshield": [["meleeRed", 22]], "leechsword": [["leech", 30]],
 "circleblade": [["leech", 15], ["dmgOut", 10]], "obsidianarmor": [["earlyDR", 60]],
 "radiantplatearmor": [["hpPct", 10]], "thousandtemperedblade": [["atkPct", 10]],
 "darts": [["truePct", 35]], "rattanshield": [["rangedRed", 45]],
 "mace": [["curHpPct", 3]], "armyflag": [["dmgOut", 20]],
 "qiankunsaber": [["aoeTrue", 45]], "sunfirearmor": [["roundTrue", 4]],
 "helmetofcalmness": [["hpPct", 15], ["regenPct", 1]], "puregoldshield": [["shieldPeriodic", 4]],
 "silverserpentwhip": [["newTargetDmg", 35]], "lamellarcuirass": [["dmgCap", 22]],
 "hookswords": [["trueProc", 25], ["trueProcPct", 3]], "mirrorarmor": [["stackDR", 4]],
 "battleaxe": [["below50Atk", 15], ["leech", 20]], "jadependant": [["allyShield", 8]],
 "lethalumbrella": [["atkPct", 10], ["dmgIn", -10]], "ringofburningheart": [["burn", 30]],
 "billhook": [["atkBasedPct", 6]], "bloodragebelt": [["castHeal", 40], ["rageOnHit", 40]],
 "spikedmace": [["killAoe", 75]], "dodgeboots": [["dodge", 22]],
 "flyingguillotine": [["execute", 12]], "timeflag": [["hpFlat", 60]],
 "hourglass": [["doubleAct", 15]], "blindingpendant": [["stunOnTrue", 22]],
 "darksteelstaff": [["newTargetTrue", 17]],
}

# exclusive skill-mod keys understood by battle.js (one per sub-type)
EXCL_MOD = {
 43: "stab_dodge", 44: "project_count", 45: "disarm_aoe", 46: "steady_attack", 47: "whirlwind_heal",
 48: "dance_parry", 49: "shield_maxhp", 50: "stance_perenemy", 51: "charge_maxhp", 52: "earthshaker_rage",
 53: "guardian_counter", 54: "whirl_bounce", 55: "scatter_multi", 56: "dexterity", 57: "poison_paralysis",
 58: "inspire_heal", 59: "anchor_kb", 60: "wildfire", 61: "leap_repeat", 62: "sweep_leech",
 63: "chop_keep", 64: "collide_stun", 65: "guerrilla", 66: "cleave_shield",
}

# ---------------------------------------------------------------- bestiary (from Battle Guide and Plot Recap.md, verified)
BESTIARY = [
 dict(id="wolf", name="Wolf", kind="beast", level=2, hp=60, rage=[6,6], move=4, atk=17, range=1, spd=8,
      skill=dict(name="Wolf Howl", type="active", desc="Inspires all allies within 5 tiles: +3 ATK and +20% DMG Reduction for 3 rounds.")),
 dict(id="leopard", name="Leopard", kind="beast", level=2, hp=88, rage=[0,0], move=4, atk=20, range=1, spd=7,
      skill=dict(name="Evade", type="passive", desc="Every 2 times hit, gains 100% Dodge against the next incoming DMG.")),
 dict(id="porcupine", name="Porcupine", kind="beast", level=2, hp=91, rage=[4,8], move=3, atk=16, range=1, spd=7,
      skill=dict(name="Spine Burst", type="active", desc="Deals 75% ATK DMG to enemies within 1 tile.")),
 dict(id="viper", name="Viper", kind="beast", level=2, hp=72, rage=[4,8], move=3, atk=17, range=2, spd=6,
      skill=dict(name="Venom Spit", type="active", desc="70% ATK DMG to 1 target + Poison: 10% of current HP as True DMG each round for 3 rounds.")),
 dict(id="lion", name="Lion", kind="beast", level=3, hp=394, rage=[5,10], move=4, atk=20, range=1, spd=7,
      skill=dict(name="Tear", type="active", desc="120% ATK DMG + bleed: 50% ATK True DMG/round and HP Restoration -60% for 3 rounds.")),
 dict(id="elephant", name="Elephant", kind="beast", level=3, hp=473, rage=[5,10], move=3, atk=31, range=1, spd=9,
      skill=dict(name="Sling", type="active", desc="200% ATK DMG to the highest-HP target within 5 tiles.")),
 dict(id="bear", name="Bear", kind="beast", level=3, hp=368, rage=[6,12], move=3, atk=25, range=1, spd=9,
      skill=dict(name="Smash", type="active", desc="Extra 5% of target Max HP DMG and stuns 1 round.")),
 dict(id="lizard", name="Lizard", kind="beast", level=3, hp=221, rage=[0,0], move=3, atk=23, range=1, spd=9,
      skill=dict(name="Scale Armor", type="passive", desc="DMG taken -40%.")),
 dict(id="hedgehog", name="Hedgehog", kind="beast", level=4, hp=622, rage=[0,0], move=3, atk=26, range=1, spd=9,
      skill=dict(name="DMG Reflection", type="passive", desc="Reflects 35% of DMG taken to the attacker.")),
 dict(id="buffalo", name="Buffalo", kind="beast", level=5, hp=725, rage=[6,12], move=3, atk=33, range=1, spd=9,
      skill=dict(name="Wild Collision", type="active", desc="Collides 2 tiles, knocks up enemies, 50% ATK DMG. Breaks Shields and Shield Stance.")),
 dict(id="tiger", name="Tiger", kind="beast", level=5, hp=648, rage=[4,8], move=3, atk=35, range=1, spd=7,
      skill=dict(name="Gash", type="active", desc="Extra 35% ATK DMG to up to 20 enemies within 1 tile around the target.")),
 dict(id="rhino", name="Rhino", kind="beast", level=5, hp=671, rage=[4,8], move=3, atk=28, range=1, spd=9,
      skill=dict(name="Trample", type="active", desc="75% ATK DMG to up to 8 units within 1 tile + stun 1 round.")),
 dict(id="goat", name="Goat", kind="beast", level=8, hp=1213, rage=[4,8], move=0, atk=80, range=6, spd=9, boss=True,
      skill=dict(name="Rampant Charge", type="active", desc="Knocks target to the most crowded place within 6 tiles; 15% Max HP True DMG to up to 8 within 2 tiles + stun 1 round."),
      passive=dict(name="Iron Mountain Stance", desc="Unable to move. Ignores 70% DMG Reduction when attacking; attacker's DMG -70% when attacked.")),
 dict(id="rat", name="Rat", kind="beast", level=8, hp=1206, rage=[0,0], move=0, atk=71, range=6, spd=9, boss=True,
      skill=dict(name="Pestilence Infection", type="passive", desc="When attacked from within 2 tiles, infects the attacker with 1 layer of Pestilence: 5% Max HP True DMG/round, stackable without limit."),
      passive=dict(name="Iron Mountain Stance", desc="Unable to move. Ignores 70% DMG Reduction when attacking; attacker's DMG -70% when attacked.")),
 dict(id="ape", name="Ape", kind="beast", level=8, hp=1052, rage=[4,6], move=0, atk=88, range=6, spd=9, boss=True,
      skill=dict(name="Fury", type="active", desc="Removes debuffs; next 2 attacks deal 300% ATK DMG + 50% splash True DMG to up to 8 within 2 tiles."),
      passive=dict(name="Iron Mountain Stance", desc="Unable to move. Ignores 70% DMG Reduction when attacking; attacker's DMG -70% when attacked.")),
 dict(id="minion", name="Minion", kind="bandit", level=6, hp=611, rage=[0,0], move=3, atk=29, range=1, spd=8,
      skill=None),
 dict(id="assassin", name="Assassin", kind="bandit", level=6, hp=533, rage=[0,0], move=3, atk=37, range=1, spd=6,
      skill=dict(name="Crit", type="passive", desc="Attacks have a 99% chance to deal 150% DMG.")),
 dict(id="banditsaberman", name="Bandit Saberman", kind="bandit", level=6, hp=625, rage=[0,0], move=3, atk=31, range=1, spd=9,
      skill=None),
 dict(id="banditbowman", name="Bandit Bowman", kind="bandit", level=6, hp=247, rage=[0,4], move=2, atk=20, range=4, spd=6,
      skill=dict(name="Snipe", type="active", desc="Deals additional DMG equal to 10% of the target's current HP. Bowman-type: counters Spearman.")),
 dict(id="boarknight6", name="Boar Knight", kind="bandit", level=6, hp=737, rage=[0,0], move=4, atk=70, range=1, spd=7,
      skill=dict(name="Counter Shield Soldier", type="passive", desc="Vs Shieldman: ATK +40%, ignores 20% DMG Reduction; attacked by Shieldman: attacker ATK -40%."),
      passive=dict(name="Fortitude", type="passive", desc="Ranged DMG taken -60%.")),
 dict(id="boarknight7", name="Boar Knight", kind="bandit", level=7, hp=827, rage=[0,0], move=4, atk=85, range=1, spd=7,
      skill=dict(name="Counter Shield Soldier", type="passive", desc="Vs Shieldman: ATK +40%, ignores 20% DMG Reduction; attacked by Shieldman: attacker ATK -40%."),
      passive=dict(name="Fortitude", type="passive", desc="Ranged DMG taken -60%.")),
 dict(id="soulreaper", name="Soulreaper", kind="bandit", level=10, hp=1074, rage=[4,6], move=0, atk=125, range=6, spd=6, boss=True,
      skill=dict(name="Frenzy Claw", type="active", desc="Gashes nearest target + up to 8 within 2 tiles, 3x 20% DMG; next gash +5% each, stackable without limit."),
      passive=dict(name="Iron Mountain Stance", desc="Unable to move. Ignores 70% DMG Reduction when attacking; attacker's DMG -70% when attacked.")),
]

# ---------------------------------------------------------------- plot rules (user-confirmed)
DIFFS = []
for t, n in [("Easy", 3), ("Entry", 3), ("Common", 4), ("Advanced", 4), ("Hard", 4), ("Hell", 2)]:
    for i in range(1, n + 1):
        DIFFS.append("%s %d" % (t, i))
PLOT_RANGES = {1: (0, 6), 2: (5, 8), 3: (9, 12), 4: (13, 17), 5: (17, 19)}  # index into DIFFS

MAP_W, MAP_H = 18, 12
P_CAPITAL = dict(col=2, row=6)
E_CAPITAL = dict(col=15, row=6)
PLOTS = [
 dict(id="p1",  col=4,  row=3,  res="wood",  level=1),
 dict(id="p2",  col=5,  row=9,  res="stone", level=1),
 dict(id="p3",  col=6,  row=5,  res="crop",  level=1),
 dict(id="p4",  col=7,  row=2,  res="crop",  level=2),
 dict(id="p5",  col=7,  row=10, res="wood",  level=2),
 dict(id="p6",  col=9,  row=4,  res="stone", level=2),
 dict(id="p7",  col=10, row=8,  res="crop",  level=3),
 dict(id="p8",  col=12, row=3,  res="wood",  level=3, guardian="ape"),
 dict(id="p9",  col=12, row=9,  res="crop",  level=3, guardian="rat"),
 dict(id="p10", col=13, row=10, res="stone", level=3, guardian="goat"),
 dict(id="p11", col=11, row=6,  res="wood",  level=4),
 dict(id="p12", col=13, row=3,  res="stone", level=4, boars=True),
 dict(id="p13", col=15, row=10, res="crop",  level=5, boars=True),
 dict(id="p14", col=15, row=2,  res="stone", level=5, soulreaper=True),
]

def garrison_for(p):
    lv, g = p["level"], []
    if lv == 1: g = ["wolf", "wolf", "leopard"]
    elif lv == 2: g = ["porcupine", "viper", "wolf"]
    elif lv == 3:
        g = [p.get("guardian"), "tiger", "rhino"] if p.get("guardian") else ["tiger", "rhino", "buffalo"]
    elif lv == 4:
        g = ["boarknight7"] * 4 + ["minion", "assassin"] if p.get("boars") else ["minion", "banditsaberman", "banditbowman", "assassin"]
    elif lv == 5:
        if p.get("soulreaper"): g = ["soulreaper"] + ["boarknight7"] * 4
        else: g = ["boarknight7"] * 4 + ["minion", "assassin", "banditsaberman", "banditbowman"]
    return g

ENEMY_CAPITAL_GARRISON = ["boarknight7"] * 4 + ["assassin"] * 2 + ["banditbowman"] * 2 + ["minion"] * 2 + ["banditsaberman"] * 2

# ---------------------------------------------------------------- emit
def main():
    soldiers, weaponry = parse_soldiers()
    heroes, expertise = parse_heroes()
    common, excl = parse_equipment()
    # canonical sub-type resolver: link hero possession & exclusive equipment to soldier ids
    def canon(s):
        s = s.lower().strip()
        if s.endswith("soldier"):
            s = s[:-len("soldier")]
        s = s.replace("and", "")
        return re.sub(r"[^a-z0-9]+", "", s)
    CANON = {canon(s["name"]): s["id"] for s in soldiers}
    for h in heroes:
        h["subId"] = CANON.get(canon(h["possession"]), "")
    for e in excl:
        e["subId"] = CANON.get(canon(e["sub"]), "")
    for e in common:
        e["fx"] = COMMON_FX.get(e["id"], [])
    for e in excl:
        e["modKey"] = EXCL_MOD.get(e["num"], "")
    # expertise numeric fx (demo: use max tier)
    def exp_fx(text):
        fx = []
        def tiers3(p):
            m = re.search(p, text)
            return [int(x) for x in m.groups()] if m else None
        m = re.search(r"ATK \+\[(\d+)/(\d+)/(\d+)\]", text)
        if m: fx.append(["atkFlat", int(m.group(3))])
        m = re.search(r"HP \+\[(\d+)/(\d+)/(\d+)\]", text)
        if m: fx.append(["hpFlat", int(m.group(3))])
        m = re.search(r"ATK \+\[(\d+)/(\d+)/(\d+)\]%", text)
        if m: fx.append(["atkPct", int(m.group(3))])
        m = re.search(r"HP \+\[(\d+)/(\d+)/(\d+)\]%", text)
        if m: fx.append(["hpPct", int(m.group(3))])
        if "DMG dealt by" in text:
            m = re.search(r"\+\[(\d+)/(\d+)/(\d+)\]%", text)
            if m: fx.append(["dmgOut", int(m.group(3))])
        if "DMG taken by" in text:
            m = re.search(r"-\[(\d+)/(\d+)/(\d+)\]%", text)
            if m: fx.append(["dmgIn", -int(m.group(3))])
        m = re.search(r"restores \[(\d+)/(\d+)/(\d+)\] HP each round", text)
        if m: fx.append(["regen", int(m.group(3))])
        m = re.search(r"\[(\d+)/(\d+)\]% Leech", text)
        if m: fx.append(["leech", int(m.group(2))])
        m = re.search(r"\[(\d+)/(\d+)\]% Dodge", text)
        if m and "ignores" not in text: fx.append(["dodge", int(m.group(2))])
        m = re.search(r"ignores \[(\d+)/(\d+)\]% Dodge", text)
        if m: fx.append(["ignoreDodge", int(m.group(2))])
        if "Max Rage -1" in text: fx.append(["maxRageMinus", 1])
        if "ATK Range +1" in text: fx.append(["rangePlus", 1])
        if "retain 1 Rage" in text: fx.append(["rageKeep", 40])
        if "30% chance to deal (30% * atk)" in text: fx.append(["trueProc", 30], ) or fx.append(["trueProcPct", 30])
        if "Converts 20%" in text: fx.append(["truePct", 20])
        m = re.search(r"\(\[(2|4)/(\d+)\]\*target's current HP\)", text)
        if m: fx.append(["curHpPct", int(m.group(2))])
        if "restores (5*own level) HP" in text: fx.append(["atkHeal", 5])
        if "HP Restoration +[15/30]%" in text: fx.append(["regenPct", 30])
        return fx
    for cat, tiers in expertise.items():
        for t, lst in tiers.items():
            expertise[cat][t] = [{"text": x, "fx": exp_fx(x)} for x in lst]

    data = {
        "soldiers": soldiers, "weaponry": weaponry, "heroes": heroes,
        "expertise": expertise, "commonEquipment": common, "exclusiveEquipment": excl,
        "bestiary": BESTIARY, "diffs": DIFFS, "plotRanges": {str(k): v for k, v in PLOT_RANGES.items()},
        "map": {"w": MAP_W, "h": MAP_H, "playerCapital": P_CAPITAL, "enemyCapital": E_CAPITAL, "plots": PLOTS},
        "garrisons": dict([ (p["id"], garrison_for(p)) for p in PLOTS ] + [("enemyCapital", ENEMY_CAPITAL_GARRISON)]),
        "typeTriangle": {"spear": "cavalry", "cavalry": "shield", "shield": "bow", "bow": "spear"},
        "reward": {"cap": 100, "perDay": 50, "firstCost": {1: 1, 2: 1, 3: 1, 4: 2, 5: 3}},
        "demoNotes": [
            "Battle is an auto-resolve simulation with a detailed log (tactical grid movement is planned for a later version).",
            "A team fights as one stack: HP = count x per-soldier HP, ATK = count x per-soldier ATK (design choice for the demo).",
            "Hero skills are displayed with full documented text; in-battle they apply a simplified archetype (damage/heal/rage/defense) - noted per hero.",
            "Equipment effects use the documented values where mechanical; complex procs are approximated (see Help tab).",
            "Expertise numeric bonuses use the maximum documented tier.",
            "Production/march/reward-point clocks are accelerated for the demo (1 game hour = 4 real seconds).",
            "Per-level soldier stats are interpolated linearly between the documented Lv1 and Lv6 bracket values.",
        ],
    }
    js = "const DATA = " + json.dumps(data, ensure_ascii=False, indent=1) + ";\n"
    js += "// Generated by gen_data.py from the project's verified RE documentation. Do not edit by hand.\n"
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with io.open(OUT, "w", encoding="utf-8") as f:
        f.write(js)
    print("soldiers:", len(soldiers), "weaponry:", len(weaponry))
    print("heroes:", len(heroes), "expertise cats:", {k: {t: len(v) for t, v in exp.items()} for k, exp in expertise.items()})
    print("common:", len(common), "exclusive:", len(excl))
    print("bestiary:", len(BESTIARY), "plots:", len(PLOTS), "diffs:", len(DIFFS))
    print("Wrote", OUT, len(js), "bytes")

if __name__ == "__main__":
    main()
