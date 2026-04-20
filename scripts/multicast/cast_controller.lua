local config = require("scripts.multicast.config")
local state = require("scripts.multicast.state")
local debug = require("scripts.multicast.debug")
local compat = require("scripts.multicast.compat")

local M = {}

local function cancel(reason)
    debug.warn("Sequence cancelled: " .. tostring(reason))
    state.cancelSequence()
end

local function selectedSpellSnapshot(player)
    local spell = compat.getSelectedSpell(player)
    if not spell then
        return nil, nil, nil
    end

    local id = compat.getSpellId(spell)
    local name = compat.getSpellName(spell)
    return spell, id, name
end

local function validateSnapshot(player)
    local currentSpell = compat.getSelectedSpell(player)
    if not currentSpell then
        return false, "selected spell missing"
    end

    local currentId = compat.getSpellId(currentSpell)
    if not currentId or currentId ~= state.snapshotSpellId then
        return false, string.format(
            "selected spell changed (expected=%s, current=%s)",
            tostring(state.snapshotSpellId),
            tostring(currentId)
        )
    end

    return true, nil
end

local function castOnce(player, castIndex)
    debug.log(string.format("Cast attempt #%d at t=%.3f", castIndex, compat.now()))

    local ok, reason = validateSnapshot(player)
    if not ok then
        cancel(reason)
        return false
    end

    if config.forceSpellStance then
        local stanceOk = compat.ensureSpellStance(player)
        if not stanceOk then
            debug.warn("Could not guarantee spell stance before cast attempt")
        end
    end

    local activated = compat.activateReadiedSpell(player)
    if not activated then
        cancel("native spell-use activation failed")
        return false
    end

    return true
end

local function queueNext(player, nextCastIndex)
    if not state.busy then
        return
    end

    if state.remainingCasts <= 0 then
        debug.log("Sequence complete")
        state.completeSequence()
        return
    end

    debug.log(string.format(
        "Queueing cast #%d in %.2fs (remaining queued: %d)",
        nextCastIndex,
        config.defaultIntervalSeconds,
        state.remainingCasts
    ))

    compat.scheduleSimulation(config.defaultIntervalSeconds, function()
        debug.log(string.format("Timer fired for cast #%d", nextCastIndex))

        if not state.busy then
            return
        end

        local ok = castOnce(player, nextCastIndex)
        if not ok then
            return
        end

        state.remainingCasts = math.max(0, state.remainingCasts - 1)
        queueNext(player, nextCastIndex + 1)
    end)
end

function M.triggerMulticast()
    local player = compat.player()
    if not player then
        debug.error("No player object available")
        return false
    end

    if state.busy then
        debug.warn("Trigger ignored: sequence already active")
        return false
    end

    local spell, spellId, spellName = selectedSpellSnapshot(player)
    if not spell or not spellId then
        debug.warn("Trigger ignored: no valid selected spell")
        return false
    end

    local casts = state.getModeCount()
    debug.log(string.format(
        "Trigger multicast: mode=x%d, selectedSpell=%s (%s)",
        casts,
        tostring(spellName),
        tostring(spellId)
    ))

    state.beginSequence(spellId, spellName, casts, compat.now())

    local firstOk = castOnce(player, 1)
    if not firstOk then
        return false
    end

    if casts <= 1 then
        debug.log("Sequence complete (x1 mode)")
        state.completeSequence()
        return true
    end

    queueNext(player, 2)
    return true
end

return M
