local Util = {}

---@param tbl table
---@param el any
---@param eq? fun(a: any, b: any) : boolean returns true if elements are the same
---@return integer idx index of the element `el` or 0 if `tbl` does not contain `el`
function Util.find_element(tbl, el, eq)
    eq = eq or function(a, b)
        return a == b
    end
    for idx, val in ipairs(tbl) do
        if eq(val, el) then
            return idx
        end
    end
    return 0
end

---@param tbl table
---@param el any
---@param eq? fun(a: any, b: any) : boolean returns true if elements are the same
---@return boolean
function Util.tbl_contains(tbl, el, eq)
    eq = eq or function(a, b)
        return a == b
    end
    return Util.find_element(tbl, el, eq) > 0
end

---@param tbl table
---@param el any
---@param eq? fun(a: any, b: any) : boolean returns true if elements are the same
function Util.remove_element(tbl, el, eq)
    eq = eq or function(a, b)
        return a == b
    end
    local idx = Util.find_element(tbl, el, eq)
    if idx > 0 then
        table.remove(tbl, idx)
    end
end

---@param list table
---@return table
function Util.reverse_list(list)
    local reversed = {}
    for i = #list, 1, -1 do
        table.insert(reversed, list[i])
    end

    return reversed
end

return Util
