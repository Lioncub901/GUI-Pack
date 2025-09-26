function gui.mapTouchToScene(touch, scen, did)
    local newTouch = {}
    newTouch.id = touch.id
    newTouch.state = touch.state
    newTouch.type = touch.type
    
    
    newTouch.began = touch.began
    newTouch.moving = touch.moving
    newTouch.ended = touch.ended
    newTouch.cancelled = touch.cancelled

    newTouch.direct = touch.direct
    newTouch.indirect = touch.indirect
    newTouch.pencil = touch.pencil
    newTouch.pointer = touch.pointer
    
    newTouch.timestamp = touch.timestamp
    newTouch.tapCount = touch.tapCount
    
    local uiScale = scen.canvas.scale
    local uiPosition = scen.canvas.position
    
    newTouch.x = uiScale * (touch.x - uiPosition.x)
    newTouch.y = uiScale * (touch.y - uiPosition.y)
    newTouch.prevX = uiScale * (touch.prevX - uiPosition.x)
    newTouch.prevY = uiScale * (touch.prevY - uiPosition.y)
    newTouch.deltaX = uiScale * touch.deltaX
    newTouch.deltaY = uiScale * touch.deltaY
    
    newTouch.pos = uiScale * (touch.pos - uiPosition)
    newTouch.prevPos = uiScale * (touch.prevPos - uiPosition)
    newTouch.delta = uiScale * touch.delta
    
    newTouch.__metaCodeaName = "touch"
    
    function newTouch:toString()
        return string.format(
        "touch(x=%.2f, y=%.2f, id=%s, state=%s, type=%s, tapCount=%s)",
        self.x,
        self.y,
        tostring(self.id),
        tostring(self.state),
        tostring(self.type),
        tostring(self.tapCount)
        )
    end
    
    local mt = {
        __tostring = function(t) return t:toString() end
    }
    setmetatable(newTouch, mt)
    
    return newTouch
end

function gui.mapMouseToScene(mous, scen)
    --if key == "x" or key == "y" or key == "position" or key == "pos" or key == "dx" or key == "dy" or key == "inRegion" or key == "hide" or key == "show" or key == "hidden" or key == "left" or key == "right" or key == "middle" or key == "scroll" or key == "init" or key == "version" or key == "pressing" or key == "released" or key == "pressed" or key == "addHandler" then
    
    local newMouse = {}
    
    local uiScale = scen.canvas.scale
    local uiPosition = scen.canvas.position
    
    newMouse.x = uiScale * (mouse.x - uiPosition.x)
    newMouse.y = uiScale * (mouse.y - uiPosition.y)
    newMouse.dx = uiScale * mouse.dx
    newMouse.dy = uiScale * mouse.dy
    newMouse.position = uiScale * (mouse.position - uiPosition)
    newMouse.pos = uiScale * (mouse.pos - uiPosition)

    return newMouse     
end
