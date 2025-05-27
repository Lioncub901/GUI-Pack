TextAlert = class()

function TextAlert:init(title, message, actionTitle)
    self.title = title
    self.message = message
    self.actionTitle = actionTitle or "Submit"
end

function TextAlert:present(result)
    local alertController = objc.UIAlertController()
    alertController.title = self.title
    alertController.message = self.message
    alertController.preferredStyle = objc.enum.UIAlertControllerStyle.alert
    
    function submitPressed(objAction)
        local field = alertController.textFields[1]
        
        if result ~= nil and field ~= nil then 
            result(field.text)
        end        
    end
    
    local action = objc.UIAlertAction:actionWithTitle_style_handler_(self.actionTitle, objc.enum.UIAlertActionStyle.default, submitPressed)
    
    alertController:addAction_(action)
    alertController:addTextFieldWithConfigurationHandler_(nil)
    
    objc.viewer:presentViewController_animated_completion_(alertController, true, nil)
end

function createAlertBox(title, message, func)
    myAlert = TextAlert(title, message)
    myAlert:present(func)
end
