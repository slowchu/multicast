local util = require("openmw.util")
local compat = require("scripts.multicast.compat")

local M = {}

function M.buildLaunchData(player, spell)
    local spellId = compat.getSpellId(spell)
    if not player or not spellId then
        return nil, "missing player or spellId"
    end

    local forward = player.rotation * util.vector3(0, 1, 0)
    local startPos = player.position + util.vector3(0, 0, 120) + (forward * 20)

    return {
        attacker = player,
        spellId = spellId,
        startPos = startPos,
        direction = forward,
    }, nil
end

return M
