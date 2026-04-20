local M = {}

M.modeCounts = { 1, 2, 3, 5 }
M.defaultModeIndex = 1
M.defaultIntervalSeconds = 0.25

M.debugEnabled = true

M.input = {
    -- Fallback key handling via onKeyPress in player context.
    cycleKey = "m",
    triggerKey = "n",
}

M.ui = {
    enabled = true,
    showScreenMessages = true,
}

return M
