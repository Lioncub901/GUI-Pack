gui.dragable = class("gui.dragable")

function gui.dragable:created(axis)
    self.entity.hitTest = true
    self.entity.hoverTest = true
    self.beginPos = nil
    
    self.style =
    {
        normalColor = color.white,
        pressedColor = color(220) ,
        hoverColor = color(255),
        selectedColor = color(255)
    }
    
    self.axis = axis or (gui.horizontal | gui.vertical)
    self.isDragging = false
    self.shouldFit = false
    self.selected = false
    self.canDrag = true
    self.hovered = false

    self.defaultColor = nil
    
    self.checkColor = nil
    self.multiplyColor = true
    self.conditionFunc = function() return true end
end

function gui.dragable:update()
    self:checkHover()
    self:checkMultiply()
    self:updateState()
end

function gui.dragable:layout()
    self:clamp()
    self.moving = false
end

function gui.dragable:checkMultiply()
    if self.multiplyColor and (self.defaultColor == nil or self:didChangeColor()) then
        self.defaultColor = self.entity.color
    end
end

function gui.dragable:didChangeColor()
    for k, col in pairs(self.style) do
        if self.defaultColor * col == self.entity.color  then
            return false
        end
    end
    return true 
end

function gui.dragable:updateState()
    if self.entity.sprite then
        local col = (self.isDragging and self.style.pressedColor) or (self.selected and self.style.selectedColor) or (self.hovered and self.style.hoverColor) or self.style.normalColor
        
        if self.multiplyColor then
            self.entity.color = (self.defaultColor or self.entity.color) * col 
        else
            self.entity.color = col
        end
    end
end

function gui.dragable:checkHover()
    if mouse and mouse.active then
        if gui.wasHovered(self.entity) then
            if not self.hovered then
                self.entity:dispatch('mouseEnter', self)
            end
            self.entity:dispatch('hovering', self)
            self.hovered = true
        else
            if self.hovered then
                self.entity:dispatch('mouseExit', self)
            end
            self.hovered = false
        end
    end
end



function gui.dragable:X()
    return self.entity.isFakeChild and "fx" or "x"
end

function gui.dragable:Y()
    return self.entity.isFakeChild and "fy" or "y"
end

function gui.dragable:touched(touch)
    if touch.began and self.conditionFunc() then
        self.passedCondition = true
    elseif touch.ended or touch.cancelled then
        self.passedCondition = false
    end
        
    if self.canDrag and self.passedCondition then
        local scal = self.entity.scene.canvas.scale
        if touch.began  then
            self.beginPos = vec2(self.entity[self:X()],self.entity[self:Y()])
            self.beginTouchPos = touch.pos * scal
            self.isDragging = true
            self.entity:dispatch('onStartDrag', self) 
        elseif touch.ended or touch.cancelled then
            self.isDragging = false
            self.entity:dispatch('onEndDrag', self)
            if self.beginTouchPos == touch.pos * scal then
                self.entity:dispatch('onTapped', self)
            end
        end
        if self.beginTouchPos == nil then
            return false
        end
        self.moving = true
        
        local newPos = self.beginPos + (touch.pos * scal - self.beginTouchPos)
        if self.axis & gui.horizontal == gui.horizontal then
            self.entity[self:X()] = newPos.x 
        end
        
        if self.axis & gui.vertical == gui.vertical then
            self.entity[self:Y()] = newPos.y
        end
        self:clamp()
        return true
    else
        if touch.began then
            self.isDragging = true 
        elseif touch.ended or touch.cancelled then
            self.isDragging = false
        end
        if touch.moving and not self.isDragging then
            return false
        end
        return true
    end
end


function gui.dragable:clamp()
    -- this makes it that you can not leave in certain areas.
    if self:rightEdge() and self:rightEdge() < self.entity[self:X()] then
        self.entity[self:X()] = self:rightEdge()
    end
    if self:leftEdge() and self:leftEdge() > self.entity[self:X()] then
        self.entity[self:X()] = self:leftEdge()
    end
    
    if self:topEdge() and self:topEdge() < self.entity[self:Y()] then
        self.entity[self:Y()] = self:topEdge()
    end
    if self:bottomEdge() and self:bottomEdge() > self.entity[self:Y()] then
        self.entity[self:Y()] = self:bottomEdge()
    end
end

function gui.dragable:bottomEdge()
    if self.shouldFit and self.bottom then
        local yPos = self.entity.pivot.y
        return self.bottom + yPos * self.entity.size.y
    end
    return self.bottom
end

function gui.dragable:topEdge()
    if self.shouldFit and self.top then
        local yPos = 1 - self.entity.pivot.y
        return self.top - yPos * self.entity.size.y
    end
    return self.top
end

function gui.dragable:rightEdge()
    if self.shouldFit and self.right then
        local xPos = 1 - self.entity.pivot.x
        return self.right - xPos * self.entity.size.x
    end
    return self.right
end

function gui.dragable:leftEdge()
    if self.shouldFit and self.left then
        local xPos = self.entity.pivot.x
        return self.left + xPos * self.entity.size.x
    end
    return self.left
end

function gui.selectDragable(enti)
    for k, ent in ipairs(enti.parent.children) do
        if ent.id ~= enti.id and ent:has(gui.dragable) then
            ent:get(gui.dragable).selected = false
        end
    end
    enti:get(gui.dragable).selected = true
    enti:get(gui.dragable):updateState()
end


--local xPos = select(2,child:anchorX()) - 0.5
--adjustVec.x = xPos * self.entity.size.x 