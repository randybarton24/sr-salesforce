({
	getAddendumLineItems : function(component, event, helper) {
        component.set("v.openAddendumLineItems", []);
        var AddID = component.get("v.recordId");        
        var action = component.get("c.getAllAddendumLineItems");
        action.setParams({
            addendumId: AddID
        });
        action.setCallback(this, function (response) {
            var name = response.getState();
            if (name === "SUCCESS") 
            {
                var items = response.getReturnValue();
                
                component.set("v.openAddendumLineItems", items);  

                if (items.length > 0)
                {                                   
                    component.set("v.key", "tabId0");        
                }
                else
                {
                    component.set("v.key", "");   
                }
            }                     
        });
        $A.enqueueAction(action); 
	} 
})