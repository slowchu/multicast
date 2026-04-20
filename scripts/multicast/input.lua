local config = require("scripts.multicast.config")
local debug = require("scripts.multicast.debug")
local compat = require("scripts.multicast.compat")

local M = {
    _handlers = nil,
}

function M.init(handlers)
    M._handlers = handlers

    compat.registerKeyHandler(function(keyCode)
        if keyCode == config.input.cycleKey then
            debug.log("Input: cycle mode key pressed")
            M._handlers.onCycleMode()
        elseif keyCode == config.input.triggerKey then
            debug.log("Input: trigger burst key pressed")
            M._handlers.onTriggerCast()
        end
    end)

    debug.log("Input initialized (fallback keys: M=cycle, N=trigger)")
end

return M
