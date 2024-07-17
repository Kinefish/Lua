-- 什么情况下通过self调用函数
local table_merge = function(src_tab, dest_tabl)
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

return table_merge
