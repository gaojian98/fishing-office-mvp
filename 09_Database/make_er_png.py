from __future__ import annotations

import struct
import zlib
from pathlib import Path

W, H = 1800, 1200

BG = (15, 23, 42)
WHITE = (255, 255, 255)
BOXES = [
    ((70, 190, 520, 220), (29, 78, 216)),
    ((640, 190, 520, 220), (15, 118, 110)),
    ((1210, 190, 520, 220), (124, 58, 237)),
    ((355, 500, 1090, 250), (51, 65, 85)),
    ((70, 790, 520, 250), (22, 101, 52)),
    ((640, 790, 520, 250), (146, 64, 14)),
    ((1210, 790, 520, 250), (190, 18, 60)),
]

FONT = {
    "A": ["01110","10001","10001","11111","10001","10001","10001"],
    "B": ["11110","10001","10001","11110","10001","10001","11110"],
    "C": ["01110","10001","10000","10000","10000","10001","01110"],
    "D": ["11110","10001","10001","10001","10001","10001","11110"],
    "E": ["11111","10000","10000","11110","10000","10000","11111"],
    "F": ["11111","10000","10000","11110","10000","10000","10000"],
    "G": ["01110","10001","10000","10111","10001","10001","01110"],
    "H": ["10001","10001","10001","11111","10001","10001","10001"],
    "I": ["01110","00100","00100","00100","00100","00100","01110"],
    "J": ["00111","00010","00010","00010","10010","10010","01100"],
    "K": ["10001","10010","10100","11000","10100","10010","10001"],
    "L": ["10000","10000","10000","10000","10000","10000","11111"],
    "M": ["10001","11011","10101","10101","10001","10001","10001"],
    "N": ["10001","11001","10101","10011","10001","10001","10001"],
    "O": ["01110","10001","10001","10001","10001","10001","01110"],
    "P": ["11110","10001","10001","11110","10000","10000","10000"],
    "Q": ["01110","10001","10001","10001","10101","10010","01101"],
    "R": ["11110","10001","10001","11110","10100","10010","10001"],
    "S": ["01111","10000","10000","01110","00001","00001","11110"],
    "T": ["11111","00100","00100","00100","00100","00100","00100"],
    "U": ["10001","10001","10001","10001","10001","10001","01110"],
    "V": ["10001","10001","10001","10001","01010","01010","00100"],
    "W": ["10001","10001","10001","10101","10101","11011","10001"],
    "X": ["10001","01010","00100","00100","00100","01010","10001"],
    "Y": ["10001","01010","00100","00100","00100","00100","00100"],
    "Z": ["11111","00010","00100","01000","10000","10000","11111"],
    "0": ["01110","10001","10011","10101","11001","10001","01110"],
    "1": ["00100","01100","00100","00100","00100","00100","01110"],
    "2": ["01110","10001","00001","00010","00100","01000","11111"],
    "3": ["11110","00001","00001","01110","00001","00001","11110"],
    "4": ["00010","00110","01010","10010","11111","00010","00010"],
    "5": ["11111","10000","10000","11110","00001","00001","11110"],
    "6": ["01110","10000","10000","11110","10001","10001","01110"],
    "7": ["11111","00001","00010","00100","01000","01000","01000"],
    "8": ["01110","10001","10001","01110","10001","10001","01110"],
    "9": ["01110","10001","10001","01111","00001","00001","01110"],
    " ": ["00000"] * 7,
    "/": ["00001","00010","00100","01000","10000","00000","00000"],
    "-": ["00000","00000","00000","01110","00000","00000","00000"],
    ":": ["00000","00100","00100","00000","00100","00100","00000"],
    ",": ["00000","00000","00000","00000","00100","00100","01000"],
    ".": ["00000","00000","00000","00000","00000","01100","01100"],
    "(": ["00010","00100","01000","01000","01000","00100","00010"],
    ")": ["01000","00100","00010","00010","00010","00100","01000"],
    "&": ["01100","10010","10100","01000","10101","10010","01101"],
}


def canvas():
    return bytearray([*BG] * (W * H))


def set_px(buf, x, y, c):
    if 0 <= x < W and 0 <= y < H:
        i = (y * W + x) * 3
        buf[i:i+3] = bytes(c)


def rect(buf, x, y, w, h, c):
    for yy in range(y, y + h):
        if 0 <= yy < H:
            start = max(x, 0)
            end = min(x + w, W)
            i = (yy * W + start) * 3
            buf[i:i+(end-start)*3] = bytes(c) * (end - start)


def line(buf, x0, y0, x1, y1, c, t=4):
    dx = abs(x1 - x0)
    dy = -abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx + dy
    while True:
        rect(buf, x0 - t // 2, y0 - t // 2, t, t, c)
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 >= dy:
            err += dy
            x0 += sx
        if e2 <= dx:
            err += dx
            y0 += sy


def draw_char(buf, x, y, ch, c, scale=4):
    pattern = FONT.get(ch, FONT[" "])
    for row, bits in enumerate(pattern):
        for col, bit in enumerate(bits):
            if bit == "1":
                rect(buf, x + col * scale, y + row * scale, scale, scale, c)


def draw_text(buf, x, y, text, c, scale=4, line_gap=10):
    yy = y
    for raw_line in text.split("\n"):
        xx = x
        for ch in raw_line.upper():
            draw_char(buf, xx, yy, ch, c, scale)
            xx += scale * 6
        yy += scale * 8 + line_gap


def save_png(path: Path, buf: bytearray):
    raw = bytearray()
    for y in range(H):
        raw.append(0)
        raw.extend(buf[y * W * 3:(y + 1) * W * 3])

    def chunk(tag, data):
        return (
            struct.pack("!I", len(data))
            + tag
            + data
            + struct.pack("!I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    png = bytearray(b"\x89PNG\r\n\x1a\n")
    png += chunk(b"IHDR", struct.pack("!IIBBBBB", W, H, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    path.write_bytes(png)


def main():
    buf = canvas()
    rect(buf, 40, 50, 1720, 90, (30, 41, 59))
    draw_text(buf, 70, 72, "FishingOffice Database ER Diagram", WHITE, scale=4, line_gap=0)

    for (x, y, w, h), color in BOXES:
        rect(buf, x, y, w, h, color)

    # connector lines
    line(buf, 590, 300, 640, 300, (226, 232, 240), 5)
    line(buf, 1160, 300, 1210, 300, (226, 232, 240), 5)
    line(buf, 900, 410, 900, 500, (226, 232, 240), 5)
    line(buf, 900, 750, 900, 790, (226, 232, 240), 5)
    line(buf, 330, 410, 330, 500, (226, 232, 240), 5)
    line(buf, 1470, 410, 1470, 500, (226, 232, 240), 5)

    draw_text(buf, 110, 230, "PLAYER\nUSER ACCOUNT\nWALLET\nINVENTORY\nCOMPANION\nRELATIONSHIP\nMEANING\nSTORY\nMEMORY", WHITE, scale=3, line_gap=4)
    draw_text(buf, 680, 230, "WORLD\nWEATHER\nTODAY\nFISHING SESSION", WHITE, scale=3, line_gap=4)
    draw_text(buf, 1250, 230, "FISH\nFISHING SESSION\nINVENTORY\nWALLET TRANSACTION\nCOMPANION", WHITE, scale=3, line_gap=4)
    draw_text(buf, 395, 545, "FISHING SESSION\nLINKS PLAYER, FISH, WORLD, WEATHER\nSETTLES WALLET TRANSACTION / MEMORY / MEANING", WHITE, scale=3, line_gap=4)
    draw_text(buf, 110, 830, "INVENTORY\nPLAYER ITEMS AND RESOURCES", WHITE, scale=3, line_gap=4)
    draw_text(buf, 680, 830, "RELATIONSHIP / MEANING\nINDEPENDENT NARRATIVE STATE\nLINKED BY PLAYER", WHITE, scale=3, line_gap=4)
    draw_text(buf, 1250, 830, "STORY / MEMORY / TRANSACTION\nLONG-TERM RECORDS AND LEDGER", WHITE, scale=3, line_gap=4)

    save_png(Path(__file__).with_name("ER_Diagram.png"), buf)


if __name__ == "__main__":
    main()

