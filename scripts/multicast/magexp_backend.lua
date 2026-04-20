local compat = require("scripts.multicast.compat")
local dependency = require("scripts.multicast.dependency")

local M = {}

function M.backendName()
    return "GLOBAL bridge -> interfaces.MagExp.launchSpell"
end

function M.requestHandshake(player)
    local ok, resultOrErr = pcall(compat.sendGlobalEvent, "Multicast_CheckBackend", {
        requester = player,
    })

    if not ok then
        return false, tostring(resultOrErr)
    end

    return true, "handshake request dispatched"
end

function M.launch(data)
    if not data or not data.spellId then
        return false, "invalid launch data"
    end

    if dependency.isChecking() then
        return false, "backend still checking"
    end

    if not dependency.isAvailable() then
        return false, dependency.getReason() or "backend unavailable"
    end

    local ok, resultOrErr = pcall(compat.sendGlobalEvent, "Multicast_LaunchRequest", data)
    if not ok then
        return false, tostring(resultOrErr)
    end

    return true, "launch request dispatched"
end

return M
