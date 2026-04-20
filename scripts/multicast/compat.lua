-- OpenMW compatibility helpers.
-- Keep this small: only wrappers needed by the multicast prototype.

local core = require("openmw.core")
local async = require("openmw.async")
local selfObj = require("openmw.self")
local types = require("openmw.types")
local ui = require("openmw.ui")

local M = {}
M._keyHandler = nil

function M.describeApiAssumptions()
    return table.concat({
        "Selected spell uses types.Actor.getSelectedSpell(actor)",
        "Burst timing uses async:newUnsavableSimulationTimer for inline closures",
        "PLAYER->GLOBAL coordination uses core.sendGlobalEvent + object sendEvent replies",
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

    if types.Actor and type(types.Actor.getSelectedSpell) == "function" then
        return types.Actor.getSelectedSpell(player)
    end

    -- Cautious compatibility fallback for older aliases.
    if types.Actor and type(types.Actor.selectedSpell) == "function" then
        return types.Actor.selectedSpell(player)
    end

    return nil
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

function M.handleKeyPress(key)
    if M._keyHandler then
        M._keyHandler(key)
    end
end

function M.scheduleSimulation(delaySeconds, callback)
    return async:newUnsavableSimulationTimer(delaySeconds, callback)
end

return M
