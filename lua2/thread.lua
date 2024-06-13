
--协程suspended
--yield

local co = coroutine.wrap(
    function()
        print("xxxx")
        local n1,n2,n3 = coroutine.yield(1,2,3)
        print("aaaa")
        print(n1,n2,n3)
    end
)
print(co()) --第一次调用时，遇到yield就挂起，同时接收yield传出来的(1,2,3)

co(4,5,6)   --当挂起后，再一次调用可以将参数传进去，同时由yield接收

--wrap返回 函数 变量，create返回 线程
--因此在调用的时候 会有不同

local co2 = coroutine.create(
    function()
        print("co2xxxxx")
    end
)

coroutine.resume(co2)
