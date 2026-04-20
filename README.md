# Multicast (OpenMW Lua prototype)

A prototype OpenMW Lua mod that tests **native repeated spell-use activation** (multicast) for the player.

## What this mod does

- Adds a multicast mode with cast counts: **x1 / x2 / x3 / x5**.
- Lets you cycle mode and trigger a multicast cast sequence.
- On trigger, the mod:
  1. snapshots the currently selected spell,
  2. optionally ensures spell stance,
  3. uses the native spell-use path for the first cast,
  4. queues follow-up native cast activations using simulation timers (default spacing: `0.25s`).
- Cancels a sequence if the selected spell changes mid-sequence.

This is intentionally a behavior-testing prototype, not a balance/combat overhaul.

## Installation (OpenMW)

1. Put this repository folder directly in your OpenMW mods location (as a normal mod folder).
2. Ensure the repo root is treated as the mod data folder (no nested `Data Files` folder is required).
3. Enable **`multicast.omwscripts`** in the launcher content list, or add it in `openmw.cfg` content entries.
4. Launch the game and load a save with a spellcasting-capable character.

## Controls / hotkeys (default fallback)

Because input APIs can differ between OpenMW versions, v1 uses a compatibility-first input setup:

- **Cycle multicast mode**: `M`
- **Trigger multicast**: `N`

If action registration APIs are available in your OpenMW build, they can be wired later with minimal refactor (the code is module-separated for this).

## Current limitations (v1)

- Prototype uses compatibility wrappers for API names that may differ across 0.51/dev snapshots.
- HUD indicator is intentionally minimal and may degrade to on-screen message fallback if the expected HUD API is unavailable.
- No custom spell effects.
- No fake projectile implementation.
- One active multicast sequence at a time.

## What to observe during testing

- Whether repeated native spell-use activations chain consistently.
- Whether cast animation, VFX, and SFX stay coherent on short intervals.
- Whether stamina/magicka use and cast outcomes remain mechanically correct.
- Whether spell stance transitions are stable while sequencing casts.
- How cancellation behaves if selected spell changes during an active sequence.

## Known uncertainty

OpenMW Lua API naming around selected spell access, stance toggling, and native spell activation can vary between builds (especially dev snapshots around 0.51-era changes). This mod isolates such calls in `scripts/multicast/compat.lua` and logs assumptions so you can quickly adapt to your exact engine build.

## File layout

- `multicast.omwscripts`
- `scripts/multicast/init.lua`
- `scripts/multicast/config.lua`
- `scripts/multicast/state.lua`
- `scripts/multicast/cast_controller.lua`
- `scripts/multicast/input.lua`
- `scripts/multicast/ui.lua`
- `scripts/multicast/debug.lua`
- `scripts/multicast/compat.lua`
