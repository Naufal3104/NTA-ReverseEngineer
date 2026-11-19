# -*- coding: utf-8 -*-
"""Extract asset catalog from NTA APK (Cocos Creator 2.4.x native build).

Maps UUID-named files in apk_extracted/assets/assets/<bundle>/native to their
original logical paths using each bundle's config.json (paths/uuids/types).

Output:
  asset_catalog/<logical path>.<ext>   (copy of plain assets: png/jpg/mp3/plist/fnt/...)
  asset_catalog/_unmapped/<bundle>/    (native files with no config path)
  asset_catalog_manifest.json          (uuid, type, path, source file, size, packed info)
Prints summary stats per category and per asset type.
"""
import json
import os
import base64
import binascii
import shutil
from collections import Counter, defaultdict

ROOT = r"D:\Android\NTA Project Reverse Engineering"
BASE = os.path.join(ROOT, "apk_extracted", "assets", "assets")
OUT = os.path.join(ROOT, "asset_catalog")
MANIFEST_OUT = os.path.join(ROOT, "asset_catalog_manifest.json")

B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"


def decomp_uuid(c):
    """Cocos 2.x compressed uuid (2 hex chars + base64 of remaining 15 bytes) -> full hyphenated uuid."""
    s = c[:2] + binascii.hexlify(base64.b64decode(c[2:] + "==")).decode()
    return "-".join([s[:8], s[8:12], s[12:16], s[16:20], s[20:]])


def scan_native(bundle):
    """Index native files: uuid -> list of (subpath, ext)."""
    native = os.path.join(BASE, bundle, "native")
    idx = defaultdict(list)
    if not os.path.isdir(native):
        return idx
    for dirpath, _dirnames, filenames in os.walk(native):
        for fn in filenames:
            stem, ext = os.path.splitext(fn)
            base = stem.split("@")[0]
            sub = stem.split("@")[1] if "@" in stem else None
            full = os.path.join(dirpath, fn)
            idx[base].append((sub, ext.lower(), full))
    return idx


EXT_CANDIDATES = {
    "cc.Texture2D": (".png", ".jpg", ".jpeg", ".webp"),
    "cc.SpriteFrame": (".png", ".jpg", ".jpeg", ".webp"),
    "cc.SpriteAtlas": (".plist", ".png"),
    "cc.AudioClip": (".mp3", ".wav", ".ogg", ".m4a"),
    "cc.BitmapFont": (".fnt", ".png"),
    "cc.JsonAsset": (".json",),
    "cc.Prefab": (".json",),
    "cc.AnimationClip": (".json",),
    "cc.Material": (".json",),
    "cc.TextAsset": (".txt", ".json", ".csv"),
    "cc.Asset": (".png", ".jpg", ".mp3", ".plist", ".fnt", ".bin", ".txt", ".json"),
}


def main():
    manifest = []
    type_counter = Counter()
    cat_counter = Counter()
    unmapped = []
    packed_entries = []

    bundles = sorted(os.listdir(BASE))
    for bundle in bundles:
        cfg_path = os.path.join(BASE, bundle, "config.json")
        if not os.path.isfile(cfg_path):
            continue
        cfg = json.load(open(cfg_path, encoding="utf-8"))
        types = cfg.get("types", [])
        uuids = cfg.get("uuids", [])
        paths = cfg.get("paths", {})
        packs = cfg.get("packs", {})
        encrypted = cfg.get("encrypted", False)

        # uuid index -> packed json file (serialized assets live inside packs)
        pack_of_index = {}
        for pack_key, idx_list in packs.items():
            for i in idx_list:
                pack_of_index[i] = pack_key

        disk = scan_native(bundle)

        for key, val in paths.items():
            try:
                i = int(key)
            except ValueError:
                continue
            if not isinstance(val, list) or len(val) < 2:
                continue
            logical_path, ti = val[0], val[1]
            type_name = types[ti] if ti < len(types) else "?"
            cuuid = uuids[i] if i < len(uuids) else None
            if cuuid is None:
                continue
            full_uuid = decomp_uuid(cuuid)
            exts = EXT_CANDIDATES.get(type_name, ())
            hits = disk.get(full_uuid, [])
            matched = False
            for sub, ext, src in hits:
                if ext in exts or type_name == "cc.Asset":
                    rel = logical_path + (("@%s" % sub) if sub else "") + ext
                    dst = os.path.join(OUT, bundle, rel.replace("\\", "/"))
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    shutil.copy2(src, dst)
                    manifest.append({"bundle": bundle, "uuid": full_uuid, "type": type_name,
                                     "path": rel, "src": os.path.relpath(src, ROOT), "size": os.path.getsize(src)})
                    type_counter[type_name] += 1
                    parts = rel.split("/")
                    cat_counter["/".join(parts[:2]) if len(parts) > 2 else parts[0]] += 1
                    matched = True
            if not matched:
                if i in pack_of_index:
                    packed_entries.append({"bundle": bundle, "uuid": full_uuid, "type": type_name,
                                           "path": logical_path, "pack": pack_of_index[i],
                                           "encrypted": encrypted})
                else:
                    unmapped.append({"bundle": bundle, "uuid": full_uuid, "type": type_name, "path": logical_path})

        # copy bundle config.json for reference
        dst_cfg = os.path.join(OUT, "_configs", "%s_config.json" % bundle)
        os.makedirs(os.path.dirname(dst_cfg), exist_ok=True)
        shutil.copy2(cfg_path, dst_cfg)

        # unmapped native files -> keep them, nothing lost
        mapped_uuids = {m["uuid"] for m in manifest if m["bundle"] == bundle}
        for uuid, hits in disk.items():
            if uuid in mapped_uuids:
                continue
            for _sub, ext, src in hits:
                rel = os.path.relpath(src, os.path.join(BASE, bundle, "native"))
                dst = os.path.join(OUT, "_unmapped", bundle, rel.replace("\\", "/"))
                os.makedirs(os.path.dirname(dst), exist_ok=True)
                shutil.copy2(src, dst)
                unmapped.append({"bundle": bundle, "uuid": uuid, "type": "?", "path": "_native/" + rel})

    json.dump({"assets": manifest, "packed_encrypted": packed_entries, "unmapped": unmapped},
              open(MANIFEST_OUT, "w", encoding="utf-8"), indent=1, ensure_ascii=False)

    total_copied = sum(type_counter.values())
    print("copied assets: %d" % total_copied)
    print("\nby type:")
    for t, n in type_counter.most_common():
        print("  %-18s %d" % (t, n))
    print("\nby category (top 2 path segments, top 30):")
    for c, n in cat_counter.most_common(30):
        print("  %-40s %d" % (c, n))
    print("\npacked (serialized, xxtea-encrypted json): %d entries in %d packs" % (len(packed_entries), 0))
    print("unmapped native files: %d" % len(unmapped))
    print("manifest: %s" % MANIFEST_OUT)
    print("catalog dir: %s" % OUT)


if __name__ == "__main__":
    main()
