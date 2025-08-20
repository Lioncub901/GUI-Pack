if not gui then
    gui = {}
end    

--colorspace(GAMMA)
gui.colorPicker = class("colorPicker")

function gui.colorPicker:created(col)
    -- you can accept and set parameters here
    

    self.pickerShape = nil
    self.hueShape = nil
    self.alphaShape = nil
    self.hexInput = nil
    self.isEditing = false
    self.didStart = false
    self.color = col
end

function gui.colorPicker:start()
    if not self.didStart then
        self.hueShapeClass = self.hueShape:get(gui.hueSlider)
        self.pickerShapeClass = self.pickerShape:get(gui.pickerBox)
        if self.alphaShape then
            self.alphaShapeClass = self.alphaShape:get(gui.alphaSlider)
        end
        if self.hexInput then
            self.hexInputClass = self.hexInput:get(gui.hexInput)
            
            
            self.hexInput.onEnter = function(enti, currStr, oldStr)
                if string.find(currStr, "^#") == nil then
                    currStr = "#" .. currStr
                end
                currStr = string.upper(currStr)
                if isValidHexColor(currStr) then
                    local r,g,b,a = hexToRGBA(currStr)
                    local h, s, v = rgbToHSV(r,g,b)
                    
                    self.hueShapeClass.hue = h 
                    self.pickerShapeClass.value = v 
                    self.pickerShapeClass.saturation = s
                    self.alphaShapeClass.alpha = a / 255
                    self.hexInputClass.input.typingText = currStr
                end
                self.hexInputClass.input.typingText = oldStr
            end
            
            self.hexInput.onDeselect = function(enti, currStr, oldStr)
                --self.hexInputClass.input.typingText = oldStr
            end
        end
        self.didStart = true
    end
end

function gui.colorPicker:update()
    local col = self.pickerShapeClass.color
    if self.hexInput then
        col = color(col.r, col.g, col.b)
        self.hexInputClass.input.style.selectedColor = col
        self.hexInputClass.input.style.normalColor = col
        self.hexInputClass.input.style.hoverColor = col
        self.hexInputClass.input.style.hoverSelectedColor = col
        
        if not self.hexInputClass.input.isTyping then
            if self.alphaShapeClass then
                self.hexInputClass.input.typingText = rgbToHEX(col.r, col.g, col.b, math.floor(255 * self.alphaShapeClass.alpha))
            else
                self.hexInputClass.input.typingText = rgbToHEX(col.r, col.g, col.b)
            end
        end
    end
    
    if self.hueShape and self.pickerShape then
        self.pickerShapeClass.hue = self.hueShapeClass.hue
        col = color(col.r, col.g, col.b)
        self.color = col
        self.color.a = 255
    end
    
    if self.alphaShape then
        col = color(col.r, col.g, col.b)
        self.alphaShapeClass.color = col
        self.color.a = 255 * self.alphaShapeClass.alpha
        
        if key.wasPressed(key.k) then
            self.alphaShapeClass.alpha = 0.5
        end
    end
    
    self.isEditing = self.hueShapeClass.isEditing or self.alphaShapeClass.isEditing or self.pickerShapeClass.isEditing or self.hexInputClass.input.isTyping
end

function gui.colorPicker:setColor(col)
    local h, s, v = rgbToHSV(col.r, col.g, col.b)
    self.hueShapeClass.hue = h 
    self.pickerShapeClass.value = v 
    self.pickerShapeClass.saturation = s
    self.alphaShapeClass.alpha = col.a / 255
    self.pickerShapeClass.color = color(col.r, col.g, col.b)
end


gui.pickerBox = class("saturationValueBox")


function gui.pickerBox:created(x)
    self.entity.hitTest = true
    self.hue = 0
    self.saturation = 100
    self.value = 100
    self.pickerShader = rectPickShader()
    
    self.color = color(255)
    
    self.cursorPos = self.entity.size
    self.pickerDiameter = 15.5
    self.isEditing = false
end

function gui.pickerBox:draw()
    sprite(self.pickerShader, 0,0, self.entity.size.x, self.entity.size.y)
    
    self.hsv = vec3(self.hue, self.saturation, (self.cursorPos.y / self.entity.size.y) * 100)
    self.color = color(hsvToRGB(self.hsv:unpack()))
    
    
    style.stroke(255).strokeWidth(2.5).shapeMode(CENTER).fill(self.color)
    ellipse(self.cursorPos,self.pickerDiameter)
end

function gui.pickerBox:update()
    self.cursorPos.x = (self.saturation / 100) * self.entity.size.x
    self.cursorPos.y = (self.value / 100) * self.entity.size.y
    self.pickerShader.hue = self.hue
end

function gui.pickerBox:touched(touc)
    local touch = gui.mapTouchToScene(touc, self.scene)
    if touch.began then
        self.isEditing = true
    elseif touch.ended then
        self.isEditing = false
    end
            
    
    self.cursorPos = touch.pos - vec2(self.entity.worldPosition.x, self.entity.worldPosition.y)
    if self.cursorPos.x > self.entity.size.x then
        self.cursorPos.x = self.entity.size.x
    elseif self.cursorPos.x < 0 then
        self.cursorPos.x = 0
    end
    
    if self.cursorPos.y > self.entity.size.y then
        self.cursorPos.y = self.entity.size.y
    elseif self.cursorPos.y < 0 then
        self.cursorPos.y = 0
    end
    
    self.saturation = (self.cursorPos.x / self.entity.size.x) * 100
    self.value = (self.cursorPos.y / self.entity.size.y) * 100
    return true
end

gui.hueSlider = class("hueSlider")

function gui.hueSlider:created(x)
    self.entity.hitTest = true
    self.hue = 0

    self.hueShader = hueSliderShader()
    
    self.cursorPos = self.entity.size.y
    self.pickerHeight = 12
    self.isEditing = false
end

function gui.hueSlider:draw()
    sprite(self.hueShader, 0,0, self.entity.size.x, self.entity.size.y)
    
    local hsv = vec3(self.hue, 100, 100)
    local col = color(hsvToRGB(hsv:unpack()))
    
    style.stroke(255).strokeWidth(2.5).shapeMode(CENTER).fill(col)
    rect(self.entity.size.x/2,self.cursorPos,self.entity.size.x, self.pickerHeight)
end

function gui.hueSlider:update()
    
    self.cursorPos =  (1-(self.hue/360)) *  self.entity.size.y
end

function gui.hueSlider:touched(touc)
    local touch = gui.mapTouchToScene(touc, self.scene)
    if touch.began then
        self.isEditing = true
    elseif touch.ended then
        self.isEditing = false
    end
    
    self.cursorPos = touch.y - self.entity.worldPosition.y
    
    if self.cursorPos > self.entity.size.y then
        self.cursorPos = self.entity.size.y
    elseif self.cursorPos < 0 then
        self.cursorPos = 0
    end
    
    self.hue = (1-(self.cursorPos/self.entity.size.y)) * 360
    return true
end

gui.alphaSlider = class("alphaSlider")

function gui.alphaSlider:created(x)
    self.entity.hitTest = true
    self.alpha = 1
    
    self.alphaShader = alphaSliderShader()
    self.alphaShader:pass(1).blendMode = NORMAL
    
    self.cursorPos = self.entity.size.y
    self.pickerHeight = 12
    
    self.color = color(255, 14, 0)
    self.isEditing = false
    
    self.checkerImg = createCheckerboardTexture(self.entity.size, 8)
end

function gui.alphaSlider:draw()
    self.cursorPos = self.alpha * self.entity.size.y
    style.shapeMode(CORNER).tint(255)
    sprite(self.checkerImg, 0, 0, self.entity.size.x, self.entity.size.y)
    
    sprite(self.alphaShader, 0,0, self.entity.size.x, self.entity.size.y)
    
    style.stroke(255).strokeWidth(2.5).shapeMode(CENTER).fill(self.color)
    rect(self.entity.size.x/2,self.cursorPos,self.entity.size.x, self.pickerHeight)
end
    

function gui.alphaSlider:update()
    self.cursorPos = self.alpha * self.entity.size.y
    self.color.a = self.alpha* 255
    self.alphaShader.mColor = self.color
end

function gui.alphaSlider:touched(touc)
    local touch = gui.mapTouchToScene(touc, self.scene)
    if touch.began then
        self.isEditing = true
    elseif touch.ended then
        self.isEditing = false
    end
    
    self.cursorPos = touch.y - self.entity.worldPosition.y
    
    if self.cursorPos > self.entity.size.y then
        self.cursorPos = self.entity.size.y
    elseif self.cursorPos < 0 then
        self.cursorPos = 0
    end
    
    self.alpha = self.cursorPos / self.entity.size.y
    return true
end


function createCheckerboardTexture(size, checkerSize)
    local ima = image(size.x, size.y)
    
    for x = 1, size.y do
        for y = 1, size.y do
            local xCheck = math.floor(x / checkerSize) % 2
            local yCheck = math.floor(y / checkerSize) % 2
            if (xCheck + yCheck) % 2 == 0 then
                ima:setPixel(x, y, color(200, 200, 200)) -- Light square
            else
                ima:setPixel(x, y, color(100, 100, 100)) -- Dark square
            end
        end
    end
    ima:apply()
    return ima
end

gui.hexInput = class("hueSlider")

function gui.hexInput:created(x)
   self.input = self.entity:add(gui.textInput)
    self.input.style.typingColor = color(255)
    self.input.typingText = "FFFFFF"
    --[=[self.input.label.shadowColor = color(0, 138)
    self.input.label.shadowOffset = vec2(3)
    self.input.label.shadowSoftner = 8]=]
    self.input.padding = vec2(3)
    self.input.placeHolderText = ""
    self.input.label.font = "Futura"
    self.input.label.fontSize = 25
    self.input.label.borderWidth = 2
    self.input.label.borderColor = color(0)
end

--------------

function isValidHexColor(input)
    -- Check if the input matches RGB, RGBA, RRGGBB, or RRGGBBAA patterns
    return 
    string.match(input, "^#%x%x%x%x%x%x$") ~= nil or -- #RRGGBB
    string.match(input, "^#%x%x%x%x%x%x%x%x$") ~= nil -- #RRGGBBAA
end

function hexToRGBA(hex)
    -- Remove the '#' if present
    hex = hex:gsub("#", "")
    
    -- Check if the hex code is valid (either 6 or 8 characters long)
    if #hex ~= 6 and #hex ~= 8 then
        return nil, "Invalid hex color"
    end
    
    
    -- Extract the RGB(A) components
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    local a = (#hex == 8) and tonumber(hex:sub(7, 8), 16) or 255 -- Default alpha is 255 (opaque)
    
    return r, g, b, a
end

function rgbToHEX(r,g,b,a)
    if a == nil then
        return string.format("#%02X%02X%02X", r,g,b)
    end
    return string.format("#%02X%02X%02X%02X", r,g,b, a)
end

function hsvToRGB(h, s, v)
    -- Normalize inputs
    h = h % 360                 -- Ensure hue is within 0–360 degrees
    s = math.min(100, math.max(0, s)) / 100 -- Normalize saturation to 0–1
    v = math.min(100, math.max(0, v)) / 100 -- Normalize value to 0–1
    
    local c = v * s    -- Chroma
    local x = c * (1 - math.abs((h / 60) % 2 - 1)) -- Second largest component
    local m = v - c    -- Match value
    
    local r, g, b
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    
    -- Adjust with m to match the value range
    r, g, b = (r + m) * 255, (g + m) * 255, (b + m) * 255
    
    -- Return RGB values as integers
    return math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5)
end

function rgbToHSV(r, g, b)
    -- Normalize RGB values to the range [0, 1]
    r, g, b = r / 255, g / 255, b / 255
    
    -- Find the maximum and minimum values among r, g, b
    local maxVal = math.max(r, g, b)
    local minVal = math.min(r, g, b)
    local delta = maxVal - minVal
    
    -- Calculate Hue
    local h
    if delta == 0 then
        h = 0 -- Undefined hue
    elseif maxVal == r then
        h = (60 * ((g - b) / delta) + 360) % 360
    elseif maxVal == g then
        h = (60 * ((b - r) / delta) + 120) % 360
    elseif maxVal == b then
        h = (60 * ((r - g) / delta) + 240) % 360
    end
    
    -- Calculate Saturation
    local s = (maxVal == 0) and 0 or (delta / maxVal)
    
    -- Calculate Value
    local v = maxVal
    
    -- Return HSV values
    return h, s * 100, v * 100 -- Saturation and Value as percentages
end