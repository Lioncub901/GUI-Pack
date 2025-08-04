if not gui then
    gui = {}
end    

gui.grid = class("gui.grid")

function gui.grid:created(col, styleFunc)
    self.padding = {left = 10, right = 10, top = 10, bottom = 10}
    self.spacing = 10
    self.numCol = col
    self.gridElementStyle = styleFunc or self:defaultStyle()
    self.elementOrder = {}
    self.elementSize = vec2(100,300)
    
    -- Types: default, stretch, fit
    self.fitType = "default"
    self.oldSize = nil
end

function gui.grid:updateFitType(doPass)
    if self.fitType == "fit" and (self.oldSize ~= self.entity.parent.size.x or doPass) then
        local num = math.floor(self.entity.parent.size.x / self.elementSize.x)
        for k = num, 1, -1 do
            if self:checkSize(k) < self.entity.parent.size.x then
                self.numCol = k
                break
            end
        end
        self.oldSize = self.entity.parent.size.x
    elseif self.fitType == "stretch" and (self.oldSize ~= self.entity.parent.size.x or doPass) then
        local newSize = (self.entity.parent.size.x - ((self.numCol - 1) * self.spacing) - (self.padding.left + self.padding.right)) / self.numCol
        local ratio = newSize / self.elementSize.x
        self.elementSize = self.elementSize * ratio
        self.oldSize = self.entity.parent.size.x
    end
end

function gui.grid:checkSize(numCol)
    local width = (numCol * self.elementSize.x) + ((numCol - 1) * self.spacing) + (self.padding.left + self.padding.right)
    return width
end

function gui.grid:setPadding(padding)
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

--computeSize
function gui.grid:changeSize()
    self.numRow = math.ceil(#self.elementOrder / self.numCol)
    local width = (self.numCol * self.elementSize.x) + ((self.numCol - 1) * self.spacing) + (self.padding.left + self.padding.right)
    local height = (self.numRow * self.elementSize.y) + ((self.numRow - 1) * self.spacing) + (self.padding.top + self.padding.bottom)
    self.entity.size = vec2(width, height)
    
end

function gui.grid:layout()
    self:updateFitType()
    self:reorderGrid()
    self:changeSize()
end

function gui.grid:reorderGrid()
    for k, element in ipairs(self.elementOrder) do
        element.size = self.elementSize
        element:anchor(LEFT, TOP)
        element.pivot = vec2(0, 1)
        
        if not element:has(gui.dragable) or not element:get(gui.dragable).isDragging then
            local pos = self:getElementPos(k)
            element.x = pos.x
            element.y = pos.y
        end
    end
end

function gui.grid:defaultStyle()
    return function(element, elementNumber)
        element.sprite = asset.Square
        element.color = color(255)
    end
end

function gui.grid:addElement(...)
    local element = self.gridElementStyle(#self.elementOrder + 1, ...)
    element.parent = self.entity
    element.size = self.elementSize
    table.insert(self.elementOrder, element)
end

function gui.grid:removeElement(num)
    local element = self.elementOrder[num]
    table.remove(self.elementOrder, num)
    element:destroy()
end

function gui.grid:removeAll()
    for k = #self.elementOrder, 1, -1 do
        self:removeElement(k)
    end
    self.oldSize = nil
end

function gui.grid:clear()
    self:removeAll()
end

function gui.grid:getElementPos(pos)
    
    local col = ((pos - 1) % self.numCol) + 1
    local row = (math.ceil(pos / self.numCol))
    
    local xPos = self.padding.left + ((col-1) * self.elementSize.x) + ((col-1) * self.spacing)
    local yPos = -(self.padding.top + ((row - 1) *  self.elementSize.y) + ((row - 1) * self.spacing) )
    return vec2(xPos, yPos)
end

Profiler.wrapClass(gui.grid)