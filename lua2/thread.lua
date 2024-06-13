
local co = coroutine.wrap(
    function()
        print("xxxx")
        local n1,n2,n3 = coroutine.yield(1,2,3)
        print("aaaa")
        print(n1,n2,n3)
    end
)
print(co())
co(4,5,6)
