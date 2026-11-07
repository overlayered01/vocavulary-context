"""Make the app icons (Android, iOS, web) from one source image.

    python -X utf8 tool/make_icons.py tool/icon_source.png

The source is a rounded-square icon on a white page. This script
1. recolors it to the app's slate theme (blue → slate gradient map,
   yellow → peach), keeping the shading,
2. crops to the rounded square and fills its corners so the square is
   full-bleed (iOS and Android adaptive icons apply their own mask),
3. writes every size the platforms need.
"""
import colorsys
import json
import pathlib
import sys

import cv2
import numpy as np
from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent

# Luminance → color for the blue parts (dark ink … slate … light gray-green).
GRADIENT = [
    (0.00, (0x1C, 0x24, 0x22)),
    (0.20, (0x2C, 0x37, 0x34)),
    (0.42, (0x46, 0x54, 0x4F)),
    (0.60, (0x76, 0x86, 0x80)),
    (0.76, (0xB4, 0xC1, 0xBC)),
    (0.90, (0xE3, 0xE9, 0xE6)),
    (1.00, (0xFF, 0xFF, 0xFF)),
]
PEACH_HUE = 28 / 360  # #F6C9A0
CORNER_RADIUS = 0.225  # of the icon size, close to the iOS/Android masks


def gradient_map(y: np.ndarray) -> np.ndarray:
    stops = np.array([s for s, _ in GRADIENT])
    colors = np.array([c for _, c in GRADIENT], dtype=np.float64)
    return np.stack(
        [np.interp(y, stops, colors[:, i]) for i in range(3)], axis=-1
    )


def recolor(rgb: np.ndarray) -> np.ndarray:
    f = rgb.astype(np.float64) / 255
    r, g, b = f[..., 0], f[..., 1], f[..., 2]
    hsv = cv2.cvtColor(rgb, cv2.COLOR_RGB2HSV_FULL).astype(np.float64) / 255
    hue, sat = hsv[..., 0], hsv[..., 1]
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    out = f * 255

    # Blue (and blue-tinted whites): gradient map by luminance.
    blue = ((hue > 170 / 360) & (hue < 260 / 360)).astype(np.float64)
    weight = blue * np.clip(sat * 4, 0, 1)
    out = out * (1 - weight[..., None]) + gradient_map(y) * weight[..., None]

    # Yellow / orange: shift to peach and soften saturation.
    yellow = (hue > 20 / 360) & (hue < 70 / 360) & (sat > 0.25)
    if yellow.any():
        flat = f[yellow]
        peach = []
        for pr, pg, pb in flat:
            _, s, v = colorsys.rgb_to_hsv(pr, pg, pb)
            peach.append(colorsys.hsv_to_rgb(PEACH_HUE, min(1, s * 0.5), v * 0.97))
        out[yellow] = np.array(peach) * 255
    return np.clip(out, 0, 255).astype(np.uint8)


def full_bleed(original: np.ndarray, rgb: np.ndarray) -> np.ndarray:
    """Crop to the rounded square and paint its white corners with nearby color.

    The square is found on the [original] (saturated blue) image.
    """
    hsv = cv2.cvtColor(original, cv2.COLOR_RGB2HSV)
    colored = (hsv[..., 1] > 60) & (hsv[..., 2] > 40)
    ys, xs = np.where(colored)
    # 가장자리의 흐린(안티앨리어싱) 줄은 버린다.
    inset = 6
    top, bottom = ys.min() + inset, ys.max() - inset
    left, right = xs.min() + inset, xs.max() - inset
    side = min(max(bottom - top, right - left) + 1,
               rgb.shape[0] - top, rgb.shape[1] - left)
    square = np.ascontiguousarray(rgb[top:top + side, left:left + side])
    # White page left in the corners: flood fill from each corner.
    mask = np.zeros((side + 2, side + 2), np.uint8)
    page = square.copy()
    for x, y in [(0, 0), (side - 1, 0), (0, side - 1), (side - 1, side - 1)]:
        cv2.floodFill(page, mask, (x, y), (0, 0, 0), (30, 30, 30), (30, 30, 30),
                      cv2.FLOODFILL_MASK_ONLY | cv2.FLOODFILL_FIXED_RANGE
                      | (255 << 8) | 8)
    corners = mask[1:-1, 1:-1]
    corners = cv2.dilate(corners, np.ones((7, 7), np.uint8))
    return cv2.inpaint(square, corners, 9, cv2.INPAINT_TELEA)


def rounded(img: Image.Image, radius: float = CORNER_RADIUS) -> Image.Image:
    size = img.size[0]
    scale = 4
    mask = Image.new('L', (size * scale, size * scale), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size * scale - 1, size * scale - 1],
        radius=int(size * scale * radius), fill=255)
    out = img.convert('RGBA')
    out.putalpha(mask.resize((size, size), Image.LANCZOS))
    return out


def save(img: Image.Image, path: pathlib.Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.resize((size, size), Image.LANCZOS).save(path, optimize=True)


def main() -> None:
    source = pathlib.Path(sys.argv[1])
    rgb = np.array(Image.open(source).convert('RGB'))
    square = Image.fromarray(full_bleed(rgb, recolor(rgb)))
    preview = rounded(square)

    # iOS: full-bleed, no alpha; iOS rounds the corners itself.
    ios = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    contents = json.loads((ios / 'Contents.json').read_text(encoding='utf-8'))
    for image in contents['images']:
        points = float(image['size'].split('x')[0])
        scale = int(image['scale'][0])
        save(square, ios / image['filename'], round(points * scale))

    # Android: legacy icon (rounded) + adaptive icon (full-bleed background
    # padded to 108dp, the visible 72dp is the square itself).
    res = ROOT / 'android/app/src/main/res'
    for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96),
                          ('xxhdpi', 144), ('xxxhdpi', 192)]:
        save(preview, res / f'mipmap-{density}/ic_launcher.png', size)
        full = round(size * 108 / 48)
        inner = round(size * 72 / 48)
        pad = (full - inner) // 2
        arr = np.array(square.resize((inner, inner), Image.LANCZOS))
        arr = np.pad(arr, ((pad, full - inner - pad), (pad, full - inner - pad), (0, 0)),
                     mode='edge')
        Image.fromarray(arr).save(res / f'mipmap-{density}/ic_launcher_background.png',
                                  optimize=True)
        Image.new('RGBA', (full, full), (0, 0, 0, 0)).save(
            res / f'mipmap-{density}/ic_launcher_foreground.png', optimize=True)
    anydpi = res / 'mipmap-anydpi-v26'
    anydpi.mkdir(exist_ok=True)
    (anydpi / 'ic_launcher.xml').write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '</adaptive-icon>\n', encoding='utf-8')

    # Web: rounded for normal icons and favicon, full-bleed for maskable.
    web = ROOT / 'web'
    save(preview, web / 'icons/Icon-192.png', 192)
    save(preview, web / 'icons/Icon-512.png', 512)
    save(square, web / 'icons/Icon-maskable-192.png', 192)
    save(square, web / 'icons/Icon-maskable-512.png', 512)
    save(preview, web / 'favicon.png', 32)
    print('icons written')


if __name__ == '__main__':
    main()
