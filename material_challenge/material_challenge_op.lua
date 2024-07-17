-- 在op文件中加载配置
--新增了reward_type = {}、challenge_type = {}

--加载配置的时候 通过gService.resource:get_sheet获取子表数据
--通过gService.resource:get_entry_can_nil获取子表中某一个id的数据

--如果说_mt.lua文件只是对参数的getter和setter，那么_op.lua文件就是参数的配置赋值

local basic_cfg = {
    --在该表中加载配置

}

local cfgs = {
    --在该表中定义与试炼相关的函数

    _init = function(self)
        self:_pre_run()
    end,
    _reload = function(self)
        self:_pre_run()
    end,

    _pre_run = function(self)
        --定义了reward_type、challenge_type,同时加载奖励配置
    end
}

return cfgs
 