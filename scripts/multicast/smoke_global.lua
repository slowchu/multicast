local interfaces = require("openmw.interfaces")

local function log(msg)
    print("[MulticastSmoke] " .. tostring(msg))
end

local function hasMagExp()
    return interfaces and interfaces.MagExp and type(interfaces.MagExp.launchSpell) == "function"
end

return {
    eventHandlers = {
        MulticastSmoke_Ping = function(data)
            log("received MulticastSmoke_Ping")
            local requester = data and data.requester
            local available = hasMagExp()

            -- Explicit transport check: GLOBAL -> PLAYER via object:sendEvent(...).
            if requester and type(requester.sendEvent) == "function" then
                requester:sendEvent("MulticastSmoke_Pong", {
                    magExpAvailable = available,
                    reason = available and "ok" or "interfaces.MagExp.launchSpell missing",
                })
                log("sent MulticastSmoke_Pong")
            else
                log("requester missing sendEvent; cannot reply")
            end
        end,
    },
}
