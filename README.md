# Multicast (OpenMW Lua)

Multicast is a player-side OpenMW Lua mod that launches the currently selected spell in a short burst (`x1 / x2 / x3 / x5`) using **Spell Framework Plus** as the casting backend.

This mod is no longer a native cast API experiment. It does **not** rely on guessed `player.cast`/`magic.cast`/`types.Actor.cast` paths.

## Requirements

1. **Spell Framework Plus**
2. **MaxYari Lua Physics** (required by Spell Framework Plus)

## Installation

1. Install and enable Spell Framework Plus and its dependencies first.
2. Ensure `SPELL API PLUS.omwscripts` is enabled in your OpenMW content list.
3. Place this mod folder into your OpenMW data/mod directory.
4. Enable `multicast.omwscripts` in your OpenMW content list.
5. Start the game.

`multicast.omwscripts` uses OpenMW line-based script declarations:

```text
# Multicast OpenMW script list
PLAYER: scripts/multicast/init.lua
```

## Controls

Fallback bindings in this prototype:

- `M`: cycle multicast mode (`x1 -> x2 -> x3 -> x5 -> x1`)
- `N`: trigger multicast burst

## What multicast does

When you trigger a burst:

1. The mod snapshots the currently selected spell.
2. It starts a single active sequence (reentry is rejected while busy).
3. It sends cast requests through Spell Framework Plus (`MagExp_CastRequest`).
4. It schedules follow-up launches with simulation timers (`0.25s` spacing by default).
5. If selected spell changes mid-sequence, remaining launches are cancelled.

## Current limitations

- This is still a prototype focused on burst behavior validation.
- Input is currently fallback key handling (`onKeyPress` path).
- Targeting uses a simple forward-direction estimate from player rotation and should be refined as needed for special spell types.
- Animation behavior for rapid burst launches is engine/framework dependent and should be observed in play tests.

## What to test / observe

- Burst stability for `x2/x3/x5` over multiple spells.
- Visual pacing and timing at `0.25s` intervals.
- How animation presentation looks under repeated framework-driven launches.
- Cancellation behavior when switching selected spells mid-burst.
- Dependency failure behavior when Spell Framework Plus (or prerequisites) is missing.

## Logging

The mod logs with `[Multicast]` prefix and includes:

- initialization and backend assumptions,
- mode changes and trigger attempts,
- each queued launch timestamp,
- cancellation reasons,
- dependency failure notices.
