"""Render docs/statusline.png from the same colors and bar ramp as statusline.py.

Usage: python docs/render.py [output.png]
Needs Pillow and a monospace font with braille glyphs (Cascadia Mono, JetBrains Mono, DejaVu Sans Mono).
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import statusline as sl  # noqa: E402

SCALE = 2
FONT_SIZE = 22 * SCALE
PAD_X, PAD_Y = 28 * SCALE, 22 * SCALE
GAP = 10 * SCALE
PILL_PAD_Y = 6 * SCALE
BG = (26, 27, 38)

FONT_CANDIDATES = [
    r"C:\Windows\Fonts\CascadiaMono.ttf",
    r"C:\Windows\Fonts\JetBrainsMono-Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf",
    "/Library/Fonts/JetBrainsMono-Bold.ttf",
]


def load_font():
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            font = ImageFont.truetype(path, FONT_SIZE)
            try:
                font.set_variation_by_name(b"Bold")
            except Exception:
                try:
                    font.set_variation_by_axes([700])
                except Exception:
                    pass
            return font
    return ImageFont.load_default(FONT_SIZE)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "statusline.png")
    font = load_font()
    bar_w = 7
    pills = [
        (" Opus 5 ", sl.MODEL_BG, sl.FG),
        (" $12.40 ", sl.COST_BG, sl.FG),
        (f" ctx {sl.gradient_bar(44, bar_w)} 44% ", sl.CTX_BG, sl.FG),
        (f" 5h {sl.gradient_bar(33, bar_w)} 33% ", sl.FIVE_BG, sl.FG),
        (" 7d 18% ", sl.SEVEN_BG, sl.FG),
    ]
    probe = ImageDraw.Draw(Image.new("RGB", (10, 10)))
    ascent, descent = font.getmetrics()
    line_h = ascent + descent
    widths = [probe.textlength(t, font=font) for t, _, _ in pills]
    total_w = int(sum(widths) + GAP * (len(pills) - 1) + PAD_X * 2)
    total_h = int(line_h + PILL_PAD_Y * 2 + PAD_Y * 2)
    img = Image.new("RGB", (total_w, total_h), BG)
    draw = ImageDraw.Draw(img)
    x = PAD_X
    y = PAD_Y
    for (text, bg, fg), w in zip(pills, widths):
        draw.rectangle([x, y, x + w, y + line_h + PILL_PAD_Y * 2], fill=bg)
        draw.text((x, y + PILL_PAD_Y), text, font=font, fill=fg)
        x += w + GAP
    img.save(out, optimize=True)
    print(out, img.size)


if __name__ == "__main__":
    main()
