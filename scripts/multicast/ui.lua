local config = require("scripts.multicast.config")
local debug = require("scripts.multicast.debug")
local dependency = require("scripts.multicast.dependency")

local M = {
    _lastStatusLine = nil,
}

local function formatStatus(state)
    local mode = state.getModeCount()
    local busy = state.busy and "ACTIVE" or "IDLE"
    local remaining = state.remainingCasts or 0
    local dep = dependency.getStateLabel()
    return string.format("Multicast x%d | %s | queued: %d | backend: %s", mode, busy, remaining, dep)
end

function M.init()
    if not config.ui.enabled then
        return
    end
    debug.log("UI initialized (message-based status)")
end

function M.refresh(state)
    if not config.ui.enabled then
        return
    end

    local line = formatStatus(state)
    if line ~= M._lastStatusLine then
        debug.message(line)
        M._lastStatusLine = line
    end
end

return M
