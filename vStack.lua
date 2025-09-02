if not gui then
    gui = {}
end 

gui.vstack = class('gui.vstack')

function gui.vstack:created(padding, spacing, stretchChildren)
    self.padding = {left = 10, right = 10, top = 10, bottom = 10}
    if padding then
        self:setPadding(padding)
    end
    self.spacing = spacing or 5
    self.stretchChildren = stretchChildren or false
    
    self.oldSize = nil
    self.oldNum = nil
end

function gui.vstack:setPadding(padding)
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

function gui.vstack:update()
    
    
end

function gui.vstack:stretchItems()
    if self.stretchChildren then
        local e = self.entity
        local sp = self.spacing
        
        local stretchSize = self.entity.size.y
        local numberOfStretchChildren = 0
        local numActiveChildren = 0
        
        for i = 1, e.childCount do
            local child = e:childAt(i)
            if child.active and child.fakeParent == nil then
                if child.stretch then
                    numberOfStretchChildren = numberOfStretchChildren + 1
                    stretchSize = stretchSize
                else
                    stretchSize = stretchSize - child.size.y
                end
                numActiveChildren = numActiveChildren + 1
            end
        end
        stretchSize = stretchSize - (self.padding.top + self.padding.bottom) - ((numActiveChildren - 1) * sp) 
        
        for i = 1, e.childCount do
            local child = e:childAt(i)
            if child.active and child.fakeParent == nil then
                if child.stretch then
                    child.size = vec2(e.size.x - self.padding.left - self.padding.right, stretchSize / numberOfStretchChildren)
                else
                    child.size = vec2(e.size.x - self.padding.left - self.padding.right, child.size.y)
                end
            end
        end
        
        e.shouldUpdateStack = nil
    end
end

function gui.vstack:checkActiveCount()
    local e = self.entity
    local num = 0
    
    for i = 1, e.childCount do
        local child = e:childAt(i)
        if child.active and child.fakeParent == nil then    
            num = num + 1
        end
    end
    return num
end

function gui.vstack:computeSize()
    if not self.stretchChildren then
        local e = self.entity
        local pd = self.padding
        local sp = self.spacing
        
        local size = e.size
        size.y = self.padding.top
        
        for i = 1, e.childCount do
            local child = e:childAt(i)
            if child.active and child.fakeParent == nil then
                size.y = size.y + child.size.y + ((i < e.childCount) and sp or 0)
            end
        end
        size.y = size.y + self.padding.bottom
        
        e.size = size
    end
    
end

function gui.vstack:layout()
    local e = self.entity
    local padding = self.padding or { left = 0, right = 0, top = 0, bottom = 0 }
    local left, right, top, bottom = padding.left, padding.right, padding.top, padding.bottom
    local spacing = self.spacing or 0
    local width = math.max(0, e.size.x - left - right)
    local childCount = e.childCount
    
    -- Initialize cached values if not set
    self.oldSize = self.oldSize or e.size.y
    self.oldNum = self.oldNum or childCount
    self.activeCount = self.activeCount or 0
    
    -- Check if layout needs updating
    local shouldChange = (
    self.oldSize ~= e.size.y or
    self.oldNum ~= childCount or
    self.activeCount ~= self:checkActiveCount() or
    (childCount > 0 and e:childAt(1).active and not e:childAt(1).fakeParent and
    (e:childAt(1).y ~= -top or e:childAt(1).size.x ~= width)) or e.shouldUpdateStack
    )
    
    if not shouldChange then
        return self.cachedY or -bottom
    end
    
    self:stretchItems()
    
    local y = -top
    for i = 1, childCount do
        local child = e:childAt(i)
        if child and child.active and not child.fakeParent then
            child.x = (left - right) * 0.5
            child.y = y
            child.pivot = vec2(0.5, 1)
            child:anchor(STRETCH, TOP)
            child.size = vec2(width, child.size.y)
            y = y - child.size.y - (i < childCount and spacing or 0)
        end
    end
    y = y - bottom
    
    -- Update cached state
    self.oldSize = e.size.y
    self.oldNum = childCount
    self.activeCount = self:checkActiveCount()
    self.cachedY = y
    
    return y
end

Profiler.wrapClass(gui.vstack)