#!/usr/bin/env python3
"""Regenerates the Scrapbook app icon (a shark on an ocean-blue gradient) for
every platform from one source design.

    python3 scripts/make_icon.py        # needs Pillow

It writes:
  * assets/icon/*.png            -> source variants used by flutter_launcher_icons
  * macOS  AppIcon.appiconset    -> 16..1024 (rounded, with shadow)
  * iOS    AppIcon.appiconset    -> single 1024 (Xcode derives the rest)
  * Android mipmaps              -> via `dart run flutter_launcher_icons`
"""
import json
import os
import shutil
import subprocess
from PIL import Image, ImageDraw, ImageFilter

SS = 2                      # supersample factor for smooth edges
TOP = (56, 189, 248)        # sky-400
BOT = (37, 99, 235)         # blue-600
WHITE = (255, 255, 255, 255)
NAVY = (30, 41, 59, 255)
GILL = (96, 165, 250, 255)

APP = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
ASSETS = os.path.join(APP, "assets", "icon")
MACOS_SET = os.path.join(APP, "macos/Runner/Assets.xcassets/AppIcon.appiconset")
IOS_SET = os.path.join(APP, "ios/Runner/Assets.xcassets/AppIcon.appiconset")
WEB = os.path.join(APP, "web")
WEB_ICONS = os.path.join(WEB, "icons")

# Shark outline in a 1024 design space (facing right), centered ~(498, 507).
SHARK = [
    (838, 512), (775, 466), (690, 449), (600, 445),
    (560, 445), (505, 308), (452, 452),
    (378, 458), (300, 468),
    (256, 452), (158, 366), (250, 512), (175, 650), (258, 574),
    (300, 560), (378, 566),
    (452, 578), (412, 706), (528, 582),
    (610, 584), (700, 576), (775, 556),
]
BCX, BCY = 498, 507


def gradient(size):
    g = Image.new("RGBA", (size, size))
    d = ImageDraw.Draw(g)
    for y in range(size):
        t = y / (size - 1)
        d.line([(0, y), (size, y)], fill=(
            int(TOP[0] + (BOT[0] - TOP[0]) * t),
            int(TOP[1] + (BOT[1] - TOP[1]) * t),
            int(TOP[2] + (BOT[2] - TOP[2]) * t), 255))
    return g


def draw_shark(img, scale, cx, cy):
    d = ImageDraw.Draw(img)
    def T(x, y):
        return ((cx + (x - BCX) * scale) * SS, (cy + (y - BCY) * scale) * SS)
    d.polygon([T(x, y) for x, y in SHARK], fill=WHITE)
    ex, ey, er = 748, 492, 17
    d.ellipse([*T(ex - er, ey - er), *T(ex + er, ey + er)], fill=NAVY)
    d.line([T(836, 522), T(770, 550), T(702, 556)], fill=NAVY, width=7 * SS)
    for gx in (638, 663, 688):
        d.line([T(gx, 470), T(gx - 11, 512), T(gx, 552)], fill=GILL, width=5 * SS)


def render(size, *, rounded, shark_scale, with_shark, with_bg, shadow):
    W = size * SS
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    if with_bg:
        grad = gradient(W)
        if rounded:
            m, r = 96 * SS, 228 * SS
            mask = Image.new("L", (W, W), 0)
            ImageDraw.Draw(mask).rounded_rectangle(
                (m, m, W - m, W - m), radius=r, fill=255)
            bg = Image.new("RGBA", (W, W), (0, 0, 0, 0))
            bg.paste(grad, (0, 0), mask)
            img = Image.alpha_composite(img, bg)
        else:
            img = Image.alpha_composite(img, grad)
    if with_shark:
        draw_shark(img, shark_scale, size / 2, size / 2)
    img = img.resize((size, size), Image.LANCZOS)
    if shadow:
        sh = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        ImageDraw.Draw(sh).rounded_rectangle(
            (96, 110, size - 96, size - 82), radius=228, fill=(20, 20, 40, 110))
        sh = sh.filter(ImageFilter.GaussianBlur(26))
        img = Image.alpha_composite(sh, img)
    return img


def write_json(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=2)


def write_macos(rounded_1024):
    os.makedirs(MACOS_SET, exist_ok=True)
    for s in (16, 32, 64, 128, 256, 512, 1024):
        rounded_1024.resize((s, s), Image.LANCZOS).save(
            os.path.join(MACOS_SET, f"app_icon_{s}.png"))
    write_json(os.path.join(MACOS_SET, "Contents.json"), {
        "images": [
            {"size": "16x16", "idiom": "mac", "filename": "app_icon_16.png", "scale": "1x"},
            {"size": "16x16", "idiom": "mac", "filename": "app_icon_32.png", "scale": "2x"},
            {"size": "32x32", "idiom": "mac", "filename": "app_icon_32.png", "scale": "1x"},
            {"size": "32x32", "idiom": "mac", "filename": "app_icon_64.png", "scale": "2x"},
            {"size": "128x128", "idiom": "mac", "filename": "app_icon_128.png", "scale": "1x"},
            {"size": "128x128", "idiom": "mac", "filename": "app_icon_256.png", "scale": "2x"},
            {"size": "256x256", "idiom": "mac", "filename": "app_icon_256.png", "scale": "1x"},
            {"size": "256x256", "idiom": "mac", "filename": "app_icon_512.png", "scale": "2x"},
            {"size": "512x512", "idiom": "mac", "filename": "app_icon_512.png", "scale": "1x"},
            {"size": "512x512", "idiom": "mac", "filename": "app_icon_1024.png", "scale": "2x"},
        ],
        "info": {"author": "xcode", "version": 1},
    })


def write_ios(full_1024_rgb):
    os.makedirs(IOS_SET, exist_ok=True)
    for f in os.listdir(IOS_SET):
        if f.endswith(".png"):
            os.remove(os.path.join(IOS_SET, f))
    name = "Icon-App-1024x1024@1x.png"
    full_1024_rgb.save(os.path.join(IOS_SET, name))
    write_json(os.path.join(IOS_SET, "Contents.json"), {
        "images": [{"filename": name, "idiom": "universal",
                    "platform": "ios", "size": "1024x1024"}],
        "info": {"author": "xcode", "version": 1},
    })


def write_web():
    if not os.path.isdir(WEB):
        return
    os.makedirs(WEB_ICONS, exist_ok=True)
    reg = render(1024, rounded=False, shark_scale=0.82, with_shark=True,
                 with_bg=True, shadow=False).convert("RGB")
    # maskable: keep the shark in the center safe zone so launchers can crop.
    msk = render(1024, rounded=False, shark_scale=0.60, with_shark=True,
                 with_bg=True, shadow=False).convert("RGB")
    reg.resize((192, 192), Image.LANCZOS).save(os.path.join(WEB_ICONS, "Icon-192.png"))
    reg.resize((512, 512), Image.LANCZOS).save(os.path.join(WEB_ICONS, "Icon-512.png"))
    msk.resize((192, 192), Image.LANCZOS).save(os.path.join(WEB_ICONS, "Icon-maskable-192.png"))
    msk.resize((512, 512), Image.LANCZOS).save(os.path.join(WEB_ICONS, "Icon-maskable-512.png"))
    # iOS home-screen icon (Safari rounds it) + favicon.
    reg.resize((180, 180), Image.LANCZOS).save(os.path.join(WEB, "apple-touch-icon.png"))
    reg.resize((32, 32), Image.LANCZOS).save(os.path.join(WEB, "favicon.png"))


def write_android():
    dart = shutil.which("dart") or shutil.which("flutter")
    if not dart:
        print("! dart/flutter not on PATH — run `dart run flutter_launcher_icons` "
              "yourself for Android.")
        return
    subprocess.run(["dart", "run", "flutter_launcher_icons"], cwd=APP, check=False)


def main():
    os.makedirs(ASSETS, exist_ok=True)

    full = render(1024, rounded=False, shark_scale=0.82, with_shark=True,
                  with_bg=True, shadow=False).convert("RGB")
    full.save(os.path.join(ASSETS, "icon_full.png"))
    render(1024, rounded=False, shark_scale=1, with_shark=False,
           with_bg=True, shadow=False).convert("RGB").save(
        os.path.join(ASSETS, "icon_bg.png"))
    render(1024, rounded=False, shark_scale=0.74, with_shark=True,
           with_bg=False, shadow=False).save(
        os.path.join(ASSETS, "icon_foreground.png"))
    macos = render(1024, rounded=True, shark_scale=1.0, with_shark=True,
                   with_bg=True, shadow=True)
    macos.save(os.path.join(ASSETS, "icon_macos.png"))

    write_macos(macos)
    write_ios(full)
    write_web()
    write_android()
    print("✓ icons regenerated for macOS, iOS, web and Android")


if __name__ == "__main__":
    main()
