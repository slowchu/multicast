local debug = require("scripts.multicast.debug")
local compat = require("scripts.multicast.compat")
local dependency = require("scripts.multicast.dependency")

local M = {}

function M.backendName()
    return "Spell Framework Plus (MagExp_CastRequest)"
end

function M.launch(data)
    if not data or not data.spellId then
        return false, "invalid cast request data"
    end

    local ok, err = pcall(compat.sendGlobalEvent, "MagExp_CastRequest", data)
    if not ok then
        dependency.reportMissing(err)
        debug.error("MagExp_CastRequest failed: " .. tostring(err))
        return false, tostring(err)
    end

    dependency.markBackendAvailable()
    return true, nil
end

return M
