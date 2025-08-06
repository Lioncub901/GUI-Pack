if not gui then
    gui = {}
end 

gui.menuButton = class("gui.menuButton")

function gui.menuButton:created(styleFunc, baseStyleFunc)
    -- you can accept and set parameters here
    if not self.entity:has(gui.button) then
        self.entity:add(gui.button)
    end
    
    self.styleFunction = styleFunc or self:defaultStyle()
    self.baseStyleFunction = baseStyleFunc or self:defaultBaseStyle()
    
    self.dropActive = true
    self.selectedElement = nil

    self.openTime = 0.2
    self.closeTime = 0.07

    
end

function gui.menuButton:addList(list)
    self.dropList = list
    self:addDropArea(self.entity, list) 
end

function gui.menuButton:refreshList()
    self.entity:fakeChildAt(1):destroy()
    self:addDropArea(self.entity, self.dropList) 
end

function gui.menuButton:addDropArea(parent, list)
    local area = self.baseStyleFunction(parent,list, self)
    
    for k, item in ipairs(list) do 
        local element = self.styleFunction(item, self)
        item.entity = element
        element.parent = area
        if item.children then
            self:addDropArea(element, item.children)
        end
    end
    area.active = false
end

function gui.menuButton:update()
    if self.dropActive then
        self.entity:fakeChildAt(1).active = true
        self.entity:get(gui.button):select(true)
        if self:notSelected() then
            self.dropActive = false
        end
        
        if self.selectedElement and self.checkDeselecting and (time.elapsed - self.deselectingTime) >= self.closeTime then
            local element = self.selectedElement
            local butto = element:get(gui.button)
            if element == self:getSelectedElement() and not butto.hovered and not self:dropHovered() then
                if element.fakeChildren then
                    element:fakeChildAt(1).active = false
                end
                butto:select(false)
            end
        end
    else
        if self.selectedElement ~= nil then
            local parentList = self:getParentList(self.selectedElement)
            for k, currEnti in ipairs(parentList) do
                if currEnti == self.entity then
                    break
                elseif currEnti.fakeParent == nil and currEnti:has(gui.button) then
                    currEnti:get(gui.button):select(false)
                end
            end

            self.selectedElement:get(gui.button):select(false)
        end
        
        
        self.selectedElement = nil
        self.entity:fakeChildAt(1).active = false
        self.entity:get(gui.button):select(false)
    end
    
    
end

function gui.menuButton:notSelected()
    if CurrentTouch.ended then
        self.canTouch = true
    end
    
    if CurrentTouch.began and self.canTouch then
        local enti = gui.insideTest(self.entity.scene, CurrentTouch, "hitTest") 
        if enti then
            local list = self:getParentList(enti)
            if enti.id ~= self.entity.id and list[#list].id ~= self.entity.id then
                return true 
            end
        else
            return true
        end
    end
    return false
end

function gui.menuButton:dropHovered()
    local enti = gui.insideTest(self.entity.scene, mouse, "hoverTest") 
    if enti then
        local list = self:getParentList(enti)
        if list[#list].id == self.entity.id then
            return true 
        end
    end
    return false
end

function gui.menuButton:getParentList(enti)
    local list = {}
    local currEnti = enti
    repeat
        local parentEnti = currEnti.fakeParent or currEnti.parent
        table.insert(list, parentEnti)
        currEnti = parentEnti
    until parentEnti.id == self.entity.id or parentEnti.id == self.entity.scene.canvas.entity.id
    return list
end


function gui.menuButton:isParentOf(parentEnt, enti)
    local currEnti = enti
    repeat
        local parentEnti = currEnti.fakeParent or currEnti.parent
        if parentEnt.id == parentEnti.id then
            return true
        end
        currEnti = parentEnti
    until parentEnti.id == self.entity.id
    return false
end

function gui.menuButton:selectElement(enti, waitOpen)
    self.checkDeselecting = false
        local oldSelected = self.selectedElement
        self.selectedElement = enti
        if self.openTween then
            self.openTween:cancel()
        end
    
        if oldSelected and not self:isParentOf(oldSelected, self.selectedElement)  then
            local parentList = self:getParentList(oldSelected)
            for k, currEnti in ipairs(parentList) do
                if self:isParentOf(currEnti, self.selectedElement) then
                    break
                end
                if currEnti.fakeParent then
                    currEnti.active = false
                elseif currEnti:has(gui.button) then
                    currEnti:get(gui.button):select(false)
                end
            end
            oldSelected:get(gui.button):select(false)
            if oldSelected.fakeChildren then
                oldSelected:fakeChildAt(1).active = false
            end
        end
        
        local parentList = self:getParentList(self.selectedElement)
        
        for k, currEnti in ipairs(parentList) do
            if currEnti.fakeParent == nil and currEnti:has(gui.button) then
                currEnti:get(gui.button):select(true)
            end
        end
        

        self.selectedElement:get(gui.button):select(true)
        if not waitOpen or oldSelected == self.selectedElement or (oldSelected and self:isParentOf(self.selectedElement, oldSelected)) then
            if self.selectedElement.fakeChildren then
                self.selectedElement:fakeChildAt(1).active = true
            end
        else
            self.openTween = tween({}):to{}:time(self.openTime):onComplete(function()
                if enti == self:getSelectedElement() and self.selectedElement.fakeChildren then
                    self.selectedElement:fakeChildAt(1).active = true
                end
            end)
        end
        

end

function gui.menuButton:getSelectedElement()
    return self.selectedElement
end

function gui.menuButton:deselectElement(element)
    self.checkDeselecting = true
    self.deselectingTime = time.elapsed
end

function gui.menuButton:defaultStyle()
    return function(item, area)
        local lab = item.item[1]
        local buttonStyle = {normalColor = color(190, 142, 224), hoverColor = color(169, 82, 230), pressedColor = color(148, 69, 204),selectedColor = color(139, 51, 201)}
        local element = gui.buttonUI(self.scene.canvas, {size = vec2(200,30)}, {sprite = asset.Square, style = buttonStyle})
        
        element.onMouseEnter = function()
            self:selectElement(element, true)
        end
        
        element.onMouseExit = function()
            self:deselectElement(element)
        end
        
        element.onTapped = function()
            self:selectElement(element)
        end

        local work = item.children == nil 
        if work then
            
            --local ent = element:child("fds")
            gui.squareUI(element, {size = vec2(20), layout = {"Right", 10}}, color(255))
            --layout = {"Right", 10}
        end
            
        local labelObject = gui.labelUI(element, {layout = {"Left", 12}, size = vec2(150, 25)}, {text = lab, fontSize = 25, align = LEFT|MIDDLE})
        --labelObject
        return element
    end
end

function gui.menuButton:defaultBaseStyle()
    return function(parent, list, clas)
        self = clas
        local padding = {left = 0, right = 0, top = 10, bottom = 10}
        local area = gui.squareUI(parent, {name = "area", fake = {self.scene.canvas}, size = list.size or 200, pivot = vec2(0,1), vstack = {padding, 0}}, color(128))
        area.hitTest = true
        
        if parent ~= self.entity  then
            area.fy = padding.top
        end
        
        if parent == self.entity then
            area:anchor(LEFT,BOTTOM)
        else
            area:anchor(RIGHT,TOP)
            area.y = padding.top
        end
        return area
    end
end
--local extraImg = gui.imageUI(element, {size = vec2(element.size.y - 15), layout = {"Right", 10}}, asset.DropDownClose)

Profiler.wrapClass(gui.menuButton)