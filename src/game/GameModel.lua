--[[--
 * @description: model
 * @author:      ccy
 * @dateTime:    2016-04-17 14:26:47
 ]]
GameModel = class("GameModel")

function GameModel:ctor(view)
	self.view = view
	self.nums = {}
	self.score = 0
	self:init()
end

function GameModel:init()
	math.randomseed(os.time())
	local pos = random(1,25)
	local num = random(1,3)
	for i = 1, 25 do
		self.nums[i] = -1
	end
	self:addGood(pos,num)
end

function GameModel:addGood(pos1,num1,pos2,num2)
	if num2 and num1 > num2 then
		pos1, pos2 = pos2, pos1
		num1, num2 = num2, num1
	end
	self.num[pos1] = num1
	if num2 then
		self.num[pos2] = num2
	end
	local actionQueue = self:checkSynthesisAll({pos1,pos2})
	self.view:runActionQueue(actionQueue)
end

function GameModel:checkSynthesisAll(posQueue)
	local actionQueue = {}
	for i = 1,#posQueue do
		local pos = posQueue[i]
		local flag = true
		while flag do
			flag = false
			local tmpFlag, action1,action2 = self:checkSynthesis(pos)
			flag = tmpFlag
			if flag then
				actionQueue[#actionQueue + 1] = action1
				actionQueue[#actionQueue + 1] = action2
			else
				actionQueue[#actionQueue + 1] = action1
			end
		end
	end
	return actionQueue
end

function GameModel:checkSynthesis(pos)
-- 检查合成
	local value = self.nums[pos]
	local vis = {}
    local queue = {}
    local forward = {-5,1,5,-1}
    local rear,front = 0,0
    queue[0] = pos 
    vis[pos] = true 
    local addLevel = 0
    while rear >= front do
        local curPos = queue[front]
        front = front + 1
        for i=1,4 do
            local tmpPos = curPos + forward[i]
            if not vis[tmpPos] and self.nums[tmpPos] == value then
                vis[tmpPos] = true 
                rear = rear + 1
                queue[rear] = tmpPos
            end
        end
    end
-- 返回结果
    local result = {}
    local num = 0 -- 相连相同块的数量
    for i = 1, 25 do
    	if vis[i] then
    		result[#result + 1] = {from = i,to = pos}
    		num = num + 1
    	end
    end
-- 无法合成
    if num < 3 then
    	return false , {action = "create",pos = pos,value = value}
    end
-- 可以合成
    for i = 1, 25 do 
    	if vis[i] then
    		self.nums[i] = -1
    	end
    end

    self.nums[pos] = value + 1

    return #result * value , {action = "move",result = result}, {action = "create",pos = pos,value = value + 1}
end