if not gui then
    gui = {}
end 

gui.hstack = class('gui.hstack')

function gui.hstack:created(padding, spacing, stretchChildren)
    self.padding = {left = 10, right = 10, top = 10, bottom = 10}
    if padding then
        self:setPadding(padding)
    end
    self.spacing = spacing or 5
    self.stretchChildren = stretchChildren or false

    
    self.oldSize = nil
    self.oldNum = nil
end

function gui.hstack:start()
    self:stretchItems()
   

end

function gui.hstack:setPadding(padding)
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

function gui.hstack:stretchItems()
    if self.stretchChildren and (self.oldSize ~= self.entity.size.x or self.oldNum ~= #self.entity.children or self.activeCount ~= self:checkActiveCount()) then
        local e = self.entity
        local sp = self.spacing

        
        local stretchSize = self.entity.size.x
        local numberOfStretchChildren = 0
        local numActiveChildren = 0
        
        for i = 1, e.childCount do
            local child = e:childAt(i)
            if child.active and child.fakeParent == nil then
                if child.stretch then
                    numberOfStretchChildren = numberOfStretchChildren + 1
                    stretchSize = stretchSize
                else
                    stretchSize = stretchSize - child.size.x
                end
                numActiveChildren = numActiveChildren + 1
            end
        end
        stretchSize = stretchSize - (self.padding.left + self.padding.right) - ((numActiveChildren - 1) * sp) 
        
        for i = 1, e.childCount do
            local child = e:childAt(i)
            if child.active and child.fakeParent == nil then            
                if child.stretch and child.fakeParent == nil then
                    child.size = vec2(stretchSize / numberOfStretchChildren, e.size.y - (self.padding.top + self.padding.bottom))
                else
                    child.size = vec2(child.size.x, e.size.y - (self.padding.top + self.padding.bottom))
                end
            --[=[    
                local stack = nil
                if child:has(gui.vstack) then
                    stack = child:get(gui.vstack)
                elseif child:has(gui.hstack) then
                    stack = child:get(gui.hstack)
                end
                if stack then
                    stack:stretchItems()
                end]=]
                
            end
        end
        self.activeCount = self:checkActiveCount()
        self.oldSize = self.entity.size.x
        self.oldNum = #self.entity.children
    end
end

function gui.hstack:checkActiveCount()
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

--computeSize
function gui.hstack:checkSize()
    if not self.stretchChildren then
        local e = self.entity
        local pd = self.padding
        local sp = self.spacing

        local size = e.size
        size.x = self.padding.left
        
        for i = 1, e.childCount do
            local child = e:childAt(i)
            if child.active and child.fakeParent == nil then
                size.x = size.x + child.size.x + ((i < e.childCount) and sp or 0)
            end
        end
        size.x = size.x + self.padding.right
        
        e.size = size
    end
   
end

function gui.hstack:layout()
    self:stretchItems()
    
    local e = self.entity
    local sp = self.spacing
    local x = self.padding.left
    

    
    for i = 1, e.childCount do
        local child = e:childAt(i)
        if child.active and child.fakeParent == nil then            
            child.x = x
            child.y = (self.padding.bottom / 2) + (-self.padding.top / 2)
            child.pivot = vec2(0, 0.5)
            child:anchor(LEFT, STRETCH)
            local s = child.size
            
            child.size = vec2(child.size.x, e.size.y - (self.padding.top + self.padding.bottom))
            
            x = x + s.x + ((i < e.childCount) and sp or 0)
        end
    end
    x = x + self.padding.right
    self:checkSize()
end

function gui.fixStack(enti)
    if enti.childCount ~= 0 then
        if enti:has(gui.hstack) then
            enti:get(gui.hstack):stretchItems()
        elseif enti:has(gui.vstack) then
            enti:get(gui.vstack):stretchItems()
        end
        
        for k, childEnti in ipairs(enti.children) do
            gui.fixStack(childEnti)
        end
    end
end
