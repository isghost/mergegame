--[[--
 * @description: 创建子面板 比如暂停，游戏结束，提示菜单 面板层级10000起
 * @author:      ccy
 * @dateTime:    2016-04-23 15:09:17
]]

SubPanel = class("SubPanel")

--[[--
 * @description: 暂停菜单  
 * @param:       parentView 父节点
 * @return:      nil
]]
function SubPanel.createPausePanel(parentView)
	-- ui
	local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), display.width, display.height)
		:addTo(parentView, 10000)
	local panel = cc.Sprite:create("panel.png")
		:addTo(colorLayer, 10)
		:setPosition(display.center)

	local contentSize = panel:getContentSize()
	local labelPause = cc.Label:create()
		:setString("暂停")
		:setSystemFontSize(45)
		:setPosition(contentSize.width / 2, contentSize.height - 50)
		:addTo(panel, 10)

	local closeButton = ccui.Button:create("close.png")
		:addTo(panel, 10)
		:setPosition(contentSize.width - 50, contentSize.height - 50)

	local resumeButton = ccui.Button:create("resume.png")
		:addTo(panel, 10)
		:setPosition(contentSize.width / 2, contentSize.height / 2 + 50)

	local homeButton = ccui.Button:create("home.png")
		:addTo(panel, 10)
		:setPosition(contentSize.width / 4, 120)

	local musicButton = ccui.Button:create("music.png")
		:addTo(panel, 10)
		:setPosition(contentSize.width / 4 * 3, 120)

	-- 回调开始
	addTouchListenerEnded(closeButton,function()
		colorLayer:removeFromParent()
	end)

	addTouchListenerEnded(resumeButton,function()
		parentView.gameModel:gameOver(false)
		display.runScene(GameScene:create())
	end)

	addTouchListenerEnded(homeButton,function()
		parentView.gameModel:gameOver(false)
		display.runScene(MainScene:create())
	end)
end

--[[--
 * @description: 游戏结束面板  
 * @param:       parentView 父节点
 * @return:      nil
]]

function SubPanel.createGameOverPanel(parentView, exp, coin)
	-- ui
	local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), display.width, display.height)
		:addTo(parentView, 10000)
	local panel = cc.Sprite:create("panel.png")
		:addTo(colorLayer, 10)
		:setPosition(display.center)

	local contentSize = panel:getContentSize()

	local labelCoin = cc.Label:create()
		:addTo(panel, 10)
		:setString("金币")
		:setPosition(contentSize.width / 4,contentSize.height / 2 + 50)
		:setSystemFontSize(25)

	local labelCoinNum = cc.Label:create()
		:addTo(panel, 10)
		:setString(coin)
		:setPosition(contentSize.width / 4,contentSize.height / 2 + 100)
		:setSystemFontSize(45)
	labelJumpAction(labelCoinNum, 1.5, 0, coin)


	local labelExp = cc.Label:create()
		:addTo(panel, 10)
		:setString("经验")
		:setPosition(contentSize.width / 4  * 3,contentSize.height / 2 + 50)
		:setSystemFontSize(25)

	local labelExpNum = cc.Label:create()
		:addTo(panel, 10)
		:setString(exp)
		:setPosition(contentSize.width / 4 * 3,contentSize.height / 2 + 100)
		:setSystemFontSize(45)
	labelJumpAction(labelExpNum, 1.5, 0, exp)

	local okButton = ccui.Button:create("ok.png")
		:addTo(panel, 10)
		:setPosition(contentSize.width / 2, 150)

	-- callback
	addTouchListenerEnded(okButton,function()
		display.runScene(GameScene:create())
	end)

end