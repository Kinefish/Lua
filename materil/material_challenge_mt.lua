--[[
  material_challenge_data = {
    -- 当前挑战状态信息
    play = {
      time = xxx，-- 开始挑战的时间
      pos = xxx,  -- 挑战的第几个斗者副本
      reward = {  -- 奖励
        {
          id = xxx,
          num =xxx,
        },
        ...
      },
    },
    -- 当前斗者副本列表
    list = {  
      [pos] = {
        challenge_id = xxx, -- 斗者副本id
        map_id = xxx,       -- 地图id
        reward_level = xxx, -- 奖励加成梯度
        is_played = xxx,    -- 标记已挑战成功
      }
    },
    -- 已翻牌次数
    refresh_times = xxx,  
    -- 已挑战次数
    challenge_times = xxx,
    -- 本周翻牌次数
    week_refresh_times = xxx,
    -- 已领取翻牌奖励idx
    picked_idx = xxx,
    -- 已领取的奖励加成
    additions = {
        xxx, -- 加成id
    }
  }
--]]

local add_index = 1

local play_mt = {
    get_play_pos = function(self)
        local play = self:get_play()
        return play.pos
    end,
    get_play_reward = function(self)
        local play = self:get_play()
        return play.reward
    end,
    get_play_time = function(self)
        local play = self:get_play()
        return play.time
    end,
}

local challenge_mt = {
    get_challenge = function(self, pos)
        local list = self:get_list()
        return list[pos]
    end,
    set_challenge = function(self, pos, challenge)
        local list = self:get_list()
        list[pos] = challenge
    end,
    is_challenge_opened = function(self, pos)
        local challenge = self:get_challenge(pos)
        return challenge ~= nil
    end,

    get_challenge_id = function(self, pos)
        local challenge = self:get_challenge(pos)
        return challenge.challenge_id
    end,

    get_reward_level = function(self, pos)
        local challenge = self:get_challenge(pos)
        return challenge.reward_level
    end,

    is_challenge_played = function(self, pos)
        local challenge = self:get_challenge(pos)
        return challenge.is_played == true
    end,
    set_challenge_played = function(self, pos, flag)
        local challenge = self:get_challenge(pos)
        challenge.is_played = flag
    end,

}

local mt = {
    get_play = function(self)
        return self.play
    end,
    set_paly = function(self, play)
        self.play = play
    end,

    get_list = function(self)
        return self.list
    end,
    reset_list = function(self)
        self.list = {}
    end,

    get_refresh_times = function(self)
        return self.refresh_times
    end,
    set_refresh_times = function(self, times)
        self.refresh_times = times
    end,

    get_challenge_times = function(self)
        return self.challenge_times
    end,
    set_challenge_times = function(self, times)
        self.challenge_times = times
    end,

    get_week_refresh_times = function(self)
        return self.week_refresh_times or 0
    end,
    
    set_week_refresh_times = function(self, times)
        self.week_refresh_times = times
    end,

    add_week_refresh_times = function(self)
        self.week_refresh_times = (self.week_refresh_times or 0) + 1
    end,

    get_picked_idx = function(self)
        return self.picked_idx or 0
    end,
    
    set_picked_idx = function(self, idx)
        self.picked_idx = idx
    end,

    get_addition_id = function(self)
        return self.additions and self.additions[add_index]
    end,

    add_additions = function(self, additions)
        self.additions = self.additions or {}
        utils.table_append(self.additions, additions)
    end,

    remove_addition = function(self)
        table.remove(self.additions or {}, add_index)
    end,

    set_additions = function(self, additions)
        self.additions = additions
    end,
}

local other_mt = {
    -- @brief: 角色初始化
  	init = function(self)
  	end,
  	-- @brief: 每日更新
    clear_data_by_day = function(self, days, now)
        -- 重置副本
        self:reset_list()
        -- 重置已翻牌次数和已挑战次数
        self:set_refresh_times(0)
        self:set_challenge_times(0)
    end,
  	-- @brief: 每周更新
    clear_data_by_week = function(self)
        gService.material_challenge_client:resend_unpick_refresh_reward(global:root(self))
        self:set_week_refresh_times(0)
        self:set_picked_idx(0)
        self:set_additions()
    end,
}

utils.table_merge(play_mt, mt)
utils.table_merge(challenge_mt, mt)
utils.table_merge(other_mt, mt)
return {
    __index = mt
}