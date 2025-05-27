if not gui then
    gui = {}
end    

gui.fitImage = class("fitImage")

function gui.fitImage:created(padding, set)
    -- you can accept and set parameters here
    if type(padding) == "number" then
        padding = vec2(padding)
    end
    self.padding = padding
    if set then
        self.set = true
    end
end

function gui.fitImage:layout()
    -- size of the image
    if self.entity.sprite then
        if self.set then
            self.maxSize = self.padding
        else
            self.maxSize = self.entity.parent.size - (self.padding and self.padding or vec2(0))
        end
        local imageSize = self.entity:pixelSize()
        
        -- Compare which side it to fit to
        if imageSize.x / imageSize.y > self.maxSize.x/self.maxSize.y then
            self.entity.size = vec2(self.maxSize.x, imageSize.y / imageSize.x * self.maxSize.x)
        else
            self.entity.size = vec2(imageSize.x / imageSize.y * self.maxSize.y, self.maxSize.y)
        end
    end
end
