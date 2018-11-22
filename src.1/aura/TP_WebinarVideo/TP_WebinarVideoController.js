({
	doinit : function(component, event, helper) {
		var recordId = helper.getParameterByName(component, event, "recordId");        
        var action = component.get("c.getSelectedWebinar");
        action.setParams({ webinarId : recordId });
        action.setCallback(this, function(data) {               
        	component.set("v.KB_Webinar",data.getReturnValue());                        
        });
        $A.enqueueAction(action);        
	}
})