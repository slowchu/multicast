local config = require("scripts.multicast.config")
local state = require("scripts.multicast.state")
local debug = require("scripts.multicast.debug")
local compat = require("scripts.multicast.compat")
local dependency = require("scripts.multicast.dependency")
local castController = require("scripts.multicast.cast_controller")
local backend = require("scripts.multicast.magexp_backend")
local input = require("scripts.multicast.input")
local ui = require("scripts.multicast.ui")

local handshakeRequestId = 0

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

local function requestBackendHandshake()
    handshakeRequestId = handshakeRequestId + 1
    local requestId = handshakeRequestId

    local ok, reason = backend.requestHandshake(compat.player())
    if not ok then
        dependency.setUnavailable("handshake dispatch failed: " .. tostring(reason))
        ui.refresh(state)
        return
    end

    debug.log("Requested backend handshake from GLOBAL bridge (requestId=" .. tostring(requestId) .. ")")

    compat.scheduleSimulation(config.handshakeTimeoutSeconds, function()
        if requestId ~= handshakeRequestId then
            return
        end
        if dependency.isChecking() then
            dependency.setUnavailable("handshake timeout")
            debug.warn("Backend handshake timed out")
            debug.message("Multicast backend check timed out.")
            ui.refresh(state)
        end
    end)
end

local function init()
    dependency.setChecking()

    debug.log("Initializing multicast (PLAYER + GLOBAL bridge)")
    debug.log("API assumptions: " .. compat.describeApiAssumptions())
    debug.log("Backend path: " .. backend.backendName())
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

    requestBackendHandshake()

    debug.log("Initialization complete")
end

init()

return {
    engineHandlers = {
        onKeyPress = function(key)
            compat.handleKeyPress(key)
        end,
    },
    eventHandlers = {
        Multicast_BackendReady = function(data)
            handshakeRequestId = handshakeRequestId + 1
            dependency.setAvailable()
            debug.log("Backend ready confirmed by handshake")
            if data and data.backend then
                debug.log("Global backend reports: " .. tostring(data.backend))
            end
            debug.message("Multicast backend ready.")
            ui.refresh(state)
        end,
        Multicast_BackendUnavailable = function(data)
            handshakeRequestId = handshakeRequestId + 1
            local reason = (data and data.reason) or "unknown"
            dependency.setUnavailable(reason)
            debug.warn("Backend unavailable from handshake: " .. tostring(reason))
            ui.refresh(state)
        end,
        Multicast_LaunchAccepted = function(data)
            if data and data.spellId then
                debug.log("Launch accepted by GLOBAL bridge: " .. tostring(data.spellId))
            else
                debug.log("Launch accepted by GLOBAL bridge")
            end
        end,
        Multicast_LaunchFailed = function(data)
            local reason = (data and data.reason) or "unknown"
            dependency.setUnavailable(reason)
            debug.warn("Launch failed in GLOBAL bridge: " .. tostring(reason))
            ui.refresh(state)
        end,
    },
}
