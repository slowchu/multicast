# Multicast (OpenMW Lua)

Multicast is an OpenMW Lua mod that launches the player's selected spell in short burst modes (`x1 / x2 / x3 / x5`) using **Spell Framework Plus**.

This mod uses a two-part architecture:
- **PLAYER script** (`init.lua`): input, UI/status, burst sequencing, selected-spell snapshot checks.
- **GLOBAL bridge script** (`global_bridge.lua`): Spell Framework Plus availability check + launch dispatch.

The mod does **not** rely on undocumented native cast APIs.

## Requirements

1. **Spell Framework Plus**
2. **MaxYari Lua Physics** (required by Spell Framework Plus)

## Installation

1. Install Spell Framework Plus and MaxYari Lua Physics.
2. Enable `SPELL API PLUS.omwscripts`.
3. Install this mod folder.
4. Enable `multicast.omwscripts`.
5. Start game and wait for backend-ready message.

`multicast.omwscripts`:

```text
# Multicast OpenMW script list
PLAYER: scripts/multicast/init.lua
GLOBAL: scripts/multicast/global_bridge.lua
```

## Controls

Fallback key symbols in this prototype:

- `m`: cycle multicast mode (`x1 -> x2 -> x3 -> x5 -> x1`)
- `n`: trigger burst

## Runtime behavior

On startup, the PLAYER script asks the GLOBAL bridge to check backend readiness.

- If ready: dependency state becomes **READY** and burst casting is enabled.
- If unavailable: dependency state becomes **UNAVAILABLE** and bursts are blocked.

During burst:

1. Selected spell is snapshotted.
2. One sequence runs at a time (reentry blocked).
3. Launch requests are sent to GLOBAL bridge.
4. GLOBAL bridge dispatches via `interfaces.MagExp.launchSpell(data)`.
5. Remaining queued launches cancel if selected spell changes.

## Current limitations

- Message-based status display (not a persistent custom widget).
- Fallback input uses key-symbol comparisons from `onKeyPress`.
- Launch visuals/animation behavior depend on engine + framework behavior.
- Multicast remains blocked until handshake succeeds.

## What to test

- Backend handshake success/failure behavior.
- Burst pacing and cancellation behavior at `0.25s` spacing.
- UI/status updates for `CHECKING/READY/UNAVAILABLE` and active queued count.
- Global bridge launch accepted/failed feedback logs.
