--[[--
 * @description: 主要游戏场景
 * @author:      ccy
 * @dateTime:    2016-04-16 19:56:03
 ]]

GameScene = class("GameScene",function()
	return cc.Scene:create()
end)

function GameScene:ctor()
	-- 前三个参数都是用于最下面，待移动的数字
	self.newNumNode = nil -- 一个node,用于包含待移动数字
	self.toDoItemViews = {} -- 待移动数字合集
	self.posIndex = 1 -- 待移动数字的位置，顺时针 1 ,2,3,4
	self.views = {}
	self:initUI()
	self:initLogic()
end

function GameScene:initUI()
	self.title = cc.Label:create()
		:setString("合并中文版")
		:addTo(self,1,101)
		:setSystemFontSize(50)
		:setAnchorPoint(0.5,0.5)
		:setTextColor(cc.c4b(255,255,255,255))
		:setPosition(display.center.x, 1000)

	local bestScore = cc.Sprite:create("best.png")
	    :setPosition(cc.p(25, 910))
    	:addTo(self,1,102)

    self.bestScoreNum = cc.Label:create()
		:setString("546")
		:addTo(self,1,103)
		:setSystemFontSize(35)
		:setAnchorPoint(0.0,0.5)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(50, 910)

	local coin = cc.Sprite:create("coin.png")
	    :setPosition(cc.p(25, 870))
	    :setScale(0.7)
    	:addTo(self,1,104)

    self.coinNum = cc.Label:create()
		:setString("546")
		:addTo(self,1,105)
		:setSystemFontSize(35)
		:setAnchorPoint(0.0,0.5)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(50, 870)

    self.curScoreNum = cc.Label:create()
		:setString("546")
		:addTo(self,1,106)
		:setSystemFontSize(70)
		:setAnchorPoint(1.0,0.5)
		:setPosition(540, 890)

	self.pauseButton = ccui.Button:create("pause.png")
		:addTo(self,1,107)
		:setPosition(590,890)

	self.cells = {}
	local baseX,baseY = 5, 255
	for i = 1,5 do
		for j = 1, 5 do
			local cell = cc.Sprite:create("num_0.png")
				:addTo(self,0,i * 5 + j + 1000)
				:setPosition(baseX + j * 105,baseY + i * 105)
			self.cells[(i - 1) * 5 + j] = cell
		end
	end

	self.trashButton = ccui.Button:create("trash.png")
		:addTo(self,10,108)
		:setAnchorPoint(0,0.5)
		:setPosition(0,200)

	local coinCost = cc.Sprite:create("coin.png")
	    :setPosition(cc.p(25, 113))
	    :setScale(0.7)
    	:addTo(self,1,159)

    self.coinCostNum = cc.Label:create()
		:setString("288")
		:addTo(self,1,115)
		:setSystemFontSize(35)
		:setAnchorPoint(0.0,0.5)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(50, 110)

	self.newNumNode = cc.Node:create()
		:addTo(self, 1000, 111)
		:setContentSize(cc.size(200,200))
		:setAnchorPoint(cc.p(0.5, 0.5))
	self:resetToDoItem()

	local rotateAction = cc.RepeatForever:create(cc.RotateBy:create(3.0,360))
	self.rotationBg = cc.Sprite:create("rotation.png")
		:setPosition(self.newNumNode:getPosition())
		:addTo(self,500,112)
		:setVisible(false)
	self.rotationBg:runAction(rotateAction)

end

function GameScene:initLogic()
	self.gameModel = GameModel:create(self)
	-- 待移动的数字 
	addTouchListener(self.newNumNode,function()
		end,function(touch, event)
			local delta = touch:getDelta()
			local curPosX,curPosY = self.newNumNode:getPosition()
			self.newNumNode:setPosition(curPosX + delta.x, curPosY + delta.y)
			self.rotationBg:setVisible(false)
		end,function(touch, event)
			local nowPos = touch:getLocation()
			local startPos = touch:getStartLocation()
			local dis = cc.pGetDistance(nowPos, startPos)
			if dis < 3 then
				self:tapItems()
			else
				local pos1,pos2 = nil, nil
				pos1 = self.newNumNode:convertToWorldSpace(cc.p(self.toDoItemViews[1]:getPosition()))
				if self.toDoItemViews[2] then
					pos2 = self.newNumNode:convertToWorldSpace(cc.p(self.toDoItemViews[2]:getPosition()))
				end
				self.gameModel:setItemProperPosition(pos1, pos2)
			end
		end)

	-- 暂停按钮
	addTouchListenerEnded(self.pauseButton, function()
		SubPanel.createPausePanel(self,99,888)
	end)

	-- 垃圾箱
	addTouchListenerEnded(self.trashButton, function()
		self.gameModel:moveToTrash()
	end)
	local deltaTime = 20.0
	local tick = 0
	self.trashButton:scheduleUpdateWithPriorityLua(function(delta)
		tick = tick + delta
		if tick < deltaTime then
			return
		end
		tick = 0
		local posX, posY = self.trashButton:getPosition()
		getFloatLabel("点击生成新数字")
			:addTo(self,20000)
			:setPosition(posX + 100, posY)
	end,0)
end

function GameScene:runMoveAction(actionMove)
	local result = actionMove.result
	for k,v in pairs(result) do
		local view = self.views[v.from]
			:setLocalZOrder(50)
			:setOpacity(125)
		self.views[v.from] = nil
		local moveTo = cc.MoveTo:create(0.5, cc.p(self.cells[v.to]:getPosition()))
		local scaleTo = cc.ScaleTo:create(0.5, 0.5)
		local callFunc = cc.CallFunc:create(function()
			view:removeFromParent()
		end)
		view:runAction(cc.Sequence:create(moveTo, callFunc))
		view:runAction(scaleTo)
		self:flyNum(actionMove.pos, actionMove.value)
	end
end

function GameScene:addGood(pos,num)
	local spriteNum = cc.Sprite:create("num_"..num..".png")
		:setPosition(self.cells[pos]:getPosition())
		:addTo(self,100)
	self.views[pos] = spriteNum
	AudioEngine.playEffect("sound/drop.mp3")
end

function GameScene:runCreateAction(pos,num)
	local spriteNum = cc.Sprite:create("num_"..num..".png")
		:setPosition(self.cells[pos]:getPosition())
		:addTo(self,100)
		:setScale(0.2)
	local scaleTo = cc.ScaleTo:create(0.2, 1.0)
	spriteNum:runAction(scaleTo)
	self.views[pos] = spriteNum
	num = num - 1
	AudioEngine.playEffect("sound/Eliminate"..num..".mp3")
end

function GameScene:runActionQueue(actionQueue)
	local curActionIndex = 1
	local endCallFunc = nil
	local actionDelay = cc.DelayTime:create(0.3)
	local function endCallFunc()
		if actionQueue[curActionIndex] then
			local action = actionQueue[curActionIndex]
			curActionIndex = curActionIndex + 1
			local callfunc = nil
			if action.actionType == "merge" then
				callFunc = cc.CallFunc:create(function()
					self:runMoveAction(action)
				end)
			elseif action.actionType == "create" then
				callFunc = cc.CallFunc:create(function()
					self:runCreateAction(action.pos, action.value)
				end)
			end
			-- 存在一个runAction bug
			-- #12082, 不知道为什么被关闭
			-- http://stackoverflow.com/questions/28130156/callfunc-doesn-t-get-called-after-delay
			-- 解决方案：callFunc已经被释放，retain一下
			self:runAction(cc.Sequence:create(callFunc, cc.DelayTime:create(0.2), cc.CallFunc:create(endCallFunc)))
		else
			-- warning release
		end
	end
	-- warning retain
	endCallFunc()
end

function GameScene:addToDoItem(nums)
	self.posIndex = 0
	local scaleTo = cc.ScaleTo:create(0.13, 1.0)
	local contentSize = self.newNumNode:getContentSize()
	if #nums == 1 then
		local num1View = cc.Sprite:create("num_"..nums[1]..".png")
			:setAnchorPoint(cc.p(0.5, 0.5))
			:setPosition(contentSize.width / 2 , contentSize.height / 2)
			:addTo(self.newNumNode)
			:setScale(0.3)
		num1View:runAction(scaleTo:clone())
		self.toDoItemViews = {num1View}
		self.rotationBg:setVisible(false)
	elseif #nums == 2 then
		local num1View = cc.Sprite:create("num_"..nums[1]..".png")
			:setAnchorPoint(cc.p(0.5, 0.5))
			:setPosition(contentSize.width / 2 , contentSize.height / 2)
			:addTo(self.newNumNode)
			:setScale(0.3)
		num1View:runAction(scaleTo:clone())
		local num2View = cc.Sprite:create("num_"..nums[2]..".png")
			:setAnchorPoint(cc.p(0.5, 0.5))
			:setPosition(contentSize.width / 2 , contentSize.height / 2)
			:addTo(self.newNumNode)
			:setScale(0.3)
		num2View:runAction(scaleTo:clone())
		self.toDoItemViews = {num1View, num2View}
		self:tapItems()
		self.rotationBg:setVisible(true)
	end
end

-- 恢复到待处理东西的默认位置
function GameScene:resetToDoItem(clearItem)
	local itemX, itemY = display.center.x, 175 + display.adapterY
	self.newNumNode:setPosition(itemX, itemY)
	if clearItem then
		self.newNumNode:removeAllChildren()
	else
		if #self.toDoItemViews == 2 then
			self.rotationBg:setVisible(true)
		end
	end
end

-- 两个以上item时，顺时针切换
function GameScene:tapItems()
	self.rotationBg:setVisible(true)
    if #self.toDoItemViews  == 1 then
        return 
    elseif #self.toDoItemViews == 2 then
    	local contentSize = self.newNumNode:getContentSize()
    	local centerX, centerY = contentSize.width / 2 , contentSize.height / 2
    	local deltaPos = {{0, 52}, {52, 0}, {0, -52}, {-52,0}}
    	self.posIndex = self.posIndex%4 + 1
    	local pos1X, pos1Y = centerX + deltaPos[self.posIndex][1], centerY + deltaPos[self.posIndex][2]
    	local pos2X, pos2Y = centerX + deltaPos[(self.posIndex + 1)%4 + 1][1], centerY + deltaPos[(self.posIndex + 1)%4 + 1][2]
    	local moveTo1 = cc.MoveTo:create(0.1, cc.p(pos1X, pos1Y))
    	local moveTo2 = cc.MoveTo:create(0.1, cc.p(pos2X, pos2Y))
    	self.toDoItemViews[1]:runAction(moveTo1)
    	self.toDoItemViews[2]:runAction(moveTo2)
    end
end

function GameScene:setScore(value)
	self.curScoreNum:setString(value)
end

function GameScene:setBeseScore(value)
	self.bestScoreNum:setString(value)
end

function GameScene:setCoin(value)
	self.coinNum:setString(value)
end

function GameScene:flyNum(pos,value)
	local numLabel = cc.Label:create()
		:setString(value)
		:setPosition(self.cells[pos]:getPosition())
		:setSystemFontSize(40)
		:addTo(self,1200)

	local moveBy = cc.MoveBy:create(0.5, cc.p(0,100))
	local callFunc = cc.CallFunc:create(function()
		numLabel:removeFromParent()
	end)

	numLabel:runAction(cc.Sequence:create(moveBy,callFunc))
end

function GameScene:runScoreTo(beginValue, endValue)
	labelJumpAction(self.curScoreNum,1.0,beginValue,endValue)
end

function GameScene:gameOver(score, coin)
	SubPanel.createGameOverPanel(self, score, coin)
end

