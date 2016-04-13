--
-- @author: ccy
-- @date: 2015-08-22 19:31:11
--
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