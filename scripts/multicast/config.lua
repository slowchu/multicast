local M = {}

M.modeCounts = { 1, 2, 3, 5 }
M.defaultModeIndex = 1
M.defaultIntervalSeconds = 0.25

M.debugEnabled = true
M.forceSpellStance = true

M.input = {
    cycleKey = string.byte("M"),
    triggerKey = string.byte("N"),
}

M.ui = {
    enabled = true,
    showScreenMessages = true,
}

return M
