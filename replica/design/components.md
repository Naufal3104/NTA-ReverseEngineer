# Component specs — Ninety Thousand Acres rebuild

Measured from the original game's screenshots. Role tokens only — no raw hex in components.
Token source: `tokens.json` / `tokens.css`. Flutter mirror: `nta_demo/lib/game/ui/design_tokens.dart`.

Screens referenced: **S1** Building Info modal, **S2** Hero detail, **S3** Rules / Season Rewards,
**S4** World map HUD.

---

## Panel (modal sheet)

```
Panel
  variants  modal, bottom-sheet, tab-body
  size      width = screen - 2*space-8, max-height 88%
  states    default, scrollable
  tokens    bg surface, border border 3px, radius panel(16), shadow panel
  structure header row (title centered, close button right) + body + footer
  a11y      focus trap while open, Esc / scrim tap closes, title is the dialog label
  used on   S1, S2, S3, Building List, Facility Access
```

Measured: modal left edge at x=63 of 1080 → 3px border at ~2x density; body `#F6EFDF`,
raised inner card `#FFFBEF`, card `#E8DDC7`.

## Card (inside panel)

```
Card
  variants  info-header, stat-row, list-item
  tokens    bg surface-card, border border 1.5px, radius card(12), padding space-5
  states    default, selected (bg accent-soft)
  used on   S1 (Building Info header), S3 (reward row)
```

## Gold button (primary action)

```
Button / primary
  variants  gold, gold-disabled
  sizes     sm h=32, md h=40, lg h=48
  states    default, pressed (translate y+1, shadow none), focus-visible (2px ring accent-border), disabled (bg disabled, text text-muted)
  tokens    bg gradient accent-top -> accent-bottom, border accent-border 2.5px,
            text on-accent 16/700, radius button(12), shadow button, padding h=space-8 v=space-4
  a11y      min 44px tap target at md+, label is the accessible name
  used on   S1 Upgrade, Building List Build, Smithy Forge
```

Measured gradient: top `#FFE288` → bottom `#FDD866`; border `#6D5249`; label `#282723`.

## Level badge

```
Badge / level
  tokens    bg border, text text-on-dark, radius pill(8), padding h=space-5 v=2, font xs/700
  used on   S1 "Level 1", building rows
```

## Stat comparison row (level now vs next)

```
StatRow
  variants  current (left, plain bg), next (right, bg accent-soft)
  tokens    label text-muted 14/400, current value text 14/400,
            next value success 14/700, divider dotted border-soft
  states    unchanged value -> value text-muted
  used on   S1 (Watchtower Durability 40 -> 45, ATK 12 -> 14)
```

## HUD resource pill

```
Pill / resource
  variants  basic (with progress), special (value only)
  tokens    bg hud-surface, border hud-border 2px, radius pill(8),
            value hud-text 16/700, rate hud-rate 12/700,
            progress fill hud-progress, track hud-track
  layout    icon overhangs the left edge by space-2, value + rate inline, bar under value
  a11y      value and rate read as one label ("3987 crops, plus 66 per hour")
  used on   S4
```

Measured: pill height 68px @2x = 34dp; progress bar 3dp tall, full-width inside the pill.

## HUD counter pill (coin / reward points)

```
Pill / counter
  variants  with-plus (green add button), plain
  tokens    bg hud-surface, border hud-border 2px, radius pill(8), value hud-text 16/700,
            plus button bg button-plus, border button-plus-edge, icon on-accent
  used on   S4
```

## Icon action button (bottom bar, right rail)

```
Button / icon
  sizes     bottom 56, rail 44
  states    default, pressed (scale .96), disabled (bg disabled)
  tokens    bg surface-raised, border border 2px, radius button(12),
            icon on-accent 28, shadow button
  a11y      44px minimum, tooltip/label required
  used on   S4 (bottom-left back, bottom-right build/smithy/facility, right rail)
```

## Rail (vertical shortcut strip)

```
Rail
  tokens    bg rail, radius panel on the left corners only, icon tiles bg rail bg,
            icon color rail-icon
  layout    right edge, vertically centered, 3-6 tiles, space-4 gap
  used on   S4
```

## Toast / quest banner

```
Toast
  variants  quest (persistent), transient
  tokens    bg rgba(0,0,0,.72), text text-on-dark 14/500, radius pill(8), padding h=space-6 v=space-3
  a11y      polite live region, auto-dismiss 3s for transient
  used on   S4 ("Conquer Stone Plot 4 (1/4)")
```

## Tab bar (panel)

```
TabBar
  variants  active, inactive
  tokens    active bg surface, text text 14/700; inactive bg surface-card tint,
            text text-muted 14/500; indicator none (segment style)
  used on   S3 (Season Rewards | Mall)
```

Measured inactive tab tint `#AB886C` over the header band.

## Hero card

```
Card / hero
  tokens    bg surface-raised, border border-soft 1px, radius card(12),
            skill name text 16/700, possession text-muted 12/500,
            stat icon text-muted, skill body text 13/400
  structure portrait area (teal bg hero-teal) + name pill (hero-name-pill, text-on-dark)
  used on   S2
```

## Typography

Roboto (open) replaces the original's bundled CJK-capable UI font — same category, different file.
Scale: 10 / 12 / 14 / 16 / 20 / 28. Numeric HUD values are bold; body copy regular.

## States checklist (every component)

focus-visible ring `accent-border` 2px · disabled `disabled` bg + `text-muted` label ·
pressed = 1dp translate + shadow off · loading keeps the label visible · empty states get written copy,
never the original's text.
