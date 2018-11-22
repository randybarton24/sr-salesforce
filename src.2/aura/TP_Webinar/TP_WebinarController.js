({
	doinit : function(component, event, helper) {
		var action = component.get("c.getWebinars");
        action.setCallback(this, function(data) {            
        	component.set("v.webinarList",data.getReturnValue());
        });
        $A.enqueueAction(action);
        
        var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');
	},
    navigateToWebinarVideo : function (component, event, helper) {  
        debugger;
        var rcdId = event.target.parentNode.id;        
        var urlEvent = $A.get("e.force:navigateToURL");               
        urlEvent.setParams({
            "url": "/webinarvideo?recordId="+rcdId,            
        });
        urlEvent.fire();
    },
    navigateToArticle : function (component, event, helper) {
        debugger;
        //event.currentTarget.id
        //var rcdId = event.target.parentNode.id;            
        var rcdId = event.currentTarget.id;
        var urlEvent = $A.get("e.force:navigateToURL");               
        urlEvent.setParams({
            "url": "/article/"+rcdId,            
        });
        urlEvent.fire();
    }
})