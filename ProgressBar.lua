if not gui then
    gui = {}
end 

gui.progressBar = class("gui.progressBar")

function gui.progressBar:created(axis)
    -- you can accept and set parameters here
    self.entity.hitTest = true
    self.axis = axis or gui.horizontal
    
    self.maxValue = 100
    self.value = currentPercent or 50
    
    
    self.padding = vec2(2)
    
    local place = nil
    if self.axis & gui.horizontal == gui.horizontal then
        place = "Left"
    elseif self.axis & gui.vertical == gui.vertical then
        place = "Bottom"
    end
    
    self.mask = gui.UI(self.entity, {name = "mask", layout = {place}})
    --self.mask.clip = true
    
    self.fill = gui.squareUI(self.mask, {name = "file", layout = {place}})
    self.fill.color = color(255, 0, 0)
end

function gui.progressBar:update()
    self.fill.size = self.entity.size - 2 * self.padding
    
    local r,g,b = self.fill.color:unpack()
    if self.value == 0 then
        self.fill.color = color(r, g, b,0)
    else
        self.fill.color = color(r, g, b,255)
    end
    
    local cutOff = vec2(1)
    if self.axis & gui.horizontal == gui.horizontal then
        self.mask.x = self.padding.x
        cutOff.x = (self.value / self.maxValue)
    elseif self.axis & gui.vertical == gui.vertical then
        self.mask.y = self.padding.y
        cutOff.y = (self.value / self.maxValue)
    end
    
    
    self.mask.size = (self.entity.size - 2 * self.padding) * cutOff
end

function gui.progressBar:touched(touch)
    return true
end
