local config = require("scripts.multicast.config")
local compat = require("scripts.multicast.compat")

local M = {}
local PREFIX = "[Multicast]"

local function fmt(message)
    return string.format("%s %s", PREFIX, tostring(message))
end

function M.log(message)
    if not config.debugEnabled then
        return
    end
    print(fmt(message))
end

function M.warn(message)
    print(fmt("WARN: " .. tostring(message)))
end

function M.error(message)
    print(fmt("ERROR: " .. tostring(message)))
end

function M.message(message)
    if config.ui.showScreenMessages then
        compat.showMessage(fmt(message))
    end
end

return M
