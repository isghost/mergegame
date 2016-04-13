--
-- @author ccy
-- @date 2016/4/13
--

--权重随机 根据权重 返回值
function randomByWeight(...)
	local params = {...}
	local sum = 0
	for k,v in pairs(params) do
		sum = sum + v 
	end
	local weight = math.random(0,sum)
	local i = #params 
	local tmpSum = sum 
	repeat 
		tmpSum = tmpSum - params[i]
		i = i - 1
	until tmpSum <= weight 
	return i + 1
end