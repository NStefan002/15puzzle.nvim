local Util = require("15puzzle.util")

---@class PuzzleSolver
---@field board integer[][]
---@field board_height integer
---@field board_width integer
---@field solution string[]
local Solver = {}
Solver.__index = Solver

---@param board integer[][]
function Solver.new(board)
    local self = setmetatable({
        board = board,
        board_height = #board,
        board_width = #board[1],
        solution = {},
    }, Solver)
    return self
end

---@param time_limit number in miliseconds
function Solver:solve(time_limit)
    local start = vim.json.encode(self.board)
    local solved_board = {}
    for i = 1, self.board_height do
        local tmp = {}
        for j = 1, self.board_width do
            table.insert(tmp, (i - 1) * self.board_height + j)
        end
        table.insert(solved_board, tmp)
    end
    solved_board[self.board_height][self.board_width] = 0

    local finish = vim.json.encode(solved_board)
    local open, closed = { start }, {}

    local parent = {}
    local cheapest_path = {}
    ---@diagnostic disable-next-line: need-check-nil
    cheapest_path[start] = 0

    ---@return string
    local function get_best_move()
        local result, result_value = nil, math.huge
        for _, node in ipairs(open) do
            local new_value = (cheapest_path[node] or math.huge) + self:_total_manhattan(node)
            if not result or new_value < result_value then
                result, result_value = node, new_value
            end
        end
        return result
    end

    local t_start = os.clock()
    local path_found = false
    while #open > 0 do
        local current = get_best_move()
        if current == finish then
            path_found = true
            break
        end

        -- took too long to find solution
        local t_curr = os.clock()
        if t_curr - t_start > time_limit / 1000 then
            break
        end

        local neighbours = self:_get_neighbours(current)
        for _, neighbour in ipairs(neighbours) do
            local path_to_neighbour_weight = (cheapest_path[current] or math.huge) + 1 -- 1 is the weight of the edge between every two neighbours in the graph
            if
                not vim.tbl_contains(open, neighbour) and not vim.tbl_contains(closed, neighbour)
            then
                table.insert(open, neighbour)
                parent[neighbour] = current
                cheapest_path[neighbour] = path_to_neighbour_weight
            elseif path_to_neighbour_weight < (cheapest_path[neighbour] or math.huge) then
                parent[neighbour] = current
                cheapest_path[neighbour] = path_to_neighbour_weight
                if vim.tbl_contains(closed, neighbour) then
                    Util.remove_element(closed, neighbour)
                    table.insert(open, neighbour)
                end
            end
        end
        Util.remove_element(open, current)
        if not vim.tbl_contains(closed, current) then
            table.insert(closed, current)
        end
    end

    if not path_found then
        self.solution = {}
        return
    end
    local path = {}
    while finish do
        table.insert(path, finish)
        finish = parent[finish]
    end
    self.solution = Util.reverse_list(path)
end

---@return string[]
function Solver:get_moves()
    local moves = {}
    for i = 1, #self.solution - 1 do
        local current_board = vim.json.decode(self.solution[i])
        local next_board = vim.json.decode(self.solution[i + 1])
        ---@diagnostic disable-next-line: param-type-mismatch
        local current_i, current_j = self:_find_empty(current_board)
        ---@diagnostic disable-next-line: param-type-mismatch
        local next_i, next_j = self:_find_empty(next_board)
        if current_i < next_i then
            table.insert(moves, "up")
        elseif current_i > next_i then
            table.insert(moves, "down")
        elseif current_j < next_j then
            table.insert(moves, "left")
        elseif current_j > next_j then
            table.insert(moves, "right")
        end
    end
    return moves
end

---@param board integer[][]
---@return integer i
---@return integer j
function Solver:_find_empty(board)
    local result_i, result_j = -1, -1
    for i = 1, self.board_height do
        for j = 1, self.board_width do
            if board[i][j] == 0 then
                result_i, result_j = i, j
                break
            end
        end
    end
    return result_i, result_j
end

---find possible moves for empty square
---@param current_node string
---@return string[]
function Solver:_get_neighbours(current_node)
    ---@type integer[][]
    ---@diagnostic disable-next-line: assign-type-mismatch
    local current_board = vim.json.decode(current_node)
    local i, j = self:_find_empty(current_board)
    local neighbours = {}

    if i > 1 then
        local new_board = vim.deepcopy(current_board)
        new_board[i][j], new_board[i - 1][j] = new_board[i - 1][j], new_board[i][j]
        table.insert(neighbours, vim.json.encode(new_board))
    end
    if i < self.board_height then
        local new_board = vim.deepcopy(current_board)
        new_board[i][j], new_board[i + 1][j] = new_board[i + 1][j], new_board[i][j]
        table.insert(neighbours, vim.json.encode(new_board))
    end
    if j > 1 then
        local new_board = vim.deepcopy(current_board)
        new_board[i][j], new_board[i][j - 1] = new_board[i][j - 1], new_board[i][j]
        table.insert(neighbours, vim.json.encode(new_board))
    end
    if j < self.board_width then
        local new_board = vim.deepcopy(current_board)
        new_board[i][j], new_board[i][j + 1] = new_board[i][j + 1], new_board[i][j]
        table.insert(neighbours, vim.json.encode(new_board))
    end

    return neighbours
end

---total sum of manhattan distances of each square of the current node
---@param current_node string
---@return integer
function Solver:_total_manhattan(current_node)
    ---@type integer[][]
    ---@diagnostic disable-next-line: assign-type-mismatch
    local current_board = vim.json.decode(current_node)
    local sum = 0
    for i = 1, self.board_height do
        for j = 1, self.board_width do
            local end_i, end_j = self:_get_destination_square(current_board[i][j])
            sum = sum + math.abs(i - end_i) + math.abs(j - end_j)
        end
    end
    return sum
end

---@param val integer value inside of the square
---@return integer end_i index of the square that val belongs to
---@return integer end_j of the square that val belongs to
function Solver:_get_destination_square(val)
    if val == 0 then
        return self.board_height, self.board_width
    end

    local end_i = math.floor((val - 1) / self.board_height) + 1
    local end_j = val - (end_i - 1) * self.board_height

    return end_i, end_j
end

return Solver
