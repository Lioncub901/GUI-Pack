if not gui then
    gui = {}
end 


gui.arrow = class()

function gui.arrow:init(points, styl)
    self.point1 = point and points[1] or vec2(300,300)
    self.point2 = point and points[2] or vec2(500,500)
    
    self.color = styl and styl.color or color.red
    
    self.arrowSize = styl and styl.arrowSize or vec2(25)
    self.width = styl and styl.width or 10
end

function gui.arrow:draw()
   
    style.push().strokeWidth(self.width).lineCap(PROJECT).fill(self.color).stroke(self.color)
        self.length = self.point1:distance(self.point2)
        self.angle = vec2(1,0):dot((self.point2 - self.point1).normalized )
        self.angle = math.deg(math.acos(self.angle))
        if self.point2.y < self.point1.y then
            self.angle = -self.angle
        end
        line(self.point1, self.point1 + ((self.point2 - self.point1).normalized * (self.length - self.arrowSize.x)))
        matrix.push().translate(self.point1.x, self.point1.y)
        matrix.rotate(self.angle)
            matrix.translate(self.length  - self.arrowSize.x, 0)
            style.strokeWidth(0)
            polygon(vec2(0, -self.arrowSize.x/2), vec2(0, self.arrowSize.y/2), vec2(self.arrowSize.x, 0))
        matrix.pop()
    style.pop()
    
    
end

