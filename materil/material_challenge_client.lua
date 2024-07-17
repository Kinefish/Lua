local cmd_func = {
    -- @brief: 刷新副本
    cmd_refresh = function(self, args, seq, userdata) 
        -- 检查本系统是否开放
        if not self:is_sys_opened(userdata) then
            return 'ERRNO_MATERIAL_CHALLENGE_SYS_NOT_OPEN'
        end
        -- 检查是否可刷新 (全部挑战过后不可刷新)
        local fix_num = self.op:get_challenge_fix_num()  -- 界面副本总数
        local played_num = 0
        local material_challenge_data = userdata:material_challenge_data()
        for _pos, _ in pairs(material_challenge_data:get_list()) do
            -- 挑战成功的副本不刷新
            if material_challenge_data:is_challenge_played(_pos) then
                played_num = played_num + 1
            end
        end
        if played_num >= fix_num then
            return 'ERRNO_MATERIAL_CHALLENGE_ALL_PALYED'
        end

        -- 刷新消耗物品 (超过免费刷新次数，需要消耗物品)
        local refresh_times = material_challenge_data:get_refresh_times() -- 已刷新次数
        local cost_items = self.op:get_refresh_cost_by_times(refresh_times + 1)
        if not cost_items then
            return "ERRNO_MATERIAL_CHALLENGE_TIMES_LIMIT"
        end

        if next(cost_items) then
            local rst = gService.bag_op:del_items(userdata, cost_items, g_enum.bag.item_source.material_challenge_refresh)
            if "COMMON_SUCCESS" ~= rst then
                return rst
            end
        end
        -- 累计刷新次数
        material_challenge_data:set_refresh_times(refresh_times + 1)
        material_challenge_data:add_week_refresh_times()
        -- 随机出副本
        local refresh_num = fix_num - played_num  -- 需要刷新的副本数量 (已挑战过的不刷新)
        local played_times_map = {}               -- 已经挑战成功副本对应的数量
        for _pos, _ in pairs(material_challenge_data:get_list()) do
            if material_challenge_data:is_challenge_played(_pos) then
                local challenge_id = material_challenge_data:get_challenge_id(_pos)
                played_times_map[challenge_id] = (played_times_map[challenge_id] or 0) + 1
            end
        end
        local picked_idx = material_challenge_data:get_picked_idx()
        local addition_id = material_challenge_data:get_addition_id()
        local random_challenges = self.op:random_challenges(refresh_num, played_times_map, picked_idx, addition_id)
        -- 移除已触发的加成
        material_challenge_data:remove_addition()
        -- 更新副本 (将随机出的结果替换"未挑战过的副本")
        local index = 1
        for _pos=1, fix_num do
            if not (material_challenge_data:is_challenge_opened(_pos) and material_challenge_data:is_challenge_played(_pos)) then
                local item = random_challenges[index]
                local challenge = {
                    challenge_id = item.challenge_id,
                    map_id = item.map_id,
                    reward_level = item.reward_level,
                    is_played = false,
                }
                material_challenge_data:set_challenge(_pos, challenge)
                index = index + 1
                NodeLogDebug("[cmd_refresh]: refresh_pos = %%, index = %%, new_challenge_id = %%", _pos, index, challenge.challenge_id)
            end
        end
        NodeLogDebug("[cmd_refresh]: refresh_num = %%, played_times_map = %%, random_challenges = %%", refresh_num, played_times_map, random_challenges)
        return "COMMON_SUCCESS", {
            materialChallengeRefreshRsp = {
                sys_info = self:export_all_info(userdata),
            }
        }
    end,

    -- @brief: 开始挑战
    cmd_start = function(self, args, seq, userdata) 
        local pos = args.materialChallengeStartReq.pos
        local cards = args.materialChallengeStartReq.cards or {}

        -- 检查本系统是否开放
        if not self:is_sys_opened(userdata) then
            return 'ERRNO_MATERIAL_CHALLENGE_SYS_NOT_OPEN'
        end
        -- 检查挑战次数是否足够
        local material_challenge_data = userdata:material_challenge_data()
        local challenge_times = material_challenge_data:get_challenge_times() -- 当日挑战次数
        local challenge_limit_times = self.op:get_challenge_limit_times()     -- 每日挑战次数限制
        if challenge_times >= challenge_limit_times then
            return 'ERRNO_MATERIAL_CHALLENGE_CHALLENGE_TIMES_LESS'
        end
        -- 检查副本是否已开启且未挑战成功过
        if not material_challenge_data:is_challenge_opened(pos) or material_challenge_data:is_challenge_played(pos) then
            NodeLogError("[cmd_start]: challenge not open or have played. pos = %%, challenge = %%", pos, material_challenge_data:get_challenge(pos))
            return 'ERRNO_MATERIAL_CHALLENGE_NOT_OPEN_OR_PLAYED' 
        end

        -- 获取上阵武将属性
        local play_id = g_enum.GAME_PLAY_ID.PLAY_ID_MATERIAL_CHALLENGE
        local card_items = {}
        local card_model_level = gService.constant:get_value(2008405)
        for _, card in ipairs(cards) do
            local card_id = card.id
            local tmpl_card = gService.card:make_trial_item(userdata, card_id, play_id, card_model_level)
            table.insert(card_items, tmpl_card)
        end

        -- 随机奖励
        local challenge_id = material_challenge_data:get_challenge_id(pos)
        local cfg = self.op:get_challenge_cfg(challenge_id)
        local reward_level = material_challenge_data:get_reward_level(pos)
        local drop_id = cfg.reward[reward_level].dropId
        local drop_reward = gService.rate_drop:rate_drop(userdata, drop_id)
        -- 记录当前挑战状态信息
        local play = {
            time = g_clock.now(),
            pos = pos,
            reward = drop_reward,
        }
        material_challenge_data:set_paly(play)

        NodeLogDebug("[cmd_start]: pos = %%, drop_id = %%, drop_reward = %%, challenge = %%, play = %%", pos, drop_id, drop_reward, material_challenge_data:get_challenge(pos), play)
        return "COMMON_SUCCESS", {
            materialChallengeStartRsp = {
                pos = pos,
                reward = drop_reward,
                cards = card_items,
            }
        }
    end,

    -- @brief: 挑战结束
    cmd_finish = function(self, args, seq, userdata) 
        local result = args.materialChallengeFinishReq.result

        -- 检查本系统是否开放
        if not self:is_sys_opened(userdata) then
            return 'ERRNO_MATERIAL_CHALLENGE_SYS_NOT_OPEN'
        end
        -- 检查结算是否合法
        local material_challenge_data = userdata:material_challenge_data()
        local play = material_challenge_data:get_play()
        if not next(play) then
            return 'ERRNO_MATERIAL_CHALLENGE_NOT_START'
        end
        -- 检查是否跨天
        if utils.check_day(g_clock.now(), play.time, _G.DAY_OFF) > 0 then
            NodeLogDebug('[cmd_finish]: over day. rid = %%, start_time = %%, now = %%', userdata:get_rid(), play.time, g_clock.now())
            return 'ERRNO_MATERIAL_CHALLENGE_NOT_START' 
        end
        
        -- 清空本次挑战状态信息
        material_challenge_data:set_paly({})
        -- 挑战失败则直接返回
        if result ~= true then
            return 'COMMON_SUCCESS'
        end
        -- 标记已挑战成功
        material_challenge_data:set_challenge_played(play.pos, true)
        -- 累计挑战次数
        material_challenge_data:set_challenge_times(material_challenge_data:get_challenge_times() + 1)
        -- 发放奖励
        local ret = gService.bag_op:add_items(userdata, play.reward, g_enum.bag.item_source.material_challenge_finish)
        if ret ~= 'COMMON_SUCCESS' then
        	return ret
        end
        NodeLogDebug("[cmd_finish]: pos = %%, challenge = %%, reward = %%", play.pos, material_challenge_data:get_challenge(play.pos), play.reward)

		gService.event:event(g_enum.event.material_challenge_finish, userdata)

        return "COMMON_SUCCESS", {
            materialChallengeFinishRsp = {
                info = self:export_challenge_info(play.pos, material_challenge_data:get_challenge(play.pos)),
            }
        }
    end,

    -- @brief: 领取次数奖励
    cmd_times_pick = function(self, args, seq, userdata) 
        -- 检查本系统是否开放
        if not self:is_sys_opened(userdata) then
            return 'ERRNO_MATERIAL_CHALLENGE_SYS_NOT_OPEN'
        end

        -- 检查是否有可领取的奖励
        local material_challenge_data = userdata:material_challenge_data()
        local picked_idx = material_challenge_data:get_picked_idx()
        local week_refresh_times = material_challenge_data:get_week_refresh_times()
        local new_picked_idx, rewards, additions = self.op:get_refresh_times_reward(picked_idx, week_refresh_times)
        if new_picked_idx == picked_idx then
            return "ERRNO_MATERIAL_CHALLENGE_REWARD_PICKED"
        end

        -- 记录领取的奖励序号
        material_challenge_data:set_picked_idx(new_picked_idx)
        material_challenge_data:add_additions(additions)
        -- 发放奖励
        if next(rewards) then
            local ret = gService.bag_op:add_items(userdata, rewards, g_enum.bag.item_source.material_challenge_times_reward)
            if ret ~= 'COMMON_SUCCESS' then
                return ret
            end
        end

        NodeLogDebug("[cmd_times_pick]: rid = %%, picked_idx = %%, times = %%, reward = %%", userdata:get_rid(), new_picked_idx, week_refresh_times, rewards)
        return "COMMON_SUCCESS", {
            materialChallengeTimesPickRsp = {
                picked_idx = new_picked_idx,
            }
        }
    end,
}

local userdata_func = {
    client_info = function(self, userdata)
        if not self:is_sys_opened(userdata) then
            return
        end

        return self:export_all_info(userdata)
    end,

    export_all_info = function(self, userdata)
        local list = {}
        local material_challenge_data = userdata:material_challenge_data()
        for pos, challenge in pairs(material_challenge_data:get_list()) do
            table.insert(list, self:export_challenge_info(pos, challenge))
        end
        return {
            list = list,
            refresh_times = material_challenge_data:get_refresh_times(),
            challenge_times = material_challenge_data:get_challenge_times(),
            picked_idx = material_challenge_data:get_picked_idx(),
            week_refresh_times = material_challenge_data:get_week_refresh_times(),
        }
    end,
    export_challenge_info = function(self, pos, challenge)
        return {
            pos = pos,
            challenge_id = challenge.challenge_id,
            map_id = challenge.map_id,
            reward_level = challenge.reward_level,
            is_played = challenge.is_played,
        }
    end,
}

local event_func = {
    _bind_event = function(self)
        self.event:bind("material_challenge_open_func", g_enum.event.system_open, function(userdata, open_list)
            for _, open_id in pairs(open_list) do
                if open_id == g_enum.open_system.id.NewMystery then
                    self:_sys_open(userdata)
                    break
                end
            end
        end)
    end,

    _sys_open = function(self, userdata)
        -- 更新
        local material_challenge_data = userdata:material_challenge_data()
        material_challenge_data:clear_data_by_day()
        -- 推送
        self:notify_sys_open(userdata)
    end
}

local notify_func = {
    notify_sys_open = function(self, userdata)
        gService.global:notify_by_rid(userdata:get_rid(), "SC_LOGIC_CMD_MATERIAL_CHALLENGE_OPEN_PUSH", {
            materialChallengeOpenPush = {
                sys_info = self:export_all_info(userdata),
            }
        })
    end,
}

local service = {
    CmdMap = {
        ['CS_LOGIC_CMD_MATERIAL_CHALLENGE_REFRESH'] = 'cmd_refresh',
        ['CS_LOGIC_CMD_MATERIAL_CHALLENGE_START'] = 'cmd_start',
        ['CS_LOGIC_CMD_MATERIAL_CHALLENGE_FINISH'] = 'cmd_finish',
        ['CS_LOGIC_CMD_MATERIAL_CHALLENGE_TIMES_PICK'] = 'cmd_times_pick',
	},
    _init = function(self, cfg)
        return self:_pre_run()
    end,
    _reload = function(self, cfg)
        return self:_pre_run()
    end,
    _pre_run = function(self)
        self:_bind_event()
    end,

    -- @brief: 检查本系统是否开放
    is_sys_opened = function(self, userdata)
        return gService.open_func_op:is_opened(userdata, g_enum.open_system.id.NewMystery)
    end,

    resend_unpick_refresh_reward = function(self, userdata)
        -- 检查是否有可领取的奖励
        local material_challenge_data = userdata:material_challenge_data()
        local picked_idx = material_challenge_data:get_picked_idx()
        local week_refresh_times = material_challenge_data:get_week_refresh_times()
        local new_picked_idx, rewards = self.op:get_refresh_times_reward(picked_idx, week_refresh_times)
        if new_picked_idx == picked_idx then
            return
        end

        -- 记录领取的奖励序号
        material_challenge_data:set_picked_idx(new_picked_idx)

        --发邮件
        gService.mail_server:add_new_mail(userdata:get_rid(), {
            textid = gService.constant:get_value(2008407),
            reward_items = rewards,
            item_source = g_enum.bag.item_source.material_challenge_times_mail,
        })
    end,
}


utils.table_merge(cmd_func, service)
utils.table_merge(userdata_func, service)
utils.table_merge(event_func, service)
utils.table_merge(notify_func, service)

return service
