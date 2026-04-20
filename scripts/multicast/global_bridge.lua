local interfaces = require("openmw.interfaces")

local M = {}

local function isBackendReady()
    return interfaces
        and interfaces.MagExp
        and type(interfaces.MagExp.launchSpell) == "function"
end

local function sendToRequester(requester, eventName, data)
    if requester and type(requester.sendEvent) == "function" then
        requester:sendEvent(eventName, data or {})
    end
end

local function describeMissing()
    if not interfaces then
        return "openmw.interfaces unavailable"
    end
    if not interfaces.MagExp then
        return "interfaces.MagExp missing"
    end
    if type(interfaces.MagExp.launchSpell) ~= "function" then
        return "interfaces.MagExp.launchSpell missing"
    end
    return "unknown"
end

function M.onCheckBackend(data)
    local requester = data and data.requester

    if isBackendReady() then
        sendToRequester(requester, "Multicast_BackendReady", {
            backend = "interfaces.MagExp.launchSpell",
        })
        return
    end

    sendToRequester(requester, "Multicast_BackendUnavailable", {
        reason = describeMissing(),
    })
end

function M.onLaunchRequest(data)
    local requester = data and data.attacker

    if not isBackendReady() then
        sendToRequester(requester, "Multicast_LaunchFailed", {
            reason = describeMissing(),
        })
        return
    end

    local ok, resultOrErr = pcall(interfaces.MagExp.launchSpell, data)
    if not ok then
        sendToRequester(requester, "Multicast_LaunchFailed", {
            reason = tostring(resultOrErr),
        })
        return
    end

    sendToRequester(requester, "Multicast_LaunchAccepted", {
        spellId = data and data.spellId,
    })
end

return {
    eventHandlers = {
        Multicast_CheckBackend = M.onCheckBackend,
        Multicast_LaunchRequest = M.onLaunchRequest,
    },
}
