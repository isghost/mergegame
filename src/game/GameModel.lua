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
    self.toDoNumsAngle = 0 -- 待处理数字旋转角度
	self.score = 0 -- 成绩
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
        return 
    end
-- 可以合成
    for i = 1, 25 do 
    	if vis[i] then
    		self.nums[i] = nil
    	end
    end

    self.nums[pos] = value + 1

    return #result * value , {actionType = "move",result = result}, {actionType = "create",pos = pos,value = value + 1}
end

-- 添加待移动的数字
function GameModel:addToDoItem()
    local num = math.random(1,3)
    self.toDoNums = {num}
    self.view:addToDoItem({num})
end

-- 两个以上item时，顺时针切换
function GameModel:tapItems()
    if #self.nums  == 1 then
        return 
    else
    end
end
-- 移动item后，将item移到合适的位置
function GameModel:setItemProperPosition(pos)
    if #self.toDoNums == 1 then
        local index = self:getMinDisCell(pos)
        if index then
            self:addGood(index, self.toDoNums[1])
        else
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
    if self.nums[index] then
        return nil
    else
        return index
    end
end