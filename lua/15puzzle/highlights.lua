local Highlights = {}

function Highlights.setup(ns_id)
    -- TODO: change colors
    vim.api.nvim_set_hl(ns_id, "PuzzleOk", { fg = "#000000", bg = "#006400", bold = true })
    vim.api.nvim_set_hl(ns_id, "PuzzleErr", { fg = "#000000", bg = "#8b0000", bold = true })
    vim.api.nvim_set_hl(ns_id, "PuzzleEmpty", { fg = "#000000", bg = "#000000", bold = true })
    vim.api.nvim_set_hl(ns_id, "PuzzleBackground", { fg = "#aa9c8f", bg = "#aa9c8f", bold = true })
    vim.api.nvim_set_hl(
        ns_id,
        "PuzzleConfirmation",
        { fg = "#ffffff", bg = "#aa9c8f", bold = true }
    )
end

return Highlights
