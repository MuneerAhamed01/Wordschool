#!/usr/bin/env python3
"""Generate Google Play Store feature graphic and phone screenshots for WordSchool."""

from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "playstore"

# WordSchool design tokens (from lib/config/themes/colors.dart)
C = {
    "bg": (18, 18, 19),
    "surface": (26, 26, 27),
    "surface_up": (37, 37, 38),
    "border": (58, 58, 60),
    "tile_empty": (18, 18, 19),
    "tile_filled": (86, 86, 88),
    "tile_correct": (83, 141, 78),
    "tile_present": (181, 159, 59),
    "tile_absent": (58, 58, 60),
    "text_muted": (129, 131, 132),
    "streak": (245, 121, 58),
    "accent": (106, 170, 100),
    "white": (255, 255, 255),
    "key": (129, 131, 132),
    "key_action": (86, 86, 88),
}


def _font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    return ImageFont.load_default()


def _draw_flame(draw: ImageDraw.ImageDraw, x: int, y: int, size: int = 24) -> None:
    draw.polygon(
        [(x + size // 2, y), (x + size, y + size), (x + size // 2, y + size + 6), (x, y + size)],
        fill=C["white"],
    )


def _draw_play_icon(draw: ImageDraw.ImageDraw, x: int, y: int, size: int = 18) -> None:
    draw.polygon(
        [(x, y), (x, y + size), (x + size, y + size // 2)],
        fill=C["white"],
    )


def _rounded_rect(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int, int, int],
    radius: int,
    fill: tuple[int, int, int],
    outline: tuple[int, int, int] | None = None,
    width: int = 2,
) -> None:
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def _tile(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    size: int,
    letter: str,
    color: tuple[int, int, int],
    border: tuple[int, int, int] | None = None,
) -> None:
    _rounded_rect(draw, (x, y, x + size, y + size), 8, color, border or color, 2)
    if letter:
        f = _font(int(size * 0.48), bold=True)
        bbox = draw.textbbox((0, 0), letter, font=f)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        draw.text((x + (size - tw) // 2, y + (size - th) // 2 - 2), letter, fill=C["white"], font=f)


def _draw_phone_frame(img: Image.Image, draw: ImageDraw.ImageDraw) -> None:
    w, h = img.size
    draw.rectangle((0, 0, w, h), fill=C["bg"])
    # Status bar
    draw.rectangle((0, 0, w, 54), fill=C["bg"])
    draw.ellipse((w // 2 - 42, 16, w // 2 + 42, 34), fill=C["surface_up"])


def _draw_app_bar(draw: ImageDraw.ImageDraw, w: int, title: str, streak: int | None = None) -> None:
    y0, y1 = 54, 118
    draw.rectangle((0, y0, w, y1), fill=C["bg"])
    f = _font(34, bold=True)
    bbox = draw.textbbox((0, 0), title, font=f)
    tw = bbox[2] - bbox[0]
    draw.text(((w - tw) // 2, y0 + 22), title, fill=C["white"], font=f)
    if streak is not None:
        chip_w, chip_h = 88, 44
        cx, cy = w - chip_w - 28, y0 + 24
        _rounded_rect(draw, (cx, cy, cx + chip_w, cy + chip_h), 22, C["streak"])
        sf = _font(22, bold=True)
        _draw_flame(draw, cx + 12, cy + 10, 20)
        draw.text((cx + 40, cy + 8), str(streak), fill=C["white"], font=sf)


def _draw_keyboard(draw: ImageDraw.ImageDraw, w: int, y: int) -> None:
    rows = [
        list("QWERTYUIOP"),
        list("ASDFGHJKL"),
        ["ENTER", *list("ZXCVBNM"), "⌫"],
    ]
    key_h = 52
    gap = 6
    for ri, row in enumerate(rows):
        row_y = y + ri * (key_h + gap)
        if ri < 2:
            total_w = len(row) * 34 + (len(row) - 1) * gap
            start_x = (w - total_w) // 2
            for i, ch in enumerate(row):
                x = start_x + i * (34 + gap)
                _rounded_rect(draw, (x, row_y, x + 34, row_y + key_h), 6, C["key"])
                f = _font(16, bold=True)
                bbox = draw.textbbox((0, 0), ch, font=f)
                tw = bbox[2] - bbox[0]
                draw.text((x + (34 - tw) // 2, row_y + 14), ch, fill=C["white"], font=f)
        else:
            x = 36
            for ch in row:
                kw = 72 if ch in ("ENTER", "⌫") else 34
                col = C["key_action"] if ch in ("ENTER", "⌫") else C["key"]
                _rounded_rect(draw, (x, row_y, x + kw, row_y + key_h), 6, col)
                label = ch if ch != "⌫" else "⌫"
                f = _font(14 if ch == "ENTER" else 16, bold=True)
                bbox = draw.textbbox((0, 0), label, font=f)
                tw = bbox[2] - bbox[0]
                draw.text((x + (kw - tw) // 2, row_y + 16), label, fill=C["white"], font=f)
                x += kw + gap


def screenshot_dashboard() -> Image.Image:
    w, h = 1080, 1920
    img = Image.new("RGB", (w, h), C["bg"])
    draw = ImageDraw.Draw(img)
    _draw_phone_frame(img, draw)

    title_f = _font(56, bold=True)
    draw.text((w // 2 - 210, 160), "WordSchool", fill=C["white"], font=title_f)
    sub_f = _font(28)
    draw.text((w // 2 - 195, 240), "Your daily word puzzle", fill=C["text_muted"], font=sub_f)

    # Stats card
    card = (60, 320, w - 60, 560)
    _rounded_rect(draw, card, 20, C["surface"], C["border"], 1)
    _draw_flame(draw, w // 2 - 70, 368, 28)
    sf = _font(64, bold=True)
    draw.text((w // 2 - 20, 350), "12", fill=C["streak"], font=sf)
    draw.text((w // 2 + 100, 380), "day streak", fill=C["text_muted"], font=_font(26))

    stats = [("42", "Played"), ("38", "Won"), ("15", "Best")]
    sx = 120
    for val, label in stats:
        draw.text((sx, 470), val, fill=C["accent"], font=_font(36, bold=True))
        draw.text((sx, 515), label, fill=C["text_muted"], font=_font(22))
        sx += 280

    # Primary CTA
    _rounded_rect(draw, (60, 620, w - 60, 720), 16, C["tile_correct"])
    _draw_play_icon(draw, w // 2 - 230, 658)
    draw.text((w // 2 - 195, 648), "Play Today's Puzzle", fill=C["white"], font=_font(30, bold=True))
    draw.text((w // 2 - 195, 750), "A new word is ready for you", fill=C["text_muted"], font=_font(22))

    tiles = [
        ("Previous Games", "Replay past daily puzzles", C["text_muted"]),
        ("Leaderboard", "Compete with friends", C["streak"]),
        ("Settings", "Account & preferences", C["text_muted"]),
    ]
    y = 820
    for title, sub, accent in tiles:
        _rounded_rect(draw, (60, y, w - 60, y + 110), 16, C["surface"], C["border"], 1)
        _rounded_rect(draw, (84, y + 28, 132, y + 82), 12, accent)
        draw.text((156, y + 28), title, fill=C["white"], font=_font(26, bold=True))
        draw.text((156, y + 62), sub, fill=C["text_muted"], font=_font(20))
        y += 130

    return img


def screenshot_gameplay() -> Image.Image:
    w, h = 1080, 1920
    img = Image.new("RGB", (w, h), C["bg"])
    draw = ImageDraw.Draw(img)
    _draw_phone_frame(img, draw)
    _draw_app_bar(draw, w, "WordSchool", streak=12)

    grid_data = [
        [("S", C["tile_present"]), ("E", C["tile_absent"]), ("R", C["tile_absent"]), ("I", C["tile_correct"]), ("A", C["tile_absent"])],
        [("P", C["tile_absent"]), ("O", C["tile_present"]), ("R", C["tile_present"]), ("T", C["tile_absent"]), ("S", C["tile_absent"])],
        [("W", C["tile_filled"]), ("O", C["tile_filled"]), ("R", C["tile_filled"]), ("D", C["tile_filled"]), ("S", C["tile_filled"])],
    ]
    tile = 88
    gap = 10
    grid_w = 5 * tile + 4 * gap
    gx = (w - grid_w) // 2
    gy = 400
    for ri, row in enumerate(grid_data):
        for ci, (letter, color) in enumerate(row):
            x = gx + ci * (tile + gap)
            y = gy + ri * (tile + gap)
            border = C["border"] if color == C["tile_filled"] else color
            _tile(draw, x, y, tile, letter, color, border)

    for ri in range(3, 6):
        for ci in range(5):
            x = gx + ci * (tile + gap)
            y = gy + ri * (tile + gap)
            _tile(draw, x, y, tile, "", C["tile_empty"], C["border"])

    draw.text((w // 2 - 95, gy + 6 * (tile + gap) + 20), "Guess 3 of 5", fill=C["text_muted"], font=_font(24, bold=True))
    _draw_keyboard(draw, w, h - 420)
    return img


def screenshot_win() -> Image.Image:
    w, h = 1080, 1920
    img = Image.new("RGB", (w, h), C["bg"])
    draw = ImageDraw.Draw(img)
    _draw_phone_frame(img, draw)
    _draw_app_bar(draw, w, "WordSchool", streak=13)

    hero = (48, 140, w - 48, 420)
    _rounded_rect(draw, hero, 20, C["surface_up"], C["tile_correct"], 2)
    draw.text((w // 2 - 28, 250), "Brilliant!", fill=C["white"], font=_font(44, bold=True))
    draw.text((w // 2 - 280, 310), "Solved in 3 of 5 — keep your streak alive", fill=C["text_muted"], font=_font(22))
    _rounded_rect(draw, (w // 2 - 60, 360, w // 2 + 60, 404), 22, C["streak"])
    _draw_flame(draw, w // 2 - 38, 372, 18)
    draw.text((w // 2 - 8, 368), "13", fill=C["white"], font=_font(24, bold=True))

    word = "WORDS"
    tile = 88
    gap = 10
    grid_w = 5 * tile + 4 * gap
    gx = (w - grid_w) // 2
    gy = 500
    for ri, row in enumerate(
        [
            [("S", C["tile_present"]), ("E", C["tile_absent"]), ("R", C["tile_absent"]), ("I", C["tile_correct"]), ("A", C["tile_absent"])],
            [("P", C["tile_absent"]), ("O", C["tile_present"]), ("R", C["tile_present"]), ("T", C["tile_absent"]), ("S", C["tile_absent"])],
            [("W", C["tile_correct"]), ("O", C["tile_correct"]), ("R", C["tile_correct"]), ("D", C["tile_correct"]), ("S", C["tile_correct"])],
        ]
    ):
        for ci, (letter, color) in enumerate(row):
            x = gx + ci * (tile + gap)
            y = gy + ri * (tile + gap)
            _tile(draw, x, y, tile, letter, color)

    _rounded_rect(draw, (60, h - 320, w - 60, h - 220), 16, C["tile_correct"])
    draw.text((w // 2 - 145, h - 290), "Back to Home", fill=C["white"], font=_font(28, bold=True))
    draw.text((w // 2 - 230, h - 180), "See you tomorrow for a fresh challenge", fill=C["text_muted"], font=_font(20))
    return img


def screenshot_victory() -> Image.Image:
    w, h = 1080, 1920
    img = Image.new("RGB", (w, h), C["bg"])
    draw = ImageDraw.Draw(img)

    # Large checkmark circle
    cx, cy = w // 2, 520
    draw.ellipse((cx - 120, cy - 120, cx + 120, cy + 120), fill=C["tile_correct"])
    draw.line((cx - 45, cy, cx - 10, cy + 45, cx + 55, cy - 55), fill=C["white"], width=14)

    draw.text((w // 2 - 195, 700), "You nailed it!", fill=C["white"], font=_font(52, bold=True))
    draw.text((w // 2 - 310, 780), "13 days in a row — you're on fire.", fill=C["text_muted"], font=_font(26))

    tile = 92
    gap = 12
    letters = "WORDS"
    gx = (w - (5 * tile + 4 * gap)) // 2
    for i, ch in enumerate(letters):
        _tile(draw, gx + i * (tile + gap), 900, tile, ch, C["tile_correct"])

    _rounded_rect(draw, (80, 1150, w - 80, 1250), 16, C["tile_correct"])
    draw.text((w // 2 - 145, 1180), "Back to Home", fill=C["white"], font=_font(30, bold=True))
    return img


def screenshot_archive() -> Image.Image:
    w, h = 1080, 1920
    img = Image.new("RGB", (w, h), C["bg"])
    draw = ImageDraw.Draw(img)
    _draw_phone_frame(img, draw)
    _draw_app_bar(draw, w, "Previous Games")

    draw.text((w // 2 - 130, 150), "June 2026", fill=C["white"], font=_font(34, bold=True))
    days = ["S", "M", "T", "W", "T", "F", "S"]
    dx = 80
    for i, d in enumerate(days):
        draw.text((dx + i * 130, 220), d, fill=C["text_muted"], font=_font(22, bold=True))

    y = 280
    for week in range(5):
        x = 70
        for day in range(7):
            num = week * 7 + day + 1
            if num > 30:
                break
            state = "win" if num % 3 != 0 else ("loss" if num % 5 == 0 else "none")
            if state == "win":
                col = C["tile_correct"]
            elif state == "loss":
                col = C["tile_absent"]
            else:
                col = C["surface"]
            _rounded_rect(draw, (x, y, x + 100, y + 100), 14, col, C["border"] if state == "none" else col)
            draw.text((x + 38, y + 32), str(num), fill=C["white"], font=_font(28, bold=True))
            x += 130
        y += 120

    draw.text((w // 2 - 280, 920), "Replay any past puzzle — no streak penalty", fill=C["text_muted"], font=_font(24))
    return img


def feature_graphic() -> Image.Image:
    w, h = 1024, 500
    img = Image.new("RGB", (w, h), C["bg"])
    draw = ImageDraw.Draw(img)

    # Gradient-like bands
    for i in range(h):
        t = i / h
        r = int(18 + t * 12)
        g = int(18 + t * 8)
        b = int(19 + t * 6)
        draw.line((0, i, w, i), fill=(r, g, b))

    # Decorative tiles left
    tiles = [
        ("W", C["tile_correct"]),
        ("O", C["tile_present"]),
        ("R", C["tile_absent"]),
        ("D", C["tile_correct"]),
        ("S", C["tile_present"]),
    ]
    tx, ty, ts = 80, 130, 72
    for i, (ch, col) in enumerate(tiles):
        _tile(draw, tx + i * (ts + 12), ty, ts, ch, col)

    # Title block
    draw.text((300, 110), "WordSchool", fill=C["white"], font=_font(72, bold=True))
    draw.text((300, 200), "Your daily word puzzle", fill=C["text_muted"], font=_font(32))
    draw.text((300, 260), "Play · Streak · Archive · Compete", fill=C["accent"], font=_font(26, bold=True))

    # Streak badge
    _rounded_rect(draw, (300, 330, 520, 400), 28, C["streak"])
    _draw_flame(draw, 330, 352, 22)
    draw.text((370, 348), "Build your streak", fill=C["white"], font=_font(26, bold=True))

    # Mini phone preview right
    pw, ph = 220, 400
    px, py = w - pw - 70, (h - ph) // 2
    _rounded_rect(draw, (px - 8, py - 8, px + pw + 8, py + ph + 8), 24, C["surface_up"], C["border"], 2)
    _rounded_rect(draw, (px, py, px + pw, py + ph), 20, C["bg"])
    mini = 34
    mgx, mgy = px + 30, py + 80
    for ri in range(3):
        for ci in range(5):
            letters = ["WORDS", "SERIA", "PORTS"]
            colors = [
                [C["tile_correct"]] * 5,
                [C["tile_present"], C["tile_absent"], C["tile_absent"], C["tile_correct"], C["tile_absent"]],
                [C["tile_absent"], C["tile_present"], C["tile_present"], C["tile_absent"], C["tile_absent"]],
            ]
            ch = letters[ri][ci] if ri < len(letters) else ""
            col = colors[ri][ci]
            _tile(draw, mgx + ci * (mini + 4), mgy + ri * (mini + 4), mini, ch, col)

    return img


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    assets = {
        "feature_graphic_1024x500.png": feature_graphic(),
        "screenshot_01_dashboard_1080x1920.png": screenshot_dashboard(),
        "screenshot_02_gameplay_1080x1920.png": screenshot_gameplay(),
        "screenshot_03_completed_win_1080x1920.png": screenshot_win(),
        "screenshot_04_victory_screen_1080x1920.png": screenshot_victory(),
        "screenshot_05_archive_1080x1920.png": screenshot_archive(),
    }

    for name, image in assets.items():
        path = OUT / name
        image.save(path, "PNG", optimize=True)
        print(f"Created {path} ({image.size[0]}x{image.size[1]})")

    readme = OUT / "README.md"
    readme.write_text(
        """# WordSchool — Google Play Store assets

Generated marketing images for Play Console upload.

## Files

| File | Size | Use in Play Console |
|------|------|---------------------|
| `feature_graphic_1024x500.png` | 1024×500 | **Feature graphic** (required) |
| `screenshot_01_dashboard_1080x1920.png` | 1080×1920 | Phone screenshots |
| `screenshot_02_gameplay_1080x1920.png` | 1080×1920 | Phone screenshots |
| `screenshot_03_completed_win_1080x1920.png` | 1080×1920 | Phone screenshots |
| `screenshot_04_victory_screen_1080x1920.png` | 1080×1920 | Phone screenshots |
| `screenshot_05_archive_1080x1920.png` | 1080×1920 | Phone screenshots |

## Play Console requirements

- **Feature graphic**: 1024×500 px, JPG or 24-bit PNG (no alpha)
- **Phone screenshots**: min 2, max 8; 16:9 or 9:16 aspect ratio; min 320 px short side

## Regenerate

```bash
python3 tool/generate_playstore_assets.py
```
""",
        encoding="utf-8",
    )
    print(f"Created {readme}")


if __name__ == "__main__":
    main()
