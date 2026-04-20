local debug = require("scripts.multicast.debug")

local M = {
    _state = "unknown",
    _reason = nil,
    _announcedUnavailable = false,
}

local function announceUnavailable(reason)
    if M._announcedUnavailable then
        return
    end
    M._announcedUnavailable = true

    debug.error("Backend unavailable: " .. tostring(reason))
    debug.message("Multicast unavailable: Spell Framework Plus bridge not ready.")
end

function M.isAvailable()
    return M._state == "available"
end

function M.isChecking()
    return M._state == "checking" or M._state == "unknown"
end

function M.getState()
    return M._state
end

function M.getReason()
    return M._reason
end

function M.getStateLabel()
    if M._state == "available" then
        return "READY"
    end
    if M._state == "checking" then
        return "CHECKING"
    end
    if M._state == "unavailable" then
        return "UNAVAILABLE"
    end
    return "UNKNOWN"
end

function M.setChecking()
    M._state = "checking"
    M._reason = nil
end

function M.setAvailable()
    M._state = "available"
    M._reason = nil
    M._announcedUnavailable = false
end

function M.setUnavailable(reason)
    M._state = "unavailable"
    M._reason = reason or "unknown"
    announceUnavailable(M._reason)
end

return M
