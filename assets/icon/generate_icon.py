"""Generate the Lift Off app icon source PNGs.

Produces:
- assets/icon/icon.png            1024x1024, black background, purple chevron
- assets/icon/icon_foreground.png 1024x1024, transparent background, purple chevron
                                  scaled to ~66% of canvas for adaptive icon safe zone

Run from repo root: python3 assets/icon/generate_icon.py
"""
from PIL import Image, ImageDraw

SIZE = 1024
PURPLE = (168, 85, 247)  # #A855F7


def draw_chevron(img: Image.Image, scale: float) -> None:
    d = ImageDraw.Draw(img)
    cx = cy = SIZE / 2
    span = SIZE * 0.45 * scale
    stroke = int(SIZE * 0.10 * scale)
    vertical = span * 0.55

    left = (cx - span, cy + vertical)
    apex = (cx, cy - vertical)
    right = (cx + span, cy + vertical)

    d.line([left, apex], fill=PURPLE, width=stroke)
    d.line([apex, right], fill=PURPLE, width=stroke)

    # Round caps/joints (Pillow lines are butt-capped)
    r = stroke // 2
    for (x, y) in (left, apex, right):
        d.ellipse([x - r, y - r, x + r, y + r], fill=PURPLE)


def main() -> None:
    # Main icon: opaque black background
    solid = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
    draw_chevron(solid, scale=1.0)
    solid.save("assets/icon/icon.png")

    # Foreground for adaptive icon: transparent, scaled to ~66%
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_chevron(fg, scale=0.66)
    fg.save("assets/icon/icon_foreground.png")


if __name__ == "__main__":
    main()
