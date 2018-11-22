/**
 * Created by mschetselaar on 9/1/2018.
 */
({
    getPlaybookList: function (component, event, helper) {
        var action = component.get("c.getPlaybookAsList");

        action.setCallback(this, function (response) {

            console.log('List Returned',response.getReturnValue());
            var name = response.getState();
            if (name === "SUCCESS") {
                component.set("v.options", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);

    },


    addPlaybook: function (component, event, helper) {
        var acctId = component.get("v.acctId");
        var selectedPlaybook = component.get("v.selectedPlaybook");
        var action = component.get("c.addPlaybookCaseApx");
        action.setParams({
            acctId : acctId ,
            playbookId :selectedPlaybook
        });

        action.setCallback(this, function (response) {
            console.log("updated Case: ", response.getState());
            var name = response.getState();
            if (name === "SUCCESS") {

                helper.updateCases(component, event, helper, true);
            }
        });

        $A.enqueueAction(action);

    },

    updateSpinner : function (component, event, helper, status) {
        var updateEvent = component.getEvent("updateSpinner");
        updateEvent.setParams({ "status" : status});
        updateEvent.fire();

    },

    updateCases : function (component, event, helper, success) {
        var updateCases = component.getEvent("updateCases");
        updateCases.setParams({"success" : success});
        updateCases.fire();
        console.log("event fired");
    }

})