/**
 * Created by mschetselaar on 9/6/2018.
 */
({
    getAllTasks : function(component, event, helper) {
        console.log('getting open Tasks');
        var caseId = component.get("v.case.Id");
        var action = component.get("c.getAllTasksApx");
        action.setParams({
            caseId : caseId
        });

        action.setCallback(this, function (response) {
            console.log('Tasks Returned',response.getReturnValue());
            var name = response.getState();
            if (name === "SUCCESS") {
                component.set("v.allTasks", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);

    },



})