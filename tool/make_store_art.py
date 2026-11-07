"""Google Play 그래픽: 512 아이콘과 1024x500 그래픽 이미지(en, ko)를 store/에 만든다.

    python tool/make_store_art.py .
"""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
root = sys.argv[1]
src = Image.open(f"{root}/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png").convert("RGBA")

# 512 icon: full-bleed square, Play applies its own mask.
src.resize((512, 512), Image.LANCZOS).save(f"{root}/store/icon-512.png")

W, H = 1024, 500
TOP, BOT = (0x72, 0x83, 0x7F), (0x33, 0x3F, 0x3B)  # icon background tones
PEACH = (0xF6, 0xC9, 0xA0)
def background():
    bg = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(bg)
    for y in range(H):
        t = y / (H - 1)
        d.line([(0, y), (W, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(TOP, BOT)))
    return bg.convert("RGBA")

def rounded(img, r):
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, img.size[0]-1, img.size[1]-1], r, fill=255)
    out = img.copy(); out.putalpha(m); return out

def make(lang, headline, sub, font_bold, font_reg, out):
    bg = background()
    size = 300
    icon = rounded(src.resize((size, size), Image.LANCZOS), int(size * 0.225))
    x, y = 88, (H - size) // 2
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sm = Image.new("L", (size, size), 0)
    ImageDraw.Draw(sm).rounded_rectangle([0, 0, size-1, size-1], int(size*0.225), fill=110)
    shadow.paste((0, 0, 0, 255), (x, y + 14), sm)
    bg = Image.alpha_composite(bg, shadow.filter(ImageFilter.GaussianBlur(18)))
    bg.alpha_composite(icon, (x, y))
    d = ImageDraw.Draw(bg)
    tx = x + size + 64
    maxw = W - tx - 56
    # Fit headline (may wrap to two lines).
    fs = 58
    while True:
        f = ImageFont.truetype(font_bold, fs)
        lines = headline  # explicit line breaks
        if all(d.textlength(l, font=f) <= maxw for l in lines) or fs <= 36: break
        fs -= 2
    fsub = ImageFont.truetype(font_reg, 28)
    lh = int(fs * 1.18)
    block = lh * len(lines) + 28 + 34
    ty = (H - block) // 2
    d.rectangle([tx, ty - 26, tx + 56, ty - 20], fill=PEACH)
    for i, line in enumerate(lines):
        d.text((tx, ty + i * lh), line, font=f, fill=(255, 255, 255))
    d.text((tx, ty + lh * len(lines) + 24), sub, font=fsub, fill=(0xE3, 0xE9, 0xE6))
    bg.convert("RGB").save(out)

F = f"{root}/assets/fonts"
make("en", ["Learn words in", "real sentences"], "Vocab with Examples",
     f"{F}/Outfit-SemiBold.ttf", f"{F}/Outfit-Regular.ttf", f"{root}/store/feature-graphic-en.png")
make("ko", ["단어는", "예문으로 외우세요"], "예문 단어장",
     "C:/Windows/Fonts/malgunbd.ttf", "C:/Windows/Fonts/malgun.ttf", f"{root}/store/feature-graphic-ko.png")
