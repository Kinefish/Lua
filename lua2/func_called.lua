-- 什么情况下通过self调用函数
local function table_merge(src_tab, dest_tabl)
    if (type(src_tab) ~= "table") or (type(dest_tabl) ~= 'table' and dest_tabl) then
        return dest_tabl
    end
    dest_tabl = dest_tabl or {}
    for i, v in pairs(src_tab) do
        local vtyp = type(v);
        if (vtyp == "table") then
            dest_tabl[i] = table_merge(v, dest_tabl[i]);
        elseif dest_tabl[i] == nil then
            if (vtyp == "thread") then
                -- TODO: dup or just point to?
                dest_tabl[i] = v;
            elseif (vtyp == "userdata") then
                -- TODO: dup or just point to?
                dest_tabl[i] = v;
            else
                dest_tabl[i] = v;
            end
        end
    end
    return dest_tabl
end

local Student = {
    [0] = 0,
    [1] = 1,
    ["string 2"] = 2,

    m_age = 10,
    m_name = "xxx",
    op = {},

    jump = function(self)
        print("jump func called")
        print("called by self m_age " .. self.m_age)
    end,

    yiel = function(self)
        name = self:getname()                               --如果使用self调用该函数，默认这些是在一个表中,也就是说，要进行merge操作
        print("yielingggggggggggggggggggg " .. name)
    end
}

local mt = {
    setname = function(self, name)
        self.m_name = name
    end,

    getname = function(self)
        print(self.m_name)
        return self.m_name
    end
}

setmetatable(Student,mt)

local s1 = Student
-- 通过 s1.op = mt 的方法调用 mt 表中的方法
--[[s1.op = mt
s1.op:setname("jack")
s1.op:getname()
]]

-- 通过 table.insert的方法
--s1 = table_merge(mt, s1)
--s1:setname("kniefish")
--s1:getname()

s1:yiel()