---@diagnostic disable: undefined-field, undefined-global
local Solver = require("15puzzle.solver")
local board = {
    { 2, 7, 8, 1 },
    { 4, 3, 10, 12 },
    { 5, 0, 14, 9 },
    { 13, 6, 15, 11 },
}
local board_serialized = vim.json.encode(board)
local solver = Solver.new(board)
local eq = assert.are.same

describe("Solver test", function()
    before_each(function() end)
    it("width, height", function()
        eq(4, solver.board_height)
        eq(4, solver.board_width)
    end)
    it("destination square", function()
        local i, j = solver:_get_destination_square(6)
        eq(i, 2)
        eq(j, 2)

        i, j = solver:_get_destination_square(4)
        eq(i, 1)
        eq(j, 4)

        i, j = solver:_get_destination_square(0)
        eq(i, solver.board_height)
        eq(j, solver.board_width)

        i, j = solver:_get_destination_square(15)
        eq(i, 4)
        eq(j, 3)
    end)
    it("total manhattan", function()
        eq(30, solver:_total_manhattan(board_serialized))
    end)
    it("get neighbours", function()
        local neighbours = solver:_get_neighbours(board_serialized)
        eq(
            vim.json.encode({
                { 2, 7, 8, 1 },
                { 4, 0, 10, 12 },
                { 5, 3, 14, 9 },
                { 13, 6, 15, 11 },
            }),
            neighbours[1]
        )
        eq(
            vim.json.encode({
                { 2, 7, 8, 1 },
                { 4, 3, 10, 12 },
                { 5, 6, 14, 9 },
                { 13, 0, 15, 11 },
            }),
            neighbours[2]
        )
        eq(
            vim.json.encode({
                { 2, 7, 8, 1 },
                { 4, 3, 10, 12 },
                { 0, 5, 14, 9 },
                { 13, 6, 15, 11 },
            }),
            neighbours[3]
        )
        eq(
            vim.json.encode({
                { 2, 7, 8, 1 },
                { 4, 3, 10, 12 },
                { 5, 14, 0, 9 },
                { 13, 6, 15, 11 },
            }),
            neighbours[4]
        )
    end)
    it("find empty", function()
        local i, j = solver:_find_empty(board)
        eq(3, i)
        eq(2, j)
    end)
end)
