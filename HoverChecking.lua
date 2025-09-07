function gui.isInside(enti, pos)
    return pos.x >= enti.worldPosition.x and pos.y >= enti.worldPosition.y and pos.x <= enti.worldPosition.x + enti.size.x and pos.y <= enti.worldPosition.y  + enti.size.y
end

function gui.wasHovered(enti, conditionFunction)
    local newMouse = gui.mapMouseToScene(mouse, enti.scene)
    if not enti.valid and not enti.hoverTest or not gui.wasInside(enti, newMouse) then
        return false
    end
    
    return enti == gui.insideTest(enti.scene, newMouse, "hoverTest", conditionFunction) 
end

function gui.getHoveredEntity(scen, conditionFunction)
    local newMouse = gui.mapMouseToScene(mouse, scen)
    return gui.insideTest(scen, newMouse, "hoverTest", conditionFunction) 
end


function gui.wasTouched(enti, conditionFunction)
    local newCurrentTouch = gui.mapTouchToScene(CurrentTouch, enti.scene)
    if not enti.valid and not enti.hitTest or not gui.wasInside(enti, newCurrentTouch) then
        return false
    end
    
    return enti == gui.insideTest(enti.scene, newCurrentTouch, "hitTest", conditionFunction)  
end

function gui.getTouchedEntity(scen, conditionFunction)
    local newCurrentTouch = gui.mapTouchToScene(CurrentTouch, scen)
    return gui.insideTest(scen, newCurrentTouch, "hitTest", conditionFunction)  
end

function gui.insideTest(scen, pos, property, conditionFunction)
    local scenName = scen.name
    if typeof(property) == "string" then
        if gui[scenName..property.."Time"] == nil then
            gui[scenName..property.."Time"] = 0
            gui[scenName..property.."Entity"] = nil
        end
        
        if time.elapsed ~= gui[scenName..property.."Time"] then
            gui[scenName..property.."Time"] = time.elapsed
            gui[scenName..property.."Entity"] = gui.insideHeavyTest(scen, pos, property, conditionFunction)
        end
        
        return  gui[scenName..property.."Entity"]
    end
    return gui.insideHeavyTest(scen, pos, property, conditionFunction)
end

function gui.insideHeavyTest(scen, pos, property, conditionFunction)
    conditionFunction = conditionFunction or function(en) return true end
    local uiList = scen.canvas.entity:getAllChildren()
    for k = #uiList, 1, -1 do
        local uiEnti = uiList[k]
        if uiEnti.valid and uiEnti.active and gui.hasProperties(uiEnti, property) and conditionFunction(uiEnti) and gui.wasInside(uiEnti, pos) then
            return uiEnti 
        end
    end
    return nil
end


function gui.wasInside(enti, pos)
    if enti then
        local currentEntity = enti
        repeat
            if not gui.isInside(currentEntity, pos) or not currentEntity.active then
                return false
            end
            currentEntity = currentEntity.parent
        until currentEntity == nil or currentEntity.depth == 0
        return true
    end
    return false
end



function gui.hasProperties(uiEnti, property)
    if type(property) == "string" then
        return uiEnti[property]
    else
        for k, singleProperty in ipairs(property) do
            if uiEnti[singleProperty] then
                return true
            end
        end
    end
    return false
end

function gui.getPivotFromPos(enti, pos)
    if gui.wasInside(enti, pos) then
        local toPos = pos - vec2(enti.worldPosition.x, enti.worldPosition.y)
        local pivot = toPos / enti.size
        return pivot
    end
    return vec2(0.5)
end

function gui.clearChildren(enti)
    if #enti.children > 0 then
        for k, childEnti in ipairs(enti.children) do
            childEnti:destroy()
        end
    end
end