t = {a = 19}

mt = {
    __add = function(table,key)
        return table.a + key
    end,
    __index = {
        abc = 123,
    }
}

setmetatable(t,mt)

print(t + 1)
print(t["abc"])