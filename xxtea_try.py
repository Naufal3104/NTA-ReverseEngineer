# -*- coding: utf-8 -*-
"""Try candidate XXTEA keys against src/settings.jsc (268 bytes)."""
import struct
import sys

DELTA = 0x9E3779B9
MASK = 0xFFFFFFFF


def to_uints(b):
    b += b"\x00" * ((4 - len(b) % 4) % 4)
    return list(struct.unpack("<%dI" % (len(b) // 4), b))


def to_bytes(v):
    return struct.pack("<%dI" % len(v), *v)


def decrypt(v, key):
    n = len(v)
    if n < 2:
        return None
    v = list(v)
    z = v[n - 1]
    y = v[0]
    s = (6 + 52 // n) * DELTA & MASK
    while s != 0:
        e = (s >> 2) & 3
        for p in range(n - 1, 0, -1):
            z = v[p - 1]
            mx = (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((s ^ y) + (key[(p & 3) ^ e] ^ z))
            v[p] = (v[p] - mx) & MASK
            y = v[p]
        z = v[n - 1]
        mx = (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((s ^ y) + (key[0 ^ e] ^ z))
        v[0] = (v[0] - mx) & MASK
        y = v[0]
        s = (s - DELTA) & MASK
    return v


def key_to_words(key):
    kb = key.encode("utf-8")
    kb = (kb + b"\x00" * 16)[:16]
    return list(struct.unpack("<4I", kb))


def try_key(data, key_str):
    kw = key_to_words(key_str)
    v = to_uints(data)
    out = decrypt(v, kw)
    if out is None:
        return None
    raw = to_bytes(out)
    return raw


CANDIDATES = [
    "jwm", "JWM", "twomiles", "TwoMiles", "2miles", "twomiles.cn",
    "acres", "NinetyThousandAcres", "ninety", "90000", "90000acres",
    "twgame", "twgame.global.acers", "com.twgame.global.acers",
    "jwm-global", "jwm-global-file", "slg", "slg-hot-update", "cocos2d-jsb",
    "XXTEA", "xxtea", "4.5.0", "v4.5.0", "jwm4.5.0", "ht", "HT",
    "netht", "HTProtect", "cocos", "Cocos", "cococs2dx", "jiuwamu",
]

data = open(r"D:\Android\NTA Project Reverse Engineering\apk_extracted\assets\src\settings.jsc", "rb").read()
print("settings.jsc len:", len(data))
for c in CANDIDATES:
    raw = try_key(data, c)
    if raw is None:
        continue
    printable = sum(1 for b in raw if 32 <= b < 127 or b in (10, 13, 9))
    head = raw[:40]
    interesting = b"{" in raw[:8] or b"debug" in raw or b"rawUrl" in raw or printable > len(raw) * 0.9
    if interesting:
        print("CANDIDATE", repr(c), "printable%%=%.0f" % (100.0 * printable / len(raw)), "head:", head)
print("done")
