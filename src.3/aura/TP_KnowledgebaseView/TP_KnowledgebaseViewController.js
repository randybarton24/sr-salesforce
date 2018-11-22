({
	doinit : function(component, event, helper) {
		var action = component.get("c.getTopSixTopics");
        action.setCallback(this, function(data) {            
        	component.set("v.topicList",data.getReturnValue());
        });
        $A.enqueueAction(action);
	},
    gotoTopicDetail : function(component, event, helper) {
        //var topicId = document.getElementsByClassName("kbaseCss")[0].id;        
        debugger; 
        console.log('####-'+event.target.parentNode.id);
        var topicId = event.target.parentNode.id; 
        var urlEvent = $A.get("e.force:navigateToURL");               
        urlEvent.setParams({
            "url": "/topic/"+topicId            
        });
        urlEvent.fire();
    }    
})