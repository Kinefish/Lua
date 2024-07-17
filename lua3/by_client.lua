return{
    cmd = {
        ['cs_cmd_1'] = 'cmd_1',
        ['cs_cmd_2'] = 'cmd_2',
    },

    _init = function(self)
        self:_pre_run()
    end,
    
    _reload = function(self)
        self:_pre_run()
    end,

    _pre_run = function(self)
        print("this is _pre_run_function()")
    end,

    cmd_1 = function(self, args, seq, userdata)
        return "cmd_1_function_return_now"
    end,

    cmd_2 = function(self, args, seq, userdata)
        return "cmd_2_return_now"
    end,
}