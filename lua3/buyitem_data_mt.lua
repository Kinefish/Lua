return {
	__index = {
		clear_data_by_day = function(self)
            self.list = {}
		end,

		get_item_cfg = function(self, id, times)
			for _, entry in ipairs(global.buyitem.buy_cfg_pool[id] or {}) do
				if (times <= entry.buy_times) or (-1 == entry.buy_times) then
					return entry
				end
			end
		end,

		client_info = function(self)
			local item_list = {}
			for _id, item_info in pairs(self.list or {}) do
				table.insert(item_list, {id = _id, buy_times = item_info.buy_times})
			end

			return { item_list = item_list }
		end,

		buy = function(self, id)
			self.list[id] = self.list[id] or {
				buy_times = 0
			}

			local cfg = self:get_item_cfg(id, self.list[id].buy_times + 1)
			if not cfg then
				return 'ERRNO_BUY_ITEM_DAILY_BUY_LIMIT'
			end


			local bag_data = global:root(self):bag_data()
			local userdata = global:root(self)
			local ret = gService.bag_op:del_items(userdata, cfg.cost, g_enum.bag.item_source.buyitem_buy)
			if ret ~= 'COMMON_SUCCESS' then
				return ret
			end
            local userdata = global:root(self)
			gService.bag_op:add_items(userdata, {{id = id, num = cfg.num}}, g_enum.bag.item_source.buyitem_buy)
			self.list[id].buy_times = self.list[id].buy_times + 1

			return 'COMMON_SUCCESS', {
				item = {id = id, buy_times = self.list[id].buy_times}
			}
		end,
	}
}
