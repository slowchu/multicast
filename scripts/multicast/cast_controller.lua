local config = require("scripts.multicast.config")
local state = require("scripts.multicast.state")
local debug = require("scripts.multicast.debug")
local compat = require("scripts.multicast.compat")
local backend = require("scripts.multicast.magexp_backend")
local targeting = require("scripts.multicast.targeting")

local M = {}

local function cancel(reason)
    debug.warn("Burst cancelled: " .. tostring(reason))
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

    return true, currentSpell
end

local function launchOnce(player, castIndex)
    local now = compat.now()
    debug.log(string.format("Launch attempt #%d at t=%.3f", castIndex, now))

    local ok, currentSpellOrReason = validateSnapshot(player)
    if not ok then
        cancel(currentSpellOrReason)
        return false
    end

    local currentSpell = currentSpellOrReason
    local requestData, targetReason = targeting.buildLaunchData(player, currentSpell)
    if not requestData then
        cancel("targeting failed: " .. tostring(targetReason))
        return false
    end

    debug.log(string.format(
        "Sending MagExp cast request: spellId=%s",
        tostring(requestData.spellId)
    ))

    local launched, launchReason = backend.launch(requestData)
    if not launched then
        cancel("backend launch failed: " .. tostring(launchReason))
        return false
    end

    return true
end

local function queueNext(player, nextCastIndex)
    if not state.busy then
        return
    end

    if state.remainingCasts <= 0 then
        debug.log("Burst sequence complete")
        state.completeSequence()
        return
    end

    debug.log(string.format(
        "Queueing launch #%d in %.2fs (remaining queued: %d)",
        nextCastIndex,
        config.defaultIntervalSeconds,
        state.remainingCasts
    ))

    compat.scheduleSimulation(config.defaultIntervalSeconds, function()
        debug.log(string.format("Timer fired for launch #%d", nextCastIndex))

        if not state.busy then
            return
        end

        local launched = launchOnce(player, nextCastIndex)
        if not launched then
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
        debug.warn("Trigger rejected: burst already active")
        return false
    end

    local spell, spellId, spellName = selectedSpellSnapshot(player)
    if not spell or not spellId then
        debug.warn("Trigger rejected: no selected spell")
        return false
    end

    local casts = state.getModeCount()
    debug.log(string.format(
        "Trigger burst: mode=x%d, spell=%s (%s), backend=%s",
        casts,
        tostring(spellName),
        tostring(spellId),
        backend.backendName()
    ))

    state.beginSequence(spellId, spellName, casts, compat.now())

    local firstOk = launchOnce(player, 1)
    if not firstOk then
        return false
    end

    if casts <= 1 then
        debug.log("Burst sequence complete (x1 mode)")
        state.completeSequence()
        return true
    end

    queueNext(player, 2)
    return true
end

return M
