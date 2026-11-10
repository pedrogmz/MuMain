"""Builds the Kryon theme's window textures (themes/kryon/ui/*.OZT) from the Season 6 HUD asset pack.

The HUD's art, reused for the windows (see make_kryon_hud_textures.py for the HUD itself):

  frame.OZT        A window's ring: the rectangular panel's (13_panel_rectangular) bronze edge with
                   its plate cut out, a small gold gem on each corner (22_controles_y_gemas).
  header.OZT       A window's header plate: the bar frame (17_marco_barra_mediano_2).
  panel.OZT        A dark plate in a bronze edge (14_panel_largo): chat, summaries.
  bar.OZT          A short row plate (16_marco_barra_mediano): a stat's row, the gold strip.
  slot.OZT         An item slot (07_slot_individual_02): equipment slots.
  slot_ring.OZT    Its frame alone, the well cut out: inventory cells, whose tint shows through.
  button.OZT       A button (23_indicadores_superiores, the rounded plate), and its lit variant,
  button_hover.OZT for hover.
  divider.OZT      The gem-ended rail (19_barra_decorativa_corta), on two transparent rows: drawn
                   along the bottom of a box with ninepatch edges of 0 at the top.
  joint.OZT        The winged gem (22_controles_y_gemas), over the middle of a header.

Every piece is a ninepatch: main_frame.rcss's sibling base.rcss declares each one's outer and
inner rect (printed here) and gives the edges an explicit size, so they keep their size inside
the panels that scale themselves (reference px) and in dp documents alike.

Usage: python tools/kryon_theme/make_kryon_window_textures.py PATH_TO_PACK [--preview DIR]
"""
import argparse
import pathlib

import numpy as np
from PIL import Image
from scipy import ndimage

from make_kryon_hud_textures import load, resize, write_ozt
import make_kryon_hud_textures as hud

OUT = pathlib.Path(__file__).resolve().parents[2] / "src/bin/Data/Interface/RmlUi/themes/kryon/ui"


def crop(pixels, box):
    x0, y0, x1, y1 = box
    return pixels[y0:y1, x0:x1].copy()


def hollow(pixels, inset):
    """Cuts a plate out of its frame: the dark texels a flood from the centre reaches inside the
    inset rect become transparent (the bevel's own dark line stops the flood)."""
    height, width = pixels.shape[:2]
    dark = pixels[..., :3].max(axis=2) < 85
    allowed = np.zeros_like(dark)
    allowed[inset:height - inset, inset:width - inset] = True
    labels, _ = ndimage.label(dark & allowed)
    plate = ndimage.binary_fill_holes(labels == labels[height // 2, width // 2])
    plate = ndimage.binary_dilation(plate, iterations=1)
    out = pixels.copy()
    out[..., 3] *= 1 - ndimage.gaussian_filter(plate.astype(np.float32), 0.8)
    return out


def paste(canvas, piece, cx, cy):
    """Alpha-composites piece centred on (cx, cy)."""
    h, w = piece.shape[:2]
    x0, y0 = int(round(cx - w / 2)), int(round(cy - h / 2))
    region = canvas[y0:y0 + h, x0:x0 + w]
    a = piece[..., 3:4] / 255.0
    region[..., :3] = piece[..., :3] * a + region[..., :3] * (1 - a)
    region[..., 3:4] = piece[..., 3:4] + region[..., 3:4] * (1 - a)


def lit(pixels, gain=1.3):
    """The hover state: the bronze brighter, the plate a little warmer."""
    out = pixels.copy()
    rgb = out[..., :3]
    out[..., :3] = np.clip(rgb * gain + np.array([10, 6, 0]) * (rgb.max(axis=2, keepdims=True) < 60), 0, 255)
    return out


def emit(name, pixels, inner):
    hud.OUT = OUT
    write_ozt(name, pixels)
    h, w = pixels.shape[:2]
    x0, y0, x1, y1 = inner
    print(f"  {name}: outer 0px 0px {w}px {h}px; inner {x0}px {y0}px {x1 - x0}px {y1 - y0}px")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("pack", type=pathlib.Path)
    parser.add_argument("--preview", type=pathlib.Path)
    args = parser.parse_args()
    pack = args.pack

    # Frame: the panel's ring at half size, padded for the corner gems.
    ring = resize(hollow(crop(load(pack, "13_panel_rectangular"), (11, 10, 146, 115)), 14), 0.5)
    pad = 7
    frame = np.zeros((ring.shape[0] + 2 * pad, ring.shape[1] + 2 * pad, 4), dtype=np.float32)
    frame[pad:pad + ring.shape[0], pad:pad + ring.shape[1]] = ring
    gem = resize(crop(load(pack, "22_controles_y_gemas"), (322, 42, 364, 92)), 0.32)
    h, w = frame.shape[:2]
    for cx, cy in ((pad + 3, pad + 3), (w - pad - 3, pad + 3), (pad + 3, h - pad - 3), (w - pad - 3, h - pad - 3)):
        paste(frame, gem, cx, cy)
    emit("frame", frame, (pad + 18, pad + 18, w - pad - 18, h - pad - 18))

    header = resize(crop(load(pack, "17_marco_barra_mediano_2"), (12, 9, 329, 71)), 0.5)
    emit("header", header, (14, 8, header.shape[1] - 14, header.shape[0] - 8))

    panel = resize(crop(load(pack, "14_panel_largo"), (10, 10, 264, 115)), 0.5)
    emit("panel", panel, (14, 13, panel.shape[1] - 14, panel.shape[0] - 13))

    bar = resize(crop(load(pack, "16_marco_barra_mediano"), (13, 11, 235, 72)), 0.5)
    emit("bar", bar, (12, 8, bar.shape[1] - 12, bar.shape[0] - 8))

    slot = resize(crop(load(pack, "07_slot_individual_02"), (11, 10, 111, 114)), 0.4)
    emit("slot", slot, (9, 9, slot.shape[1] - 9, slot.shape[0] - 9))
    ring = resize(hollow(crop(load(pack, "07_slot_individual_02"), (11, 10, 111, 114)), 10), 0.4)
    emit("slot_ring", ring, (9, 9, ring.shape[1] - 9, ring.shape[0] - 9))

    button = resize(crop(load(pack, "23_indicadores_superiores"), (31, 6, 217, 57)), 0.5)
    inner = (13, 8, button.shape[1] - 13, button.shape[0] - 8)
    emit("button", button, inner)
    emit("button_hover", lit(button), inner)

    rail = resize(crop(load(pack, "19_barra_decorativa_corta"), (12, 10, 375, 69)), 0.4)
    divider = np.zeros((rail.shape[0] + 2, rail.shape[1], 4), dtype=np.float32)
    divider[2:] = rail
    emit("divider", divider, (22, 0, divider.shape[1] - 22, 2))

    joint = resize(crop(load(pack, "22_controles_y_gemas"), (149, 116, 349, 170)), 0.3)
    emit("joint", joint, (0, 0, joint.shape[1], joint.shape[0]))

    if args.preview:
        args.preview.mkdir(parents=True, exist_ok=True)
        for path in OUT.glob("*.OZT"):
            data = path.read_bytes()[4:]
            width, height = int.from_bytes(data[12:14], "little"), int.from_bytes(data[14:16], "little")
            pixels = np.frombuffer(data[18:18 + width * height * 4], np.uint8).reshape(height, width, 4)
            Image.fromarray(pixels[::-1, :, [2, 1, 0, 3]].copy(), "RGBA").save(args.preview / f"{path.stem}.png")


if __name__ == "__main__":
    main()
