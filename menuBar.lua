gui.menuBar = class("gui.menuBar")

function gui.menuBar:created(nameStyle, listStyle, baseStyle)
    self.nameStyle = nameStyle
    self.listStyle = listStyle
    self.baseStyle = baseStyle
    self.spacing = 5
    
    self.groupActive = false
    self.activeFileDrop = nil
    
    self.openTime = 0.2
    self.closeTime = 0.07
end

function gui.menuBar:start()
    self.entity:add(gui.hstack, 0, self.spacing)
end

function gui.menuBar:addItem(name, list)
    local ent = self.nameStyle(name)
    ent.parent = self.entity
    local fileDropClass = ent:add(gui.menuButton, self.listStyle, self.baseStyle)
    fileDropClass:addList(list)
    fileDropClass.dropActive = false
    fileDropClass.openTime = self.openTime
    fileDropClass.closeTime = self.closeTime
    
    ent.onTapped = function()
        if not self.groupActive then
            self.groupActive = true
            self.activeFileDrop = fileDropClass
            fileDropClass.dropActive = true
            self.activeName = name
        elseif self.activeFileDrop == fileDropClass then
            self.groupActive = false
            self.activeFileDrop = nil
            self.activeName = nil
            fileDropClass.dropActive = false
        elseif self.activeFileDrop ~= fileDropClass then
            self.activeFileDrop.dropActive = false
            self.activeFileDrop = fileDropClass
            fileDropClass.dropActive = true
            self.activeName = name
        end
    end
    
    ent.onMouseEnter = function()
        if self.groupActive then
            self.activeFileDrop.dropActive = false
            self.activeFileDrop = fileDropClass
            fileDropClass.dropActive = true
            self.activeName = name
        end
    end
end

function gui.menuBar:update()
    if self.activeFileDrop and not self.activeFileDrop.dropActive then
        self.groupActive = false
        self.activeFileDrop = nil
    end
end
