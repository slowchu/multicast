local config = require("scripts.multicast.config")

local M = {
    modeIndex = config.defaultModeIndex,
    busy = false,
    remainingCasts = 0,
    snapshotSpellId = nil,
    snapshotSpellName = nil,
    sequenceStartTimestamp = 0,
}

local function clampModeIndex(idx)
    if idx < 1 then
        return 1
    end
    if idx > #config.modeCounts then
        return #config.modeCounts
    end
    return idx
end

function M.getModeCount()
    return config.modeCounts[M.modeIndex]
end

function M.cycleMode()
    M.modeIndex = M.modeIndex + 1
    if M.modeIndex > #config.modeCounts then
        M.modeIndex = 1
    end
    return M.getModeCount(), M.modeIndex
end

function M.setModeIndex(idx)
    M.modeIndex = clampModeIndex(idx)
    return M.getModeCount(), M.modeIndex
end

function M.beginSequence(snapshotSpellId, snapshotSpellName, totalCasts, timestamp)
    M.busy = true
    M.remainingCasts = math.max(0, (totalCasts or 1) - 1)
    M.snapshotSpellId = snapshotSpellId
    M.snapshotSpellName = snapshotSpellName
    M.sequenceStartTimestamp = timestamp or 0
end

function M.completeSequence()
    M.busy = false
    M.remainingCasts = 0
    M.snapshotSpellId = nil
    M.snapshotSpellName = nil
    M.sequenceStartTimestamp = 0
end

function M.cancelSequence()
    M.completeSequence()
end

return M
