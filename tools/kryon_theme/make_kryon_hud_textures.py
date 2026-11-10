"""Builds the Kryon theme's HUD textures (themes/kryon/hud/*.OZT) from the Season 6 HUD asset pack.

The pack (MU_Online_Season6_HUD_AssetPack.zip, PNG/ folder) is the source art; it is not in the
repository. This script cuts what the HUD draws from it:

  bar.OZT          The skill bar (05_barra_habilidades_completa) with ten slots instead of nine (a
                   slot without the centre gem is repeated after the seventh), the letters drawn
                   in the art removed (the HUD writes the hotkeys itself) and the centre gem
                   removed, so the experience line can run along the rail below the slots.
  bar_gem.OZT      That gem, cut out on its diamond: drawn over the experience line.
  orb_hp.OZT       Each orb (01..04) with its glass emptied: the frame the gauge is drawn in.
  orb_mp.OZT
  orb_sd.OZT
  orb_ag.OZT
  orb_hp_fill.OZT  Each orb's glass alone (the square around it, transparent outside the circle):
  orb_hp_poison.OZT the gauge's fill, shown from the bottom up to the gauge's level. The poison
  orb_mp_fill.OZT  fill is the life glass turned green.
  orb_sd_fill.OZT
  orb_ag_fill.OZT

Every texture is scaled by one factor, so the bar is 1024 texels wide (the loader's limit) and
everything keeps the art's proportions. It prints the geometry main_frame.rcss places the parts
with, in texels of the scaled textures.

Usage: python tools/kryon_theme/make_kryon_hud_textures.py PATH_TO_PACK [--preview DIR]
"""
import argparse
import colorsys
import pathlib

import numpy as np
from PIL import Image
from scipy import ndimage

OUT = pathlib.Path(__file__).resolve().parents[2] / "src/bin/Data/Interface/RmlUi/themes/kryon/hud"

# The bar's art, in its own pixels. The slots' dark wells sit at these x ranges, y 73..187; the
# frame between two slots is at their midpoint, so a slot repeated from one midpoint to the next
# fits the bar's pitch (151).
SLOT_WELLS = [(146, 271), (295, 425), (448, 577), (600, 727), (750, 876), (899, 1028), (1051, 1178),
              (1202, 1329), (1353, 1480)]
WELL_TOP, WELL_BOTTOM = 73, 187
REPEATED = (1039, 1190)  # the seventh slot, midpoint to midpoint
# The gem and its swoop under the fifth slot; the fourth slot's rail (150 to the left) replaces it.
GEM_AREA = (742, 176, 872, 258)
GEM_PATCH_SHIFT = 150
GEM_CENTER, GEM_HALF = (806.5, 221.0), (31.0, 36.0)
# The letters at each well's top left; the same rows of the well further right replace them (the
# well darkens toward its top, so a patch from lower rows would show).
LABEL_AREA = (4, 4, 46, 40)  # from the well's top left
LABEL_PATCH_SHIFT = 48
BAR_ROWS = 257  # the horns end at row 256

BAR_TEXELS = 1024

ORBS = {
    "hp": "01_orbe_vida",
    "mp": "02_orbe_mana",
    "sd": "03_orbe_dorado_pequeno",
    "ag": "04_orbe_purpura_pequeno",
}


def load(pack, name):
    return np.asarray(Image.open(pack / "PNG" / f"{name}.png").convert("RGBA")).astype(np.float32)


def without_specks(pixels):
    """Drops what the atlas cut left beside a piece: every visible island but the big ones."""
    labels, count = ndimage.label(pixels[..., 3] > 8)
    if count < 2:
        return pixels
    sizes = ndimage.sum(np.ones(labels.shape), labels, range(1, count + 1))
    keep = np.isin(labels, np.nonzero(sizes >= sizes.max() * 0.02)[0] + 1)
    out = pixels.copy()
    out[..., 3] *= ndimage.binary_dilation(keep, iterations=2)
    return out


def write_ozt(name, pixels):
    """An OZT is a 4-byte prefix followed by an uncompressed, bottom-up 32-bit TGA."""
    image = np.clip(np.rint(without_specks(pixels)), 0, 255).astype(np.uint8)
    height, width = image.shape[:2]
    header = (bytes([0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0]) + width.to_bytes(2, "little")
              + height.to_bytes(2, "little") + bytes([32, 8]))
    bgra = image[::-1, :, [2, 1, 0, 3]]
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / f"{name}.OZT").write_bytes(bytes([0, 0, 2, 0]) + header + bgra.tobytes())
    print(f"{name}.OZT: {width}x{height}")


def resize(pixels, scale):
    """Lanczos resize in premultiplied alpha, so transparent texels don't bleed their colour."""
    height, width = pixels.shape[:2]
    size = (max(1, round(width * scale)), max(1, round(height * scale)))
    alpha = pixels[..., 3:4] / 255.0
    channels = [Image.fromarray(c.astype(np.float32), "F").resize(size, Image.LANCZOS)
                for c in np.moveaxis(np.concatenate([pixels[..., :3] * alpha, pixels[..., 3:4]], axis=2), 2, 0)]
    out = np.stack([np.asarray(c) for c in channels], axis=2)
    out[..., 3] = np.clip(out[..., 3], 0, 255)
    a = np.maximum(out[..., 3:4] / 255.0, 1e-6)
    out[..., :3] = np.where(out[..., 3:4] > 0.5, out[..., :3] / a, 0)
    return np.clip(out, 0, 255)


def build_bar(pack):
    bar = load(pack, "05_barra_habilidades_completa").copy()
    x0, y0, x1, y1 = GEM_AREA
    gem = bar[:, :].copy()
    bar[y0:y1, x0:x1] = gem[y0:y1, x0 - GEM_PATCH_SHIFT:x1 - GEM_PATCH_SHIFT]
    for left, _ in SLOT_WELLS:
        lx0, ly0, lx1, ly1 = left + LABEL_AREA[0], WELL_TOP + LABEL_AREA[1], left + LABEL_AREA[2], WELL_TOP + LABEL_AREA[3]
        # Only the white letter and its antialiased edge: the gold corner of the slot's frame,
        # which the area reaches, stays.
        area = bar[ly0:ly1, lx0:lx1]
        letter = ndimage.binary_dilation(area[..., :3].min(axis=2) > 90, iterations=3)
        weight = ndimage.gaussian_filter(letter.astype(np.float32), 1.0)[..., None]
        patch = bar[ly0:ly1, lx0 + LABEL_PATCH_SHIFT:lx1 + LABEL_PATCH_SHIFT]
        bar[ly0:ly1, lx0:lx1] = area * (1 - weight) + patch * weight
    a, b = REPEATED
    bar = np.concatenate([bar[:, :b], bar[:, a:b], bar[:, b:]], axis=1)[:BAR_ROWS]
    wells = SLOT_WELLS[:7] + [(l + b - a, r + b - a) for l, r in SLOT_WELLS[6:]]

    # The gem on its diamond, with a soft edge.
    (cx, cy), (hx, hy) = GEM_CENTER, GEM_HALF
    gx0, gy0, gx1, gy1 = int(cx - hx) - 1, int(cy - hy) - 1, int(cx + hx) + 2, min(int(cy + hy) + 2, 265)
    cut = gem[gy0:gy1, gx0:gx1].copy()
    yy, xx = np.mgrid[gy0:gy1, gx0:gx1]
    distance = np.abs(xx + 0.5 - cx) / hx + np.abs(yy + 0.5 - cy) / hy
    cut[..., 3] *= np.clip((1.0 - distance) * hx / 1.5, 0, 1)
    return bar, wells, cut, (gx0, gy0)


def glass(orb):
    """The orb's glass: the circle its liquid fills (centre and radius, in its pixels).

    A black line separates the liquid from the bronze ring. Rays from inside the glass stop at
    it; a circle fitted to where the upper rays stop (the horns cover the glass's lower sides)
    is the glass."""
    value = orb[..., :3].max(axis=2)
    alpha = orb[..., 3]
    height, width = value.shape
    start = np.array([width / 2, height * 0.45])
    points = []
    for angle in np.radians(np.arange(-170, -9, 4)):
        direction = np.array([np.cos(angle), np.sin(angle)])
        for step in range(20, int(height * 0.6)):
            x, y = (start + direction * step).astype(int)
            if not (0 <= x < width and 0 <= y < height) or value[y, x] < 40 or alpha[y, x] < 200:
                points.append(start + direction * (step - 0.5))
                break
    points = np.array(points)
    # Kasa's algebraic fit: x^2 + y^2 + D x + E y + F = 0, then trim the rays that ran into a
    # dark texel inside the liquid and fit again.
    for _ in range(3):
        a = np.column_stack([points[:, 0], points[:, 1], np.ones(len(points))])
        b = -(points[:, 0] ** 2 + points[:, 1] ** 2)
        d, e, f = np.linalg.lstsq(a, b, rcond=None)[0]
        cx, cy = -d / 2, -e / 2
        radius = np.sqrt(cx * cx + cy * cy - f)
        distances = np.hypot(points[:, 0] - cx, points[:, 1] - cy)
        points = points[distances > radius - 4]
    return cx, cy, radius


def circle_mask(shape, cx, cy, radius, feather=1.5):
    yy, xx = np.mgrid[0:shape[0], 0:shape[1]]
    distance = np.hypot(xx + 0.5 - cx, yy + 0.5 - cy)
    return np.clip((radius - distance) / feather + 0.5, 0, 1)


def liquid_mask(orb, cx, cy, radius):
    """The texels of the liquid: the glass less the horn tips and the gem that reach over it. They
    are outlined in black like the ring, so the liquid is what a flood from the centre reaches
    without crossing a black texel."""
    open_texels = (orb[..., :3].max(axis=2) >= 40) & (orb[..., 3] > 200) & (circle_mask(orb.shape, cx, cy, radius) > 0.5)
    labels, _ = ndimage.label(open_texels)
    region = ndimage.binary_fill_holes(labels == labels[int(cy), int(cx)])
    region = ndimage.binary_dilation(region, iterations=1)
    return ndimage.gaussian_filter(region.astype(np.float32), 0.7) * circle_mask(orb.shape, cx, cy, radius + 0.5)


def emptied(orb, mask):
    """The orb with dark glass: the liquid dimmed to a smoky tint, its white glint kept."""
    out = orb.copy()
    mask = mask[..., None]
    rgb = orb[..., :3]
    luminance = rgb @ np.array([0.299, 0.587, 0.114], dtype=np.float32)
    dark = rgb * 0.13 + luminance[..., None] * 0.05 + np.array([6, 5, 5], dtype=np.float32)
    glint = np.clip((rgb.min(axis=2) - 170) / 70, 0, 1)[..., None] * 0.6
    dark = dark * (1 - glint) + rgb * glint
    out[..., :3] = rgb * (1 - mask) + dark * mask
    return out


def glass_only(orb, mask, cx, cy, radius):
    """The liquid alone, on the square around the glass."""
    x0, y0 = int(np.floor(cx - radius)), int(np.floor(cy - radius))
    size = int(np.ceil(2 * radius)) + 1
    padded = np.zeros((size, size, 4), dtype=np.float32)
    sx0, sy0 = max(x0, 0), max(y0, 0)
    sx1, sy1 = min(x0 + size, orb.shape[1]), min(y0 + size, orb.shape[0])
    padded[sy0 - y0:sy1 - y0, sx0 - x0:sx1 - x0] = orb[sy0:sy1, sx0:sx1]
    alpha = np.zeros((size, size), dtype=np.float32)
    alpha[sy0 - y0:sy1 - y0, sx0 - x0:sx1 - x0] = mask[sy0:sy1, sx0:sx1]
    padded[..., 3] *= alpha
    return padded, (x0, y0, size)


def to_green(pixels):
    out = pixels.copy()
    rgb = (pixels[..., :3] / 255.0).reshape(-1, 3)
    hsv = np.array([colorsys.rgb_to_hsv(*p) for p in rgb])
    hsv[:, 0] = (hsv[:, 0] + 0.33) % 1.0
    hsv[:, 1] *= 0.85
    out[..., :3] = np.array([colorsys.hsv_to_rgb(*p) for p in hsv]).reshape(pixels.shape[:2] + (3,)) * 255
    return out


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("pack", type=pathlib.Path)
    parser.add_argument("--preview", type=pathlib.Path)
    args = parser.parse_args()

    bar, wells, gem, gem_origin = build_bar(args.pack)
    scale = BAR_TEXELS / bar.shape[1]
    print(f"scale {scale:.5f} texels per art pixel")
    write_ozt("bar", resize(bar, scale))
    write_ozt("bar_gem", resize(gem, scale))
    # The gem where it was in the art: the fifth slot, before the repeated one, did not move.
    print(f"  gem at x {gem_origin[0] * scale:.1f}, y {gem_origin[1] * scale:.1f}; "
          f"size {gem.shape[1] * scale:.1f}x{gem.shape[0] * scale:.1f}")
    for i, (left, right) in enumerate(wells):
        print(f"  well {i}: x {left * scale:.1f}..{(right + 1) * scale:.1f}, y {WELL_TOP * scale:.1f}..{(WELL_BOTTOM + 1) * scale:.1f}")
    print(f"  rail channel y {212 * scale:.1f}..{223 * scale:.1f}")

    for key, name in ORBS.items():
        orb = load(args.pack, name)
        cx, cy, radius = glass(orb)
        mask = liquid_mask(orb, cx, cy, radius)
        fill, (x0, y0, size) = glass_only(orb, mask, cx, cy, radius)
        write_ozt(f"orb_{key}", resize(emptied(orb, mask), scale))
        write_ozt(f"orb_{key}_fill", resize(fill, scale))
        if key == "hp":
            write_ozt("orb_hp_poison", resize(to_green(fill), scale))
        print(f"  {key}: art {orb.shape[1] * scale:.1f}x{orb.shape[0] * scale:.1f}, glass at "
              f"x {x0 * scale:.1f}, y {y0 * scale:.1f}, size {size * scale:.1f} (centre {cx * scale:.1f},{cy * scale:.1f})")

    if args.preview:
        args.preview.mkdir(parents=True, exist_ok=True)
        for path in OUT.glob("*.OZT"):
            data = path.read_bytes()[4:]
            width, height = int.from_bytes(data[12:14], "little"), int.from_bytes(data[14:16], "little")
            pixels = np.frombuffer(data[18:18 + width * height * 4], np.uint8).reshape(height, width, 4)
            Image.fromarray(pixels[::-1, :, [2, 1, 0, 3]].copy(), "RGBA").save(args.preview / f"{path.stem}.png")


if __name__ == "__main__":
    main()
