({
	doInit : function(component, event, helper) {		
		var addendumId = component.get("v.recordId", true); 
        helper.getAddendumLineItems(component, event, helper);       	
	},
	selectTab : function(component, event, helper) {        
        var selected = component.get("v.key");
        component.find("tabs").set("v.selectedTabId", selected);
    }	
})