return {
    CmdMap = {
    	['CS_LOGIC_CMD_BUY_ITEM_INFO'] 	= 'client_info',
    	['CS_LOGIC_CMD_BUY_ITEM_BUY'] 	= 'buy',
	},
	_init = function(self)
		self:_pre_run()
	end,

	_relod = function(self)
		self:_pre_run()
	end,

	_pre_run = function(self)
		self.buy_cfg_pool = {}
		local sheet = global.resource:get_sheet("ResBuyitemList", "list")
		if sheet then
			for _, entry in pairs(sheet) do
				self.buy_cfg_pool[entry.ID.id] = self.buy_cfg_pool[entry.ID.id] or {}
				table.insert(self.buy_cfg_pool[entry.ID.id], entry)
			end
		end
		--需要根据次数排序，确保次数小在前
		for id, _ in pairs(self.buy_cfg_pool or {}) do
			table.sort(self.buy_cfg_pool[id], function(left_item, right_item)
				return left_item.buy_times < right_item.buy_times
			end)
		end
	end,

	client_info = function(self, args, seq, userdata)
		local rsp_info = userdata:buyitem_data():client_info()
		return 'COMMON_SUCCESS', {
			buyItemInfoRsp = rsp_info
		}
	end,

	buy = function(self, args, seq, userdata)
		if not args or 
		   not args.buyItemBuyReq or
		   not args.buyItemBuyReq.id then
			NodeLogWarnning("buyitem buy args error")
			return 'COMMON_ERROR'
		end

		local ret, rsp_info = userdata:buyitem_data():buy(args.buyItemBuyReq.id)
		if ret ~= 'COMMON_SUCCESS' then
			return ret
		end

		return 'COMMON_SUCCESS', {
			buyItemBuyRsp =  rsp_info 
		}
	end,
}
