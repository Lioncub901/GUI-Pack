gui.dragableList = class("gui.dragableList")

function gui.dragableList:created(padding, spacing)
    self.padding = {left = 10, right = 10, top = 10, bottom = 10}
    if padding then
        self:setPadding(padding)
    end
    self.spacing = spacing or 5
    self.moveSpeed = 5
    self.childrenOrder = {}
    self.addedChildren = false
    
    if self.entity:has(gui.vstack) then
        self.padding = self.entity:get(gui.vstack).padding
        self.spacing = self.entity:get(gui.vstack).spacing
        self.entity:remove(gui.vstack)
    end
end

function gui.dragableList:start()
    if not self.addedChildren then
        local e = self.entity
        for i = 1, e.childCount do
            local child = e:childAt(i)
            self:checkDrag(child)
            table.insert(self.childrenOrder, child)
            child.y = self:getYPos(i)
        end
        self.addedChildren = true
    end
end

function gui.dragableList:setPadding(padding)
    if type(padding) == "number" or padding.x ~= nil then
        if  type(padding) == "number" then
            self.padding.left = padding
            self.padding.right = padding
            self.padding.top = padding
            self.padding.bottom = padding
        else
            self.padding.left = padding.x
            self.padding.right = padding.x
            self.padding.top = padding.y
            self.padding.bottom = padding.y
        end
    else
        self.padding = padding
    end
end

function gui.dragableList:computeSize()
    local e = self.entity
    local pd = self.padding
    local sp = self.spacing
    
    local size = e.size
    size.y = self.padding.top
    
    for i = 1, e.childCount do
        local child = e:childAt(i)
        if child.active then
            size.y = size.y + child.size.y + ((i < e.childCount) and sp or 0)
        end
    end
    size.y = size.y + self.padding.bottom
    
    e.size = size
end

function gui.dragableList:getYPos(pos)
    local e = self.entity
    local y = -self.padding.top
    for i = 1, pos - 1 do
        local child = self.childrenOrder[i]
        y = y - child.size.y - ((i < e.childCount) and self.spacing or 0)
    end
    return y
end

function gui.dragableList:getOrderNum(childEnti)
    for k, child in ipairs(self.childrenOrder) do
        if child.id == childEnti.id then
            return k
        end
    end
end

function gui.dragableList:layout()
    local e = self.entity
    local pd = self.padding
    local left, right, top, bottom = pd.left, pd.right, pd.top, pd.bottom
    local spacing = self.spacing or 0
    local width = math.max(0, e.size.x - left - right)
    
    for k, child in ipairs(self.childrenOrder) do
        local drag = child:get(gui.dragable)
        if not drag.isDragging then
            
            child.x = (left - right) * 0.5
            
            
            self:moveTowardPosition(child, k)
            drag.bottom = nil
            drag.top = nil
        else
            if e.children[e.childCount] ~= child then
                child:moveAfter(e.children[e.childCount])
            end
            if drag.moving then
                self:checkNeighbors(k)
            end
            drag.shouldFit = true
            drag.bottom = -(self.entity.size.y - self.padding.bottom + 0.3)
            drag.top = - (self.padding.top - 0.3)
        end
        
        
        child.pivot = vec2(0.5, 1)
        child:anchor(STRETCH, TOP)
        child.size = vec2(width, child.size.y)
    end

    if not self.first then
        self.first = true
    end
end

function gui.dragableList:moveTowardPosition(enti, pos)
    local dis = (vec2(enti.x, self:getYPos(pos)) - vec2(enti.x, enti.y))
    dir = dis.normalized --dis / math.abs(dis)
    
    local moveSpeed = (not self.first) and 9999999999 or self.moveSpeed
    
    if dis.length > dir.length * moveSpeed then
        dis = dir * moveSpeed
    end
    enti.y = enti.y + dis.y
    enti.x = enti.x + dis.x
    --print(dis)
end

function gui.dragableList:checkNeighbors(pos)
    local newCurrentTouch = gui.mapTouchToScene(CurrentTouch, self.scene)
    if pos ~= 1 then
        local yToWorld = self.entity.worldPosition.y + self.entity.size.y + self:getYPos(pos-1)
        if newCurrentTouch.delta.y > 0 and newCurrentTouch.y > yToWorld - self.childrenOrder[pos - 1].size.y then
            local hold = self.childrenOrder[pos]
            self.childrenOrder[pos] = self.childrenOrder[pos-1]
            self.childrenOrder[pos-1] = hold
        end
    end
    
    if pos ~= #self.childrenOrder then
        local yToWorld = self.entity.worldPosition.y + self.entity.size.y + self:getYPos(pos+1)
        if newCurrentTouch.delta.y < 0 and newCurrentTouch.y < yToWorld then
            local hold = self.childrenOrder[pos]
            self.childrenOrder[pos] = self.childrenOrder[pos+1]
            self.childrenOrder[pos+1] = hold
        end
    end
end

function gui.dragableList:addChild(child)
    if #self.childrenOrder > 0 then
        child:moveBefore(self.childrenOrder[#self.childrenOrder])
        child.y = self.childrenOrder[#self.childrenOrder].y
    end
    self:checkDrag(child)
    table.insert(self.childrenOrder, child)
end

function gui.dragableList:checkDrag(child)
    if not child:has(gui.dragable) then
        child:add(gui.dragable, gui.vertical) 
    end
end