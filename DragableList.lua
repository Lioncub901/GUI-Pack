gui.dragableList = class("gui.dragableList")

function gui.dragableList:created(padding, spacing)
    self.padding = padding or 10
    self.spacing = spacing or 5
    self.moveSpeed = 5
    self.childrenOrder = {}
    self.addedChildren = false
end

function gui.dragableList:start()
    if not self.addedChildren then
        local e = self.entity
        for i = 1, e.childCount do
            local child = e:childAt(i)
            table.insert(self.childrenOrder, child)
            child.y = self:getYPos(i)
        end
        self.addedChildren = true
    end
end

function gui.dragableList:computeSize()
    local e = self.entity
    local pd = self.padding
    local sp = self.spacing
    
    local size = e.size
    size.y = pd
    
    for i = 1, e.childCount do
        local child = e:childAt(i)
        if child.active then
            size.y = size.y + child.size.y + ((i < e.childCount) and sp or 0)
        end
    end
    size.y = size.y + pd
    
    e.size = size
end

function gui.dragableList:getYPos(pos)
    local e = self.entity
    local y = -self.padding
    for i = 1, pos - 1 do
        local child = self.childrenOrder[i]
        y = y - child.size.y - ((i < e.childCount) and self.spacing or 0)
    end
    return y
end

function gui.dragableList:layout()
    local e = self.entity
    local pd = self.padding
    
    for k, child in ipairs(self.childrenOrder) do
        self:checkDrag(child)
        local drag = child:get(gui.dragable)
        if not drag.isDragging then
            --child.x = 0
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
            drag.bottom = -(self.entity.size.y - self.padding + 0.3)
            drag.top = - (self.padding - 0.3)
        end
        
        
        child.pivot = vec2(0.5, 1)
        child:anchor(STRETCH, TOP)
        local s = child.size
        child.size = vec2(e.size.x - pd * 2, s.y)
    end
end

function gui.dragableList:moveTowardPosition(enti, pos)
    local dis = (vec2(0, self:getYPos(pos)) - vec2(enti.x, enti.y))
    dir = dis.normalized --dis / math.abs(dis)
    if dis.length > dir.length * self.moveSpeed then
        dis = dir * self.moveSpeed
    end
    enti.y = enti.y + dis.y
    enti.x = enti.x + dis.x
end

function gui.dragableList:checkNeighbors(pos)
    local scal = self.entity.scene.canvas.scale
    if pos ~= 1 then
        local yToWorld = self.entity.worldPosition.y + self.entity.size.y + self:getYPos(pos-1)
        if CurrentTouch.delta.y * scal > 0 and CurrentTouch.y * scal > yToWorld - self.childrenOrder[pos - 1].size.y then
            local hold = self.childrenOrder[pos]
            self.childrenOrder[pos] = self.childrenOrder[pos-1]
            self.childrenOrder[pos-1] = hold
        end
    end
    
    if pos ~= #self.childrenOrder then
        local yToWorld = self.entity.worldPosition.y + self.entity.size.y + self:getYPos(pos+1)
        if CurrentTouch.delta.y * scal < 0 and CurrentTouch.y * scal < yToWorld then
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
    table.insert(self.childrenOrder, child)
end

function gui.dragableList:checkDrag(child)
    if not child:has(gui.dragable) then
        child:add(gui.dragable, gui.vertical) 
    end
end