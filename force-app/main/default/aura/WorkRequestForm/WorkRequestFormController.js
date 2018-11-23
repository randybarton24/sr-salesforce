({
    handleCreate : function(component, event, helper) {
        var validRequest = component.find('workrequestform').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        // If we pass error checking, do some real work
        if(validRequest){
            var btn = event.getSource();
            btn.set("v.disabled",true);
            // Create the new request
            var newRequest = component.get("v.newRequest");
            console.log("Create Request: " + JSON.stringify(newRequest));
            helper.createRequest(component, event, newRequest);
        }
    },
    
    onCategoryChange : function(component, event, helper) {
        var selectedCategory = event.getSource().get("v.value");
        
        if(selectedCategory === "Bug"){
            component.set("v.newRequest.agf__Details__c", "-Expected Behavior:\n\n-Actual Behavior/Error Message(Attach screenshot(s) in next screen):\n\n-Steps to Reproduce:\n  1.\n  2.\n\n-How many users are impacted?\n\n-Is there currently a workaround in place?");    
        } else if(selectedCategory === "Feature Request"){
            component.set("v.newRequest.agf__Details__c", "-What problem or issue are we solving for?\n\n-Current solution:\n\n-Potential/Proposed Solution:\n\n-What teams will use or will be affected by this change?");        
        } else if(selectedCategory === "Access Request"){
            component.set("v.newRequest.agf__Details__c", "-What system, object, field, etc. do you need access to?\n\n-What is the reason for the change in access? (ie. Team change, new employee, etc.)\n\n-Who is an example of someone that has the level of access you are requesting?");        
        } else if(selectedCategory === "Data Change Request"){
            component.set("v.newRequest.agf__Details__c", "-What data needs to be changed? (ie.Subscriber ID, Closed Won, MRFMS, ISB Status, Duplicates to be Merged, CalendarAnything, List Upload, etc.)\n\n-What are the URL(s) for the data to be changed (for uploads, attach file(s) in next screen):\n  1.\n  2.");        
        } else if(selectedCategory === "Reporting Request"){
            component.set("v.newRequest.agf__Details__c", "What insight are we trying to get from the data?\n\n-Where is the data stored(which objects/fields do we need to see)?\n\n-Are we starting from scratch or is there an existing report/dashboard to be modified?");        
        }    
        var categoryChange = $A.get("e.c:categoryChange");
        categoryChange.setParams({ "selectedCategory": selectedCategory });
        categoryChange.fire();
    },
})