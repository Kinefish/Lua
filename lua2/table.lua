--自定义索引.no number be index
local tb = {
    ["xxx"] = 10,
    1,
    3,
    5,
    ["bbb"] = function()
        print("this func index is bbb")
    end
}

print(tb["bbb"]())

--table中的ipairs遍历
--只能找到连续索引的key，从key == 1 开始，自定义index也需要连续才能遍历出
local tb2 = {
    [0] = 1,
    2,          --k == 1
    [-1] = 3,
    4,          --k == 2
    5,          --k == 3
    [4] = 6   
}

for k, v in ipairs(tb2) do
    print(k.."-"..v)
end

--table中的pairs遍历
--先遍历无定义v，自定义int遍历过的不会再遍历，
--除非自定义index不冲突
local tb3 = {
    [0] = 1,
    2,     
    "adjak",     
    [7] = 3,
    4,    
    5,          
    [6] = 6,    --不会遍历
    "xxxx",
}
for k, v in pairs(tb3) do
    print("paris--"..k.."-"..v)
end

-------------tb4作为k，v与自定义索引的k，v 对比------------------------------------------------
--不能作为索引
local tb4 = {
    m_age = 1,
    m_name = "x",
}

print(tb4[1])   --nil
print(tb4[2])   --nil

--paris遍历同样可以
for k, v in pairs(tb4) do
    print("tb4 " .. k .. " - " .. v)
end