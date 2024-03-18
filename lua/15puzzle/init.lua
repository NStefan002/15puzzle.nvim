local Highlights = require("15puzzle.highlights")

---@class Config
---@field keys Keymap

---@class Keymap
---@field up string
---@field down string
---@field left string
---@field right string
---@field new_game string
---@field confirm string
---@field cancel string
---@field next_theme string
---@field prev_theme string

---@class Puzzle
---@field bufnr integer
---@field winnr integer
---@field score_bufnr integer
---@field score_winnr integer
---@field ns_id integer
---@field number_of_moves integer
---@field time number
---@field timer uv_timer_t
---@field board table
---@field board_height integer
---@field board_width integer
---@field opts Config
---@field _square_height integer
---@field _square_width integer
---@field _vertical_padding integer
---@field _horizontal_padding integer
---@field _up_down_animation_interval number
---@field _left_right_animation_interval number
---@field _timer_presision number
local Puzzle = {}
Puzzle.__index = Puzzle

function Puzzle.new()
    local self = setmetatable({
        bufnr = nil,
        winnr = nil,
        score_bufnr = nil,
        score_winnr = nil,
        ns_id = vim.api.nvim_create_namespace("15puzzle"),

        number_of_moves = 0,
        time = 0,

        board = {},
        empty_i = 0,
        empty_j = 0,
        board_height = 4,
        board_width = 4,

        opts = {
            keys = {
                up = "k",
                down = "j",
                left = "h",
                right = "l",
                new_game = "n",
                confirm = "<CR>",
                cancel = "<Esc>",
                next_theme = "<c-l>",
                prev_theme = "<c-h>",
            },
        },

        _square_height = 5,
        _square_width = 10,
        _vertical_padding = 1,
        _horizontal_padding = 2,
        _up_down_animation_interval = 30,
        _left_right_animation_interval = nil,
        _timer_presision = 100,
    }, Puzzle)
    self._left_right_animation_interval = self._up_down_animation_interval
        * (self._square_height + self._vertical_padding)
        / (self._square_width + self._horizontal_padding)

    return self
end

local puzzle = Puzzle.new()

---@param opts? Config
function Puzzle.setup(opts)
    opts = opts or {}
    puzzle.opts = vim.tbl_deep_extend("force", puzzle.opts, opts)

    math.randomseed(os.time())
    Highlights.set_theme()
    vim.api.nvim_create_user_command("Play15puzzle", function(event)
        if #event.fargs > 0 then
            error("15puzzle: command does not take arguments.")
        end
        puzzle:close_window()
        puzzle:generate_board()
        puzzle:create_window()
        puzzle:start_timer()
    end, { nargs = 0, desc = "Start 15puzzle game." })
end

function Puzzle:generate_board()
    for i = 1, self.board_height do
        self.board[i] = {}
        for j = 1, self.board_width do
            self.board[i][j] = (i - 1) * self.board_height + j
        end
    end
    self.board[self.board_height][self.board_width] = 0
    local steps = 100
    local empty_i, empty_j = self.board_height, self.board_width
    while steps > 0 do
        local moves = self:get_legal_moves(empty_i, empty_j)
        local move = moves[math.random(#moves)]
        local new_i, new_j = move[1], move[2]
        self.board[empty_i][empty_j], self.board[new_i][new_j] =
            self.board[new_i][new_j], self.board[empty_i][empty_j]
        empty_i, empty_j = new_i, new_j
        steps = steps - 1
    end
    self.empty_i, self.empty_j = empty_i, empty_j
end

function Puzzle:create_window()
    local height = (self._square_height + self._vertical_padding) * self.board_height
        + self._vertical_padding
    local width = (self._square_width + self._horizontal_padding) * self.board_width
        + self._horizontal_padding

    -- NOTE: Why 5? -> 5 is just an approximation, so there is enough space for the scoreboard
    -- window, and a little bit of padding between the scoreboard window and the top of the editor
    local extra_space = 5

    local nvim_uis = vim.api.nvim_list_uis()
    if #nvim_uis > 0 then
        if nvim_uis[1].height <= height + extra_space or nvim_uis[1].width <= width then
            error("15puzzle: increase the size of your Neovim instance.")
        end
    end

    local cols = vim.o.columns
    local lines = vim.o.lines - vim.o.cmdheight
    local bufnr = vim.api.nvim_create_buf(false, true)

    local winnr = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        anchor = "NW",
        title = " 15 Puzzle ",
        title_pos = "center",
        row = math.floor((lines - height) / 2),
        col = math.floor((cols - width) / 2),
        width = width,
        height = height,
        style = "minimal",
        border = "single",
        noautocmd = true,
    })

    if winnr == 0 then
        error("15puzzle: failed to open window")
    end

    vim.api.nvim_set_option_value("filetype", "15puzzle", { buf = bufnr })
    self.bufnr = bufnr
    self.winnr = winnr

    self:clear_buffer_text()
    vim.api.nvim_win_set_hl_ns(self.winnr, self.ns_id)

    self:create_scoreboard_window()
    self:set_keymaps()
    self:create_autocmds()
    self:draw()
end

function Puzzle:close_window()
    if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
    end

    if self.winnr ~= nil and vim.api.nvim_win_is_valid(self.winnr) then
        vim.api.nvim_win_close(self.winnr, true)
    end
    self.bufnr = nil
    self.winnr = nil

    self:close_scoreboard_window()
    pcall(vim.api.nvim_del_augroup_by_name, "15puzzle")
    self.changed = false
end

function Puzzle:create_scoreboard_window()
    local height = 1
    local width = vim.api.nvim_win_get_width(self.winnr)

    local bufnr = vim.api.nvim_create_buf(false, true)

    local winnr = vim.api.nvim_open_win(bufnr, false, {
        relative = "win",
        win = self.winnr,
        anchor = "SW",
        title = " Score ",
        title_pos = "center",
        row = -1,
        col = -1,
        width = width,
        height = height,
        style = "minimal",
        border = "single",
        focusable = false,
        noautocmd = true,
    })

    if winnr == 0 then
        error("15puzzle: failed to open scoreboard window")
    end

    vim.api.nvim_set_option_value("filetype", "15puzzle_scoreboard", { buf = bufnr })
    self.score_bufnr = bufnr
    self.score_winnr = winnr
    vim.api.nvim_win_set_hl_ns(self.score_winnr, self.ns_id)
end

function Puzzle:close_scoreboard_window()
    if self.score_bufnr ~= nil and vim.api.nvim_buf_is_valid(self.score_bufnr) then
        vim.api.nvim_buf_delete(self.score_bufnr, { force = true })
    end

    if self.score_winnr ~= nil and vim.api.nvim_win_is_valid(self.score_winnr) then
        vim.api.nvim_win_close(self.score_winnr, true)
    end

    self.score_bufnr = nil
    self.score_winnr = nil
end

function Puzzle:create_autocmds()
    local autocmd = vim.api.nvim_create_autocmd
    local augroup = vim.api.nvim_create_augroup
    local grp = augroup("15puzzle", {})

    autocmd("WinClosed", {
        group = grp,
        callback = function(ev)
            if tonumber(ev.match) == self.winnr then
                vim.api.nvim_win_close(self.score_winnr, true)
                self:stop_timer()
                pcall(vim.api.nvim_del_augroup_by_id, grp)
            end
        end,
        desc = "Close the scoreboard window when the game window is closed",
    })
    autocmd({ "WinResized", "VimResized" }, {
        group = grp,
        callback = function(ev)
            if ev.event == "VimResized" or tonumber(ev.match) == self.winnr then
                self:stop_timer()
                self:close_window()
                self:create_window()
                self:start_timer()
            end
        end,
        desc = "React to resizing the vim/window",
    })
end

function Puzzle:start_timer()
    self.timer = (vim.uv or vim.loop).new_timer()
    self.timer:start(
        0,
        self._timer_presision,
        vim.schedule_wrap(function()
            self.time = self.time + self._timer_presision / 1000
            self:update_score()
        end)
    )
end

function Puzzle:stop_timer()
    if self.timer ~= nil then
        self.timer:stop()
        self.timer:close()
        self.timer = nil
    end
end

---@param key string
---@param fn function | string
local function map(key, fn)
    vim.keymap.set("n", key, fn, { buffer = true })
end

function Puzzle:set_keymaps()
    self:disable_keymaps()

    local keys = self.opts.keys
    map(keys.down, function()
        self:move_down()
        self:draw()
    end)
    map(keys.up, function()
        self:move_up()
        self:draw()
    end)
    map(keys.right, function()
        self:animate_right()
    end)
    map(keys.left, function()
        self:animate_left()
    end)
    map(keys.new_game, function()
        self:new_game()
        self:draw()
    end)
    map(keys.next_theme, function()
        Highlights.next_theme()
        self:draw()
    end)
    map(keys.prev_theme, function()
        Highlights.prev_theme()
        self:draw()
    end)
end

function Puzzle:disable_keymaps()
    for _, key in pairs(self.opts.keys) do
        map(key, "<nop>")
    end
end

function Puzzle:clear_buffer_text()
    local height = vim.api.nvim_win_get_height(self.winnr)
    local width = vim.api.nvim_win_get_width(self.winnr)
    local replacement = {}
    for _ = 1, height do
        table.insert(replacement, string.rep(" ", width))
    end
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, replacement)
end

function Puzzle:draw()
    self:update_score()

    vim.api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)
    local height = vim.api.nvim_win_get_height(self.winnr)
    for i = 0, height - 1 do
        vim.api.nvim_buf_add_highlight(self.bufnr, self.ns_id, "PuzzleBackground", i, 0, -1)
    end

    local current_row = self._vertical_padding
    local current_col = self._horizontal_padding

    local outer_padding = string.rep(" ", self._horizontal_padding)
    for i = 1, self.board_height do
        local line = outer_padding
        for j = 1, self.board_width do
            local val = tostring(self.board[i][j])
            if val == "0" then
                val = ""
            end
            local inner_padding_left, inner_padding_right
            if (self._square_width - #val) % 2 == 1 then
                inner_padding_left = string.rep(" ", (self._square_width - #val - 1) / 2)
                inner_padding_right = string.rep(" ", (self._square_width - #val + 1) / 2)
            else
                inner_padding_left = string.rep(" ", (self._square_width - #val) / 2)
                inner_padding_right = inner_padding_left
            end
            line = string.format(
                "%s%s%s%s%s",
                line,
                inner_padding_left,
                val,
                inner_padding_right,
                outer_padding
            )
        end

        vim.api.nvim_buf_set_lines(
            self.bufnr,
            current_row + math.floor(self._square_height / 2),
            current_row + math.floor(self._square_height / 2) + 1,
            false,
            {
                line,
            }
        )
        -- nvim_buf_set_lines removes highlihting from that line
        vim.api.nvim_buf_add_highlight(
            self.bufnr,
            self.ns_id,
            "PuzzleBackground",
            current_row + math.floor(self._square_height / 2),
            0,
            -1
        )

        for j = 1, self.board_width do
            self:draw_square(current_col, current_row, i, j)
            current_col = current_col + self._square_width + self._horizontal_padding
        end
        current_col = self._horizontal_padding
        current_row = current_row + self._square_height + self._vertical_padding
    end

    if self:game_over() then
        self:stop_timer()
        self:set_scoreboard_buffer_text(
            string.format(
                "You did it in %d moves! It took you %d seconds",
                self.number_of_moves,
                math.floor(self.time)
            )
        )
        self:disable_keymaps()
    end
end

---draw square on the board
---@param x integer x coordinates of the top-left corner of the square
---@param y integer y coordinates of the top-left corner of the square
---@param i integer idx in the board
---@param j integer idx in the board
function Puzzle:draw_square(x, y, i, j)
    local hl_grp
    local ok = self:is_in_the_right_place(i, j)
    if self.board[i][j] == 0 then
        hl_grp = "PuzzleEmpty"
    elseif ok then
        hl_grp = "PuzzleOk"
    else
        hl_grp = "PuzzleErr"
    end
    for k = 0, self._square_height - 1 do
        local txt =
            vim.api.nvim_buf_get_text(self.bufnr, y + k, x, y + k, x + self._square_width, {})
        vim.api.nvim_buf_set_text(self.bufnr, y + k, x, y + k, x + self._square_width, txt)
        vim.api.nvim_buf_add_highlight(
            self.bufnr,
            self.ns_id,
            hl_grp,
            y + k,
            x,
            x + self._square_width
        )
    end
end

function Puzzle:update_score()
    local moves_text = string.format(" Moves: %d", self.number_of_moves)
    local time_text = string.format("Time: %ds ", self.time)
    local width = vim.api.nvim_win_get_width(self.winnr)
    local sep = string.rep(" ", width - #moves_text - #time_text)
    vim.api.nvim_buf_set_lines(
        self.score_bufnr,
        0,
        1,
        false,
        { string.format("%s%s%s", moves_text, sep, time_text) }
    )
end

---center the notification text in the scoreboard buffer
---@param text string
function Puzzle:set_scoreboard_buffer_text(text)
    local width = vim.api.nvim_win_get_width(self.score_winnr)
    local half_sep = string.rep(" ", math.floor((width - #text) / 2))
    vim.api.nvim_buf_set_lines(
        self.score_bufnr,
        0,
        1,
        false,
        { string.format("%s%s%s", half_sep, text, half_sep) }
    )
    vim.api.nvim_buf_add_highlight(self.score_bufnr, self.ns_id, "2048_Confirmation", 0, 0, -1)
    vim.api.nvim_win_set_config(self.score_winnr, {
        title = "",
    })
end

---call after the set_scoreboard_buffer_text function to undo it
function Puzzle:reset_scoreboard_changes()
    vim.api.nvim_win_set_config(self.score_winnr, {
        title = " Score ",
        title_pos = "center",
    })
    self:update_score()
end

---@return boolean
function Puzzle:game_over()
    for i = 1, self.board_height do
        for j = 1, self.board_width do
            if self:is_in_the_right_place(i, j) == false then
                return false
            end
        end
    end
    return true
end

---@param i integer idx in the board
---@param j integer idx in the board
---@return boolean
function Puzzle:is_in_the_right_place(i, j)
    -- last value is not width x height, it's 0
    local mod = self.board_width * self.board_height
    return self.board[i][j] == ((i - 1) * self.board_height + j) % mod
end

---@param i integer idx in the board
---@param j integer idx in the board
---@return table<integer, integer>
function Puzzle:get_legal_moves(i, j)
    local moves = {}
    if i > 1 then
        table.insert(moves, { i - 1, j })
    end
    if i < self.board_height then
        table.insert(moves, { i + 1, j })
    end
    if j > 1 then
        table.insert(moves, { i, j - 1 })
    end
    if j < self.board_width then
        table.insert(moves, { i, j + 1 })
    end
    return moves
end

function Puzzle:move_down()
    if self.empty_i == 1 then
        return
    end
    self.board[self.empty_i][self.empty_j], self.board[self.empty_i - 1][self.empty_j] =
        self.board[self.empty_i - 1][self.empty_j], self.board[self.empty_i][self.empty_j]
    self.empty_i = self.empty_i - 1
    self.number_of_moves = self.number_of_moves + 1
end

function Puzzle:move_up()
    if self.empty_i == self.board_height then
        return
    end
    self.board[self.empty_i][self.empty_j], self.board[self.empty_i + 1][self.empty_j] =
        self.board[self.empty_i + 1][self.empty_j], self.board[self.empty_i][self.empty_j]
    self.empty_i = self.empty_i + 1
    self.number_of_moves = self.number_of_moves + 1
end

function Puzzle:move_left()
    if self.empty_j == self.board_width then
        return
    end
    self.board[self.empty_i][self.empty_j], self.board[self.empty_i][self.empty_j + 1] =
        self.board[self.empty_i][self.empty_j + 1], self.board[self.empty_i][self.empty_j]
    self.empty_j = self.empty_j + 1
    self.number_of_moves = self.number_of_moves + 1
end

function Puzzle:move_right()
    if self.empty_j == 1 then
        return
    end
    self.board[self.empty_i][self.empty_j], self.board[self.empty_i][self.empty_j - 1] =
        self.board[self.empty_i][self.empty_j - 1], self.board[self.empty_i][self.empty_j]
    self.empty_j = self.empty_j - 1
    self.number_of_moves = self.number_of_moves + 1
end

function Puzzle:new_game()
    self:stop_timer()
    self:generate_board()
    self.number_of_moves = 0
    self.time = 0
end

function Puzzle:animate_left()
    local timer = (vim.uv or vim.loop).new_timer()
    local steps = self._square_width + self._horizontal_padding
    local i, j = self.empty_i, self.empty_j + 1
    local x = (j - 1) * (self._square_width + self._horizontal_padding) + self._horizontal_padding
    local y = (i - 1) * (self._square_height + self._vertical_padding) + self._vertical_padding
    timer:start(
        0,
        self._left_right_animation_interval,
        vim.schedule_wrap(function()
            if steps == 0 then
                timer:stop()
                timer:close()
                self:move_left()
                self:draw()
                return
            end
            x = x - 1
            self:draw_square(x, y, i, j)

            steps = steps - 1
        end)
    )
end

function Puzzle:animate_right()
    local timer = (vim.uv or vim.loop).new_timer()
    local steps = self._square_width + self._horizontal_padding
    local i, j = self.empty_i, self.empty_j - 1
    local x = (j - 1) * (self._square_width + self._horizontal_padding) + self._horizontal_padding
    local y = (i - 1) * (self._square_height + self._vertical_padding) + self._vertical_padding
    timer:start(
        0,
        self._left_right_animation_interval,
        vim.schedule_wrap(function()
            if steps == 0 then
                timer:stop()
                timer:close()
                self:move_right()
                self:draw()
                return
            end

            x = x + 1
            self:draw_square(x, y, i, j)
            steps = steps - 1
        end)
    )
end

return Puzzle
