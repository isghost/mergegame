--[[--
 * @description: 主要游戏场景
 * @author:      ccy
 * @dateTime:    2016-04-16 19:56:03
 ]]

GameScene = class("GameScene",function()
	return cc.Scene:create()
end)

function GameScene:ctor()
	self.newNumNode = nil
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
		:setPosition(display.center.x, 1100)

	local score = cc.Sprite:create("best.png")
	    :setPosition(cc.p(25, 1000))
    	:addTo(self,1,102)

    self.scoreNum = cc.Label:create()
		:setString("546")
		:addTo(self,1,103)
		:setSystemFontSize(35)
		:setAnchorPoint(0.0,0.5)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(50, 1000)

	local coin = cc.Sprite:create("coin.png")
	    :setPosition(cc.p(25, 960))
	    :setScale(0.7)
    	:addTo(self,1,104)

    self.coinNum = cc.Label:create()
		:setString("546")
		:addTo(self,1,105)
		:setSystemFontSize(35)
		:setAnchorPoint(0.0,0.5)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(50, 960)

    self.scoreNum = cc.Label:create()
		:setString("546")
		:addTo(self,1,106)
		:setSystemFontSize(70)
		:setAnchorPoint(1.0,0.5)
		:setPosition(545, 975)

	self.pauseButton = ccui.Button:create("pause.png")
		:addTo(self,1,107)
		:setPosition(590,975)

	self.cells = {}
	local baseX,baseY = 10,200
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
		:setPosition(0,150)

	local coinCost = cc.Sprite:create("coin.png")
	    :setPosition(cc.p(25, 50))
	    :setScale(0.7)
    	:addTo(self,1,109)

    self.coinCostNum = cc.Label:create()
		:setString("546")
		:addTo(self,1,110)
		:setSystemFontSize(35)
		:setAnchorPoint(0.0,0.5)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(50, 50)

	self.newNumNode = cc.Node:create()
		:setPosition(display.center.x, 200)
		:addTo(self, 1, 111)
		:setContentSize(cc.size(100,100))
		:setAnchorPoint(cc.p(0.5, 0.5))
end

function GameScene:initLogic()
	self.gameModel = GameModel:create(self)
	addTouchListener(self.newNumNode,function()
		end,function(touch, event)
			local delta = touch:getDelta()
			local curPosX,curPosY = self.newNumNode:getPosition()
			self.newNumNode:setPosition(curPosX + delta.x, curPosY + delta.y)
		end,function(touch, event)
			local nowPos = touch:getLocation()
			local startPos = touch:getStartLocation()
			local dis = cc.pGetLength(nowPos, startPos)
			if dis < 10 then
				self.gameModel:tapItems()
			else
				self.gameModel:setItemProperPosition(self:convertToNodeSpace(nowPos))
			end
		end)
end

function GameScene:runMoveAction(actionMove)
	for k,v in pairs(actionMove) do
		local view = self.views[v.from]
			:setLocalZOrder(50)
		self.views[v.from] = nil
		local moveTo = cc.MoveTo:create(0.5, cc.p(self.cells[v.to]:getPosition()))
		local callFunc = cc.CallFunc:create(function()
			view:removeFromParent()
		end)
		view:runAction(cc.Sequence:create(moveTo, callFunc))
	end
end

function GameScene:addGood(pos,num)
	local spriteNum = cc.Sprite:create("num_"..num..".png")
		:setPosition(self.cells[pos]:getPosition())
		:addTo(self,100)
	self.views[pos] = spriteNum
end

function GameScene:runCreateAction(pos,num)
	local spriteNum = cc.Sprite:create("num_"..num..".png")
		:setPosition(self.cells[pos]:getPosition())
		:addTo(self,100)
		:setScale(0.2)
	local scaleTo = cc.ScaleTo:create(0.2, 1.0)
	spriteNum:runAction(scaleTo)
	self.views[pos] = spriteNum
end

function GameScene:runActionQueue(actionQueue)
	local curActionIndex = 1
	local endCallFunc = nil
	local actionDelay = cc.DelayTime:create(0.3)
	endCallFunc = cc.CallFunc:create(function()
		if actionQueue[curActionIndex] then
			local action = actionQueue[curActionIndex]
			curActionIndex = curActionIndex + 1
			local callfunc = nil
			if action.actionType == "move" then
				callFunc = cc.CallFunc:create(function()
					self:runMoveAction(action.result)
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
			self:runAction(cc.Sequence:create(callFunc, cc.DelayTime:create(0.2), endCallFunc:clone()))
		else
			-- warning release
			endCallFunc:release()
		end
	end)
	-- warning retain
	endCallFunc:retain()
	self:runAction(endCallFunc)
end

function GameScene:addToDoItem(nums)
	if #nums == 1 then
		local contentSize = self.newNumNode:getContentSize()
		local spriteNum = cc.Sprite:create("num_"..nums[1]..".png")
			:setAnchorPoint(cc.p(0.5, 0.5))
			:setPosition(contentSize.width / 2 , contentSize.height / 2)
		self.newNumNode:addChild(spriteNum)
	end
end

