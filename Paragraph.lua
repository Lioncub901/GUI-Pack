gui.paragraph = class("")

function gui.paragraph:created(x)
    -- you can accept and set parameters here
    
    self.text = ""
    self.fontSize = 32
    self.color = color(255)
    self.style = 0
    self.shadowOffset = vec2(1, 1)
    self.shadowSoftner = 5
    self.shadowColor = color(37, 24, 23, 72)
    self.borderWidth = 0
    self.borderColor = color(0,0)
    self.align = LEFT | MIDDLE
    self.font = "ArialMT"
    
end

function gui.paragraph:update()
end

function gui.paragraph:computeSize()
    style.fontSize(self.fontSize)
    style.textAlign(self.align).textStyle(self.style)
    style.strokeWidth(self.borderWidth).stroke(self.borderColor)
    style.textAlign(self.align)
    style.font(self.font)

    local w, h = textSize(self.text, self.entity.size.x)
    self.entity.size = vec2(self.entity.size.x, h)
end

function gui.paragraph:draw()
    style.fontSize(self.fontSize)
    style.fill(self.color * color(255,255,255, self.entity.color.a))
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
    
    text(self.text, 0, 0, self.entity.size:unpack())
end

function gui.paragraph:setStyle(lis)
    for k, v in pairs(lis) do
        self[k] = v
    end
end