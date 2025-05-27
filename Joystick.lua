gui.joystick = class("gui.joystick")

gui.joystick.NONE = -1
gui.joystick.LEFT = 0
gui.joystick.RIGHT = 1
gui.joystick.UP = 2
gui.joystick.DOWN = 3

function gui.joystick:created()
    self.entity.hitTest = true
    
    if self.entity.size == nil then
        self.entity.size = vec2(300, 300)
    end
    self.handle = self.entity:child("handle")
    self.handle:add(JoystickHandle, self.entity)
    self.direction = vec2(0)
    self.offset = -10
    self.directionEnum = gui.joystick.NONE 
    
    self.style = {
        baseImage = image.read(asset.Joystick_Base),
        handleImage = image.read(asset.Joystick_Handle),
        baseColor = color(255, 0, 0),
        handleColor = color(255, 166, 0)
    }
    
    
end


function gui.joystick:update()
    self.entity.sprite = self.style.baseImage
    self.entity.color = self.style.baseColor
    self.entity.handle.sprite = self.style.handleImage
    self.entity.handle.color = self.style.handleColor
end

function gui.joystick:touched(touch,hit)
    local center = self.entity.worldPosition + vec3(self.entity.size.x/2, self.entity.size.y/2, 0)
    local scal = self.entity.scene.canvas.scale
    if touch.moving or touch.began then
        local offset = touch.pos * scal - vec2(center.x, center.y)
        local pos = nil
        if offset.length > self.entity.size.x/2 - self.entity.handle.size.x/2 + self.offset then
            pos = offset.normalized * (self.entity.size.x/2 - self.entity.handle.size.x/2 + self.offset)
            self.entity.handle.worldPosition = vec3(pos.x, pos.y, 0) + center
        else
            pos = offset
            self.entity.handle.worldPosition = vec3(pos.x, pos.y, 0) + center
        end
        self.direction= (offset.normalized * pos.length)/(self.entity.size.x/2 - self.entity.handle.size.x/2 + self.offset)
        self.directionEnum = self:getDirectionEnum(self.direction)
        
        return true
        
    elseif touch.ended then
        self.entity.handle.position = vec3(0)
        self.direction = vec2(0)
        self.directionEnum = gui.joystick.NONE 
        
    end
end

function gui.joystick:getDirectionEnum(dir)
    local angle = math.deg(math.acos(vec2(1,0):dot(dir)))
    if angle <= 45 then
        return gui.joystick.RIGHT
    elseif angle > 135 then
        return gui.joystick.LEFT
    elseif dir.y > 0 then
        return gui.joystick.UP
    else
        return gui.joystick.DOWN
    end
end

JoystickHandle = class("JoystickHandle", component)

function JoystickHandle:created(base)
    self.entity.hitTest = true
    self.base = base
    self.entity.size = base.size * 0.3
end

function JoystickHandle:touched(touch, hit)
    
end