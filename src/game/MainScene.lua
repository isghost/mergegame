--[[--
 * @description: 主界面
 * @author:      ccy
 * @dateTime:    2016-04-16 10:31:26
 ]]

MainScene = class("MainScene",function()
	return cc.Scene:create()
end)

function MainScene:ctor()
	self:initUI()
	self:initLogic()
end
--[[--
 * @description: 初始化界面，相当于读取一个UI工程，这里改成纯代码编写
 * @return:      nil
 ]]
function MainScene:initUI()
	self.bg = cc.Sprite:create("bg.png")
		:addTo(self,0,10)
		:setPosition(display.center)

	self.logo = cc.Sprite:create("logo.png")
		:addTo(self,1,11)
		:setPosition(display.center.x,1000)

	self.bestScore = cc.Label:create()
		:setString("成绩")
		:addTo(self,1,20)
		:setSystemFontSize(30)
		:setAnchorPoint(1.0,0.5)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(display.center.x - 70, 980)

	self.bestScoreNum = cc.Label:create()
		:setString("469")
		:addTo(self,1,21)
		:setSystemFontSize(70)
		:setAnchorPoint(1.0,0.5)
		:setPosition(display.center.x - 70, 1050)

	self.coin = cc.Label:create()
		:setString("金币")
		:addTo(self,1,20)
		:setSystemFontSize(30)
		:setAnchorPoint(0.0,0.5)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(display.center.x + 70, 980)

	self.coinNum = cc.Label:create()
		:setString("957")
		:addTo(self,1,21)
		:setSystemFontSize(70)
		:setAnchorPoint(0.0,0.5)
		:setPosition(display.center.x + 70, 1050)

	--self.to1 = cc.ProgressTo:create(2, 100)

    self.levelProgress = cc.ProgressTimer:create(cc.Sprite:create("process_2.png"))
    	:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    	:setPosition(cc.p(display.center.x, 600))
    	:setPercentage(50)
    	:addTo(self,1,22)

    self.levelProgressBg = cc.Sprite:create("process.png")
	    :setPosition(cc.p(display.center.x, 600))
    	:addTo(self,0,23)

    self.coinImage = cc.Sprite:create("coin.png")
    	:setPosition(cc.p(display.center.x, 685))
    	:addTo(self,1,24)

    self.level = cc.Label:create()
		:setString("等级")
		:addTo(self,1,25)
		:setSystemFontSize(30)
		:setTextColor(cc.c4b(125,125,125,255))
		:setPosition(display.center.x , 570)

	self.levelNum = cc.Label:create()
		:setString("11")
		:addTo(self,1,26)
		:setSystemFontSize(70)
		:setPosition(display.center.x , 620)


	self.playButton = ccui.Button:create("play.png")
		:addTo(self,2,12)
		:setPosition(display.center.x,400)

	self.shopButton = ccui.Button:create("shop.png")
		:addTo(self,3,13)
		:setPosition(display.center.x - 180,200)

	self.bestButton = ccui.Button:create("best_2.png")
		:addTo(self,4,14)
		:setPosition(display.center.x, 200)

	self.settingButton = ccui.Button:create("setting.png")
		:addTo(self, 5, 15)
		:setPosition(display.center.x + 180, 200)
end

function MainScene:initLogic()
	addTouchListener(self.playButton,function()
		display.runScene(GameScene:create())
	end)
end