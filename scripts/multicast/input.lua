local config = require("scripts.multicast.config")
local debug = require("scripts.multicast.debug")
local compat = require("scripts.multicast.compat")

local M = {
    _handlers = nil,
}

function M.init(handlers)
    M._handlers = handlers

    compat.registerKeyHandler(function(key)
        if not key then
            return
        end

        local symbol = key.symbol
        if not symbol then
            return
        end
        if type(symbol) ~= "string" then
            symbol = tostring(symbol)
        end

        symbol = symbol:lower()

        if symbol == config.input.cycleKey then
            debug.log("Input: cycle mode key pressed")
            M._handlers.onCycleMode()
        elseif symbol == config.input.triggerKey then
            debug.log("Input: trigger burst key pressed")
            M._handlers.onTriggerCast()
        end
    end)

    debug.log("Input initialized (fallback key symbols: m=cycle, n=trigger)")
end

return M
