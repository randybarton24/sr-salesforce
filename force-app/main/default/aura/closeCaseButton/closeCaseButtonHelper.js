/**
 * Created by mschetselaar on 9/7/2018.
 */
({
    closeCase : function (component, event, helper) {
        console.log("In the Helper now");
        var CaseID = component.get("v.CaseID");
        console.log("CaseID: ", CaseID);
        var action = component.get("c.closePlaybookCaseApx");
        action.setParams({
            CaseID : CaseID,
            "resolution" : component.get("v.Resolution"),
            "resDescription" : component.get("v.ResolutionDescription")
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
        updateCases.setParams({
            "success" : success
        });
        updateCases.fire();
        console.log("event fired");
    }
})