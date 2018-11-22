({
	getPlaybookCase : function(component, event, helper) {
	    console.log('getting playbook cases');
	    var acctId = component.get("v.recordId");
	    console.log('Record Id: ', acctId);
	    var action = component.get("c.getPlaybookCaseApx");
	    action.setParams({
            acctId : acctId
        });

        action.setCallback(this, function (response) {
            console.log('Cases Returned',response.getReturnValue());
            var name = response.getState();
            if (name === "SUCCESS") {
                component.set("v.openCases", response.getReturnValue());
            }
            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
		
	},

    showToast : function(component, event, helper){

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : "success",
            "message": "This has been added to you Account"
        });

        toastEvent.fire();
    },

    handlePlaybookSpinner : function (component, event, helper) {
        var status = event.getParam("status");
        component.set("v.showSpinner", status);

    },

})