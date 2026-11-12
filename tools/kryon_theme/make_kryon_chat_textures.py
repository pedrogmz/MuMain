"""Builds the Kryon theme's chat textures (themes/kryon/ui/chat_*.OZT) from the Season 6 HUD asset pack.

The chat's own pieces, beside the shared window art (make_kryon_window_textures.py):

  chat_tab.OZT        A tab: the short rounded plate (23_indicadores_superiores), at rest,
  chat_tab_hover.OZT  lit for hover,
  chat_tab_on.OZT     and gilded for the selected tab.
  chat_field.OZT      The message field's plate: the long rounded plate (23_indicadores_superiores).
  chat_knob.OZT       The square plate (20_adornos_laterales): the send button, the scroll arrows.
  chat_knob_hover.OZT Its lit variant.
  chat_gear.OZT       The settings gear (21_iconos_alerta_config_menu), and its lit variant,
  chat_gear_hover.OZT for hover.
  chat_arrow_up.OZT   The bronze triangle (20_adornos_laterales), turned to point up,
  chat_arrow_down.OZT down,
  chat_arrow_right.OZT and right (the send glyph).
  chat_thumb.OZT      The scrollbar's thumb: the bar frame (16_marco_barra_mediano) stood upright.

Every plate is a ninepatch: chat_log.rcss / chat_input.rcss declare each one's outer and inner
rect (printed here) and give the edges an explicit size.

Usage: python tools/kryon_theme/make_kryon_chat_textures.py PATH_TO_PACK [--preview DIR]
"""
import argparse
import pathlib

import numpy as np
from PIL import Image

from make_kryon_hud_textures import load, resize, write_ozt
import make_kryon_hud_textures as hud
from make_kryon_window_textures import crop, lit, emit, OUT


def gilded(pixels):
    """The selected tab: the bronze edge brighter and yellower, the plate a warm brown."""
    out = pixels.copy()
    rgb = out[..., :3]
    value = rgb.max(axis=2, keepdims=True)
    edge = np.clip((value - 60) / 80, 0, 1)
    bright = np.clip(rgb * 1.45 + np.array([18, 12, 0]), 0, 255)
    plate = np.clip(rgb * 1.2 + np.array([46, 30, 12]), 0, 255)
    out[..., :3] = bright * edge + plate * (1 - edge)
    return out


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("pack", type=pathlib.Path)
    parser.add_argument("--preview", type=pathlib.Path)
    args = parser.parse_args()
    pack = args.pack
    hud.OUT = OUT

    plates = load(pack, "23_indicadores_superiores")
    tab = resize(crop(plates, (32, 128, 139, 166)), 0.5)
    inner = (10, 7, tab.shape[1] - 10, tab.shape[0] - 7)
    emit("chat_tab", tab, inner)
    emit("chat_tab_hover", lit(tab), inner)
    emit("chat_tab_on", gilded(tab), inner)

    field = resize(crop(plates, (32, 177, 232, 220)), 0.5)
    emit("chat_field", field, (12, 8, field.shape[1] - 12, field.shape[0] - 8))

    ornaments = load(pack, "20_adornos_laterales")
    knob = resize(crop(ornaments, (132, 32, 235, 121)), 0.3)
    inner = (8, 8, knob.shape[1] - 8, knob.shape[0] - 8)
    emit("chat_knob", knob, inner)
    emit("chat_knob_hover", lit(knob), inner)

    gear = resize(crop(load(pack, "21_iconos_alerta_config_menu"), (78, 12, 137, 71)), 0.4)
    full = (0, 0, gear.shape[1], gear.shape[0])
    emit("chat_gear", gear, full)
    emit("chat_gear_hover", lit(gear, 1.35), full)

    # The right-hand triangle points right; turned a quarter it points up or down.
    arrow = crop(ornaments, (259, 31, 296, 119))
    arrow = lit(arrow, 1.9)
    right = resize(arrow, 0.2)
    emit("chat_arrow_right", right, (0, 0, right.shape[1], right.shape[0]))
    up = resize(np.rot90(arrow, 1).copy(), 0.16)
    emit("chat_arrow_up", up, (0, 0, up.shape[1], up.shape[0]))
    down = resize(np.rot90(arrow, -1).copy(), 0.16)
    emit("chat_arrow_down", down, (0, 0, down.shape[1], down.shape[0]))

    bar = crop(load(pack, "16_marco_barra_mediano"), (13, 11, 235, 72))
    thumb = resize(np.rot90(bar, 1).copy(), 0.2)
    emit("chat_thumb", thumb, (0, 5, thumb.shape[1], thumb.shape[0] - 5))

    if args.preview:
        args.preview.mkdir(parents=True, exist_ok=True)
        for path in OUT.glob("chat_*.OZT"):
            data = path.read_bytes()[4:]
            width, height = int.from_bytes(data[12:14], "little"), int.from_bytes(data[14:16], "little")
            pixels = np.frombuffer(data[18:18 + width * height * 4], np.uint8).reshape(height, width, 4)
            Image.fromarray(pixels[::-1, :, [2, 1, 0, 3]].copy(), "RGBA").save(args.preview / f"{path.stem}.png")


if __name__ == "__main__":
    main()
