local config = require("scripts.multicast.config")
local state = require("scripts.multicast.state")
local debug = require("scripts.multicast.debug")
local compat = require("scripts.multicast.compat")
local dependency = require("scripts.multicast.dependency")
local castController = require("scripts.multicast.cast_controller")
local backend = require("scripts.multicast.magexp_backend")
local input = require("scripts.multicast.input")
local ui = require("scripts.multicast.ui")

local function onCycleMode()
    local modeCount = state.cycleMode()
    debug.log(string.format("Mode changed: x%d", modeCount))
    debug.message(string.format("Multicast mode: x%d", modeCount))
    ui.refresh(state)
end

local function onTriggerCast()
    debug.log("Burst trigger requested")
    local ok = castController.triggerMulticast()
    if ok then
        ui.refresh(state)
    end
end

local function init()
    dependency.reset()

    debug.log("Initializing multicast (Spell Framework Plus backend)")
    debug.log("API assumptions: " .. compat.describeApiAssumptions())
    debug.log("Backend: " .. backend.backendName())
    debug.log("Dependency check strategy: validate on first launch request via protected global event")
    debug.log(string.format(
        "Config: interval=%.2f, debug=%s",
        config.defaultIntervalSeconds,
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
        -- Fallback key path.
        onKeyPress = function(key)
            compat.handleKeyPress(key)
        end,
    },
}
