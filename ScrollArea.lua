gui.scrollArea = class("gui.scrollArea")

gui.vertical = 2 << 0
gui.horizontal = 2 << 1



function gui.scrollArea:created(axis)
    -- you can accept and set parameters here
    self.entity.hitTest = true
    self.entity.hoverTest = true
    self.entity.scrollTest = true
    self.size = nil
    self.velocity = vec2(0,0)
    self.axis = axis
    self.entity.clip = true
    self.content = nil
    
    
    self.tapCount = 0
    
    -- Damping Properties
    self.bounceDamping = 0.87
    self.velocityDamping = 0.95
    self.pullBackStrength = 3


    self.mouseScrollStrength = 0.2

    self.currentlyPanning = false
    self.hovered = false
    self.pan = gesture.pan(function(ges)
        if ges.state == 1 then
            self.currentlyPanning = true
        end
        

            if ges.state == 2 then
                self:calculateVelocity(ges)
            end
            
            if ges.state == 3 then
                self.currentlyPanning = false
        end
    end, 2, 2, false)
    
    
    if not gui.scrollArea.scenes then
        gui.scrollArea.scenes = {}
        gui.scrollArea.oldSelected = {}
    end
    
    gui.scrollArea.scenes[self.scene.name] = self.scene
    
    if not gui.scrollArea.didHandleHover then
        mouse.addHandler("onHover", gui.scrollArea.handleHover)
        gui.scrollArea.didHandleHover = true
    end
end

function gui.scrollArea.handleHover()
    for k, scen in pairs(gui.scrollArea.scenes) do
        local newMouse = nil
        if scen.canvas.entity.newMouse then
            newMouse = scen.canvas.entity.newMouse(mouse)
        end
        
        local scrollEnti =gui.insideTest(scen, mouse, "scrollTest") 
        
        local oldSelected = gui.scrollArea.oldSelected[scen.name]
        if oldSelected and oldSelected ~= scrollEnti and oldSelected.valid and oldSelected:has(gui.scrollArea) then
            oldSelected:get(gui.scrollArea).hovered = false
            
        end
        
        if scrollEnti and scrollEnti:has(gui.scrollArea) then
            local scrol = scrollEnti:get(gui.scrollArea)
            scrol.hovered = true
        end
        
        gui.scrollArea.oldSelected[scen.name] = scrollEnti
    end
end

function gui.scrollArea:start()
    if self.verticalBar then
        self.verticalBar.x = 99999
        self.verticalBar.hold.pivot = vec2(0.5,1)
        self.verticalBar.hold:anchor(CENTER, TOP)
        self.vScrollBar = self.verticalBar:get(gui.scrollBar)
        self.vScrollBar.hold:get(gui.dragable):updateState()
    end
    
    if self.horizontalBar then
        self.verticalBar.y = 99999
        self.horizontalBar.hold.pivot = vec2(0,0.5)
        self.horizontalBar.hold:anchor(LEFT, MIDDLE)
        self.hScrollBar = self.horizontalBar:get(gui.scrollBar)
        self.hScrollBar.hold:get(gui.dragable):updateState()
    end
    
    local pivot = self.content.pivot
    if self.axis & gui.vertical == gui.vertical then
        pivot.y = 1
        self.content:anchorY(TOP)
    end
    if self.axis & gui.horizontal == gui.horizontal then
        pivot.x = 0
        self.content:anchorX(LEFT)
    end
    self.content.pivot = pivot
  
    --self.content.pivot = vec2(0, 1)
    --self.content:anchor(LEFT, TOP)
    self.content.y = 0
end

function gui.scrollArea:layout()
    if self:contentIsSmaller() then
        
        self.maxMovePos = vec2(0)
        self:setBarState(false)
    else
        self:setBarState(true)
    end
    
end

function gui.scrollArea:update()
    
    --self.hovered = self:hoveredScrollArea()
    self.pan.enabled = mouse and mouse.active and self.hovered     
    self.maxMovePos = vec2.max(self.content.size - self.entity.size, vec2(0))
    self:mouseScroll()
    
    if self:contentIsSmaller() then
        
        self.maxMovePos = vec2(0)
        self:setBarState(false)
    else
        self:setBarState(true)
    end

   
    self:updateBar()
    
    self:moveContent() 
    self:addDamping()
end

function gui.scrollArea:setBarState(state)
    if self.verticalBar then
        self.verticalBar.active = state
    end
    if self.horizontalBar then
        self.horizontalBar.active = state
    end
end

function gui.scrollArea:mouseScroll()
    if mouse and mouse.active and not self.currentlyPanning and self.hovered then
        if self.axis & gui.horizontal == gui.horizontal then
            self.content.x = self.content.x + self.mouseScrollStrength * mouse.scroll.x
        end
        if self.axis & gui.vertical == gui.vertical then
            self.content.y = self.content.y + self.mouseScrollStrength * mouse.scroll.y
        end
    end
end

function gui.scrollArea:contentIsSmaller()
    if self.axis & gui.horizontal == gui.horizontal and self.content.size.x < self.entity.size.x then
        return true
    end
    if self.axis & gui.vertical == gui.vertical and self.content.size.y < self.entity.size.y then
        return true
    end
    return false
end

function gui.scrollArea:hoveredScrollArea()
    return gui.wasInside(self.entity, mouse) and self.entity == gui.insideTest(self.entity.scene, mouse, "scrollTest") 
end

function gui.scrollArea:updateBar()
    if self.verticalBar and self.verticalBar.active then
        self:updateBarVertical()
    end
    if self.horizontalBar and self.horizontalBar.active then
        self:updateBarHorizontal()
    end
end

function gui.scrollArea:updateBarVertical()
    local percent = self.entity.size.y/self.content.size.y
    if percent < 0 then
        percent = 0
    end
    if percent > 1 then
        percent = 1
    end
    
    local ySize = percent * (self.verticalBar.size.y - 2 * self.vScrollBar.padding.y) 
    self.verticalBar.hold.size = vec2(self.verticalBar.size.x - 2 * self.vScrollBar.padding.x,ySize)
    
    self:linkX()
    
    self.vScrollBar.drag.top = -self.vScrollBar.padding.y
    self.vScrollBar.drag.bottom = -(self.verticalBar.size.y - self.vScrollBar.padding.y - self.verticalBar.hold.size.y)
    
end

function gui.scrollArea:updateBarHorizontal()
    local percent = self.entity.size.x/self.content.size.x
    if percent > 1 then
        percent = 1
    end
    
    local xSize = percent * (self.horizontalBar.size.x - 2 * self.hScrollBar.padding.x)
    
    self.horizontalBar.hold.size = vec2(xSize, self.horizontalBar.size.y - 2 * self.hScrollBar.padding.y)
    self:linkY()
    self.hScrollBar.drag.left = self.hScrollBar.padding.x
    self.hScrollBar.drag.right = (self.horizontalBar.size.x - self.hScrollBar.padding.x - self.horizontalBar.hold.size.x)
end

function gui.scrollArea:linkX()
    if self.verticalBar.active then
        if not self.vScrollBar.drag.isDragging then
            self:followContentX()
        else
            self:followBarX()
        end
    end
end

function gui.scrollArea:linkY()
    if self.horizontalBar.active then
        if not self.hScrollBar.drag.isDragging then
            self:followContentY()
        else
            self:followBarY()
        end
    end
end

function gui.scrollArea:followContentX()
    
    -- This is so we can not the percent through the bar we should go
    local percent = ((self.content.size.y + math.abs(self.content.y)) ~= self.entity.size.y) and (self.content.y) / (self.content.size.y - self.entity.size.y) or 0

    if self.content.y < 0 then
        percent = self.content.y / self.content.size.y
    elseif self.content.y > self.maxMovePos.y then
        local offsetPass = self.content.y - self.maxMovePos.y 
        percent = (self.content.size.y + offsetPass) / self.content.size.y
    end
    
    local size = percent * (self.verticalBar.size.y - self.verticalBar.hold.size.y- 2* self.vScrollBar.padding.y)
    self.verticalBar.hold.y = (-self.vScrollBar.padding.y - size)
    
    if percent < 0 then
        local o = math.abs(self.content.size.y / (self.content.y - self.content.size.y))
        self.verticalBar.hold.size = vec2(self.verticalBar.hold.size.x, o * self.verticalBar.hold.size.y)
        self.verticalBar.hold.y = -self.vScrollBar.padding.y
    elseif percent > 1 then
        local o = (self.content.size.y)/ (self.entity.size.y + self.content.y)
        self.verticalBar.hold.size = vec2(self.verticalBar.hold.size.x, o * self.verticalBar.hold.size.y)
        self.verticalBar.hold.y = -(self.verticalBar.size.y - self.vScrollBar.padding.y - self.verticalBar.hold.size.y)
    end
end

function gui.scrollArea:followContentY()
    
    -- This is so we can not the percent through the bar we should go
    local percent = ((self.content.size.x + math.abs(self.content.x)) ~= self.entity.size.x) and (self.content.x) / (self.content.size.x - self.entity.size.x) or 0
    local size = percent * (self.horizontalBar.size.x - self.horizontalBar.hold.size.x- 2* self.hScrollBar.padding.x)
    self.horizontalBar.hold.x = (-self.hScrollBar.padding.x - size)
    percent = -percent
    
    if percent < 0 then
        self.horizontalBar.hold.x = -self.hScrollBar.padding.x
        local o = self.content.size.x / math.abs(self.content.x + self.content.size.x)
        self.horizontalBar.hold.size = vec2(o * self.horizontalBar.hold.size.x ,self.horizontalBar.hold.size.y)
    elseif percent > 1 then
        local o = (self.content.size.x)/ (self.entity.size.x - self.content.x)
        self.horizontalBar.hold.size = vec2(o * self.horizontalBar.hold.size.x, self.horizontalBar.hold.size.y)
        self.horizontalBar.hold.x = (self.horizontalBar.size.x - self.horizontalBar.hold.size.x-self.hScrollBar.padding.x)
    end
end


function gui.scrollArea:followBarX()
    local percent = -((self.verticalBar.hold.y+self.vScrollBar.padding.y) / (self.verticalBar.size.y - self.verticalBar.hold.size.y- 2 *self.vScrollBar.padding.y))
    self.content.y = percent* (self.content.size.y - self.entity.size.y)
end

function gui.scrollArea:followBarY()
    
    local percent = ((self.horizontalBar.hold.x-self.hScrollBar.padding.x) / (self.horizontalBar.size.x - self.horizontalBar.hold.size.x- 2 *self.hScrollBar.padding.x))
    self.content.x = -(percent* (self.content.size.x - self.entity.size.x))
    
end

function gui.scrollArea:moveContent()
    if self.axis & gui.horizontal == gui.horizontal then
        self.content.x = self.content.x + self.velocity.x
    end
    if self.axis & gui.vertical == gui.vertical then
        self.content.y = self.content.y + self.velocity.y
    end
end

function gui.scrollArea:addDamping()
    if self.tapCount == 0 then
        self.velocity = self.velocity * self.velocityDamping
        
        
        if self.content.x > 0  then
            self.content.x = self.content.x * self.bounceDamping
        elseif self.content.x < -self.maxMovePos.x then
            self.content.x = -self.maxMovePos.x + (((self.content.x + self.maxMovePos.x))* self.bounceDamping)
        end
        
        if self.content.y < 0  then
            self.content.y = self.content.y * self.bounceDamping
        elseif self.content.y > self.maxMovePos.y then
            self.content.y = self.maxMovePos.y + ((self.content.y - self.maxMovePos.y)* self.bounceDamping)
        end
    else
        self.velocity = vec2(0)
        if self.bounceDamping == 0 then
            if self.content.x > 0  then
                self.content.x = 0
            elseif self.content.x < -self.maxMovePos.x then
                self.content.x = -self.maxMovePos.x
            end
            if self.content.y < 0  then
                self.content.y = 0
            elseif self.content.y > self.maxMovePos.y then
                self.content.y = self.maxMovePos.y
            end
        end
    end
end

function gui.scrollArea:touched(touch)
    if not self:contentIsSmaller() then
        if touch.began then
            self.tapCount = self.tapCount + 1
        elseif touch.moving then
            self.tapCount = 1
            self:calculateVelocity(touch)
        elseif  touch.ended or touch.cancelled then
            self.tapCount = self.tapCount - 1 
            self:calculateVelocity(touch)
        end
    end
    return true
end

function gui.scrollArea:calculateVelocity(touch)
    if (typeof(touch) == "touch" and (not mouse or  touch.type ~= touch.pointer)) or typeof(touch) == "gesture" then
        self.velocity = touch.delta
        
        if self.content.y < 0 then
            self.velocity.y = touch.delta.y / ((1 + math.abs(self.content.y) / self.entity.size.y) * self.pullBackStrength)
        elseif self.content.y > self.maxMovePos.y then
            self.velocity.y = touch.delta.y / ((1 + math.abs(self.content.y - self.maxMovePos.y) / self.entity.size.y) * self.pullBackStrength)
        end
        
        if self.content.x > 0 then
            self.velocity.x = touch.delta.x / ((1 + math.abs(self.content.x) / self.entity.size.x) * self.pullBackStrength)
        elseif self.content.x < -self.maxMovePos.x then
            self.velocity.x = touch.delta.x / ((1 + math.abs(self.content.x - self.maxMovePos.x) / self.entity.size.x) * self.pullBackStrength)
        end
    end
end

Profiler.wrapClass(gui.scrollArea)