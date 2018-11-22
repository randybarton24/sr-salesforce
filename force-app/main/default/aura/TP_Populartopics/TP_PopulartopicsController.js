({
	doinit : function(component, event, helper) {
		var action = component.get("c.getTopics");
        action.setCallback(this, function(data) {
            //debugger;
            console.log(data.getReturnValue());
        	component.set("v.pTopics",data.getReturnValue());
        });
        $A.enqueueAction(action);
	},
    showAllTopics : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/alltopics"
        });
        urlEvent.fire();
    },
    removeCss : function(component, event, helper) {
        var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');        
    }
})