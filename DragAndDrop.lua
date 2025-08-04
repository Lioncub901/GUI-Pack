if not gui then
    gui = {}
end    

gui.dragAndDrop = class("gui.dragAndDrop",component)

gui.draggingEntity = nil
gui.draggedEntity = nil
gui.dragItems = nil

function gui.dragAndDrop:created(allowDrag)
    self.entity.dragAndDropTest = true
    self.allowDrag = allowDrag
    if allowDrag == nil then
        self.allowDrag = true
    end
    self.dragDistance = 6.5
    table.insert(gui.dragAndDrop.list, self.entity)
end

gui.dragAndDrop.list = {}

gui.beginTouchPos = nil
function gui.dragAndDrop.handleDrag(touch, scen)
    if touch.began and gui.draggedEntity == nil then
        gui.draggedEntity = gui.insideTest(scen, touch.pos, {"hitTest", "dragAndDropTest"})
        if gui.draggedEntity and gui.draggedEntity.dragAndDropTest and gui.draggedEntity:get(gui.dragAndDrop).allowDrag then
            gui.draggedEntity.needToAddDragItem = true
            gui.beginTouchPos = touch.pos
        else
            gui.draggedEntity = nil
        end   
    end
    
    if gui.draggedEntity and not gui.draggedEntity.valid then
        gui.dragAndDrop.destroyDrop()
    elseif gui.draggedEntity then
        gui.dragAndDrop.handleDragging(touch, scen)
    end
end


function gui.dragAndDrop.handleDragging(touch, scen)

    if touch.moving and gui.draggedEntity.needToAddDragItem and (touch.pos - gui.beginTouchPos).length > gui.draggedEntity:get(gui.dragAndDrop).dragDistance then
        gui.draggingEntity = gui.squareUI(gui.draggedEntity.scene.canvas, {name = "new", anchor = {LEFT, BOTTOM}, pivot = vec2(0,1)}, color(128))
        gui.draggedEntity:dispatch("onDrag")
        gui.draggedEntity.needToAddDragItem = nil
    end
    
    if gui.draggingEntity then
        local scal = gui.draggingEntity.scene.canvas.scale

        local offset = gui.draggingOffset or vec2(0)
        gui.draggingEntity.x = touch.x * scal + offset.x
        gui.draggingEntity.y = touch.y * scal + offset.y
    end
   
    if (touch.ended or touch.cancelled) then
        local droppedEntity = gui.insideTest(scen, touch.pos, "dragAndDropTest", function(enti)
            return enti.valid and enti.active and gui.dragAndDrop.passCondition(enti)
        end)
        
        if gui.draggingEntity then
            if droppedEntity then 
                gui.draggedEntity:dispatch("onWasDropped")
                if droppedEntity ~= gui.draggedEntity then
                    droppedEntity:dispatch("onDrop")
                end
            else
                gui.draggedEntity:dispatch("onNoDrop")
            end
        end
            
        gui.draggedEntity.needToAddDragItem = nil
        gui.dragAndDrop.destroyDrop()
    end
end

function gui.dragAndDrop:destroyed()
    for k, enti in ipairs(gui.dragAndDrop.list) do
        if enti == self.entity then
            table.remove(gui.dragAndDrop.list, k)
            break
        end
    end
end

function gui.dragAndDrop.passCondition(enti)
    if enti.dropCondition then
        return enti.dropCondition()
    end
    return false
end

function gui.dragAndDrop.destroyDrop()
    if gui.draggingEntity and gui.draggingEntity.valid then
        gui.draggingEntity:destroy()
    end
    gui.draggingEntity = nil
    gui.draggedEntity = nil
    gui.dragItems = nil
    gui.draggingOffset = nil
end

Profiler.wrapClass(gui.dragAndDrop)