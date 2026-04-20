local config = require("scripts.multicast.config")
local debug = require("scripts.multicast.debug")

local M = {
    _lastHudLine = nil,
}

local function formatHud(state)
    local mode = state.getModeCount()
    local status = state.busy and "ACTIVE" or "IDLE"
    local remaining = state.remainingCasts or 0
    return string.format("Multicast x%d | %s | queued: %d", mode, status, remaining)
end

function M.init()
    if not config.ui.enabled then
        return
    end
    debug.log("UI initialized (message-based HUD prototype)")
end

function M.refresh(state)
    if not config.ui.enabled then
        return
    end
    local line = formatHud(state)
    if line ~= M._lastHudLine then
        debug.message(line)
        M._lastHudLine = line
    end
end

return M
