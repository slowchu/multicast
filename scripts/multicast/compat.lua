-- Compatibility wrapper for OpenMW API differences across 0.51/dev snapshots.
-- Assumptions are logged by init.lua at startup.

local M = {}

local function safeRequire(name)
    local ok, result = pcall(require, name)
    if ok then
        return result
    end
    return nil
end

local core = safeRequire("openmw.core")
local selfObj = safeRequire("openmw.self")
local input = safeRequire("openmw.input")
local ui = safeRequire("openmw.ui")
local async = safeRequire("openmw.async")
local types = safeRequire("openmw.types")

local function callIfFn(target, fnName, ...)
    if target and type(target[fnName]) == "function" then
        return true, target[fnName](...)
    end
    return false, nil
end

function M.describeApiAssumptions()
    local bits = {
        "Assuming selected-spell read/set and native spell-use calls are exposed in current build",
        "Using openmw.async simulation timers for queued casts (with immediate fallback)",
        "Using key fallback input if action registration APIs are unavailable",
    }
    return table.concat(bits, " | ")
end

function M.now()
    if core and type(core.getSimulationTime) == "function" then
        return core.getSimulationTime()
    end
    return os.clock()
end

function M.player()
    return selfObj
end

function M.showMessage(text)
    if ui and type(ui.showMessage) == "function" then
        ui.showMessage(tostring(text))
    end
end

function M.registerKeyHandler(callback)
    -- No guaranteed global key registration call across builds; this is a marker.
    -- init.lua wires engineHandlers.onKeyPress to forward here where available.
    M._keyHandler = callback
end

function M.handleKeyPress(keyCode)
    if M._keyHandler then
        M._keyHandler(keyCode)
    end
end

function M.getSelectedSpell(player)
    if not player then
        return nil
    end

    -- Common naming candidates across engine/dev snapshots.
    local ok, spell = callIfFn(player, "getSelectedSpell", player)
    if ok then return spell end

    if player.magic and type(player.magic.getSelectedSpell) == "function" then
        return player.magic.getSelectedSpell(player.magic)
    end

    if types and types.Actor and type(types.Actor.selectedSpell) == "function" then
        local success, result = pcall(types.Actor.selectedSpell, player)
        if success then
            return result
        end
    end

    return nil
end

function M.setSelectedSpell(player, spell)
    if not player or not spell then
        return false
    end

    local ok = callIfFn(player, "setSelectedSpell", player, spell)
    if ok then return true end

    if player.magic and type(player.magic.setSelectedSpell) == "function" then
        player.magic.setSelectedSpell(player.magic, spell)
        return true
    end

    if types and types.Actor and type(types.Actor.setSelectedSpell) == "function" then
        local success = pcall(types.Actor.setSelectedSpell, player, spell)
        return success
    end

    return false
end

function M.getSpellId(spell)
    if not spell then return nil end
    return spell.id or spell.recordId or spell.name
end

function M.getSpellName(spell)
    if not spell then return nil end
    return spell.name or spell.id or spell.recordId or "<unknown spell>"
end

function M.ensureSpellStance(player)
    if not player then
        return false
    end

    local ok = callIfFn(player, "setMagicMode", player, true)
    if ok then return true end

    if types and types.Actor and type(types.Actor.setStance) == "function" then
        local success = pcall(types.Actor.setStance, player, "spell")
        if success then
            return true
        end
    end

    return false
end

function M.activateReadiedSpell(player)
    if not player then
        return false
    end

    -- Native cast path candidates.
    local ok = callIfFn(player, "useSelectedSpell", player)
    if ok then return true end

    ok = callIfFn(player, "cast", player)
    if ok then return true end

    if player.magic and type(player.magic.cast) == "function" then
        player.magic.cast(player.magic)
        return true
    end

    if types and types.Actor and type(types.Actor.cast) == "function" then
        local success = pcall(types.Actor.cast, player)
        return success
    end

    return false
end

function M.scheduleSimulation(delaySeconds, callback)
    if async and type(async.newSimulationTimer) == "function" then
        return async.newSimulationTimer(delaySeconds, callback)
    end

    if async and type(async:newSimulationTimer) == "function" then
        return async:newSimulationTimer(delaySeconds, callback)
    end

    -- Fallback: run immediately so behavior remains testable even without timer API.
    callback()
    return nil
end

return M
