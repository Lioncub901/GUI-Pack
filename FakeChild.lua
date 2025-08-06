gui.fakeChild = class("gui.fakeChild", component)

function gui.fakeChild:created()
    --print("pdsfsdfsdf")
    self.entity.fakeChildren = {}
    
    self.entity.fakeChildAt = function(lol,num)
        return self.entity.fakeChildren[num]
    end

    self.entity.fakeChild = function(lol, name, parent)
        if not parent then
            parent = self.entity.parent
        end
        name = name or "untitledUI"
        local newFakeChild = parent:child(name)
        newFakeChild.isFakeChild = true
        newFakeChild.fx = 0
        newFakeChild.fy = 0
        self.entity[name] = newFakeChild
        newFakeChild.fakeParent = self.entity
        newFakeChild:add(gui.fakeChildComponent, self.entity)
        table.insert(self.entity.fakeChildren, newFakeChild)
        return newFakeChild
    end
    self.entity.destroyed = function()
    for k, child in ipairs(self.entity.fakeChildren) do
        child:destroy(0.00000000001)
        end
    end
    self.entity.hitTest = true
end

function gui.fakeChild:start()

end

function gui.fakeChild:layout()
    local parentWorldPos = vec2(self.entity.worldPosition.x, self.entity.worldPosition.y)
    for k, child in ipairs(self.entity.fakeChildren) do
        local worldPos = vec2(child.worldPosition.x, child.worldPosition.y)
        
        newWorldPosition = parentWorldPos + (self.entity.size / 2) + self:addAnchor(child) + self:addFakePosition(child)
        child.worldPosition = vec3(newWorldPosition.x, newWorldPosition.y, 0)
    end
end


function gui.fakeChild:addAnchor(child)
    adjustVec = vec2(0)
    local first, second = child:anchorX()
    
    if not (first == 0 and second == 1) then 
        local xPos = second - 0.5
        adjustVec.x = xPos * self.entity.size.x 
    else
        child.size = vec2(self.entity.size.x, child.size.y)
    end 
    
    local yPos = select(2,child:anchorY()) - 0.5
    adjustVec.y = yPos * self.entity.size.y 
    
    return adjustVec
end

function gui.fakeChild:addFakePosition(child)
    local pos  = vec2(0)
    pos.x = child.fx
    pos.y = child.fy
    return pos
end


gui.fakeChildComponent = class("gui.fakeChildComponent", component)

function gui.fakeChildComponent:created(fakeParent)
    self.fakeParent = fakeParent
end

function gui.fakeChildComponent:destroyed()
    if self.fakeParent and self.fakeParent.valid and self.fakeParent.fakeChildren then
        for k, child in ipairs(self.fakeParent.fakeChildren) do
            if child == self.entity then
                table.remove(self.fakeParent.fakeChildren, k)
                if self.entity.name then
                    self.fakeParent[self.entity.name] = nil
                end
                break
            end
        end
    end
end

function gui.fakeChildComponent:update()
    if not self.fakeParent.activeInHierarchy then
        self.entity.active = false
    end
end

Profiler.wrapClass(gui.fakeChild)