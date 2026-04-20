local debug = require("scripts.multicast.debug")

local M = {
    _missingAnnounced = false,
}

local function announceMissing(reason)
    if M._missingAnnounced then
        return
    end
    M._missingAnnounced = true

    debug.error("Required dependency unavailable: " .. tostring(reason))
    debug.message("Multicast disabled: Spell Framework Plus / MaxYari Lua Physics missing.")
end

function M.reset()
    M._missingAnnounced = false
end

function M.reportMissing(reason)
    announceMissing(reason or "unknown dependency error")
end

function M.markBackendAvailable()
    if M._missingAnnounced then
        debug.log("Dependency path recovered: Spell Framework Plus event path responded")
    end
    M._missingAnnounced = false
end

return M
