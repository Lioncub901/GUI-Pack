gui.collapse = class('gui.vstack')

function gui.collapse:created(padding, spacing, styleFunction)
    self.styleFunction = styleFunction or self:defaultCollapleStyle()
    self.entity:add(gui.vstack,padding or 0,spacing or 0)
    self.collapseList = {}
    self.shouldClose = true
    
    self.autoClose = false
end

function gui.collapse:addList(list)
    self.collapseList = list
    for k, item in ipairs(list) do 


        item.isLast = self:isLast(k)
        if item.isLast then
            item.isClosed = nil
        end
        if self.shouldClose then
            item.parent = self:getParent(k)
        end
        
        if self.autoClose then
            item.isClosed = true
        end
        --item.temporarilyClosed = nil
        local element = self.styleFunction(item, self, k)
        element.parent = self.entity
        item.entity = element
        --item.entity.active = true
        item.entity.itemNumber = k
    end
end

function gui.collapse:addItem(item, num)
    for k, ite in ipairs(self.collapseList) do
        ite.entity:destroy()
    end
    
    num = self:insertInPosition(item, num)

    self:addList(self.collapseList)
    
    return self.collapseList[num].entity
end

function gui.collapse:itemIsOpen(itemNum)
    local firstDepth = self.collapseList[itemNum].depth
    while itemNum > 0 do
        local item = self.collapseList[itemNum]
        if item.isClosed and item.depth < firstDepth then
            return false
        end
        if item.depth == 1 then
            return true
        end
        itemNum = itemNum - 1
    end
end

function gui.collapse:getChildren(itemNum)
    local children = {}
    local firstDepth = self.collapseList[itemNum].depth
    itemNum = itemNum + 1
    
    local item = self.collapseList[itemNum]
    while item.depth > firstDepth or itemNum > #self.collapseList do
        
        table.insert(children, item)
        
        itemNum = itemNum + 1
        item = self.collapseList[itemNum]
    end
    return children
end

function gui.collapse:insertInPosition(item, num)
    if not num or num > #self.collapseList then
        table.insert(self.collapseList, item)
        num = #self.collapseList
    else
        table.insert(self.collapseList, num, item)
    end
    return num
end

function gui.collapse:removeItem(num)
    
    for k, ite in ipairs(self.collapseList) do
        ite.entity:destroy()
    end
    
    local pos = num
    local depth = self.collapseList[num].depth
    repeat
        table.remove(self.collapseList, pos)
    until pos > #self.collapseList or depth >= self.collapseList[pos].depth
    
    self:addList(self.collapseList)
    return true
end

function gui.collapse:getNum(enti)
    for k, item in ipairs(self.collapseList) do
        if item.entity == enti then
            
            return k
        end
    end
    error("not an entity")
end

function gui.collapse:removeEntity(enti)
    self:removeItem(self:getNum(enti))
end

function gui.collapse:moveAfter(oldPos, nextPos)

    if self.collapseList[nextPos + 1] and self.collapseList[nextPos + 1].depth > self.collapseList[nextPos].depth then
        return self:moveToPos(oldPos, nextPos + 1, true)
    else

        return self:moveToPos(oldPos, nextPos + 1)
    end
end

function gui.collapse:moveAfterEntity(oldEntity, nextEntity)
    return self:moveAfter(self:getNum(oldEntity), self:getNum(nextEntity))
end

function gui.collapse:makeChild(oldPos, nextPos)
    local pos = nextPos + 1
    local num = 0
    while  pos <= #self.collapseList and self.collapseList[nextPos].depth < self.collapseList[pos].depth do
        pos = pos + 1
        num = num + 1
    end
    local depth = self.collapseList[nextPos].depth + 1
    return self:moveToPos(oldPos, nextPos + num + 1, depth)
end

function gui.collapse:makeChildEntity(oldEntity, nextEntity)
    return self:makeChild(self:getNum(oldEntity), self:getNum(nextEntity))
end

function gui.collapse:moveBefore(oldPos, nextPos)
    self.nextNum = self.collapseList[nextPos].depth
    return self:moveToPos(oldPos, nextPos, self.nextNum)
end

function gui.collapse:moveBeforeEntity(oldEntity, nextEntity)
    return self:moveBefore(self:getNum(oldEntity), self:getNum(nextEntity))
end

function gui.collapse:moveToEnd(pos)
    return self:moveToPos(pos, #self.collapseList + 1, 1)
end

function gui.collapse:moveToEndEntity(enti)
    return self:moveToEnd(self:getNum(enti))
end

function gui.collapse:addAfter(item, theEnti)
    local newItem = {1, item}
    local getNum = self:getNum(theEnti)
    local entityo = self:addItem(newItem)
    return self:moveAfter(#self.collapseList, getNum)
end
function gui.collapse:addChild(item, theEnti)
    local newItem = {1, item}
    local getNum = self:getNum(theEnti)
    local entityo = self:addItem(newItem)
    return self:makeChild(#self.collapseList, getNum) 
end


function gui.collapse:moveToPos(oldPos, newPos, makeChild)
    local pos = newPos 
    while self.collapseList[pos] ~= nil and self.collapseList[pos].depth ~= 1 do
        pos = pos - 1
        if pos == oldPos and oldPos ~= newPos then
            return nil
        end
    end
    
    local pos = oldPos
    local newList = {}
    local depth = self.collapseList[pos].depth
    local minusNum = 0

    
    local addNum =  nil
    if type(makeChild) == "boolean" or makeChild == nil then
        addNum = (self.collapseList[newPos-1] and self.collapseList[newPos-1].depth or 1) + (makeChild and 1 or 0)
    else
        addNum = makeChild
    end
    repeat
        local newNumPos = (self.collapseList[pos].depth - depth) + addNum
        table.insert(newList, {depth = newNumPos, content = self.collapseList[pos].content, isClosed = self.collapseList[pos].isClosed})
        pos = pos + 1
        minusNum = minusNum + 1
    until pos > #self.collapseList or self.collapseList[oldPos].depth >= self.collapseList[pos].depth
    
    for k, ite in ipairs(self.collapseList) do
        ite.entity:destroy()
    end
    
    for k = 1, minusNum do
        table.remove(self.collapseList, oldPos)
    end
    
    if newPos > oldPos then
        newPos = newPos - minusNum
    end
    
    for k, item in ipairs(newList) do
        self:insertInPosition(item, newPos + (k-1))
    end
    
    self:addList(self.collapseList)
    return self.collapseList[newPos].entity
end

function gui.collapse:isLast(pos)
    if pos == #self.collapseList then
        return true
    end

    local element = self.collapseList[pos]
    local nextPos = pos + 1
    local nextElement = self.collapseList[nextPos]
    if nextElement.depth > element.depth then
        return false
    else
        return true
    end
end

function gui.collapse:getParent(pos)
    if self.collapseList[pos].depth == 1 then
        return nil
    end
    
    local currPos = pos - 1
    while self.collapseList[currPos].depth >= self.collapseList[pos].depth do
        currPos = currPos - 1
    end
    return self.collapseList[currPos]
end

function gui.collapse:defaultCollapleStyle()
    return function(item)
        local posNum, properties ,isLast, isClosed = item.depth, item.content, item.isLast, item.isClosed
        
        local sty = {normalColor = color(190, 142, 224), hoverColor = color(169, 82, 230), pressedColor = color(148, 69, 204), selectedColor = color(139, 51, 201)}
        local element = gui.buttonUI(self.entity, {size = vec2(30)}, {style = sty, sprite = asset.Square} )

        if not isLast then
            local toggle, tog = gui.toggleUI(element, {size = vec2(element.size.y - 15), layout = {"Right", 10}},{ sprites = {on = asset.DropDownOpen, off = asset.DropDownClose}, state = not item.isClosed})
            
            function element:onTapped()
                item.isClosed = not item.isClosed
                tog:set(not item.isClosed)
                gui.selectButton(element)
            end
        else
            function element:onTapped()
                gui.selectButton(element)
            end
        end

        local name = table.unpack(properties)
        
        local labelObject = gui.labelUI(element, {size = vec2(100, 20), layout = {"Left", 12 * posNum}}, {text = name, fontSize = 20, align = LEFT|MIDDLE, truncate = true})
    
        return element
    end
end

function gui.collapse:update()
    
    if self.collapseList then
        for k, item in ipairs(self.collapseList) do
            item.entity.active = true
            if self.shouldClose then
                if self.closeNum and item.depth > self.closeNum then
                    item.entity.active = false
                    goto continue
                else
                    self.closeNum = nil
                end
                
                
                if item.isClosed or item.temporarilyClosed then
                    self.closeNum = item.depth
                end 
                ::continue::
            end
        end
        self.closeNum = nil
    end
end
