
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

local function main()
    require "game.init"
    require "ccyeasy.init"
    local scene = cc.Scene:create()
    display.runScene(MainScene:create())
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
