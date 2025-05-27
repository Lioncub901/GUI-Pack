uxl = {
    readFile = function(filePath, isString)
        
        local uxlContent = filePath
        if not isString then
            uxlContent = string.read(filePath)
        end
        c = scene.main.canvas
        
        local pos, _, content = string.find(uxlContent, "<style.->(.-)</style>")
        if pos ~= nil then
            uxl:loadStyles(content)
        end
        
        local pos, _, content = string.find(uxlContent, "<canvas.->(.-)</canvas.-")
    
        if pos ~= nil then
            uxl:loadUI(content, scene.main:findEntity("canvas"))
        else
            warning("Uxl: there is no canvas tag")
            do return end
        end
        
        
        
    end,
    
    loadUI = function(self,elements, parent, parentStyle)
        
    
        for uiElement in string.gmatch(elements, "<%a+.->.-</%a+>") do
            local _, _, tagName, attributes, content = string.find(uiElement, "<(%a+)(.-)>(.-)</%1>")
            attributes = uxl:getAttributes(attributes)
            
            if not attributes["style"] and parentStyle then
                attributes["style"] = parentStyle
            end
            
            if attributes["style"] and self.styles == nil then
                warning("'"..tagName.."' uses custom styles but their is no styles made")
                do return end
            end
            
            entityOnly = {"x", "y", "size", "pivot", "anchorX", "anchorY"}
            local uiEntity = parent:child(attributes["name"])
            uiEntity.x = attributes["x"]
            uiEntity.y = attributes["y"]
            uiEntity.size = attributes["size"]
            uiEntity:anchor(attributes["anchorX"], attributes["anchorY"])
            uiComponent = uiEntity:add(ui[tagName])
            
            shouldSendStyle = false
            
            if attributes["style"] ~= nil then
                local sty, shouldSendStyle = self:prepareStyle(attributes["style"], tagName)
                if sty ~= nil then
                    self:setStyle(uiComponent.style, sty, tagName)
                else
                    warning("Error: Style Group '"..attributes["style"]:sub(2,-2).."' does not have a '" .. tagName .. "' style")
                    do return end
                end
            elseif self.styles.default ~= nil then
                self:setStyle(uiComponent.style, self.styles.default[tagName], tagName)
            end
            
            
            --self:loadUI(content, uiEntity)
        end
    end,
    
    prepareStyle = function(self, style, tag)
        local sty, count = string.gsub(style, "#(%a+)#", function(group) 
            return self.styles[group][tag] .. ";"
        end)
        return sty, false
    end, 
    
    setStyle = function(self,uiStyle,style, tag)
        for sty in string.gmatch(style, "%a+%s*:%s*[^;]+") do
            _, _, styleTag, styleValue = string.find(sty, "(%a+)%s*:%s*(.+)")
            uiStyle[styleTag] = load("return "..styleValue)()
        end
    end,
    
    getAttributes = function(self, attri)
        
        local attributes = {}
        for attr in string.gmatch(attri, "%a+%s*=%s*%b\"\"") do
            local _, _, tag, value = string.find(attr, "(%a+)%s-=%s-(%b\"\")")
            local special = {"style"}
            if not table.contains(special, tag) then
                attributes[tag] = load("return "..value:sub(2,-2))()
            else
                attributes[tag] = value:sub(2,-2)
            end
        end
        return attributes
    end,
    
    styles = {}, 
    
    loadStyles = function(self, styleGroups)
        for styleGroup in string.gmatch(styleGroups, "<%a+.->.-</%a+>") do
            local _, _, groupName ,groupContent = string.find(styleGroup, "<(%a+).->(.-)</%1.->")
            local _, _, uiType ,content = string.find(groupContent, "(%a+)(%b{})")
            content = content:sub(2, -2)
            self.styles[groupName] = {}
            self.styles[groupName][uiType] = content
        end
    end
}

table.contains = function(tab, val) 
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
