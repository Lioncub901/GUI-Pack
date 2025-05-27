if not gui then
    gui = {}
end    

gui.button = class('gui.button', component)

function gui.button:created(styles)
    self.entity.hitTest = true
    self.entity.hoverTest = true
    self.pressed = false

        --self.entity.sprite = image.read(asset.builtin.UI.Grey_Button_10).slice:patch(10)
    
    self.style =
    {
        normalColor = color.white,
        pressedColor = color(206) ,
        disabledColor = color(100),
        selectedColor = color(186),
        hoverColor = color(234)
    }
    
    if styles then
        for styleName, styleValue in pairs(styles) do
            self.style[styleName] = styleValue
        end
    end
    
    self.defaultColor = nil

    self.checkColor = nil
    self.multiplyColor = false
    
    self.hovered = false
    self.selected = false
    self.disabled = false
    self.passCondition = nil
end

function gui.button:start()
    self:updateState()
end

function gui.button:update()
    self:checkHover()
    self:checkMultiply()
    self:updateState()
end

function gui.button:checkMultiply()
    if self.multiplyColor and (self.defaultColor == nil or self:didChangeColor()) then
        self.defaultColor = self.entity.color
    end
end

function gui.button:didChangeColor()
    for k, col in pairs(self.style) do
        if self.defaultColor * col == self.entity.color  then
            return false
        end
    end
    return true 
end

function gui.button:updateState()
    if self.entity.sprite then
        local col = (self.disabled and self.style.disabledColor) or (self.selected and self.style.selectedColor) or (self.pressed and self.style.pressedColor) or  (self.hovered and self.style.hoverColor) or self.style.normalColor
        
        if self.multiplyColor then
            self.entity.color = (self.defaultColor or self.entity.color) * col 
        else
            self.entity.color = col
        end
    end
end

function gui.button:checkHover()
    if mouse and mouse.active then
        if gui.wasHovered(self.entity) then
            if not self.hovered then
                self.entity:dispatch("onMouseEnter", self)
            end
            self.entity:dispatch('hovering', self)
            self.hovered = true
        else
            if self.hovered then
                self.entity:dispatch('onMouseExit', self)
            end
            self.hovered = false
        end
    end
end

function gui.button:touched(touch, hit)
    if not self.disabled then
        if touch.moving then
            return false
        end
        
        if touch.began then
            self.cantMove = nil
        end
        
        if touch.began and  (mouse and touch.type ~= touch.pointer) then
            local currentEntity = self.entity
            repeat
                currentEntity = currentEntity.parent
                if currentEntity:has(gui.scrollArea) then

                    self.cantMove = true
                    break
                end
            until currentEntity == self.scene.canvas.entity 
        end
        
        if touch.began then
            self.pressed = true
            self:updateState()
            return true
        elseif touch.moving then
            if self.cantMove then
                self.pressed = false
                return false
            end
            self.pressed = hit
            self:updateState()
        elseif touch.ended then
            self.pressed = false
            self:updateState()
            if hit then
                self.entity:dispatch('onTapped', self)
            end
        end
    end
        
    return true
end

function gui.selectButton(enti)
    for k, ent in ipairs(enti.parent.children) do
        if ent.id ~= enti.id and ent:has(gui.button) then
            ent:get(gui.button).selected = false
        end
    end
    enti:get(gui.button).selected = true
    enti:get(gui.button):updateState()
end
