gui.dropDown = class("gui.dropDown", component)

function gui.dropDown:created(styleButton, buttonSize)
    -- you can accept and set parameters here
    self.buttonSize = vec2(self.entity.size.x, self.entity.size.y)
    
    self.styleFunction = styleButton or self.defaultButton
    
    self.entity:add(gui.fakeChild)
        
    self.defaultText = "Select an item"
    self.hasSelected = false
    self.button = self.entity:add(gui.button)
    self.button.multiplyColor = true

    gui.beginParent(self.entity)
        self.labelObj, self.label = gui.labelUI({size =  vec2(350,0), layout = {"LEFT", 10}}, {align = LEFT | MIDDLE, text = "hdsfsdf"})
        self.labelObj:anchorY(STRETCH)
        self.icon = gui.imageUI({layout = {"Right", 10}, size = 25}, asset.DropDownClose)
    
        self.container = gui.squareUI({layout = "Bottom", size = self.buttonSize.x, fake = {}, vstack = {0,0}}, color(255))
        self.container.active = false
    gui.endParent()
    
    self.entity.onTapped = function(button)
        self.container.active = not self.container.active
        self.icon.sprite = self.container.active and asset.DropDownOpen or asset.DropDownClose
    end
   
    self.shouldStretchContainer =  true
    self.selectedText = nil
end

function gui.dropDown:update()
    if not self.hasSelected then
        self.label.text = self.defaultText
    end
    
    if CurrentTouch.began and not gui.wasTouched( self.container) and not gui.wasTouched( self.entity) then
        self.container.active = false
        self.icon.sprite = self.container.active and asset.DropDownOpen or asset.DropDownClose
    end
    self:stretchContainer()
end

function gui.dropDown:stretchContainer()
    if  self.shouldStretchContainer then
        self.container.size = vec2(self.entity.size.x, self.container.size.y)
    end
end



function gui.dropDown:addItem(...)
    local newButton = self.styleFunction({...}, self)
    if newButton.onTapped == nil then
        newButton.onTapped = function(buttonC)
            self.container.active = false
            self.icon.sprite = self.container.active and asset.DropDownOpen or asset.DropDownClose
            gui.selectButton(newButton)
            self.selectedText = newButton.itemText:get(gui.label).text
            self.label.text = self.selectedText
            self.entity:dispatch('onItemSelected', newButton:siblingNumber()) 
            self.hasSelected = true
        end
    end
    newButton.parent = self.container
    return newButton
end

function gui.dropDown.defaultButton(items, theClass)
    self = theClass
    local textName = table.unpack(items)
    
    
    local buttonEntity = gui.buttonUI(self.scene.canvas, {size = self.buttonSize}, {sprite = asset.Square, multiplyColor = true})
    --buttonEntity.color = color.red
    
    
    local lab = gui.labelUI(buttonEntity, { name = "itemText", size = self.buttonSize - vec2(10), layout = {"LEFT", 10}}, {text = textName, color = color(20), align = LEFT | MIDDLE})

    return buttonEntity
end

