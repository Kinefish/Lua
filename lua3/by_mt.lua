-- xx_mt.lua文件作为元表使用
return {
    __index = {
        func_1 = function(self)
            print("func_1 called")
        end,

        func_2 = function(self, id, times)
            return "func_2 return now"
        end,

        cmd_1 = function(self)
            return "cmd_1 return now"
        end,

        cmd_2 = function(self,id)
            return "cmd_2 return now"
        end
    }
}
