-- OpenMW compatibility helpers.
-- Keep this small: only version-sensitive wrappers that are actually needed.

local core = require("openmw.core")
local async = require("openmw.async")
local selfObj = require("openmw.self")
local types = require("openmw.types")
local ui = require("openmw.ui")

local M = {}
M._keyHandler = nil

function M.describeApiAssumptions()
    return table.concat({
        "Selected spell is read using types.Actor.selectedSpell(player)",
        "Burst timing uses async:newSimulationTimer",
        "Spell Framework Plus requests are sent by core.sendGlobalEvent('MagExp_CastRequest', data)",
    }, " | ")
end

function M.now()
    if type(core.getSimulationTime) == "function" then
        return core.getSimulationTime()
    end
    return os.clock()
end

function M.player()
    return selfObj
end

function M.showMessage(text)
    if type(ui.showMessage) == "function" then
        ui.showMessage(tostring(text))
    end
end

function M.getSelectedSpell(player)
    if not player then
        return nil
    end

    -- Documented type API.
    return types.Actor.selectedSpell(player)
end

function M.getSpellId(spell)
    if not spell then
        return nil
    end
    return spell.id or spell.recordId
end

function M.getSpellName(spell)
    if not spell then
        return nil
    end
    return spell.name or spell.id or spell.recordId
end

function M.sendGlobalEvent(eventName, data)
    return core.sendGlobalEvent(eventName, data)
end

function M.registerKeyHandler(callback)
    M._keyHandler = callback
end

function M.handleKeyPress(keyCode)
    if M._keyHandler then
        M._keyHandler(keyCode)
    end
end

function M.scheduleSimulation(delaySeconds, callback)
    -- openmw.async docs: functions are methods on async package.
    return async:newSimulationTimer(delaySeconds, async:callback(callback))
end

return M
