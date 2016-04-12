
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

local function main()
    local scene = cc.Scene:create()
    local sprite = cc.Sprite:create("HelloWorld.png")
    	:addTo(scene)
    	:setScale(0.5)
    	:setPosition(300,200)
    local label = cc.Label:createWithSystemFont("Hello Mygame", "Helvetica", 24)
    	:addTo(scene)
    	:setPosition(display.center)
    display.runScene(scene)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
