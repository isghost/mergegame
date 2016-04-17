
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
require "game.init"
require "ccyeasy.init"

local function main()
    local scene = cc.Scene:create()
    local sprite = cc.Sprite:create("HelloWorld.png")
    	:addTo(scene)
    	:setScale(0.5)
    	:setPosition(300,200)
    local label = cc.Label:createWithSystemFont("Hello Mygame", "Helvetica", 24)
    	:addTo(scene)
    	:setPosition(display.center)
        print("1111111")
    display.runScene(GameScene:create())
    print("1111112")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
