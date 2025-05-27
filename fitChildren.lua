gui.fitChild = class("gui.fitChild")

function gui.fitChild:created(padding)
    if padding and type(padding) == "number" then
        padding = vec2(padding)
    end
    self.padding = padding or vec2(0)
end

function gui.fitChild:computeSize()
    self.entity.size = self.entity:childAt(1).size + 2 * self.padding
end


---multiple


gui.fitChildren = class("gui.fitChildren")

function gui.fitChildren:created(padding)
    if padding and type(padding) == "number" then
        padding = vec2(padding)
    end
    self.padding = padding or vec2(0)
end

function gui.fitChildren:layout()
    local pos = vec2((self.edge.right + self.edge.left)/2, (self.edge.up + self.edge.down)/2)
    local containerPos = vec2(self.entity.worldPosition.x, self.entity.worldPosition.y) + self.entity.size/2
    local offset = containerPos - pos
    
    for k, enti in ipairs(self.entity.children) do
        enti.x = enti.x + offset.x
        enti.y = enti.y + offset.y
    end
end

function gui.fitChildren:computeSize()
    self.edge = {right = math.mininteger, left = math.maxinteger, up = math.mininteger, down = math.maxinteger}
    for k, enti in ipairs(self.entity.children) do
        if enti.worldPosition.x + enti.size.x > self.edge.right then
            self.edge.right = enti.worldPosition.x + enti.size.x
        end
        if enti.worldPosition.y + enti.size.y > self.edge.up then
            self.edge.up = enti.worldPosition.y + enti.size.y
        end
        if enti.worldPosition.x < self.edge.left then
            self.edge.left = enti.worldPosition.x
        end
        if enti.worldPosition.y < self.edge.down then
            self.edge.down = enti.worldPosition.y
        end
    end

    self.entity.size = vec2(self.edge.right - self.edge.left, self.edge.up - self.edge.down)
    
    self.entity.size = self.entity.size + 2 * self.padding
end

