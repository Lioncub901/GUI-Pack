if not gui then
    gui = {}
end 

gui.slider = class()

function gui.slider:created(currentPercent)
    -- you can accept and set parameters here
    self.entity.hitTest = true
    self.entity:add(gui.fakeChild)
    
    self.bar = self.entity:add(gui.progressBar, currentPercent)
    self.handle = self.entity:fakeChild("handle")
    self.handle.size = vec2(35)
    self.handle.sprite = asset.Slider_Handle
    self.drag = self.handle:add(gui.dragable, gui.horizontal)
    self.drag.style.normalColor = color(223, 151, 170)
    self.drag.style.pressedColor = color(226, 117, 143)

end

function gui.slider:update()
    self.left = -self.entity.size.x / 2 + self.bar.spacing
    self.right = -self.left

    self.drag.left= self.left
    self.drag.right = self.right
    
    local per = (self.handle.fx - self.left)/(self.entity.size.x - 2 * self.bar.spacing)
    self.bar.percent = per * 100
end

function gui.slider:touched(touch)
    local left = self.entity.worldPosition.x + self.bar.spacing
    local right = self.entity.worldPosition.x + self.entity.size.x - self.bar.spacing
    
    local p = (touch.x - left)/(right - left)
    self.handle.fx = self.left + p * self.entity.size.x
    
 
    return true
end
