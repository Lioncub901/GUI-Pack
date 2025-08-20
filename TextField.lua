if not gui then
    gui = {}
end    

gui.textField = class("textField")

function gui.textField:created(x)
    self.entity.hitTest = true
    
    self.padding = vec2(5)
    
    
    self.label = self.entity:add(gui.paragraph)
    
    --self.textObject.size = self.entity.size
    
    self.style = {
        cursorFlickerColor = color(117, 214, 226),
        cursorSelectColor = color(117, 194, 226,   86),
        pressedColor = color(101),
        selectedColor = color(101),
        normalColor = color(128),
        typingColor = color(255),
        placeHolderColor = color(203, 206, 207)
    }
    
    self.textAlign = CENTER
self.typingText = [[Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.]]
    self.oldTypingText = ""
    self.placeHolderText = "Enter your name:"
    
self.label.text = self.typingText
    
    self.isTyping = false
    
    self.cursor = self.entity:child("cursor")
    self.cursorSize = vec2(3, self.entity.size.y - 2* self.padding.y)
    self.cursor.size = vec2(self.cursorSize:unpack())
    self.cursor.sprite = asset.Square
    self.cursor.color = self.style.cursorFlickerColor
    
    self.flickerOffset = 0.4
    self.startFlickerTime = nil
    
    self.pressedFirstOffset = 0.5
    self.pressedOffset = 0.05
    self.canType = false
    self.futurePressedTime = nil
    self.shouldReposition = false
    
    self.beginCharPos = nil
    self.endCharPos = nil
    
    self.lastTouchTime = num
    self.touchOffsetTime = 0.35
    self.numTaps = 0
    --self.offsetInside
    
    self.isPressing = false
    self.charPos = nil

    self.lines = {}
    self:breakLines()
end

function gui.textField:breakLines()
    self:loadStyle()
    
    self.lines = {}
    local currentLine = ""
    local currentPos = 1
    local numText = #self.typingText
    
    -- Debug: Ensure we're splitting the text properly
    print("Text to break:", self.typingText)
    
    -- Loop through the text manually and break by spaces and words
    while currentPos <= numText do
        -- Find the next word or space
        local word, space = self.typingText:match("(%S+)(%s*)", currentPos)
        
        if word then
            -- If we have a word, check if it fits in the line
            local testLine = currentLine .. word
            local width = textSize(testLine)
            
            if width > self.entity.size.x then
                -- If it doesn't fit, start a new line
                table.insert(self.lines, currentLine)
                currentLine = word
            else
                -- If it fits, add the word to the current line
                currentLine = testLine
            end
            
            -- Move the position after the word
            currentPos = currentPos + #word
        end
        
        if space then
            -- If we have a space, add it to the current line as well
            local testLine = currentLine .. space
            local width = textSize(testLine)
            
            if width > self.entity.size.x then
                -- If it doesn't fit, start a new line
                table.insert(self.lines, currentLine)
                currentLine = space
            else
                -- If it fits, add the space to the current line
                currentLine = testLine
            end
            
            -- Move the position after the space
            currentPos = currentPos + #space
        end
    end
    
    -- Add the last line if it's not empty
    if currentLine ~= "" then
        table.insert(self.lines, currentLine)
    end
    
    -- Debug: Output the result
    print("Lines:", #self.lines)
    print("Content:\n" .. table.concat(self.lines, "\n"))
end

function gui.textField:getChar(num)
    self:loadStyle()
    local lastText = string.sub(self.typingText, 1, num-1)
    
    local w, h = textSize(lastText)
    
    
    local currentChar = string.sub(self.typingText, 1, num)
    
    local cW, cH = textSize(currentChar)
    
    local x = self.textObject.worldPosition.x + w
    local y = self.textObject.worldPosition.y + h
    
    return vec2(x, y), vec2(cW-w, cH-h)
end



function gui.textField:loadStyle()
    style.fontSize(self.label.fontSize)
    style.textAlign(self.label.align).textStyle(self.label.style)
    style.strokeWidth(self.label.borderWidth).stroke(self.label.borderColor)
    style.textAlign(self.label.align)
    style.font(self.label.font)
end

function gui.textField:touched(touc)
    local touch = gui.mapTouchToScene(touc, self.scene)
    -- Codea does not automatically call this method
end
