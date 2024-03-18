---@class Highlights
---@field theme integer the current theme index
---@field themes table
local Highlights = {}

local ns_id = vim.api.nvim_create_namespace("15puzzle")

function Highlights.set_theme()
    Highlights.theme = 0
    Highlights.next_theme()
end

function Highlights.next_theme()
    Highlights.theme = math.min(#Highlights.themes, Highlights.theme + 1)
    for hl, colors in pairs(Highlights.themes[Highlights.theme]) do
        vim.api.nvim_set_hl(ns_id, hl, colors)
    end
end

function Highlights.prev_theme()
    Highlights.theme = math.max(1, Highlights.theme - 1)
    for hl, colors in pairs(Highlights.themes[Highlights.theme]) do
        vim.api.nvim_set_hl(ns_id, hl, colors)
    end
end

Highlights.themes = {}
Highlights.themes[1] = {
    PuzzleOk = { fg = "#002824", bg = "#00b294", bold = true },
    PuzzleErr = { fg = "#002824", bg = "#ef5222", bold = true },
    -- PuzzleEmpty = { fg = "#ff896e", bg = "#ff896e", bold = true },
    PuzzleEmpty = { fg = "#f9c0c2", bg = "#f9c0c2", bold = true },
    PuzzleBackground = { fg = "#f9c0c2", bg = "#f9c0c2", bold = true },
    PuzzleConfirmation = { fg = "#002824", bg = "#f9c0c2", bold = true },
}

Highlights.themes[2] = {
    PuzzleOk = { fg = "#000000", bg = "#abffd1", bold = true },
    PuzzleErr = { fg = "#abffd1", bg = "#8c002b", bold = true },
    -- PuzzleEmpty = { fg = "#424242", bg = "#424242", bold = true },
    PuzzleEmpty = { fg = "#f9c0c2", bg = "#f9c0c2", bold = true },
    PuzzleBackground = { fg = "#f9c0c2", bg = "#f9c0c2", bold = true },
    PuzzleConfirmation = { fg = "#000000", bg = "#f9c0c2", bold = true },
}

Highlights.themes[3] = {
    PuzzleOk = { fg = "#290033", bg = "#ffbb22", bold = true },
    PuzzleErr = { fg = "#290033", bg = "#8c002b", bold = true },
    -- PuzzleEmpty = { fg = "#f4c7ff", bg = "#f4c7ff", bold = true },
    PuzzleEmpty = { fg = "#caa7e8", bg = "#caa7e8", bold = true },
    PuzzleBackground = { fg = "#caa7e8", bg = "#caa7e8", bold = true },
    PuzzleConfirmation = { fg = "#290033", bg = "#caa7e8", bold = true },
}

Highlights.themes[4] = {
    PuzzleOk = { fg = "#000000", bg = "#00b294", bold = true },
    PuzzleErr = { fg = "#000000", bg = "#d12c00", bold = true },
    -- PuzzleEmpty = { fg = "#db7979", bg = "#db7979", bold = true },
    PuzzleEmpty = { fg = "#ffce00", bg = "#ffce00", bold = true },
    PuzzleBackground = { fg = "#ffce00", bg = "#ffce00", bold = true },
    PuzzleConfirmation = { fg = "#290033", bg = "#caa7e8", bold = true },
}

Highlights.themes[5] = {
    PuzzleOk = { fg = "#000000", bg = "#006400", bold = true },
    PuzzleErr = { fg = "#000000", bg = "#8b0000", bold = true },
    -- PuzzleEmpty = { fg = "#000000", bg = "#000000", bold = true },
    PuzzleEmpty = { fg = "#aa9c8f", bg = "#aa9c8f", bold = true },
    PuzzleBackground = { fg = "#aa9c8f", bg = "#aa9c8f", bold = true },
    PuzzleConfirmation = { fg = "#000000", bg = "#aa9c8f", bold = true },
}

return Highlights
