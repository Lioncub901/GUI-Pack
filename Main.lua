-- Modern
require(asset.icloud.Mouse_Support)
require(asset.icloud.Entity_Plus)

if not gui then
    gui = {}
end    

-- Use this function to perform your initial setup
function setup()
    viewer.mode = FULLSCREEN
    gameWorld = scene.default2d()
    --scene.main = gameWorld
    
    --Sim:
    gameWorld.canvas.scale = 1.1
    --Change the units of the 2d scene
    gameWorld.camera:get(camera).orthoSize = 24
    gameWorld.pixelsPerUnit = 64
    gameWorld.time.autoUpdate = false
    gameWorld.camera:get(camera).clearColor = color(40, 40, 50)
    
    --uxl.readFile(asset.documents.TestUxl)
    --style.font()
    
    -- sliders 
    -- wrap around text.                                             

    -- file dropdown
    -- scene order
    -- fix sliders
    
    --[=[
    
    progressBar = gameWorld.canvas:child("bar")
    progressBar.size = vec2(500,50)
    progressBar.sprite = asset.Square
    progressBar.color = color(233, 226, 80)
    bar = progressBar:add(gui.progressBar)
    progressBar.y = 100
    
    bar.spacing = 2]=]
    
    --[[textfield = gameWorld.canvas:child("textField")
    textfield.size = vec2(300,50)
    textfield.sprite = asset.Square
    textfield.color = color(234, 107, 75)
    local drop = textfield:add(gui.dropDown)
    drop:addItem("here")
    drop:addItem("every")
    drop:addItem("week")
    print(drop.container)
    drop.container.color =  color(234, 83, 75)
    textfield.size = vec2(500, 50)
    
    
    textfield.onItemSelected = function(lol, num)
        print(num)
    end]]
    
                 
   --[=[ local sty = function(num)
        local ele = gui.buttonUI(gameWorld.canvas, "ele", {}, {sprite = asset.Square})
        ele.onTapped = function()
            print("tapped button ".. num)
        end
        return ele
    end
    
    local p = gui.squareUI(gameWorld.canvas, "dfs", {pos = vec2(25,-50), layout = {"TOP"}, size = vec2(1000, 500)}, color(222, 78, 69))
    
    here, gri = gui.gridUI(p, "nice", {layout = {"TOP"}, size = vec2(350, 500)},{sprite = asset.Square, color = color(65), fitType = "fit", padding = vec2(50, 20), styleFunction = sty})
    
    for k = 1, 35 do
        gri:addElement()
    end]=]
    
    --slider = gui.squareUI(gameWorld.canvas, "nice",  {pos = vec2(0, -100), size = vec2(400,50)}, color(255))
    --slider:add(gui.progressBar)
    
   --[=[pres = gameWorld.canvas:child("bar")
    pres.size = vec2(200)
    pres.sprite = asset.Square
    pres.y = -300
    
    
    local colorPicker = gameWorld.canvas:child("colorPicker")
    
    colorPicker.size = vec2(700, 500)
    colorPicker.sprite = asset.Square
    colorPicker.color = color(0, 70)
    colorPicker.y = 230
    colorPicker:add(gui.fitChildren, 20)
    
    picker = colorPicker:add(gui.colorPicker)
    
    
    
    
    local satValue = colorPicker:child("colorPicker")
    
    satValue.size = vec2(170)
    satValue.x = -40

    
    
    box = satValue:add(gui.pickerBox)
    picker.pickerShape = satValue
    
    local hueSlider = colorPicker:child("hueSlider")
    
    hueSlider.size = vec2(25, 170)
    hueSlider.x = 75
    
    hueSlider:add(gui.hueSlider)
    picker.hueShape = hueSlider
    
    local alphaSlider = colorPicker:child("alphaSlider")
    
    alphaSlider.size = vec2(25, 170)
    alphaSlider.x = 110
    
    alphaSlider:add(gui.alphaSlider)
    picker.alphaShape = alphaSlider
    
    local hexInput = colorPicker:child("hexInput")
    
    hexInput.size = vec2(250, 35)
    hexInput.sprite = asset.Square
    hexInput.y = -120
    
    hexInput:add(gui.hexInput)
    picker.hexInput = hexInput]=]
    
    

    
    scrollBar1 = gameWorld.canvas:child("scrollBar")
    bar = scrollBar1:add(gui.scrollBar, gui.vertical)
    scrollBar1.size = vec2(20,500)
    scrollBar1.x = 400
    
    scrollArea = gameWorld.canvas:child("scroll")
    scrollArea.size = vec2(200,300)
    scr = scrollArea:add(gui.scrollArea,  gui.vertical)
    scr.verticalBar = scrollBar1
    scrollArea.sprite = asset.Square
    scrollArea.color = color(195, 45, 45)
    
    
    container = scrollArea:child("content")
    container.size = vec2(200,500)
    container.sprite = asset.Square
    container.color = color(128)
    collapse = container:add(gui.collapse)
    --print(scr)

    list = 
    {
        {depth = 1,content =  {"Hats"}},
        {depth = 2,content =  {"Cap"}},
        {depth = 2, content = {"Beanie"}},
        {depth = 3,content =  {"Cuffless"}},
        {depth = 3,content =  {"Cuffed"}},
        {depth = 1, content =  {"Tops"}},
        {depth = 2, content =  {"Shirt"}},
        {depth = 2, content =  {"Singlet"}},
        {depth = 2, content =  {"Coat"}},
        {depth = 1, content =  {"Pants"}},
        {depth = 2, content =  {"Jeans"}},
        {depth = 2, content =  {"Shorts"}},
        {depth = 2, content =  {"Underwear"}},
        {depth = 3, content =  {"Boxers"}},
        {depth = 3, content =  {"Briefs"}},
        {depth = 4, content =  {"Shortly"}},
        {depth = 3, content =  {"Tunks"}},
    }

    collapse:addList(list)
  --  local uio = collapse:addItem({1, {"Hats"}}, 17 + 1)

    --pri = collapse:moveToEnd(1)
    
    
    scr.content = container
--[[
    names = function()
        local item = gameWorld.canvas:child("content")
        item.size = vec2(100,28)
        item.sprite = asset.Square
        item.color = color(128)
        --collapse = container:add(gui.dragAndDrop, true, false)
        return  item
    end
    
    local container =   gameWorld.canvas:child("content")
    collapse = container:add(gui.menuBar, names)
    container.size = vec2(28)
    
    fileList = 
    {
        {item = {"Hats"},
            children = {
                {item = {"Cap"}},
                {item = {"Beanie"},
                    children = {
                        {item = {"Cuffless"}}
                    }
                },
                {item = {"Cap"}},
                {item =  {"Beanie"},
                    children = {
                        {item = {"Cuffless"}},
                        {item =  {"Cuffed"}}
                    }
                }
            },
        },
        {item = {"Tops"},
            children = {
                {item = {"Shirt"}},
                {item = {"Singlet"}},
                {item = {"Coat"}}
            },
        },
        {item = {"Pants"},
            children = {
                {item = {"Jeans"}},
                {item = {"Shorts"}},
                {item =  {"Underwear"},
                    children = {
                        {item = {"Boxers"}},
                        {item =  {"Briefs"},
                            children = {
                                {item = {"Boxers"}}
                            }
                        },
                        {item = {"Tunks"}}
                    }
                }
            },
        },
    }
    
    collapse:addItem("hey",fileList)
    collapse:addItem("hey",fileList)
    collapse:addItem("hey",fileList)
    ]]
    
    
    
    gameWorld:start()
 
end



-- This function gets called once every frame
function draw()
    --container.size = vec2(300 + 200 * math.sin(time.elapsed), 50) 
    gameWorld:update(time.delta)
    gameWorld:draw()

    --style.textStyle(TEXT_BOLD)
    --style.font("Heiti SC")
    text( "👍⇥⌫↵⎋↑↓→←␣⇧⌘c你好", 400, 400, 200, 300)
end

function touched(touch)
    fixMouse(touch)
    gameWorld:touched(touch)
   
end


--[=[
container = gameWorld.canvas:child("content")
container.size = vec2(100,28)
container.sprite = asset.Square
container.color = color(128)
--collapse = container:add(gui.dragAndDrop, true, false)

collapse = container:add(gui.menuButton)


fileList = 
{
{label = {"Hats"},
children = {
{label = {"Cap"}},
{label = {"Beanie"},
children = {
label = {"Cuffless"}
}
},
{label = {"Cap"}},
{label =  {"Beanie"},
children = {
{label = {"Cuffless"}},
{label =  {"Cuffed"}}
}
}
},
},
{label = {"Tops"},
children = {
{label = {"Shirt"}},
{label = {"Singlet"}},
{label = {"Coat"}}
},
},
{label = {"Pants"},
children = {
{label = {"Jeans"}},
{label = {"Shorts"}},
{label =  {"Underwear"},
children = {
{label = {"Boxers"}},
{label =  {"Briefs"},
children = {
{label = {"Boxers"}}
}
},
{label = {"Tunks"}}
}
}
},
},
}

collapse:addList(fileList)
]=]