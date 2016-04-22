--[[--
 * @description: model
 * @author:      ccy
 * @dateTime:    2016-04-17 14:26:47
 ]]
GameModel = class("GameModel")

function GameModel:ctor(view)
	self.view = view -- 场景 view
	self.nums = {} -- 数字合集
    self.toDoNums = {} -- 待处理数字合集
	self.score = 0 -- 成绩
    self.bestScore = cc.UserDefault:getInstance():getIntegerForKey("bestScore",0) -- 不合理写法
    self.coin = cc.UserDefault:getInstance():getIntegerForKey("coin",0) -- 不合理写法
	self:init()
end

function GameModel:init()
	math.randomseed(os.time())
	local pos = math.random(1,25)
	local num = math.random(1,3)
	for i = 1, 25 do
		self.nums[i] = nil
	end
	self:addGood(pos,num)
    self:addToDoItem()
    -- setNum
    self.view:setScore(self.score)
    self.view:setBeseScore(self.bestScore)
    self.view:setCoin(self.coin)
end

function GameModel:addGood(pos1,num1,pos2,num2)
	if num2 and num1 > num2 then
		pos1, pos2 = pos2, pos1
		num1, num2 = num2, num1
	end
	self.nums[pos1] = num1
    self.view:addGood(pos1, num1)
    if num2 then
        self.nums[pos2] = num2
        self.view:addGood(pos2, num2)
	end
	local actionQueue ,addScore = self:checkSynthesisAll({pos1,pos2})
	self.view:runActionQueue(actionQueue)
    if addScore <= 0 then
        return 
    end
    self.view:runScoreTo(self.score, self.score + addScore)
    self.score = self.score + addScore
    if self.score > self.bestScore then
        self.bestScore = self.score
        self.view:setBeseScore(self.bestScore)
        cc.UserDefault:getInstance():setIntegerForKey("bestScore", self.bestScore)
    end
end

function GameModel:checkSynthesisAll(posQueue)
	local actionQueue = {}
    local addScore = 0 -- 增加的分数
	for i = 1,#posQueue do
		local pos = posQueue[i]
		local flag = true
		while flag do
			flag = false
			local valueSum, action1,action2 = self:checkSynthesis(pos)
			flag = valueSum
			if flag then
				actionQueue[#actionQueue + 1] = action1
				actionQueue[#actionQueue + 1] = action2
                addScore = addScore + valueSum
			else
				--actionQueue[#actionQueue + 1] = action1
			end
		end
	end
	return actionQueue, addScore
end

function GameModel:checkSynthesis(pos)
-- 检查合成
	local value = self.nums[pos]
    if not value then return end
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
            local flag = (curPos % 5 == 1 and i == 4) or (curPos % 5 == 0 and i == 2)
            if not vis[tmpPos] and self.nums[tmpPos] == value and not flag then
                vis[tmpPos] = true 
                rear = rear + 1
                queue[rear] = tmpPos
            end
        end
    end
-- 返回结果
    local result = {}
    local count = 0 -- 相连相同块的数量
    for i = 1, 25 do
    	if vis[i] then
    		result[#result + 1] = {from = i,to = pos}
    		count = count + 1
    	end
    end
-- 无法合成
    if count < 3 then
        return 
    end
-- 可以合成
    for i = 1, 25 do 
    	if vis[i] then
    		self.nums[i] = nil
    	end
    end

    self.nums[pos] = value + 1

    return #result * value , {actionType = "merge",result = result, value = value * count, pos = pos}, 
        {actionType = "create",pos = pos,value = value + 1}
end

-- 添加待移动的数字
function GameModel:addToDoItem()
    if self:getCreateItemNum() == 1 then
        local num = math.random(1,3)
        self.toDoNums = {num}
        self.view:addToDoItem({num})
    else
        local num1 = math.random(1,3)
        local num2 = num1
        while num2 == num1 do
            num2 = math.random(1,3)
        end
        self.toDoNums = {num1, num2}
        self.view:addToDoItem({num1, num2})
    end
end
-- 产生item的数量
function GameModel:getCreateItemNum()
    local flag = false
    local forward = {-5,1,5,-1}
    for curPos = 1, 25 do
        if not self.nums[curPos] then
            for i=1, 4 do
                local tmpPos = curPos + forward[i]
                local flag2 = (curPos % 5 == 1 and i == 4) or (curPos % 5 == 0 and i == 2)
                if  tmpPos >= 1 and tmpPos <= 25 and not self.nums[tmpPos] and not flag2 then
                    flag = true
                    break
                end
            end
        end
    end
    if flag then
        local kk = randomByWeight(2, 8)
        return kk
    else
        return 1
    end
end


-- 移动item后，将item移到合适的位置
function GameModel:setItemProperPosition(pos1, pos2)
    if #self.toDoNums == 1 then
        local index = self:getMinDisCell(pos1)
        if index then
            self:addGood(index, self.toDoNums[1])
            self.view:resetToDoItem(true)
            self:addToDoItem()
        else
            self.view:resetToDoItem(false)
        end
    elseif #self.toDoNums == 2 then
        local index1 = self:getMinDisCell(pos1)
        local index2 = self:getMinDisCell(pos2)
        if index1 and index2 then
            self:addGood(index1, self.toDoNums[1], index2, self.toDoNums[2])
            self.view:resetToDoItem(true)
            self:addToDoItem()
        else
            self.view:resetToDoItem(false)
        end
    end
end


-- 根据位置，寻找对应的格子,直接暴力找最近点，不优化
function GameModel:getMinDisCell(pos)
    local minDis = 1e99
    local index = nil 
    for i = 1, 25 do
        local cellPos = cc.p(self.view.cells[i]:getPosition()) -- 错误写法，引用了view
        local dis = cc.pGetDistance(pos,cellPos)
        if dis < minDis then
            index = i 
            minDis = dis
        end
    end
    if self.nums[index] or minDis > 50 then
        return nil
    else
        return index
    end
end