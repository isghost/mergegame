--[[--
 * @description: 主要游戏场景
 * @author:      ccy
 * @dateTime:    2016-04-16 19:56:03
 ]]

GameScene = class("GameScene",function()
	return cc.Scene:create()
end)

function GameScene:ctor()
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
			self.cells[i * 5 + j] = cell
		end
	end

	self.trashButton = ccui.Button:create("trash.png")
		:addTo(self,10,108)
		:setAnchorPoint(0,0.5)
		:setPosition(0,150)

	local coinCost = cc.Sprite:create("coin.png")
	    :setPosition(cc.p(25, 50))
	    :setScale(0.7)
    	:addTo(self,1,104)

    self.coinCostNum = cc.Label:create()
		:setString("546")
		:addTo(self,1,105)
		:setSystemFontSize(35)
		:setAnchorPoint(0.0,0.5)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(50, 50)
end

function GameScene:initLogic()

end