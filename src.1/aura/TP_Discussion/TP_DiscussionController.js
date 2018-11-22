({
	doinit : function(component, event, helper) {
		var action = component.get("c.getFeedItems");
        action.setCallback(this, function(data) {
            console.log(data.getReturnValue());
        	component.set("v.c_feedItems", data.getReturnValue());        	
        });
        $A.enqueueAction(action);
	},
    removeCss : function(component, event, helper) {
        var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');        
    },
    showAllDiscussion : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/alldiscussion"
        });
        urlEvent.fire();
    }
})