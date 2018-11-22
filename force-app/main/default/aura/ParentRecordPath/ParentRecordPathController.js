({
    recordUpdate : function(component) {       
        var countPath = component.find({ instancesOf : "lightning:path" }).length;        
        if (countPath === 0) {
            $A.createComponent(
                "lightning:path",
                {
                    "aura:id": "path",
                    "recordId": component.get("v.childRecord.Active_Opportunity__c"),
                    "variant": component.get("v.variant"),
                    "hideUpdateButton": component.get("v.hideUpdateButton"),
                    "onselect": component.getReference("c.handleSelect")
                },
                function (newPath, status, errorMessage) {
                    //Add the new button to the body array
                    if (status === "SUCCESS") {
                        var body = component.get("v.body");
                        body.push(newPath);
                        component.set("v.body", body);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                        // Show offline error
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
                }
            );
        }
    },        
    handleSelect : function (component, event, helper) {
        var stepName = event.getParam("detail").value;     
        var toastEvent = $A.get("e.force:showToast");
        var buttonName =  stepName === "Closed" ? "Select Closed Stage" : "Mark as Current Stage";
        toastEvent.setParams({
            "title": "Almost Done!",
            "message": "Click \" "+ buttonName +"\" to change the stage to " + stepName
        });
        
        toastEvent.fire();
    }
})