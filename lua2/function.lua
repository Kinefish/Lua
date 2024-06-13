--将函数定义为数据类型
local func = function()
    print(
        "this is a function called by func arg"
    )
end

func()


--定义不固定参数函数
local func2 = function(...)
    --需要将无固定参数转换为table
    local args = {...}
    local ret = 0
    for i = 1, #args, 1 do
        ret = ret + args[i]
    end
    return ret
end

print(func2(1, 2, 3)) 
print(func2(1, 2, 3, 4))

--多返回值函数
local func3 = function()
    return 1,2
end

local n1,n2 = func3()   --两个参数接收
print(n1,n2)

--闭包
local func4 = function(x)
    return function(y)
        return x + y
    end
end

local func5 = func4(10)
print(func5(5))