/**
 * Created by mschetselaar on 9/10/2018.
 */
({
    addActivity : function (component, event, helper) {
        var action = component.get("c.AddActivityApx");
        action.setParams({
            CaseId : component.get("v.CaseId"),
            TaskId : component.get("v.TaskId"),
            isTask : component.get("v.isTask"),
            newTask : component.get("v.newTask"),
            newEvent : component.get("v.newEvent")
        });

        action.setCallback(this, function (response) {
            console.log("updated Case: ", response.getState());
            var name = response.getState();
            if (name === "SUCCESS") {

                helper.updateCases(component, event, helper, true);
                // helper.updateSpinner(component, event, helper, false);
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
    },

})