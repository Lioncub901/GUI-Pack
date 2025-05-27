gui.toggle = class("gui.toggle", component)

function gui.toggle:created(offImg, onImg, makeButton)
    -- you can accept and set parameters here
    self.offImg = offImg
    self.onImg = onImg
    self.state = false
    self.entity.sprite = self.offImg

    if makeButton then
        button = self.entity:add(gui.button)
        button.style.pressedColor = color(255)
        self.entity.sprite = offImg
        
        self.entity.onTapped = function(button)
            self.state = not self.state
            if self.state == true then
                self.entity.sprite = self.onImg
                self.entity:dispatch('turnedOn', self)
            else
                self.entity.sprite = self.offImg
                self.entity:dispatch('turnedOff', self)
            end
        end
    end
end

function gui.toggle:flip()
    self:set(not self.state)
end

function gui.toggle:set(value)
    if value then
        self:turnOn()
    else
        self:turnOff()
    end
end

function gui.toggle:turnOff()
    self.state = false
    self.entity.sprite = self.offImg
end

function gui.toggle:turnOn()
    self.state = true
    self.entity.sprite = self.onImg
end

