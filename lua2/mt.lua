local t = {a = 19}
local mt_local_tmp = "xxxx"
mt_gobal_tmp = 20
mt = {
    __add = function(table,key)     --add op
        return table.a + key
    end,
    __index = {                     --be index  当表没有该index时，就去元表找，当该元表也没有该index时，就去该元表的元表去找...
        abc = 123,
    },
    __newindex = {                  --赋值一个table中没有的index时，优先去meta中的__newindex赋值,若要忽略需要用rawset()

    },
    __tostring = function(t)         --print table
        return t.a
    end,
    __call = function()             --be function  frist arg default self
        print("now table called by function")
    end
}

setmetatable(t,mt)

print(t + 1)
print(t["abc"])
print(t)
t()
t.b = 19
print(mt.__newindex.b)