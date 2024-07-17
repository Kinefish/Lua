-- mt表中处理get、set之类的逻辑
--[[

    material_challenge_data = {
        play = {
        },
        list = {
        },
        refresh_times = 
        challenge_times = 
        week_refresh_times = 
        pick_idx = 
        additions = {
        
        }
    }

    当确定material_challenge_data有这些属性的时候，
    那么就在mt表中设置getter、setter对应的function
--]] 
require("util.table")

local mt = {
    -- play
    set_play = function(self, play)
        self.play = play
    end,
    get_play = function(self)
        return self.play
    end,

    -- list，每次翻出的新牌放入重置的list中
    reset_list = function(self)
        self.list = {}
    end,
    get_list = function(self)
        return self.list
    end,

    -- refresh_times
    set_refresh_times = function(self, times)
        self.refresh_times = times
    end,
    get_refresh_times = function(self)
        return self.refresh_times
    end,

    -- week_refresh_times
    set_week_refresh_times = function(self, times)
        self.week_refresh_times = times
    end,
    get_week_refresh_times = function(self)
        return self.week_refresh_times
    end,

    -- challenge_times
    set_challenge_times = function(self, times)
        self.challenge_times = times
    end,
    get_challenge_times = function(self)
        return self.challenge_times
    end,

    -- pick_idx
    set_pick_idx = function(self, idx)
        self.pick_idx = idx
    end,
    get_pick_idx = function(self)
        return self.pick_idx
    end,

    -- addition
    set_addition = function(self, addition)
        self.addition = addition
    end,
    get_addition = function(self)
        return self.addition
    end,
    add_addition = function(self, addition_id)
        table.insert(self.addition, addition_id)
    end,
    remove_addition = function(self, add_inx)
        table.remove(self.addtion or {}, add_inx)
    end

}

return {
    __index = mt
}
