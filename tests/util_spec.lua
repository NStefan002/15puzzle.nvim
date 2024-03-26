---@diagnostic disable: undefined-field, undefined-global
local Util = require("15puzzle.util")
local eq = assert.are.same

describe("Util test", function()
    before_each(function() end)
    it("find", function()
        local tbl = { 1, 2, 3, 4 }
        eq(2, Util.find_element(tbl, 2))
        eq(0, Util.find_element(tbl, 5))
    end)
    it("remove", function()
        local tbl = { "a", "b", "c", "d" }
        Util.remove_element(tbl, "c")
        eq({ "a", "b", "d" }, tbl)
        Util.remove_element(tbl, "c")
        eq({ "a", "b", "d" }, tbl)

        tbl = { "a" }
        Util.remove_element(tbl, "a")
        eq(0, #tbl)
    end)
    it("reverse", function()
        local list = { 1, 2, 3, 4 }
        local rev_list = Util.reverse_list(list)
        eq({ 4, 3, 2, 1 }, rev_list)
    end)
end)
