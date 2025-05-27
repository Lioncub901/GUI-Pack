if not gui then
    gui = {}
end 

function gui.entityToUiPos(enti, cam)

    local x, y = enti.scene.camera:get(camera):worldToScreen(enti.worldPosition.x , enti.worldPosition.y ,0)
    return vec2(x ,y)
end

gui.setParentList = {}
gui.setParentUILayout = {}
gui.styleFunctions = {}

function gui.beginParent(parent, uiLayout)
    if uiLayout and uiLayout.styleFunction ~= nil then
        gui.beginStyle(uiLayout.styleFunction) 
        parent.usesTheStyleFunction = true
        uiLayout.styleFunction = nil
    end
    table.insert(gui.setParentList, parent)
    table.insert(gui.setParentUILayout, uiLayout or {})
end

function gui.endParent()
    local parent = gui.setParentList[#gui.setParentList] 
    table.remove(gui.setParentList, #gui.setParentList)
    table.remove(gui.setParentUILayout, #gui.setParentUILayout)
    if parent.usesTheStyleFunction then
        gui.endStyle()
        parent.usesTheStyleFunction = nil
    end
end

function gui.addItem(...)
    local styleFunction = gui.styleFunctions[#gui.styleFunctions]
    return styleFunction(...)
end

function gui.beginStyle(styleFunction)    
    table.insert(gui.styleFunctions, styleFunction or function() return nil end)
end

function gui.endStyle()
    table.remove(gui.styleFunctions, #gui.styleFunctions)
end 


function gui.checkParameters(numPara, ...)
    local stuff = {...}
    local parent = stuff[1]
    
    local doStretch = false
        
    local parentName = tostring(parent)
    if parentName:sub(1,6) ~= "entity" and parentName:sub(1,6) ~= "ui.can"  then
            
        table.insert(stuff, 1, gui.setParentList[#gui.setParentList])
        doStretch = true
            
    end
        
    local count = 0
    for _ in pairs(stuff) do
        count = count + 1
    end
        
    if count < numPara then
        table.insert(stuff, 2, gui.setParentUILayout[#gui.setParentUILayout])
    end
        
    if doStretch and stuff[2].size == nil then
        stuff[2].stretch = true
    end
    
    
    
    return table.unpack(stuff)
end

function gui.beginDragableList(parent, uiLayout, properties)
    parent, uiLayout, properties = gui.checkParameters(3, parent, uiLayout, properties)
    gui.setUIName("dragableList")
    
    local bas = gui.UI(parent, uiLayout)
    local drag = bas:add(gui.dragableList)
    
    drag.spacing = properties.spacing
    drag.padding = properties.padding
    drag.moveSpeed = properties.moveSpeed
    
    gui.beginParent(bas)
    gui.beginStyle(uiLayout.styleFunction)
    return bas
end

function gui.endDragableList()
    local dragableList = gui.setParentList[#gui.setParentList]
    dragableList:get(gui.dragableList):start()
    gui.endStyle()
   gui.endParent() 
end

function gui.beginStack(theStack, parent, uiLayout, properties)
    parent, uiLayout, properties = gui.checkParameters(3, parent, uiLayout, properties)
    gui.setUIName(theStack)
    
    if properties == true then
        properties = {0,0,true}
    end
    uiLayout[theStack] = properties
    
    local base = gui.UI(parent, uiLayout)
    gui.beginParent(base, uiLayout.childUILayout)
    if uiLayout.testColor then
        base.sprite = asset.Square
        base.color = uiLayout.testColor
    end
    gui.beginStyle(uiLayout.styleFunction)
    return base
end

function gui.beginHStack(parent, uiLayout, properties)
    return gui.beginStack("hstack", parent, uiLayout, properties)
end

function gui.endHStack()
    gui.endStyle()
    gui.endParent()

end

function gui.beginVStack(parent, uiLayout, properties)
    return gui.beginStack("vstack", parent, uiLayout, properties)
end

function gui.endVStack()
    gui.endStyle()
    gui.endParent()
end


function gui.scrollAreaUI(parent, uiLayout, properties)
    parent, uiLayout, properties = gui.checkParameters(3, parent, uiLayout, properties)
    gui.setUIName("scrollArea")
    
    local uiEn = gui.UI(parent, uiLayout)
    local scorllArea = uiEn:add(gui.scrollArea)
    
    scorllArea.content = properties.content
    scorllArea.axis = properties.axis or scorllArea.axis
    
    scorllArea.bounceDamping = properties.bounceDamping or  scorllArea.bounceDamping 
    scorllArea.velocityDamping = properties.velocityDamping or scorllArea.velocityDamping
    scorllArea.pullBackStrength = properties.pullBackStrength or scorllArea.pullBackStrength
    
    
    scorllArea.mouseScrollStrength = scorllArea.mouseScrollStrength or scorllArea.mouseScrollStrength
    
    if properties.sprite then
        uiEn.sprite = properties.sprite
        uiEn.color = properties.color or uiEn.color
    end
        
    return uiEn, scorllArea
end

function gui.scrollBarUI(parent, uiLayout, properties)
    parent, uiLayout, properties = gui.checkParameters(3, parent, uiLayout, properties)
    gui.setUIName("scrollBar")

    local uiEn = gui.UI(parent, uiLayout)
    local scorllBar = uiEn:add(gui.scrollBar, properties.axis or gui.vertical)
    
    if properties.holdStyle then
        for styleName, styleValue in pairs(properties.holdStyle) do
            scorllBar.drag.style[styleName] = styleValue
        end
    end
    
    scorllBar.padding = properties.padding or scorllBar.padding
    scorllBar.moveSpeed = properties.moveSpeed or scorllBar.moveSpeed
    
    uiEn.sprite = properties.sprite or asset.Square
    uiEn.color = properties.color or uiEn.color

    return uiEn, scorllBar
end

function gui.toggleUI(parent, uiLayout, properties)
    parent, uiLayout, properties = gui.checkParameters(3, parent, uiLayout, properties)
    gui.setUIName("toggle")
    
    local uiEn = gui.UI(parent, uiLayout)
    local tog = uiEn:add(gui.toggle)

    if properties.sprites then
        tog.offImg = properties.sprites.off
        tog.onImg = properties.sprites.on
        uiEn.sprite = properties.sprites.off
    end

    if properties.state ~= nil then
        tog:set(properties.state)
    end
    
    return uiEn, tog
end

function gui.buttonUI(parent, uiLayout, properties)
    parent, uiLayout, properties = gui.checkParameters(3, parent, uiLayout, properties)
    gui.setUIName("button")
    
    local uiEn = gui.UI(parent, uiLayout)
    local butto = uiEn:add(gui.button,  properties.noSprite)
    
    if properties.multiplyColor then
        butto.multiplyColor = true
    end


    local validStyles = {
        normal = "normalColor",
        pressed = "pressedColor",
        disabled = "disabledColor",
        selected = "selectedColor",
        hover = "hoverColor"
    }
    
    if properties.style then
        for styleName, styleValue in pairs(properties.style) do
            local fullKey = validStyles[styleName] or styleName -- Map to full key if exists
            butto.style[fullKey] = styleValue
        end
    end
    
    uiEn.sprite = properties.sprite or uiEn.sprite
    uiEn.color = properties.color or uiEn.color

    butto:start()
    return uiEn, butto
end

function gui.dragableUI(parent, uiLayout, properties)
    parent, uiLayout, properties = gui.checkParameters(3, parent, uiLayout, properties)
    gui.setUIName("dragable")
    
    local uiEn = gui.UI(parent, uiLayout)
    local drag = uiEn:add(gui.dragable, properties.axis)
    
    if properties.multiplyColor then
        drag.multiplyColor = true
    end
    
    
    local validStyles = {
        normal = "normalColor",
        pressed = "pressedColor",
        disabled = "disabledColor",
        selected = "selectedColor",
        hover = "hoverColor"
    }
    
    if properties.style then
        for styleName, styleValue in pairs(properties.style) do
            local fullKey = validStyles[styleName] or styleName -- Map to full key if exists
            drag.style[fullKey] = styleValue
        end
    end
    
    uiEn.sprite = properties.sprite or uiEn.sprite
    uiEn.color = properties.color or uiEn.color

    return uiEn, drag
end

function gui.gridUI(parent, uiLayout, properties)
    parent, uiLayout, properties = gui.checkParameters(3, parent, uiLayout, properties)
    gui.setUIName("grid")
    
    local uiEn = gui.UI(parent, uiLayout)
    local gri = uiEn:add(gui.grid)

    if not properties then
        properties = {}
    end
    
    gri.spacing = properties.spacing or gri.spacing
    gri.numCol = properties.numCol or 10

    if properties.padding then
        gri:setPadding(properties.padding)
    end
    
    gri.gridElementStyle = properties.styleFunction or gri.gridElementStyle
    gri.elementSize = properties.elementSize or gri.elementSize
    gri.fitType = properties.fitType or gri.fitType
    
    if properties.sprite then
        uiEn.sprite = properties.sprite or nil
        uiEn.color = properties.color or uiEn.color
    end
    
    return uiEn, gri
end

function gui.labelUI(parent, uiLayout, textProperties)
    parent, uiLayout, textProperties = gui.checkParameters(3, parent, uiLayout, textProperties)
    gui.setUIName("label")
    
    local uiEn = gui.UI(parent, uiLayout)
    local lab = uiEn:add(gui.label)
    lab.text = textProperties.text
    lab.fontSize = textProperties.fontSize or lab.fontSize
    lab.color = textProperties.color or lab.color
    lab.align = textProperties.align or lab.align
    lab.font = textProperties.font or "Futura"
    lab.style = textProperties.style or lab.style
    lab.shouldFit = textProperties.fit or lab.shouldFit
    lab.fitAxis = textProperties.fitAxis or lab.fitAxis
    lab.truncate = textProperties.truncate or false
    lab.truncatePadding =  textProperties.truncatePadding or 0
    
    return uiEn, lab
end

function gui.textInputUI(parent, uiLayout, properties)
    parent, uiLayout, properties = gui.checkParameters(3, parent, uiLayout, properties)
    gui.setUIName("textInput")
    
    local uiEn = gui.UI(parent, uiLayout)
    lab = uiEn:add(gui.label)
    
    if not properties then
        properties = {}
    end

    uiEn.sprite = properties.sprite or asset.Square
    
    local input = uiEn:add(gui.textInput)
    
    input.textAlign = properties.textAlign or input.textAlign
    input.typingText = properties.typingText or input.typingText
    input.placeHolderText = properties.placeHolderText or input.placeHolderText
    input.beginSelect = properties.beginSelect or input.beginSelect
    

    local validStyles = {
        normal = "normalColor",
        selected = "selectedColor",
        hover = "hoverColor",
        placeHolder = "placeHolderColor",
        typing = "typingColor",
        cursorSelect = "cursorSelectColor",
        cursorFlicker = "cursorFlickerColor",
        hoverSelected = "hoverSelectedColor"
    }
    
    if properties.style then
        for styleName, styleValue in pairs(properties.style) do
            local fullKey = validStyles[styleName] or styleName -- Map to full key if exists
            input.style[fullKey] = styleValue
        end
    end
    
    input.padding = properties.padding or input.padding
    input.cursorSize.x = properties.cursorWidth or input.cursorSize.x
    input.cursorSize.y = properties.cursorHeight or input.cursorSize.y
    input.label.fontSize = properties.fontSize or input.label.fontSize
    input.label.font = properties.font or "Futura"
    
    return uiEn, input
end

function gui.squareUI(parent, uiLayout, col)
    parent, uiLayout, col = gui.checkParameters(3, parent, uiLayout, col)
    gui.setUIName("square")
    
    local squareImg = gui.imageUI(parent, uiLayout, asset.Square)
    squareImg.color = col or squareImg.color  
    return squareImg
end

function gui.imageUI(parent, uiLayout, img)
    parent, uiLayout, img = gui.checkParameters(3, parent, uiLayout, img)
    gui.setUIName("image")
    
    local uiEn = gui.UI(parent, uiLayout)
    uiEn.sprite = img
    
    return uiEn
end

function gui.UI(parent, uiLayout)
    local parent, uiLayout = gui.checkParameters(2, parent, uiLayout)

    local uiEn = nil
    local uiName = gui.retrieveNameOfUI()

    if uiLayout.fake then
        if not parent:has(gui.fakeChild) then
            parent:add(gui.fakeChild)
        end
        uiEn = parent:fakeChild(uiLayout.name or uiName, uiLayout.fake[1])
    else
        uiEn = parent:child(uiLayout.name or uiName)
    end
    
    setBasics(uiLayout, uiEn)
    setComponents(uiLayout, uiEn)

    return uiEn
end

gui.currentUIStackName = nil

function gui.retrieveNameOfUI()
    local name = gui.currentUIStackName ~= nil and gui.currentUIStackName or "ui"
    gui.currentUIStackName = nil
    return name
end

function gui.setUIName(name)
    gui.currentUIStackName = gui.currentUIStackName == nil and name or gui.currentUIStackName
end

function gui.setUILayout(uiEn, uiLayout)
    setBasics(uiLayout, uiEn)
    setComponents(uiLayout, uiEn)
end


function setComponents(uiLayout, uiEn)
    if uiLayout.vstack then
        if uiLayout.vstack == true then
            uiLayout.vstack = {0,0,true}
        end
        uiEn:add(gui.vstack,table.unpack(uiLayout.vstack))
    end

    if uiLayout.hstack then
        if uiLayout.hstack == true then
            uiLayout.hstack = {0,0,true}
        end
        uiEn:add(gui.hstack,table.unpack(uiLayout.hstack))
end

    if uiLayout.fitImage then
        if type(uiLayout.fitImage) ~= "table" then
            uiLayout.fitImage = {uiLayout.fitImage}
        end
        uiEn:add(gui.fitImage, table.unpack(uiLayout.fitImage) )
    end

    if uiLayout.fitChildren then
        if uiLayout.fitChildren == true then
            uiLayout.fitChildren = {0}
        end
        uiEn:add(gui.fitChildren, table.unpack(uiLayout.fitChildren))
    end

    if uiLayout.hitTest then
        uiEn.hitTest = uiLayout.hitTest
    end
    
    if uiLayout.hoverTest then
        uiEn.hoverTest = uiLayout.hoverTest
    end
    uiEn.stretch = uiLayout.stretch
        
    if uiLayout.clip ~= nil then
        uiEn.clip = uiLayout.clip
    end
end

function setBasics(uiLayout, uiEn)
    

    if uiLayout.layout then
        setLayout(uiLayout)
    end

    if uiLayout.x then
        uiLayout.pos = vec2(uiLayout.x, 0)
    elseif uiLayout.y then
        uiLayout.pos = vec2(0, uiLayout.y)
    end

    if uiLayout.pos then
        local sce = uiLayout.fake and "f" or ""
        uiEn[sce.."x"] = uiLayout.pos.x
        uiEn[sce.."y"] = uiLayout.pos.y
    end

    if uiLayout.anchor == STRETCH and uiLayout.size == nil then
        uiLayout.size = vec2(0)
    end

    if uiLayout.size then
        if type(uiLayout.size) == "number" then
            uiLayout.size = vec2(uiLayout.size)
        end
        uiEn.size = uiLayout.size
    end
    
    
    
    if uiLayout.anchor then
        
        uiLayout.anchor = uiLayout.anchor == STRETCH and {STRETCH, STRETCH} or uiLayout.anchor
        uiEn:anchor(uiLayout.anchor[1], uiLayout.anchor[2])
    end

    
    if uiLayout.pivot then
        uiEn.pivot = uiLayout.pivot
    end
end

function setLayout(uiLayout)
    local anchorLay = nil
    local pos = nil
    if type(uiLayout.layout) == "string" then
        anchorLay = string.upper(uiLayout.layout)
    else
        anchorLay = string.upper(uiLayout.layout[1])
        pos = uiLayout.layout[2]
    end

    if uiLayout.fake then
        setFakeLayout(uiLayout, anchorLay, pos)
    else
        setRealLayout(uiLayout, anchorLay, pos)
    end
end

function setRealLayout(uiLayout, anchorLay, pos)
    if anchorLay == "TOP" then
        uiLayout.anchor = {CENTER, TOP}
        uiLayout.pos = pos and vec2(0, -pos) or uiLayout.pos 
        uiLayout.pivot = vec2(0.5, 1)
    elseif anchorLay == "RIGHTTOP" or anchorLay == "TOPRIGHT" then
        uiLayout.anchor = {RIGHT, TOP}
        uiLayout.pos = pos and vec2(-pos, -pos) or uiLayout.pos 
        uiLayout.pivot = vec2(1, 1)
    elseif anchorLay == "RIGHT" then
        uiLayout.anchor = {RIGHT, MIDDLE}
        uiLayout.pos = pos and vec2(-pos,0) or uiLayout.pos 
        uiLayout.pivot = vec2(1, 0.5)
    elseif anchorLay == "RIGHTBOTTOM" or anchorLay == "BOTTOMRIGHT" then
        uiLayout.anchor = {RIGHT, BOTTOM}
        uiLayout.pos = pos and vec2(-pos,pos) or uiLayout.pos 
        uiLayout.pivot = vec2(1, 0)
    elseif anchorLay == "BOTTOM" then
        uiLayout.anchor = {CENTER, BOTTOM}
        uiLayout.pos = pos and vec2(0,pos) or uiLayout.pos 
        uiLayout.pivot = vec2(0.5, 0)
    elseif anchorLay == "LEFTBOTTOM" or anchorLay == "BOTTOMLEFT" then
        uiLayout.anchor = {LEFT, BOTTOM}
        uiLayout.pos = pos and vec2(pos,pos) or uiLayout.pos 
        uiLayout.pivot = vec2(0, 0)
    elseif anchorLay == "LEFT" then
        uiLayout.anchor = {LEFT, MIDDLE}
        uiLayout.pos = pos and vec2(pos,0) or uiLayout.pos 
        uiLayout.pivot = vec2(0, 0.5)
    elseif anchorLay == "LEFTTOP" or anchorLay == "TOPLEFT" then
        uiLayout.anchor = {LEFT, TOP}
        uiLayout.pos = pos and vec2(pos,-pos) or uiLayout.pos 
        uiLayout.pivot = vec2(0, 1)
    end
end

function setFakeLayout(uiLayout, anchorLay, pos)
    if anchorLay == "TOP" then
        uiLayout.anchor = {CENTER, TOP}
        uiLayout.pos = pos and vec2(0, pos)
        uiLayout.pivot = vec2(0.5, 0)
    elseif anchorLay == "RIGHTTOP" or anchorLay == "TOPRIGHT" then
        uiLayout.anchor = {RIGHT, TOP}
        uiLayout.pos = pos and vec2(pos, pos)
        uiLayout.pivot = vec2(0, 0)
    elseif anchorLay == "RIGHT" then
        uiLayout.anchor = {RIGHT, MIDDLE}
        uiLayout.pos = pos and vec2(pos,0) 
        uiLayout.pivot = vec2(0, 0.5)
    elseif anchorLay == "RIGHTBOTTOM" or anchorLay == "BOTTOMRIGHT" then
        uiLayout.anchor = {RIGHT, BOTTOM}
        uiLayout.pos = pos and vec2(pos,-pos) 
        uiLayout.pivot = vec2(0, 1)
    elseif anchorLay == "BOTTOM" then
        uiLayout.anchor = {CENTER, BOTTOM}
        uiLayout.pos = pos and vec2(0,-pos) 
        uiLayout.pivot = vec2(0.5, 1)
    elseif anchorLay == "LEFTBOTTOM" or anchorLay == "BOTTOMLEFT" then
        uiLayout.anchor = {LEFT, BOTTOM}
        uiLayout.pos = pos and vec2(-pos,-pos) 
        uiLayout.pivot = vec2(1, 1)
    elseif anchorLay == "LEFT" then
        uiLayout.anchor = {LEFT, MIDDLE}
        uiLayout.pos = pos and vec2(-pos,0) 
        uiLayout.pivot = vec2(1, 0.5)
    elseif anchorLay == "LEFTTOP" or anchorLay == "TOPLEFT" then
        uiLayout.anchor = {LEFT, TOP}
        uiLayout.pos = pos and vec2(-pos,pos) 
        uiLayout.pivot = vec2(1, 0)
    end
end
