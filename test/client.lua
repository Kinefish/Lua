return {
    CmdMap = {
        ["CS_LOGIC_CMD_MATERIAL_CHALLENGE_REFRESH"] = "cmd_refresh"
    },

    _init = function(self)
        return self:_pre_run()
    end,

    _reload = function(self)
        return self:_pre_run()
    end,

    _pre_run = function(self)
        print("call --> self:_bind_event()")
    end,

    is_sys_open = function(self,userdata)
        return true
    end,

    cmd_refresh = function(self, args, seq, userdata)
        if not self:is_sys_open(userdata) then
            return "ERRNO_MATERIAL_CHALLENGE_SYS_NOT_OPEN"
        end
    end,
}
