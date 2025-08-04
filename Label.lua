gui.label = class('gui.label')

function gui.label:created(shouldFit, fitAxis)
    
    self.text = ""
    self.fontSize = 32
    self.color = color(255)
    self.align = CENTER|MIDDLE
    self.style = 0
    self.shadowOffset = vec2(1, 1)
    self.shadowSoftner = 5
    --self.shadowColor = color(37, 24, 23, 72)
    self.borderWidth = 0
    self.borderColor = color(0,0)
    self.font = "ArialMT"

    --self.entity.sprite = asset.Square
    --self.entity.color = color(59)
    
    self.shouldFit = shouldFit
    self.fitAxis = gui.horizontal | gui.vertical

    
    self.truncate = false
    self.truncatePadding = 0
end

function gui.label:computeSize()
    if self.shouldFit then
        local w, h = self:getSize(self.text)
        local size = self.entity.size
        if self.fitAxis  & gui.vertical == gui.vertical then
            size.x = w
        end
        if self.fitAxis  & gui.vertical == gui.vertical then
            size.y = h
        end
        self.entity.size = size
    end
end

function gui.label:getSize(txt)
    style.fontSize(self.fontSize)
    style.textAlign(self.align).textStyle(self.style)
    style.strokeWidth(self.borderWidth).stroke(self.borderColor)
    style.textAlign(self.align)
    style.font(self.font)
        
    return textSize(txt)
    
end

function gui.label:draw()
    if self.entity.visible then
        style.fontSize(self.fontSize)
        style.fill(self.color )
        style.textAlign(self.align).textStyle(self.style)
        
        
        if self.font then style.font(self.font) end
        if self.shadowColor then
            style.textShadow(self.shadowColor).textShadowOffset(self.shadowOffset).textShadowSoftner(self.shadowSoftner)
        else
            style.noTextShadow()
        end
        
        style.strokeWidth(self.borderWidth).stroke(self.borderColor)
        if self.borderWidth == 0 then
            style.stroke(self.color)
        end
        style.textAlign(self.align)
        
        if self.truncate then
            text(self:cutToFit(self.text), 0, 0, self.entity.size:unpack())
        else
            text(self.text, 0, 0, self.entity.size:unpack())
        end
    end
end

function gui.label:setStyle(lis)
    for k, v in pairs(lis) do
        self[k] = v
    end
end

function gui.label:cutToFit(name)
    local w = textSize(name)
    
    local frameWidth = self.entity.size.x - self.truncatePadding
    
    if w <= frameWidth then
        return name
    end

    if self.oldSize ~= frameWidth then
    
        local ellipsis = "..."
        local ellipsisWidth = textSize(ellipsis)
            
        local truncatedText = name 
            
        while textSize(truncatedText) + ellipsisWidth > frameWidth do 
            truncatedText = truncatedText:sub(1, -2) -- Remove the last character 
        end
        self.truncatedString = truncatedText .. ellipsis
        
        self.oldSize = self.entity.size.x - self.truncatePadding
    end
        
    
    return self.truncatedString
end

Profiler.wrapClass(gui.label)