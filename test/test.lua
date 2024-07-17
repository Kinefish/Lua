local ret = require("test.client")


local cards = ret or {}

for k, _ in pairs(cards) do
    print(k)
end