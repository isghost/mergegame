--
-- @author: ccy
-- @date: 2015-08-22 19:31:11
--
--[[--
 * @description: 点击回调  
 * @param:       string name 
 * @return:      nil
 ]]
function addTouchListener(item,began,moved,ended,canceled)
	if item.addTouchEventListener then
		item:addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.began and began then
				began(sender,eventType)
			elseif eventType == ccui.TouchEventType.moved and moved then
				moved(sender,eventType)
			elseif eventType == ccui.TouchEventType.ended and ended then
				ended(sender,eventType)
			elseif eventType == ccui.TouchEventType.canceled and canceled then
				canceled(sender,eventType)
			end
		end)
	else
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		local gBegan = function (touch, event)
	        local target = event:getCurrentTarget()
	        local rect   = target:getBoundingBox()
	        if cc.rectContainsPoint(rect, touch:getLocation()) then
	        	if began then began(touch,event) end
	            return true
	        end
	        return false
	    end
	    if not moved then 
	    	moved = function() return true end
	    end
		listener:registerScriptHandler(gBegan,cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(moved,cc.Handler.EVENT_TOUCH_MOVED)
		if ended then listener:registerScriptHandler(ended,cc.Handler.EVENT_TOUCH_ENDED) end
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, item)
	end
end
function addTouchListenerEnded(item,ended)
	addTouchListener(item,nil,nil,ended,nil)
end

--[[--
 * @description: ease相关函数 quadratic(quad) 二次 cubic 三次 Quart四次  in下凹，out上凸
 * @param:       float 0~1
 * @return:      float 0~1
]]

function easeOutQuad(rate)
	rate = math.max(0, rate)
	rate = math.min(1, rate)
	return - rate * (rate - 2)
end

function easeInQuad(rate)
	return rate^2
end

function easeOutCubic(rate)
	rate = rate - 1
	return rate^3 + 1
end

function easeInCubic(rate)
	return rate^3
end

--[[--
 * @description: 数字标签快速移动  
 * @param:       string name 
 * @return:      nil
]]

function labelJumpAction(label, runTime, beginNum, endNum)
	label:unscheduleUpdate()
	local curTime = 0
	label:scheduleUpdateWithPriorityLua(function(delta)
		curTime = curTime + delta
		local num = beginNum + (endNum - beginNum) * easeOutQuad(curTime / runTime)
		num = math.floor(math.min(endNum, num))
		label:setString(num)
		if num >= endNum then
			label:unscheduleUpdate()
		end
	end,0)
end