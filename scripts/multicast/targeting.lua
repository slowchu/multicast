local compat = require("scripts.multicast.compat")

local M = {}

local function forwardFromRotation(rotation)
    if not rotation then
        return { x = 0, y = 1, z = 0 }
    end

    -- Morrowind-style yaw around Z axis; pitch tilts up/down.
    local yaw = rotation.z or 0
    local pitch = rotation.x or 0

    local cp = math.cos(pitch)
    return {
        x = math.sin(yaw) * cp,
        y = math.cos(yaw) * cp,
        z = math.sin(pitch),
    }
end

local function offsetStart(position, direction)
    if not position or not direction then
        return position
    end

    return {
        x = (position.x or 0) + (direction.x or 0) * 20,
        y = (position.y or 0) + (direction.y or 0) * 20,
        z = (position.z or 0) + 120,
    }
end

function M.buildLaunchData(player, spell)
    local spellId = compat.getSpellId(spell)
    if not player or not spellId then
        return nil, "missing player or spellId"
    end

    local direction = forwardFromRotation(player.rotation)
    local startPos = offsetStart(player.position, direction)

    return {
        attacker = player,
        spellId = spellId,
        startPos = startPos,
        direction = direction,
    }, nil
end

return M
