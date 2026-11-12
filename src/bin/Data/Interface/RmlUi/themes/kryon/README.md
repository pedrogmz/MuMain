# Kryon theme

**Warm obsidian and gilded bronze.** Kryon takes its material language and typography from the
OpenMU browser stack's loader/analysis shell (`openmu-browser-stack/public/index.html` and the
`analysis/index.html` build): warm near-black plates, rounded gold-edged cards, a bright gold
rule along the top, a radial sheen from above, parchment text, and a Georgia-metric serif face.

The theme is a presentation package, not a recolour of modern's iron. It keeps modern's complete
layout, RML forks and component behaviour, and replaces the shared chrome plus the windows that
paint their own literal surfaces.

## Inheritance

- `theme.ini` declares `Base=modern`. Everything a file here does not override comes from
  `themes/modern/`, including its `.rml` forks and its structural layout.
- A copied `.rcss` is a **fork**: it keeps modern's selectors and geometry and adds Kryon's
  palette at the end. When the modern original changes, re-sync the fork (or delete it when the
  change no longer needs a Kryon override).
- `tokens.ini` only changes the palette, radii and fonts; unset keys inherit from modern.
- The theme adds no C++ and no `[Capabilities]`; layout and behaviour stay modern's, except the
  main HUD's layout (see HUD art below).

## Direction

- **Warm obsidian, not cold iron.** Surfaces use the analysis deck's
  `rgba(28,24,20)` -> `rgba(5,8,11)` family, with a brown-black recess instead of blue slate.
- **Even bronze ring, no glare.** Major panels follow the web client's command panel: a
  `rgba(163,111,61)` 2dp ring with 14dp corners, a `rgba(24,20,18)` -> `rgba(5,5,6)` vertical
  fade, a faint amber sheen at the upper right and an inner black ring. Header rails are a quiet
  band closed by a bronze hairline; the title carries the colour.
- **Rounded command buttons.** `.btn`, icon buttons and option chips are 10dp-rounded cards with a
  soft bronze edge, a warm-to-black fade and serif `#f3d79a` lettering; hover lifts the edge to
  gold. `.btn-ok` / `.btn-icon-primary` are the one amber plate per window, with dark lettering.
  Rows and server chips use the teleport list's 12dp card.
- **Every text has a soft drop shadow.** `body` in `base.rcss` sets
  `font-effect: glow(0px 2dp 0dp 1dp ...)` (the web client's `0 1px 2px #000`); font-effect is
  inherited, so a window opts out only by setting its own (outlines on HUD counts, `none` on the
  amber buttons).
- **Sharp text in scaled panels.** Placed panels lay out in reference px and are enlarged with
  `transform: scale(root_scale)`; RmlUi rasterises text before that transform. The shared title,
  wallet and button-glyph classes (`base.rcss`, modern and here) and the character sheet's and
  inventory's text set `font-size` and their own lengths as reference px times `--root-scale` and
  cancel the scale, so glyphs are drawn at the size they are shown. Keep that pattern when adding
  text to a placed panel.
- **Serif voice.** A bundled Gelasio face (metric-compatible with Georgia) is the body and title
  family, so the native and WASM clients look the same. Headers and window titles are uppercase
  with letter spacing; body text stays mixed case.

## Tokens

The values live in `tokens.ini`; this table is their meaning.

### Surfaces

| Token | Use |
|---|---|
| `surface-deep` | Deepest plate / HUD backing |
| `surface-backdrop` | Full-screen modal dim |
| `surface-recessed` | Sunken content well |
| `surface-panel` | Default panel body |
| `surface-raised` | Raised control chrome |
| `surface-control` | Resting icon-button wash |
| `surface-tooltip` | Every tooltip background |

### Metal / frame

| Token | Use |
|---|---|
| `metal-dark` | Dark control plate |
| `metal-mid` | Muted bronze frame edge |
| `metal-edge` | Lit bronze catch |
| `metal-highlight` | Bright bronze catch |
| `metal-warm-edge` | Ornamental warm line |
| `metal-outer` / `metal-groove` | Outer seat / inner groove |
| `metal-rail` / `metal-rail-dark` | Header rail body / shadow end |
| `metal-title-face` / `metal-title-face-dark` | Hero title plate |

### Text

| Token | Use |
|---|---|
| `text-primary` | Default parchment body |
| `text-secondary` | Metadata and secondary text |
| `text-muted` | Quietest tier |
| `text-warm` | Titles, names, emphasis |
| `text-disabled` | Disabled control text |

### Accents and semantic

| Token | Use |
|---|---|
| `accent-steel`, `accent-steel-hover` | Neutral interaction chrome |
| `accent-gold`, `accent-gold-hover` | Selection, checked state, emphasis, primary action |
| `accent-crimson`, `accent-crimson-hover` | Reserved for danger; not general chrome |
| `semantic-success` / `warning` / `danger` / `rare` / `neutral` | State meaning |

### Borders

| Token | Use |
|---|---|
| `border-frame` | Muted bronze control/frame edge |
| `border-inner` | Recessed well edge |
| `border-recessed` | Hairline divider |
| `border-hover` / `border-selected` | Interaction / selected states |
| `border-outer` / `border-rail` / `border-title` | Shell, header rail, title plate |

### Typography and HUD

`font-title` is `Gelasio` (titles, buttons, the character sheet's name and stat names);
`font-body` is the bundled `Liberation Sans`, as the web client sets rows and values in a sans face. `theme.ini` loads its regular and bold faces from
`fonts/` inside this theme; the files are bundled under the SIL Open Font License (see
`fonts/OFL.txt`). Gelasio is metric-compatible with Georgia, the face the analysis shell uses,
and being inside the theme means the WASM build gets the same serif as the native client. If the
faces cannot load, RmlUi falls back to the bundled Liberation Sans.
`resource-hp`, `resource-mp`, `resource-sd`, `resource-ag` keep their semantic stat colours.

## What this folder restyles

| Family | Files |
|---|---|
| Shared chrome | `base.rcss` |
| Login and scene | `login.rcss`, `title_scene.rcss` |
| Main menu / dialogs | `sys_menu.rcss`, `option_window.rcss`, `generic_confirm_dialog.rcss`, `generic_menu_dialog.rcss` |
| HUD / chat | `main_frame.rcss`, `main_frame_top.rcss`, `mu_helper_bar.rcss`, `chat_log.rml`/`.rcss`, `chat_input.rml`/`.rcss` (Season 6 chat deck: tabs, gear menu, framed log; art by `tools/kryon_theme/make_kryon_chat_textures.py`), `item_grid.rcss`, `tooltip.rcss` |
| Letters | `letter_read.rcss`, `letter_write.rcss` |
| Inventory family | `my_inventory.rcss`, `trade.rcss`, `storage.rcss`, `storage_ext.rcss`, `npc_shop.rcss`, `my_shop.rcss`, `purchase_shop.rcss`, `inventory_extension.rcss`, `mix_inventory.rcss`, `lucky_item.rcss` |
| Docked windows | `docked_panel_frame.rcss`, `character_info.rcss` |
| Character creation | `char_make.rcss` |

Everything else — server select, message boxes, character select, tooltips, the MU Helper, event
windows and the remaining dialogs — inherits modern's file, reading Kryon's tokens and the shared
`base.rcss` pass. Add a file here only when a window paints its own literal surface that the
shared pass cannot reach.

## Trying it

1. Open **Options → UI → Theme** and pick **Kryon** (the list refreshes when the theme is
   selected).
2. Or type `$theme kryon` in chat for a session-only preview.
3. To persist, set `[UI] RmlTheme=kryon` in `config.ini` while the client is closed.

Run `python tools/check_rml_rcss_drift.py` after changing a forked `.rcss`; it checks the
required ids, callbacks and model fields. Visual structure and interaction still need a client
check at more than one resolution and UI scale.

## HUD art

The main HUD (`main_frame.rcss`) does not follow modern's flat strip: it draws the life and mana
orbs at the ends, the SD and AG orbs at their feet and a ten-slot bronze skill bar between them
(the four item hotkeys, the five skill hotkeys and the current skill), with the experience line in
the bar's lower rail and the tenth of the level on its gem. The textures are in `hud/`, cut from
the Season 6 HUD asset pack by `tools/kryon_theme/make_kryon_hud_textures.py`, which writes them as
OZT (the only container the engine reads for `.tga` paths) and prints the geometry the stylesheet
places the parts with. Re-run it with the pack's folder to rebuild them:
`python tools/kryon_theme/make_kryon_hud_textures.py PATH_TO_PACK` (needs Pillow, NumPy and SciPy).

The orb frames are drawn with empty glass; each gauge shows its glass texture (`orb_*_fill`) from
the bottom up to its level, so the fill follows the glass, not the whole orb. The layout keeps the
shared `main_frame.rml`: if a part is added there, place or hide it here.

## Window art

The windows reuse the same pack, sparingly, through `ui/` (cut by
`tools/kryon_theme/make_kryon_window_textures.py`, which prints each piece's ninepatch rects):

| Piece | Where |
|---|---|
| Ring with gold corner gems (`frame`) | `.modern-shell-edge`, `.inv-shell-edge`: every framed window's edge |
| Bar frame (`header`) and winged gem (`joint`) | Header rails and the joint over them |
| Item slot (`slot`, `slot_ring`) | Equipment slots; the inventory cells (the hollow ring, so the cell tint shows) |
| Dark plate (`panel`) | Chat backdrop, the character sheet's summary |
| Gem-ended rail (`divider`) | The character sheet's stat rows, which separate the attributes |
| Rounded plate (`button`, `button_hover`) | `.btn`, `.btn-icon`, `.modern-btn-px`, `.modern-icon-btn-px` |
| Row plate (`bar`) | The gold strip (`.modern-wallet-px`) |

The shared rules are at the end of `base.rcss` ("Kryon art pass"), with `body ...` selectors so they
win over each window's palette rules. Every piece is a `ninepatch(...)` with explicit edges: a
sprite's natural size follows the context's dp ratio, which the panels that scale themselves
(reference px) would apply twice.

## Rules for changes

- Every new colour traces to a token in `tokens.ini`; add the token and its meaning here first.
- Keep the command deck's state language: warm obsidian at rest, gold for
  hover/selected/checked, green for running/active, ember only for danger.
- Do not move geometry into `base.rcss` or into this theme's overrides. Layout stays in the
  window's own file or the shared RML.
- Nothing here changes `modern`.
