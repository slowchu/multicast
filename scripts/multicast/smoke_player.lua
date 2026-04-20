local core = require("openmw.core")
local self = require("openmw.self")
local types = require("openmw.types")
local util = require("openmw.util")

local function log(msg)
    print("[MulticastSmoke] " .. tostring(msg))
end

local function runSmoke()
    local spell = nil
    if types.Actor and type(types.Actor.getSelectedSpell) == "function" then
        spell = types.Actor.getSelectedSpell(self)
    end

    local spellId = spell and (spell.id or spell.recordId or spell.name) or "<none>"
    log("selected spell = " .. tostring(spellId))

    local dir = self.rotation * util.vector3(0, 1, 0)
    log(string.format("direction = (%.3f, %.3f, %.3f)", dir.x, dir.y, dir.z))

    core.sendGlobalEvent("MulticastSmoke_Ping", {
        requester = self,
        spellId = spellId,
    })
    log("sent MulticastSmoke_Ping")
end

return {
    engineHandlers = {
        onKeyPress = function(key)
            if key and key.symbol == "k" then
                runSmoke()
            end
        end,
    },
    eventHandlers = {
        MulticastSmoke_Pong = function(data)
            log("received MulticastSmoke_Pong")
            log("MagExp interface available = " .. tostring(data and data.magExpAvailable))
            if data and data.reason then
                log("reason = " .. tostring(data.reason))
            end
        end,
    },
}
