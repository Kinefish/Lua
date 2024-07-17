local basic_cfg = {
    _load_reward_cfg = function(self)
        local cfgs = self:get_challenge_cfgs()
        if not cfgs then
            return
        end

        local reward_level_total_weight = {--[[
            [challenge_id] = xxx,  副本id对应的奖励等级总权重
        ]]}
        for _, entry in pairs(cfgs) do
            local total_weight = 0
            for _, item in pairs(entry.reward) do
                total_weight = total_weight + item.weight
            end
            reward_level_total_weight[entry.ID] = total_weight
        end

        self._reward_level_total_weight = reward_level_total_weight
    end,

    get_challenge_cfg = function(self, id)
        local cfg = gService.resource:get_entry_can_nil("ResNewMysteryList", "list", id)
        if not cfg then
            NodeLogErrorEx("[get_challenge_cfg]: ResNewMysteryList cfg is nil, id = %%", id)
            return 
        end
        return cfg
    end,
    get_challenge_cfgs = function(self)
        local cfgs = gService.resource:get_sheet("ResNewMysteryList", "list")
        if not cfgs then
            NodeLogErrorEx("[get_challenge_cfgs]: ResNewMysteryList cfg is nil")
            return 
        end
        return cfgs
    end,

    get_reward_cfg = function(self, id)
        local cfg = gService.resource:get_entry_can_nil("ResNewMysteryRewardList", "list", id)
        if not cfg then
            NodeLogErrorEx("[get_reward_cfg]: ResNewMysteryRewardList cfg is nil, id = %%", id)
            return 
        end
        return cfg
    end,
    get_reward_cfgs = function(self)
        local cfgs = gService.resource:get_sheet("ResNewMysteryRewardList", "list")
        if not cfgs then
            NodeLogErrorEx("[get_reward_cfgs]: ResNewMysteryRewardList cfg is nil")
            return 
        end
        return cfgs
    end,

    get_refresh_cost_cfg = function(self, id)
        local cfg = gService.resource:get_entry_can_nil("ResNewMysteryCostList", "list", id)
        if not cfg then
            NodeLogErrorEx("[get_refresh_cost_cfg]: ResNewMysteryCostList cfg is nil, id = %%", id)
            return 
        end
        return cfg
    end,
    get_refresh_cost_cfgs = function(self)
        local cfgs = gService.resource:get_sheet("ResNewMysteryCostList", "list")
        if not cfgs then
            NodeLogErrorEx("[get_refresh_cost_cfgs]: ResNewMysteryCostList cfg is nil")
            return 
        end
        return cfgs
    end,

    get_times_reward_cfg = function(self, id)
        local cfg = gService.resource:get_entry_can_nil("ResNewMysteryFPList", "list", id)
        if not cfg then
            NodeLogErrorEx("[get_times_reward_cfg]: ResNewMysteryFPList cfg is nil, id = %%", id)
            return 
        end
        return cfg
    end,
    get_times_reward_cfgs = function(self)
        local cfgs = gService.resource:get_sheet("ResNewMysteryFPList", "list")
        if not cfgs then
            NodeLogErrorEx("[get_times_reward_cfgs]: ResNewMysteryFPList cfg is nil")
            return 
        end
        return cfgs
    end,
}

local cfgs = {
    _init = function(self, cfg)
        return self:_pre_run()
    end,
    _reload = function(self, cfg)
        return self:_pre_run()
    end,
    _pre_run = function(self)
        self.reward_type = {
            item = 0,
            addition = 1,
            challenge = 2,
        }
        self.challenge_type = {
            original = 0,
            reward = 1,
        }
        self:_load_reward_cfg()
    end,

    -- @brief: 界面副本总数
    get_challenge_fix_num = function(self)
        return 5
    end,
    -- @brief: 每日可挑战次数
    get_challenge_limit_times = function(self)
        return gService.constant:get_value(2008400)
    end,
    -- @brief: 可免费刷新次数
    get_free_refresh_limit_times = function(self)
        return gService.constant:get_value(2008401)
    end,
    -- @brief: 第n次刷新消耗的物品
    get_refresh_cost_by_times = function(self, refresh_times)
        local free_refresh_limit_times = self:get_free_refresh_limit_times() -- 可免费刷新次数
        if refresh_times <= free_refresh_limit_times then
            return {}
        end

        local cost_refresh_times = refresh_times - free_refresh_limit_times
        for _, entry in pairs(self:get_refresh_cost_cfgs()) do
            if cost_refresh_times >= entry.min and cost_refresh_times <= entry.max then
                return entry.costs
            end
        end
        NodeLogWarnning("[get_refresh_cost_by_times]: refresh cost none. cost_refresh_times = %%", cost_refresh_times)
    end,
    -- @brief: 已解锁的奖励试炼
    get_unlock_challenges = function(self, picked_idx)
        local challenges = {}
        for idx = 1, picked_idx do
            local cfg = self:get_times_reward_cfg(idx)
            local reward_type = cfg.rewardType or 0
            local reward_id = tonumber(cfg.params[1]) or 0
            local reward_num = tonumber(cfg.params[2])

            if reward_type == self.reward_type.challenge then   -- 奖励试炼
                challenges[reward_id] = reward_num
            end
        end
        return challenges
    end,
    -- @brief: 可领取的刷新次数奖励
    get_refresh_times_reward = function(self, picked_idx, week_refresh_times)
        local rewards = {}
        local additions = {}
        local new_picked_idx = picked_idx
        for idx = picked_idx+1, #(self:get_times_reward_cfgs()) do
            local cfg = self:get_times_reward_cfg(idx)
            if week_refresh_times < cfg.needTimes then
                break
            end

            -- 满足所需翻牌次数
            new_picked_idx = idx
            local reward_type = cfg.rewardType or 0
            local reward_id = tonumber(cfg.params[1])
            local reward_num = tonumber(cfg.params[2])

            if reward_type == self.reward_type.item then   -- 奖励道具
                table.insert(rewards, {id = reward_id, num = reward_num})
            elseif reward_type == self.reward_type.addition then   -- 试炼奖励加成
                for n=1, reward_num do
                    table.insert(additions, reward_id)
                end
            end
        end
        return new_picked_idx, rewards, additions
    end,

    -- @brief: 随出num个副本 (可重复)
    random_challenges = function(self, num, played_times_map, picked_idx, addition_id)
        -- 针对挑战过的副本，修正权重
        local challenge_total_weight = 0
        local challenge_weight_list = {--[[
            [challenge_id] = weight,
            ...
        ]]}

        -- 修正权重，并将挑战加入随机列表
        local add_weight_func = function(challenge_id, entry, cha_type)
            entry = entry or self:get_challenge_cfg(challenge_id)
            if (entry.ifOpen or 0) ~= cha_type then
                return
            end

            local played_times = played_times_map[challenge_id] or 0 -- 已挑战次数
            local fix_weight = entry.weight + (entry.addWeightEveryTimes * played_times)
            challenge_weight_list[challenge_id] = fix_weight
            challenge_total_weight = challenge_total_weight + fix_weight
        end

        for challenge_id, entry in pairs(self:get_challenge_cfgs()) do
            add_weight_func(challenge_id, entry, self.challenge_type.original)
        end

        -- 随出所有副本
        local challenge_list = {--[[
            {
                challenge_id = xxx,
                map_id = xxx,
                reward_level = xxx,
            },
            ...
        ]]}

        -- 先随出必得加成的副本
        local must_idx = 0
        local must_challenge_id
        if addition_id then
            must_idx = g_random.uniform_r(num)
            must_challenge_id = self:_random_challenge(challenge_total_weight, challenge_weight_list)
        end


        -- 奖励解锁副本
        local unlock_challenge = self:get_unlock_challenges(picked_idx)
        for challenge_id in pairs(unlock_challenge) do
            add_weight_func(challenge_id, nil, self.challenge_type.reward)
        end


        for i=1, num do
            local challenge_id, reward_level
            if i == must_idx then
                challenge_id = must_challenge_id
                reward_level = addition_id
            else
                -- 随机挑战
                challenge_id = self:_random_challenge(challenge_total_weight, challenge_weight_list)
                -- 随机奖励加成梯度
                reward_level = self:_random_reward_level(challenge_id)
            end
            -- 随机地图
            local map_id = self:_random_map(challenge_id)
            
            table.insert(challenge_list, {
                challenge_id = challenge_id, 
                map_id = map_id,
                reward_level = reward_level,
            })
            NodeLogDebug("[random_challenges]: num = %%, [challenge_total_weight = %%], [challenge_id = %%, map_id = %%, reward_level = %%]", num, challenge_total_weight, challenge_id, map_id, reward_level)
        end
        return challenge_list
    end,
    -- @brief: 随机挑战
    _random_challenge = function(self, challenge_total_weight, challenge_weight_list)
        local random_value = g_random.uniform_r(challenge_total_weight)
        for challenge_id, weight in pairs(challenge_weight_list) do
            if random_value <= weight then
                return challenge_id
            end
            random_value = random_value - weight
        end
    end,
    -- @brief: 随机地图
    _random_map = function(self, challenge_id)
        local map_list = self:get_challenge_cfg(challenge_id).map
        local random_value = g_random.uniform_r(#map_list)
        return map_list[random_value]
    end,
    -- @brief:  随机奖励加成梯度
    -- @return: 奖励配置的索引
    _random_reward_level = function(self, challenge_id)
        local random_value = g_random.uniform_r(self._reward_level_total_weight[challenge_id])
        for index, item in ipairs(self:get_challenge_cfg(challenge_id).reward) do
            if random_value <= item.weight then
                return index
            end
            random_value = random_value - item.weight
        end
    end
}

utils.table_merge(basic_cfg, cfgs)
return cfgs
