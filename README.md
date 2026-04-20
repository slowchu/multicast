# Multicast (OpenMW Lua)

Multicast is an OpenMW Lua mod that launches the player's selected spell in short burst modes (`x1 / x2 / x3 / x5`) using **Spell Framework Plus**.

## Architecture

This mod keeps a split PLAYER + GLOBAL design:

- **PLAYER script** (`scripts/multicast/init.lua`): input, burst state, selected-spell snapshot validation, and lightweight status messages.
- **GLOBAL bridge** (`scripts/multicast/global_bridge.lua`): Spell Framework Plus interface checks, handshake replies, and launch forwarding.

PLAYER/local scripts do **not** call `interfaces.MagExp` directly.

## Dependencies

1. **Spell Framework Plus**
2. **MaxYari Lua Physics** (required by Spell Framework Plus)

## Content files

This repo now ships two content files:

1. Main mod:
   - `multicast.omwscripts`
2. Optional smoke test harness:
   - `multicast_smoke.omwscripts`

Main content file:

```text
# Multicast OpenMW script list
PLAYER: scripts/multicast/init.lua
GLOBAL: scripts/multicast/global_bridge.lua
```

Smoke content file:

```text
# Multicast smoke test script list
PLAYER: scripts/multicast/smoke_player.lua
GLOBAL: scripts/multicast/smoke_global.lua
```

## Installation

1. Install Spell Framework Plus and MaxYari Lua Physics.
2. Enable `SPELL API PLUS.omwscripts`.
3. Install this mod folder.
4. Enable `multicast.omwscripts`.
5. Start game and wait for backend-ready message.

## Controls (main mod)

Fallback key symbols:

- `m`: cycle multicast mode (`x1 -> x2 -> x3 -> x5 -> x1`)
- `n`: trigger burst

## Handshake behavior

At startup, the PLAYER script sends `Multicast_CheckBackend` to GLOBAL bridge and enters `CHECKING` state.

- `Multicast_BackendReady` => state becomes `READY`.
- `Multicast_BackendUnavailable` => state becomes `UNAVAILABLE`.
- If no reply arrives in `3.0` simulation seconds => state becomes `UNAVAILABLE` with reason `handshake timeout`.

Burst casting is blocked unless backend state is `READY`.

## Runtime behavior (main mod)

1. Snapshot selected spell.
2. Reject reentry while busy.
3. Dispatch launch requests via `Multicast_LaunchRequest`.
4. GLOBAL bridge forwards launch to `interfaces.MagExp.launchSpell(data)`.
5. Cancel remaining queued launches if selected spell changes.

## Optional smoke test

The smoke harness is intentionally minimal and separate from gameplay logic.

Press `k` in-game (with `multicast_smoke.omwscripts` enabled) to verify:

1. Selected spell access (`types.Actor.getSelectedSpell`).
2. `onKeyPress(key)` with `key.symbol`.
3. `util.vector3` + rotation-vector math.
4. PLAYER -> GLOBAL event dispatch.
5. GLOBAL -> PLAYER reply transport (`player:sendEvent`).
6. GLOBAL visibility of `openmw.interfaces.MagExp`.

## Known limitations

- Status is message-based (not a persistent custom widget).
- Burst visual/animation coherence remains engine/framework behavior to observe in play.
- Burst launch acceptance currently confirms bridge dispatch path, not final projectile/effect resolution.

## Deferred / Not In This Patch

- **Magicka-cost policy** is deferred.
  - This patch does not normalize charge-once vs charge-per-launch economics.
- **Skill progression policy** is deferred.
  - Current skill progression behavior during multicast bursts is not yet normalized.

These are intentionally deferred to avoid undocumented or half-correct gameplay overrides.
