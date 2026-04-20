local M = {}

M.modeCounts = { 1, 2, 3, 5 }
M.defaultModeIndex = 1
M.defaultIntervalSeconds = 0.25
M.handshakeTimeoutSeconds = 3.0

M.debugEnabled = true

-- Policy note (deferred in this patch):
-- - Magicka-cost accounting for burst follow-ups is not normalized yet.
-- - Skill progression/XP normalization for burst follow-ups is not normalized yet.

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
