package.path = package.path..
                ";./lua/?.lua"..";./lua2/?.lua"

require("string")

require("mt")
print(mt_gobal_tmp)

--require只会执行一次
--使用package.loaded["xxx"]卸载脚本


print("this is frist time running script")
require("script")

package.loaded["script"] = nil      --卸载后可以重新运行

print("this is second time running script")
require("script")

local tmp = require("script")

print(tmp)