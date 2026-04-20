local config = require("scripts.multicast.config")
local state = require("scripts.multicast.state")
local debug = require("scripts.multicast.debug")
local compat = require("scripts.multicast.compat")
local castController = require("scripts.multicast.cast_controller")
local input = require("scripts.multicast.input")
local ui = require("scripts.multicast.ui")

local function onCycleMode()
    local modeCount = state.cycleMode()
    debug.log(string.format("Mode changed: x%d", modeCount))
    ui.refresh(state)
end

local function onTriggerCast()
    debug.log("Multicast trigger requested")
    local ok = castController.triggerMulticast()
    if ok then
        ui.refresh(state)
    end
end

local function init()
    debug.log("Initializing multicast prototype")
    debug.log("API assumptions: " .. compat.describeApiAssumptions())
    debug.log(string.format(
        "Config: interval=%.2f, forceSpellStance=%s, debug=%s",
        config.defaultIntervalSeconds,
        tostring(config.forceSpellStance),
        tostring(config.debugEnabled)
    ))

    input.init({
        onCycleMode = onCycleMode,
        onTriggerCast = onTriggerCast,
    })
    ui.init()
    ui.refresh(state)

    debug.log("Initialization complete")
end

init()

return {
    engineHandlers = {
        -- Forward key presses to compat/input fallback path.
        -- If this event is unavailable in a specific build, action registration
        -- can be added in input.lua without changing cast/state architecture.
        onKeyPress = function(key)
            compat.handleKeyPress(key)
        end,
    },
}
