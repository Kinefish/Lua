tb = {
    {
        ID = {
            line = 1001,
        }
    },
    {
        ID = {
            line = 1002,
        }   
    },
    {
        ID = {
            line = 1003,
        }   
    },
}

group_by = function(tb, key)
    local rst = {}
    for _, value in pairs(tb) do
        local k = key(value)
        print(k)
        if k then
            rst[k] = rst[k] or {}
            print(rst[k])
            local group = rst[k]
            group[#group + 1] = value
        end
    end
    return rst
end

local group_map = group_by(tb,function(cfg)
    return cfg.ID.line
end)
