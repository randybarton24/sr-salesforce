({
    doInit : function(component, event, helper) {
        var action = component.get('c.getUserName');
        action.setCallback(this, function(data) {
            var loggedInUserName = data.getReturnValue();
            if(loggedInUserName.includes('Site Guest User')){
                 var chatBotElement = component.find('chatBotWrapper');
                 $A.util.addClass(chatBotElement, 'slds-hide');                                            
            }                       
        });
        $A.enqueueAction(action); 
    }
})