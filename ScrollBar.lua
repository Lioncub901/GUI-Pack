gui.scrollBar = class("gui.scrollBar")

function gui.scrollBar:created(axis)
    -- you can accept and set parameters here
    self.axis = axis
    
    self.padding = vec2(1, 1)
    
    self.entity.sprite = asset.Square
    self.entity.color = color(146, 136, 136)
    
    
    
    self.hold = self.entity:child("hold")
    self.hold.sprite = image.read(asset.Round_Rect).slice:patch(10)
    self.drag = self.hold:add(gui.dragable, axis)
    self.drag.style.normalColor = color(95)
    self.drag.style.pressedColor =  color(75)
    self.drag.style.hoverColor = color(85)
    
    self.entity.hitTest = true
    self.mousePos = nil
    self.moveSpeed = 15
end



function gui.scrollBar:layout()
    if self.mousePos then
        if self.axis  & gui.vertical == gui.vertical then
            local diff = self.mousePos.y - (self.entity.hold.worldPosition.y + self.entity.hold.size.y /2)
            local percent = self.hold.size.y/ (self.entity.size.y - 2 * self.padding.y)
            local size = self.entity.size.y / 500
            if math.abs(diff) > size * self.moveSpeed * percent then 
                diff = (diff / math.abs(diff)) * size * self.moveSpeed * percent
            end
            self.hold.y = self.hold.y + diff
        else
            local diff = self.mousePos.x - (self.entity.hold.worldPosition.x + self.entity.hold.size.x /2)
            local percent = self.hold.size.x/ (self.entity.size.x - 2 * self.padding.x)
            local size = self.entity.size.y / 500
            if math.abs(diff) > size * self.moveSpeed * percent then 
                diff = (diff / math.abs(diff)) * size * self.moveSpeed * percent
            end
            self.hold.x = self.hold.x + diff
        end   
    end
end

function gui.scrollBar:touched(touc)
    local touch = gui.mapTouchToScene(touc, self.scene)
    self.mousePos = touch.pos
    self.drag.isDragging = true
    if touch.ended then
        self.drag.isDragging = false
        self.mousePos = nil
    end
    return true
end


Profiler.wrapClass(gui.scrollBar)


