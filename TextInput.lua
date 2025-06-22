if not gui then
    gui = {}
end    

gui.textInput = class("gui.textInput")

function gui.textInput:created(x)
    self.entity.hitTest = true
    self.entity.hoverTest = true
    
    self.padding = vec2(5)
    
    self.textArea = self.entity:child("textArea")
    self.textArea.size = self.entity.size - self.padding * 2
    
    self.textObject = self.textArea:child("label")
    self.textObject.size = self.entity.size 
    self.label = self.textObject:add(gui.label, true)
    --self.textObject.size = self.entity.size
    self.textObject.pivot = vec2(0, 0.5)
    self.textArea.clip = true
    
    self.style = {
        cursorFlickerColor = color(117, 214, 226),
        cursorSelectColor = color(117, 194, 226,   86),
        selectedColor = color(101),
        normalColor = color(128),
        hoverColor = color(137),
        hoverSelectedColor = color(148),
        typingColor = color(255),
        placeHolderColor = color(203, 206, 207)
    }
    
    self.textAlign = CENTER
    self.typingText = ""
    self.oldTypingText = ""
    self.placeHolderText = "Enter your name:"
    
    self.textObject:anchor(self.textAlign, MIDDLE)
    
    self.isTyping = false
    self.beginSelect = false
    
    self.cursor = self.textArea:child("cursor")
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
    
    self.canEdit = true
end

function gui.textInput:start()
    self.oldTypingText = self.typingText
    self.cursorSize = vec2(3, self.entity.size.y - 2* self.padding.y)
    self.cursor.size = vec2(self.cursorSize:unpack())
    self.textObject:anchor(self.textAlign, MIDDLE)
    self:update()
end

function gui.textInput:getChar(num)
    style.fontSize(self.label.fontSize)
    style.textAlign(self.label.align).textStyle(self.label.style)
    style.strokeWidth(self.label.borderWidth).stroke(self.label.borderColor)
    style.textAlign(self.label.align)
    style.font(self.label.font)
    
    local lastText = string.sub(self.typingText, 1, num-1)
    
    local w, h = textSize(lastText)
    
    
    local currentChar = string.sub(self.typingText, 1, num)
    
    local cW, cH = textSize(currentChar)
    
    local x = self.textObject.worldPosition.x + w
    local y = self.textObject.worldPosition.y + h
    
    return vec2(x, y), vec2(cW-w, cH-h)
end

function gui.textInput:whichChar(pos)
    local charPos = 0
    for k = 1, #self.typingText do
        local p, size = self:getChar(k)
        local nP, nSize = self:getChar(k+1)
        
        if k == 1 and pos.x < p.x + size.x/2 then
            charPos = 0
            break
        end
      
        if k == #self.typingText then
            if p.x + size.x/2 <= pos.x then
                charPos = k
            end
        else
            if p.x + size.x/2 <= pos.x  and pos.x <= nP.x + nSize.x /2 then
                charPos = k
                break
            end
        end
end

return charPos
end

function gui.textInput:willDeselect()
    if self.charPos ~= nil and ((CurrentTouch.began and not gui.wasTouched(self.entity)) or gui.textInput.selectedEntity ~= self.entity) then
        self.charPos = nil
        gui.textInput.selectedEntity = nil
        self.entity:dispatch("onDeselect", self.typingText, self.oldTypingText, class)
    end
    
    print(self.charPos)
  
end

function gui.textInput:update()
    self:checkHover()
    self:handleState()
    
    self.isTyping = false
    if self.charPos then self.isTyping  = true end
    if self.charPos then
        self:handleCursor()
        self:handleKeyboard()
        self:willDeselect()
    else
        if gui.textInput.selectedEntity and not gui.textInput.selectedEntity.valid then
            gui.textInput.selectedEntity = nil
        end
        self.cursor.active = false
    end
    
    self.textObject:anchor(self.textAlign, MIDDLE)
    self.textArea.size = self.entity.size - self.padding * 2
    self:displayText()
end

        
function gui.textInput:checkHover()
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

function gui.textInput:layout()
   
    
    if self.charPos then
        self:handleMoveOut()
    end
    self:repositionText()
end

function gui.textInput:displayText()
    if #self.typingText ~= 0 then
        self.label.text = self.typingText
        self.label.color = self.style.typingColor
    else
        self.label.text = self.placeHolderText
        self.label.color = self.style.placeHolderColor
    end
end

function gui.textInput:handleState()
    self.entity.color = ((self.charPos ~= nil and self.hovered) and self.style.hoverSelectedColor) or (self.charPos ~= nil and self.style.selectedColor) or (self.hovered and self.style.hoverColor) or self.style.normalColor
end

function gui.textInput:handleMoveOut()
    local p, s = self:getChar(self.charPos)
    if p.x - (self.entity.worldPosition.x + self.entity.size.x - s.x) > -self.padding.x then
        local offset = p.x - (self.entity.worldPosition.x + self.entity.size.x - s.x - self.padding.x)
        self.textObject.x = self.textObject.x - offset -  self.cursorSize.x/2
    end
    p, s = self:getChar(self.charPos + 1)
    if p.x - self.entity.worldPosition.x < self.padding.x then
        local offset = p.x - self.entity.worldPosition.x - self.padding.x
        self.textObject.x = self.textObject.x - offset +  self.cursorSize.x/2
    end
end

function gui.textInput:handleKeyboard()
    if self.futurePressedTime and self.futurePressedTime <= time.elapsed then
        self.canType = true
        self.futurePressedTime = self.futurePressedTime + self.pressedOffset
    end
    
    for k, character in pairs(typeCharactersList) do   
        self:canPress(k,function()
            local char = (key.modifiers(key.shift) > 0 and key.modifiers(key.shift)&key.shift  == key.shift) and character[2] or character[1]
            
            if self.endCharPos and key.modifiers(key.cmd)&key.cmd  == key.cmd and (k == "c" or k == "x") then
                self:copyText()
                if k == "x" then
                    self:deleteText()
                end
                return
            end
            
            if key.modifiers(key.cmd)&key.cmd  == key.cmd and k == "v" then
                self:pasteText()
                return
            end
            
            if self.endCharPos then
                self:deleteText()
            end
            
            local back = string.sub(self.typingText, 1, self.charPos)
            local front = string.sub(self.typingText, self.charPos+1, #self.typingText)
            self.typingText = back..char..front
            self.charPos = self.charPos + 1
            self.entity:dispatch('onTextChanged', self.typingText)
        end)
    end
    
    self:canPress("backspace",function()
        self:deleteText()
        self.entity:dispatch('onTextChanged', self.typingText)
    end)
   
    
    
    self:canPress("delete",function()
        if self.charPos ~= #self.typingText then

            if self.endCharPos then
                self:deleteText()
                return
            end
            local back = string.sub(self.typingText, 1, self.charPos)
            local front = string.sub(self.typingText, self.charPos+2, #self.typingText)
            
            local p, s = self:getChar(self.charPos)
            
            self.typingText = back..front
            self.charPos = self.charPos
            self.entity:dispatch('onTextChanged', self.typingText)
        end
    end)
    
    self:canPress("enter",function()
        self:deselect()
        self.entity:dispatch('onEnter', self.typingText, self.oldTypingText)
    end)
    
    self:canPress("esc",function()
        self:deselect()
        self.entity:dispatch('onEscape', self.typingText)
        self.typingText = self.oldTypingText
    end)
    
    self:canPress("left",function()
        if self.endCharPos then
            local beginPos, endPos = self:getSelectNumbers()
            self.charPos = beginPos
            self.endCharPos = nil
        else
            self.charPos = self.charPos-1
            if self.charPos < 0 then
                self.charPos = 0
            end 
        end
    end)
    
    self:canPress("right",function()
        if self.endCharPos then
            local beginPos, endPos = self:getSelectNumbers()
            self.charPos = endPos
            self.endCharPos = nil
        else
            self.charPos = self.charPos+1
            if self.charPos > #self.typingText then
                self.charPos = #self.typingText
            end
        end
    end)
   
    
    self.canType = false
end

function gui.textInput:pasteText()
    local paste = objc.UIPasteboard.generalPasteboard_()
    if self.endCharPos then
        self:deleteText()
    end
    local back = string.sub(self.typingText, 1, self.charPos)
    local front = string.sub(self.typingText, self.charPos+1, #self.typingText)
    self.typingText = back..paste.string..front
    self.charPos = self.charPos + #paste.string
end

function gui.textInput:copyText()
    local beginPos, endPos = self:getSelectNumbers()
    local str = string.sub(self.typingText, beginPos + 1, endPos)
    local paste = objc.UIPasteboard.generalPasteboard_()
    paste.string = str
end

function gui.textInput:deleteText()
    if self.charPos ~= 0 or self.endCharPos ~= nil then
        local back, front = self:backSpaceValues()
        
        local p, s = self:getChar(self.charPos)
        
        self.typingText = back..front
        
        --self.textObject.x = self.textObject.x + s.x
    end
end

function gui.textInput:backSpaceValues()
    local back = nil
    local front = nil
    if self.endCharPos == nil then
        back = string.sub(self.typingText, 0, self.charPos-1)
        front = string.sub(self.typingText, self.charPos+1, #self.typingText)
        self.charPos = self.charPos-1
    else
        local beginPos, endPos = self:getSelectNumbers()
        back = string.sub(self.typingText, 1, beginPos)
        front = string.sub(self.typingText, endPos+1, #self.typingText)
        self.charPos = beginPos
        self.endCharPos = nil
    end
    return back, front
end

function gui.textInput:canPress(keyName, extraFunction)
    if key.wasPressed(key[keyName]) or (key.pressing(key[keyName]) and self.canType)then
        if key.wasPressed(key[keyName]) then
            self.futurePressedTime = time.elapsed + self.pressedFirstOffset
        end
        
        extraFunction()
        self.startFlickerTime = time.elapsed
        self.shouldReposition = true
    end
end

function gui.textInput:repositionText()
    --local p, s = self:getChar(self.charPos)
  
    if self.textObject.size.x >  self.textArea.size.x then
        if self.textObject.worldPosition.x > self.textArea.worldPosition.x + self.cursor.size.x/2  then
            self.textObject.x = self.textObject.x - (self.textObject.worldPosition.x - self.textArea.worldPosition.x) + self.cursorSize.x/2 
        end
        if self.textObject.worldPosition.x + self.textObject.size.x < self.textArea.worldPosition.x + self.textArea.size.x then
            self.textObject.x = self.textObject.x + ((self.textArea.worldPosition.x + self.textArea.size.x )- (self.textObject.worldPosition.x + self.textObject.size.x)) - self.cursorSize.x/2 
        end
        
    else
        if self.textAlign == LEFT then
            self.textObject.x = self.cursorSize.x/2 
        elseif self.textAlign == CENTER then
            self.textObject.x = -self.textObject.size.x/2
        elseif self.textAlign == RIGHT then
            self.textObject.x = -self.textObject.size.x - self.cursorSize.x/2 
        end
    end
end


function gui.textInput:handleCursor()
    if self.endCharPos == nil then
        self:handleFlicker()
    else
        self:handleSelect()
    end
end

function gui.textInput:handleSelect()
    local beginPos, endPos = self:getSelectNumbers()  
    self.cursor.active = true

    local bPos, bSize = self:getChar(beginPos+1)
    if beginPos == 0 then
        bPos, bSize = vec2(self.textObject.worldPosition.x,0), vec2(0)
    end
    self.cursor.color = self.style.cursorSelectColor
    local ePos, eSize = self:getChar(endPos)
    
    local selectSize = (ePos.x + eSize.x) - bPos.x
    
    self.cursor.size = vec2(selectSize, self.cursorSize.y)
    local x = bPos.x + self.cursor.size.x/2
    self.cursor.worldPosition =  vec3(x,self.cursor.worldPosition.y, 0) + vec3(0, self.cursor.size.y/2, 0)
end

function gui.textInput:getSelectNumbers()
    local beginPos, endPos = self.beginCharPos, self.endCharPos
    if endPos then
        if beginPos > endPos then
            local hold = endPos
            endPos = beginPos
            beginPos = hold
        end
    end
    return beginPos, endPos
end

function gui.textInput:deselect()
    self.charPos = nil
    self.beginCharPos = nil
    self.endCharPos = nil
end

function gui.textInput:handleFlicker()
    local timeOffset = time.elapsed - self.startFlickerTime
    
    self.cursor.color = self.style.cursorFlickerColor
    self.cursor.size = self.cursorSize
    self.cursor.active = math.floor(timeOffset / self.flickerOffset) % 2 == 0
    if self.charPos == 0 then
        local sX, sY = (self.cursor.size/2):unpack()
        self.cursor.worldPosition = vec3(self.textObject.worldPosition.x -  self.cursorSize.x/2,self.cursor.worldPosition.y, 0) + vec3(self.cursor.size.x/2, sY, 0)
        
        if #self.typingText == 0 then
           if self.textAlign == CENTER then
                self.cursor.worldPosition = vec3(self.textObject.worldPosition.x + self.textObject.size.x/2,self.cursor.worldPosition.y, 0) + vec3(self.cursor.size.x/2, sY, 0)
            elseif self.textAlign == RIGHT then
                self.cursor.worldPosition = vec3(self.textObject.worldPosition.x + self.textObject.size.x -  self.cursorSize.x/2,self.cursor.worldPosition.y, 0) + vec3(self.cursor.size.x/2, sY, 0)
            end
        end
    else
        local pos, size = self:getChar(self.charPos)
        local x = pos.x + size.x
        local sX, sY = (self.cursor.size/2):unpack()
        self.cursor.worldPosition = vec3(x,self.cursor.worldPosition.y, 0) + vec3(0, sY, 0)
    end
end

function gui.textInput:touched(touch)
    local scal = self.entity.scene.canvas.scale
    if self.canEdit then 
        if touch.type == touch.pointer then
            self.startFlickerTime = time.elapsed
            gui.textInput.selectedEntity = self.entity
            if touch.began and self.charPos == nil then
                self.oldTypingText = self.typingText
                self.entity:dispatch('onTapped')
            end
            
            if touch.began then
                if self.beginSelect and self.charPos == nil and self.typingText ~= "" then
                    self.charPos = 0
                    self.beginCharPos = 0
                    self.endCharPos = #self.typingText
                    self.saveCharPos = self.charPos
                    self.lastTouchTime = time.elapsed
                    return true
                end
                
                
                if self.lastTouchTime == nil or time.elapsed - self.lastTouchTime > self.touchOffsetTime then
                    self.numTaps = 1
                else
                    self.numTaps = self.numTaps +1
                end
                
                
                self.charPos = self:whichChar(touch.pos * scal)
                self.isPressing = true
                self.beginCharPos = self.charPos
                self.endCharPos = nil
                
                
                self.lastTouchTime = time.elapsed
                self.isPressing = false
                if self.numTaps >= 3 then
                    self.beginCharPos = 0
                    self.endCharPos = #self.typingText
                elseif self.numTaps == 2 then
                    self:highLightWord()
                end
                
                self.saveCharPos = self.charPos
            end
            if touch.moving and self.charPos then
                self.charPos = self:whichChar(touch.pos * scal)
                self.beginCharPos = self.saveCharPos
                if self.beginCharPos ~= self.charPos then
                    self.endCharPos = self.charPos
                else
                    self.endCharPos = nil
                end
            end
        elseif touch.began then
            self.isTyping = true
            gui.textInput.selectedEntity = self.entity
            self:deselect()
            createAlertBox("Input", self.placeHolderText, function(txt)
                self.typingText = txt
                self.entity:dispatch('onEnter', self.typingText, self.oldTypingText )
                gui.textInput.selectedEntity = nil
            end)
        end
            
            
        return true
    else
        self:deselect()
    end
end

function gui.textInput:highLightWord()
    local back = string.sub(self.typingText, 0, self.charPos)
    local front = string.sub(self.typingText, self.charPos+1, #self.typingText)
    
    local _, bNum, ext = string.find(front, "(%W*)%w*")
    local endN, ei, ext2 = string.find(back, "%w-(%W*)$")
    
    self.beginCharPos = endN - 1
    self.endCharPos = bNum + self.charPos
    
    if ext ~= "" then
        self.endCharPos = self.charPos
        return
    end
    
    if ext == "" and ext2 ~= "" then
        self.beginCharPos = self.charPos 
        return
    end
end

local lowerCase = "qwertyuiopasdfghjklzxcvbnm"
local upperCase = "QWERTYUIOPASDFGHJKLZXCVBNM"
typeCharactersList = {}
for k = 1, #lowerCase do
    typeCharactersList[string.sub(lowerCase,k,k)] = {string.sub(lowerCase,k,k), string.sub(upperCase,k,k)}
end
typeCharactersList["space"] = {" ", " "}

for k = 1, #lowerCase do
    typeCharactersList[string.sub(lowerCase,k,k)] = {string.sub(lowerCase,k,k), string.sub(upperCase,k,k)}
end

otherList = {
    num1 = {"1", "!"},
    num2 = {"2", "@"},
    num3 = {"3", "#"},
    num4 = {"4", "$"},
    num5 = {"5", "%"},
    num6 = {"6", "^"},
    num7 = {"7", "&"},
    num8 = {"8", "*"},
    num9 = {"9", "("},
    num0 = {"0", ")"},
    minus = {"-", "_"},
    plus = {"=", "+"},
    leftbracket = {"[", "{"},
    rightbracket = {"]", "}"},
    backslash = {"\\", "|"},
    semicolon = {";", ":"},
    quote = {"'", "\""},
        comma = {",", "<"},
        period = {".", ">"},
        slash = {"/", "?"},
        tilde = {"`", "~"}
}
    
for k, v in pairs(otherList) do
    typeCharactersList[k] = v
end
